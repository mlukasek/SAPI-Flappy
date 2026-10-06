#!/usr/bin/env python3
"""Compare the screen of the SAPI port (SAPIemu, CGA-1V) with the MZ-800 original
(mz800emu) at every game step.

Both builds get the same test patches (TEST_PATCH): random without the R register
and the code bytes, the direction keys from the byte 7F80h, the joystick off, and a
sync point (7F90h) at every wait for interrupt ticks (2217h, 2F48h). The script runs
both machines from sync point to sync point, sets the input of the scenario and
compares the MZ planes I and II with the CGA (converted the same way as the port).

  compare.py [--steps N] [--scen title|play] [--dump DIR]

Needs sapiemu-cli with MCP (SAPIEMU_MCP, see tools/emu/sapimcp.py) and mz800emu.
"""
import argparse, base64, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'emu'))
sys.path.insert(0, os.path.join(HERE, 'mz'))
sys.path.insert(0, HERE)
import sapimcp as sm
from mzemu import Emu
import png

ROOT = os.path.normpath(os.path.join(HERE, '..'))
SYNC = 0x7F90
INPUT = 0x7F80
TEST_PATCH = [
    (0x7F90, 'C9'),                                   # sync: RET
    (0x7FA0, 'CD907F 3A195C C34B2F'),                 # wait_ticks2: sync, LD A,(5C19h), back
    (0x7FB0, 'CD907F 3A195C C31A22'),                 # wait_ticks: sync, LD A,(5C19h), back
    (0x2F48, 'C3A07F'),
    (0x2217, 'C3B07F'),
    (0x393F, '3A807F 328F39 C9'),                     # read_dir: A = (7F80h)
    (0x3B3A, 'AF C9'),                                # read_joy: nothing
    (0x3990, '3A827F B7 2808 3D 32827F 3A817F C9 AF C9'),  # read_key: (7F81h) for (7F82h) calls (2: the menu reads twice a round)
    (0x3B82, 'E5 2A9C3B 29 3004 7D EE2D 6F 229C3B 7D E1 C9'),   # random: 16-bit LFSR
    (0x3B9C, '3412'),
    (0x2236, 'C3C07F'),                               # delay_2000: sync (stub per build)
    (0x7FD0, 'CD907F C33F39'),                        # sync, then read_dir
    (0x532A, 'CDD07F'),                               # "Hit SPACE KEY" loop after a stage
]
MZ_PATCH = [(0x7FC0, 'CD907F F5 E5 210020 C33B22')]   # sync, PUSH AF, PUSH HL, LD HL,2000h, back


def sapi_patch():
    for line in open(os.path.join(ROOT, 'build', 'flappy.sym')):
        m = re.match(r'delay_2000_s\s+EQU\s+0*([0-9A-F]+)H', line)
        if m:
            a = int(m.group(1), 16)
            return [(0x7FC0, 'CD907F C3%02X%02X' % (a & 255, a >> 8))]
    raise SystemExit('delay_2000_s not in build/flappy.sym')
# read_dir bits: 80h space, 10h, 08h, 04h directions, 02h BREAK; read_key: MZ key code
# (0Dh CR, F0h-F4h F1-F5, ASCII). Scenario: (first step, last step, {'dir': v, 'key': v,
# 'poke': [(addr, value)] at the first step only})
START = [(60, 62, {'dir': 0x80})]
SCEN = {
    'title': [],
    'play': START + [(100, 104, {'dir': 0x10}), (110, 120, {'dir': 0x08}), (130, 140, {'dir': 0x20}),
                     (150, 152, {'dir': 0x80}), (160, 175, {'dir': 0x04}), (180, 200, {'dir': 0x10}),
                     (210, 230, {'dir': 0x08}), (240, 260, {'dir': 0x20}), (270, 300, {'dir': 0x04}),
                     (320, 322, {'dir': 0x02}), (400, 430, {'dir': 0x10}), (440, 470, {'dir': 0x20})],
    'clear': START + [(100, 100, {'poke': [(0x2246, 1)]}), (200, 230, {'dir': 0x10}),
                      (300, 300, {'poke': [(0x2246, 1)]}), (400, 420, {'dir': 0x08})],
    'ending': START + [(100, 100, {'poke': [(0x5C1B, 200), (0x2246, 1)]}), (200, 202, {'dir': 0x80}),
               (1500, 1502, {'dir': 0x80})],
    'menu': START + [(100, 100, {'poke': [(0x502F, 1)]}), (101, 103, {'dir': 0x02}),
                     (180, 182, {'key': 0x0D}), (200, 202, {'key': 0x0D}), (220, 222, {'key': 0x0D}),
                     (260, 262, {'key': 0xF0}), (270, 272, {'key': 0x33}), (290, 292, {'key': 0xF1}),
                     (300, 302, {'key': 0x53}), (306, 308, {'key': 0x48}), (312, 314, {'key': 0x49}),
                     (318, 320, {'key': 0x42}), (324, 326, {'key': 0x41}), (330, 332, {'key': 0x0D}),
                     (360, 362, {'key': 0x0D}), (500, 502, {'dir': 0x80}), (600, 640, {'dir': 0x10})],
    'keyword': START + [(100, 100, {'poke': [(0x502F, 1)]}), (101, 103, {'dir': 0x02}),
                        (180, 182, {'key': 0x0D}), (200, 202, {'key': 0x0D}), (220, 222, {'key': 0x0D}),
                        (290, 292, {'key': 0xF1}), (300, 300, {'key': 0x4D}), (306, 306, {'key': 0x65}),
                        (312, 312, {'key': 0x67}), (318, 318, {'key': 0x6D}), (324, 324, {'key': 0x49}),
                        (340, 340, {'key': 0x0D}), (400, 402, {'dir': 0x80})],
    'fkeys': START + [(100, 102, {'key': 0xF2}), (150, 152, {'key': 0xF4}), (200, 202, {'key': 0xF0}),
                      (210, 260, {'dir': 0x08})],
}


def rev8(b):
    return int('{:08b}'.format(b)[::-1], 2)


REV = [rev8(b) for b in range(256)]


def mz_to_cga(p1, p2):
    out = bytearray(16000)
    for i in range(8000):
        r1, r2 = REV[p1[i]], REV[p2[i]]
        out[2 * i] = (r1 & 0xF0) | (r2 >> 4)
        out[2 * i + 1] = ((r1 << 4) & 0xF0) | (r2 & 0x0F)
    return bytes(out)


def cga_png(path, cga):
    pal = [(0, 0, 0), (64, 64, 172), (208, 52, 0), (232, 212, 48)]
    rows = []
    for y in range(200):
        row = []
        for x in range(80):
            b = cga[y * 80 + x]
            for k in range(4):
                c = ((b >> (7 - k)) & 1) | (((b >> (3 - k)) & 1) << 1)
                row.append(pal[c])
        rows.append(row)
    png.write(path, 320, 200, rows)


class Sapi:
    def __init__(self):
        sm.call('pause')
        try:
            sm.call('load_state', name='cpm')
        except RuntimeError:
            sm.call('power', state='cycle')
            sm.call('resume')
            sm.call('run_until', screen_text='Zadej 0-3', timeout_ms=20000)
            sm.call('type_text', text='1')
            sm.call('run_until', screen_text='A>', timeout_ms=30000)
            sm.call('pause')
            sm.call('save_state', name='cpm')
        sm.call('pause')
        sm.call('load_binary', address='0100', path=os.path.join(ROOT, 'build', 'flappy.com'))
        for a, h in TEST_PATCH + sapi_patch():
            sm.call('write_memory', address='%04X' % a, data=' '.join(re.findall('..', h.replace(' ', ''))))
        sm.call('set_registers', pc='0100')

    def sync(self):
        r = sm.call('run_until', address='%04X' % SYNC, timeout_ms=20000)
        assert r.get('stopped') != 'timeout', r
        return r

    def poke(self, a, v):
        sm.call('write_memory', address='%04X' % a, data='%02X' % v)

    def read(self, a, n):
        out = b''
        while len(out) < n:
            k = min(4096, n - len(out))
            h = sm.call('read_memory', address='%04X' % (a + len(out)), length=k, format='hex')
            b = bytes.fromhex(re.sub(r'[^0-9A-Fa-f]', '', h))
            assert len(b) == k
            out += b
        return out

    def screen(self):
        return self.read(0xC000, 16000)


class Mz:
    def __init__(self):
        self.e = Emu()
        self.e.load_mzf()
        self.e.run_until(0x2000)
        for a, h in TEST_PATCH + MZ_PATCH:
            self.e.poke(a, bytes.fromhex(h.replace(' ', '')))

    def sync(self):
        return self.e.run_until(SYNC)

    def poke(self, a, v):
        self.e.poke(a, v)

    def screen(self):
        p = []
        for rid in (8, 9):
            d = self.e.data('region_read', {'region_id': rid, 'offset': 0, 'length': 8000})
            p.append(base64.b64decode(d['data_b64']))
        return mz_to_cga(*p)

    def close(self):
        self.e.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--steps', type=int, default=300)
    ap.add_argument('--scen', default='play')
    ap.add_argument('--dump', default='')
    ap.add_argument('--every', type=int, default=1, help='compare every N steps')
    ap.add_argument('--sp', action='store_true', help='print SP of both at every step')
    a = ap.parse_args()
    if a.dump:
        os.makedirs(a.dump, exist_ok=True)
    s = Sapi()
    m = Mz()
    bad = 0
    try:
        for step in range(a.steps):
            d = k = 0
            pokes = []
            for f0, f1, act in SCEN[a.scen]:
                if f0 <= step <= f1:
                    d = act.get('dir', d)
                    k = act.get('key', k)
                    if step == f0:
                        pokes += act.get('poke', [])
            rs = s.sync()
            rm = m.sync()
            if a.sp:
                print('step %d SP sapi %s mz %04X' % (step, rs['registers']['sp'], rm['SP']))
            if k and any(f0 == step and 'key' in act for f0, f1, act in SCEN[a.scen]):
                pokes += [(INPUT + 1, k), (INPUT + 2, 2)]
            for addr, val in [(INPUT, d)] + pokes:
                s.poke(addr, val)
                m.poke(addr, val)
            if step % a.every:
                continue
            cs, cm = s.screen(), m.screen()
            if cs != cm:
                bad += 1
                diff = [i for i in range(16000) if cs[i] != cm[i]]
                print('step %d: %d bytes differ, first at line %d byte %d' % (step, len(diff), diff[0] // 80, diff[0] % 80))
                if a.dump and bad <= 5:
                    cga_png(os.path.join(a.dump, 'sapi_%04d.png' % step), cs)
                    cga_png(os.path.join(a.dump, 'mz_%04d.png' % step), cm)
                if bad >= 20:
                    break
            elif a.dump and step % 50 == 0:
                cga_png(os.path.join(a.dump, 'ok_%04d.png' % step), cs)
        print('%d steps, %d with a different screen' % (step + 1, bad))
        print('stage SAPI %d MZ %d' % (s.read(0x5C1B, 1)[0], m.e.peek(0x5C1B)[0]))
    finally:
        m.close()


if __name__ == '__main__':
    main()
