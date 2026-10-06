#!/usr/bin/env python3
"""Compare the music of the port with the original: the sequence of tones per channel.

MZ-800 (mz800emu): writes to the SN76489 (port F2h) logged by a breakpoint, decoded to
divider N and attenuation per channel. SAPI (SAPIemu io_log): writes to the YM3812,
decoded to F-number / block (frequency) and total level / key per channel.
Both give a list of tone changes (channel, Hz) and volume changes; the script prints
the first notes of each channel side by side and how many of them agree (within 1 %).

  sound_check.py [--ms 4000] [--game]
"""
import argparse, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'emu'))
sys.path.insert(0, os.path.join(HERE, 'mz'))
import sapimcp as sm

ROOT = os.path.normpath(os.path.join(HERE, '..'))
PSG_CLK = 3546895 / 32


def mz_tones(ms, game):
    from mzemu import Emu
    bpt = os.path.join(ROOT, 'build', 'mzemu', 'mz800-breakpoints.bpt')
    if os.path.exists(bpt):
        os.remove(bpt)
    e = Emu()
    try:
        e.load_mzf()
        e.run_until(0x2000)
        if game:
            e.run_frames(250)
            e.press('SPACE')
            e.run_frames(5)
            e.release('SPACE')
            e.run_frames(150)
        e.call('debugger_activate')
        e.call('bp_create_with_init', {'addr': 0xF2, 'fields': ['type', 'port', 'action', 'enabled'],
                                       'type': 'IORQ_W', 'port': 0xF2, 'action': 'log "PSG %X", A',
                                       'enabled': True})
        e.run_frames(ms // 20)
        log = e.errlog.name
    finally:
        e.close()
    writes = [int(m.group(1), 16) for m in re.finditer(r'\[BP-LOG\] PSG ([0-9A-F]+)', open(log).read())]
    tones = {0: [], 1: [], 2: []}
    reg = [0] * 8
    latch = 0
    for v in writes:
        if v & 0x80:
            latch = (v >> 4) & 7
            if latch & 1:
                reg[latch] = v & 15
            elif latch < 6:
                reg[latch] = (reg[latch] & 0x3F0) | (v & 15)
            continue
        if latch & 1:
            reg[latch] = v & 15
        elif latch < 6:
            reg[latch] = ((v & 0x3F) << 4) | (reg[latch] & 15)
            n = reg[latch] or 1024
            tones[latch // 2].append(PSG_CLK / n if n >= 18 else 0.0)   # N = 1: a rest
    return tones, len(writes)


def sapi_tones(ms, game):
    sm.call('pause')
    sm.call('load_state', name='cpm')
    sm.call('load_binary', address='0100', path=os.path.join(ROOT, 'build', 'flappy.com'))
    sm.call('set_registers', pc='0100')
    if game:
        sm.call('run_for', ms=4000)
        sm.call('joystick', pressed=['fire1'])
        sm.call('run_for', ms=100)
        sm.call('joystick', pressed=[])
        sm.call('run_for', ms=2900)
    sm.call('io_log', enable=True, clear=True)
    lines = []
    left = ms
    while left > 0:
        k = min(left, 20)
        sm.call('run_for', ms=k)
        left -= k
        r = sm.call('io_log', count=100000)
        sm.call('io_log', clear=True)
        lines += r.splitlines()
    sm.call('io_log', enable=False)
    regs = {}
    tones = {0: [], 1: [], 2: []}
    addr = None
    for l in lines:
        m = re.search(r'OUT 5([67]) <- ([0-9A-F]{2})', l)
        if not m:
            continue
        if m.group(1) == '6':
            addr = int(m.group(2), 16)
            continue
        v = int(m.group(2), 16)
        regs[addr] = v
        if 0xB0 <= addr <= 0xB2:
            ch = addr - 0xB0
            fnum = regs.get(0xA0 + ch, 0) | ((v & 3) << 8)
            block = (v >> 2) & 7
            f = fnum * 49716 / 2 ** (20 - block) if v & 0x20 else 0.0   # key off = rest
            if not tones[ch] or abs(tones[ch][-1] - f) > 0.01:
                tones[ch].append(f)
    return tones


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--ms', type=int, default=4000)
    ap.add_argument('--game', action='store_true')
    a = ap.parse_args()
    mz, n = mz_tones(a.ms, a.game)
    sp = sapi_tones(a.ms, a.game)
    print('MZ PSG writes: %d' % n)
    for ch in range(3):
        # the MZ list has every tone write, the SAPI list only changes: compare the changes
        m = [f for i, f in enumerate(mz[ch]) if i == 0 or abs(mz[ch][i - 1] - f) > 0.01]
        s = sp[ch]
        k = min(len(m), len(s))
        # align on the first common tone
        off = 0
        for o in range(min(10, len(s))):
            if m and abs(s[o] - m[0]) <= 0.01 * max(m[0], 1):
                off = o
                break
        same = sum(1 for i in range(min(len(m), len(s) - off)) if abs(m[i] - s[i + off]) <= 0.01 * max(m[i], 1))
        print('channel %d: MZ %d tones, SAPI %d, the same (1 %%) %d of %d' % (ch, len(m), len(s), same, min(len(m), len(s) - off)))
        print('   MZ  ', ' '.join('%.0f' % f for f in m[:16]))
        print('   SAPI', ' '.join('%.0f' % f for f in s[off:off + 16]))


if __name__ == '__main__':
    main()
