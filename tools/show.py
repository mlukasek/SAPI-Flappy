#!/usr/bin/env python3
"""show.py ADDR [LINES] [FILE]: print the disassembly from the line containing ADDR (hex)."""
import re, sys
a = int(sys.argv[1], 16)
n = int(sys.argv[2]) if len(sys.argv) > 2 else 40
f = sys.argv[3] if len(sys.argv) > 3 else 'build/flappy_dis.asm'
lines = open(f).read().splitlines()
best = 0
for i, l in enumerate(lines):
    m = re.search(r'; ([0-9A-F]{4})\b', l)
    if m and int(m.group(1), 16) <= a:
        best = i
    elif m and int(m.group(1), 16) > a and best:
        break
for l in lines[max(0, best - 2):best + n]:
    print(l[:110])
