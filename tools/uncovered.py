#!/usr/bin/env python3
"""List decoded instructions that no CDL run executed (ranges)."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mkdis
d = mkdis.Dis()
d.run()
rs, s = [], None
for a in sorted(d.ins):
    ne = a not in d.xs
    if ne and s is None:
        s = a
    if not ne and s is not None:
        rs.append((s, pe))
        s = None
    pe = a + d.ins[a].length - 1
if s is not None:
    rs.append((s, pe))
print(' '.join('%04X-%04X(%d)' % (x, y, y - x + 1) for x, y in rs if y - x >= int(sys.argv[1] if len(sys.argv) > 1 else 0)))
print('executed but not decoded:', ' '.join('%04X' % a for a in d.uncovered[:100]))
