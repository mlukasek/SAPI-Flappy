"""Annotations for tools/mkdis.py (MZ-800 Flappy disassembly)."""

# (start, end_exclusive, name): memory image after the loader
SEGMENTS = [
    (0x0100, 0x1500, 'low block (loaded from B400h): interrupt, sound, music'),
    (0x2000, 0x8000, 'main program'),
    (0xB000, 0xE300, 'stage data (loaded from 8000h)'),
]

ENTRIES = [0x2000, 0x0100, 0x0103, 0x0106, 0x01A9,
           0x3E6E, 0x3E75, 0x3E7C,     # targets of the self-modified djnz at 3EADh (offset written at 3E7Fh)
           0x57DF, 0x57F3, 0x580D]     # called through the self-modified calls at 57CEh, 57D6h

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
    0xA000: 'map_buf',      # 40 x 22 cells of the play field (logic map)
    0xA029: 'map_buf_29',
    0xFA00: 'ext_vectors',  # table of 12 vectors copied for an external program (never read by the game)
    0xFA02: 'ext_vectors_2',
}

NAMES = {
    # low block: interrupt and PSG music driver
    0x0109: 'music_off', 0x010C: 'music_start', 0x0166: 'pause_wait', 0x0186: 'pause_key',
    0x01A9: 'isr', 0x01B7: 'ticks', 0x0649: 'psg_vol_cur', 0x064C: 'psg_vol', 0x066E: 'psg_note',
    0x0673: 'psg_tone', 0x0692: 'psg_tone2', 0x06BA: 'psg_noise_vol', 0x0764: 'note_table',
    # main program
    0x2000: 'start', 0x204E: 'restart', 0x205E: 'title_loop', 0x207E: 'stage_start', 0x20B1: 'main_loop',
    0x2119: 'lose_life', 0x2133: 'check_clear', 0x2217: 'wait_ticks', 0x2236: 'delay_2000',
    0x2243: 'dying', 0x2246: 'stage_clear', 0x225B: 'speed_table', 0x2266: 'keywords',
    0x232E: 'title', 0x2A3A: 'fall_test', 0x2DFE: 'scroll_logo', 0x2E3B: 'copy_row', 0x2E4B: 'logo_row',
    0x2E90: 'put_obj', 0x2E9F: 'cls', 0x2ECF: 'cls_lower',
    0x2EFA: 'box_top', 0x2F08: 'box_right', 0x2F13: 'box_bottom', 0x2F21: 'box_left',
    0x2F2C: 'row_down', 0x2F3A: 'row_up', 0x2F48: 'wait_ticks2', 0x2F66: 'poll_keys',
    0x3747: 'quit_req', 0x3748: 'speed_req', 0x386A: 'key_held', 0x3936: 'last_key', 0x3937: 'speed_digit',
    0x3939: 'keyword_buf', 0x393F: 'read_dir', 0x398F: 'dir_state', 0x3990: 'read_key', 0x3B24: 'key_row',
    0x3B3A: 'read_joy', 0x3B82: 'random', 0x3BA0: 'delay', 0x3BB2: 'vaddr_field', 0x3BC5: 'vaddr',
    0x3BD8: 'map_addr', 0x3BF1: 'put8x8', 0x3C0C: 'put8x8_plane', 0x3C1C: 'put16x8', 0x3C39: 'put16x8_plane',
    0x3C4D: 'put16x16', 0x3C8D: 'put24x16', 0x3CD1: 'put16x24', 0x3D11: 'clr8', 0x3D21: 'clr8_rows',
    0x3D2A: 'clr16x8', 0x3D45: 'clr8x16', 0x3D55: 'print', 0x3DAD: 'print_char', 0x3DEA: 'print_big',
    0x3E06: 'put_char', 0x3E26: 'put_char_plane', 0x3E46: 'put_char_rows', 0x3E54: 'text_colour',
    0x3E55: 'print_num',
    0x502F: 'lives', 0x5032: 'player_state', 0x512C: 'clear_screen_seq', 0x51EA: 'wipe',
    0x5385: 'draw_field_bg', 0x53E0: 'load_stage', 0x5739: 'clear_map', 0x57B3: 'pattern_rows',
    0x57BA: 'pattern_cols4', 0x57C1: 'pattern_cols2', 0x57C5: 'pattern_draw',
    0x5C19: 'tick_div', 0x5C1B: 'stage', 0x5C1C: 'keyword_idx', 0x3F32: 'time_left',
    0x6ADD: 'font', 0x7978: 'ending',
    0xB000: 'stage_count', 0xB001: 'stage_data',
}

COMMENTS = {
}

LINE_CMT = {
}
