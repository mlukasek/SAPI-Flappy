#!/usr/bin/env python3
"""Disassemble the MZ-800 Flappy memory image into pasmo source.

Code is found by recursive descent from known entry points plus everything
the mz800emu Code/Data Logger saw executed (CDL exports in build/cdl*).
Annotations (names, extra entries, data tables, immediates that are not
addresses) are in tools/annot.py.

  mkdis.py report      code/data map, conflicts, immediate operands to review
  mkdis.py asm OUT     write the source (assembles to the same image)
"""
import glob, os, struct, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from z80dis import decode
import annot

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
MZF = os.path.join(ROOT, 'SHARP', 'Flappy.mzf')


def load_image():
    """Memory after the loader at 1E00h has run (see orig/README)."""
    d = open(MZF, 'rb').read()
    body = d[128:]
    m = bytearray(65536)
    m[0x1E00:0x1E00 + len(body)] = body
    m[0x0100:0x1500] = m[0xB400:0xC800]
    tmp = bytes(m[0x8000:0xB300])
    m[0xC000:0xF300] = tmp
    m[0xB000:0xE300] = tmp
    return m


SEGS = annot.SEGMENTS   # list of (start, end_exclusive, name)


def in_seg(a):
    for s, e, n in SEGS:
        if s <= a < e:
            return True
    return False


def cdl_exec():
    xs = set()
    for meta in glob.glob(os.path.join(ROOT, 'build', 'cdl*', 'flappy.json')):
        m = json.load(open(meta))
        r = [r for r in m['regions'] if r['name'] == 'ram'][0]
        d = open(os.path.join(os.path.dirname(meta), r['file']), 'rb').read()
        cs = r['size_bytes'] // r['size_cells']
        for a in range(65536):
            if struct.unpack_from('<I', d, a * cs + 8)[0]:
                xs.add(a)
    return xs


class Dis:
    def __init__(self):
        self.mem = load_image()
        self.ins = {}          # addr -> Ins
        self.owner = {}        # byte addr -> instruction start
        self.conflicts = []
        self.xs = cdl_exec()

    def descend(self, seeds):
        todo = list(seeds)
        while todo:
            a = todo.pop()
            while True:
                if a in self.ins or not in_seg(a):
                    break
                if a in annot.DATA_FORCE or any(s <= a < e for s, e, *_ in annot.DATA_RANGES):
                    self.conflicts.append((a, 'descent into data'))
                    break
                i = decode(self.mem, a)
                clash = [b for b in range(a, a + i.length) if b in self.owner]
                if clash:
                    self.conflicts.append((a, 'overlaps instruction at %04X' % self.owner[clash[0]]))
                    break
                self.ins[a] = i
                for b in range(a, a + i.length):
                    self.owner[b] = a
                if i.target is not None and i.flow in ('jump', 'cjump', 'call', 'ccall'):
                    todo.append(i.target)
                if i.flow in ('jump', 'ret', 'stop'):
                    break
                if a in annot.NORETURN_AFTER:
                    break
                if i.flow in ('call', 'ccall') and i.target in annot.NORETURN:
                    if i.flow == 'call':
                        break
                a += i.length

    def run(self):
        seeds = list(annot.ENTRIES)
        # start of every CDL-executed run is an instruction start
        prev = False
        for a in range(65536):
            x = a in self.xs
            if x and not prev and in_seg(a):
                seeds.append(a)
            prev = x
        self.descend(seeds)
        # executed bytes not covered by descent
        self.uncovered = sorted(a for a in self.xs if in_seg(a) and a not in self.owner)

    # ---- labels
    def refs(self):
        """address -> set of kinds that reference it"""
        refs = {}
        for a, i in self.ins.items():
            if i.target is not None and i.flow != 'rst':
                refs.setdefault(i.target, set()).add(i.flow)
            if i.nn is not None and i.nn_kind in ('mem',):
                refs.setdefault(i.nn, set()).add('mem')
            if i.nn is not None and i.nn_kind == 'imm' and self.imm_is_addr(a, i):
                refs.setdefault(i.nn, set()).add('imm')
        for t in annot.DATA_RANGES:
            s, e, kind = t[0], t[1], t[2]
            if kind == 'dw':
                for p in range(s, e, 2):
                    v = self.mem[p] | self.mem[p + 1] << 8
                    if self.dw_is_addr(v):
                        refs.setdefault(v, set()).add('dw')
        for a in annot.NAMES:
            refs.setdefault(a, set()).add('name')
        return refs

    def dw_is_addr(self, v):
        return in_seg(v) or v in annot.EQU

    def imm_is_addr(self, a, i):
        if a in annot.IMM_NUM:
            return False
        if a in annot.IMM_ADDR:
            return True
        return any(s <= i.nn < e for s, e in annot.IMM_RANGES) or i.nn in annot.EQU

    def label(self, v):
        if v in annot.NAMES:
            return annot.NAMES[v]
        if v in annot.EQU:
            return annot.EQU[v]
        return 'L%04X' % v


def hx(v, w=2):
    s = ('%0' + str(w) + 'X') % v
    return ('0' + s if s[0] in 'ABCDEF' else s) + 'h'


def report(d):
    print('conflicts:')
    for a, why in d.conflicts:
        print('  %04X %s' % (a, why))
    print('executed but not decoded:', ' '.join('%04X' % a for a in d.uncovered[:200]))
    # code coverage
    code = sorted(d.ins)
    print('instructions:', len(code), ' not executed:', sum(1 for a in code if a not in d.xs))
    print('immediates treated as addresses:')
    for a in sorted(d.ins):
        i = d.ins[a]
        if i.nn is not None and i.nn_kind == 'imm' and d.imm_is_addr(a, i) and a not in annot.IMM_ADDR:
            print('  %04X  %s' % (a, i.render()))
    print('immediates treated as numbers (16-bit, >= 0100h):')
    for a in sorted(d.ins):
        i = d.ins[a]
        if i.nn is not None and i.nn_kind == 'imm' and not d.imm_is_addr(a, i) and i.nn >= 0x100:
            print('  %04X  %s' % (a, i.render()))


def write_asm(d, path):
    refs = d.refs()
    mem = d.mem
    out = []
    w = out.append
    w('; Flappy (dB-SOFT 1984), Sharp MZ-800 - disassembly generated by tools/mkdis.py')
    w('; Memory image after the loader at 1E00h (see README). Assembles with pasmo 0.5.3.')
    w('')
    # equates for addresses outside the image
    used_equ = sorted(v for v in refs if not in_seg(v))
    for v in used_equ:
        w('%-16s equ %s' % (d.label(v), hx(v, 4)))
    w('')
    for s, e, segname in SEGS:
        w('; ' + '=' * 70)
        w('; %s %04X-%04X' % (segname, s, e - 1))
        w('')
        w('\torg %s' % hx(s, 4))
        a = s
        while a < e:
            if a in annot.COMMENTS:
                for c in annot.COMMENTS[a].split('\n'):
                    w('; ' + c if c else ';')
            lab = d.label(a) if a in refs else None
            if a in d.ins:
                i = d.ins[a]
                nn = None
                if i.nn is not None:
                    use = (i.nn_kind in ('jump', 'call', 'mem')) or (i.nn_kind == 'imm' and d.imm_is_addr(a, i))
                    if use and i.nn in refs:
                        nn = d.label(i.nn)
                e_ = d.label(i.e) if i.e is not None else None
                text = i.render(nn, e_)
                if i.undoc and not text.startswith('defb'):
                    text = 'defb ' + ','.join(hx(b) for b in i.bytes) + '\t; ' + text
                cmt = annot.LINE_CMT.get(a, '')
                line = '%s\t%s' % ((lab + ':') if lab else '', text)
                line = line.expandtabs(16) if False else line
                w('%-40s; %04X%s' % (line, a, ('  ' + cmt) if cmt else ''))
                for k in range(1, i.length):
                    if a + k in refs:
                        w('%-16s equ %s+%d' % (d.label(a + k), lab or ('$-%d' % (i.length)), k) if lab else
                          '%-16s equ $-%d' % (d.label(a + k), i.length - k))
                a += i.length
                continue
            # data
            kind = 'db'
            rng = None
            for t in annot.DATA_RANGES:
                if t[0] <= a < t[1]:
                    kind = t[2]
                    rng = t
                    break
            if kind == 'dw' and (a - rng[0]) % 2 == 0 and a + 1 < rng[1]:
                v = mem[a] | mem[a + 1] << 8
                txt = d.label(v) if (v in refs and d.dw_is_addr(v)) else hx(v, 4)
                w('%-40s; %04X' % ('%s\tdefw %s' % ((lab + ':') if lab else '', txt), a))
                if a + 1 in refs:
                    w('%-16s equ $-1' % d.label(a + 1))
                a += 2
                continue
            # run of db up to 16 bytes, stop at labels / code / range changes
            b = a + 1
            while b < e and b - a < 16 and b not in refs and b not in d.ins and b not in annot.COMMENTS:
                inr = None
                for t in annot.DATA_RANGES:
                    if t[0] <= b < t[1]:
                        inr = t
                        break
                if inr is not rng:
                    break
                b += 1
            # long zero runs
            if all(mem[k] == 0 for k in range(a, b)) and b - a == 16:
                z = a
                while z < e and mem[z] == 0 and (z == a or (z not in refs and z not in d.ins and z not in annot.COMMENTS)):
                    inr = None
                    for t in annot.DATA_RANGES:
                        if t[0] <= z < t[1]:
                            inr = t
                            break
                    if inr is not rng:
                        break
                    z += 1
                w('%-40s; %04X' % ('%s\tdefs %d' % ((lab + ':') if lab else '', z - a), a))
                a = z
                continue
            w('%-40s; %04X' % ('%s\tdefb %s' % ((lab + ':') if lab else '', ','.join(hx(mem[k]) for k in range(a, b))), a))
            a = b
        w('')
    w('\tend')
    open(path, 'w', newline='\n').write('\n'.join(out) + '\n')


def main():
    d = Dis()
    d.run()
    if sys.argv[1] == 'report':
        report(d)
    elif sys.argv[1] == 'asm':
        write_asm(d, sys.argv[2])


if __name__ == '__main__':
    main()
