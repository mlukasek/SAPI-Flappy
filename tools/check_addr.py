#!/usr/bin/env python3
"""Check that the SAPI build keeps the addresses of the original.

Every symbol of orig/flappy.asm that is also in the SAPI build must be at
the same address (the stage data B000-E2FF of the MZ is at 8000h, -3000h).
The game has pointers in data tables that are not labels, so the code of
0100-14FF and 2000-7FFF must not move. Symbols moved on purpose are listed
in MOVED.
"""
import os, re, subprocess, sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
PASMO = os.environ.get('PASMO', r'E:\SAPI_GIT\Tools\pasmo-0.5.3\pasmo.exe')
MOVED = {'map_buf', 'map_buf_29', 'ext_vectors_2'}


def syms(path):
    out = {}
    for line in open(path):
        m = re.match(r'(\S+)\s+EQU\s+0*([0-9A-F]+)H', line)
        if m:
            out[m.group(1)] = int(m.group(2), 16)
    return out


def main():
    build = os.path.join(ROOT, 'build')
    orig_sym = os.path.join(build, 'orig.sym')
    subprocess.check_call([PASMO, '--bin', os.path.join(ROOT, 'orig', 'flappy.asm'),
                           os.path.join(build, 'orig.bin'), orig_sym], stdout=subprocess.DEVNULL)
    o = syms(orig_sym)
    s = syms(os.path.join(build, 'flappy.sym'))
    bad = 0
    for name, a in sorted(o.items(), key=lambda kv: kv[1]):
        if name in MOVED or name not in s:
            continue
        want = a - 0x3000 if 0xB000 <= a < 0xE300 else a
        if s[name] != want:
            bad += 1
            print('%-16s orig %04X, SAPI %04X (expected %04X)' % (name, a, s[name], want))
    missing = sorted(n for n in o if n not in s and n not in MOVED)
    print('%d symbols checked, %d moved, %d not in the SAPI build%s' %
          (len(o), bad, len(missing), (': ' + ' '.join(missing[:20])) if missing else ''))
    print('code_end %04X' % s.get('code_end', 0))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
