; =====================================================================
;  SAPI-1 V platform layer for the Flappy port (replaces the MZ-800
;  GDG graphics, the 8253 interrupt, the keyboard matrix, the joystick
;  and the SN76489 PSG).
;
;  Hardware (machines/sapi1v.sapi of SAPIemu):
;  - RAM-1V MAP register 63h: C0h = MAP1 = MAP2 = H, CGA-1V at C000h
;    (RAM C000-FFFF hidden, CP/M is not called during the game);
;  - CGA-1V in CGA mode: 80 bytes per line, 4 pixels per byte, high
;    nibble = MZ plane I, low nibble = MZ plane II (D7/D3 = left pixel),
;    COLMASK 11h: colour index = plane I + 16 * plane II;
;  - MPH-1V at 50h: 82C54 (CLK0 = CLK2 = 55930.4 Hz), F2 interrupt on
;    /INT0 (JPR-1V: /INT, IM 1 = RST 38h), YM3812, joystick on K4;
;  - keyboard on JPR-1V (Consul 262.3 or EKL-1): STROBE on P0-IN0
;    (port 01h, active low), code on P1 (port 02h, inverted).
;
;  The game keeps MZ-800 VRAM addresses (8000h + y * 40 + x / 8) in all
;  its data; only the routines here touch the CGA:
;  CGA address = C000h + 2 * (MZ address - 8000h), see cga_addr.
; =====================================================================

MAPREG:		equ 063h		; RAM-1V MAP register
MAP_CGA:	equ 0C0h		; MAP1 = MAP2 = H
CGA:		equ 0C000h		; CGA-1V base
CGA_SIZE:	equ 16000		; 200 lines x 80 bytes
CGA_CFG:	equ CGA+03FFBh		; CONFIG (write), STATUS (read, D7 = VBI)
CGA_PAL_ADDR:	equ CGA+03FFCh		; Bt476 palette address
CGA_PAL_DATA:	equ CGA+03FFDh		; Bt476 R, G, B
CGA_COLMASK:	equ CGA+03FFEh		; Bt476 pixel mask
LINE:		equ 80			; CGA bytes per pixel line
CFG_GAME:	equ 004h		; CGA mode, CPU and display page A, no IRQ

PIT0:		equ 050h		; 82C54 counter 0
PIT2:		equ 052h		; 82C54 counter 2
PITCW:		equ 053h		; 82C54 control word (write)
MSTATUS:	equ 053h		; MPH-1V STATUS (read): D7 F2, D3 T0
MIEN:		equ 054h		; MPH-1V IEN (write)
JOY:		equ 054h		; joystick K4 (read)
MIACK:		equ 055h		; MPH-1V IACK (write)
YMADDR:		equ 056h		; YM3812 register address
YMDATA:		equ 057h		; YM3812 data

KSTB:		equ 001h		; P0-IN: D0 = keyboard STROBE (active low)
KDATA:		equ 002h		; P1-IN: key code (inverted)

; Interrupt: the MZ-800 game reloads 8253 counter 2 with 11 counts of
; 208.6 us in each interrupt (2.295 ms, 436 Hz). Here 82C54 counter 2
; runs in mode 2 with 128 (55930.4 / 128 = 437 Hz, 2.289 ms) and sets F2.
TICK_DIV:	equ 128
; Counter 0 in mode 3 with 224: 249.7 Hz (4.005 ms) = one unit of the
; MZ delay loop at 3BA0h (200 x 71 T at 3.5469 MHz = 4.004 ms).
UNIT_DIV:	equ 224
IEN_QUIET:	equ 028h		; gates G2 and G0, no interrupt
IEN_RUN:	equ 0A8h		; and the F2 interrupt

; Keys (see kbd_poll): a cursor key, space or BREAK stays down until
; the game reads its input (input_hook) or KEY_MAX ticks; other keys
; KEY_TIME ticks. Between two keys they are KEY_GAP ticks up.
KEY_MIN:	equ 8			; 18 ms
KEY_MAX:	equ 250			; 570 ms
KEY_TIME:	equ 44			; 100 ms
KEY_GAP:	equ 12			; 27 ms
KQ_SIZE:	equ 4

; Places in the original code used here
char_blank:	equ L5C1D		; 8 bytes for a plane that is off (put_char)
field_pattern:	equ L5C65		; 8 lines of the field background
wipe_end:	equ L51FF		; after the wipe of the field

; =====================================================================
; Start, exit
; =====================================================================

; ---- sapi_init
; Entry from CP/M (0100h). Saves page 0 RST vectors and puts ours there,
; maps the CGA in, sets the palette, starts the 82C54, the YM3812 and the
; keyboard, then runs the original start of the game.
sapi_init:
	di
	ld sp,stack_top
	ld hl,0008h
	ld de,page0_save
	ld bc,page0_end-0008h
	ldir
	ld hl,rst_vectors		; JP xxxx at 08h, 10h, 18h and 38h
.si_rst:
	ld e,(hl)
	inc hl
	ld d,0
	ld a,e
	or a
	jr z,.si_map
	ld a,0C3h
	ld (de),a
	inc de
	ldi
	ldi
	jr .si_rst
.si_map:
	ld a,MAP_CGA
	out (MAPREG),a
	ld a,CFG_GAME+002h		; CPU page B: clear it too
	ld (CGA_CFG),a
	call cga_clear
	ld a,CFG_GAME
	ld (CGA_CFG),a
	call cga_clear
	xor a				; MZ palette 0-3 = black
	ld (CGA_PAL_ADDR),a
	ld b,18*3
.si_pal:
	ld (CGA_PAL_DATA),a
	djnz .si_pal
	ld a,011h			; index = plane II * 16 + plane I
	ld (CGA_COLMASK),a
	ld a,036h			; counter 0: LSB+MSB, mode 3
	out (PITCW),a
	ld a,UNIT_DIV
	out (PIT0),a
	xor a
	out (PIT0),a
	ld a,0B4h			; counter 2: LSB+MSB, mode 2
	out (PITCW),a
	ld a,TICK_DIV
	out (PIT2),a
	xor a
	out (PIT2),a
	ld a,IEN_QUIET
	out (MIEN),a
	ld a,0C0h			; clear F2 and F1
	out (MIACK),a
	call ym_init
	ld a,002h			; keyboard ACK off, buzzer off
	out (KSTB),a
	jp start

rst_vectors:
	defb 008h
	defw wf_set			; RST 08h: OUT (0CCh),A (GDG WF)
	defb 010h
	defw psg_write			; RST 10h: OUT (0F2h),A (PSG)
	defb 018h
	defw pal_write			; RST 18h: OUT (C),B with C = 0F0h (palette)
	defb 038h
	defw isr			; RST 38h: interrupt (also set by music_start)
	defb 0

; ---- sapi_exit
; Back to CP/M: silence, interrupts off, page 0 back, CGA unmapped,
; warm boot.
sapi_exit:
	di
	ld sp,stack_top
	ld a,IEN_QUIET
	out (MIEN),a
	ld a,0C0h
	out (MIACK),a
	call ym_silence
	ld hl,page0_save
	ld de,0008h
	ld bc,page0_end-0008h
	ldir
	xor a
	out (MAPREG),a
	ld a,002h
	out (KSTB),a
	jp 0

; =====================================================================
; Interrupt (called from the original ISR at 01A9h)
; =====================================================================

; ---- isr_hook
; At the end of the interrupt: acknowledge F2, count the tick, keyboard.
; The ISR saved all registers.
isr_hook:
	ld a,080h			; clear F2
	out (MIACK),a
	call kbd_poll
	jp key_tick

; =====================================================================
; Delays
; =====================================================================

; ---- delay_units
; Wait A units of 4 ms (rising edges of 82C54 OUT0), A = 0 means 256.
; Replaces the MZ busy loop at 3BA0h (keeps BC, returns A = 0, Z) and
; works with interrupts disabled too.
delay_units:
	push bc
	ld c,a
.du_low:
	call kbd_poll_di
	in a,(MSTATUS)			; OUT0 low
	and 008h
	jr nz,.du_low
.du_high:
	in a,(MSTATUS)			; rising edge
	and 008h
	jr z,.du_high
	dec c
	jr nz,.du_low
	pop bc
	xor a
	ret

; ---- delay_2000
; MZ delay at 2236h: 2000h x 26 T = 60 ms. Keeps all registers.
delay_2000_s:
	push af
	ld a,15
	call delay_units
	pop af
	ret

; =====================================================================
; Graphics
; =====================================================================

; ---- cga_addr
; HL = MZ VRAM address (8000h-9F3Fh) -> CGA address C000h + 2 * offset.
; Changes A.
cga_addr:
	add hl,hl
	ld a,h
	or 0C0h
	ld h,a
	ret

; ---- cga_clear
; Fill the CPU page of the CGA (0000-3E7F) with 00h.
cga_clear:
	ld hl,CGA
	ld de,CGA+1
	ld bc,CGA_SIZE-1
	ld (hl),0
	ldir
	ret

; ---- wf_set (RST 08h)
; OUT (0CCh),A: remember the GDG write format for vw_hl.
wf_set:
	ld (wf),a
	ret

wf:
	defb 0				; MZ-800 WF register (CCh)

; ---- pal_write (RST 18h)
; OUT (0F0h),B: MZ-800 palette. B: D5-D4 palette 0-3, D3-D0 colour
; (IGRB); D6 = 1 is the palette group of the 16-colour mode (not used).
; MZ palette n -> Bt476 entry (n & 1) + 16 * (n >> 1). Keeps all.
pal_write:
	push af
	push bc
	push hl
	ld a,b
	bit 6,a
	jr nz,.pw_end
	and 020h			; palette bit 1 -> entry bit 4
	rrca
	ld c,a
	ld a,b
	and 010h			; palette bit 0 -> entry bit 0
	rrca
	rrca
	rrca
	rrca
	or c
	ld (CGA_PAL_ADDR),a
	ld a,b
	and 00Fh
	ld c,a
	add a,a
	add a,c
	ld c,a
	ld b,0
	ld hl,mz_colours
	add hl,bc
	ld a,(hl)
	ld (CGA_PAL_DATA),a
	inc hl
	ld a,(hl)
	ld (CGA_PAL_DATA),a
	inc hl
	ld a,(hl)
	ld (CGA_PAL_DATA),a
.pw_end:
	pop hl
	pop bc
	pop af
	ret

; ---- vw_hl, vw_de
; LD (HL),A (or LD (DE),A) to MZ VRAM through the GDG write format wf
; (only frame A: planes I and II). Keeps all registers and flags.
;   single:  selected planes = data
;   XOR, OR, RESET: selected planes ^ | & ~ data
;   REPLACE: selected planes = data, the other plane = 0
;   PSET:    pixels with data 1 get the colour of the selected planes
vw_de:
	ex de,hl
	call vw_hl
	ex de,hl
	ret

vw_hl:
	push af
	push bc
	push de
	push hl
	call wf_pair			; B, C = selected planes, D, E = all planes
	pop hl
	push hl
	call cga_addr
	ld a,(wf)
	rlca
	rlca
	rlca
	and 007h
	jr z,.vw_single
	dec a
	jr z,.vw_xor
	dec a
	jr z,.vw_or
	dec a
	jr z,.vw_reset
	dec a
	jr z,.vw_replace
	dec a
	jr z,.vw_replace
.vw_pset:				; byte = byte & ~all | sel
	ld a,d
	cpl
	and (hl)
	or b
	ld (hl),a
	inc hl
	ld a,e
	cpl
	and (hl)
	or c
	ld (hl),a
	jr .vw_end
.vw_single:				; byte = byte & ~planes | sel
	ld a,(wf)
	call wf_planes
	ld d,a
	ld e,a
	jr .vw_pset
.vw_xor:
	ld a,b
	xor (hl)
	ld (hl),a
	inc hl
	ld a,c
	xor (hl)
	ld (hl),a
	jr .vw_end
.vw_or:
	ld a,b
	or (hl)
	ld (hl),a
	inc hl
	ld a,c
	or (hl)
	ld (hl),a
	jr .vw_end
.vw_reset:
	ld a,b
	cpl
	and (hl)
	ld (hl),a
	inc hl
	ld a,c
	cpl
	and (hl)
	ld (hl),a
	jr .vw_end
.vw_replace:
	ld (hl),b
	inc hl
	ld (hl),c
.vw_end:
	pop hl
	pop de
	pop bc
	pop af
	ret

; ---- wf_pair
; A = MZ data byte -> B, C = CGA bytes 0, 1 with the pixels of A in the
; planes selected by wf; D, E = the pixels of A in both planes (masks).
; Changes AF, HL.
wf_pair:
	ld l,a
	ld h,pix_lo1/256
	ld b,(hl)			; plane I, pixels 0-3
	inc h
	ld c,(hl)			; plane I, pixels 4-7
	inc h
	ld d,(hl)			; plane II, pixels 0-3
	inc h
	ld e,(hl)			; plane II, pixels 4-7
	ld a,b
	or d
	ld h,a
	ld a,c
	or e
	ld l,a
	push hl				; masks
	ld a,(wf)
	rra
	jr c,.wp_1
	ld b,0				; plane I not selected
	ld c,0
.wp_1:
	rra
	jr c,.wp_2
	ld d,0				; plane II not selected
	ld e,0
.wp_2:
	ld a,b
	or d
	ld b,a
	ld a,c
	or e
	ld c,a
	pop de
	ret

; ---- wf_planes
; A = wf -> A = CGA nibble mask of the selected planes (F0h I, 0Fh II).
wf_planes:
	push bc
	ld c,0
	rra
	jr nc,.wn_1
	ld c,0F0h
.wn_1:
	rra
	ld a,c
	jr nc,.wn_2
	or 00Fh
.wn_2:
	pop bc
	ret

; ---- put_tile
; Tile of C bytes x B lines at HL (MZ address), source DE: plane I
; (C * B bytes, line by line), then plane II. The MZ code writes plane I
; with REPLACE (plane II = 0) and then plane II with XOR. Changes AF, BC,
; DE, HL; DE ends after the plane II data.
put_tile:
	ld a,c
	ld (pt_w),a
	ld a,b
	ld (pt_h),a
	call cga_addr
	push hl
	call pt_plane1
	pop hl
	call pt_plane2
	ld a,022h			; WF as the MZ code leaves it
	ld (wf),a
	ret

pt_plane1:				; (HL) = lo1[s], (HL+1) = hi1[s]
	ld a,(pt_h)
	ld (pt_r),a
.p1_row:
	push hl
	ld a,(pt_w)
	ld (pt_c),a
.p1_col:
	ld a,(de)
	inc de
	ld c,a
	ld b,pix_lo1/256
	ld a,(bc)
	ld (hl),a
	inc hl
	inc b
	ld a,(bc)
	ld (hl),a
	inc hl
	ld a,(pt_c)
	dec a
	ld (pt_c),a
	jr nz,.p1_col
	pop hl
	ld bc,LINE
	add hl,bc
	ld a,(pt_r)
	dec a
	ld (pt_r),a
	jr nz,.p1_row
	ret

pt_plane2:				; (HL) |= lo2[s], (HL+1) |= hi2[s]
	ld a,(pt_h)
	ld (pt_r),a
.p2_row:
	push hl
	ld a,(pt_w)
	ld (pt_c),a
.p2_col:
	ld a,(de)
	inc de
	ld c,a
	ld b,pix_lo2/256
	ld a,(bc)
	or (hl)
	ld (hl),a
	inc hl
	inc b
	ld a,(bc)
	or (hl)
	ld (hl),a
	inc hl
	ld a,(pt_c)
	dec a
	ld (pt_c),a
	jr nz,.p2_col
	pop hl
	ld bc,LINE
	add hl,bc
	ld a,(pt_r)
	dec a
	ld (pt_r),a
	jr nz,.p2_row
	ret

pt_w:	defb 0
pt_h:	defb 0
pt_r:	defb 0
pt_c:	defb 0

; ---- put8x8, put16x8, put16x16, put24x16, put16x24
; The MZ tile routines (3BF1h, 3C1Ch, 3C4Dh, 3C8Dh, 3CD1h): HL = MZ
; address, DE = tile. put8x8 keeps HL, DE, BC, the others all registers;
; the three with 16 or 24 lines end with EI as on the MZ.
put8x8_s:
	push hl
	push de
	push bc
	ld bc,00801h
pt_call:
	call put_tile
	pop bc
	pop de
	pop hl
	ret

put16x8_s:
	push af
	push hl
	push de
	push bc
	ld bc,00802h
pt_call_af:
	call put_tile
	pop bc
	pop de
	pop hl
	pop af
	ret

put16x16_s:
	push af
	push hl
	push de
	push bc
	ld bc,01002h
pt_call_ei:
	call put_tile
	pop bc
	pop de
	pop hl
	pop af
	ei
	ret

put24x16_s:
	push af
	push hl
	push de
	push bc
	ld bc,01003h
	jr pt_call_ei

put16x24_s:
	push af
	push hl
	push de
	push bc
	ld bc,01802h
	jr pt_call_ei

; ---- clr8, clr16x8
; MZ 3D11h: (clr8_rows) lines of 1 byte at HL to colour 0; 3D2Ah: 8 lines
; of 2 bytes. Keep HL, DE, BC.
clr8_s:
	push hl
	push de
	push bc
	ld a,(clr8_rows)
	ld b,a
	ld c,2
	jr clr_box

clr16x8_s:
	push hl
	push de
	push bc
	ld b,8
	ld c,4
clr_box:				; B lines of C CGA bytes
	call cga_addr
	ld de,LINE
.cb_line:
	push hl
	push bc
	xor a
.cb_byte:
	ld (hl),a
	inc hl
	dec c
	jr nz,.cb_byte
	pop bc
	pop hl
	add hl,de
	djnz .cb_line
	ld a,081h
	ld (wf),a
	pop bc
	pop de
	pop hl
	ret

; ---- put_char
; MZ 3E06h: 8 x 8 character DE at HL in the colour C: D0 plane I, D1
; plane II, D2 inverse. A plane that is off gets the bytes at
; char_blank instead (as the MZ code). Keeps HL, DE, BC.
put_char_s:
	push hl
	push de
	push bc
	call cga_addr
	xor a				; inverse mask
	bit 2,c
	jr z,.pc_ninv
	dec a
.pc_ninv:
	ld (pc_x1),a
	ld (pc_x2),a
	ld (pc_src1),de
	ld (pc_src2),de
	ld de,char_blank
	xor a
	bit 0,c
	jr nz,.pc_p1
	ld (pc_src1),de
	ld (pc_x1),a
.pc_p1:
	bit 1,c
	jr nz,.pc_p2
	ld (pc_src2),de
	ld (pc_x2),a
.pc_p2:
	ld b,8
.pc_line:
	push bc
	ld de,(pc_src1)
	ld a,(de)
	inc de
	ld (pc_src1),de
	ld c,a
	ld a,(pc_x1)
	xor c
	ld c,a				; C = plane I byte
	ld de,(pc_src2)
	ld a,(de)
	inc de
	ld (pc_src2),de
	ld b,a
	ld a,(pc_x2)
	xor b
	ld b,a				; B = plane II byte
	push hl
	call conv_pair
	pop hl
	ld (hl),d
	inc hl
	ld (hl),e
	ld de,LINE-1
	add hl,de
	pop bc
	djnz .pc_line
	ld a,022h
	ld (wf),a
	pop bc
	pop de
	pop hl
	ret

pc_src1:	defw 0
pc_src2:	defw 0
pc_x1:		defb 0
pc_x2:		defb 0

; ---- conv_pair
; C = plane I byte, B = plane II byte (MZ, bit 0 left) -> D, E = the two
; CGA bytes. Changes AF, HL.
conv_pair:
	ld h,pix_lo1/256
	ld l,c
	ld d,(hl)			; plane I, pixels 0-3
	inc h
	ld e,(hl)			; plane I, pixels 4-7
	inc h
	ld l,b
	ld a,(hl)			; plane II, pixels 0-3
	or d
	ld d,a
	inc h
	ld a,(hl)			; plane II, pixels 4-7
	or e
	ld e,a
	ret

; ---- cls, cls_lower
; MZ 2E9Fh: the whole screen to colour 0; 2ECFh: lines 72-199. Keep all
; registers, end with EI. The fill uses PUSH with interrupts disabled.
cls_s:
	push hl
	push bc
	push af
	ld hl,CGA+CGA_SIZE
	ld b,0				; 8000 x PUSH = 16000 bytes: 250 x 32
	ld c,250
	jr cls_fill

cls_lower_s:
	push hl
	push bc
	push af
	ld hl,CGA+CGA_SIZE
	ld c,160			; 128 lines x 80 = 10240 bytes = 160 x 64
cls_fill:
	di
	ld (cls_sp),sp
	ld sp,hl
	ld hl,0
.cf_loop:
	rept 32
	push hl
	endm
	dec c
	jr nz,.cf_loop
	ld sp,(cls_sp)
	ld a,081h
	ld (wf),a
	ei
	pop af
	pop bc
	pop hl
	ret

cls_sp:	defw 0

; ---- scroll_logo
; MZ 2DFEh: lines 8-71 move up to 0-63, eight lines at a time with
; poll_keys between them. Keeps HL, DE, BC.
scroll_logo_s:
	push hl
	push de
	push bc
	ld hl,CGA+8*LINE
	ld de,CGA
	ld a,8
.sl_grp:
	push af
	ld bc,8*LINE
	ldir
	call poll_keys
	pop af
	dec a
	jr nz,.sl_grp
	ld a,022h
	ld (wf),a
	pop bc
	pop de
	pop hl
	ret

; ---- box_top, box_right, box_bottom, box_left
; The MZ line routines at 2EFAh-2F2Bh with LD (DE),A through vw_de.
box_top_s:
	ld a,0F8h
	call vw_de
	inc de
	ld a,0FFh
.bt_l:
	call vw_de
	inc de
	djnz .bt_l
	ld a,01Fh
	jp vw_de

box_right_s:
	ld a,014h
.br_l:
	call vw_de
	call row_down
	djnz .br_l
	jp row_up

box_bottom_s:
	ld a,01Fh
	call vw_de
	ld a,0FFh
.bb_l:
	dec de
	call vw_de
	djnz .bb_l
	dec de
	ld a,0F8h
	jp vw_de

box_left_s:
	ld a,028h
.bl_l:
	call vw_de
	call row_up
	djnz .bl_l
	jp row_down

; ---- fill_field
; MZ 5393h-53BBh: 22 rows of 8 lines from 83C0h with the 8 pattern bytes
; at field_pattern, through wf (82h: REPLACE plane II). Then on at 53BCh.
fill_field_s:
	ld hl,083C0h
	call cga_addr
	ld b,22
.ff_row:
	push bc
	ld de,field_pattern
	ld b,8
.ff_line:
	push bc
	push hl
	ld a,(de)
	inc de
	push de
	call wf_pair			; B, C = the two CGA bytes
	pop de
	pop hl
	push hl
	ld a,40
.ff_byte:
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	dec a
	jr nz,.ff_byte
	pop hl
	ld bc,LINE
	add hl,bc
	pop bc
	djnz .ff_line
	pop bc
	djnz .ff_row
	jp field_bg_end

; ---- wipe
; MZ 51EAh-51FEh: columns 1-38 of lines 191 down to 32 to colour 0
; (WF 81h). Then on at 51FFh.
wipe_s:
	ld a,081h
	ld (wf),a
	ld hl,CGA+191*LINE+2
	ld de,0-LINE-76
	ld c,160
.wp_line:
	ld b,76
.wp_byte:
	ld (hl),0
	inc hl
	djnz .wp_byte
	add hl,de
	dec c
	jr nz,.wp_line
	xor a
	jp wipe_end

; ---- pattern_draw
; MZ 57C5h: HL = one of the pattern routines (57DFh, 57F3h, 580Dh),
; (SP) = MZ address, DE = data. The routine runs twice, first with the
; WF as it is, then with 82h (REPLACE plane II), DE goes on; WF ends 21h.
pattern_draw_s:
	ld (.pd_call1+1),hl
	ld (.pd_call2+1),hl
	pop hl
	push de
	push hl
.pd_call1:
	call 0
	pop hl
	ld a,082h
	ld (wf),a
.pd_call2:
	call 0
	ld a,021h
	ld (wf),a
	pop de
	ret

; the three MZ pattern routines with LD (HL),A through vw_hl
pat_rows_s:				; 57DFh: 8 lines of 40 bytes
	ld c,8
.pr_line:
	ld a,(de)
	inc de
	ld b,40
.pr_byte:
	call vw_hl
	inc hl
	djnz .pr_byte
	dec c
	jr nz,.pr_line
	ret

pat_cols4_s:				; 57F3h: bytes at +0, +11, +26, +39 for 8 lines
	ld b,8
.pc4_line:
	ld a,(de)
	inc de
	push de
	call vw_hl
	ld de,11
	add hl,de
	call vw_hl
	ld de,15
	add hl,de
	call vw_hl
	ld de,13
	add hl,de
	call vw_hl
	inc hl
	pop de
	djnz .pc4_line
	ret

pat_cols2_s:				; 580Dh: bytes at +0 and +39 for 8 lines
	ld b,8
.pc2_line:
	ld a,(de)
	inc de
	call vw_hl
	push de
	ld de,39
	add hl,de
	pop de
	call vw_hl
	inc hl
	djnz .pc2_line
	ret

; ---- plane2_test
; MZ fall test (2A44h): any pixel of plane II in the two bytes at HL
; (MZ address)? A = 0 and Z when none. Keeps BC, DE, HL.
plane2_test:
	push hl
	call cga_addr
	ld a,(hl)
	inc hl
	or (hl)
	inc hl
	or (hl)
	inc hl
	or (hl)
	and 00Fh
	pop hl
	ret

; =====================================================================
; Keyboard and joystick
; =====================================================================

; ---- kbd_row
; Replaces OUT (0D0h),A + IN A,(0D1h): A = 8255 port A (low nibble =
; matrix column 0-9) -> A = the column, active low. Keeps BC, DE, HL.
kbd_row:
	push bc
	and 00Fh
	ld b,a
	call kbd_poll_di
	ld a,(key_col)
	cp b
	ld a,0FFh
	jr nz,.kr_end
	ld a,(key_bits)
	cpl
.kr_end:
	pop bc
	ret

; ---- joy_k4, joy_none
; Replace OUT (0D0h),A + IN A,(0F0h) / (0F1h): MZ-800 joystick, active
; low: D0 up, D1 down, D2 left, D3 right, D4 trigger 1, D5 trigger 2.
; joy_k4 = MPH-1V K4 (D0 down, D1 up, D2 right, D3 left, D4 FL, D5 FR).
joy_k4:
	push bc
	in a,(JOY)
	ld b,a
	ld c,0FFh
	rra				; down
	jr c,.jk_1
	res 1,c
.jk_1:
	rra				; up
	jr c,.jk_2
	res 0,c
.jk_2:
	rra				; right
	jr c,.jk_3
	res 3,c
.jk_3:
	rra				; left
	jr c,.jk_4
	res 2,c
.jk_4:
	ld a,b				; triggers: the same bits
	or 0CFh
	and c
	pop bc
	ret

joy_none:
	ld a,0FFh
	ret

; ---- kbd_poll, kbd_poll_di
; Catch a key from the SAPI keyboard: STROBE (P0-IN0 = 0), the code (P1,
; inverted), ACK (P0-OUT0 = 1) until STROBE is inactive, ACK off (as
; MikroMon). ESC ends the game. The code becomes an MZ-800 matrix key
; (key_new). kbd_poll runs in the interrupt; kbd_poll_di from the game
; disables interrupts around it. Changes AF.
kbd_poll_di:
	in a,(KSTB)
	rrca
	ret c				; STROBE inactive
	push af
	ld a,i				; P/V = IFF2
	di
	push af
	call kbd_poll
	pop af
	jp po,.kd_di
	ei
.kd_di:
	pop af
	ret

kbd_poll:
	in a,(KSTB)
	rrca
	ret c
	push bc
	push hl
	in a,(KDATA)
	cpl
	ld c,a				; C = code
	ld a,003h			; ACK
	out (KSTB),a
	ld b,0				; STROBE inactive, at most 256 reads
.kp_strobe:
	in a,(KSTB)
	rrca
	jr c,.kp_ack
	djnz .kp_strobe
.kp_ack:
	ld a,002h
	out (KSTB),a
	ld a,c
	cp 01Bh				; ESC: back to CP/M
	jp z,sapi_exit
	cp 'a'
	jr c,.kp_find
	cp 'z'+1
	jr nc,.kp_find
	sub 020h			; lower case = upper case
.kp_find:
	ld hl,key_map
.kp_next:
	ld b,(hl)
	inc hl
	inc b
	jr z,.kp_end			; not in the table
	dec b
	cp b
	ld b,(hl)			; column, bit
	inc hl
	jr nz,.kp_next
	ld a,b
	call key_new
.kp_end:
	pop hl
	pop bc
	ret

; SAPI key code -> MZ-800 key: high nibble = bit of the column, low = column.
; Bit 7 of the column byte (80h) marks keys held until the game reads them.
KH:	equ 080h
key_map:
	defb 0C1h,KH+057h, 005h,KH+057h	; up: Consul, EKL-1
	defb 0C2h,KH+047h, 018h,KH+047h	; down
	defb 0C3h,KH+037h, 004h,KH+037h	; right
	defb 0C4h,KH+027h, 013h,KH+027h	; left
	defb ' ',KH+046h		; space
	defb 084h,KH+078h, 085h,KH+078h	; BREAK: Consul BREAK, backspace
	defb 008h,KH+078h
	defb 00Dh,000h			; CR
	defb 001h,079h, 080h,079h, 081h,079h	; F1: Ctrl+A, Consul ROL
	defb 002h,069h, 082h,069h, 083h,069h	; F2: Ctrl+B, Consul COPY
	defb 003h,059h			; F3: Ctrl+C
	defb 07Fh,067h, 00Bh,067h	; DEL
	defb '-',056h, '.',006h, ',',016h, '/',007h, ':',010h, ';',020h
	defb '1',075h, '2',065h, '3',055h, '4',045h, '5',035h
	defb '6',025h, '7',015h, '8',005h, '9',026h, '0',036h
	defb 'A',074h, 'B',064h, 'C',054h, 'D',044h, 'E',034h, 'F',024h
	defb 'G',014h, 'H',004h, 'I',073h, 'J',063h, 'K',053h, 'L',043h
	defb 'M',033h, 'N',023h, 'O',013h, 'P',003h, 'Q',072h, 'R',062h
	defb 'S',052h, 'T',042h, 'U',032h, 'V',022h, 'W',012h, 'X',002h
	defb 'Y',071h, 'Z',061h
	defb 0FFh

; ---- key_new
; A = key from key_map: press it now, again (refresh), or queue it.
key_new:
	push de
	ld b,a
	and 07Fh
	ld c,a				; C = bit, column
	ld a,(key_col)
	inc a
	jr z,.kn_free			; no key down
	ld a,(key_code)
	cp c
	jr nz,.kn_queue
	xor a				; the same key again (autorepeat)
	ld (key_ticks),a
	ld (key_seen),a
	jr .kn_end
.kn_free:
	ld a,(key_gap)
	or a
	jr nz,.kn_queue
	ld a,(kq_count)
	or a
	jr nz,.kn_queue
	ld a,b
	call key_down
	jr .kn_end
.kn_queue:
	ld a,(kq_count)
	cp KQ_SIZE
	jr nc,.kn_end			; full: left out
	ld e,a
	inc a
	ld (kq_count),a
	ld d,0
	ld hl,key_queue
	add hl,de
	ld (hl),b
.kn_end:
	pop de
	ret

; ---- key_down
; A = key from key_map: it is down from now.
key_down:
	ld (key_flags),a
	and 07Fh
	ld (key_code),a
	and 00Fh
	ld (key_col),a
	ld a,(key_code)			; bit number 0-7 -> mask
	rrca
	rrca
	rrca
	rrca
	and 007h
	ld b,a
	ld a,1
	jr z,.kd_mask
.kd_shift:
	add a,a
	djnz .kd_shift
.kd_mask:
	ld (key_bits),a
	xor a
	ld (key_ticks),a
	ld (key_seen),a
	ret

; ---- key_tick
; Each interrupt: release the key when its time is over, then the next
; one from the queue after a gap.
key_tick:
	ld a,(key_col)
	inc a
	jr z,.kt_up
	ld hl,key_ticks
	inc (hl)
	ld a,(hl)
	cp KEY_MAX
	jr nc,.kt_release
	ld b,a
	ld a,(key_flags)
	rlca
	jr nc,.kt_timed
	ld a,b				; held until the game reads it
	cp KEY_MIN
	ret c
	ld a,(key_seen)
	or a
	ret z
	jr .kt_release
.kt_timed:
	ld a,b
	cp KEY_TIME
	ret c
.kt_release:
	ld a,0FFh
	ld (key_col),a
	ld a,KEY_GAP
	ld (key_gap),a
	ret
.kt_up:
	ld hl,key_gap
	ld a,(hl)
	or a
	jr z,.kt_next
	dec (hl)
	ret
.kt_next:
	ld a,(kq_count)
	or a
	ret z
	dec a
	ld (kq_count),a
	ld hl,key_queue
	ld a,(hl)
	push af
	ld de,key_queue
	inc hl
	ld bc,KQ_SIZE-1
	ldir
	pop af
	jp key_down

; ---- input_hook
; Replaces XOR A + LD (5028h),A at the start of the input routine of the
; game (4FB5h), which runs once a game step: the key down was read.
input_hook:
	ld a,1
	ld (key_seen),a
	xor a
	ld (L5028),a
	ret

key_col:	defb 0FFh		; column of the key down, FFh = none
key_bits:	defb 0			; its bit mask (active high)
key_code:	defb 0			; bit, column
key_flags:	defb 0			; key_map byte (bit 7: held until read)
key_ticks:	defb 0
key_seen:	defb 0
key_gap:	defb 0
kq_count:	defb 0
key_queue:	defs KQ_SIZE

; =====================================================================
; Sound: SN76489 -> YM3812
; =====================================================================

; The MZ-800 PSG (SN76489, 3.5469 MHz): tone channels 0-2 with a 10-bit
; divider N (f = 110840 / N Hz) and 4-bit attenuation (2 dB steps),
; noise channel 3. YM3812 channels 0-2 play the tones, channel 3 the
; noise. F-number = K / (N << block), K = 110840 * 2^20 / 49716 =
; 23ABECh; the block is the smallest with N << block > K >> 10 (2282).
YM_KHI:		equ 008EAh		; K >> 10
YM_KLO:		equ 003ECh		; the 10 low bits of K

ym_init:
	ld hl,ym_regs
.yi_loop:
	ld a,(hl)			; register, value pairs, FFh ends
	inc a
	ret z
	dec a
	inc hl
	ld e,(hl)
	inc hl
	call ym_write
	jr .yi_loop

; tone channels 0-2: modulator with feedback (buzzy, like the square of
; the PSG), carrier sustained; channel 3: noisy modulator
ym_regs:
	defb 001h,020h			; WSE
	defb 008h,000h
	defb 0BDh,000h
	defb 020h,021h, 021h,021h, 022h,021h, 023h,021h, 024h,021h, 025h,021h
	defb 040h,01Ch, 041h,01Ch, 042h,01Ch, 043h,03Fh, 044h,03Fh, 045h,03Fh
	defb 060h,0F0h, 061h,0F0h, 062h,0F0h, 063h,0F0h, 064h,0F0h, 065h,0F0h
	defb 080h,00Fh, 081h,00Fh, 082h,00Fh, 083h,00Fh, 084h,00Fh, 085h,00Fh
	defb 0E0h,000h, 0E1h,000h, 0E2h,000h, 0E3h,000h, 0E4h,000h, 0E5h,000h
	defb 0C0h,00Ch, 0C1h,00Ch, 0C2h,00Ch
	defb 028h,02Fh, 02Bh,021h	; channel 3 (slots 8 and 11)
	defb 048h,000h, 04Bh,03Fh
	defb 068h,0F0h, 06Bh,0F0h
	defb 088h,00Fh, 08Bh,00Fh
	defb 0E8h,000h, 0EBh,000h
	defb 0C3h,00Eh
	defb 0B0h,000h, 0B1h,000h, 0B2h,000h, 0B3h,000h
	defb 0FFh

; ---- ym_silence
ym_silence:
	ld a,0B0h
.ys_loop:
	ld e,0
	push af
	call ym_write
	pop af
	inc a
	cp 0B4h
	jr nz,.ys_loop
	ret

; ---- ym_write
; YM3812 register A = E. The chip needs 12 of its clocks after the
; address and 84 after the data (3.3 us and 23.5 us, 94 T at 4 MHz).
ym_write:
	out (YMADDR),a
	ex (sp),hl
	ex (sp),hl
	ld a,e
	out (YMDATA),a
	push bc
	ld b,7
.yw_wait:
	djnz .yw_wait
	pop bc
	ret

; ---- psg_write (RST 10h)
; OUT (0F2h),A: SN76489 write. Keeps all registers and flags.
psg_write:
	push af
	push bc
	push de
	push hl
	bit 7,a
	jr z,.ps_data
	ld c,a				; latch byte 1 r r r d d d d
	rrca
	rrca
	rrca
	rrca
	and 007h
	ld (psg_latch),a
	ld b,a
	ld a,c
	and 00Fh
	ld c,a				; C = data
	bit 0,b
	jr nz,.ps_vol
	ld a,b
	cp 6
	jr z,.ps_noise
	call psg_tone_ptr		; tone: low 4 bits
	ld a,(hl)
	and 0F0h
	or c
	ld (hl),a
	jr .ps_end			; the high byte follows (the game writes both)
.ps_data:				; data byte 0 x d d d d d d
	ld c,a
	ld a,(psg_latch)
	ld b,a
	bit 0,b
	jr nz,.ps_vol_d
	cp 6
	jr z,.ps_noise_d
	call psg_tone_ptr		; tone: high 6 bits -> N = d << 4 | low
	ld a,c
	and 03Fh
	ld e,a
	ld d,0
	ld a,(hl)
	and 00Fh
	ex de,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	or l
	ld l,a
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	ld a,b
	rrca				; channel
	call ym_tone
	jr .ps_end
.ps_vol_d:
	ld a,c
	and 00Fh
	ld c,a
.ps_vol:				; B = 1, 3, 5, 7: volume of channel B >> 1
	ld a,b
	rrca
	and 003h
	call ym_volume
	jr .ps_end
.ps_noise_d:
.ps_noise:
	ld a,c
	and 007h
	ld (psg_nctl),a
	call ym_noise
.ps_end:
	pop hl
	pop de
	pop bc
	pop af
	ret

; HL = psg_tones + 2 * (B >> 1)
psg_tone_ptr:
	ld a,b
	and 006h
	ld e,a
	ld d,0
	ld hl,psg_tones
	add hl,de
	ret

; ---- ym_tone
; A = channel 0-2: set the YM3812 frequency from psg_tones (keyed on
; when the channel is not silent).
ym_tone:
	ld c,a
	add a,a
	ld e,a
	ld d,0
	ld hl,psg_tones
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	call ym_fnum			; HL = F-number, B = block
	ld a,c
	jp ym_freq

; ---- ym_fnum
; DE = PSG divider N (0 = 1024) -> HL = F-number, B = block. Keeps C.
ym_fnum:
	ld a,d
	or e
	jr nz,.yf_nz
	ld de,1024
.yf_nz:
	ld b,0
.yf_blk:
	ld hl,YM_KHI
	or a
	sbc hl,de
	jr c,.yf_div			; N << block > K >> 10
	ld a,b
	cp 7
	jr z,.yf_max
	inc b
	ex de,hl
	add hl,hl
	ex de,hl
	jr .yf_blk
.yf_max:
	ld hl,1023			; above the YM3812
	ret
.yf_div:
	push bc
	push ix
	ld ix,0				; quotient
	ld hl,YM_KHI			; remainder
	ld bc,YM_KLO			; next bits of K, shifted out of B: 10 bits
	ld a,10
.yf_loop:
	add ix,ix
	sla c				; CY = next bit of K (bit 9 of BC first)
	rl b
	bit 2,b
	jr z,.yf_b0
	res 2,b
	scf
	jr .yf_bit
.yf_b0:
	or a
.yf_bit:
	adc hl,hl
	or a
	sbc hl,de
	jr nc,.yf_one
	add hl,de
	jr .yf_next
.yf_one:
	inc ix
.yf_next:
	dec a
	jr nz,.yf_loop
	push ix
	pop hl
	pop ix
	pop bc
	ret

; ---- ym_freq
; Channel A: F-number HL, block B; key on unless the channel is silent.
ym_freq:
	ld c,a
	add a,0A0h
	ld e,l
	push hl
	call ym_write
	pop hl
	ld a,b
	add a,a
	add a,a
	or h
	ld b,a				; block, F-number high
	ld hl,psg_vols
	ld e,c
	ld d,0
	add hl,de
	ld a,(hl)
	cp 00Fh
	jr z,.yq_off
	set 5,b				; KEY ON
.yq_off:
	ld hl,ym_b0
	add hl,de
	ld a,b
	cp (hl)
	ret z
	ld (hl),a
	ld e,a
	ld a,c
	add a,0B0h
	jp ym_write

; ---- ym_volume
; Channel A (0-3) gets the PSG attenuation C (0 = loud, 15 = off).
ym_volume:
	ld e,a
	ld d,0
	ld hl,psg_vols
	add hl,de
	ld a,(hl)
	cp c
	ret z				; no change
	ld (hl),c
	push de
	ld hl,ym_tl
	ld b,0
	add hl,bc
	ld a,(hl)
	ld hl,ym_car
	add hl,de
	ld e,a
	ld a,(hl)			; carrier slot register 40h + x
	call ym_write
	pop de
	ld a,e				; key on / off with the volume
	ld hl,ym_b0
	add hl,de
	ld b,(hl)
	ld a,c
	cp 00Fh
	jr z,.yv_off
	set 5,b
	jr .yv_set
.yv_off:
	res 5,b
.yv_set:
	ld a,b
	cp (hl)
	ret z
	ld (hl),a
	ld a,e
	add a,0B0h
	ld e,b
	jp ym_write

; ---- ym_noise
; Noise channel: the rate (psg_nctl D1-D0: N = 16, 32, 64 or channel 2)
; as a frequency of YM3812 channel 3.
ym_noise:
	ld a,(psg_nctl)
	and 003h
	cp 3
	jr z,.yn_ch2
	ld de,16
	or a
	jr z,.yn_set
.yn_sh:
	sla e
	dec a
	jr nz,.yn_sh
	jr .yn_set
.yn_ch2:
	ld de,(psg_tones+4)
.yn_set:
	call ym_fnum
	ld a,3
	jp ym_freq

; attenuation 0-15 (2 dB) -> total level (0.75 dB)
ym_tl:
	defb 0,3,5,8,11,13,16,19,21,24,27,29,32,35,37,63
ym_car:
	defb 043h,044h,045h,04Bh	; carrier slots of channels 0-3

psg_latch:	defb 0
psg_nctl:	defb 0
psg_tones:	defw 0,0,0
psg_vols:	defb 15,15,15,15
ym_b0:		defb 0,0,0,0		; last B0h-B3h values
