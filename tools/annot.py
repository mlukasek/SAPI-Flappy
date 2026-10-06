"""Annotations for tools/mkdis.py (MZ-800 Flappy disassembly)."""

# (start, end_exclusive, name): memory image after the loader
SEGMENTS = [
    (0x0100, 0x1500, 'low block (loaded from B400h): interrupt, sound, music'),
    (0x2000, 0x8000, 'main program'),
    (0xB000, 0xE300, 'stage data (loaded from 8000h)'),
]

ENTRIES = [0x2000, 0x0100, 0x0103, 0x0106, 0x01A9]

# calls that never return / instructions after which code does not continue
NORETURN = set()
NORETURN_AFTER = set()

# bytes that are never code
DATA_FORCE = set()

# (start, end_exclusive, kind) kind = 'db' | 'dw'
DATA_RANGES = [
]

# ld rr,nn at these instruction addresses: nn is a number / an address
# ld rr,nn immediates in these ranges are taken as addresses (the low block stays at its address)
IMM_RANGES = [(0x2000, 0x8000), (0xB000, 0xE300)]
IMM_NUM = {0x013F, 0x0258,             # ld bc,74D7h: B = 8253 control word, C = port D7h
           0x3C00, 0x3C2C, 0x3C73, 0x3CB5, 0x3CF7,   # ld bc,22CCh: B = GDG WF value, C = port CCh
           0x3B8F,                     # ld bc,7F3Fh: end of the code area used as random bytes
           0x3E67,                     # ld de,2710h = 10000
           0x2238}                     # ld hl,2000h: delay count
IMM_ADDR = set()

# addresses outside the image with a name
EQU = {
}

NAMES = {
}

COMMENTS = {
}

LINE_CMT = {
}
