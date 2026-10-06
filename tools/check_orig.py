#!/usr/bin/env python3
"""Check that orig/flappy.asm assembles to the memory image of the original (SHARP/Flappy.mzf after its loader)."""
import os, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mkdis import load_image, ROOT, SEGS

PASMO = os.environ.get('PASMO', r'E:\SAPI_GIT\Tools\pasmo-0.5.3\pasmo.exe')
out = os.path.join(ROOT, 'build')
os.makedirs(out, exist_ok=True)
binf, symf = os.path.join(out, 'orig.bin'), os.path.join(out, 'orig.sym')
subprocess.check_call([PASMO, '--bin', os.path.join(ROOT, 'orig', 'flappy.asm'), binf, symf])
b = open(binf, 'rb').read()
img = bytearray(65536)
img[0x100:0x100 + len(b)] = b
m = load_image()
bad = 0
for s, e, n in SEGS:
    d = [a for a in range(s, e) if img[a] != m[a]]
    bad += len(d)
    print('%04X-%04X %s: %s' % (s, e - 1, n, 'OK' if not d else '%d bytes differ, first %04X' % (len(d), d[0])))
sys.exit(1 if bad else 0)
