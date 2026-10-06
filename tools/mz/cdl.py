#!/usr/bin/env python3
"""Load and summarize mz800emu CDL exports.

cdl.py DIR [DIR...]   prints R/W/X ranges of RAM, I/O port counts and VRAM usage (merged over all dirs).
"""
import json, os, struct, sys


class Cdl:
    def __init__(self, meta):
        self.dir = os.path.dirname(os.path.abspath(meta))
        self.m = json.load(open(meta))
        self.regions = {r['name']: r for r in self.m['regions']}
        self.cache = {}

    def region(self, name):
        if name not in self.cache:
            r = self.regions[name]
            d = open(os.path.join(self.dir, r['file']), 'rb').read()
            cs = r['size_bytes'] // r['size_cells']
            n = cs // 4
            self.cache[name] = [struct.unpack_from('<%dI' % n, d, i * cs) for i in range(r['size_cells'])]
        return self.cache[name]


def merged(dirs, name):
    out = None
    for d in dirs:
        reg = Cdl(os.path.join(d, 'flappy.json')).region(name)
        if out is None:
            out = [list(c) for c in reg]
        else:
            for i, c in enumerate(reg):
                for j, v in enumerate(c):
                    out[i][j] += v
    return out


def ranges(cells, pred, base=0):
    out, s = [], None
    for a, c in enumerate(cells):
        if pred(c):
            if s is None:
                s = a
        elif s is not None:
            out.append((s + base, a - 1 + base))
            s = None
    if s is not None:
        out.append((s + base, len(cells) - 1 + base))
    return out


def fmt(rs):
    return ' '.join('%04X-%04X' % r if r[0] != r[1] else '%04X' % r[0] for r in rs)


def main():
    dirs = sys.argv[1:]
    ram = merged(dirs, 'ram')
    for i, t in ((2, 'X'), (1, 'W'), (0, 'R')):
        print(t, fmt(ranges(ram, lambda c: c[i] > 0)))
        print()
    io = merged(dirs, 'iorq-8bit')
    for p in range(256):
        if any(io[p]):
            print('port %02X r=%d w=%d' % (p, io[p][0], io[p][1]))
    for n in ('vram800-320x200_4A-I', 'vram800-320x200_4A-II', 'vram800-320x200_4B-I', 'vram800-320x200_4B-II'):
        v = merged(dirs, n)
        print(n, 'R', fmt(ranges(v, lambda c: c[0] > 0, 0x8000)))
        print(n, 'W', fmt(ranges(v, lambda c: c[1] > 0, 0x8000)))


if __name__ == '__main__':
    main()
