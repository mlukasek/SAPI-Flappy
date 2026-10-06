#!/usr/bin/env python3
"""Find every instruction of the original that writes or reads MZ-800 VRAM (8000-9FFF).

Runs the title loop and a random play session with MEM_W / MEM_R breakpoints
that log PC. Hot routines already known can be excluded with --skip lo-hi,...
Prints instruction address -> hit count (mapped to instruction starts via the disassembler).
"""
import argparse, collections, os, random, re, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mzemu import Emu, ROOT
import mkdis


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--title', type=int, default=1500)
    ap.add_argument('--play', type=int, default=3000)
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--skip', default='')
    ap.add_argument('--read', action='store_true', help='log reads instead of writes')
    a = ap.parse_args()
    cond = []
    for r in [r for r in a.skip.split(',') if r]:
        lo, hi = [int(x, 16) for x in r.split('-')]
        cond.append('(PC < 0x%X || PC > 0x%X)' % (lo, hi + 1))
    bpt = os.path.join(ROOT, 'build', 'mzemu', 'mz800-breakpoints.bpt')
    if os.path.exists(bpt):
        os.remove(bpt)
    e = Emu()
    rnd = random.Random(a.seed)
    try:
        e.load_mzf()
        e.run_until(0x2000)
        e.call('debugger_activate')
        vals = {'type': 'MEM_R' if a.read else 'MEM_W', 'addr_end': 0x9FFF, 'addr_match_mode': 'RANGE',
                'action': 'log "V %X %X", PC, [0xE000]', 'enabled': True}
        fields = ['type', 'addr', 'addr_end', 'addr_match_mode', 'action', 'enabled']
        if cond:
            vals['expr'] = ' && '.join(cond)
            fields.append('expr')
        e.call('bp_create_with_init', dict(addr=0x8000, fields=fields, **vals))
        e.run_frames(a.title)
        done = 0
        while done < a.play:
            k = rnd.choice(['LEFT', 'RIGHT', 'UP', 'DOWN', 'SPACE', 'SPACE', None])
            n = rnd.randint(5, 60)
            if k:
                e.press(k)
            e.run_frames(n)
            if k:
                e.release(k)
            done += n
        log = e.errlog.name
    finally:
        e.close()
    d = mkdis.Dis()
    d.run()
    cnt = collections.Counter()
    for line in open(log):
        m = re.match(r'\[BP-LOG\] V ([0-9A-F]+)', line)
        if m:
            pc = int(m.group(1), 16)
            # PC is logged after the opcode fetch: find the instruction holding pc-1
            ins = d.owner.get((pc - 1) & 0xFFFF, None)
            cnt[ins if ins is not None else ('?%04X' % pc)] += 1
    for k, v in sorted(cnt.items(), key=lambda kv: str(kv[0]) if isinstance(kv[0], str) else '%04X' % kv[0]):
        if isinstance(k, int):
            print('%04X %8d  %s' % (k, v, d.ins[k].render()))
        else:
            print(k, v)


if __name__ == '__main__':
    main()
