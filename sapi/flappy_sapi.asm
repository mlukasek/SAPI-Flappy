; Flappy (dB-SOFT 1984) for the Tesla SAPI-1 V (CGA-1V, MPH-1V), CP/M .COM.
; From orig/flappy.asm (MZ-800). Changes are marked SAPI:, the comments with
; addresses are the addresses of the MZ-800 original. Assembles with pasmo 0.5.3.

L0000            equ 0000h
L0038            equ 0038h
L0039            equ 0039h
; SAPI: map_buf is after the platform code (MZ: A000h)
map_buf_29       equ map_buf+29h
ext_vectors_2    equ ext_vectors+2

; ======================================================================
; low block (loaded from B400h): interrupt, sound, music 0100-14FF

	org 0100h
	; SAPI: CP/M starts here (MZ: JP music_start, not used).
	jp sapi_init
	jp isr                                 ; 0103
	jp L062A                               ; 0106
music_off:	ld hl,07A4h                  ; 0109
music_start:	di                         ; 010C
	push hl                                ; 010D
	pop ix                                 ; 010E
	push hl                                ; 0110
	; SAPI: MZ: IN A,(0E1h) maps RAM at 1000h and 8000h (CG ROM and VRAM out).
	nop
	nop
	ld e,(hl)                              ; 0113
	inc hl                                 ; 0114
	ld d,(hl)                              ; 0115
	inc hl                                 ; 0116
	add ix,de                              ; 0117
	ld (L01ED),ix                          ; 0119
	ld e,(hl)                              ; 011D
	inc hl                                 ; 011E
	ld d,(hl)                              ; 011F
	inc hl                                 ; 0120
	pop ix                                 ; 0121
	push ix                                ; 0123
	add ix,de                              ; 0125
	ld (L01F0),ix                          ; 0127
	ld e,(hl)                              ; 012B
	inc hl                                 ; 012C
	ld d,(hl)                              ; 012D
	inc hl                                 ; 012E
	pop ix                                 ; 012F
	add ix,de                              ; 0131
	ld (L01F3),ix                          ; 0133
	xor a                                  ; 0137
	ld (L0323),a                           ; 0138
	inc a                                  ; 013B
	ld (L031F),a                           ; 013C
	; SAPI: MZ: 8253 counter 1 = 2 (mode 2) and counter 2 = 14 (mode 0) give the interrupt.
	; SAPI: Here 82C54 counter 2 runs since sapi_init; clear F2 and enable its interrupt.
	ld a,080h
	out (MIACK),a
	ld a,IEN_RUN
	out (MIEN),a
	defs 16
	; SAPI: MZ: LD HL,01A9h (vector at 0038h); isr_entry acknowledges F2 first.
	ld hl,isr_entry                        ; 0157
	ld (L0039),hl                          ; 015A
	ld a,0C3h                              ; 015D
	ld (L0038),a                           ; 015F
	; SAPI: MZ: IN A,(0E0h) maps CG ROM at 1000h and VRAM at 8000h.
	nop
	nop
	ei                                     ; 0164
	ret                                    ; 0165
pause_wait:	defb 0F5h,0C5h,0CDh,86h,01h,01h,0D7h,74h,0EDh,41h,06h,0B0h,0EDh,41h,0Dh,06h; 0166
	defb 0Eh,0EDh,41h,0AFh,0EDh,79h,0Dh,06h,02h,0EDh,41h,0EDh,79h,0C1h,0F1h,0C9h; 0176
pause_key:	defb 3Eh,0E4h,0D3h,0D0h,0DBh,0D1h,0FEh,7Fh,28h,0Ch,0FEh,0BFh,28h,0Eh,3Ah,9Bh; 0186
	defb 01h,0B7h,0C0h,18h,0EBh,01h,3Eh,01h,32h,9Bh,01h,0C9h,3Eh,00h,32h,9Bh; 0196
	defb 01h,18h,0DDh                      ; 01A6
isr:	di                                 ; 01A9
	push hl                                ; 01AA
	push de                                ; 01AB
	push bc                                ; 01AC
	exx                                    ; 01AD
	push hl                                ; 01AE
	push de                                ; 01AF
	push bc                                ; 01B0
	push af                                ; 01B1
	ex af,af'                              ; 01B2
	push af                                ; 01B3
	; SAPI: MZ: IN A,(0E1h) maps RAM at 1000h and 8000h (CG ROM and VRAM out).
	nop
	nop
	ld a,00h                               ; 01B6
ticks            equ $-1
	; SAPI: MZ: INC A + JR Z + LD (ticks),A counts the tick (isr_entry does it).
	; The rest of the interrupt (the music) runs with interrupts enabled: a tick
	; during it is counted by isr_entry, the music is not run twice.
	ei
	defs 5
L01BE:	ld a,00h                         ; 01BE
	or a                                   ; 01C0
	jr z,L01E0                             ; 01C1
	ld a,9Fh                               ; 01C3
	ld c,0F3h                              ; 01C5
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	; SAPI: MZ: OUT (C),A to a second PSG at 0F3h (MZ-1500).
	nop
	nop
	ld a,0BFh                              ; 01CB
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	; SAPI: MZ: OUT (C),A to a second PSG at 0F3h (MZ-1500).
	nop
	nop
	ld a,0DFh                              ; 01D1
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	; SAPI: MZ: OUT (C),A to a second PSG at 0F3h (MZ-1500).
	nop
	nop
	ld a,0FFh                              ; 01D7
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	; SAPI: MZ: OUT (C),A to a second PSG at 0F3h (MZ-1500).
	nop
	nop
	jp L0258                               ; 01DD
L01E0:	ld a,(L01FE)                     ; 01E0
	or a                                   ; 01E3
	jr nz,L01FD                            ; 01E4
	ld a,(L0323)                           ; 01E6
	or a                                   ; 01E9
	jr nz,L01FA                            ; 01EA
	ld hl,0000h                            ; 01EC
L01ED            equ $-2
	ld de,0000h                            ; 01EF
L01F0            equ $-2
	ld bc,0000h                            ; 01F2
L01F3            equ $-2
	call L0283                             ; 01F5
	jr L01FD                               ; 01F8
L01FA:	call L02B9                       ; 01FA
L01FD:	ld a,00h                         ; 01FD
L01FE            equ L01FD+1
	or a                                   ; 01FF
	jp z,L0258                             ; 0200
	jp p,L0223                             ; 0203
	cp 80h                                 ; 0206
	jr nz,L020F                            ; 0208
	ld hl,07B2h                            ; 020A
	jr L0212                               ; 020D
L020F:	ld hl,07F9h                      ; 020F
L0212:	ld (L0232),hl                    ; 0212
	ld a,01h                               ; 0215
	ld (L01FE),a                           ; 0217
	ld (L0224),a                           ; 021A
	ld a,0E7h                              ; 021D
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	ld a,02h                               ; 0221
L0222            equ $-1
L0223:	ld a,01h                         ; 0223
L0224            equ L0223+1
	dec a                                  ; 0225
	ld (L0224),a                           ; 0226
	jr nz,L0258                            ; 0229
	ld a,(L0222)                           ; 022B
	ld (L0224),a                           ; 022E
L0231:	ld hl,07B2h                      ; 0231
L0232            equ L0231+1
	ld a,(hl)                              ; 0234
	inc hl                                 ; 0235
	ld (L0232),hl                          ; 0236
	or a                                   ; 0239
	jr nz,L0245                            ; 023A
	ld (L01FE),a                           ; 023C
	call psg_noise_vol                     ; 023F
	jp L0258                               ; 0242
L0245:	jp p,L0252                       ; 0245
	ld a,(hl)                              ; 0248
	inc hl                                 ; 0249
	ld (L0232),hl                          ; 024A
	call psg_noise_vol                     ; 024D
	jr L0231                               ; 0250
L0252:	call L06DB                       ; 0252
	call psg_tone2                         ; 0255
	; SAPI: MZ: reloads 8253 counter 2 with 11 for the next interrupt.
	; SAPI: Here: acknowledge F2 of the MPH-1V, keyboard (isr_hook).
L0258:	call isr_hook
	defs 21
	; SAPI: MZ: IN A,(0E0h) maps CG ROM at 1000h and VRAM at 8000h.
	nop
	nop
	pop af                                 ; 0272
	ex af,af'                              ; 0273
	pop af                                 ; 0274
	pop bc                                 ; 0275
	pop de                                 ; 0276
	pop hl                                 ; 0277
	exx                                    ; 0278
	pop bc                                 ; 0279
	pop de                                 ; 027A
	pop hl                                 ; 027B
	ei                                     ; 027C
	reti                                   ; 027D
	defb 0AFh,32h,1Fh,03h                  ; 027F
L0283:	ld (L0333),hl                    ; 0283
	ld (L0348),de                          ; 0286
	ld (L035D),bc                          ; 028A
	ld a,07h                               ; 028E
	ld (L0323),a                           ; 0290
	ld (L02BA),a                           ; 0293
	ld (L02DB),a                           ; 0296
	ld (L02FD),a                           ; 0299
	ld a,(L077C)                           ; 029C
	ld (L02C3),a                           ; 029F
	ld (L02E5),a                           ; 02A2
	ld (L0307),a                           ; 02A5
	call L0328                             ; 02A8
	call L033C                             ; 02AB
	call L0351                             ; 02AE
	ld a,(L031F)                           ; 02B1
	or a                                   ; 02B4
	ret nz                                 ; 02B5
L02B6:	call L0637                       ; 02B6
L02B9:	ld a,03h                         ; 02B9
L02BA            equ L02B9+1
	or a                                   ; 02BB
	jr z,L02DA                             ; 02BC
	xor a                                  ; 02BE
	call L0548                             ; 02BF
	ld a,10h                               ; 02C2
L02C3            equ $-1
	dec a                                  ; 02C4
	ld (L02C3),a                           ; 02C5
	jr nz,L02DA                            ; 02C8
	ld a,(L077C)                           ; 02CA
	ld (L02C3),a                           ; 02CD
	ld a,(L07A1)                           ; 02D0
	dec a                                  ; 02D3
	ld (L07A1),a                           ; 02D4
	call z,L0328                           ; 02D7
L02DA:	ld a,03h                         ; 02DA
L02DB            equ L02DA+1
	or a                                   ; 02DC
	jr z,L02FC                             ; 02DD
	ld a,01h                               ; 02DF
	call L0548                             ; 02E1
	ld a,10h                               ; 02E4
L02E5            equ $-1
	dec a                                  ; 02E6
	ld (L02E5),a                           ; 02E7
	jr nz,L02FC                            ; 02EA
	ld a,(L077C)                           ; 02EC
	ld (L02E5),a                           ; 02EF
	ld a,(L07A2)                           ; 02F2
	dec a                                  ; 02F5
	ld (L07A2),a                           ; 02F6
	call z,L033C                           ; 02F9
L02FC:	ld a,03h                         ; 02FC
L02FD            equ L02FC+1
	or a                                   ; 02FE
	jr z,L031E                             ; 02FF
	ld a,02h                               ; 0301
	call L0548                             ; 0303
	ld a,10h                               ; 0306
L0307            equ $-1
	dec a                                  ; 0308
	ld (L0307),a                           ; 0309
	jr nz,L031E                            ; 030C
	ld a,(L077C)                           ; 030E
	ld (L0307),a                           ; 0311
	ld a,(L07A3)                           ; 0314
	dec a                                  ; 0317
	ld (L07A3),a                           ; 0318
	call z,L0351                           ; 031B
L031E:	ld a,00h                         ; 031E
L031F            equ L031E+1
	or a                                   ; 0320
	ret nz                                 ; 0321
	ld a,03h                               ; 0322
L0323            equ $-1
	or a                                   ; 0324
	jr nz,L02B6                            ; 0325
	ret                                    ; 0327
L0328:	ld hl,02BAh                      ; 0328
	ld (L0542),hl                          ; 032B
	xor a                                  ; 032E
	ld (L0625),a                           ; 032F
	ld hl,0000h                            ; 0332
L0333            equ $-2
	call L0366                             ; 0335
	ld (L0333),hl                          ; 0338
	ret                                    ; 033B
L033C:	ld hl,02DBh                      ; 033C
	ld (L0542),hl                          ; 033F
	ld a,01h                               ; 0342
	ld (L0625),a                           ; 0344
	ld hl,0000h                            ; 0347
L0348            equ $-2
	call L0366                             ; 034A
	ld (L0348),hl                          ; 034D
	ret                                    ; 0350
L0351:	ld hl,02FDh                      ; 0351
	ld (L0542),hl                          ; 0354
	ld a,02h                               ; 0357
	ld (L0625),a                           ; 0359
	ld hl,0000h                            ; 035C
L035D            equ $-2
	call L0366                             ; 035F
	ld (L035D),hl                          ; 0362
	ret                                    ; 0365
L0366:	xor a                            ; 0366
	ld (L04D4),a                           ; 0367
	ld (L04D9),a                           ; 036A
L036D:	ld a,(hl)                        ; 036D
	inc hl                                 ; 036E
	cp 23h                                 ; 036F
	jr z,L03CD                             ; 0371
	cp 24h                                 ; 0373
	jr z,L03D1                             ; 0375
	cp 2Bh                                 ; 0377
	jr z,L03DC                             ; 0379
	cp 2Dh                                 ; 037B
	jr z,L03E4                             ; 037D
	cp 3Ch                                 ; 037F
	jp z,L040C                             ; 0381
	cp 3Eh                                 ; 0384
	jp z,L0414                             ; 0386
	cp 5Eh                                 ; 0389
	jp z,L03C7                             ; 038B
	cp 3Ah                                 ; 038E
	jp z,L0528                             ; 0390
	cp 20h                                 ; 0393
	jp z,L036D                             ; 0395
	and 0DFh                               ; 0398
	cp 56h                                 ; 039A
	jr z,L041C                             ; 039C
	cp 4Ch                                 ; 039E
	jp z,L0449                             ; 03A0
	cp 4Fh                                 ; 03A3
	jr z,L03EC                             ; 03A5
	cp 53h                                 ; 03A7
	jp z,L047D                             ; 03A9
	cp 4Dh                                 ; 03AC
	jp z,L048B                             ; 03AE
L03B1:	push hl                          ; 03B1
	ld hl,0754h                            ; 03B2
	ld b,08h                               ; 03B5
L03B7:	cp (hl)                          ; 03B7
	inc hl                                 ; 03B8
	jp z,L04C8                             ; 03B9
	inc hl                                 ; 03BC
	djnz L03B7                             ; 03BD
	pop hl                                 ; 03BF
	or a                                   ; 03C0
	jp z,L0528                             ; 03C1
	jp L036D                               ; 03C4
L03C7:	ld (L04D9),a                     ; 03C7
	jp L036D                               ; 03CA
L03CD:	ld a,01h                         ; 03CD
	jr L03D3                               ; 03CF
L03D1:	ld a,0FFh                        ; 03D1
L03D3:	ld (L04D4),a                     ; 03D3
	call L074B                             ; 03D6
	inc hl                                 ; 03D9
	jr L03B1                               ; 03DA
L03DC:	exx                              ; 03DC
	call L05F4                             ; 03DD
	exx                                    ; 03E0
	inc a                                  ; 03E1
	jr L03F5                               ; 03E2
L03E4:	exx                              ; 03E4
	call L05F4                             ; 03E5
	exx                                    ; 03E8
	dec a                                  ; 03E9
	jr L03F5                               ; 03EA
L03EC:	call L0724                       ; 03EC
	ld a,e                                 ; 03EF
	or a                                   ; 03F0
	jr nz,L03F5                            ; 03F1
	ld a,04h                               ; 03F3
L03F5:	dec a                            ; 03F5
	jp p,L03FB                             ; 03F6
	ld a,05h                               ; 03F9
L03FB:	cp 06h                           ; 03FB
	jr c,L0400                             ; 03FD
	xor a                                  ; 03FF
L0400:	inc a                            ; 0400
	ex af,af'                              ; 0401
	exx                                    ; 0402
	call L05F4                             ; 0403
	ex af,af'                              ; 0406
	ld (hl),a                              ; 0407
	exx                                    ; 0408
	jp L036D                               ; 0409
L040C:	exx                              ; 040C
	call L05FE                             ; 040D
	exx                                    ; 0410
	inc a                                  ; 0411
	jr L0431                               ; 0412
L0414:	exx                              ; 0414
	call L05FE                             ; 0415
	exx                                    ; 0418
	dec a                                  ; 0419
	jr L042C                               ; 041A
L041C:	call L074B                       ; 041C
	call L0746                             ; 041F
	jr c,L0428                             ; 0422
	ld a,0Ch                               ; 0424
	jr L042C                               ; 0426
L0428:	call L0724                       ; 0428
	ld a,e                                 ; 042B
L042C:	or a                             ; 042C
	jp p,L0431                             ; 042D
	xor a                                  ; 0430
L0431:	cp 10h                           ; 0431
	jr c,L0437                             ; 0433
	ld a,0Fh                               ; 0435
L0437:	ex af,af'                        ; 0437
	exx                                    ; 0438
	call L05FE                             ; 0439
	ex af,af'                              ; 043C
	ld (hl),a                              ; 043D
	exx                                    ; 043E
	ld e,a                                 ; 043F
	ld a,(L0625)                           ; 0440
	call psg_vol                           ; 0443
	jp L036D                               ; 0446
L0449:	call L0724                       ; 0449
	ld a,e                                 ; 044C
	or a                                   ; 044D
	jr nz,L0452                            ; 044E
	ld a,04h                               ; 0450
L0452:	exx                              ; 0452
	ld l,40h                               ; 0453
	ld d,a                                 ; 0455
	call L06FB                             ; 0456
	ld a,l                                 ; 0459
	exx                                    ; 045A
	ld e,a                                 ; 045B
	ex af,af'                              ; 045C
L045D:	call L074B                       ; 045D
	cp 2Eh                                 ; 0460
	jr nz,L046C                            ; 0462
	srl e                                  ; 0464
	ex af,af'                              ; 0466
	add a,e                                ; 0467
	ex af,af'                              ; 0468
	inc hl                                 ; 0469
	jr L045D                               ; 046A
L046C:	ex af,af'                        ; 046C
	or a                                   ; 046D
	jr nz,L0472                            ; 046E
	ld a,10h                               ; 0470
L0472:	ex af,af'                        ; 0472
	exx                                    ; 0473
	call L05F9                             ; 0474
	ex af,af'                              ; 0477
	ld (hl),a                              ; 0478
	exx                                    ; 0479
	jp L036D                               ; 047A
L047D:	call L0724                       ; 047D
	ld a,e                                 ; 0480
	exx                                    ; 0481
	ld e,a                                 ; 0482
	call L0603                             ; 0483
	ld (hl),e                              ; 0486
	exx                                    ; 0487
	jp L036D                               ; 0488
L048B:	call L074B                       ; 048B
	and 0DFh                               ; 048E
	cp 55h                                 ; 0490
	jr z,L04A9                             ; 0492
	cp 46h                                 ; 0494
	jr z,L04B5                             ; 0496
	cp 44h                                 ; 0498
	jp nz,L036D                            ; 049A
	inc hl                                 ; 049D
	call L0724                             ; 049E
	ld a,e                                 ; 04A1
	exx                                    ; 04A2
	ld e,a                                 ; 04A3
	call L0612                             ; 04A4
	jr L04BF                               ; 04A7
L04A9:	inc hl                           ; 04A9
	call L0724                             ; 04AA
	ld a,e                                 ; 04AD
	exx                                    ; 04AE
	ld e,a                                 ; 04AF
	call L0608                             ; 04B0
	jr L04BF                               ; 04B3
L04B5:	inc hl                           ; 04B5
	call L0724                             ; 04B6
	ld a,e                                 ; 04B9
	exx                                    ; 04BA
	ld e,a                                 ; 04BB
	call L060D                             ; 04BC
L04BF:	ld (hl),e                        ; 04BF
	inc hl                                 ; 04C0
	inc hl                                 ; 04C1
	inc hl                                 ; 04C2
	ld (hl),e                              ; 04C3
	exx                                    ; 04C4
	jp L036D                               ; 04C5
L04C8:	ld a,(hl)                        ; 04C8
	ex af,af'                              ; 04C9
	call L05F4                             ; 04CA
	ld b,a                                 ; 04CD
	ld a,(L0625)                           ; 04CE
	ld c,a                                 ; 04D1
	ex af,af'                              ; 04D2
	add a,00h                              ; 04D3
L04D4            equ $-1
	call psg_note                          ; 04D5
	ld a,00h                               ; 04D8
L04D9            equ $-1
	or a                                   ; 04DA
	jr nz,L04E8                            ; 04DB
	call L05DC                             ; 04DD
	call L0617                             ; 04E0
	ld (hl),00h                            ; 04E3
	call L054B                             ; 04E5
L04E8:	pop hl                           ; 04E8
	call L074B                             ; 04E9
	call L0746                             ; 04EC
	jr c,L04F8                             ; 04EF
L04F1:	exx                              ; 04F1
	call L05F9                             ; 04F2
	exx                                    ; 04F5
	jr L051F                               ; 04F6
L04F8:	call L0724                       ; 04F8
	ld a,e                                 ; 04FB
	or a                                   ; 04FC
	jr z,L04F1                             ; 04FD
	exx                                    ; 04FF
	ld l,40h                               ; 0500
	ld d,a                                 ; 0502
	call L06FB                             ; 0503
	ld a,l                                 ; 0506
	exx                                    ; 0507
	ld e,a                                 ; 0508
	ex af,af'                              ; 0509
L050A:	call L074B                       ; 050A
	cp 2Eh                                 ; 050D
	jr nz,L0519                            ; 050F
	srl e                                  ; 0511
	ex af,af'                              ; 0513
	add a,e                                ; 0514
	ex af,af'                              ; 0515
	inc hl                                 ; 0516
	jr L050A                               ; 0517
L0519:	ex af,af'                        ; 0519
	or a                                   ; 051A
	jr nz,L051F                            ; 051B
	ld a,10h                               ; 051D
L051F:	exx                              ; 051F
	ld e,a                                 ; 0520
	call L0621                             ; 0521
	ld (hl),e                              ; 0524
	ld a,e                                 ; 0525
	exx                                    ; 0526
	ret                                    ; 0527
L0528:	ld a,(L0625)                     ; 0528
	ld b,a                                 ; 052B
	call L0645                             ; 052C
	cpl                                    ; 052F
	ld e,a                                 ; 0530
	ld a,(L0323)                           ; 0531
	and e                                  ; 0534
	ld (L0323),a                           ; 0535
	ld a,(L0625)                           ; 0538
	ld e,00h                               ; 053B
	call psg_vol                           ; 053D
	exx                                    ; 0540
	ld hl,02BAh                            ; 0541
L0542            equ $-2
	ld (hl),00h                            ; 0544
	exx                                    ; 0546
	ret                                    ; 0547
L0548:	ld (L0625),a                     ; 0548
L054B:	call L0617                       ; 054B
	dec a                                  ; 054E
	jr z,L058E                             ; 054F
	dec a                                  ; 0551
	jr z,L059F                             ; 0552
	dec a                                  ; 0554
	ret z                                  ; 0555
	call L0608                             ; 0556
	or a                                   ; 0559
	jr nz,L056D                            ; 055A
L055C:	call L0617                       ; 055C
	ld (hl),01h                            ; 055F
	call L05FE                             ; 0561
L0564:	ld e,a                           ; 0564
L0565:	call L061C                       ; 0565
	ld (hl),e                              ; 0568
	call psg_vol_cur                       ; 0569
	ret                                    ; 056C
L056D:	ld hl,078Ch                      ; 056D
	call L0624                             ; 0570
	dec (hl)                               ; 0573
	jr nz,L0589                            ; 0574
	push hl                                ; 0576
	call L0608                             ; 0577
	pop hl                                 ; 057A
	ld (hl),a                              ; 057B
	call L061C                             ; 057C
	inc (hl)                               ; 057F
	ld e,(hl)                              ; 0580
	call L05FE                             ; 0581
	cp e                                   ; 0584
	jr z,L055C                             ; 0585
	jr L0565                               ; 0587
L0589:	call L061C                       ; 0589
	jr L0564                               ; 058C
L058E:	ld hl,0792h                      ; 058E
	call L0624                             ; 0591
	or a                                   ; 0594
	jr z,L0599                             ; 0595
	dec (hl)                               ; 0597
	ret                                    ; 0598
L0599:	call L0617                       ; 0599
	ld (hl),02h                            ; 059C
	ret                                    ; 059E
L059F:	call L0612                       ; 059F
	or a                                   ; 05A2
	jr nz,L05C3                            ; 05A3
L05A5:	call L0617                       ; 05A5
	push hl                                ; 05A8
	call L0603                             ; 05A9
	ld b,03h                               ; 05AC
	or a                                   ; 05AE
	jr z,L05B6                             ; 05AF
	call L05DC                             ; 05B1
	ld b,00h                               ; 05B4
L05B6:	pop hl                           ; 05B6
	ld (hl),b                              ; 05B7
	call L061C                             ; 05B8
	ld (hl),00h                            ; 05BB
	ld e,00h                               ; 05BD
	call psg_vol_cur                       ; 05BF
	ret                                    ; 05C2
L05C3:	ld hl,0798h                      ; 05C3
	call L0624                             ; 05C6
	dec (hl)                               ; 05C9
	ret nz                                 ; 05CA
	push hl                                ; 05CB
	call L0612                             ; 05CC
	pop hl                                 ; 05CF
	ld (hl),a                              ; 05D0
	call L061C                             ; 05D1
	dec (hl)                               ; 05D4
	jr z,L05A5                             ; 05D5
	ld e,(hl)                              ; 05D7
	call psg_vol_cur                       ; 05D8
	ret                                    ; 05DB
L05DC:	ld de,0003h                      ; 05DC
	call L0608                             ; 05DF
	add hl,de                              ; 05E2
	ld (hl),a                              ; 05E3
	call L060D                             ; 05E4
	add hl,de                              ; 05E7
	ld (hl),a                              ; 05E8
	call L0612                             ; 05E9
	add hl,de                              ; 05EC
	ld (hl),a                              ; 05ED
	call L061C                             ; 05EE
	ld (hl),00h                            ; 05F1
	ret                                    ; 05F3
L05F4:	ld hl,0780h                      ; 05F4
	jr L0624                               ; 05F7
L05F9:	ld hl,0783h                      ; 05F9
	jr L0624                               ; 05FC
L05FE:	ld hl,077Dh                      ; 05FE
	jr L0624                               ; 0601
L0603:	ld hl,0786h                      ; 0603
	jr L0624                               ; 0606
L0608:	ld hl,0789h                      ; 0608
	jr L0624                               ; 060B
L060D:	ld hl,078Fh                      ; 060D
	jr L0624                               ; 0610
L0612:	ld hl,0795h                      ; 0612
	jr L0624                               ; 0615
L0617:	ld hl,079Bh                      ; 0617
	jr L0624                               ; 061A
L061C:	ld hl,079Eh                      ; 061C
	jr L0624                               ; 061F
L0621:	ld hl,07A1h                      ; 0621
L0624:	ld bc,0000h                      ; 0624
L0625            equ L0624+1
	add hl,bc                              ; 0627
	ld a,(hl)                              ; 0628
	ret                                    ; 0629
L062A:	ld d,h                           ; 062A
	ld e,l                                 ; 062B
	ld bc,0BB8h                            ; 062C
	call L070B                             ; 062F
	ld a,c                                 ; 0632
	ld (L0638),a                           ; 0633
	ret                                    ; 0636
L0637:	ld b,32h                         ; 0637
L0638            equ L0637+1
L0639:	ld a,12h                         ; 0639
L063B:	dec a                            ; 063B
	jr nz,L063B                            ; 063C
	djnz L0639                             ; 063E
	ld b,0Ah                               ; 0640
L0642:	djnz L0642                       ; 0642
	ret                                    ; 0644
L0645:	add a,a                          ; 0645
	ret nz                                 ; 0646
	inc a                                  ; 0647
	ret                                    ; 0648
psg_vol_cur:	ld a,(L0625)               ; 0649
psg_vol:	add a,a                        ; 064C
	inc a                                  ; 064D
	add a,a                                ; 064E
	add a,a                                ; 064F
	add a,a                                ; 0650
	add a,a                                ; 0651
	or 80h                                 ; 0652
	ld c,a                                 ; 0654
	ld a,e                                 ; 0655
	cpl                                    ; 0656
	and 0Fh                                ; 0657
	or c                                   ; 0659
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	ret                                    ; 065C
	defb 87h,3Ch,87h,87h,87h,87h,0F6h,80h,4Fh,7Bh,2Fh,0E6h,0Fh,0B1h,0D3h,0F3h; 065D
	defb 0C9h                              ; 066D
psg_note:	push bc                       ; 066E
	call L06C0                             ; 066F
	pop bc                                 ; 0672
psg_tone:	ld a,e                        ; 0673
	and 0Fh                                ; 0674
	push de                                ; 0676
	ld e,a                                 ; 0677
	ld a,c                                 ; 0678
	add a,a                                ; 0679
	add a,a                                ; 067A
	add a,a                                ; 067B
	add a,a                                ; 067C
	add a,a                                ; 067D
	or 80h                                 ; 067E
	or e                                   ; 0680
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	pop de                                 ; 0683
	ld a,e                                 ; 0684
	and 0F0h                               ; 0685
	srl d                                  ; 0687
	rra                                    ; 0689
	srl d                                  ; 068A
	rra                                    ; 068C
	rra                                    ; 068D
	rra                                    ; 068E
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	ret                                    ; 0691
psg_tone2:	ld c,02h                     ; 0692
	jr psg_tone                            ; 0694
	defb 0C5h,0CDh,0C0h,06h,0C1h,7Bh,0E6h,0Fh,0D5h,5Fh,79h,87h,87h,87h,87h,87h; 0696
	defb 0F6h,80h,0B3h,0D3h,0F3h,0D1h,7Bh,0E6h,0F0h,0CBh,3Ah,1Fh,0CBh,3Ah,1Fh,1Fh; 06A6
	defb 1Fh,0D3h,0F3h,0C9h                ; 06B6
psg_noise_vol:	cpl                      ; 06BA
	or 0F0h                                ; 06BB
	; SAPI: MZ: OUT (0F2h),A to the SN76489 (psg_write).
	rst 10h
	nop
	ret                                    ; 06BF
L06C0:	push af                          ; 06C0
	cp 0Ch                                 ; 06C1
	jr z,L06D7                             ; 06C3
	cp 0FFh                                ; 06C5
	jr z,L06D2                             ; 06C7
	cp 80h                                 ; 06C9
	jr nz,L06E4                            ; 06CB
	ld de,0001h                            ; 06CD
	pop af                                 ; 06D0
	ret                                    ; 06D1
L06D2:	ld a,0Bh                         ; 06D2
	dec b                                  ; 06D4
	jr L06E4                               ; 06D5
L06D7:	xor a                            ; 06D7
	inc b                                  ; 06D8
	jr L06E4                               ; 06D9
L06DB:	push af                          ; 06DB
	ld l,a                                 ; 06DC
	ld d,0Ch                               ; 06DD
	call L06FB                             ; 06DF
	ld b,l                                 ; 06E2
	ld a,h                                 ; 06E3
L06E4:	add a,a                          ; 06E4
	ld e,a                                 ; 06E5
	ld d,00h                               ; 06E6
	ld hl,0764h                            ; 06E8
	add hl,de                              ; 06EB
	ld e,(hl)                              ; 06EC
	inc hl                                 ; 06ED
	ld d,(hl)                              ; 06EE
	ld a,b                                 ; 06EF
	or a                                   ; 06F0
	jr z,L06F9                             ; 06F1
L06F3:	srl d                            ; 06F3
	rr e                                   ; 06F5
	djnz L06F3                             ; 06F7
L06F9:	pop af                           ; 06F9
	ret                                    ; 06FA
L06FB:	ld b,08h                         ; 06FB
	ld h,00h                               ; 06FD
L06FF:	add hl,hl                        ; 06FF
	ld a,h                                 ; 0700
	cp d                                   ; 0701
	jp m,L0708                             ; 0702
	sub d                                  ; 0705
	ld h,a                                 ; 0706
	inc l                                  ; 0707
L0708:	djnz L06FF                       ; 0708
	ret                                    ; 070A
L070B:	ld a,10h                         ; 070B
	ld hl,0000h                            ; 070D
L0710:	sla c                            ; 0710
	rl b                                   ; 0712
	adc hl,hl                              ; 0714
	sbc hl,de                              ; 0716
	jr nc,L071F                            ; 0718
	add hl,de                              ; 071A
	dec a                                  ; 071B
	jr nz,L0710                            ; 071C
	ret                                    ; 071E
L071F:	inc c                            ; 071F
	dec a                                  ; 0720
	jr nz,L0710                            ; 0721
	ret                                    ; 0723
L0724:	call L074B                       ; 0724
	exx                                    ; 0727
	ld hl,0000h                            ; 0728
	exx                                    ; 072B
L072C:	ld a,(hl)                        ; 072C
	call L0746                             ; 072D
	jr nc,L0741                            ; 0730
	inc hl                                 ; 0732
	exx                                    ; 0733
	add hl,hl                              ; 0734
	ld d,h                                 ; 0735
	ld e,l                                 ; 0736
	add hl,hl                              ; 0737
	add hl,hl                              ; 0738
	add hl,de                              ; 0739
	ld e,a                                 ; 073A
	ld d,00h                               ; 073B
	add hl,de                              ; 073D
	exx                                    ; 073E
	jr L072C                               ; 073F
L0741:	exx                              ; 0741
	push hl                                ; 0742
	exx                                    ; 0743
	pop de                                 ; 0744
	ret                                    ; 0745
L0746:	add a,0D0h                       ; 0746
	cp 0Ah                                 ; 0748
	ret                                    ; 074A
L074B:	ld a,(hl)                        ; 074B
	or a                                   ; 074C
	ret z                                  ; 074D
	cp 21h                                 ; 074E
	ret nc                                 ; 0750
	inc hl                                 ; 0751
	jr L074B                               ; 0752
	defb 43h,00h,44h,02h,45h,04h,46h,05h,47h,07h,41h,09h,42h,0Bh,52h,80h; 0754
note_table:	defb 0AEh,06h,4Eh,06h,0F3h,05h,9Eh,05h,4Dh,05h,01h,05h,0B9h,04h,75h,04h; 0764
	defb 35h,04h,0F8h,03h,0BFh,03h,89h,03h ; 0774
L077C:	defb 09h,15h,15h,15h,02h,02h,02h,04h,04h,04h,00h,00h,00h,00h,00h,00h; 077C
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,14h,14h,14h,00h,00h,00h,00h; 078C
	defb 00h,00h,00h,00h,00h               ; 079C
L07A1:	defb 10h                         ; 07A1
L07A2:	defb 10h                         ; 07A2
L07A3:	defb 10h,08h,00h,08h,00h,08h,00h,08h,00h,56h,30h,5Eh,52h,31h,00h,80h; 07A3
	defb 0Fh,46h,45h,44h,43h,42h,80h,0Eh,41h,40h,3Fh,3Eh,3Dh,80h,0Dh,3Ch; 07B3
	defb 3Bh,3Ah,38h,37h,80h,0Ch,36h,35h,34h,34h,33h,80h,0Bh,32h,31h,30h; 07C3
	defb 2Fh,2Eh,80h,0Ah,2Dh,2Ch,2Bh,2Ah,29h,80h,09h,28h,27h,26h,25h,24h; 07D3
	defb 80h,08h,23h,22h,21h,20h,1Fh,80h,07h,1Eh,1Dh,1Ch,1Bh,1Ah,80h,06h; 07E3
	defb 19h,18h,17h,16h,15h,00h,80h,0Fh,0Fh,10h,11h,12h,13h,80h,0Eh,14h; 07F3
	defb 15h,16h,17h,18h,80h,0Dh,19h,1Ah,1Bh,1Ch,1Dh,80h,0Ch,1Eh,1Fh,20h; 0803
	defb 21h,22h,80h,0Bh,23h,24h,25h,26h,27h,80h,0Ah,28h,29h,2Ah,2Bh,2Ch; 0813
	defb 80h,09h,2Dh,2Eh,2Fh,30h,31h,80h,08h,32h,33h,34h,35h,36h,80h,07h; 0823
	defb 37h,38h,39h,3Ah,3Bh,80h,06h,3Ch,3Dh,3Eh,3Fh,40h,00h,80h,00h,0Fh; 0833
	defb 10h,11h,12h,13h,80h,00h,14h,15h,16h,17h,18h,80h,00h,19h,1Ah,1Bh; 0843
	defb 1Ch,1Dh,80h,00h,1Eh,1Fh,20h,21h,22h,80h,00h,23h,24h,25h,26h,27h; 0853
	defb 80h,00h,28h,29h,2Ah,2Bh,2Ch,80h,00h,2Dh,2Eh,2Fh,30h,31h,80h,00h; 0863
	defb 32h,33h,34h,35h,36h,80h,00h,37h,38h,39h,3Ah,3Bh,80h,00h,3Ch,3Dh; 0873
	defb 3Eh,3Fh,40h,00h,41h,38h,2Bh,43h,38h,2Dh,24h,42h,38h,20h,47h,38h; 0883
	defb 24h,41h,38h,2Bh,43h,38h,2Dh,24h,42h,38h,47h,38h,24h,41h,38h,20h; 0893
	defb 24h,42h,38h,2Bh,43h,38h,24h,44h,38h,24h,45h,38h,46h,38h,24h,47h; 08A3
	defb 38h,20h,24h,42h,34h,2Eh,24h,41h,38h,24h,47h,38h,46h,38h,20h,46h; 08B3
	defb 38h,24h,45h,38h,24h,45h,33h,32h,46h,33h,32h,24h,45h,31h,36h,44h; 08C3
	defb 38h,24h,45h,34h,20h,24h,42h,34h,2Eh,24h,41h,38h,24h,47h,38h,46h; 08D3
	defb 38h,20h,46h,38h,24h,45h,33h,32h,46h,33h,32h,24h,45h,31h,36h,44h; 08E3
	defb 38h,24h,45h,38h,46h,38h,2Dh,24h,42h,38h,20h,47h,38h,24h,41h,38h; 08F3
	defb 2Bh,43h,38h,2Dh,24h,42h,38h,47h,38h,24h,41h,38h,20h,2Bh,43h,38h; 0903
	defb 2Dh,24h,42h,38h,47h,38h,24h,41h,38h,2Bh,43h,38h,2Dh,24h,42h,38h; 0913
	defb 20h,47h,38h,24h,41h,38h,2Bh,43h,38h,2Dh,24h,42h,38h,47h,38h,24h; 0923
	defb 41h,38h,20h,24h,42h,38h,2Bh,43h,38h,24h,44h,38h,24h,45h,38h,46h; 0933
	defb 38h,24h,47h,38h,20h,24h,42h,34h,2Eh,24h,41h,38h,24h,47h,38h,46h; 0943
	defb 38h,20h,46h,38h,24h,45h,38h,24h,45h,33h,32h,46h,33h,32h,24h,45h; 0953
	defb 31h,36h,44h,38h,24h,45h,34h,20h,24h,42h,34h,2Eh,24h,41h,38h,24h; 0963
	defb 47h,38h,46h,38h,20h,24h,45h,38h,46h,38h,24h,45h,38h,44h,38h,24h; 0973
	defb 45h,38h,45h,38h,20h,46h,31h,36h,24h,47h,31h,36h,46h,38h,45h,38h; 0983
	defb 46h,38h,24h,41h,38h,24h,47h,38h,20h,46h,38h,24h,47h,38h,46h,38h; 0993
	defb 45h,38h,46h,38h,24h,42h,38h,20h,24h,41h,31h,36h,24h,42h,31h,36h; 09A3
	defb 24h,41h,38h,47h,38h,24h,41h,38h,2Bh,43h,38h,2Dh,24h,42h,38h,20h; 09B3
	defb 24h,41h,38h,24h,42h,38h,24h,41h,38h,47h,38h,24h,41h,38h,2Bh,24h; 09C3
	defb 44h,38h,20h,43h,38h,2Dh,24h,42h,38h,24h,41h,38h,24h,47h,38h,46h; 09D3
	defb 38h,24h,45h,38h,20h,24h,44h,38h,43h,38h,2Dh,24h,42h,38h,24h,41h; 09E3
	defb 38h,24h,47h,38h,46h,38h,20h,24h,45h,38h,24h,44h,38h,43h,38h,24h; 09F3
	defb 45h,38h,24h,42h,38h,24h,41h,38h,20h,47h,38h,24h,41h,38h,24h,42h; 0A03
	defb 38h,2Bh,43h,38h,24h,44h,38h,24h,45h,38h,20h,46h,31h,36h,24h,47h; 0A13
	defb 31h,36h,46h,38h,45h,38h,46h,38h,24h,41h,38h,24h,47h,38h,20h,46h; 0A23
	defb 38h,24h,47h,38h,46h,38h,45h,38h,46h,38h,24h,42h,38h,20h,24h,41h; 0A33
	defb 31h,36h,24h,42h,31h,36h,24h,41h,38h,47h,38h,24h,41h,38h,2Bh,43h; 0A43
	defb 38h,2Dh,24h,42h,38h,20h,24h,41h,38h,24h,42h,38h,24h,41h,38h,47h; 0A53
	defb 38h,24h,41h,38h,2Bh,46h,38h,20h,24h,45h,38h,24h,44h,38h,43h,38h; 0A63
	defb 2Dh,24h,42h,38h,24h,41h,38h,24h,47h,38h,20h,46h,38h,24h,45h,38h; 0A73
	defb 24h,44h,38h,43h,38h,2Dh,24h,42h,38h,24h,41h,38h,20h,41h,38h,2Bh; 0A83
	defb 43h,38h,2Dh,24h,42h,38h,46h,38h,24h,47h,38h,43h,38h,20h,24h,44h; 0A93
	defb 34h,52h,34h,24h,41h,34h,20h,24h,41h,32h,24h,45h,34h,20h,24h,41h; 0AA3
	defb 32h,45h,34h,20h,24h,41h,32h,46h,34h,20h,2Bh,46h,32h,46h,34h,20h; 0AB3
	defb 46h,32h,2Dh,24h,42h,34h,20h,2Bh,46h,32h,43h,34h,20h,24h,45h,32h; 0AC3
	defb 24h,44h,34h,20h,43h,38h,24h,45h,38h,24h,44h,34h,2Dh,24h,42h,34h; 0AD3
	defb 20h,24h,41h,32h,24h,45h,34h,20h,24h,41h,32h,45h,34h,20h,24h,41h; 0AE3
	defb 32h,46h,34h,20h,2Bh,46h,32h,2Eh,20h,43h,31h,36h,24h,44h,31h,36h; 0AF3
	defb 43h,38h,2Dh,42h,34h,2Bh,43h,34h,20h,24h,41h,34h,2Dh,24h,42h,34h; 0B03
	defb 2Bh,47h,34h,20h,2Dh,41h,34h,2Bh,24h,47h,34h,2Dh,24h,41h,34h,20h; 0B13
	defb 2Bh,46h,34h,2Dh,46h,34h,24h,42h,34h,20h,24h,41h,32h,24h,45h,34h; 0B23
	defb 20h,2Bh,24h,41h,31h,36h,2Dh,24h,41h,31h,36h,5Eh,24h,41h,34h,2Eh; 0B33
	defb 45h,34h,20h,2Bh,24h,41h,31h,36h,2Dh,24h,41h,31h,36h,5Eh,24h,41h; 0B43
	defb 34h,2Eh,46h,34h,20h,2Bh,24h,41h,31h,36h,46h,31h,36h,5Eh,46h,34h; 0B53
	defb 2Eh,46h,34h,20h,24h,41h,31h,36h,46h,31h,36h,5Eh,46h,34h,2Eh,2Dh; 0B63
	defb 24h,42h,34h,20h,2Bh,24h,41h,31h,36h,46h,31h,36h,5Eh,46h,34h,2Eh; 0B73
	defb 43h,34h,20h,24h,41h,31h,36h,24h,45h,38h,2Eh,24h,44h,34h,43h,34h; 0B83
	defb 20h,24h,41h,31h,36h,24h,45h,38h,2Eh,24h,44h,34h,2Eh,2Dh,24h,42h; 0B93
	defb 38h,20h,2Bh,24h,41h,31h,36h,2Dh,24h,41h,31h,36h,5Eh,24h,41h,34h; 0BA3
	defb 2Eh,24h,45h,34h,20h,2Bh,24h,41h,31h,36h,2Dh,24h,41h,31h,36h,5Eh; 0BB3
	defb 24h,41h,34h,2Eh,45h,34h,20h,2Bh,24h,41h,31h,36h,2Dh,24h,41h,31h; 0BC3
	defb 36h,5Eh,24h,41h,34h,2Eh,46h,34h,20h,2Bh,46h,32h,2Eh,20h,46h,32h; 0BD3
	defb 2Dh,24h,42h,34h,20h,2Bh,24h,45h,32h,2Dh,41h,34h,20h,2Bh,24h,45h; 0BE3
	defb 34h,2Dh,24h,41h,34h,2Bh,44h,34h,20h,46h,34h,24h,45h,34h,24h,41h; 0BF3
	defb 34h,20h,00h,56h,31h,33h,53h,30h,4Dh,55h,30h,4Dh,46h,30h,4Dh,44h; 0C03
	defb 32h,30h,20h,20h,20h,20h,20h,4Fh,33h,20h,52h,32h,2Eh,20h,52h,32h; 0C13
	defb 2Eh,20h,52h,32h,2Eh,20h,52h,32h,2Eh,20h,52h,34h,46h,34h,46h,34h; 0C23
	defb 20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h; 0C33
	defb 34h,46h,34h,46h,34h,20h,52h,34h,24h,47h,34h,24h,47h,34h,20h,52h; 0C43
	defb 34h,24h,47h,34h,24h,47h,34h,20h,52h,34h,24h,47h,34h,24h,47h,34h; 0C53
	defb 20h,52h,34h,24h,47h,34h,24h,47h,34h,20h,52h,34h,46h,34h,46h,34h; 0C63
	defb 20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h; 0C73
	defb 34h,46h,34h,46h,34h,20h,52h,34h,24h,47h,34h,24h,47h,34h,20h,52h; 0C83
	defb 34h,24h,47h,34h,24h,47h,34h,20h,52h,34h,24h,47h,34h,24h,47h,34h; 0C93
	defb 20h,52h,34h,24h,47h,34h,52h,34h,20h,52h,34h,24h,45h,34h,24h,45h; 0CA3
	defb 34h,20h,52h,34h,24h,44h,34h,24h,44h,34h,20h,52h,34h,24h,47h,34h; 0CB3
	defb 24h,47h,34h,20h,52h,34h,46h,34h,52h,34h,20h,52h,34h,24h,45h,34h; 0CC3
	defb 52h,34h,20h,52h,34h,24h,44h,34h,52h,34h,20h,52h,34h,2Dh,24h,41h; 0CD3
	defb 34h,2Bh,43h,34h,20h,52h,34h,46h,34h,52h,34h,20h,52h,34h,46h,34h; 0CE3
	defb 46h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,24h,41h,34h,24h; 0CF3
	defb 41h,34h,20h,52h,34h,24h,41h,34h,52h,34h,20h,52h,34h,24h,42h,34h; 0D03
	defb 52h,34h,20h,52h,34h,24h,44h,34h,52h,34h,20h,52h,34h,2Dh,24h,41h; 0D13
	defb 34h,24h,41h,34h,20h,52h,34h,2Bh,46h,34h,52h,34h,20h,52h,34h,43h; 0D23
	defb 34h,43h,34h,20h,43h,34h,43h,34h,43h,34h,20h,52h,34h,24h,44h,34h; 0D33
	defb 24h,44h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,24h,47h,34h; 0D43
	defb 24h,47h,34h,20h,52h,34h,24h,47h,34h,24h,47h,34h,20h,52h,34h,46h; 0D53
	defb 34h,46h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,2Dh,24h,41h; 0D63
	defb 34h,24h,41h,34h,20h,52h,34h,2Bh,43h,34h,43h,34h,20h,52h,34h,24h; 0D73
	defb 44h,34h,24h,44h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,46h; 0D83
	defb 34h,46h,34h,20h,52h,34h,45h,34h,52h,34h,20h,52h,34h,52h,34h,43h; 0D93
	defb 34h,20h,52h,32h,2Eh,20h,52h,34h,2Dh,24h,41h,34h,24h,41h,34h,20h; 0DA3
	defb 52h,34h,2Bh,43h,34h,43h,34h,20h,52h,34h,24h,44h,34h,24h,44h,34h; 0DB3
	defb 20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,24h,47h,34h,24h,47h,34h; 0DC3
	defb 20h,52h,34h,24h,47h,34h,24h,47h,34h,20h,52h,34h,46h,34h,46h,34h; 0DD3
	defb 20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,2Dh,24h,41h,34h,24h,41h; 0DE3
	defb 34h,20h,52h,34h,2Bh,43h,34h,43h,34h,20h,52h,34h,24h,45h,34h,24h; 0DF3
	defb 45h,34h,20h,52h,34h,44h,34h,44h,34h,20h,52h,34h,47h,34h,47h,34h; 0E03
	defb 20h,52h,34h,24h,47h,34h,24h,47h,34h,20h,52h,34h,24h,47h,34h,00h; 0E13
	defb 56h,31h,33h,53h,30h,4Dh,55h,30h,4Dh,46h,30h,4Dh,44h,32h,30h,20h; 0E23
	defb 20h,20h,20h,20h,4Fh,33h,20h,52h,32h,2Eh,20h,52h,32h,2Eh,20h,52h; 0E33
	defb 32h,2Eh,20h,52h,32h,2Eh,20h,2Dh,24h,44h,34h,2Bh,24h,44h,34h,24h; 0E43
	defb 44h,34h,20h,2Dh,46h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,24h; 0E53
	defb 44h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,46h,34h,2Bh,24h,44h; 0E63
	defb 34h,24h,44h,34h,20h,2Dh,2Dh,24h,41h,34h,2Bh,2Bh,43h,34h,43h,34h; 0E73
	defb 20h,2Dh,24h,45h,34h,2Bh,43h,34h,43h,34h,20h,2Dh,2Dh,24h,41h,34h; 0E83
	defb 2Bh,2Bh,43h,34h,43h,34h,20h,2Dh,24h,45h,34h,2Bh,43h,34h,43h,34h; 0E93
	defb 20h,2Dh,24h,44h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,46h,34h; 0EA3
	defb 2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,24h,44h,34h,2Bh,24h,44h,34h; 0EB3
	defb 24h,44h,34h,20h,2Dh,46h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh; 0EC3
	defb 2Dh,24h,41h,34h,2Bh,2Bh,43h,34h,43h,34h,20h,2Dh,24h,45h,34h,2Bh; 0ED3
	defb 43h,34h,43h,34h,20h,2Dh,2Dh,24h,41h,34h,2Bh,2Bh,43h,34h,43h,34h; 0EE3
	defb 20h,2Dh,24h,41h,34h,2Bh,43h,34h,2Dh,2Dh,24h,41h,34h,20h,41h,34h; 0EF3
	defb 2Bh,2Bh,43h,34h,43h,34h,20h,2Dh,2Dh,24h,42h,34h,2Bh,46h,34h,46h; 0F03
	defb 34h,20h,43h,34h,2Bh,43h,34h,43h,34h,20h,2Dh,24h,44h,34h,24h,41h; 0F13
	defb 34h,52h,34h,20h,24h,47h,34h,24h,42h,34h,52h,34h,20h,2Dh,24h,41h; 0F23
	defb 34h,2Bh,24h,41h,34h,52h,34h,20h,2Dh,24h,41h,34h,2Bh,24h,47h,34h; 0F33
	defb 24h,41h,34h,20h,24h,44h,34h,2Bh,24h,44h,34h,52h,34h,20h,2Dh,41h; 0F43
	defb 34h,2Bh,24h,45h,34h,24h,45h,34h,20h,2Dh,24h,42h,34h,2Bh,24h,44h; 0F53
	defb 34h,24h,44h,34h,20h,43h,34h,24h,47h,34h,24h,47h,34h,20h,24h,44h; 0F63
	defb 34h,46h,34h,52h,34h,20h,2Dh,24h,47h,34h,2Bh,24h,45h,34h,52h,34h; 0F73
	defb 20h,2Dh,2Dh,24h,41h,34h,2Bh,24h,41h,34h,52h,34h,20h,2Dh,24h,41h; 0F83
	defb 34h,2Bh,24h,47h,34h,24h,47h,34h,20h,24h,44h,34h,24h,41h,34h,52h; 0F93
	defb 34h,20h,2Dh,24h,41h,34h,2Bh,24h,41h,34h,24h,41h,34h,20h,24h,47h; 0FA3
	defb 34h,24h,47h,34h,24h,47h,34h,20h,24h,44h,34h,24h,41h,34h,24h,41h; 0FB3
	defb 34h,20h,2Dh,24h,41h,34h,2Bh,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh; 0FC3
	defb 24h,45h,34h,2Bh,43h,34h,43h,34h,20h,2Dh,2Dh,24h,41h,34h,2Bh,2Bh; 0FD3
	defb 24h,45h,34h,24h,45h,34h,20h,2Dh,24h,44h,34h,2Bh,24h,44h,34h,24h; 0FE3
	defb 44h,34h,20h,2Dh,46h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,43h; 0FF3
	defb 34h,24h,47h,34h,24h,47h,34h,20h,2Dh,24h,41h,34h,2Bh,24h,47h,34h; 1003
	defb 24h,47h,34h,20h,24h,44h,34h,24h,41h,34h,24h,41h,34h,20h,2Dh,42h; 1013
	defb 34h,2Bh,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,43h,34h,2Bh,43h,34h; 1023
	defb 43h,34h,20h,2Dh,2Dh,43h,34h,2Bh,2Bh,43h,34h,52h,34h,20h,2Dh,2Dh; 1033
	defb 46h,34h,52h,34h,2Bh,46h,34h,20h,52h,32h,2Eh,20h,43h,34h,24h,47h; 1043
	defb 34h,24h,47h,34h,20h,2Dh,24h,41h,34h,2Bh,24h,47h,34h,24h,47h,34h; 1053
	defb 20h,24h,44h,34h,24h,41h,34h,24h,41h,34h,20h,2Dh,24h,41h,34h,2Bh; 1063
	defb 2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,24h,45h,34h,2Bh,43h,34h,43h; 1073
	defb 34h,20h,2Dh,2Dh,24h,41h,34h,2Bh,2Bh,24h,45h,34h,24h,45h,34h,20h; 1083
	defb 2Dh,24h,44h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,2Dh,46h,34h,2Bh; 1093
	defb 24h,44h,34h,24h,44h,34h,20h,2Dh,43h,34h,24h,47h,34h,24h,47h,34h; 10A3
	defb 20h,2Dh,24h,41h,34h,2Bh,24h,41h,34h,24h,41h,34h,20h,24h,43h,34h; 10B3
	defb 24h,41h,34h,24h,41h,34h,20h,2Dh,24h,42h,34h,2Bh,24h,41h,34h,24h; 10C3
	defb 41h,34h,20h,24h,45h,34h,2Bh,24h,44h,34h,24h,44h,34h,20h,52h,34h; 10D3
	defb 24h,44h,34h,24h,44h,34h,20h,2Dh,24h,41h,34h,2Bh,43h,34h,52h,34h; 10E3
	defb 20h,52h,32h,2Eh,20h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 10F3
	defs 269                               ; 1103
	defb 08h,00h,08h,01h,0D7h,01h,92h,02h,56h,31h,33h,53h,30h,4Dh,55h,30h; 1210
	defb 4Dh,46h,30h,4Dh,44h,32h,30h,20h,20h,20h,20h,20h,4Fh,33h,20h,52h; 1220
	defb 32h,2Bh,45h,38h,52h,38h,20h,43h,34h,52h,34h,45h,38h,52h,38h,20h; 1230
	defb 43h,34h,52h,34h,45h,38h,52h,38h,20h,47h,34h,47h,38h,45h,38h,43h; 1240
	defb 38h,45h,38h,20h,44h,34h,2Eh,52h,38h,46h,38h,52h,38h,20h,2Dh,42h; 1250
	defb 34h,52h,34h,2Bh,44h,38h,52h,38h,20h,2Dh,47h,34h,52h,34h,2Bh,44h; 1260
	defb 38h,52h,38h,20h,46h,34h,46h,38h,44h,38h,2Dh,42h,38h,2Bh,44h,38h; 1270
	defb 20h,43h,34h,2Eh,52h,34h,2Eh,20h,41h,32h,2Eh,20h,52h,32h,52h,34h; 1280
	defb 20h,52h,38h,41h,38h,46h,38h,41h,38h,46h,38h,41h,38h,20h,2Bh,44h; 1290
	defb 38h,43h,38h,2Dh,42h,38h,2Bh,44h,38h,43h,38h,2Dh,41h,38h,20h,47h; 12A0
	defb 34h,45h,34h,43h,34h,20h,52h,34h,45h,34h,43h,34h,20h,52h,34h,45h; 12B0
	defb 34h,43h,34h,20h,47h,38h,23h,46h,38h,41h,38h,47h,38h,46h,38h,45h; 12C0
	defb 38h,20h,44h,34h,2Dh,42h,38h,2Bh,47h,38h,46h,34h,20h,44h,34h,2Dh; 12D0
	defb 42h,38h,2Bh,47h,38h,46h,34h,20h,44h,34h,2Dh,42h,38h,2Bh,47h,38h; 12E0
	defb 46h,34h,20h,42h,38h,41h,38h,47h,38h,46h,38h,45h,38h,44h,38h,20h; 12F0
	defb 43h,34h,52h,34h,2Dh,42h,34h,20h,2Bh,43h,34h,52h,34h,2Dh,42h,34h; 1300
	defb 20h,2Bh,43h,34h,52h,32h,20h,00h,56h,31h,33h,53h,30h,4Dh,55h,30h; 1310
	defb 4Dh,46h,30h,4Dh,44h,32h,30h,20h,20h,20h,20h,20h,4Fh,33h,20h,52h; 1320
	defb 32h,52h,34h,20h,43h,34h,45h,34h,45h,34h,20h,43h,34h,45h,34h,45h; 1330
	defb 34h,20h,43h,34h,45h,34h,45h,34h,20h,2Dh,47h,34h,2Bh,44h,34h,44h; 1340
	defb 34h,20h,2Dh,47h,34h,2Bh,44h,34h,44h,34h,20h,2Dh,47h,34h,2Bh,44h; 1350
	defb 34h,44h,34h,20h,2Dh,47h,34h,42h,34h,42h,34h,20h,2Bh,43h,34h,45h; 1360
	defb 34h,52h,34h,20h,43h,34h,46h,34h,46h,34h,20h,43h,34h,46h,34h,46h; 1370
	defb 34h,20h,43h,34h,46h,34h,46h,34h,20h,43h,34h,46h,34h,46h,34h,20h; 1380
	defb 43h,34h,45h,34h,45h,34h,20h,43h,34h,45h,34h,45h,34h,20h,43h,34h; 1390
	defb 45h,34h,45h,34h,20h,43h,34h,45h,34h,45h,34h,20h,2Dh,47h,34h,2Bh; 13A0
	defb 44h,34h,44h,34h,20h,2Dh,47h,34h,2Bh,44h,34h,44h,34h,20h,2Dh,47h; 13B0
	defb 34h,2Bh,44h,34h,44h,34h,20h,2Dh,47h,34h,42h,34h,42h,34h,20h,2Bh; 13C0
	defb 43h,34h,52h,34h,2Dh,47h,34h,20h,2Bh,43h,34h,52h,34h,2Dh,47h,34h; 13D0
	defb 20h,2Bh,43h,34h,52h,34h,00h,56h,31h,33h,53h,30h,4Dh,55h,30h,4Dh; 13E0
	defb 46h,30h,4Dh,44h,32h,30h,20h,20h,20h,20h,20h,4Fh,33h,20h,52h,32h; 13F0
	defb 52h,34h,20h,52h,34h,47h,34h,47h,34h,20h,52h,34h,47h,34h,47h,34h; 1400
	defb 20h,52h,34h,47h,34h,47h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h; 1410
	defb 34h,46h,34h,46h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,46h; 1420
	defb 34h,46h,34h,20h,52h,34h,47h,34h,52h,34h,20h,52h,34h,41h,34h,41h; 1430
	defb 34h,20h,52h,34h,41h,34h,41h,34h,20h,52h,34h,41h,34h,41h,34h,20h; 1440
	defb 52h,34h,41h,34h,41h,34h,20h,52h,34h,47h,34h,47h,34h,20h,52h,34h; 1450
	defb 47h,34h,47h,34h,20h,52h,34h,47h,34h,47h,34h,20h,52h,34h,47h,34h; 1460
	defb 47h,34h,20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,46h,34h,46h,34h; 1470
	defb 20h,52h,34h,46h,34h,46h,34h,20h,52h,34h,46h,34h,46h,34h,20h,45h; 1480
	defb 34h,52h,34h,44h,34h,20h,45h,34h,52h,34h,44h,34h,20h,45h,34h,52h; 1490
	defb 32h,20h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,2Dh; 14A0
	defs 80                                ; 14B0

; ======================================================================
; SAPI: RAM of the port (map, saved page 0, stack) and the pixel tables

	org 1500h
page0_save:	defs 038h		; CP/M page 0 08h-3Fh (RST vectors)
page0_end:	equ 040h
ext_vectors:	defs 24			; MZ: FA00h
; The stack goes down from 1C00h (1.7 KB). The MZ stack starts at FFFFh: the
; game leaves subroutines with JP (poll_keys -> menu, title), held keys can
; make it grow by about 24 bytes per round.
stack_top:	equ 1C00h

	org 1C00h
	include tables.asm

; ======================================================================
; main program 2000-7FFF

	org 2000h
start:	im 1                             ; 2000
	; SAPI: MZ: LD SP,0000h (stack at the top of RAM, CGA-1V there).
	ld sp,stack_top
	ld bc,00CDh                            ; 2005
	; SAPI: MZ: OUT (C),B: RF = 0 (CDh), display mode 0 = 320 x 200, 4 colours (CEh).
	nop
	nop
	inc c                                  ; 200A
	; SAPI: MZ: OUT (C),B: RF = 0 (CDh), display mode 0 = 320 x 200, 4 colours (CEh).
	nop
	nop
	ld bc,00F0h                            ; 200D
	; SAPI: MZ: OUT (C),B to the palette (0F0h), pal_write.
	rst 18h
	nop
	ld b,11h                               ; 2012
	; SAPI: MZ: OUT (C),B to the palette (0F0h), pal_write.
	rst 18h
	nop
	ld b,22h                               ; 2016
	; SAPI: MZ: OUT (C),B to the palette (0F0h), pal_write.
	rst 18h
	nop
	ld b,36h                               ; 201A
	; SAPI: MZ: OUT (C),B to the palette (0F0h), pal_write.
	rst 18h
	nop
	call cls                               ; 201E
	ld bc,06CFh                            ; 2021
	xor a                                  ; 2024
	; SAPI: MZ: OUT (C),A: scroll register 6 (CFh) = 0.
	nop
	nop
	ld bc,font                             ; 2027
	ld hl,L7332                            ; 202A
	sbc hl,bc                              ; 202D
	ld b,h                                 ; 202F
	ld c,l                                 ; 2030
	ld hl,font                             ; 2031
L2034:	push bc                          ; 2034
	ld b,08h                               ; 2035
	xor a                                  ; 2037
L2038:	sla a                            ; 2038
	srl (hl)                               ; 203A
	call c,L204B                           ; 203C
	djnz L2038                             ; 203F
	ld (hl),a                              ; 2041
	inc hl                                 ; 2042
	pop bc                                 ; 2043
	dec bc                                 ; 2044
	ld a,b                                 ; 2045
	or c                                   ; 2046
	jr z,restart                           ; 2047
	jr L2034                               ; 2049
L204B:	set 0,a                          ; 204B
	ret                                    ; 204D
restart:	di                             ; 204E
	; SAPI: MZ: LD SP,0000h (stack at the top of RAM, CGA-1V there).
	ld sp,stack_top
	xor a                                  ; 2052
	ld (L331D),a                           ; 2053
	ld (L331F),a                           ; 2056
	ld a,01h                               ; 2059
	ld (stage),a                           ; 205B
title_loop:	call title                  ; 205E
	ld a,(speed_digit)                     ; 2061
	sub 30h                                ; 2064
	ld hl,speed_table                      ; 2066
	add a,l                                ; 2069
	ld l,a                                 ; 206A
	ld a,(hl)                              ; 206B
	ld (tick_div),a                        ; 206C
	ld a,(L5C15)                           ; 206F
	ld (lives),a                           ; 2072
	ld hl,0000h                            ; 2075
	ld (L3F06),hl                          ; 2078
	call clear_map                         ; 207B
stage_start:	xor a                      ; 207E
	ld (dying),a                           ; 207F
	ld (stage_clear),a                     ; 2082
	ld (L2244),a                           ; 2085
	ld hl,(L5C16)                          ; 2088
	ld (time_left),hl                      ; 208B
	call draw_field_bg                     ; 208E
	ld a,0F0h                              ; 2091
	call delay                             ; 2093
	call load_stage                        ; 2096
	call L5672                             ; 2099
	xor a                                  ; 209C
	ld (quit_req),a                        ; 209D
	ld hl,L2247                            ; 20A0
	ld (L21EC),hl                          ; 20A3
	ld a,10h                               ; 20A6
	ld (L78EB),a                           ; 20A8
	ld hl,1210h                            ; 20AB
	call music_start                       ; 20AE
main_loop:	xor a                        ; 20B1
	ld (ticks),a                           ; 20B2
	call L4FB5                             ; 20B5
	ld a,(L5028)                           ; 20B8
	cp 0FFh                                ; 20BB
	jp z,lose_life                         ; 20BD
	call L219A                             ; 20C0
	call L4747                             ; 20C3
	call check_clear                       ; 20C6
	ld a,01h                               ; 20C9
	ld (L2245),a                           ; 20CB
	call L581D                             ; 20CE
	call L4CE4                             ; 20D1
	call L3F79                             ; 20D4
	call L21A8                             ; 20D7
	call wait_ticks                        ; 20DA
	xor a                                  ; 20DD
	ld (ticks),a                           ; 20DE
	call L219A                             ; 20E1
	call L4BC5                             ; 20E4
	xor a                                  ; 20E7
	ld (L2245),a                           ; 20E8
	call L581D                             ; 20EB
	call L4465                             ; 20EE
	call check_clear                       ; 20F1
	call L4EB6                             ; 20F4
	call L3F79                             ; 20F7
	call wait_ticks                        ; 20FA
	ld a,(dying)                           ; 20FD
	and a                                  ; 2100
	jp z,main_loop                         ; 2101
	ld a,(L78EB)                           ; 2104
	cp 20h                                 ; 2107
	jr nc,L210F                            ; 2109
	inc a                                  ; 210B
	ld (L78EB),a                           ; 210C
L210F:	ld a,(dying)                     ; 210F
	dec a                                  ; 2112
	ld (dying),a                           ; 2113
	jp nz,main_loop                        ; 2116
lose_life:	call music_off               ; 2119
	ld a,(lives)                           ; 211C
	dec a                                  ; 211F
	ld (lives),a                           ; 2120
	jp nz,stage_start                      ; 2123
	ld a,02h                               ; 2126
	ld (L331D),a                           ; 2128
	ld a,01h                               ; 212B
	ld (stage),a                           ; 212D
	jp title_loop                          ; 2130
check_clear:	ld a,(player_state)        ; 2133
	and 7Fh                                ; 2136
	ret nz                                 ; 2138
	ld a,(stage_clear)                     ; 2139
	and a                                  ; 213C
	ret z                                  ; 213D
	pop hl                                 ; 213E
	call music_off                         ; 213F
	call clear_screen_seq                  ; 2142
	ld a,(stage_count)                     ; 2145
	ld c,a                                 ; 2148
	ld a,(stage)                           ; 2149
	cp c                                   ; 214C
	jr nc,L2156                            ; 214D
	inc a                                  ; 214F
	ld (stage),a                           ; 2150
	jp stage_start                         ; 2153
L2156:	call ending                      ; 2156
	ld hl,L3500                            ; 2159
L215C:	call read_dir                    ; 215C
	and 80h                                ; 215F
	jr nz,L217E                            ; 2161
	ld a,01h                               ; 2163
	call read_joy                          ; 2165
	and 10h                                ; 2168
	jr nz,L217E                            ; 216A
	ld a,02h                               ; 216C
	call read_joy                          ; 216E
	and 10h                                ; 2171
	jr nz,L217E                            ; 2173
	ld de,0001h                            ; 2175
	and a                                  ; 2178
	sbc hl,de                              ; 2179
	jp nz,L215C                            ; 217B
L217E:	call music_off                   ; 217E
	ld a,0C8h                              ; 2181
	call delay                             ; 2183
	call cls                               ; 2186
	ld a,32h                               ; 2189
	call delay                             ; 218B
	xor a                                  ; 218E
	ld (last_key),a                        ; 218F
	ld a,01h                               ; 2192
	ld (stage),a                           ; 2194
	jp title_loop                          ; 2197
L219A:	ld a,(player_state)              ; 219A
	and 7Fh                                ; 219D
	cp 01h                                 ; 219F
	ret nz                                 ; 21A1
	ld a,18h                               ; 21A2
	ld (dying),a                           ; 21A4
	ret                                    ; 21A7
L21A8:	ld a,(L2244)                     ; 21A8
	and a                                  ; 21AB
	jp z,L21DE                             ; 21AC
	ld a,(L2244)                           ; 21AF
	inc a                                  ; 21B2
	ld (L2244),a                           ; 21B3
	cp 03h                                 ; 21B6
	jp z,L21C1                             ; 21B8
	cp 06h                                 ; 21BB
	jp z,L21C5                             ; 21BD
	ret                                    ; 21C0
L21C1:	ld a,00h                         ; 21C1
	jr L21CC                               ; 21C3
L21C5:	ld a,01h                         ; 21C5
	ld (L2244),a                           ; 21C7
	ld a,07h                               ; 21CA
L21CC:	ld (text_colour),a               ; 21CC
	ld hl,8161h                            ; 21CF
	ld de,(time_left)                      ; 21D2
	ld a,05h                               ; 21D6
	ld (L3EE9),a                           ; 21D8
	jp print_num                           ; 21DB
L21DE:	ld hl,(time_left)                ; 21DE
	ld de,0001h                            ; 21E1
	sbc hl,de                              ; 21E4
	ld (time_left),hl                      ; 21E6
	push af                                ; 21E9
	ld de,(L0000)                          ; 21EA
L21EC            equ $-2
	sbc hl,de                              ; 21EE
	jp nc,L2202                            ; 21F0
	ld a,(L78EB)                           ; 21F3
	dec a                                  ; 21F6
	ld (L78EB),a                           ; 21F7
	ld hl,(L21EC)                          ; 21FA
	inc hl                                 ; 21FD
	inc hl                                 ; 21FE
	ld (L21EC),hl                          ; 21FF
L2202:	call L3F19                       ; 2202
	pop af                                 ; 2205
	ret nz                                 ; 2206
	ld a,01h                               ; 2207
	ld (L2244),a                           ; 2209
	ld a,(player_state)                    ; 220C
	and a                                  ; 220F
	ret nz                                 ; 2210
	ld a,01h                               ; 2211
	ld (player_state),a                    ; 2213
	ret                                    ; 2216
wait_ticks:	ld a,(tick_div)             ; 2217
	ld b,a                                 ; 221A
L221B:	ld a,(quit_req)                  ; 221B
	and a                                  ; 221E
	jr nz,L2232                            ; 221F
	ld a,(ticks)                           ; 2221
	cp b                                   ; 2224
	jp c,L221B                             ; 2225
L2228:	call read_dir                    ; 2228
	ld a,(key_held)                        ; 222B
	and a                                  ; 222E
	jr nz,L2228                            ; 222F
	ret                                    ; 2231
L2232:	pop hl                           ; 2232
	jp lose_life                           ; 2233
	; SAPI: MZ busy loop (60 ms at 3.5 MHz): replaced by delay_2000_s.
delay_2000:	jp delay_2000_s
	defs 2
L223B:	dec hl                           ; 223B
	ld a,l                                 ; 223C
	or h                                   ; 223D
	jr nz,L223B                            ; 223E
	pop hl                                 ; 2240
	pop af                                 ; 2241
	ret                                    ; 2242
dying:	defb 00h                         ; 2243
L2244:	defb 00h                         ; 2244
L2245:	defb 00h                         ; 2245
stage_clear:	defb 00h                   ; 2246
L2247:	defb 20h,03h,0F4h,01h,2Ch,01h,0C8h,00h,96h,00h,64h,00h,32h,00h,1Eh,00h; 2247
	defb 14h,00h,00h,00h                   ; 2257
speed_table:	defb 19h,1Dh,21h,26h,2Ch,33h,3Bh,44h,4Eh,59h,64h; 225B
keywords:	defb 73h,68h,69h,62h,61h,4Dh,65h,67h,6Dh,49h,50h,65h,6Eh,54h,41h,6Dh; 2266
	defb 69h,6Bh,69h,21h,73h,61h,6Bh,72h,61h,31h,2Ch,32h,2Ch,4Fh,3Fh,3Fh; 2276
	defb 4Fh,6Bh,55h,4Fh,6Dh,6Fh,52h,49h,55h,2Dh,43h,61h,4Eh,51h,75h,6Fh; 2286
	defb 54h,65h,61h,79h,41h,6Bh,6Fh,55h,66h,2Ch,66h,2Ch,43h,68h,69h,65h; 2296
	defb 3Fh,73h,41h,4Bh,45h,21h,53h,79h,6Fh,67h,6Eh,62h,55h,53h,48h,69h; 22A6
	defb 42h,61h,6Bh,41h,21h,53h,54h,4Fh,4Eh,45h,4Ah,61h,70h,61h,6Eh,48h; 22B6
	defb 41h,72h,66h,45h,53h,61h,70h,70h,72h,4Fh,68h,61h,59h,6Fh,47h,6Fh; 22C6
	defb 68h,61h,6Eh,52h,61h,6Dh,65h,6Eh,4Eh,65h,6Dh,75h,69h,4Eh,61h,74h; 22D6
	defb 73h,75h,59h,75h,6Bh,69h,21h,48h,65h,49h,77h,61h,50h,69h,63h,65h; 22E6
	defb 21h,4Dh,5Ah,38h,30h,31h,45h,6Eh,67h,6Ch,61h,52h,6Fh,6Dh,65h,21h; 22F6
	defb 50h,61h,52h,69h,65h,4Ch,65h,74h,67h,6Fh,46h,72h,45h,6Eh,63h,41h; 2306
	defb 46h,65h,77h,65h,47h,65h,72h,4Dh,61h,54h,6Fh,6Bh,79h,6Fh,50h,72h; 2316
	defb 65h,6Eh,64h,4Fh,4Bh,55h,2Dh,48h   ; 2326
title:	ld (L238B),sp                    ; 232E
	xor a                                  ; 2332
	ld (L3320),a                           ; 2333
	ld a,(L331D)                           ; 2336
	and a                                  ; 2339
	jp nz,L26F4                            ; 233A
L233D:	call L377D                       ; 233D
	ld a,01h                               ; 2340
	ld (L331D),a                           ; 2342
	ld a,(speed_digit)                     ; 2345
	sub 30h                                ; 2348
	ld hl,speed_table                      ; 234A
	add a,l                                ; 234D
	ld l,a                                 ; 234E
	ld a,(hl)                              ; 234F
	ld (tick_div),a                        ; 2350
	call cls                               ; 2353
	ld a,08h                               ; 2356
	ld (L78EB),a                           ; 2358
	ld hl,1210h                            ; 235B
	call music_start                       ; 235E
	jp L238D                               ; 2361
L2364:	call L377D                       ; 2364
	call music_off                         ; 2367
	call cls                               ; 236A
	ld a,(L3320)                           ; 236D
	and a                                  ; 2370
	jr nz,L2386                            ; 2371
	ld hl,keyword_buf                      ; 2373
	ld a,20h                               ; 2376
	ld b,05h                               ; 2378
L237A:	ld (hl),a                        ; 237A
	inc hl                                 ; 237B
	djnz L237A                             ; 237C
	ld a,01h                               ; 237E
	ld (keyword_idx),a                     ; 2380
	ld (stage),a                           ; 2383
L2386:	ld sp,(L238B)                    ; 2386
	ret                                    ; 238A
L238B:	defb 00h,00h                     ; 238B
L238D:	call L2DE3                       ; 238D
	call cls_lower                         ; 2390
	ld hl,0D00h                            ; 2393
	ld de,L33DA                            ; 2396
	call vaddr                             ; 2399
	call logo_row                          ; 239C
	call logo_row                          ; 239F
	ld hl,1600h                            ; 23A2
	ld de,L33EE                            ; 23A5
	call vaddr                             ; 23A8
	call logo_row                          ; 23AB
	call logo_row                          ; 23AE
	ld hl,L349D                            ; 23B1
	ld de,L5DDD                            ; 23B4
	call put_obj                           ; 23B7
	ld (L346D),hl                          ; 23BA
	ld (L346B),bc                          ; 23BD
	ld hl,L34F9                            ; 23C1
	ld de,L65ED                            ; 23C4
	call put_obj                           ; 23C7
	ld (L3479),hl                          ; 23CA
	ld (L3477),bc                          ; 23CD
	ld hl,L3507                            ; 23D1
	ld de,L634D                            ; 23D4
	call put_obj                           ; 23D7
	ld (L3485),hl                          ; 23DA
	ld (L3483),bc                          ; 23DD
	ld hl,L34CB                            ; 23E1
	ld de,L5D9D                            ; 23E4
	call put_obj                           ; 23E7
	ld (L3473),hl                          ; 23EA
	ld (L3471),bc                          ; 23ED
	ld ix,L3535                            ; 23F1
	ld de,L6ACD                            ; 23F5
	ld l,(ix+0)                            ; 23F8
	ld h,(ix+1)                            ; 23FB
	ld (L348F),hl                          ; 23FE
	call vaddr                             ; 2401
	call put8x8                            ; 2404
	inc ix                                 ; 2407
	inc ix                                 ; 2409
	ld (L3491),ix                          ; 240B
	ld hl,L3557                            ; 240F
	ld c,(hl)                              ; 2412
	inc hl                                 ; 2413
	ld b,(hl)                              ; 2414
	inc hl                                 ; 2415
	ld (L3493),hl                          ; 2416
	ld (L3495),bc                          ; 2419
	ld hl,L3570                            ; 241D
	ld c,(hl)                              ; 2420
	inc hl                                 ; 2421
	ld b,(hl)                              ; 2422
	inc hl                                 ; 2423
	ld (L3497),hl                          ; 2424
	ld (L3499),bc                          ; 2427
	xor a                                  ; 242B
	ld (L3470),a                           ; 242C
	ld (L3476),a                           ; 242F
	ld (L347B),a                           ; 2432
	ld (L347C),a                           ; 2435
	ld (L3487),a                           ; 2438
	ld (L3488),a                           ; 243B
	ld b,05h                               ; 243E
L2440:	call wait_ticks2                 ; 2440
	djnz L2440                             ; 2443
	ld hl,1212h                            ; 2445
	call vaddr                             ; 2448
	ld de,L36F5                            ; 244B
	ld a,03h                               ; 244E
	call print                             ; 2450
L2453:	call L27DA                       ; 2453
	call L2B03                             ; 2456
	call L2A1C                             ; 2459
	call L2900                             ; 245C
	call L2D14                             ; 245F
	call wait_ticks2                       ; 2462
	call L2866                             ; 2465
	call L2CCA                             ; 2468
	call L2BD2                             ; 246B
	call L2AF0                             ; 246E
	call L2D01                             ; 2471
	call L29A8                             ; 2474
	call L2C2B                             ; 2477
	call wait_ticks2                       ; 247A
	ld hl,(L346D)                          ; 247D
	ld a,(hl)                              ; 2480
	cp 0FFh                                ; 2481
	jr nz,L2453                            ; 2483
	call L2DAC                             ; 2485
	call wait_ticks2                       ; 2488
	call L2DE8                             ; 248B
	call cls_lower                         ; 248E
	ld hl,0902h                            ; 2491
	call vaddr                             ; 2494
	ld de,00A0h                            ; 2497
	add hl,de                              ; 249A
	ld d,h                                 ; 249B
	ld e,l                                 ; 249C
	ld a,82h                               ; 249D
	; SAPI: MZ: OUT (0CCh),A: GDG write format (wf_set).
	rst 08h
	nop
	ld b,0Dh                               ; 24A1
	call box_top                           ; 24A3
	call row_down                          ; 24A6
	ld b,5Eh                               ; 24A9
	call box_right                         ; 24AB
	call row_down                          ; 24AE
	ld b,0Dh                               ; 24B1
	call box_bottom                        ; 24B3
	call row_up                            ; 24B6
	ld b,5Eh                               ; 24B9
	call box_left                          ; 24BB
	ld hl,0A03h                            ; 24BE
	ld de,L65ED                            ; 24C1
	call vaddr                             ; 24C4
	call put16x16                          ; 24C7
	ld hl,0B06h                            ; 24CA
	ld de,L3420                            ; 24CD
	ld a,03h                               ; 24D0
	call vaddr                             ; 24D2
	call print                             ; 24D5
	ld de,L3424                            ; 24D8
	ld a,02h                               ; 24DB
	call print                             ; 24DD
	ld hl,0D03h                            ; 24E0
	ld de,L634D                            ; 24E3
	call vaddr                             ; 24E6
	call put16x16                          ; 24E9
	ld hl,0E06h                            ; 24EC
	ld de,L342B                            ; 24EF
	ld a,03h                               ; 24F2
	call vaddr                             ; 24F4
	call print                             ; 24F7
	ld de,L342F                            ; 24FA
	ld a,02h                               ; 24FD
	call print                             ; 24FF
	ld hl,1004h                            ; 2502
	ld de,L3436                            ; 2505
	ld a,01h                               ; 2508
	call vaddr                             ; 250A
	call print                             ; 250D
	ld hl,1204h                            ; 2510
	ld de,L6ACD                            ; 2513
	call vaddr                             ; 2516
	call put8x8                            ; 2519
	ld hl,1206h                            ; 251C
	ld de,L3442                            ; 251F
	ld a,03h                               ; 2522
	call vaddr                             ; 2524
	call print                             ; 2527
	ld de,L3446                            ; 252A
	ld a,02h                               ; 252D
	call print                             ; 252F
	ld hl,1407h                            ; 2532
	ld de,L344D                            ; 2535
	ld a,02h                               ; 2538
	call vaddr                             ; 253A
	call print                             ; 253D
	ld hl,091Ch                            ; 2540
	call vaddr                             ; 2543
	ld de,00A0h                            ; 2546
	add hl,de                              ; 2549
	ld d,h                                 ; 254A
	ld e,l                                 ; 254B
	ld a,41h                               ; 254C
	; SAPI: MZ: OUT (0CCh),A: GDG write format (wf_set).
	rst 08h
	nop
	ld b,08h                               ; 2550
	call box_top                           ; 2552
	call row_down                          ; 2555
	ld b,5Eh                               ; 2558
	call box_right                         ; 255A
	call row_down                          ; 255D
	ld b,08h                               ; 2560
	call box_bottom                        ; 2562
	call row_up                            ; 2565
	ld b,5Eh                               ; 2568
	call box_left                          ; 256A
	ld hl,0A20h                            ; 256D
	ld de,L6FB2                            ; 2570
	call vaddr                             ; 2573
	call put16x16                          ; 2576
	ld hl,0D1Dh                            ; 2579
	ld de,L7032                            ; 257C
	call vaddr                             ; 257F
	call put16x16                          ; 2582
	ld hl,0D20h                            ; 2585
	ld de,L5DDD                            ; 2588
	call vaddr                             ; 258B
	call put16x16                          ; 258E
	ld hl,0D23h                            ; 2591
	ld de,L7072                            ; 2594
	call vaddr                             ; 2597
	call put16x16                          ; 259A
	ld hl,1020h                            ; 259D
	ld de,L6FF2                            ; 25A0
	call vaddr                             ; 25A3
	call put16x16                          ; 25A6
	ld hl,131Eh                            ; 25A9
	ld de,L70B2                            ; 25AC
	call vaddr                             ; 25AF
	call put16x16                          ; 25B2
	inc hl                                 ; 25B5
	inc hl                                 ; 25B6
	ld de,L70F2                            ; 25B7
	call put16x16                          ; 25BA
	inc hl                                 ; 25BD
	inc hl                                 ; 25BE
	ld de,L7132                            ; 25BF
	call put16x16                          ; 25C2
	ld hl,0C00h                            ; 25C5
	ld de,L3402                            ; 25C8
	call vaddr                             ; 25CB
	call logo_row                          ; 25CE
	call logo_row                          ; 25D1
	ld hl,1800h                            ; 25D4
	ld de,L3416                            ; 25D7
	call vaddr                             ; 25DA
	call logo_row                          ; 25DD
	ld hl,L359B                            ; 25E0
	ld de,L5DDD                            ; 25E3
	call put_obj                           ; 25E6
	ld (L346D),hl                          ; 25E9
	ld (L346B),bc                          ; 25EC
	ld hl,L35E7                            ; 25F0
	ld de,L65ED                            ; 25F3
	call put_obj                           ; 25F6
	ld (L3479),hl                          ; 25F9
	ld (L3477),bc                          ; 25FC
	ld hl,L35EA                            ; 2600
	ld de,L634D                            ; 2603
	call put_obj                           ; 2606
	ld (L3485),hl                          ; 2609
	ld (L3483),bc                          ; 260C
	ld hl,L35ED                            ; 2610
	ld de,L65ED                            ; 2613
	call put_obj                           ; 2616
	ld (L347F),hl                          ; 2619
	ld (L347D),bc                          ; 261C
	ld hl,L35F0                            ; 2620
	ld de,L634D                            ; 2623
	call put_obj                           ; 2626
	ld (L348B),hl                          ; 2629
	ld (L3489),bc                          ; 262C
	ld hl,L35C1                            ; 2630
	ld de,L5D9D                            ; 2633
	call put_obj                           ; 2636
	ld (L3473),hl                          ; 2639
	ld (L3471),bc                          ; 263C
	ld ix,L3616                            ; 2640
	ld de,L6ACD                            ; 2644
	ld l,(ix+0)                            ; 2647
	ld h,(ix+1)                            ; 264A
	ld (L348F),hl                          ; 264D
	call vaddr                             ; 2650
	call put8x8                            ; 2653
	inc ix                                 ; 2656
	inc ix                                 ; 2658
	ld (L3491),ix                          ; 265A
	ld hl,L3631                            ; 265E
	ld c,(hl)                              ; 2661
	inc hl                                 ; 2662
	ld b,(hl)                              ; 2663
	inc hl                                 ; 2664
	ld (L3493),hl                          ; 2665
	ld (L3495),bc                          ; 2668
	ld hl,L3653                            ; 266C
	ld (L349B),hl                          ; 266F
	xor a                                  ; 2672
	ld (L3470),a                           ; 2673
	ld (L3476),a                           ; 2676
	ld (L347B),a                           ; 2679
	ld (L347C),a                           ; 267C
	ld (L3481),a                           ; 267F
	ld (L3482),a                           ; 2682
	ld (L3487),a                           ; 2685
	ld (L3488),a                           ; 2688
	ld (L348D),a                           ; 268B
	ld (L348E),a                           ; 268E
	ld b,05h                               ; 2691
L2693:	call wait_ticks2                 ; 2693
	djnz L2693                             ; 2696
L2698:	call L27DA                       ; 2698
	call L28DE                             ; 269B
	call L27DA                             ; 269E
	call L28DE                             ; 26A1
	call L2B03                             ; 26A4
	call L2C09                             ; 26A7
	call L2B03                             ; 26AA
	call L2C09                             ; 26AD
	call L2A1C                             ; 26B0
	call L2900                             ; 26B3
	call L2CCA                             ; 26B6
	call wait_ticks2                       ; 26B9
	call L2866                             ; 26BC
	call L28DE                             ; 26BF
	call L2866                             ; 26C2
	call L28DE                             ; 26C5
	call L2BD2                             ; 26C8
	call L2C09                             ; 26CB
	call L2BD2                             ; 26CE
	call L2C09                             ; 26D1
	call L2D3D                             ; 26D4
	call L2AF0                             ; 26D7
	call L29A8                             ; 26DA
	call L2C2B                             ; 26DD
	call wait_ticks2                       ; 26E0
	ld hl,(L346D)                          ; 26E3
	ld a,(hl)                              ; 26E6
	cp 0FFh                                ; 26E7
	jr nz,L2698                            ; 26E9
	call L2DAC                             ; 26EB
	call wait_ticks2                       ; 26EE
	jp L238D                               ; 26F1
L26F4:	call wait_ticks2                 ; 26F4
	ld hl,070Ah                            ; 26F7
	call vaddr                             ; 26FA
	ld c,0Ch                               ; 26FD
L26FF:	ld b,0Ah                         ; 26FF
L2701:	call clr16x8                     ; 2701
	inc hl                                 ; 2704
	inc hl                                 ; 2705
	djnz L2701                             ; 2706
	ld de,012Ch                            ; 2708
	add hl,de                              ; 270B
	dec c                                  ; 270C
	jr nz,L26FF                            ; 270D
	call L2772                             ; 270F
	ld hl,0D0Bh                            ; 2712
	ld de,L3670                            ; 2715
	call vaddr                             ; 2718
	ld a,02h                               ; 271B
	call print                             ; 271D
	push hl                                ; 2720
	ld de,00A0h                            ; 2721
	add hl,de                              ; 2724
	ld de,L3684                            ; 2725
	ld a,03h                               ; 2728
	call print                             ; 272A
	pop hl                                 ; 272D
	ld de,0FF60h                           ; 272E
	add hl,de                              ; 2731
	ld de,L367A                            ; 2732
	call print                             ; 2735
	ld hl,110Bh                            ; 2738
	ld de,L368C                            ; 273B
	ld a,02h                               ; 273E
	call vaddr                             ; 2740
	call print                             ; 2743
	ld de,L3695                            ; 2746
	ld a,03h                               ; 2749
	call print                             ; 274B
	call wait_ticks2                       ; 274E
	ld b,30h                               ; 2751
L2753:	push bc                          ; 2753
	call L27B9                             ; 2754
	call wait_ticks2                       ; 2757
	call wait_ticks2                       ; 275A
	call wait_ticks2                       ; 275D
	call L2772                             ; 2760
	call wait_ticks2                       ; 2763
	call wait_ticks2                       ; 2766
	call wait_ticks2                       ; 2769
	pop bc                                 ; 276C
	djnz L2753                             ; 276D
	jp L233D                               ; 276F
L2772:	ld hl,080Bh                      ; 2772
	call vaddr                             ; 2775
	ld de,L7172                            ; 2778
	call put16x16                          ; 277B
	inc hl                                 ; 277E
	inc hl                                 ; 277F
	ld de,L71B2                            ; 2780
	call put16x16                          ; 2783
	inc hl                                 ; 2786
	inc hl                                 ; 2787
	ld de,L71F2                            ; 2788
	call put16x16                          ; 278B
	inc hl                                 ; 278E
	inc hl                                 ; 278F
	ld de,L7232                            ; 2790
	call put16x16                          ; 2793
	inc hl                                 ; 2796
	inc hl                                 ; 2797
	inc hl                                 ; 2798
	inc hl                                 ; 2799
	ld de,L7272                            ; 279A
	call put16x16                          ; 279D
	inc hl                                 ; 27A0
	inc hl                                 ; 27A1
	ld de,L72B2                            ; 27A2
	call put16x16                          ; 27A5
	inc hl                                 ; 27A8
	inc hl                                 ; 27A9
	ld de,L7232                            ; 27AA
	call put16x16                          ; 27AD
	inc hl                                 ; 27B0
	inc hl                                 ; 27B1
	ld de,L72F2                            ; 27B2
	call put16x16                          ; 27B5
	ret                                    ; 27B8
L27B9:	ld hl,080Bh                      ; 27B9
	call vaddr                             ; 27BC
	ld b,04h                               ; 27BF
L27C1:	call clr8x16                     ; 27C1
	inc hl                                 ; 27C4
	call clr8x16                           ; 27C5
	inc hl                                 ; 27C8
	djnz L27C1                             ; 27C9
	inc hl                                 ; 27CB
	inc hl                                 ; 27CC
	ld b,04h                               ; 27CD
L27CF:	call clr8x16                     ; 27CF
	inc hl                                 ; 27D2
	call clr8x16                           ; 27D3
	inc hl                                 ; 27D6
	djnz L27CF                             ; 27D7
	ret                                    ; 27D9
L27DA:	call L2A90                       ; 27DA
	ld a,(L347C)                           ; 27DD
	and a                                  ; 27E0
	jp nz,L2841                            ; 27E1
	ld hl,(L3479)                          ; 27E4
	ld a,(hl)                              ; 27E7
	cp 05h                                 ; 27E8
	ret nc                                 ; 27EA
	and a                                  ; 27EB
	ret z                                  ; 27EC
	ld hl,(L3477)                          ; 27ED
	call vaddr                             ; 27F0
	push af                                ; 27F3
	ld a,(L347B)                           ; 27F4
	cpl                                    ; 27F7
	ld (L347B),a                           ; 27F8
	pop af                                 ; 27FB
	dec a                                  ; 27FC
	jr z,L2807                             ; 27FD
	dec a                                  ; 27FF
	jr z,L281D                             ; 2800
	dec a                                  ; 2802
	jr z,L2833                             ; 2803
	jr L283A                               ; 2805
L2807:	ld bc,0FEC0h                     ; 2807
	add hl,bc                              ; 280A
	ld a,(L347B)                           ; 280B
	and a                                  ; 280E
	jr z,L2817                             ; 280F
	ld de,L672D                            ; 2811
	jp put16x24                            ; 2814
L2817:	ld de,L678D                      ; 2817
	jp put16x24                            ; 281A
L281D:	ld bc,0140h                      ; 281D
	add hl,bc                              ; 2820
	ld a,(L347B)                           ; 2821
	and a                                  ; 2824
	jr z,L282D                             ; 2825
	ld de,L662D                            ; 2827
	jp put16x24                            ; 282A
L282D:	ld de,L668D                      ; 282D
	jp put16x24                            ; 2830
L2833:	dec hl                           ; 2833
	ld de,L68CD                            ; 2834
	jp put24x16                            ; 2837
L283A:	inc hl                           ; 283A
	ld de,L682D                            ; 283B
	jp put24x16                            ; 283E
L2841:	ld a,(L347C)                     ; 2841
	inc a                                  ; 2844
	ld (L347C),a                           ; 2845
	ld (L3476),a                           ; 2848
	cp 0Ah                                 ; 284B
	ret c                                  ; 284D
	xor a                                  ; 284E
	ld (L347C),a                           ; 284F
	ld (L3476),a                           ; 2852
	ld hl,(L3477)                          ; 2855
	inc h                                  ; 2858
	call vaddr                             ; 2859
	call clr16x8                           ; 285C
	ld hl,0000h                            ; 285F
	ld (L3477),hl                          ; 2862
	ret                                    ; 2865
L2866:	call L2A90                       ; 2866
	ld a,(L347C)                           ; 2869
	and a                                  ; 286C
	jp nz,L2841                            ; 286D
	ld hl,(L3479)                          ; 2870
	ld a,(hl)                              ; 2873
	cp 05h                                 ; 2874
	ret nc                                 ; 2876
	inc hl                                 ; 2877
	ld (L3479),hl                          ; 2878
	and a                                  ; 287B
	ret z                                  ; 287C
	ld hl,(L3477)                          ; 287D
	call vaddr                             ; 2880
	dec a                                  ; 2883
	jr z,L288E                             ; 2884
	dec a                                  ; 2886
	jr z,L28A6                             ; 2887
	dec a                                  ; 2889
	jr z,L28BA                             ; 288A
	jr L28CD                               ; 288C
L288E:	ld bc,0140h                      ; 288E
	add hl,bc                              ; 2891
	call clr16x8                           ; 2892
	ld bc,0FD80h                           ; 2895
	add hl,bc                              ; 2898
	ld de,L66ED                            ; 2899
	ld a,(L3478)                           ; 289C
	dec a                                  ; 289F
	ld (L3478),a                           ; 28A0
	jp put16x16                            ; 28A3
L28A6:	call clr16x8                     ; 28A6
	ld bc,0140h                            ; 28A9
	add hl,bc                              ; 28AC
	ld de,L65ED                            ; 28AD
	ld a,(L3478)                           ; 28B0
	inc a                                  ; 28B3
	ld (L3478),a                           ; 28B4
	jp put16x16                            ; 28B7
L28BA:	inc hl                           ; 28BA
	call clr8x16                           ; 28BB
	dec hl                                 ; 28BE
	dec hl                                 ; 28BF
	ld de,L688D                            ; 28C0
	ld a,(L3477)                           ; 28C3
	dec a                                  ; 28C6
	ld (L3477),a                           ; 28C7
	jp put16x16                            ; 28CA
L28CD:	call clr8x16                     ; 28CD
	inc hl                                 ; 28D0
	ld de,L67ED                            ; 28D1
	ld a,(L3477)                           ; 28D4
	inc a                                  ; 28D7
	ld (L3477),a                           ; 28D8
	jp put16x16                            ; 28DB
L28DE:	ld hl,L3477                      ; 28DE
	ld de,L3668                            ; 28E1
	ld bc,0006h                            ; 28E4
	ldir                                   ; 28E7
	ld hl,L347D                            ; 28E9
	ld de,L3477                            ; 28EC
	ld bc,0006h                            ; 28EF
	ldir                                   ; 28F2
	ld hl,L3668                            ; 28F4
	ld de,L347D                            ; 28F7
	ld bc,0006h                            ; 28FA
	ldir                                   ; 28FD
	ret                                    ; 28FF
L2900:	ld hl,(L346D)                    ; 2900
	ld a,(hl)                              ; 2903
	cp 06h                                 ; 2904
	ret nc                                 ; 2906
	and a                                  ; 2907
	ret z                                  ; 2908
	ld hl,(L346B)                          ; 2909
	call vaddr                             ; 290C
	cp 05h                                 ; 290F
	jp z,L2982                             ; 2911
	ld (L346F),a                           ; 2914
	ld a,(L3470)                           ; 2917
	cpl                                    ; 291A
	ld (L3470),a                           ; 291B
	ld a,(L346F)                           ; 291E
	dec a                                  ; 2921
	jr z,L292C                             ; 2922
	dec a                                  ; 2924
	jr z,L293E                             ; 2925
	dec a                                  ; 2927
	jr z,L295E                             ; 2928
	jr L2971                               ; 292A
L292C:	ld a,(L3470)                     ; 292C
	and a                                  ; 292F
	jr z,L2938                             ; 2930
	ld de,L5F5D                            ; 2932
	jp put16x16                            ; 2935
L2938:	ld de,L5F9D                      ; 2938
	jp put16x16                            ; 293B
L293E:	call clr16x8                     ; 293E
	ld bc,0140h                            ; 2941
	add hl,bc                              ; 2944
	ld a,(L346C)                           ; 2945
	inc a                                  ; 2948
	ld (L346C),a                           ; 2949
	ld a,(L3470)                           ; 294C
	and a                                  ; 294F
	jr z,L2958                             ; 2950
	ld de,L5E1D                            ; 2952
	jp put16x16                            ; 2955
L2958:	ld de,L5E5D                      ; 2958
	jp put16x16                            ; 295B
L295E:	inc hl                           ; 295E
	call clr8x16                           ; 295F
	dec hl                                 ; 2962
	dec hl                                 ; 2963
	ld a,(L346B)                           ; 2964
	dec a                                  ; 2967
	ld (L346B),a                           ; 2968
	ld de,L609D                            ; 296B
	jp put16x16                            ; 296E
L2971:	call clr8x16                     ; 2971
	inc hl                                 ; 2974
	ld a,(L346B)                           ; 2975
	inc a                                  ; 2978
	ld (L346B),a                           ; 2979
	ld de,L619D                            ; 297C
	jp put16x16                            ; 297F
L2982:	ld a,(L346F)                     ; 2982
	dec a                                  ; 2985
	jr z,L2990                             ; 2986
	dec a                                  ; 2988
	jr z,L2996                             ; 2989
	dec a                                  ; 298B
	jr z,L299C                             ; 298C
	jr L29A2                               ; 298E
L2990:	ld de,L5FDD                      ; 2990
	jp put16x16                            ; 2993
L2996:	ld de,L5E9D                      ; 2996
	jp put16x16                            ; 2999
L299C:	ld de,L60DD                      ; 299C
	jp put16x16                            ; 299F
L29A2:	ld de,L61DD                      ; 29A2
	jp put16x16                            ; 29A5
L29A8:	ld hl,(L346D)                    ; 29A8
	ld a,(hl)                              ; 29AB
	and 7Fh                                ; 29AC
	cp 06h                                 ; 29AE
	ret nc                                 ; 29B0
	inc hl                                 ; 29B1
	ld (L346D),hl                          ; 29B2
	and a                                  ; 29B5
	ret z                                  ; 29B6
	ld hl,(L346B)                          ; 29B7
	call vaddr                             ; 29BA
	cp 05h                                 ; 29BD
	jr z,L29F6                             ; 29BF
	dec a                                  ; 29C1
	jr z,L29CC                             ; 29C2
	dec a                                  ; 29C4
	jr z,L29E4                             ; 29C5
	dec a                                  ; 29C7
	jr z,L29EA                             ; 29C8
	jr L29F0                               ; 29CA
L29CC:	ld bc,0140h                      ; 29CC
	add hl,bc                              ; 29CF
	call clr16x8                           ; 29D0
	ld bc,0FD80h                           ; 29D3
	add hl,bc                              ; 29D6
	ld de,L5F1D                            ; 29D7
	ld a,(L346C)                           ; 29DA
	dec a                                  ; 29DD
	ld (L346C),a                           ; 29DE
	jp put16x16                            ; 29E1
L29E4:	ld de,L5DDD                      ; 29E4
	jp put16x16                            ; 29E7
L29EA:	ld de,L605D                      ; 29EA
	jp put16x16                            ; 29ED
L29F0:	ld de,L615D                      ; 29F0
	jp put16x16                            ; 29F3
L29F6:	ld a,(L346F)                     ; 29F6
	dec a                                  ; 29F9
	jr z,L2A04                             ; 29FA
	dec a                                  ; 29FC
	jr z,L2A0A                             ; 29FD
	dec a                                  ; 29FF
	jr z,L2A10                             ; 2A00
	jr L2A16                               ; 2A02
L2A04:	ld de,L601D                      ; 2A04
	jp put16x16                            ; 2A07
L2A0A:	ld de,L5EDD                      ; 2A0A
	jp put16x16                            ; 2A0D
L2A10:	ld de,L611D                      ; 2A10
	jp put16x16                            ; 2A13
L2A16:	ld de,L621D                      ; 2A16
	jp put16x16                            ; 2A19
L2A1C:	ld hl,(L3473)                    ; 2A1C
	ld a,(hl)                              ; 2A1F
	cp 05h                                 ; 2A20
	ret nc                                 ; 2A22
	and a                                  ; 2A23
	ret z                                  ; 2A24
	ld hl,(L3471)                          ; 2A25
	call vaddr                             ; 2A28
	dec a                                  ; 2A2B
	ret z                                  ; 2A2C
	dec a                                  ; 2A2D
	jr z,L2A35                             ; 2A2E
	dec a                                  ; 2A30
	jr z,L2A6C                             ; 2A31
	jr L2A7F                               ; 2A33
L2A35:	ld a,(L3476)                     ; 2A35
	and a                                  ; 2A38
	ret nz                                 ; 2A39
fall_test:	ld hl,(L3471)                ; 2A3A
	call vaddr                             ; 2A3D
	ld bc,0280h                            ; 2A40
	add hl,bc                              ; 2A43
	; SAPI: MZ: RF = 02h (plane II) and reads the two VRAM bytes at HL.
	call plane2_test
	ret nz
	defs 9
	ld a,(L3472)                           ; 2A51
	inc a                                  ; 2A54
	ld (L3472),a                           ; 2A55
	cp 17h                                 ; 2A58
	ret nc                                 ; 2A5A
	ld bc,0FD80h                           ; 2A5B
	add hl,bc                              ; 2A5E
	call clr16x8                           ; 2A5F
	ld bc,0140h                            ; 2A62
	add hl,bc                              ; 2A65
	ld de,L5D9D                            ; 2A66
	jp put16x16                            ; 2A69
L2A6C:	inc hl                           ; 2A6C
	call clr8x16                           ; 2A6D
	dec hl                                 ; 2A70
	dec hl                                 ; 2A71
	ld a,(L3471)                           ; 2A72
	dec a                                  ; 2A75
	ld (L3471),a                           ; 2A76
	ld de,L5D9D                            ; 2A79
	jp put16x16                            ; 2A7C
L2A7F:	call clr8x16                     ; 2A7F
	inc hl                                 ; 2A82
	ld a,(L3471)                           ; 2A83
	inc a                                  ; 2A86
	ld (L3471),a                           ; 2A87
	ld de,L5D9D                            ; 2A8A
	jp put16x16                            ; 2A8D
L2A90:	ld a,(L347C)                     ; 2A90
	and a                                  ; 2A93
	ret nz                                 ; 2A94
	ld bc,(L3471)                          ; 2A95
	inc b                                  ; 2A99
	inc b                                  ; 2A9A
	ld hl,(L3477)                          ; 2A9B
	and a                                  ; 2A9E
	sbc hl,bc                              ; 2A9F
	ret nz                                 ; 2AA1
	ld a,01h                               ; 2AA2
	ld (L347C),a                           ; 2AA4
	ld (L3476),a                           ; 2AA7
	ld hl,(L3477)                          ; 2AAA
	call vaddr                             ; 2AAD
	call clr16x8                           ; 2AB0
	ld bc,0140h                            ; 2AB3
	add hl,bc                              ; 2AB6
	ld de,L6AAD                            ; 2AB7
	call put16x8                           ; 2ABA
	jp fall_test                           ; 2ABD
L2AC0:	ld a,(L3488)                     ; 2AC0
	and a                                  ; 2AC3
	ret nz                                 ; 2AC4
	ld bc,(L3471)                          ; 2AC5
	inc b                                  ; 2AC9
	inc b                                  ; 2ACA
	ld hl,(L3483)                          ; 2ACB
	and a                                  ; 2ACE
	sbc hl,bc                              ; 2ACF
	ret nz                                 ; 2AD1
	ld a,01h                               ; 2AD2
	ld (L3488),a                           ; 2AD4
	ld (L3476),a                           ; 2AD7
	ld hl,(L3483)                          ; 2ADA
	call vaddr                             ; 2ADD
	call clr16x8                           ; 2AE0
	ld bc,0140h                            ; 2AE3
	add hl,bc                              ; 2AE6
	ld de,L65CD                            ; 2AE7
	call put16x8                           ; 2AEA
	jp fall_test                           ; 2AED
L2AF0:	ld hl,(L3473)                    ; 2AF0
	ld a,(hl)                              ; 2AF3
	cp 05h                                 ; 2AF4
	ret nc                                 ; 2AF6
	inc hl                                 ; 2AF7
	ld (L3473),hl                          ; 2AF8
	and a                                  ; 2AFB
	ret z                                  ; 2AFC
	cp 02h                                 ; 2AFD
	jp z,L2A35                             ; 2AFF
	ret                                    ; 2B02
L2B03:	call L2AC0                       ; 2B03
	ld a,(L3488)                           ; 2B06
	and a                                  ; 2B09
	jp nz,L2BAD                            ; 2B0A
	ld hl,(L3485)                          ; 2B0D
	ld a,(hl)                              ; 2B10
	cp 08h                                 ; 2B11
	ret nc                                 ; 2B13
	ld a,(L3487)                           ; 2B14
	and a                                  ; 2B17
	jr nz,L2B6F                            ; 2B18
	ld a,(hl)                              ; 2B1A
	cp 03h                                 ; 2B1B
	ret c                                  ; 2B1D
	ld hl,(L3483)                          ; 2B1E
	call vaddr                             ; 2B21
	jr z,L2B34                             ; 2B24
	cp 04h                                 ; 2B26
	jr z,L2B47                             ; 2B28
	cp 05h                                 ; 2B2A
	jr z,L2B58                             ; 2B2C
	cp 06h                                 ; 2B2E
	jr z,L2B63                             ; 2B30
	jr L2B69                               ; 2B32
L2B34:	inc hl                           ; 2B34
	call clr8x16                           ; 2B35
	dec hl                                 ; 2B38
	dec hl                                 ; 2B39
	ld a,(L3483)                           ; 2B3A
	dec a                                  ; 2B3D
	ld (L3483),a                           ; 2B3E
	ld de,L638D                            ; 2B41
	jp put16x16                            ; 2B44
L2B47:	call clr8x16                     ; 2B47
	inc hl                                 ; 2B4A
	ld a,(L3483)                           ; 2B4B
	inc a                                  ; 2B4E
	ld (L3483),a                           ; 2B4F
	ld de,L640D                            ; 2B52
	jp put16x16                            ; 2B55
L2B58:	ld a,01h                         ; 2B58
	ld (L3487),a                           ; 2B5A
	ld de,L644D                            ; 2B5D
	jp put16x16                            ; 2B60
L2B63:	ld de,L654D                      ; 2B63
	jp put16x16                            ; 2B66
L2B69:	ld de,L658D                      ; 2B69
	jp put16x16                            ; 2B6C
L2B6F:	ld a,(L3487)                     ; 2B6F
	inc a                                  ; 2B72
	ld (L3487),a                           ; 2B73
	ld hl,(L3483)                          ; 2B76
	call vaddr                             ; 2B79
	cp 02h                                 ; 2B7C
	jr z,L2B91                             ; 2B7E
	cp 03h                                 ; 2B80
	jr z,L2B97                             ; 2B82
	cp 04h                                 ; 2B84
	jr z,L2B9D                             ; 2B86
	cp 05h                                 ; 2B88
	jr z,L2BA3                             ; 2B8A
	xor a                                  ; 2B8C
	ld (L3487),a                           ; 2B8D
	ret                                    ; 2B90
L2B91:	ld de,L648D                      ; 2B91
	jp put16x16                            ; 2B94
L2B97:	ld de,L64CD                      ; 2B97
	jp put16x16                            ; 2B9A
L2B9D:	ld de,L650D                      ; 2B9D
	jp put16x16                            ; 2BA0
L2BA3:	xor a                            ; 2BA3
	ld (L3487),a                           ; 2BA4
	ld de,L634D                            ; 2BA7
	jp put16x16                            ; 2BAA
L2BAD:	ld a,(L3488)                     ; 2BAD
	inc a                                  ; 2BB0
	ld (L3488),a                           ; 2BB1
	ld (L3476),a                           ; 2BB4
	cp 0Ah                                 ; 2BB7
	ret c                                  ; 2BB9
	xor a                                  ; 2BBA
	ld (L3488),a                           ; 2BBB
	ld (L3476),a                           ; 2BBE
	ld hl,(L3483)                          ; 2BC1
	inc h                                  ; 2BC4
	call vaddr                             ; 2BC5
	call clr16x8                           ; 2BC8
	ld hl,0000h                            ; 2BCB
	ld (L3483),hl                          ; 2BCE
	ret                                    ; 2BD1
L2BD2:	call L2AC0                       ; 2BD2
	ld a,(L3488)                           ; 2BD5
	and a                                  ; 2BD8
	jr nz,L2BAD                            ; 2BD9
	ld hl,(L3485)                          ; 2BDB
	ld a,(hl)                              ; 2BDE
	cp 08h                                 ; 2BDF
	ret nc                                 ; 2BE1
	inc hl                                 ; 2BE2
	ld (L3485),hl                          ; 2BE3
	ld a,(L3487)                           ; 2BE6
	and a                                  ; 2BE9
	jr nz,L2B6F                            ; 2BEA
	ld a,(hl)                              ; 2BEC
	cp 03h                                 ; 2BED
	ret c                                  ; 2BEF
	ld hl,(L3483)                          ; 2BF0
	call vaddr                             ; 2BF3
	jr z,L2BFD                             ; 2BF6
	cp 04h                                 ; 2BF8
	jr z,L2C03                             ; 2BFA
	ret                                    ; 2BFC
L2BFD:	ld de,L634D                      ; 2BFD
	jp put16x16                            ; 2C00
L2C03:	ld de,L63CD                      ; 2C03
	jp put16x16                            ; 2C06
L2C09:	ld hl,L3483                      ; 2C09
	ld de,L3668                            ; 2C0C
	ld bc,0006h                            ; 2C0F
	ldir                                   ; 2C12
	ld hl,L3489                            ; 2C14
	ld de,L3483                            ; 2C17
	ld bc,0006h                            ; 2C1A
	ldir                                   ; 2C1D
	ld hl,L3668                            ; 2C1F
	ld de,L3489                            ; 2C22
	ld bc,0006h                            ; 2C25
	ldir                                   ; 2C28
	ret                                    ; 2C2A
L2C2B:	ld hl,(L3491)                    ; 2C2B
	ld a,(hl)                              ; 2C2E
	cp 07h                                 ; 2C2F
	ret nc                                 ; 2C31
	inc hl                                 ; 2C32
	ld (L3491),hl                          ; 2C33
	and a                                  ; 2C36
	ret z                                  ; 2C37
	cp 05h                                 ; 2C38
	jr z,L2C9B                             ; 2C3A
	ld hl,(L348F)                          ; 2C3C
	call vaddr                             ; 2C3F
	dec a                                  ; 2C42
	jr z,L2C51                             ; 2C43
	dec a                                  ; 2C45
	jr z,L2C65                             ; 2C46
	dec a                                  ; 2C48
	jr z,L2C79                             ; 2C49
	dec a                                  ; 2C4B
	jr z,L2C8A                             ; 2C4C
	jp clr8                                ; 2C4E
L2C51:	call clr8                        ; 2C51
	ld bc,0FEC0h                           ; 2C54
	add hl,bc                              ; 2C57
	ld a,(L3490)                           ; 2C58
	dec a                                  ; 2C5B
	ld (L3490),a                           ; 2C5C
	ld de,L6ACD                            ; 2C5F
	jp put8x8                              ; 2C62
L2C65:	call clr8                        ; 2C65
	ld bc,0140h                            ; 2C68
	add hl,bc                              ; 2C6B
	ld a,(L3490)                           ; 2C6C
	inc a                                  ; 2C6F
	ld (L3490),a                           ; 2C70
	ld de,L6ACD                            ; 2C73
	jp put8x8                              ; 2C76
L2C79:	call clr8                        ; 2C79
	dec hl                                 ; 2C7C
	ld a,(L348F)                           ; 2C7D
	dec a                                  ; 2C80
	ld (L348F),a                           ; 2C81
	ld de,L6ACD                            ; 2C84
	jp put8x8                              ; 2C87
L2C8A:	call clr8                        ; 2C8A
	inc hl                                 ; 2C8D
	ld a,(L348F)                           ; 2C8E
	inc a                                  ; 2C91
	ld (L348F),a                           ; 2C92
	ld de,L6ACD                            ; 2C95
	jp put8x8                              ; 2C98
L2C9B:	ld a,(L346F)                     ; 2C9B
	ld hl,(L346B)                          ; 2C9E
	dec a                                  ; 2CA1
	jr z,L2CAE                             ; 2CA2
	dec a                                  ; 2CA4
	jr z,L2CBC                             ; 2CA5
	dec a                                  ; 2CA7
	jr z,L2CC1                             ; 2CA8
	dec a                                  ; 2CAA
	jr z,L2CC5                             ; 2CAB
	ret                                    ; 2CAD
L2CAE:	inc l                            ; 2CAE
	dec h                                  ; 2CAF
L2CB0:	ld (L348F),hl                    ; 2CB0
	call vaddr                             ; 2CB3
	ld de,L6ACD                            ; 2CB6
	jp put8x8                              ; 2CB9
L2CBC:	inc h                            ; 2CBC
	inc h                                  ; 2CBD
	jp L2CB0                               ; 2CBE
L2CC1:	dec l                            ; 2CC1
	jp L2CB0                               ; 2CC2
L2CC5:	inc l                            ; 2CC5
	inc l                                  ; 2CC6
	jp L2CB0                               ; 2CC7
L2CCA:	ld hl,(L3493)                    ; 2CCA
	ld a,(hl)                              ; 2CCD
	cp 0Bh                                 ; 2CCE
	ret nc                                 ; 2CD0
	inc hl                                 ; 2CD1
	ld (L3493),hl                          ; 2CD2
	and a                                  ; 2CD5
	ret z                                  ; 2CD6
	cp 09h                                 ; 2CD7
	jr z,L2CF8                             ; 2CD9
	ret nc                                 ; 2CDB
	dec a                                  ; 2CDC
	ld hl,(L3495)                          ; 2CDD
	ld d,00h                               ; 2CE0
	ld e,a                                 ; 2CE2
	add hl,de                              ; 2CE3
	call vaddr                             ; 2CE4
	push hl                                ; 2CE7
	ld h,00h                               ; 2CE8
	ld l,a                                 ; 2CEA
	add hl,hl                              ; 2CEB
	add hl,hl                              ; 2CEC
	add hl,hl                              ; 2CED
	add hl,hl                              ; 2CEE
	ld de,L6EA1                            ; 2CEF
	add hl,de                              ; 2CF2
	ex de,hl                               ; 2CF3
	pop hl                                 ; 2CF4
	jp put8x8                              ; 2CF5
L2CF8:	ld hl,(L3495)                    ; 2CF8
	call vaddr                             ; 2CFB
	jp clr8                                ; 2CFE
L2D01:	ld hl,(L3493)                    ; 2D01
	ld a,(hl)                              ; 2D04
	cp 0Ah                                 ; 2D05
	ret nz                                 ; 2D07
	ld hl,(L3495)                          ; 2D08
	call vaddr                             ; 2D0B
	ld de,L6EA1                            ; 2D0E
	jp put8x8                              ; 2D11
L2D14:	ld hl,(L3497)                    ; 2D14
	ld a,(hl)                              ; 2D17
	cp 09h                                 ; 2D18
	ret nc                                 ; 2D1A
	inc hl                                 ; 2D1B
	ld (L3497),hl                          ; 2D1C
	and a                                  ; 2D1F
	ret z                                  ; 2D20
	dec a                                  ; 2D21
	ld hl,(L3499)                          ; 2D22
	ld d,00h                               ; 2D25
	ld e,a                                 ; 2D27
	add hl,de                              ; 2D28
	call vaddr                             ; 2D29
	push hl                                ; 2D2C
	ld h,00h                               ; 2D2D
	ld l,a                                 ; 2D2F
	add hl,hl                              ; 2D30
	add hl,hl                              ; 2D31
	add hl,hl                              ; 2D32
	add hl,hl                              ; 2D33
	ld de,L6F21                            ; 2D34
	add hl,de                              ; 2D37
	ex de,hl                               ; 2D38
	pop hl                                 ; 2D39
	jp put8x8                              ; 2D3A
L2D3D:	ld hl,(L349B)                    ; 2D3D
	ld a,(hl)                              ; 2D40
	cp 05h                                 ; 2D41
	ret nc                                 ; 2D43
	inc hl                                 ; 2D44
	ld (L349B),hl                          ; 2D45
	dec a                                  ; 2D48
	jr z,L2D55                             ; 2D49
	dec a                                  ; 2D4B
	jr z,L2D66                             ; 2D4C
	dec a                                  ; 2D4E
	jr z,L2D83                             ; 2D4F
	dec a                                  ; 2D51
	jr z,L2DA0                             ; 2D52
	ret                                    ; 2D54
L2D55:	ld hl,0F15h                      ; 2D55
	call vaddr                             ; 2D58
	ld de,L3457                            ; 2D5B
	ld a,03h                               ; 2D5E
	ld (text_colour),a                     ; 2D60
	jp print                               ; 2D63
L2D66:	ld hl,0F15h                      ; 2D66
	call vaddr                             ; 2D69
	ld de,L3466                            ; 2D6C
	call print                             ; 2D6F
	ld hl,1215h                            ; 2D72
	call vaddr                             ; 2D75
	ld de,L345C                            ; 2D78
	ld a,03h                               ; 2D7B
	ld (text_colour),a                     ; 2D7D
	jp print                               ; 2D80
L2D83:	ld hl,1215h                      ; 2D83
	call vaddr                             ; 2D86
	ld de,L3466                            ; 2D89
	call print                             ; 2D8C
	ld hl,1515h                            ; 2D8F
	call vaddr                             ; 2D92
	ld de,L3461                            ; 2D95
	ld a,03h                               ; 2D98
	ld (text_colour),a                     ; 2D9A
	jp print                               ; 2D9D
L2DA0:	ld hl,1515h                      ; 2DA0
	call vaddr                             ; 2DA3
	ld de,L3466                            ; 2DA6
	jp print                               ; 2DA9
L2DAC:	ld hl,(L346B)                    ; 2DAC
	call vaddr                             ; 2DAF
	ld de,L5DDD                            ; 2DB2
	call put16x16                          ; 2DB5
	call wait_ticks2                       ; 2DB8
	ld b,03h                               ; 2DBB
L2DBD:	ld de,L625D                      ; 2DBD
	push bc                                ; 2DC0
	call put16x16                          ; 2DC1
	call wait_ticks2                       ; 2DC4
	call wait_ticks2                       ; 2DC7
	ld de,L629D                            ; 2DCA
	call put16x16                          ; 2DCD
	call poll_keys                         ; 2DD0
	ld de,L5DDD                            ; 2DD3
	call put16x16                          ; 2DD6
	call wait_ticks2                       ; 2DD9
	call wait_ticks2                       ; 2DDC
	pop bc                                 ; 2DDF
	djnz L2DBD                             ; 2DE0
	ret                                    ; 2DE2
L2DE3:	ld de,L3326                      ; 2DE3
	jr L2DEB                               ; 2DE6
L2DE8:	ld de,L3380                      ; 2DE8
L2DEB:	ld hl,0800h                      ; 2DEB
	call vaddr                             ; 2DEE
	ld b,09h                               ; 2DF1
L2DF3:	push hl                          ; 2DF3
	call scroll_logo                       ; 2DF4
	call logo_row                          ; 2DF7
	pop hl                                 ; 2DFA
	djnz L2DF3                             ; 2DFB
	ret                                    ; 2DFD
	; SAPI: the MZ routine below draws into the VRAM: replaced by scroll_logo_s.
scroll_logo:	jp scroll_logo_s
	ld hl,8140h                            ; 2E01
	ld de,8000h                            ; 2E04
	ld c,08h                               ; 2E07
L2E09:	ld b,08h                         ; 2E09
L2E0B:	push bc                          ; 2E0B
	push de                                ; 2E0C
	push hl                                ; 2E0D
	ld a,01h                               ; 2E0E
	ld (L2E3C),a                           ; 2E10
	or 80h                                 ; 2E13
	ld (L2E41),a                           ; 2E15
	ld b,28h                               ; 2E18
	call copy_row                          ; 2E1A
	pop hl                                 ; 2E1D
	pop de                                 ; 2E1E
	ld a,02h                               ; 2E1F
	ld (L2E3C),a                           ; 2E21
	or 20h                                 ; 2E24
	ld (L2E41),a                           ; 2E26
	ld b,28h                               ; 2E29
	call copy_row                          ; 2E2B
	pop bc                                 ; 2E2E
	djnz L2E0B                             ; 2E2F
	call poll_keys                         ; 2E31
	dec c                                  ; 2E34
	jr nz,L2E09                            ; 2E35
	pop bc                                 ; 2E37
	pop de                                 ; 2E38
	pop hl                                 ; 2E39
	ret                                    ; 2E3A
copy_row:	ld a,02h                      ; 2E3B
L2E3C            equ copy_row+1
	out (0CDh),a                           ; 2E3D
	ld c,(hl)                              ; 2E3F
	ld a,82h                               ; 2E40
L2E41            equ $-1
	out (0CCh),a                           ; 2E42
	ld a,c                                 ; 2E44
	ld (de),a                              ; 2E45
	inc de                                 ; 2E46
	inc hl                                 ; 2E47
	djnz copy_row                          ; 2E48
	ret                                    ; 2E4A
logo_row:	push bc                       ; 2E4B
	call poll_keys                         ; 2E4C
	ld a,0Ah                               ; 2E4F
L2E51:	push af                          ; 2E51
	ld a,(de)                              ; 2E52
	inc de                                 ; 2E53
	ld c,a                                 ; 2E54
	ld b,04h                               ; 2E55
L2E57:	rlc c                            ; 2E57
	rlc c                                  ; 2E59
	ld a,c                                 ; 2E5B
	and 03h                                ; 2E5C
	dec a                                  ; 2E5E
	jp z,L2E70                             ; 2E5F
	dec a                                  ; 2E62
	jp z,L2E7B                             ; 2E63
	dec a                                  ; 2E66
	jp z,L2E83                             ; 2E67
	call clr8                              ; 2E6A
	jp L2E83                               ; 2E6D
L2E70:	push de                          ; 2E70
	ld de,L5C5D                            ; 2E71
	call put8x8                            ; 2E74
	pop de                                 ; 2E77
	jp L2E83                               ; 2E78
L2E7B:	push de                          ; 2E7B
	ld de,L5C8D                            ; 2E7C
	call put8x8                            ; 2E7F
	pop de                                 ; 2E82
L2E83:	inc hl                           ; 2E83
	djnz L2E57                             ; 2E84
	pop af                                 ; 2E86
	dec a                                  ; 2E87
	jr nz,L2E51                            ; 2E88
	ld bc,0118h                            ; 2E8A
	add hl,bc                              ; 2E8D
	pop bc                                 ; 2E8E
	ret                                    ; 2E8F
put_obj:	ld c,(hl)                      ; 2E90
	inc hl                                 ; 2E91
	ld b,(hl)                              ; 2E92
	inc hl                                 ; 2E93
	push hl                                ; 2E94
	ld h,b                                 ; 2E95
	ld l,c                                 ; 2E96
	call vaddr                             ; 2E97
	call put16x16                          ; 2E9A
	pop hl                                 ; 2E9D
	ret                                    ; 2E9E
	; SAPI: the MZ routine below draws into the VRAM: replaced by cls_s.
cls:	jp cls_s
	ld (L2EC8),sp                          ; 2EA2
	di                                     ; 2EA6
	ld bc,81CCh                            ; 2EA7
	out (c),b                              ; 2EAA
	in a,(0E0h)                            ; 2EAC
	ld hl,0000h                            ; 2EAE
	ld sp,9F40h                            ; 2EB1
	ld c,02h                               ; 2EB4
L2EB6:	ld b,0C8h                        ; 2EB6
L2EB8:	push hl                          ; 2EB8
	push hl                                ; 2EB9
	push hl                                ; 2EBA
	push hl                                ; 2EBB
	push hl                                ; 2EBC
	push hl                                ; 2EBD
	push hl                                ; 2EBE
	push hl                                ; 2EBF
	push hl                                ; 2EC0
	push hl                                ; 2EC1
	djnz L2EB8                             ; 2EC2
	dec c                                  ; 2EC4
	jr nz,L2EB6                            ; 2EC5
	ld sp,0000h                            ; 2EC7
L2EC8            equ $-2
	ei                                     ; 2ECA
	pop af                                 ; 2ECB
	pop bc                                 ; 2ECC
	pop hl                                 ; 2ECD
	ret                                    ; 2ECE
	; SAPI: the MZ routine below draws into the VRAM: replaced by cls_lower_s.
cls_lower:	jp cls_lower_s
	ld (L2EF3),sp                          ; 2ED2
	ld bc,81CCh                            ; 2ED6
	out (c),b                              ; 2ED9
	in a,(0E0h)                            ; 2EDB
	di                                     ; 2EDD
	ld hl,0000h                            ; 2EDE
	ld sp,9F40h                            ; 2EE1
	ld b,00h                               ; 2EE4
L2EE6:	push hl                          ; 2EE6
	push hl                                ; 2EE7
	push hl                                ; 2EE8
	push hl                                ; 2EE9
	push hl                                ; 2EEA
	push hl                                ; 2EEB
	push hl                                ; 2EEC
	push hl                                ; 2EED
	push hl                                ; 2EEE
	push hl                                ; 2EEF
	djnz L2EE6                             ; 2EF0
	ld sp,0000h                            ; 2EF2
L2EF3            equ $-2
	ei                                     ; 2EF5
	pop af                                 ; 2EF6
	pop bc                                 ; 2EF7
	pop hl                                 ; 2EF8
	ret                                    ; 2EF9
	; SAPI: the MZ routine below writes into the VRAM: replaced by box_top_s.
box_top:	jp box_top_s
	inc de                                 ; 2EFD
	ld a,0FFh                              ; 2EFE
L2F00:	ld (de),a                        ; 2F00
	inc de                                 ; 2F01
	djnz L2F00                             ; 2F02
	ld a,1Fh                               ; 2F04
	ld (de),a                              ; 2F06
	ret                                    ; 2F07
	; SAPI: the MZ routine below writes into the VRAM: replaced by box_right_s.
box_right:	jp box_right_s
L2F0A            equ box_right+2
	call row_down                          ; 2F0B
	djnz L2F0A                             ; 2F0E
	jp row_up                              ; 2F10
	; SAPI: the MZ routine below writes into the VRAM: replaced by box_bottom_s.
box_bottom:	jp box_bottom_s
	ld a,0FFh                              ; 2F16
L2F18:	dec de                           ; 2F18
	ld (de),a                              ; 2F19
	djnz L2F18                             ; 2F1A
	dec de                                 ; 2F1C
	ld a,0F8h                              ; 2F1D
	ld (de),a                              ; 2F1F
	ret                                    ; 2F20
	; SAPI: the MZ routine below writes into the VRAM: replaced by box_left_s.
box_left:	jp box_left_s
L2F23            equ box_left+2
	call row_up                            ; 2F24
	djnz L2F23                             ; 2F27
	jp row_down                            ; 2F29
row_down:	push de                       ; 2F2C
	ld de,0028h                            ; 2F2D
	add hl,de                              ; 2F30
	pop de                                 ; 2F31
	push hl                                ; 2F32
	ld hl,0028h                            ; 2F33
	add hl,de                              ; 2F36
	ex de,hl                               ; 2F37
	pop hl                                 ; 2F38
	ret                                    ; 2F39
row_up:	push de                         ; 2F3A
	ld de,0FFD8h                           ; 2F3B
	add hl,de                              ; 2F3E
	pop de                                 ; 2F3F
	push hl                                ; 2F40
	ld hl,0FFD8h                           ; 2F41
	add hl,de                              ; 2F44
	ex de,hl                               ; 2F45
	pop hl                                 ; 2F46
	ret                                    ; 2F47
wait_ticks2:	ld a,(tick_div)            ; 2F48
	push bc                                ; 2F4B
	ld b,a                                 ; 2F4C
L2F4D:	call poll_keys                   ; 2F4D
	ld a,(ticks)                           ; 2F50
	cp b                                   ; 2F53
	jp c,L2F4D                             ; 2F54
L2F57:	call L3821                       ; 2F57
	ld a,(key_held)                        ; 2F5A
	and a                                  ; 2F5D
	jr nz,L2F57                            ; 2F5E
	xor a                                  ; 2F60
	ld (ticks),a                           ; 2F61
	pop bc                                 ; 2F64
	ret                                    ; 2F65
poll_keys:	push hl                      ; 2F66
	push de                                ; 2F67
	push bc                                ; 2F68
	push af                                ; 2F69
	call read_dir                          ; 2F6A
	and 80h                                ; 2F6D
	jr nz,L2F93                            ; 2F6F
	ld a,01h                               ; 2F71
	call read_joy                          ; 2F73
	and 10h                                ; 2F76
	jr nz,L2F96                            ; 2F78
	ld a,02h                               ; 2F7A
	call read_joy                          ; 2F7C
	and 10h                                ; 2F7F
	jr nz,L2F9A                            ; 2F81
	call L3821                             ; 2F83
	ld a,(last_key)                        ; 2F86
	cp 0Dh                                 ; 2F89
	jp z,L2FA6                             ; 2F8B
	pop af                                 ; 2F8E
	pop bc                                 ; 2F8F
	pop de                                 ; 2F90
	pop hl                                 ; 2F91
	ret                                    ; 2F92
L2F93:	xor a                            ; 2F93
	jr L2F9C                               ; 2F94
L2F96:	ld a,01h                         ; 2F96
	jr L2F9C                               ; 2F98
L2F9A:	ld a,02h                         ; 2F9A
L2F9C:	ld (L5C1A),a                     ; 2F9C
	xor a                                  ; 2F9F
	ld (L331D),a                           ; 2FA0
	jp L2364                               ; 2FA3
L2FA6:	call music_off                   ; 2FA6
	call cls                               ; 2FA9
	call L32D9                             ; 2FAC
	call L318F                             ; 2FAF
	call L31A0                             ; 2FB2
	call L31C6                             ; 2FB5
	call L31F5                             ; 2FB8
	call L3216                             ; 2FBB
L2FBE:	call L377D                       ; 2FBE
	xor a                                  ; 2FC1
	ld (speed_req),a                       ; 2FC2
	ld (L3321),a                           ; 2FC5
	ld (last_key),a                        ; 2FC8
	ld a,00h                               ; 2FCB
	call L328D                             ; 2FCD
	ld a,00h                               ; 2FD0
	ld (L331E),a                           ; 2FD2
L2FD5:	push hl                          ; 2FD5
	push bc                                ; 2FD6
	push de                                ; 2FD7
	call L3727                             ; 2FD8
	pop de                                 ; 2FDB
	pop bc                                 ; 2FDC
	pop hl                                 ; 2FDD
	ld a,(L3321)                           ; 2FDE
	ld c,a                                 ; 2FE1
	ld a,(speed_req)                       ; 2FE2
	cp c                                   ; 2FE5
	jr z,L2FF0                             ; 2FE6
	dec a                                  ; 2FE8
	jp z,L307F                             ; 2FE9
	dec a                                  ; 2FEC
	jp z,L30AE                             ; 2FED
L2FF0:	ld a,(speed_req)                 ; 2FF0
	dec a                                  ; 2FF3
	jr z,L3005                             ; 2FF4
	dec a                                  ; 2FF6
	jr z,L300A                             ; 2FF7
	ld a,(L331E)                           ; 2FF9
	cp 03h                                 ; 2FFC
	jr z,L300F                             ; 2FFE
	call L3821                             ; 3000
	jr L3012                               ; 3003
L3005:	call L386C                       ; 3005
	jr L3012                               ; 3008
L300A:	call L3885                       ; 300A
	jr L3012                               ; 300D
L300F:	call L38F1                       ; 300F
L3012:	ld a,(last_key)                  ; 3012
	cp 0Dh                                 ; 3015
	jp z,L30EC                             ; 3017
	call read_dir                          ; 301A
	and 80h                                ; 301D
	jp nz,L2F93                            ; 301F
	ld a,01h                               ; 3022
	call read_joy                          ; 3024
	and 10h                                ; 3027
	jp nz,L2F96                            ; 3029
	ld a,02h                               ; 302C
	call read_joy                          ; 302E
	and 10h                                ; 3031
	jp nz,L2F9A                            ; 3033
	ld a,(L3321)                           ; 3036
	and a                                  ; 3039
	jr z,L3079                             ; 303A
	ld a,(L3322)                           ; 303C
	inc a                                  ; 303F
	ld (L3322),a                           ; 3040
	cp 20h                                 ; 3043
	jr z,L304D                             ; 3045
	cp 40h                                 ; 3047
	jr nc,L3051                            ; 3049
	jr L3079                               ; 304B
L304D:	ld c,03h                         ; 304D
	jr z,L3057                             ; 304F
L3051:	ld c,00h                         ; 3051
	xor a                                  ; 3053
	ld (L3322),a                           ; 3054
L3057:	ld a,(L3321)                     ; 3057
	dec a                                  ; 305A
	jr z,L3062                             ; 305B
	dec a                                  ; 305D
	jr z,L306A                             ; 305E
	jr L3079                               ; 3060
L3062:	ld hl,0708h                      ; 3062
	ld de,L36A5                            ; 3065
	jr L3070                               ; 3068
L306A:	ld hl,0908h                      ; 306A
	ld de,L36A8                            ; 306D
L3070:	ld a,c                           ; 3070
	di                                     ; 3071
	call vaddr                             ; 3072
	call print                             ; 3075
	ei                                     ; 3078
L3079:	call delay_2000                  ; 3079
	jp L2FD5                               ; 307C
L307F:	call L31C6                       ; 307F
	xor a                                  ; 3082
	ld (speed_req),a                       ; 3083
	ld (L3322),a                           ; 3086
	ld a,01h                               ; 3089
	ld (L3321),a                           ; 308B
	ld a,03h                               ; 308E
	call L324B                             ; 3090
	ld a,00h                               ; 3093
	call L325A                             ; 3095
	ld a,00h                               ; 3098
	call L328D                             ; 309A
	ld a,01h                               ; 309D
	ld (L331E),a                           ; 309F
	ld hl,071Eh                            ; 30A2
	ld (L3933),hl                          ; 30A5
	call L3749                             ; 30A8
	jp L2FD5                               ; 30AB
L30AE:	ld a,(L5C18)                     ; 30AE
	ld c,a                                 ; 30B1
	ld a,(L331F)                           ; 30B2
	cp c                                   ; 30B5
	jp nc,L30E5                            ; 30B6
	call L31A0                             ; 30B9
	xor a                                  ; 30BC
	ld (L3322),a                           ; 30BD
	ld a,02h                               ; 30C0
	ld (L3321),a                           ; 30C2
	ld a,01h                               ; 30C5
	call L324B                             ; 30C7
	ld a,03h                               ; 30CA
	call L325A                             ; 30CC
	ld a,00h                               ; 30CF
	call L328D                             ; 30D1
	ld a,02h                               ; 30D4
	ld (L331E),a                           ; 30D6
	ld hl,091Ah                            ; 30D9
	ld (L3933),hl                          ; 30DC
	call L3757                             ; 30DF
	jp L2FD5                               ; 30E2
L30E5:	xor a                            ; 30E5
	ld (speed_req),a                       ; 30E6
	jp L2FD5                               ; 30E9
L30EC:	call L31A0                       ; 30EC
	call L31C6                             ; 30EF
	xor a                                  ; 30F2
	ld (speed_req),a                       ; 30F3
	ld (L3321),a                           ; 30F6
	ld a,(L331E)                           ; 30F9
	and a                                  ; 30FC
	jp z,L233D                             ; 30FD
	dec a                                  ; 3100
	jp z,L2FBE                             ; 3101
	dec a                                  ; 3104
	jp z,L310B                             ; 3105
	jp L233D                               ; 3108
L310B:	ld hl,keywords                   ; 310B
	ld a,01h                               ; 310E
	ld (keyword_idx),a                     ; 3110
L3113:	ld de,keyword_buf                ; 3113
	ld c,01h                               ; 3116
	ld b,05h                               ; 3118
L311A:	ld a,(de)                        ; 311A
	cp (hl)                                ; 311B
	jp z,L3121                             ; 311C
	ld c,00h                               ; 311F
L3121:	inc hl                           ; 3121
	inc de                                 ; 3122
	djnz L311A                             ; 3123
	ld a,c                                 ; 3125
	and a                                  ; 3126
	jr nz,L3160                            ; 3127
	ld a,(stage_count)                     ; 3129
	ld c,a                                 ; 312C
	ld a,(keyword_idx)                     ; 312D
	add a,05h                              ; 3130
	cp c                                   ; 3132
	jr nc,L313B                            ; 3133
	ld (keyword_idx),a                     ; 3135
	jp L3113                               ; 3138
L313B:	ld a,(L5C18)                     ; 313B
	ld c,a                                 ; 313E
	ld a,(L331F)                           ; 313F
	inc a                                  ; 3142
	ld (L331F),a                           ; 3143
	cp c                                   ; 3146
	call nc,L327A                          ; 3147
	ld a,01h                               ; 314A
	ld (keyword_idx),a                     ; 314C
	ld (stage),a                           ; 314F
	ld hl,keyword_buf                      ; 3152
	ld a,20h                               ; 3155
	ld b,05h                               ; 3157
L3159:	ld (hl),a                        ; 3159
	inc hl                                 ; 315A
	djnz L3159                             ; 315B
	jp L2FBE                               ; 315D
L3160:	call L31A0                       ; 3160
	call L31C6                             ; 3163
	ld a,01h                               ; 3166
	ld (L3320),a                           ; 3168
	call L324B                             ; 316B
	ld a,00h                               ; 316E
	call L325A                             ; 3170
	ld a,03h                               ; 3173
	call L328D                             ; 3175
	ld a,03h                               ; 3178
	ld (L331E),a                           ; 317A
	ld a,(keyword_idx)                     ; 317D
	ld (stage),a                           ; 3180
	ld hl,1509h                            ; 3183
	ld (L3933),hl                          ; 3186
	call L3765                             ; 3189
	jp L2FD5                               ; 318C
L318F:	ld hl,0510h                      ; 318F
	ld de,L369D                            ; 3192
	ld a,01h                               ; 3195
	di                                     ; 3197
	call vaddr                             ; 3198
	call print                             ; 319B
	ei                                     ; 319E
	ret                                    ; 319F
L31A0:	ld hl,0708h                      ; 31A0
	ld de,L36A5                            ; 31A3
	ld a,03h                               ; 31A6
	di                                     ; 31A8
	call vaddr                             ; 31A9
	call print                             ; 31AC
	ld de,L36AB                            ; 31AF
	ld a,01h                               ; 31B2
	call print                             ; 31B4
	ld de,L36AD                            ; 31B7
	ld a,02h                               ; 31BA
	call print                             ; 31BC
	ei                                     ; 31BF
	ld a,01h                               ; 31C0
	call L324B                             ; 31C2
	ret                                    ; 31C5
L31C6:	ld a,(L5C18)                     ; 31C6
	ld c,a                                 ; 31C9
	ld a,(L331F)                           ; 31CA
	cp c                                   ; 31CD
	ret nc                                 ; 31CE
	ld hl,0908h                            ; 31CF
	ld de,L36A8                            ; 31D2
	ld a,03h                               ; 31D5
	di                                     ; 31D7
	call vaddr                             ; 31D8
	call print                             ; 31DB
	ld de,L36AB                            ; 31DE
	ld a,01h                               ; 31E1
	call print                             ; 31E3
	ld de,L36C1                            ; 31E6
	ld a,02h                               ; 31E9
	call print                             ; 31EB
	ei                                     ; 31EE
	ld a,00h                               ; 31EF
	call L325A                             ; 31F1
	ret                                    ; 31F4
L31F5:	ld hl,0D07h                      ; 31F5
	ld de,L36D0                            ; 31F8
	ld a,02h                               ; 31FB
	di                                     ; 31FD
	call vaddr                             ; 31FE
	call print                             ; 3201
	ld de,L3695                            ; 3204
	ld a,03h                               ; 3207
	call print                             ; 3209
	ld de,L36D5                            ; 320C
	ld a,02h                               ; 320F
	call print                             ; 3211
	ei                                     ; 3214
	ret                                    ; 3215
L3216:	ld hl,1007h                      ; 3216
	ld de,L36D0                            ; 3219
	ld a,02h                               ; 321C
	di                                     ; 321E
	call vaddr                             ; 321F
	call print                             ; 3222
	push hl                                ; 3225
	ld de,00A0h                            ; 3226
	add hl,de                              ; 3229
	ld de,L3684                            ; 322A
	ld a,03h                               ; 322D
	call print                             ; 322F
	pop hl                                 ; 3232
	ld de,0FF60h                           ; 3233
	add hl,de                              ; 3236
	ld de,L367A                            ; 3237
	call print                             ; 323A
	ld de,00A0h                            ; 323D
	add hl,de                              ; 3240
	ld de,L36E4                            ; 3241
	ld a,02h                               ; 3244
	call print                             ; 3246
	ei                                     ; 3249
	ret                                    ; 324A
L324B:	ld hl,071Eh                      ; 324B
	ld de,speed_digit                      ; 324E
	di                                     ; 3251
	call vaddr                             ; 3252
	call print                             ; 3255
	ei                                     ; 3258
	ret                                    ; 3259
L325A:	push af                          ; 325A
	ld a,(L5C18)                           ; 325B
	ld c,a                                 ; 325E
	ld a,(L331F)                           ; 325F
	cp c                                   ; 3262
	jr nc,L3275                            ; 3263
	pop af                                 ; 3265
	ld hl,091Ah                            ; 3266
	ld de,keyword_buf                      ; 3269
	di                                     ; 326C
	call vaddr                             ; 326D
	call print                             ; 3270
	ei                                     ; 3273
	ret                                    ; 3274
L3275:	call L327A                       ; 3275
	pop af                                 ; 3278
	ret                                    ; 3279
L327A:	ld hl,0901h                      ; 327A
	di                                     ; 327D
	call vaddr                             ; 327E
	push bc                                ; 3281
	ld b,26h                               ; 3282
L3284:	call clr8                        ; 3284
	inc hl                                 ; 3287
	djnz L3284                             ; 3288
	ei                                     ; 328A
	pop bc                                 ; 328B
	ret                                    ; 328C
L328D:	ld hl,1509h                      ; 328D
	di                                     ; 3290
	call vaddr                             ; 3291
	call L32C9                             ; 3294
	push hl                                ; 3297
	push de                                ; 3298
	push bc                                ; 3299
	push af                                ; 329A
	and a                                  ; 329B
	jp z,L32C3                             ; 329C
	ld (text_colour),a                     ; 329F
	xor a                                  ; 32A2
	ld (L3EE9),a                           ; 32A3
	ld a,(keyword_idx)                     ; 32A6
	ld d,00h                               ; 32A9
	ld e,a                                 ; 32AB
	ld b,05h                               ; 32AC
L32AE:	ld a,e                           ; 32AE
	cp 0Ah                                 ; 32AF
	jr c,L32B9                             ; 32B1
	cp 64h                                 ; 32B3
	jr c,L32BA                             ; 32B5
	jr L32BB                               ; 32B7
L32B9:	inc hl                           ; 32B9
L32BA:	inc hl                           ; 32BA
L32BB:	call print_num                   ; 32BB
	inc e                                  ; 32BE
	inc hl                                 ; 32BF
	inc hl                                 ; 32C0
	djnz L32AE                             ; 32C1
L32C3:	ei                               ; 32C3
	pop hl                                 ; 32C4
	pop de                                 ; 32C5
	pop bc                                 ; 32C6
	pop af                                 ; 32C7
	ret                                    ; 32C8
L32C9:	push hl                          ; 32C9
	push bc                                ; 32CA
	push af                                ; 32CB
	ld b,0Dh                               ; 32CC
L32CE:	call clr16x8                     ; 32CE
	inc hl                                 ; 32D1
	inc hl                                 ; 32D2
	djnz L32CE                             ; 32D3
	pop af                                 ; 32D5
	pop bc                                 ; 32D6
	pop hl                                 ; 32D7
	ret                                    ; 32D8
L32D9:	call cls                         ; 32D9
	ld hl,8000h                            ; 32DC
	ld de,L5C3D                            ; 32DF
	ld b,14h                               ; 32E2
L32E4:	call put16x8                     ; 32E4
	inc hl                                 ; 32E7
	inc hl                                 ; 32E8
	djnz L32E4                             ; 32E9
	ld hl,8140h                            ; 32EB
	ld de,L5C5D                            ; 32EE
	ld bc,0140h                            ; 32F1
	ld a,17h                               ; 32F4
L32F6:	push af                          ; 32F6
	call put8x8                            ; 32F7
	add hl,bc                              ; 32FA
	pop af                                 ; 32FB
	dec a                                  ; 32FC
	jr nz,L32F6                            ; 32FD
	ld hl,8167h                            ; 32FF
	ld a,17h                               ; 3302
L3304:	push af                          ; 3304
	call put8x8                            ; 3305
	add hl,bc                              ; 3308
	pop af                                 ; 3309
	dec a                                  ; 330A
	jr nz,L3304                            ; 330B
	ld hl,9E00h                            ; 330D
	ld de,L5C3D                            ; 3310
	ld b,14h                               ; 3313
L3315:	call put16x8                     ; 3315
	inc hl                                 ; 3318
	inc hl                                 ; 3319
	djnz L3315                             ; 331A
	ret                                    ; 331C
L331D:	defb 00h                         ; 331D
L331E:	defb 00h                         ; 331E
L331F:	defb 00h                         ; 331F
L3320:	defb 00h                         ; 3320
L3321:	defb 00h                         ; 3321
L3322:	defb 00h,00h,00h,00h             ; 3322
L3326:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Ah,0A8h,0A0h,0Ah,0A8h,0AAh; 3326
	defb 8Ah,0A8h,0A0h,0A0h,0Ah,0A8h,0A0h,0Ah,0A8h,0AAh,8Ah,0A8h,0A0h,0A0h,0Ah,00h; 3336
	defb 0A0h,0Ah,28h,0A2h,8Ah,28h,0A0h,0A0h,0Ah,00h,0A0h,0Ah,28h,0A2h,8Ah,28h; 3346
	defb 0A0h,0A0h,0Ah,0A8h,0A0h,0Ah,0A8h,0AAh,8Ah,0A8h,0AAh,0A0h,0Ah,0A8h,0A0h,0Ah; 3356
	defb 0A8h,0AAh,8Ah,0A8h,0AAh,0A0h,0Ah,00h,0AAh,8Ah,28h,0A0h,0Ah,00h,0Ah,00h; 3366
	defb 0Ah,00h,0AAh,8Ah,28h,0A0h,0Ah,00h,0Ah,00h; 3376
L3380:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,05h,54h,50h,05h,54h,55h; 3380
	defb 45h,54h,50h,50h,05h,54h,50h,05h,54h,55h,45h,54h,50h,50h,05h,00h; 3390
	defb 50h,05h,14h,51h,45h,14h,50h,50h,05h,00h,50h,05h,14h,51h,45h,14h; 33A0
	defb 50h,50h,05h,54h,50h,05h,54h,55h,45h,54h,55h,50h,05h,54h,50h,05h; 33B0
	defb 54h,55h,45h,54h,55h,50h,05h,00h,55h,45h,14h,50h,05h,00h,05h,00h; 33C0
	defb 05h,00h,55h,45h,14h,50h,05h,00h,05h,00h; 33D0
L33DA:	defb 15h,55h,55h,54h,15h,55h,55h,55h,55h,54h,15h,55h,55h,54h,15h,55h; 33DA
	defb 55h,55h,55h,54h                   ; 33EA
L33EE:	defb 15h,55h,55h,55h,55h,55h,55h,0A5h,55h,54h,15h,55h,55h,55h,55h,55h; 33EE
	defb 55h,55h,55h,54h                   ; 33FE
L3402:	defb 3Fh,0FFh,0FFh,0FFh,0FFh,0D5h,57h,0FFh,0FFh,0FCh,3Fh,0FFh,0FFh,0FFh,0FFh,0D5h; 3402
	defb 57h,0FFh,0FFh,0FCh                ; 3412
L3416:	defb 15h,55h,55h,55h,55h,55h,55h,56h,95h,54h; 3416
L3420:	defb 35h,30h,20h,00h             ; 3420
L3424:	defb 50h,6Fh,69h,6Eh,74h,73h,00h ; 3424
L342B:	defb 33h,30h,20h,00h             ; 342B
L342F:	defb 50h,6Fh,69h,6Eh,74h,73h,00h ; 342F
L3436:	defb 3Ch,3Ch,20h,42h,6Fh,6Eh,75h,73h,20h,3Eh,3Eh,00h; 3436
L3442:	defb 31h,30h,20h,00h             ; 3442
L3446:	defb 50h,6Fh,69h,6Eh,74h,73h,00h ; 3446
L344D:	defb 26h,20h,54h,49h,4Dh,45h,2Eh,2Eh,2Eh,00h; 344D
L3457:	defb 28h,78h,31h,29h,00h         ; 3457
L345C:	defb 28h,78h,32h,29h,00h         ; 345C
L3461:	defb 28h,78h,33h,29h,00h         ; 3461
L3466:	defb 20h,20h,20h,20h,00h         ; 3466
L346B:	defb 00h                         ; 346B
L346C:	defb 00h                         ; 346C
L346D:	defb 00h,00h                     ; 346D
L346F:	defb 00h                         ; 346F
L3470:	defb 00h                         ; 3470
L3471:	defb 00h                         ; 3471
L3472:	defb 00h                         ; 3472
L3473:	defb 00h,00h,00h                 ; 3473
L3476:	defb 00h                         ; 3476
L3477:	defb 00h                         ; 3477
L3478:	defb 00h                         ; 3478
L3479:	defb 00h,00h                     ; 3479
L347B:	defb 00h                         ; 347B
L347C:	defb 00h                         ; 347C
L347D:	defb 00h,00h                     ; 347D
L347F:	defb 00h,00h                     ; 347F
L3481:	defb 00h                         ; 3481
L3482:	defb 00h                         ; 3482
L3483:	defb 00h,00h                     ; 3483
L3485:	defb 00h,00h                     ; 3485
L3487:	defb 00h                         ; 3487
L3488:	defb 00h                         ; 3488
L3489:	defb 00h,00h                     ; 3489
L348B:	defb 00h,00h                     ; 348B
L348D:	defb 00h                         ; 348D
L348E:	defb 00h                         ; 348E
L348F:	defb 00h                         ; 348F
L3490:	defb 00h                         ; 3490
L3491:	defb 00h,00h                     ; 3491
L3493:	defb 00h,00h                     ; 3493
L3495:	defb 00h,00h                     ; 3495
L3497:	defb 00h,00h                     ; 3497
L3499:	defb 00h,00h                     ; 3499
L349B:	defb 00h,00h                     ; 349B
L349D:	defb 1Ch,0Bh,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,82h; 349D
	defb 00h,00h,02h,02h,02h,02h,02h,02h,02h,03h,03h,02h,02h,03h,05h,04h; 34AD
	defb 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0FFh; 34BD
L34CB:	defb 11h,0Bh,00h,00h,00h,00h,00h,00h,00h,00h,00h,03h,03h,02h,02h,02h; 34CB
	defb 02h,02h,02h,02h,02h,02h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 34DB
	defb 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0FFh; 34EB
L34F9:	defb 18h,10h,01h,03h,03h,03h,03h ; 34F9
L3500:	defb 03h,03h,03h,03h,03h,01h,0FFh; 3500
L3507:	defb 0Bh,14h,03h,04h,04h,04h,04h,03h,03h,03h,03h,03h,03h,04h,03h,03h; 3507
	defb 03h,04h,03h,03h,03h,03h,03h,03h,04h,04h,03h,03h,04h,04h,04h,04h; 3517
	defb 04h,04h,04h,05h,00h,00h,06h,06h,06h,06h,06h,07h,07h,0FFh; 3527
L3535:	defb 16h,0Ch,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 3535
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,05h,03h; 3545
	defb 03h,0FFh                          ; 3555
L3557:	defb 10h,10h,00h,00h,00h,08h,07h,06h,05h,04h,03h,02h,01h,00h,00h,00h; 3557
	defb 00h,09h,00h,0Ah,00h,00h,00h,01h,0FFh; 3567
L3570:	defb 11h,14h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 3570
	defs 20                                ; 3580
	defb 01h,02h,03h,04h,05h,06h,0FFh      ; 3594
L359B:	defb 19h,0Ah,03h,03h,03h,03h,03h,03h,03h,03h,02h,02h,02h,02h,02h,02h; 359B
	defb 02h,02h,02h,02h,02h,02h,03h,05h,04h,04h,04h,04h,04h,04h,04h,04h; 35AB
	defb 04h,04h,04h,04h,04h,0FFh          ; 35BB
L35C1:	defb 15h,0Ah,00h,00h,03h,03h,02h,02h,02h,02h,02h,02h,02h,02h,02h,02h; 35C1
	defb 02h,02h,02h,02h,02h,02h,02h,02h,02h,04h,04h,04h,04h,04h,04h,04h; 35D1
	defb 04h,04h,04h,04h,04h,0FFh          ; 35E1
L35E7:	defb 13h,0Eh,0FFh                ; 35E7
L35EA:	defb 13h,11h,0FFh                ; 35EA
L35ED:	defb 13h,14h,0FFh                ; 35ED
L35F0:	defb 0Ah,16h,03h,04h,04h,04h,03h,03h,04h,04h,04h,03h,04h,03h,03h,03h; 35F0
	defb 03h,03h,03h,04h,03h,04h,04h,04h,04h,04h,05h,00h,00h,06h,06h,06h; 3600
	defb 06h,06h,07h,07h,07h,0FFh          ; 3610
L3616:	defb 17h,0Bh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 3616
	defb 00h,00h,00h,00h,00h,00h,00h,05h,03h,06h,0FFh; 3626
L3631:	defb 11h,16h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 3631
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,02h,03h,04h,05h,06h,07h; 3641
	defb 08h,0FFh                          ; 3651
L3653:	defb 00h,00h,00h,00h,01h,00h,00h,00h,00h,02h,00h,00h,00h,00h,03h,00h; 3653
	defb 00h,00h,00h,04h,0FFh              ; 3663
L3668:	defb 00h,00h,00h,00h,00h,00h,00h,00h; 3668
L3670:	defb 52h,45h,50h,4Ch,41h,59h,2Eh,2Eh,2Eh,00h; 3670
L367A:	defb 53h,50h,41h,43h,45h,20h,4Bh,45h,59h,00h; 367A
L3684:	defb 54h,52h,49h,47h,47h,45h,52h,00h; 3684
L368C:	defb 4Dh,45h,4Eh,55h,2Eh,2Eh,2Eh,2Eh,00h; 368C
L3695:	defb 43h,52h,20h,20h,4Bh,45h,59h,00h; 3695
L369D:	defb 4Dh,20h,45h,20h,4Eh,20h,55h,00h; 369D
L36A5:	defb 46h,31h,00h                 ; 36A5
L36A8:	defb 46h,32h,00h                 ; 36A8
L36AB:	defb 3Ah,00h                     ; 36AB
L36AD:	defb 53h,70h,65h,65h,64h,20h,63h,6Fh,6Eh,74h,72h,6Fh,6Ch,20h,28h,30h; 36AD
	defb 2Dh,39h,29h,00h                   ; 36BD
L36C1:	defb 4Bh,65h,79h,20h,77h,6Fh,72h,64h,20h,69h,6Eh,70h,75h,74h,00h; 36C1
L36D0:	defb 48h,69h,74h,20h,00h         ; 36D0
L36D5:	defb 20h,74h,6Fh,20h,44h,45h,4Dh,4Fh,20h,53h,54h,41h,52h,54h,00h; 36D5
L36E4:	defb 20h,74h,6Fh,20h,47h,41h,4Dh,45h,20h,53h,54h,41h,52h,54h,00h,00h; 36E4
	defb 00h                               ; 36F4
L36F5:	defb 31h,39h,38h,34h,00h,0F3h,21h,0Fh,37h,11h,00h,0FAh,01h,18h,00h,0EDh; 36F5
	defb 0B0h,0FBh,0C9h,0F5h,0CDh,90h,39h,0FBh,0F1h,0C9h,06h,37h,21h,38h,06h,37h; 3705
	defb 06h,37h,06h,37h,06h,37h,06h,37h,27h,37h,27h,37h,06h,37h,27h,37h; 3715
	defb 86h,39h                           ; 3725
L3727:	di                               ; 3727
	push af                                ; 3728
	call read_key                          ; 3729
	sub 0F0h                               ; 372C
	jp c,L3737                             ; 372E
	cp 0Ah                                 ; 3731
	jr z,L373A                             ; 3733
	jr c,L3741                             ; 3735
L3737:	ei                               ; 3737
	pop af                                 ; 3738
	ret                                    ; 3739
L373A:	ld a,01h                         ; 373A
	ld (quit_req),a                        ; 373C
	jr L3737                               ; 373F
L3741:	inc a                            ; 3741
	ld (speed_req),a                       ; 3742
	jr L3737                               ; 3745
quit_req:	defb 00h                      ; 3747
speed_req:	defb 00h                     ; 3748
L3749:	di                               ; 3749
	push hl                                ; 374A
	ld hl,L386C                            ; 374B
	call L3773                             ; 374E
	call L378D                             ; 3751
	pop hl                                 ; 3754
	ei                                     ; 3755
	ret                                    ; 3756
L3757:	di                               ; 3757
	push hl                                ; 3758
	ld hl,L3885                            ; 3759
	call L3773                             ; 375C
	call L37A4                             ; 375F
	pop hl                                 ; 3762
	ei                                     ; 3763
	ret                                    ; 3764
L3765:	di                               ; 3765
	push hl                                ; 3766
	ld hl,L38F1                            ; 3767
	call L3773                             ; 376A
	call L37C5                             ; 376D
	pop hl                                 ; 3770
	ei                                     ; 3771
	ret                                    ; 3772
L3773:	push af                          ; 3773
	xor a                                  ; 3774
	ld (L3935),a                           ; 3775
	ld (ext_vectors_2),hl                  ; 3778
	pop af                                 ; 377B
	ret                                    ; 377C
L377D:	di                               ; 377D
	push hl                                ; 377E
	ld hl,L3821                            ; 377F
	ld (ext_vectors_2),hl                  ; 3782
	pop hl                                 ; 3785
	ei                                     ; 3786
	ret                                    ; 3787
	defb 0C5h,0Eh,03h,18h,03h              ; 3788
L378D:	push bc                          ; 378D
	ld c,07h                               ; 378E
	push hl                                ; 3790
	push af                                ; 3791
	ld a,(speed_digit)                     ; 3792
	call L3801                             ; 3795
	call print_char                        ; 3798
	pop af                                 ; 379B
	pop hl                                 ; 379C
	pop bc                                 ; 379D
	ret                                    ; 379E
L379F:	push bc                          ; 379F
	ld c,03h                               ; 37A0
	jr L37A7                               ; 37A2
L37A4:	push bc                          ; 37A4
	ld c,07h                               ; 37A5
L37A7:	push hl                          ; 37A7
	push de                                ; 37A8
	push af                                ; 37A9
	ld hl,keyword_buf                      ; 37AA
	ld a,(L3935)                           ; 37AD
	ld d,00h                               ; 37B0
	ld e,a                                 ; 37B2
	add hl,de                              ; 37B3
	ld a,(hl)                              ; 37B4
	call L3801                             ; 37B5
	call print_char                        ; 37B8
	pop af                                 ; 37BB
	pop de                                 ; 37BC
	pop hl                                 ; 37BD
	pop bc                                 ; 37BE
	ret                                    ; 37BF
L37C0:	push bc                          ; 37C0
	ld c,03h                               ; 37C1
	jr L37C8                               ; 37C3
L37C5:	push bc                          ; 37C5
	ld c,07h                               ; 37C6
L37C8:	push hl                          ; 37C8
	push de                                ; 37C9
	push af                                ; 37CA
	call L380F                             ; 37CB
	ld a,(L3935)                           ; 37CE
	ld e,a                                 ; 37D1
	ld a,(keyword_idx)                     ; 37D2
	add a,e                                ; 37D5
	ld d,00h                               ; 37D6
	ld e,a                                 ; 37D8
	cp 0Ah                                 ; 37D9
	call c,L37F4                           ; 37DB
	cp 64h                                 ; 37DE
	call c,L37F4                           ; 37E0
	ld a,00h                               ; 37E3
	ld (L3EE9),a                           ; 37E5
	ld a,c                                 ; 37E8
	ld (text_colour),a                     ; 37E9
	call print_num                         ; 37EC
	pop af                                 ; 37EF
	pop de                                 ; 37F0
	pop hl                                 ; 37F1
	pop bc                                 ; 37F2
	ret                                    ; 37F3
L37F4:	push de                          ; 37F4
	push af                                ; 37F5
	ld de,font                             ; 37F6
	ld a,c                                 ; 37F9
	call put_char                          ; 37FA
	inc hl                                 ; 37FD
	pop af                                 ; 37FE
	pop de                                 ; 37FF
	ret                                    ; 3800
L3801:	push af                          ; 3801
	ld hl,(L3933)                          ; 3802
	ld a,(L3935)                           ; 3805
	add a,l                                ; 3808
	ld l,a                                 ; 3809
	call vaddr                             ; 380A
	pop af                                 ; 380D
	ret                                    ; 380E
L380F:	push af                          ; 380F
	ld a,(L3935)                           ; 3810
	ld l,a                                 ; 3813
	add a,a                                ; 3814
	add a,a                                ; 3815
	add a,l                                ; 3816
	ld hl,(L3933)                          ; 3817
	add a,l                                ; 381A
	ld l,a                                 ; 381B
	call vaddr                             ; 381C
	pop af                                 ; 381F
	ret                                    ; 3820
L3821:	di                               ; 3821
	push af                                ; 3822
	call read_key                          ; 3823
	ld (last_key),a                        ; 3826
	cp 0Ch                                 ; 3829
	jr z,L3834                             ; 382B
	cp 1Bh                                 ; 382D
	jr z,L3844                             ; 382F
	pop af                                 ; 3831
	ei                                     ; 3832
	ret                                    ; 3833
L3834:	ld a,(key_held)                  ; 3834
	and a                                  ; 3837
	jr nz,L3841                            ; 3838
	ld a,(L738D)                           ; 383A
	cpl                                    ; 383D
	ld (L738D),a                           ; 383E
L3841:	pop af                           ; 3841
	ei                                     ; 3842
	ret                                    ; 3843
L3844:	ld a,(key_held)                  ; 3844
	and a                                  ; 3847
	jr nz,L385D                            ; 3848
	ld a,0FFh                              ; 384A
	ld (key_held),a                        ; 384C
	ld a,(L738D)                           ; 384F
	ld (L386B),a                           ; 3852
	ld a,0FFh                              ; 3855
	ld (L738D),a                           ; 3857
	pop af                                 ; 385A
	ei                                     ; 385B
	ret                                    ; 385C
L385D:	xor a                            ; 385D
	ld (key_held),a                        ; 385E
	ld a,(L386B)                           ; 3861
	ld (L738D),a                           ; 3864
	pop af                                 ; 3867
	ei                                     ; 3868
	ret                                    ; 3869
key_held:	defb 00h                      ; 386A
L386B:	defb 00h                         ; 386B
L386C:	di                               ; 386C
	push af                                ; 386D
	call read_key                          ; 386E
	ld (last_key),a                        ; 3871
	cp 30h                                 ; 3874
	jr c,L387F                             ; 3876
	cp 3Ah                                 ; 3878
	jr nc,L387F                            ; 387A
	ld (speed_digit),a                     ; 387C
L387F:	call L378D                       ; 387F
	pop af                                 ; 3882
	ei                                     ; 3883
	ret                                    ; 3884
L3885:	di                               ; 3885
	push hl                                ; 3886
	push de                                ; 3887
	push af                                ; 3888
	call read_key                          ; 3889
	ld (last_key),a                        ; 388C
	cp 21h                                 ; 388F
	jr c,L38C0                             ; 3891
	cp 0E0h                                ; 3893
	jp nc,L38E9                            ; 3895
	cp 0A0h                                ; 3898
	jr nc,L38A0                            ; 389A
	cp 86h                                 ; 389C
	jr nc,L38E9                            ; 389E
L38A0:	ld hl,keyword_buf                ; 38A0
	push af                                ; 38A3
	ld a,(L3935)                           ; 38A4
	ld d,00h                               ; 38A7
	ld e,a                                 ; 38A9
	add hl,de                              ; 38AA
	pop af                                 ; 38AB
	ld (hl),a                              ; 38AC
	call L379F                             ; 38AD
	ld a,(L3935)                           ; 38B0
	inc a                                  ; 38B3
	cp 05h                                 ; 38B4
	jr c,L38BA                             ; 38B6
	ld a,04h                               ; 38B8
L38BA:	ld (L3935),a                     ; 38BA
	jp L38E9                               ; 38BD
L38C0:	cp 1Ch                           ; 38C0
	jr z,L38D9                             ; 38C2
	cp 1Dh                                 ; 38C4
	jr z,L38CA                             ; 38C6
	jr L38E9                               ; 38C8
L38CA:	ld a,(L3935)                     ; 38CA
	and a                                  ; 38CD
	jr z,L38E9                             ; 38CE
	call L379F                             ; 38D0
	dec a                                  ; 38D3
	ld (L3935),a                           ; 38D4
	jr L38E9                               ; 38D7
L38D9:	ld a,(L3935)                     ; 38D9
	cp 04h                                 ; 38DC
	jr nc,L38E9                            ; 38DE
	call L379F                             ; 38E0
	inc a                                  ; 38E3
	ld (L3935),a                           ; 38E4
	jr L38E9                               ; 38E7
L38E9:	call L37A4                       ; 38E9
	pop af                                 ; 38EC
	pop de                                 ; 38ED
	pop hl                                 ; 38EE
	ei                                     ; 38EF
	ret                                    ; 38F0
L38F1:	di                               ; 38F1
	push bc                                ; 38F2
	push af                                ; 38F3
	call read_key                          ; 38F4
	ld (last_key),a                        ; 38F7
	cp 1Ch                                 ; 38FA
	jr z,L3913                             ; 38FC
	cp 1Dh                                 ; 38FE
	jr z,L3904                             ; 3900
	jr L3921                               ; 3902
L3904:	ld a,(L3935)                     ; 3904
	and a                                  ; 3907
	jr z,L3921                             ; 3908
	call L37C0                             ; 390A
	dec a                                  ; 390D
	ld (L3935),a                           ; 390E
	jr L3921                               ; 3911
L3913:	ld a,(L3935)                     ; 3913
	cp 04h                                 ; 3916
	jr nc,L3921                            ; 3918
	call L37C0                             ; 391A
	inc a                                  ; 391D
	ld (L3935),a                           ; 391E
L3921:	call L37C5                       ; 3921
	ld a,(keyword_idx)                     ; 3924
	ld c,a                                 ; 3927
	ld a,(L3935)                           ; 3928
	add a,c                                ; 392B
	ld (stage),a                           ; 392C
	pop af                                 ; 392F
	pop bc                                 ; 3930
	ei                                     ; 3931
	ret                                    ; 3932
L3933:	defb 00h,00h                     ; 3933
L3935:	defb 00h                         ; 3935
last_key:	defb 00h                      ; 3936
speed_digit:	defb 35h,00h               ; 3937
keyword_buf:	defb 20h,20h,20h,20h,20h,00h; 3939
read_dir:	di                            ; 393F
	ld a,0E6h                              ; 3940
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	ld b,00h                               ; 3946
	cpl                                    ; 3948
	and 10h                                ; 3949
	jr z,L3951                             ; 394B
	rlca                                   ; 394D
	rlca                                   ; 394E
	rlca                                   ; 394F
	ld b,a                                 ; 3950
L3951:	ld a,0E7h                        ; 3951
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3957
	and 3Ch                                ; 3958
	jr z,L3971                             ; 395A
	ld c,00h                               ; 395C
	rlca                                   ; 395E
	rlca                                   ; 395F
	rlca                                   ; 3960
	rr c                                   ; 3961
	rlca                                   ; 3963
	rr c                                   ; 3964
	rlca                                   ; 3966
	rr c                                   ; 3967
	rlca                                   ; 3969
	rr c                                   ; 396A
	ld a,c                                 ; 396C
	rrca                                   ; 396D
	rrca                                   ; 396E
	or b                                   ; 396F
	ld b,a                                 ; 3970
L3971:	ld a,0E8h                        ; 3971
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3977
	and 80h                                ; 3978
	jr z,L3980                             ; 397A
	rlca                                   ; 397C
	rlca                                   ; 397D
	or b                                   ; 397E
	ld b,a                                 ; 397F
L3980:	ld a,b                           ; 3980
	ld (dir_state),a                       ; 3981
	ei                                     ; 3984
	ret                                    ; 3985
	defb 0F5h,0CDh,90h,39h,32h,8Fh,39h,0F1h,0C9h; 3986
dir_state:	defb 00h                     ; 398F
read_key:	push de                       ; 3990
	push bc                                ; 3991
	ld b,30h                               ; 3992
	ld a,0E5h                              ; 3994
	ld d,08h                               ; 3996
	call key_row                           ; 3998
	ld a,0E4h                              ; 399B
	ld b,40h                               ; 399D
	ld d,08h                               ; 399F
	call key_row                           ; 39A1
	ld a,0E3h                              ; 39A4
	ld b,48h                               ; 39A6
	ld d,08h                               ; 39A8
	call key_row                           ; 39AA
	ld a,0E2h                              ; 39AD
	ld b,50h                               ; 39AF
	ld d,08h                               ; 39B1
	call key_row                           ; 39B3
	ld a,0E6h                              ; 39B6
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 39BC
	or a                                   ; 39BD
	jr z,L39F0                             ; 39BE
	rra                                    ; 39C0
	jr nc,L39C8                            ; 39C1
	ld a,7Fh                               ; 39C3
	jp L3AF3                               ; 39C5
L39C8:	rra                              ; 39C8
	jr nc,L39D0                            ; 39C9
	ld a,2Ch                               ; 39CB
	jp L3AF3                               ; 39CD
L39D0:	rra                              ; 39D0
	jr nc,L39D8                            ; 39D1
	ld a,39h                               ; 39D3
	jp L3AF3                               ; 39D5
L39D8:	rra                              ; 39D8
	jr nc,L39E0                            ; 39D9
	ld a,30h                               ; 39DB
	jp L3AF3                               ; 39DD
L39E0:	rra                              ; 39E0
	jr nc,L39E8                            ; 39E1
	ld a,20h                               ; 39E3
	jp L3AF3                               ; 39E5
L39E8:	rra                              ; 39E8
	jr nc,L39F0                            ; 39E9
	ld a,2Dh                               ; 39EB
	jp L3AF3                               ; 39ED
L39F0:	ld a,0E7h                        ; 39F0
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 39F6
	or a                                   ; 39F7
	jr z,L3A3A                             ; 39F8
	rla                                    ; 39FA
	jr nc,L3A02                            ; 39FB
	ld a,01h                               ; 39FD
	jp L3AF3                               ; 39FF
L3A02:	rla                              ; 3A02
	jr nc,L3A0A                            ; 3A03
	ld a,02h                               ; 3A05
	jp L3AF3                               ; 3A07
L3A0A:	rla                              ; 3A0A
	jr nc,L3A12                            ; 3A0B
	ld a,1Eh                               ; 3A0D
	jp L3AF3                               ; 3A0F
L3A12:	rla                              ; 3A12
	jr nc,L3A1A                            ; 3A13
	ld a,1Fh                               ; 3A15
	jp L3AF3                               ; 3A17
L3A1A:	rla                              ; 3A1A
	jr nc,L3A22                            ; 3A1B
	ld a,1Ch                               ; 3A1D
	jp L3AF3                               ; 3A1F
L3A22:	rla                              ; 3A22
	jr nc,L3A2A                            ; 3A23
	ld a,1Dh                               ; 3A25
	jp L3AF3                               ; 3A27
L3A2A:	rla                              ; 3A2A
	jr nc,L3A32                            ; 3A2B
	ld a,3Fh                               ; 3A2D
	jp L3AF3                               ; 3A2F
L3A32:	rla                              ; 3A32
	jr nc,L3A3A                            ; 3A33
	ld a,2Fh                               ; 3A35
	jp L3AF3                               ; 3A37
L3A3A:	ld a,0E8h                        ; 3A3A
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3A40
	or a                                   ; 3A41
	jr z,L3A54                             ; 3A42
	rla                                    ; 3A44
	jr nc,L3A4C                            ; 3A45
	ld a,03h                               ; 3A47
	jp L3AF3                               ; 3A49
L3A4C:	rla                              ; 3A4C
	jr nc,L3A54                            ; 3A4D
	ld a,04h                               ; 3A4F
	jp L3AF3                               ; 3A51
L3A54:	ld a,0E1h                        ; 3A54
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3A5A
	or a                                   ; 3A5B
	jr z,L3A86                             ; 3A5C
	rla                                    ; 3A5E
	jr nc,L3A66                            ; 3A5F
	ld a,59h                               ; 3A61
	jp L3AF3                               ; 3A63
L3A66:	rla                              ; 3A66
	jr nc,L3A6E                            ; 3A67
	ld a,5Ah                               ; 3A69
	jp L3AF3                               ; 3A6B
L3A6E:	rla                              ; 3A6E
	jr nc,L3A76                            ; 3A6F
	ld a,40h                               ; 3A71
	jp L3AF3                               ; 3A73
L3A76:	rla                              ; 3A76
	jr nc,L3A7E                            ; 3A77
	ld a,5Bh                               ; 3A79
	jp L3AF3                               ; 3A7B
L3A7E:	rla                              ; 3A7E
	jr nc,L3A86                            ; 3A7F
	ld a,5Dh                               ; 3A81
	jp L3AF3                               ; 3A83
L3A86:	ld a,0E0h                        ; 3A86
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3A8C
	or a                                   ; 3A8D
	jr z,L3AC8                             ; 3A8E
	rla                                    ; 3A90
	jr nc,L3A97                            ; 3A91
	ld a,06h                               ; 3A93
	jr L3AF3                               ; 3A95
L3A97:	rla                              ; 3A97
	jr nc,L3A9E                            ; 3A98
	ld a,07h                               ; 3A9A
	jr L3AF3                               ; 3A9C
L3A9E:	rla                              ; 3A9E
	jr nc,L3AA5                            ; 3A9F
	ld a,08h                               ; 3AA1
	jr L3AF3                               ; 3AA3
L3AA5:	rla                              ; 3AA5
	jr nc,L3AAC                            ; 3AA6
	ld a,09h                               ; 3AA8
	jr L3AF3                               ; 3AAA
L3AAC:	rla                              ; 3AAC
	jr nc,L3AB3                            ; 3AAD
	ld a,0Ah                               ; 3AAF
	jr L3AF3                               ; 3AB1
L3AB3:	rla                              ; 3AB3
	jr nc,L3ABA                            ; 3AB4
	ld a,3Bh                               ; 3AB6
	jr L3AF3                               ; 3AB8
L3ABA:	rla                              ; 3ABA
	jr nc,L3AC1                            ; 3ABB
	ld a,3Ah                               ; 3ABD
	jr L3AF3                               ; 3ABF
L3AC1:	rla                              ; 3AC1
	jr nc,L3AF3                            ; 3AC2
	ld a,0Dh                               ; 3AC4
	jr L3AF3                               ; 3AC6
L3AC8:	ld a,0E9h                        ; 3AC8
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3ACE
	or a                                   ; 3ACF
	jr z,L3AF3                             ; 3AD0
	rla                                    ; 3AD2
	jr nc,L3AD9                            ; 3AD3
	ld a,0F0h                              ; 3AD5
	jr L3AF3                               ; 3AD7
L3AD9:	rla                              ; 3AD9
	jr nc,L3AE0                            ; 3ADA
	ld a,0F1h                              ; 3ADC
	jr L3AF3                               ; 3ADE
L3AE0:	rla                              ; 3AE0
	jr nc,L3AE7                            ; 3AE1
	ld a,0F2h                              ; 3AE3
	jr L3AF3                               ; 3AE5
L3AE7:	rla                              ; 3AE7
	jr nc,L3AEE                            ; 3AE8
	ld a,0F3h                              ; 3AEA
	jr L3AF3                               ; 3AEC
L3AEE:	rla                              ; 3AEE
	jr nc,L3AF3                            ; 3AEF
	ld a,0F4h                              ; 3AF1
L3AF3:	push af                          ; 3AF3
	ld a,0E8h                              ; 3AF4
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
	call kbd_row
	nop
	cpl                                    ; 3AFA
	and 01h                                ; 3AFB
	ld (L3B15),a                           ; 3AFD
	jr z,L3B16                             ; 3B00
	pop af                                 ; 3B02
	cp 30h                                 ; 3B03
	jr c,L3B17                             ; 3B05
	cp 3Ah                                 ; 3B07
	jr c,L3B1A                             ; 3B09
	cp 41h                                 ; 3B0B
	jr c,L3B17                             ; 3B0D
	cp 5Bh                                 ; 3B0F
	jr c,L3B1F                             ; 3B11
	jr L3B17                               ; 3B13
L3B15:	defb 00h                         ; 3B15
L3B16:	pop af                           ; 3B16
L3B17:	pop bc                           ; 3B17
	pop de                                 ; 3B18
	ret                                    ; 3B19
L3B1A:	sub 10h                          ; 3B1A
	pop bc                                 ; 3B1C
	pop de                                 ; 3B1D
	ret                                    ; 3B1E
L3B1F:	add a,20h                        ; 3B1F
	pop bc                                 ; 3B21
	pop de                                 ; 3B22
	ret                                    ; 3B23
	; SAPI: MZ: OUT (0D0h),A + IN A,(0D1h), keyboard column (kbd_row).
key_row:	call kbd_row
	nop
	cpl                                    ; 3B28
	or a                                   ; 3B29
	ret z                                  ; 3B2A
L3B2B:	inc b                            ; 3B2B
	rla                                    ; 3B2C
	jr c,L3B33                             ; 3B2D
	dec d                                  ; 3B2F
	jr nz,L3B2B                            ; 3B30
	ret                                    ; 3B32
L3B33:	ld a,b                           ; 3B33
	pop de                                 ; 3B34
	jr L3AF3                               ; 3B35
	defb 3Eh,01h,0C9h                      ; 3B37
read_joy:	di                            ; 3B3A
	ld a,0CFh                              ; 3B3B
	; SAPI: MZ: OUT (0D0h),A + IN A,(0F0h), joystick 1 (joy_k4).
	call joy_k4
	nop
	cpl                                    ; 3B41
	or a                                   ; 3B42
	jr nz,L3B4C                            ; 3B43
	ld a,0CFh                              ; 3B45
	; SAPI: MZ: OUT (0D0h),A + IN A,(0F1h), joystick 2.
	call joy_none
	nop
	cpl                                    ; 3B4B
L3B4C:	push bc                          ; 3B4C
	ld b,a                                 ; 3B4D
	and 30h                                ; 3B4E
	jr z,L3B54                             ; 3B50
	set 4,b                                ; 3B52
L3B54:	ld a,b                           ; 3B54
	pop bc                                 ; 3B55
	ei                                     ; 3B56
	ret                                    ; 3B57
	defb 0F6h,80h,0C5h,47h,3Eh,07h,0F3h,0D3h,0A0h,0DBh,0A2h,4Fh,3Eh,80h,0D3h,0A1h; 3B58
	defb 3Eh,0Fh,0D3h,0A0h,78h,0D3h,0A1h,3Eh,0Eh,0D3h,0A0h,0DBh,0A2h,2Fh,47h,3Eh; 3B68
	defb 07h,0D3h,0A0h,79h,0D3h,0A1h,0FBh,78h,0C1h,0C9h; 3B78
random:	push hl                         ; 3B82
	push bc                                ; 3B83
	ld hl,restart                          ; 3B84
L3B85            equ $-2
	ld a,(hl)                              ; 3B87
	inc hl                                 ; 3B88
	xor (hl)                               ; 3B89
	inc hl                                 ; 3B8A
	ld b,a                                 ; 3B8B
	ld a,r                                 ; 3B8C
	xor b                                  ; 3B8E
	ld bc,7F3Fh                            ; 3B8F
	sbc hl,bc                              ; 3B92
	jr c,L3B9A                             ; 3B94
	ld hl,restart                          ; 3B96
	ld l,a                                 ; 3B99
L3B9A:	ld (L3B85),hl                    ; 3B9A
	pop bc                                 ; 3B9D
	pop hl                                 ; 3B9E
	ret                                    ; 3B9F
	; SAPI: MZ busy loop (A x 4 ms at 3.5 MHz): replaced by delay_units.
delay:	jp delay_units
L3BA1            equ delay+1
L3BA3:	push ix                          ; 3BA3
	pop ix                                 ; 3BA5
	push ix                                ; 3BA7
	pop ix                                 ; 3BA9
	djnz L3BA3                             ; 3BAB
	dec a                                  ; 3BAD
	jr nz,L3BA1                            ; 3BAE
	pop bc                                 ; 3BB0
	ret                                    ; 3BB1
vaddr_field:	push de                    ; 3BB2
	ld d,h                                 ; 3BB3
	ld e,l                                 ; 3BB4
	ld l,h                                 ; 3BB5
	ld h,00h                               ; 3BB6
	add hl,hl                              ; 3BB8
	add hl,hl                              ; 3BB9
	add hl,hl                              ; 3BBA
	add hl,hl                              ; 3BBB
	add hl,hl                              ; 3BBC
	add hl,hl                              ; 3BBD
	add hl,de                              ; 3BBE
	ld de,83C0h                            ; 3BBF
	add hl,de                              ; 3BC2
	pop de                                 ; 3BC3
	ret                                    ; 3BC4
vaddr:	push de                          ; 3BC5
	ld d,h                                 ; 3BC6
	ld e,l                                 ; 3BC7
	ld l,h                                 ; 3BC8
	ld h,00h                               ; 3BC9
	add hl,hl                              ; 3BCB
	add hl,hl                              ; 3BCC
	add hl,hl                              ; 3BCD
	add hl,hl                              ; 3BCE
	add hl,hl                              ; 3BCF
	add hl,hl                              ; 3BD0
	add hl,de                              ; 3BD1
	ld de,8000h                            ; 3BD2
	add hl,de                              ; 3BD5
	pop de                                 ; 3BD6
	ret                                    ; 3BD7
map_addr:	push de                       ; 3BD8
	push af                                ; 3BD9
	ld a,l                                 ; 3BDA
	ld l,h                                 ; 3BDB
	ld h,00h                               ; 3BDC
	add hl,hl                              ; 3BDE
	add hl,hl                              ; 3BDF
	add hl,hl                              ; 3BE0
	ld d,h                                 ; 3BE1
	ld e,l                                 ; 3BE2
	add hl,hl                              ; 3BE3
	add hl,hl                              ; 3BE4
	add hl,de                              ; 3BE5
	ld d,00h                               ; 3BE6
	ld e,a                                 ; 3BE8
	add hl,de                              ; 3BE9
	ld de,map_buf                          ; 3BEA
	add hl,de                              ; 3BED
	pop af                                 ; 3BEE
	pop de                                 ; 3BEF
	ret                                    ; 3BF0
	; SAPI: the MZ routine below draws into the VRAM: replaced by put8x8_s.
put8x8:	jp put8x8_s
	in a,(0E0h)                            ; 3BF4
	ld bc,81CCh                            ; 3BF6
	out (c),b                              ; 3BF9
	push hl                                ; 3BFB
	call put8x8_plane                      ; 3BFC
	pop hl                                 ; 3BFF
	ld bc,22CCh                            ; 3C00
	out (c),b                              ; 3C03
	call put8x8_plane                      ; 3C05
	pop bc                                 ; 3C08
	pop de                                 ; 3C09
	pop hl                                 ; 3C0A
	ret                                    ; 3C0B
put8x8_plane:	ld a,08h                  ; 3C0C
	ld bc,0028h                            ; 3C0E
L3C11:	ex af,af'                        ; 3C11
	ld a,(de)                              ; 3C12
	ld (hl),a                              ; 3C13
	inc de                                 ; 3C14
	add hl,bc                              ; 3C15
	ex af,af'                              ; 3C16
	dec a                                  ; 3C17
	jp nz,L3C11                            ; 3C18
	ret                                    ; 3C1B
	; SAPI: the MZ routine below draws into the VRAM: replaced by put16x8_s.
put16x8:	jp put16x8_s
	push af                                ; 3C1F
	in a,(0E0h)                            ; 3C20
	ld bc,81CCh                            ; 3C22
	out (c),b                              ; 3C25
	push hl                                ; 3C27
	call put16x8_plane                     ; 3C28
	pop hl                                 ; 3C2B
	ld bc,22CCh                            ; 3C2C
	out (c),b                              ; 3C2F
	call put16x8_plane                     ; 3C31
	pop af                                 ; 3C34
	pop bc                                 ; 3C35
	pop de                                 ; 3C36
	pop hl                                 ; 3C37
	ret                                    ; 3C38
put16x8_plane:	ld a,08h                 ; 3C39
	ld bc,0027h                            ; 3C3B
L3C3E:	ex af,af'                        ; 3C3E
	ld a,(de)                              ; 3C3F
	ld (hl),a                              ; 3C40
	inc de                                 ; 3C41
	inc hl                                 ; 3C42
	ld a,(de)                              ; 3C43
	ld (hl),a                              ; 3C44
	inc de                                 ; 3C45
	add hl,bc                              ; 3C46
	ex af,af'                              ; 3C47
	dec a                                  ; 3C48
	jp nz,L3C3E                            ; 3C49
	ret                                    ; 3C4C
	; SAPI: the MZ routine below draws into the VRAM: replaced by put16x16_s.
put16x16:	jp put16x16_s
	push af                                ; 3C50
	in a,(0E0h)                            ; 3C51
	ld bc,81CCh                            ; 3C53
	out (c),b                              ; 3C56
	ld (L3C71),hl                          ; 3C58
	ex de,hl                               ; 3C5B
	ld (L3C85),sp                          ; 3C5C
	di                                     ; 3C60
	ld sp,0026h                            ; 3C61
	ld bc,10FFh                            ; 3C64
L3C67:	ldi                              ; 3C67
	ldi                                    ; 3C69
	ex de,hl                               ; 3C6B
	add hl,sp                              ; 3C6C
	ex de,hl                               ; 3C6D
	djnz L3C67                             ; 3C6E
	ld de,0000h                            ; 3C70
L3C71            equ $-2
	ld bc,22CCh                            ; 3C73
	out (c),b                              ; 3C76
	ld bc,10FFh                            ; 3C78
L3C7B:	ldi                              ; 3C7B
	ldi                                    ; 3C7D
	ex de,hl                               ; 3C7F
	add hl,sp                              ; 3C80
	ex de,hl                               ; 3C81
	djnz L3C7B                             ; 3C82
	ld sp,0000h                            ; 3C84
L3C85            equ $-2
	ei                                     ; 3C87
	pop af                                 ; 3C88
	pop bc                                 ; 3C89
	pop de                                 ; 3C8A
	pop hl                                 ; 3C8B
	ret                                    ; 3C8C
	; SAPI: the MZ routine below draws into the VRAM: replaced by put24x16_s.
put24x16:	jp put24x16_s
	push af                                ; 3C90
	in a,(0E0h)                            ; 3C91
	ld bc,81CCh                            ; 3C93
	out (c),b                              ; 3C96
	ld (L3CB3),hl                          ; 3C98
	ex de,hl                               ; 3C9B
	ld (L3CC9),sp                          ; 3C9C
	di                                     ; 3CA0
	ld sp,0025h                            ; 3CA1
	ld bc,10FFh                            ; 3CA4
L3CA7:	ldi                              ; 3CA7
	ldi                                    ; 3CA9
	ldi                                    ; 3CAB
	ex de,hl                               ; 3CAD
	add hl,sp                              ; 3CAE
	ex de,hl                               ; 3CAF
	djnz L3CA7                             ; 3CB0
	ld de,0000h                            ; 3CB2
L3CB3            equ $-2
	ld bc,22CCh                            ; 3CB5
	out (c),b                              ; 3CB8
	ld bc,10FFh                            ; 3CBA
L3CBD:	ldi                              ; 3CBD
	ldi                                    ; 3CBF
	ldi                                    ; 3CC1
	ex de,hl                               ; 3CC3
	add hl,sp                              ; 3CC4
	ex de,hl                               ; 3CC5
	djnz L3CBD                             ; 3CC6
	ld sp,0000h                            ; 3CC8
L3CC9            equ $-2
	ei                                     ; 3CCB
	pop af                                 ; 3CCC
	pop bc                                 ; 3CCD
	pop de                                 ; 3CCE
	pop hl                                 ; 3CCF
	ret                                    ; 3CD0
	; SAPI: the MZ routine below draws into the VRAM: replaced by put16x24_s.
put16x24:	jp put16x24_s
	push af                                ; 3CD4
	in a,(0E0h)                            ; 3CD5
	ld bc,81CCh                            ; 3CD7
	out (c),b                              ; 3CDA
	ld (L3CF5),hl                          ; 3CDC
	ex de,hl                               ; 3CDF
	ld (L3D09),sp                          ; 3CE0
	di                                     ; 3CE4
	ld sp,0026h                            ; 3CE5
	ld bc,18FFh                            ; 3CE8
L3CEB:	ldi                              ; 3CEB
	ldi                                    ; 3CED
	ex de,hl                               ; 3CEF
	add hl,sp                              ; 3CF0
	ex de,hl                               ; 3CF1
	djnz L3CEB                             ; 3CF2
	ld de,0000h                            ; 3CF4
L3CF5            equ $-2
	ld bc,22CCh                            ; 3CF7
	out (c),b                              ; 3CFA
	ld bc,18FFh                            ; 3CFC
L3CFF:	ldi                              ; 3CFF
	ldi                                    ; 3D01
	ex de,hl                               ; 3D03
	add hl,sp                              ; 3D04
	ex de,hl                               ; 3D05
	djnz L3CFF                             ; 3D06
	ld sp,0000h                            ; 3D08
L3D09            equ $-2
	ei                                     ; 3D0B
	pop af                                 ; 3D0C
	pop bc                                 ; 3D0D
	pop de                                 ; 3D0E
	pop hl                                 ; 3D0F
	ret                                    ; 3D10
	; SAPI: the MZ routine below draws into the VRAM: replaced by clr8_s.
clr8:	jp clr8_s
	in a,(0E0h)                            ; 3D14
	ld bc,81CCh                            ; 3D16
	out (c),b                              ; 3D19
	ld de,0028h                            ; 3D1B
	ld c,00h                               ; 3D1E
	ld b,08h                               ; 3D20
clr8_rows        equ $-1
L3D22:	ld (hl),c                        ; 3D22
	add hl,de                              ; 3D23
	djnz L3D22                             ; 3D24
	pop bc                                 ; 3D26
	pop de                                 ; 3D27
	pop hl                                 ; 3D28
	ret                                    ; 3D29
	; SAPI: the MZ routine below draws into the VRAM: replaced by clr16x8_s.
clr16x8:	jp clr16x8_s
	in a,(0E0h)                            ; 3D2D
	ld bc,81CCh                            ; 3D2F
	out (c),b                              ; 3D32
	ld de,0027h                            ; 3D34
	ld c,00h                               ; 3D37
	ld b,08h                               ; 3D39
L3D3B:	ld (hl),c                        ; 3D3B
	inc hl                                 ; 3D3C
	ld (hl),c                              ; 3D3D
	add hl,de                              ; 3D3E
	djnz L3D3B                             ; 3D3F
	pop bc                                 ; 3D41
	pop de                                 ; 3D42
	pop hl                                 ; 3D43
	ret                                    ; 3D44
clr8x16:	push af                        ; 3D45
	ld a,10h                               ; 3D46
	ld (clr8_rows),a                       ; 3D48
	call clr8                              ; 3D4B
	ld a,08h                               ; 3D4E
	ld (clr8_rows),a                       ; 3D50
	pop af                                 ; 3D53
	ret                                    ; 3D54
print:	push de                          ; 3D55
	push bc                                ; 3D56
	push af                                ; 3D57
	ld c,a                                 ; 3D58
	ld (L3D9D),hl                          ; 3D59
	ld (L3D61),de                          ; 3D5C
L3D60:	ld de,0000h                      ; 3D60
L3D61            equ L3D60+1
	ld a,(de)                              ; 3D63
	inc de                                 ; 3D64
	ld (L3D61),de                          ; 3D65
	and a                                  ; 3D69
	jp z,L3DA9                             ; 3D6A
	cp 20h                                 ; 3D6D
	jp c,L3D99                             ; 3D6F
	cp 0E0h                                ; 3D72
	jp nc,L3D99                            ; 3D74
	cp 0A0h                                ; 3D77
	jp nc,L3D89                            ; 3D79
	cp 80h                                 ; 3D7C
	jp nc,L3D99                            ; 3D7E
	ld de,font                             ; 3D81
	sub 20h                                ; 3D84
	jp L3D8E                               ; 3D86
L3D89:	ld de,font                       ; 3D89
	sub 0A0h                               ; 3D8C
L3D8E:	ld h,00h                         ; 3D8E
	ld l,a                                 ; 3D90
	add hl,hl                              ; 3D91
	add hl,hl                              ; 3D92
	add hl,hl                              ; 3D93
	add hl,de                              ; 3D94
	ex de,hl                               ; 3D95
	jp L3D9C                               ; 3D96
L3D99:	ld de,font                       ; 3D99
L3D9C:	ld hl,0000h                      ; 3D9C
L3D9D            equ L3D9C+1
	call put_char                          ; 3D9F
	inc hl                                 ; 3DA2
	ld (L3D9D),hl                          ; 3DA3
	jp L3D60                               ; 3DA6
L3DA9:	pop af                           ; 3DA9
	pop bc                                 ; 3DAA
	pop de                                 ; 3DAB
	ret                                    ; 3DAC
print_char:	push de                     ; 3DAD
	push af                                ; 3DAE
	ld (L3DD8),hl                          ; 3DAF
	cp 20h                                 ; 3DB2
	jr c,L3DE2                             ; 3DB4
	cp 0E0h                                ; 3DB6
	jr nc,L3DE2                            ; 3DB8
	cp 0A0h                                ; 3DBA
	jr nc,L3DCA                            ; 3DBC
	cp 86h                                 ; 3DBE
	jr nc,L3DE2                            ; 3DC0
	ld de,font                             ; 3DC2
	sub 20h                                ; 3DC5
	jp L3DCF                               ; 3DC7
L3DCA:	ld de,font                       ; 3DCA
	sub 0A0h                               ; 3DCD
L3DCF:	ld h,00h                         ; 3DCF
	ld l,a                                 ; 3DD1
	add hl,hl                              ; 3DD2
	add hl,hl                              ; 3DD3
	add hl,hl                              ; 3DD4
	add hl,de                              ; 3DD5
	ex de,hl                               ; 3DD6
	ld hl,0000h                            ; 3DD7
L3DD8            equ $-2
	call put_char                          ; 3DDA
	ld a,01h                               ; 3DDD
	jp L3DE3                               ; 3DDF
L3DE2:	xor a                            ; 3DE2
L3DE3:	ld (L3DE9),a                     ; 3DE3
	pop af                                 ; 3DE6
	pop de                                 ; 3DE7
	ret                                    ; 3DE8
L3DE9:	defb 00h                         ; 3DE9
print_big:	push de                      ; 3DEA
	push bc                                ; 3DEB
	push af                                ; 3DEC
	ld a,(text_colour)                     ; 3DED
	ld c,a                                 ; 3DF0
	ld a,(de)                              ; 3DF1
	inc de                                 ; 3DF2
	ld b,a                                 ; 3DF3
L3DF4:	call put_char                    ; 3DF4
	inc hl                                 ; 3DF7
	inc de                                 ; 3DF8
	inc de                                 ; 3DF9
	inc de                                 ; 3DFA
	inc de                                 ; 3DFB
	inc de                                 ; 3DFC
	inc de                                 ; 3DFD
	inc de                                 ; 3DFE
	inc de                                 ; 3DFF
	djnz L3DF4                             ; 3E00
	pop af                                 ; 3E02
	pop bc                                 ; 3E03
	pop de                                 ; 3E04
	ret                                    ; 3E05
	; SAPI: the MZ routine below draws into the VRAM: replaced by put_char_s.
put_char:	jp put_char_s
	defs 2
	ld a,2Fh                               ; 3E0B
	jr L3E10                               ; 3E0D
L3E0F:	xor a                            ; 3E0F
L3E10:	ld (L3E36),a                     ; 3E10
	ld a,81h                               ; 3E13
	out (0CCh),a                           ; 3E15
	bit 0,c                                ; 3E17
	call put_char_plane                    ; 3E19
	ld a,22h                               ; 3E1C
	out (0CCh),a                           ; 3E1E
	bit 1,c                                ; 3E20
	call put_char_plane                    ; 3E22
	ret                                    ; 3E25
put_char_plane:	push hl                 ; 3E26
	push de                                ; 3E27
	push bc                                ; 3E28
	push af                                ; 3E29
	jr nz,L3E34                            ; 3E2A
	ld de,L5C1D                            ; 3E2C
	ex af,af'                              ; 3E2F
	xor a                                  ; 3E30
	jp L3E37                               ; 3E31
L3E34:	ex af,af'                        ; 3E34
	ld a,00h                               ; 3E35
L3E36            equ $-1
L3E37:	ld (L3E4A),a                     ; 3E37
	ex af,af'                              ; 3E3A
	ld bc,0028h                            ; 3E3B
	call put_char_rows                     ; 3E3E
	pop af                                 ; 3E41
	pop bc                                 ; 3E42
	pop de                                 ; 3E43
	pop hl                                 ; 3E44
	ret                                    ; 3E45
put_char_rows:	ld a,08h                 ; 3E46
L3E48:	ex af,af'                        ; 3E48
	ld a,(de)                              ; 3E49
L3E4A:	nop                              ; 3E4A
	ld (hl),a                              ; 3E4B
	inc de                                 ; 3E4C
	add hl,bc                              ; 3E4D
	ex af,af'                              ; 3E4E
	dec a                                  ; 3E4F
	jp nz,L3E48                            ; 3E50
	ret                                    ; 3E53
text_colour:	defb 03h                   ; 3E54
print_num:	push de                      ; 3E55
	push bc                                ; 3E56
	push af                                ; 3E57
	xor a                                  ; 3E58
	ld (L3EEA),a                           ; 3E59
	ld (L3F77),hl                          ; 3E5C
	ex de,hl                               ; 3E5F
	ld (L3EEB),hl                          ; 3E60
	ld b,04h                               ; 3E63
	ld a,0B8h                              ; 3E65
	ld de,2710h                            ; 3E67
	ld a,0BFh                              ; 3E6A
	jr L3E7F                               ; 3E6C
	ld de,03E8h                            ; 3E6E
	ld a,0C6h                              ; 3E71
	jr L3E7F                               ; 3E73
	ld de,0064h                            ; 3E75
	ld a,0CDh                              ; 3E78
	jr L3E7F                               ; 3E7A
	ld de,000Ah                            ; 3E7C
L3E7F:	ld (L3EAE),a                     ; 3E7F
	ld c,00h                               ; 3E82
	ld hl,(L3EEB)                          ; 3E84
	xor a                                  ; 3E87
L3E88:	sbc hl,de                        ; 3E88
	jr c,L3E92                             ; 3E8A
	ld (L3EEB),hl                          ; 3E8C
	inc c                                  ; 3E8F
	jr L3E88                               ; 3E90
L3E92:	ld a,(L3EEA)                     ; 3E92
	or a                                   ; 3E95
	jr nz,L3EA6                            ; 3E96
	push bc                                ; 3E98
	ld a,(L3EE9)                           ; 3E99
	inc b                                  ; 3E9C
	cp b                                   ; 3E9D
	jr c,L3EA5                             ; 3E9E
	ld a,01h                               ; 3EA0
	ld (L3EEA),a                           ; 3EA2
L3EA5:	pop bc                           ; 3EA5
L3EA6:	call L3EBC                       ; 3EA6
	srl d                                  ; 3EA9
	rr e                                   ; 3EAB
	djnz L3EAF                             ; 3EAD
L3EAE            equ $-1
L3EAF:	ld a,(L3EEB)                     ; 3EAF
	call L3EC6                             ; 3EB2
	ld hl,(L3F77)                          ; 3EB5
	pop af                                 ; 3EB8
	pop bc                                 ; 3EB9
	pop de                                 ; 3EBA
	ret                                    ; 3EBB
L3EBC:	ld a,c                           ; 3EBC
	or a                                   ; 3EBD
	jr nz,L3EC6                            ; 3EBE
	ld a,(L3EEA)                           ; 3EC0
	or a                                   ; 3EC3
	ret z                                  ; 3EC4
	ld a,c                                 ; 3EC5
L3EC6:	add a,a                          ; 3EC6
	add a,a                                ; 3EC7
	add a,a                                ; 3EC8
	push hl                                ; 3EC9
	push de                                ; 3ECA
	ld hl,L6B5D                            ; 3ECB
	ld d,00h                               ; 3ECE
	ld e,a                                 ; 3ED0
	add hl,de                              ; 3ED1
	ex de,hl                               ; 3ED2
	ld hl,(L3F77)                          ; 3ED3
	ld a,(text_colour)                     ; 3ED6
	ld c,a                                 ; 3ED9
	call put_char                          ; 3EDA
	inc hl                                 ; 3EDD
	ld (L3F77),hl                          ; 3EDE
	pop de                                 ; 3EE1
	pop hl                                 ; 3EE2
	ld a,01h                               ; 3EE3
	ld (L3EEA),a                           ; 3EE5
	ret                                    ; 3EE8
L3EE9:	defb 00h                         ; 3EE9
L3EEA:	defb 00h                         ; 3EEA
L3EEB:	defb 00h,00h                     ; 3EEB
L3EED:	push hl                          ; 3EED
	push de                                ; 3EEE
	push af                                ; 3EEF
	ld a,(text_colour)                     ; 3EF0
	push af                                ; 3EF3
	ld a,(L3EE9)                           ; 3EF4
	push af                                ; 3EF7
	ld a,05h                               ; 3EF8
	ld (L3EE9),a                           ; 3EFA
	ld a,03h                               ; 3EFD
	ld (text_colour),a                     ; 3EFF
	ld hl,8153h                            ; 3F02
	ld de,0000h                            ; 3F05
L3F06            equ $-2
	call print_num                         ; 3F08
	ld a,01h                               ; 3F0B
	ld (L3EE9),a                           ; 3F0D
	ld de,0000h                            ; 3F10
	call print_num                         ; 3F13
	jp L3F37                               ; 3F16
L3F19:	push hl                          ; 3F19
	push de                                ; 3F1A
	push af                                ; 3F1B
	ld a,(text_colour)                     ; 3F1C
	push af                                ; 3F1F
	ld a,(L3EE9)                           ; 3F20
	push af                                ; 3F23
	ld a,05h                               ; 3F24
	ld (L3EE9),a                           ; 3F26
	ld a,03h                               ; 3F29
	ld (text_colour),a                     ; 3F2B
	ld hl,8161h                            ; 3F2E
	ld de,0000h                            ; 3F31
time_left        equ $-2
	call print_num                         ; 3F34
L3F37:	pop af                           ; 3F37
	ld (L3EE9),a                           ; 3F38
	pop af                                 ; 3F3B
	ld (text_colour),a                     ; 3F3C
	pop af                                 ; 3F3F
	pop de                                 ; 3F40
	pop hl                                 ; 3F41
	ret                                    ; 3F42
L3F43:	push hl                          ; 3F43
	push de                                ; 3F44
	push bc                                ; 3F45
	push af                                ; 3F46
	ld b,0Dh                               ; 3F47
	ld a,00h                               ; 3F49
L3F4A            equ $-1
	and a                                  ; 3F4B
	ld hl,828Dh                            ; 3F4C
	jp z,L3F6C                             ; 3F4F
	ld de,L6ACD                            ; 3F52
	cp 0Dh                                 ; 3F55
	jp c,L3F5C                             ; 3F57
	ld a,0Dh                               ; 3F5A
L3F5C:	push af                          ; 3F5C
	ld c,a                                 ; 3F5D
	ld b,a                                 ; 3F5E
L3F5F:	call put8x8                      ; 3F5F
	inc hl                                 ; 3F62
	djnz L3F5F                             ; 3F63
	pop af                                 ; 3F65
	jr nc,L3F72                            ; 3F66
	ld a,0Dh                               ; 3F68
	sub c                                  ; 3F6A
	ld b,a                                 ; 3F6B
L3F6C:	call clr8                        ; 3F6C
	inc hl                                 ; 3F6F
	djnz L3F6C                             ; 3F70
L3F72:	pop af                           ; 3F72
	pop bc                                 ; 3F73
	pop de                                 ; 3F74
	pop hl                                 ; 3F75
	ret                                    ; 3F76
L3F77:	defb 00h,00h                     ; 3F77
L3F79:	ld a,(L425D)                     ; 3F79
	or a                                   ; 3F7C
	ret z                                  ; 3F7D
	ld a,40h                               ; 3F7E
	ld (L425C),a                           ; 3F80
	ld ix,L425E                            ; 3F83
	ld a,(L425D)                           ; 3F87
L3F8A:	push af                          ; 3F8A
	ld a,(ix+1)                            ; 3F8B
	and a                                  ; 3F8E
	jp z,L412E                             ; 3F8F
	ld a,(ix+5)                            ; 3F92
	and a                                  ; 3F95
	jp nz,L415E                            ; 3F96
	ld a,(ix+4)                            ; 3F99
	and a                                  ; 3F9C
	jp z,L3FCA                             ; 3F9D
	xor a                                  ; 3FA0
	ld (ix+4),a                            ; 3FA1
	ld a,(ix+2)                            ; 3FA4
	dec a                                  ; 3FA7
	jr z,L3FB2                             ; 3FA8
	dec a                                  ; 3FAA
	jr z,L3FB8                             ; 3FAB
	dec a                                  ; 3FAD
	jr z,L3FBE                             ; 3FAE
	jr L3FC4                               ; 3FB0
L3FB2:	call L42E6                       ; 3FB2
	jp L411C                               ; 3FB5
L3FB8:	call L431D                       ; 3FB8
	jp L411C                               ; 3FBB
L3FBE:	call L4352                       ; 3FBE
	jp L411C                               ; 3FC1
L3FC4:	call L4378                       ; 3FC4
	jp L411C                               ; 3FC7
L3FCA:	ld l,(ix+0)                      ; 3FCA
	ld h,(ix+1)                            ; 3FCD
	dec h                                  ; 3FD0
	call map_addr                          ; 3FD1
	ld c,(hl)                              ; 3FD4
	inc hl                                 ; 3FD5
	ld b,(hl)                              ; 3FD6
	ld (L42DE),bc                          ; 3FD7
	ld de,0026h                            ; 3FDB
	add hl,de                              ; 3FDE
	ld c,(hl)                              ; 3FDF
	inc hl                                 ; 3FE0
	inc hl                                 ; 3FE1
	inc hl                                 ; 3FE2
	ld a,(hl)                              ; 3FE3
	ld e,25h                               ; 3FE4
	add hl,de                              ; 3FE6
	ld b,(hl)                              ; 3FE7
	ld (L42E2),bc                          ; 3FE8
	ld c,a                                 ; 3FEC
	inc hl                                 ; 3FED
	inc hl                                 ; 3FEE
	inc hl                                 ; 3FEF
	ld b,(hl)                              ; 3FF0
	ld (L42E4),bc                          ; 3FF1
	ld de,0026h                            ; 3FF5
	add hl,de                              ; 3FF8
	ld c,(hl)                              ; 3FF9
	inc hl                                 ; 3FFA
	ld b,(hl)                              ; 3FFB
	ld (L42E0),bc                          ; 3FFC
	ld a,(ix+2)                            ; 4000
	and a                                  ; 4003
	call z,L4414                           ; 4004
	ld a,(ix+2)                            ; 4007
	cp 03h                                 ; 400A
	jr nc,L405E                            ; 400C
	ld a,(L5029)                           ; 400E
	sub (ix+0)                             ; 4011
	jr z,L4038                             ; 4014
L4016:	jr c,L4028                       ; 4016
	ld hl,(L42E4)                          ; 4018
	call L4420                             ; 401B
	jp nz,L40B2                            ; 401E
	ld (ix+2),04h                          ; 4021
	jp L40B2                               ; 4025
L4028:	ld hl,(L42E2)                    ; 4028
	call L4420                             ; 402B
	jp nz,L40B2                            ; 402E
	ld (ix+2),03h                          ; 4031
	jp L40B2                               ; 4035
L4038:	ld a,(L502A)                     ; 4038
	sub (ix+1)                             ; 403B
	push af                                ; 403E
	jr nc,L4043                            ; 403F
	neg                                    ; 4041
L4043:	cp 06h                           ; 4043
	jr nc,L4053                            ; 4045
	call random                            ; 4047
	cp 08h                                 ; 404A
	jp c,L40AB                             ; 404C
	pop af                                 ; 404F
	jp L4066                               ; 4050
L4053:	call random                      ; 4053
	cp 10h                                 ; 4056
	jp c,L40AB                             ; 4058
	pop af                                 ; 405B
	jr L4066                               ; 405C
L405E:	ld a,(L502A)                     ; 405E
	sub (ix+1)                             ; 4061
	jr z,L4084                             ; 4064
L4066:	jr c,L4076                       ; 4066
	ld hl,(L42E0)                          ; 4068
	call L4420                             ; 406B
	jr nz,L40B2                            ; 406E
	ld (ix+2),02h                          ; 4070
	jr L40B2                               ; 4074
L4076:	ld hl,(L42DE)                    ; 4076
	call L4420                             ; 4079
	jr nz,L40B2                            ; 407C
	ld (ix+2),01h                          ; 407E
	jr L40B2                               ; 4082
L4084:	ld a,(L5029)                     ; 4084
	sub (ix+0)                             ; 4087
	push af                                ; 408A
	jr nc,L408F                            ; 408B
	neg                                    ; 408D
L408F:	cp 06h                           ; 408F
	jr nc,L409F                            ; 4091
	call random                            ; 4093
	cp 08h                                 ; 4096
	jp c,L40AB                             ; 4098
	pop af                                 ; 409B
	jp L4016                               ; 409C
L409F:	call random                      ; 409F
	cp 10h                                 ; 40A2
	jp c,L40AB                             ; 40A4
	pop af                                 ; 40A7
	jp L4016                               ; 40A8
L40AB:	call L4414                       ; 40AB
	pop af                                 ; 40AE
	jp L40B2                               ; 40AF
L40B2:	call random                      ; 40B2
	cp 0Ah                                 ; 40B5
	call c,L4414                           ; 40B7
	ld a,(ix+2)                            ; 40BA
	dec a                                  ; 40BD
	jr z,L40C8                             ; 40BE
	dec a                                  ; 40C0
	jr z,L40DA                             ; 40C1
	dec a                                  ; 40C3
	jr z,L40EC                             ; 40C4
	jr L40FE                               ; 40C6
L40C8:	ld hl,(L42DE)                    ; 40C8
	call L4420                             ; 40CB
	jr nz,L40D5                            ; 40CE
	call L42FF                             ; 40D0
	jr L4118                               ; 40D3
L40D5:	call L42F3                       ; 40D5
	jr L410E                               ; 40D8
L40DA:	ld hl,(L42E0)                    ; 40DA
	call L4420                             ; 40DD
	jr nz,L40E7                            ; 40E0
	call L4335                             ; 40E2
	jr L4118                               ; 40E5
L40E7:	call L4329                       ; 40E7
	jr L410E                               ; 40EA
L40EC:	ld hl,(L42E2)                    ; 40EC
	call L4420                             ; 40EF
	jr nz,L40F9                            ; 40F2
	call L436B                             ; 40F4
	jr L4118                               ; 40F7
L40F9:	call L435F                       ; 40F9
	jr L410E                               ; 40FC
L40FE:	ld hl,(L42E4)                    ; 40FE
	call L4420                             ; 4101
	jr nz,L410B                            ; 4104
	call L4390                             ; 4106
	jr L4118                               ; 4109
L410B:	call L4384                       ; 410B
L410E:	ld (ix+2),00h                    ; 410E
	ld (ix+4),00h                          ; 4112
	jr L411C                               ; 4116
L4118:	ld (ix+4),01h                    ; 4118
L411C:	ld de,0008h                      ; 411C
	add ix,de                              ; 411F
	ld a,(L425C)                           ; 4121
	inc a                                  ; 4124
	ld (L425C),a                           ; 4125
	pop af                                 ; 4128
	dec a                                  ; 4129
	jp nz,L3F8A                            ; 412A
	ret                                    ; 412D
L412E:	ld a,(ix+0)                      ; 412E
	cp 08h                                 ; 4131
	jp z,L4140                             ; 4133
	jp nc,L411C                            ; 4136
	inc a                                  ; 4139
	ld (ix+0),a                            ; 413A
	jp L411C                               ; 413D
L4140:	inc a                            ; 4140
	ld (ix+0),a                            ; 4141
	ld l,(ix+6)                            ; 4144
	ld h,(ix+7)                            ; 4147
	inc h                                  ; 414A
	push hl                                ; 414B
	call map_addr                          ; 414C
	ld c,00h                               ; 414F
	ld (hl),c                              ; 4151
	inc hl                                 ; 4152
	ld (hl),c                              ; 4153
	pop hl                                 ; 4154
	call vaddr_field                       ; 4155
	call clr16x8                           ; 4158
	jp L411C                               ; 415B
L415E:	cp 01h                           ; 415E
	jr z,L4188                             ; 4160
	cp 02h                                 ; 4162
	jr z,L419C                             ; 4164
	cp 03h                                 ; 4166
	jr z,L41A2                             ; 4168
	cp 04h                                 ; 416A
	jr z,L41A8                             ; 416C
	cp 05h                                 ; 416E
	jr z,L41AE                             ; 4170
	cp 18h                                 ; 4172
	jp c,L4252                             ; 4174
	jr z,L41C6                             ; 4177
	cp 92h                                 ; 4179
	jr c,L41B4                             ; 417B
	jr z,L41D9                             ; 417D
	cp 0A0h                                ; 417F
	jp c,L4252                             ; 4181
	xor a                                  ; 4184
	jp L4256                               ; 4185
L4188:	ld a,(ix+4)                      ; 4188
	or a                                   ; 418B
	call nz,L41E3                          ; 418C
	ld (ix+2),00h                          ; 418F
	call L422F                             ; 4193
	ld de,L692D                            ; 4196
	jp L4246                               ; 4199
L419C:	ld de,L696D                      ; 419C
	jp L4246                               ; 419F
L41A2:	ld de,L69AD                      ; 41A2
	jp L4246                               ; 41A5
L41A8:	ld de,L69ED                      ; 41A8
	jp L4246                               ; 41AB
L41AE:	ld de,L65ED                      ; 41AE
	jp L4246                               ; 41B1
L41B4:	ld a,(ix+4)                      ; 41B4
	cp 0Ch                                 ; 41B7
	jr z,L41D0                             ; 41B9
	cp 18h                                 ; 41BB
	jr z,L41C6                             ; 41BD
	inc a                                  ; 41BF
	ld (ix+4),a                            ; 41C0
	jp L4252                               ; 41C3
L41C6:	ld (ix+4),00h                    ; 41C6
	ld de,L6A6D                            ; 41CA
	jp L4246                               ; 41CD
L41D0:	inc a                            ; 41D0
	ld (ix+4),a                            ; 41D1
	ld de,L6A2D                            ; 41D4
	jr L4246                               ; 41D7
L41D9:	xor a                            ; 41D9
	ld (ix+4),a                            ; 41DA
	ld de,L65ED                            ; 41DD
	jp L4246                               ; 41E0
L41E3:	ld l,(ix+0)                      ; 41E3
	ld h,(ix+1)                            ; 41E6
	ld a,(ix+2)                            ; 41E9
	dec a                                  ; 41EC
	jr z,L41F7                             ; 41ED
	dec a                                  ; 41EF
	jr z,L4204                             ; 41F0
	dec a                                  ; 41F2
	jr z,L4213                             ; 41F3
	jr L4220                               ; 41F5
L41F7:	ld a,(ix+7)                      ; 41F7
	sub (ix+1)                             ; 41FA
	jp c,L42E6                             ; 41FD
	dec h                                  ; 4200
	jp L43EF                               ; 4201
L4204:	ld a,(ix+1)                      ; 4204
	inc a                                  ; 4207
	sub (ix+7)                             ; 4208
	jp c,L431D                             ; 420B
	inc h                                  ; 420E
	inc h                                  ; 420F
	jp L43EF                               ; 4210
L4213:	ld a,(ix+6)                      ; 4213
	sub (ix+0)                             ; 4216
	jp c,L4352                             ; 4219
	dec l                                  ; 421C
	jp L4400                               ; 421D
L4220:	ld a,(ix+0)                      ; 4220
	inc a                                  ; 4223
	sub (ix+6)                             ; 4224
	jp c,L4378                             ; 4227
	inc l                                  ; 422A
	inc l                                  ; 422B
	jp L4400                               ; 422C
L422F:	ld l,(ix+0)                      ; 422F
	ld h,(ix+1)                            ; 4232
	call map_addr                          ; 4235
	ld a,(L425C)                           ; 4238
	ld (hl),a                              ; 423B
	inc hl                                 ; 423C
	ld (hl),a                              ; 423D
	ld de,0027h                            ; 423E
	add hl,de                              ; 4241
	ld (hl),a                              ; 4242
	inc hl                                 ; 4243
	ld (hl),a                              ; 4244
	ret                                    ; 4245
L4246:	ld l,(ix+0)                      ; 4246
	ld h,(ix+1)                            ; 4249
	call vaddr_field                       ; 424C
	call put16x16                          ; 424F
L4252:	ld a,(ix+5)                      ; 4252
	inc a                                  ; 4255
L4256:	ld (ix+5),a                      ; 4256
	jp L411C                               ; 4259
L425C:	defb 00h                         ; 425C
L425D:	defb 00h                         ; 425D
L425E:	defs 126                         ; 425E
	defb 0DDh,6Eh                          ; 42DC
L42DE:	defb 00h,00h                     ; 42DE
L42E0:	defb 00h,00h                     ; 42E0
L42E2:	defb 00h,00h                     ; 42E2
L42E4:	defb 00h,00h                     ; 42E4
L42E6:	ld l,(ix+0)                      ; 42E6
	ld h,(ix+1)                            ; 42E9
	inc h                                  ; 42EC
	call L43EF                             ; 42ED
	dec (ix+1)                             ; 42F0
L42F3:	ld l,(ix+0)                      ; 42F3
	ld h,(ix+1)                            ; 42F6
	ld de,L66ED                            ; 42F9
	jp L439C                               ; 42FC
L42FF:	ld l,(ix+0)                      ; 42FF
	ld h,(ix+1)                            ; 4302
	dec h                                  ; 4305
	ld a,(ix+3)                            ; 4306
	cpl                                    ; 4309
	ld (ix+3),a                            ; 430A
	or a                                   ; 430D
	jp z,L4317                             ; 430E
	ld de,L672D                            ; 4311
	jp L43B5                               ; 4314
L4317:	ld de,L678D                      ; 4317
	jp L43B5                               ; 431A
L431D:	ld l,(ix+0)                      ; 431D
	ld h,(ix+1)                            ; 4320
	call L43EF                             ; 4323
	inc (ix+1)                             ; 4326
L4329:	ld l,(ix+0)                      ; 4329
	ld h,(ix+1)                            ; 432C
	ld de,L65ED                            ; 432F
	jp L439C                               ; 4332
L4335:	ld l,(ix+0)                      ; 4335
	ld h,(ix+1)                            ; 4338
	ld a,(ix+3)                            ; 433B
	cpl                                    ; 433E
	ld (ix+3),a                            ; 433F
	or a                                   ; 4342
	jp z,L434C                             ; 4343
	ld de,L662D                            ; 4346
	jp L43B5                               ; 4349
L434C:	ld de,L668D                      ; 434C
	jp L43B5                               ; 434F
L4352:	ld l,(ix+0)                      ; 4352
	ld h,(ix+1)                            ; 4355
	inc l                                  ; 4358
	call L4400                             ; 4359
	dec (ix+0)                             ; 435C
L435F:	ld de,L688D                      ; 435F
	ld l,(ix+0)                            ; 4362
	ld h,(ix+1)                            ; 4365
	jp L439C                               ; 4368
L436B:	ld de,L68CD                      ; 436B
	ld l,(ix+0)                            ; 436E
	ld h,(ix+1)                            ; 4371
	dec l                                  ; 4374
	jp L43D2                               ; 4375
L4378:	ld l,(ix+0)                      ; 4378
	ld h,(ix+1)                            ; 437B
	call L4400                             ; 437E
	inc (ix+0)                             ; 4381
L4384:	ld de,L67ED                      ; 4384
	ld l,(ix+0)                            ; 4387
	ld h,(ix+1)                            ; 438A
	jp L439C                               ; 438D
L4390:	ld de,L682D                      ; 4390
	ld l,(ix+0)                            ; 4393
	ld h,(ix+1)                            ; 4396
	jp L43D2                               ; 4399
L439C:	push hl                          ; 439C
	call vaddr_field                       ; 439D
	call put16x16                          ; 43A0
	pop hl                                 ; 43A3
	call map_addr                          ; 43A4
	ld de,0027h                            ; 43A7
	ld a,(L425C)                           ; 43AA
	ld (hl),a                              ; 43AD
	inc hl                                 ; 43AE
	ld (hl),a                              ; 43AF
	add hl,de                              ; 43B0
	ld (hl),a                              ; 43B1
	inc hl                                 ; 43B2
	ld (hl),a                              ; 43B3
	ret                                    ; 43B4
L43B5:	push hl                          ; 43B5
	call vaddr_field                       ; 43B6
	call put16x24                          ; 43B9
	pop hl                                 ; 43BC
	call map_addr                          ; 43BD
	ld de,0027h                            ; 43C0
	ld a,(L425C)                           ; 43C3
	ld (hl),a                              ; 43C6
	inc hl                                 ; 43C7
	ld (hl),a                              ; 43C8
	add hl,de                              ; 43C9
	ld (hl),a                              ; 43CA
	inc hl                                 ; 43CB
	ld (hl),a                              ; 43CC
	add hl,de                              ; 43CD
	ld (hl),a                              ; 43CE
	inc hl                                 ; 43CF
	ld (hl),a                              ; 43D0
	ret                                    ; 43D1
L43D2:	push hl                          ; 43D2
	call vaddr_field                       ; 43D3
	call put24x16                          ; 43D6
	pop hl                                 ; 43D9
	call map_addr                          ; 43DA
	ld de,0026h                            ; 43DD
	ld a,(L425C)                           ; 43E0
	ld (hl),a                              ; 43E3
	inc hl                                 ; 43E4
	ld (hl),a                              ; 43E5
	inc hl                                 ; 43E6
	ld (hl),a                              ; 43E7
	add hl,de                              ; 43E8
	ld (hl),a                              ; 43E9
	inc hl                                 ; 43EA
	ld (hl),a                              ; 43EB
	inc hl                                 ; 43EC
	ld (hl),a                              ; 43ED
	ret                                    ; 43EE
L43EF:	push hl                          ; 43EF
	call vaddr_field                       ; 43F0
	call clr16x8                           ; 43F3
	pop hl                                 ; 43F6
	call map_addr                          ; 43F7
	ld a,00h                               ; 43FA
	ld (hl),a                              ; 43FC
	inc hl                                 ; 43FD
	ld (hl),a                              ; 43FE
	ret                                    ; 43FF
L4400:	push hl                          ; 4400
	call vaddr_field                       ; 4401
	call clr8x16                           ; 4404
	pop hl                                 ; 4407
	call map_addr                          ; 4408
	ld a,00h                               ; 440B
	ld de,0028h                            ; 440D
	ld (hl),a                              ; 4410
	add hl,de                              ; 4411
	ld (hl),a                              ; 4412
	ret                                    ; 4413
L4414:	push af                          ; 4414
	call random                            ; 4415
	and 03h                                ; 4418
	inc a                                  ; 441A
	ld (ix+2),a                            ; 441B
	pop af                                 ; 441E
	ret                                    ; 441F
L4420:	xor a                            ; 4420
	ld (L4463),a                           ; 4421
	ld (L4464),a                           ; 4424
	ld a,h                                 ; 4427
	call L444C                             ; 4428
	ld a,l                                 ; 442B
	call L444C                             ; 442C
	ld a,(L4463)                           ; 442F
	and a                                  ; 4432
	jp z,L4447                             ; 4433
	ld a,(L4464)                           ; 4436
	and a                                  ; 4439
	ret nz                                 ; 443A
	ld a,(player_state)                    ; 443B
	and a                                  ; 443E
	ret nz                                 ; 443F
	ld a,01h                               ; 4440
	ld (player_state),a                    ; 4442
	and a                                  ; 4445
	ret                                    ; 4446
L4447:	ld a,(L4464)                     ; 4447
	and a                                  ; 444A
	ret                                    ; 444B
L444C:	and 0F0h                         ; 444C
	cp 20h                                 ; 444E
	jp c,L4461                             ; 4450
	jr z,L445B                             ; 4453
	ld a,01h                               ; 4455
	ld (L4464),a                           ; 4457
	ret                                    ; 445A
L445B:	ld a,01h                         ; 445B
	ld (L4463),a                           ; 445D
	ret                                    ; 4460
L4461:	xor a                            ; 4461
	ret                                    ; 4462
L4463:	defb 00h                         ; 4463
L4464:	defb 00h                         ; 4464
L4465:	ld a,(L46EB)                     ; 4465
	and a                                  ; 4468
	ret z                                  ; 4469
	ld a,(L5028)                           ; 446A
	cp 05h                                 ; 446D
	call z,L465F                           ; 446F
	ld a,10h                               ; 4472
	ld (L46EA),a                           ; 4474
	ld ix,L46EC                            ; 4477
	ld a,(L46EB)                           ; 447B
L447E:	push af                          ; 447E
	ld a,(ix+3)                            ; 447F
	cp 03h                                 ; 4482
	jp z,L45C6                             ; 4484
	cp 01h                                 ; 4487
	jp z,L45C6                             ; 4489
	ld l,(ix+0)                            ; 448C
	ld h,(ix+1)                            ; 448F
	ld (L473C),hl                          ; 4492
	ld (L473E),hl                          ; 4495
	ld (L4742),hl                          ; 4498
	call map_addr                          ; 449B
	ld a,(hl)                              ; 449E
	ld (L4744),a                           ; 449F
	ld (L4745),a                           ; 44A2
	ld c,a                                 ; 44A5
	ld a,(ix+3)                            ; 44A6
	cp 02h                                 ; 44A9
	jp z,L452A                             ; 44AB
	ld hl,(L473C)                          ; 44AE
	ld (L4740),hl                          ; 44B1
	ld a,c                                 ; 44B4
	and 0F0h                               ; 44B5
	cp 20h                                 ; 44B7
	jp z,L45DF                             ; 44B9
	cp 50h                                 ; 44BC
	jp nc,L45D8                            ; 44BE
	ld a,(ix+4)                            ; 44C1
	and a                                  ; 44C4
	jp z,L455E                             ; 44C5
	ld a,(L4744)                           ; 44C8
	ld c,a                                 ; 44CB
	and 0F0h                               ; 44CC
	cp 40h                                 ; 44CE
	jp z,L461F                             ; 44D0
	cp 30h                                 ; 44D3
	jp z,L45FE                             ; 44D5
	dec (ix+4)                             ; 44D8
	jp z,L455E                             ; 44DB
	ld a,(ix+2)                            ; 44DE
	dec a                                  ; 44E1
	jr z,L44EB                             ; 44E2
	dec a                                  ; 44E4
	dec a                                  ; 44E5
	jr z,L44F1                             ; 44E6
	jp L44F7                               ; 44E8
L44EB:	dec (ix+1)                       ; 44EB
	jp L44FA                               ; 44EE
L44F1:	dec (ix+0)                       ; 44F1
	jp L44FA                               ; 44F4
L44F7:	inc (ix+0)                       ; 44F7
L44FA:	ld l,(ix+0)                      ; 44FA
	ld h,(ix+1)                            ; 44FD
	ld (L473E),hl                          ; 4500
	call map_addr                          ; 4503
	ld a,(hl)                              ; 4506
	ld (L4745),a                           ; 4507
	ld hl,(L473E)                          ; 450A
	ld (L4740),hl                          ; 450D
	ld c,a                                 ; 4510
	and 0F0h                               ; 4511
	cp 20h                                 ; 4513
	jp z,L45DF                             ; 4515
	cp 30h                                 ; 4518
	jp z,L45FE                             ; 451A
	cp 40h                                 ; 451D
	jp z,L461F                             ; 451F
	cp 50h                                 ; 4522
	jp nc,L4551                            ; 4524
	jp L45C0                               ; 4527
L452A:	ld (ix+3),00h                    ; 452A
	ld hl,(L473C)                          ; 452E
	ld (L4740),hl                          ; 4531
	ld a,(L4744)                           ; 4534
	ld c,a                                 ; 4537
	and 0F0h                               ; 4538
	cp 30h                                 ; 453A
	jp z,L45FE                             ; 453C
	cp 40h                                 ; 453F
	jp z,L461F                             ; 4541
	cp 00h                                 ; 4544
	jp z,L45C3                             ; 4546
	cp 10h                                 ; 4549
	jp z,L45C3                             ; 454B
	jp L45DF                               ; 454E
L4551:	ld hl,(L473C)                    ; 4551
	ld (ix+0),l                            ; 4554
	ld (ix+1),h                            ; 4557
	ld (ix+4),00h                          ; 455A
L455E:	ld hl,(L473C)                    ; 455E
	ld (L4740),hl                          ; 4561
	inc h                                  ; 4564
	inc (ix+1)                             ; 4565
	ld (L473E),hl                          ; 4568
	call map_addr                          ; 456B
	ld a,(hl)                              ; 456E
	ld (L4745),a                           ; 456F
	ld hl,(L473E)                          ; 4572
	ld (L4740),hl                          ; 4575
	ld c,a                                 ; 4578
	and 0F0h                               ; 4579
	cp 50h                                 ; 457B
	jr nc,L45A7                            ; 457D
	cp 20h                                 ; 457F
	jp z,L45DF                             ; 4581
	cp 30h                                 ; 4584
	jp z,L45FE                             ; 4586
	cp 40h                                 ; 4589
	jp z,L461F                             ; 458B
	ld hl,(L473C)                          ; 458E
	ld (L4740),hl                          ; 4591
	ld a,(L4744)                           ; 4594
	ld c,a                                 ; 4597
	and 0F0h                               ; 4598
	cp 30h                                 ; 459A
	jp z,L45FE                             ; 459C
	cp 40h                                 ; 459F
	jp z,L461F                             ; 45A1
	jp L45C0                               ; 45A4
L45A7:	ld hl,(L473C)                    ; 45A7
	ld (L473E),hl                          ; 45AA
	ld (ix+0),l                            ; 45AD
	ld (ix+1),h                            ; 45B0
	ld a,(L4744)                           ; 45B3
	and 0F0h                               ; 45B6
	cp 00h                                 ; 45B8
	call z,L46D3                           ; 45BA
	jp L45C6                               ; 45BD
L45C0:	call L46C2                       ; 45C0
L45C3:	call L46D3                       ; 45C3
L45C6:	ld de,0005h                      ; 45C6
	add ix,de                              ; 45C9
	ld a,(L46EA)                           ; 45CB
	inc a                                  ; 45CE
	ld (L46EA),a                           ; 45CF
	pop af                                 ; 45D2
	dec a                                  ; 45D3
	jp nz,L447E                            ; 45D4
	ret                                    ; 45D7
L45D8:	ld (ix+3),03h                    ; 45D8
	jp L45C6                               ; 45DC
L45DF:	ld hl,(L4742)                    ; 45DF
	call map_addr                          ; 45E2
	ld a,(hl)                              ; 45E5
	and 0F0h                               ; 45E6
	cp 10h                                 ; 45E8
	call z,L46C2                           ; 45EA
	ld (ix+3),01h                          ; 45ED
	ld a,(L3F4A)                           ; 45F1
	inc a                                  ; 45F4
	ld (L3F4A),a                           ; 45F5
	call L3F43                             ; 45F8
	jp L45C6                               ; 45FB
L45FE:	ld hl,(L4742)                    ; 45FE
	call map_addr                          ; 4601
	ld a,(hl)                              ; 4604
	and 0F0h                               ; 4605
	cp 10h                                 ; 4607
	call z,L46C2                           ; 4609
	ld (ix+3),03h                          ; 460C
	ld a,c                                 ; 4610
	and 0Fh                                ; 4611
	ld hl,L5094                            ; 4613
	ld d,00h                               ; 4616
	ld e,a                                 ; 4618
	add hl,de                              ; 4619
	ld (hl),02h                            ; 461A
	jp L45C6                               ; 461C
L461F:	ld hl,(L4742)                    ; 461F
	call map_addr                          ; 4622
	ld a,(hl)                              ; 4625
	and 0F0h                               ; 4626
	cp 10h                                 ; 4628
	call z,L46C2                           ; 462A
	ld (ix+3),03h                          ; 462D
	ld a,c                                 ; 4631
	and 0Fh                                ; 4632
	ld iy,L425E                            ; 4634
	jp z,L4643                             ; 4638
	ld de,0008h                            ; 463B
	ld b,a                                 ; 463E
L463F:	add iy,de                        ; 463F
	djnz L463F                             ; 4641
L4643:	ld a,(iy+5)                      ; 4643
	cp 02h                                 ; 4646
	jp c,L464F                             ; 4648
	ld (iy+4),00h                          ; 464B
L464F:	ld (iy+5),01h                    ; 464F
	ld hl,(L4740)                          ; 4653
	ld (iy+6),l                            ; 4656
	ld (iy+7),h                            ; 4659
	jp L45C6                               ; 465C
L465F:	ld ix,L46EC                      ; 465F
	ld de,0005h                            ; 4663
	ld a,(L46EB)                           ; 4666
	and a                                  ; 4669
	ret z                                  ; 466A
	ld b,a                                 ; 466B
L466C:	ld a,(ix+3)                      ; 466C
	cp 01h                                 ; 466F
	jp z,L4679                             ; 4671
	add ix,de                              ; 4674
	djnz L466C                             ; 4676
	ret                                    ; 4678
L4679:	ld a,(L3F4A)                     ; 4679
	dec a                                  ; 467C
	ld (L3F4A),a                           ; 467D
	call L3F43                             ; 4680
	ld hl,(L5029)                          ; 4683
	ld a,(L5031)                           ; 4686
	ld (ix+2),a                            ; 4689
	dec a                                  ; 468C
	jr z,L4697                             ; 468D
	dec a                                  ; 468F
	jr z,L46A0                             ; 4690
	dec a                                  ; 4692
	jr z,L46A9                             ; 4693
	jr L46B1                               ; 4695
L4697:	dec h                            ; 4697
	inc l                                  ; 4698
	ld (ix+4),06h                          ; 4699
	jp L46B7                               ; 469D
L46A0:	inc h                            ; 46A0
	inc h                                  ; 46A1
	ld (ix+4),00h                          ; 46A2
	jp L46B7                               ; 46A6
L46A9:	dec l                            ; 46A9
	ld (ix+4),0Fh                          ; 46AA
	jp L46B7                               ; 46AE
L46B1:	inc l                            ; 46B1
	inc l                                  ; 46B2
	ld (ix+4),0Fh                          ; 46B3
L46B7:	ld (ix+3),02h                    ; 46B7
	ld (ix+0),l                            ; 46BB
	ld (ix+1),h                            ; 46BE
	ret                                    ; 46C1
L46C2:	ld hl,(L473C)                    ; 46C2
	call map_addr                          ; 46C5
	ld (hl),00h                            ; 46C8
	ld hl,(L473C)                          ; 46CA
	call vaddr_field                       ; 46CD
	jp clr8                                ; 46D0
L46D3:	ld hl,(L473E)                    ; 46D3
	call vaddr_field                       ; 46D6
	ld de,L6ACD                            ; 46D9
	call put8x8                            ; 46DC
	ld hl,(L473E)                          ; 46DF
	call map_addr                          ; 46E2
	ld a,(L46EA)                           ; 46E5
	ld (hl),a                              ; 46E8
	ret                                    ; 46E9
L46EA:	defb 00h                         ; 46EA
L46EB:	defb 00h                         ; 46EB
L46EC:	defs 80                          ; 46EC
L473C:	defb 00h,00h                     ; 473C
L473E:	defb 00h,00h                     ; 473E
L4740:	defb 00h,00h                     ; 4740
L4742:	defb 00h,00h                     ; 4742
L4744:	defb 00h                         ; 4744
L4745:	defb 00h,00h                     ; 4745
L4747:	ld a,(player_state)              ; 4747
	and a                                  ; 474A
	jp m,L4CA1                             ; 474B
	jp nz,L4C55                            ; 474E
	ld a,(L5028)                           ; 4751
	and a                                  ; 4754
	jp z,L4B79                             ; 4755
	dec a                                  ; 4758
	jp nz,L482B                            ; 4759
	ld hl,(L502B)                          ; 475C
	ld de,0028h                            ; 475F
	and a                                  ; 4762
	sbc hl,de                              ; 4763
	ld a,(hl)                              ; 4765
	ld b,a                                 ; 4766
	inc hl                                 ; 4767
	cp 70h                                 ; 4768
	jp nc,L4B67                            ; 476A
	cp 50h                                 ; 476D
	jp nc,L4798                            ; 476F
	cp 20h                                 ; 4772
	jp nc,L478A                            ; 4774
	ld a,(hl)                              ; 4777
	cp 70h                                 ; 4778
	jp nc,L4B67                            ; 477A
	cp 50h                                 ; 477D
	jp nc,L47AF                            ; 477F
	cp 20h                                 ; 4782
	jp nc,L4CDC                            ; 4784
	jp L47FE                               ; 4787
L478A:	ld a,(hl)                        ; 478A
	cp 70h                                 ; 478B
	jp nc,L4B67                            ; 478D
	cp 50h                                 ; 4790
	jp nc,L47BE                            ; 4792
	jp L4CDC                               ; 4795
L4798:	ld a,(hl)                        ; 4798
	cp 70h                                 ; 4799
	jp nc,L4B67                            ; 479B
	cp 50h                                 ; 479E
	jp nc,L47E2                            ; 47A0
	cp 20h                                 ; 47A3
	jp nc,L47CC                            ; 47A5
	ld hl,(L502B)                          ; 47A8
	dec hl                                 ; 47AB
	jp L47B5                               ; 47AC
L47AF:	ld hl,(L502B)                    ; 47AF
	inc hl                                 ; 47B2
	inc hl                                 ; 47B3
	ld b,a                                 ; 47B4
L47B5:	ld a,(hl)                        ; 47B5
	cp 50h                                 ; 47B6
	call nc,L4CC0                          ; 47B8
	jp L4B67                               ; 47BB
L47BE:	cp 60h                           ; 47BE
	jp nc,L4B67                            ; 47C0
	ld hl,(L502B)                          ; 47C3
	inc hl                                 ; 47C6
	inc hl                                 ; 47C7
	ld b,a                                 ; 47C8
	jp L47D6                               ; 47C9
L47CC:	ld a,b                           ; 47CC
	cp 60h                                 ; 47CD
	jp nc,L4B67                            ; 47CF
	ld hl,(L502B)                          ; 47D2
	dec hl                                 ; 47D5
L47D6:	ld a,(hl)                        ; 47D6
	cp 50h                                 ; 47D7
	jp c,L4B67                             ; 47D9
	call L4CC0                             ; 47DC
	jp L4CDC                               ; 47DF
L47E2:	ld c,a                           ; 47E2
	xor b                                  ; 47E3
	jp z,L4B67                             ; 47E4
	ld hl,(L502B)                          ; 47E7
	dec hl                                 ; 47EA
	ld a,(hl)                              ; 47EB
	cp 50h                                 ; 47EC
	call nc,L4CC0                          ; 47EE
	ld b,c                                 ; 47F1
	inc hl                                 ; 47F2
	inc hl                                 ; 47F3
	inc hl                                 ; 47F4
	ld a,(hl)                              ; 47F5
	cp 50h                                 ; 47F6
	call nc,L4CC0                          ; 47F8
	jp L4B67                               ; 47FB
L47FE:	xor a                            ; 47FE
	ld (hl),20h                            ; 47FF
	dec hl                                 ; 4801
	ld (hl),20h                            ; 4802
	ld (L502B),hl                          ; 4804
	sla e                                  ; 4807
	add hl,de                              ; 4809
	ld (hl),a                              ; 480A
	inc hl                                 ; 480B
	ld (hl),a                              ; 480C
	ld hl,L502A                            ; 480D
	dec (hl)                               ; 4810
	ld a,(L5030)                           ; 4811
	neg                                    ; 4814
	ld (L5030),a                           ; 4816
	jp m,L4821                             ; 4819
	ld de,L5F9D                            ; 481C
	jr L4824                               ; 481F
L4821:	ld de,L5F5D                      ; 4821
L4824:	ld hl,(L502D)                    ; 4824
	call put16x16                          ; 4827
	ret                                    ; 482A
L482B:	dec a                            ; 482B
	jp nz,L4963                            ; 482C
	ld hl,(L502B)                          ; 482F
	ld de,0050h                            ; 4832
	add hl,de                              ; 4835
	ld a,(hl)                              ; 4836
	ld b,a                                 ; 4837
	inc hl                                 ; 4838
	cp 70h                                 ; 4839
	jp nc,L4B6B                            ; 483B
	cp 60h                                 ; 483E
	jp nc,L486E                            ; 4840
	cp 50h                                 ; 4843
	jp nc,L487D                            ; 4845
	cp 20h                                 ; 4848
	jp nc,L4860                            ; 484A
	ld a,(hl)                              ; 484D
	cp 60h                                 ; 484E
	jp nc,L4B6B                            ; 4850
	cp 50h                                 ; 4853
	jp nc,L48A7                            ; 4855
	cp 20h                                 ; 4858
	jp nc,L4CDC                            ; 485A
	jp L4926                               ; 485D
L4860:	ld a,(hl)                        ; 4860
	cp 60h                                 ; 4861
	jp nc,L4B6B                            ; 4863
	cp 50h                                 ; 4866
	jp nc,L48BC                            ; 4868
	jp L4CDC                               ; 486B
L486E:	ld a,(hl)                        ; 486E
	ld b,a                                 ; 486F
	cp 60h                                 ; 4870
	jp nc,L4B6B                            ; 4872
	cp 50h                                 ; 4875
	jp c,L4B6B                             ; 4877
	jp L48A7                               ; 487A
L487D:	ld a,(hl)                        ; 487D
	cp 70h                                 ; 487E
	jp nc,L4B6B                            ; 4880
	cp 60h                                 ; 4883
	jp nc,L4892                            ; 4885
	cp 50h                                 ; 4888
	jp nc,L48E6                            ; 488A
	cp 20h                                 ; 488D
	jp nc,L48D1                            ; 488F
L4892:	dec hl                           ; 4892
	add hl,de                              ; 4893
	ld a,(hl)                              ; 4894
	cp 50h                                 ; 4895
	jp nc,L48A1                            ; 4897
	dec hl                                 ; 489A
	ld a,(hl)                              ; 489B
	cp 50h                                 ; 489C
	jp c,L4B6B                             ; 489E
L48A1:	call L4CC0                       ; 48A1
	jp L4B6B                               ; 48A4
L48A7:	ld b,a                           ; 48A7
	add hl,de                              ; 48A8
	ld a,(hl)                              ; 48A9
	cp 50h                                 ; 48AA
	jp nc,L48B6                            ; 48AC
	inc hl                                 ; 48AF
	ld a,(hl)                              ; 48B0
	cp 50h                                 ; 48B1
	jp c,L4B6B                             ; 48B3
L48B6:	call L4CC0                       ; 48B6
	jp L4B6B                               ; 48B9
L48BC:	ld b,a                           ; 48BC
	add hl,de                              ; 48BD
	ld a,(hl)                              ; 48BE
	cp 50h                                 ; 48BF
	jp nc,L48CB                            ; 48C1
	inc hl                                 ; 48C4
	ld a,(hl)                              ; 48C5
	cp 50h                                 ; 48C6
	jp c,L4CDC                             ; 48C8
L48CB:	call L4CC0                       ; 48CB
	jp L4CDC                               ; 48CE
L48D1:	dec hl                           ; 48D1
	add hl,de                              ; 48D2
	ld a,(hl)                              ; 48D3
	cp 50h                                 ; 48D4
	jp nc,L48E0                            ; 48D6
	dec hl                                 ; 48D9
	ld a,(hl)                              ; 48DA
	cp 50h                                 ; 48DB
	jp c,L4CDC                             ; 48DD
L48E0:	call L4CC0                       ; 48E0
	jp L4CDC                               ; 48E3
L48E6:	ld c,a                           ; 48E6
	xor b                                  ; 48E7
	jp nz,L48FF                            ; 48E8
	add hl,de                              ; 48EB
	ld a,(hl)                              ; 48EC
	cp 50h                                 ; 48ED
	jp nc,L48F9                            ; 48EF
	dec hl                                 ; 48F2
	ld a,(hl)                              ; 48F3
	cp 50h                                 ; 48F4
	jp c,L4B6B                             ; 48F6
L48F9:	call L4CC0                       ; 48F9
	jp L4B6B                               ; 48FC
L48FF:	inc hl                           ; 48FF
	add hl,de                              ; 4900
	ld a,(hl)                              ; 4901
	cp 50h                                 ; 4902
	jp nc,L490E                            ; 4904
	dec hl                                 ; 4907
	ld a,(hl)                              ; 4908
	cp 50h                                 ; 4909
	jp c,L4911                             ; 490B
L490E:	call L4CC0                       ; 490E
L4911:	ld b,c                           ; 4911
	dec hl                                 ; 4912
	ld a,(hl)                              ; 4913
	cp 50h                                 ; 4914
	jp nc,L4920                            ; 4916
	dec hl                                 ; 4919
	ld a,(hl)                              ; 491A
	cp 50h                                 ; 491B
	jp c,L4B6B                             ; 491D
L4920:	call L4CC0                       ; 4920
	jp L4B6B                               ; 4923
L4926:	ld (hl),20h                      ; 4926
	dec hl                                 ; 4928
	ld (hl),20h                            ; 4929
	srl e                                  ; 492B
	xor a                                  ; 492D
	sbc hl,de                              ; 492E
	ld (L502B),hl                          ; 4930
	sbc hl,de                              ; 4933
	ld (hl),a                              ; 4935
	inc hl                                 ; 4936
	ld (hl),a                              ; 4937
	ld hl,L502A                            ; 4938
	inc (hl)                               ; 493B
	ld hl,(L502D)                          ; 493C
	call clr16x8                           ; 493F
	ld de,0140h                            ; 4942
	add hl,de                              ; 4945
	ld (L502D),hl                          ; 4946
	ld a,(L5030)                           ; 4949
	neg                                    ; 494C
	ld (L5030),a                           ; 494E
	jp m,L4959                             ; 4951
	ld de,L5E5D                            ; 4954
	jr L495C                               ; 4957
L4959:	ld de,L5E1D                      ; 4959
L495C:	ld hl,(L502D)                    ; 495C
	call put16x16                          ; 495F
	ret                                    ; 4962
L4963:	dec a                            ; 4963
	jp nz,L4A66                            ; 4964
	ld hl,(L502B)                          ; 4967
	dec hl                                 ; 496A
	ld a,(hl)                              ; 496B
	ld b,a                                 ; 496C
	ld de,0028h                            ; 496D
	add hl,de                              ; 4970
	cp 70h                                 ; 4971
	jp nc,L4B6F                            ; 4973
	cp 50h                                 ; 4976
	jp nc,L4997                            ; 4978
	cp 20h                                 ; 497B
	jp nc,L498E                            ; 497D
	ld a,(hl)                              ; 4980
	cp 50h                                 ; 4981
	jp nc,L4B6F                            ; 4983
	cp 20h                                 ; 4986
	jp nc,L4CDC                            ; 4988
	jp L4A40                               ; 498B
L498E:	ld a,(hl)                        ; 498E
	cp 50h                                 ; 498F
	jp nc,L4B6F                            ; 4991
	jp L4CDC                               ; 4994
L4997:	ld a,(hl)                        ; 4997
	cp 70h                                 ; 4998
	jp nc,L4B6F                            ; 499A
	cp 50h                                 ; 499D
	jp c,L4B6F                             ; 499F
	xor b                                  ; 49A2
	jp nz,L4B6F                            ; 49A3
	dec hl                                 ; 49A6
	dec hl                                 ; 49A7
	ld a,(hl)                              ; 49A8
	cp 20h                                 ; 49A9
	jp nc,L49B7                            ; 49AB
	and a                                  ; 49AE
	sbc hl,de                              ; 49AF
	ld a,(hl)                              ; 49B1
	cp 20h                                 ; 49B2
	jp c,L49BD                             ; 49B4
L49B7:	call L4CC0                       ; 49B7
	jp L4B6F                               ; 49BA
L49BD:	ld a,b                           ; 49BD
	cp 60h                                 ; 49BE
	jp nc,L4A04                            ; 49C0
	and 0Fh                                ; 49C3
	ld b,a                                 ; 49C5
	add a,a                                ; 49C6
	add a,a                                ; 49C7
	add a,a                                ; 49C8
	ld d,00h                               ; 49C9
	ld e,a                                 ; 49CB
	ld a,b                                 ; 49CC
	ex af,af'                              ; 49CD
	ld hl,L50AC                            ; 49CE
	add hl,de                              ; 49D1
	ld a,(hl)                              ; 49D2
	dec a                                  ; 49D3
	ld (hl),a                              ; 49D4
	inc hl                                 ; 49D5
	inc hl                                 ; 49D6
	ld e,(hl)                              ; 49D7
	inc hl                                 ; 49D8
	ld d,(hl)                              ; 49D9
	ex de,hl                               ; 49DA
	ld bc,0028h                            ; 49DB
	inc hl                                 ; 49DE
	xor a                                  ; 49DF
	ld (hl),a                              ; 49E0
	add hl,bc                              ; 49E1
	ld (hl),a                              ; 49E2
	and a                                  ; 49E3
	sbc hl,bc                              ; 49E4
	ex de,hl                               ; 49E6
	dec de                                 ; 49E7
	dec de                                 ; 49E8
	ld (hl),d                              ; 49E9
	dec hl                                 ; 49EA
	ld (hl),e                              ; 49EB
	ex de,hl                               ; 49EC
	ex af,af'                              ; 49ED
	or 50h                                 ; 49EE
	ld (hl),a                              ; 49F0
	add hl,bc                              ; 49F1
	ld (hl),a                              ; 49F2
	ex de,hl                               ; 49F3
	inc hl                                 ; 49F4
	inc hl                                 ; 49F5
	ld e,(hl)                              ; 49F6
	inc hl                                 ; 49F7
	ld d,(hl)                              ; 49F8
	dec de                                 ; 49F9
	ld (hl),d                              ; 49FA
	dec hl                                 ; 49FB
	ld (hl),e                              ; 49FC
	ex de,hl                               ; 49FD
	ld de,L5C9D                            ; 49FE
	jp L4A35                               ; 4A01
L4A04:	ld hl,L50A4                      ; 4A04
	ld a,(hl)                              ; 4A07
	dec a                                  ; 4A08
	ld (hl),a                              ; 4A09
	inc hl                                 ; 4A0A
	inc hl                                 ; 4A0B
	ld e,(hl)                              ; 4A0C
	inc hl                                 ; 4A0D
	ld d,(hl)                              ; 4A0E
	ex de,hl                               ; 4A0F
	ld bc,0028h                            ; 4A10
	inc hl                                 ; 4A13
	xor a                                  ; 4A14
	ld (hl),a                              ; 4A15
	add hl,bc                              ; 4A16
	ld (hl),a                              ; 4A17
	and a                                  ; 4A18
	sbc hl,bc                              ; 4A19
	ex de,hl                               ; 4A1B
	dec de                                 ; 4A1C
	dec de                                 ; 4A1D
	ld (hl),d                              ; 4A1E
	dec hl                                 ; 4A1F
	ld (hl),e                              ; 4A20
	ex de,hl                               ; 4A21
	ld a,60h                               ; 4A22
	ld (hl),a                              ; 4A24
	add hl,bc                              ; 4A25
	ld (hl),a                              ; 4A26
	ex de,hl                               ; 4A27
	inc hl                                 ; 4A28
	inc hl                                 ; 4A29
	ld e,(hl)                              ; 4A2A
	inc hl                                 ; 4A2B
	ld d,(hl)                              ; 4A2C
	dec de                                 ; 4A2D
	ld (hl),d                              ; 4A2E
	dec hl                                 ; 4A2F
	ld (hl),e                              ; 4A30
	ex de,hl                               ; 4A31
	ld de,L5D9D                            ; 4A32
L4A35:	call put16x16                    ; 4A35
	ld hl,(L502B)                          ; 4A38
	dec hl                                 ; 4A3B
	ld de,0028h                            ; 4A3C
	add hl,de                              ; 4A3F
L4A40:	ld (hl),20h                      ; 4A40
	xor a                                  ; 4A42
	sbc hl,de                              ; 4A43
	ld (hl),20h                            ; 4A45
	ld (L502B),hl                          ; 4A47
	inc hl                                 ; 4A4A
	inc hl                                 ; 4A4B
	ld (hl),a                              ; 4A4C
	add hl,de                              ; 4A4D
	ld (hl),a                              ; 4A4E
	ld hl,L5029                            ; 4A4F
	dec (hl)                               ; 4A52
	ld hl,(L502D)                          ; 4A53
	inc hl                                 ; 4A56
	call clr8x16                           ; 4A57
	dec hl                                 ; 4A5A
	dec hl                                 ; 4A5B
	ld (L502D),hl                          ; 4A5C
	ld de,L609D                            ; 4A5F
	call put16x16                          ; 4A62
	ret                                    ; 4A65
L4A66:	dec a                            ; 4A66
	jp nz,L4BA1                            ; 4A67
	ld hl,(L502B)                          ; 4A6A
	inc hl                                 ; 4A6D
	inc hl                                 ; 4A6E
	ld a,(hl)                              ; 4A6F
	ld b,a                                 ; 4A70
	ld de,0028h                            ; 4A71
	add hl,de                              ; 4A74
	cp 70h                                 ; 4A75
	jp nc,L4B73                            ; 4A77
	cp 50h                                 ; 4A7A
	jp nc,L4A9B                            ; 4A7C
	cp 20h                                 ; 4A7F
	jp nc,L4A92                            ; 4A81
	ld a,(hl)                              ; 4A84
	cp 50h                                 ; 4A85
	jp nc,L4B73                            ; 4A87
	cp 20h                                 ; 4A8A
	jp nc,L4CDC                            ; 4A8C
	jp L4B43                               ; 4A8F
L4A92:	ld a,(hl)                        ; 4A92
	cp 50h                                 ; 4A93
	jp nc,L4B73                            ; 4A95
	jp L4CDC                               ; 4A98
L4A9B:	ld a,(hl)                        ; 4A9B
	cp 70h                                 ; 4A9C
	jp nc,L4B73                            ; 4A9E
	cp 50h                                 ; 4AA1
	jp c,L4B73                             ; 4AA3
	xor b                                  ; 4AA6
	jp nz,L4B73                            ; 4AA7
	inc hl                                 ; 4AAA
	inc hl                                 ; 4AAB
	ld a,(hl)                              ; 4AAC
	cp 20h                                 ; 4AAD
	jp nc,L4ABB                            ; 4AAF
	and a                                  ; 4AB2
	sbc hl,de                              ; 4AB3
	ld a,(hl)                              ; 4AB5
	cp 20h                                 ; 4AB6
	jp c,L4AC1                             ; 4AB8
L4ABB:	call L4CC0                       ; 4ABB
	jp L4B73                               ; 4ABE
L4AC1:	ld a,b                           ; 4AC1
	cp 60h                                 ; 4AC2
	jp nc,L4B07                            ; 4AC4
	and 0Fh                                ; 4AC7
	ld b,a                                 ; 4AC9
	add a,a                                ; 4ACA
	add a,a                                ; 4ACB
	add a,a                                ; 4ACC
	ld d,00h                               ; 4ACD
	ld e,a                                 ; 4ACF
	ld a,b                                 ; 4AD0
	ex af,af'                              ; 4AD1
	ld hl,L50AC                            ; 4AD2
	add hl,de                              ; 4AD5
	ld a,(hl)                              ; 4AD6
	inc a                                  ; 4AD7
	ld (hl),a                              ; 4AD8
	inc hl                                 ; 4AD9
	inc hl                                 ; 4ADA
	ld e,(hl)                              ; 4ADB
	inc hl                                 ; 4ADC
	ld d,(hl)                              ; 4ADD
	ex de,hl                               ; 4ADE
	ld bc,0028h                            ; 4ADF
	xor a                                  ; 4AE2
	ld (hl),a                              ; 4AE3
	add hl,bc                              ; 4AE4
	ld (hl),a                              ; 4AE5
	and a                                  ; 4AE6
	sbc hl,bc                              ; 4AE7
	ex de,hl                               ; 4AE9
	inc de                                 ; 4AEA
	ld (hl),d                              ; 4AEB
	dec hl                                 ; 4AEC
	ld (hl),e                              ; 4AED
	inc de                                 ; 4AEE
	ex de,hl                               ; 4AEF
	ex af,af'                              ; 4AF0
	or 50h                                 ; 4AF1
	ld (hl),a                              ; 4AF3
	add hl,bc                              ; 4AF4
	ld (hl),a                              ; 4AF5
	ex de,hl                               ; 4AF6
	inc hl                                 ; 4AF7
	inc hl                                 ; 4AF8
	ld e,(hl)                              ; 4AF9
	inc hl                                 ; 4AFA
	ld d,(hl)                              ; 4AFB
	inc de                                 ; 4AFC
	ld (hl),d                              ; 4AFD
	dec hl                                 ; 4AFE
	ld (hl),e                              ; 4AFF
	ex de,hl                               ; 4B00
	ld de,L5C9D                            ; 4B01
	jp L4B37                               ; 4B04
L4B07:	ld hl,L50A4                      ; 4B07
	ld a,(hl)                              ; 4B0A
	inc a                                  ; 4B0B
	ld (hl),a                              ; 4B0C
	inc hl                                 ; 4B0D
	inc hl                                 ; 4B0E
	ld e,(hl)                              ; 4B0F
	inc hl                                 ; 4B10
	ld d,(hl)                              ; 4B11
	ex de,hl                               ; 4B12
	ld bc,0028h                            ; 4B13
	xor a                                  ; 4B16
	ld (hl),a                              ; 4B17
	add hl,bc                              ; 4B18
	ld (hl),a                              ; 4B19
	and a                                  ; 4B1A
	sbc hl,bc                              ; 4B1B
	ex de,hl                               ; 4B1D
	inc de                                 ; 4B1E
	ld (hl),d                              ; 4B1F
	dec hl                                 ; 4B20
	ld (hl),e                              ; 4B21
	inc de                                 ; 4B22
	ex de,hl                               ; 4B23
	ld a,60h                               ; 4B24
	ld (hl),a                              ; 4B26
	add hl,bc                              ; 4B27
	ld (hl),a                              ; 4B28
	ex de,hl                               ; 4B29
	inc hl                                 ; 4B2A
	inc hl                                 ; 4B2B
	ld e,(hl)                              ; 4B2C
	inc hl                                 ; 4B2D
	ld d,(hl)                              ; 4B2E
	inc de                                 ; 4B2F
	ld (hl),d                              ; 4B30
	dec hl                                 ; 4B31
	ld (hl),e                              ; 4B32
	ex de,hl                               ; 4B33
	ld de,L5D9D                            ; 4B34
L4B37:	call put16x16                    ; 4B37
	ld hl,(L502B)                          ; 4B3A
	inc hl                                 ; 4B3D
	inc hl                                 ; 4B3E
	ld de,0028h                            ; 4B3F
	add hl,de                              ; 4B42
L4B43:	ld (hl),20h                      ; 4B43
	xor a                                  ; 4B45
	sbc hl,de                              ; 4B46
	ld (hl),20h                            ; 4B48
	dec hl                                 ; 4B4A
	ld (L502B),hl                          ; 4B4B
	dec hl                                 ; 4B4E
	ld (hl),a                              ; 4B4F
	add hl,de                              ; 4B50
	ld (hl),a                              ; 4B51
	ld hl,L5029                            ; 4B52
	inc (hl)                               ; 4B55
	ld hl,(L502D)                          ; 4B56
	call clr8x16                           ; 4B59
	inc hl                                 ; 4B5C
	ld (L502D),hl                          ; 4B5D
	ld de,L619D                            ; 4B60
	call put16x16                          ; 4B63
	ret                                    ; 4B66
L4B67:	ld a,06h                         ; 4B67
	jr L4B75                               ; 4B69
L4B6B:	ld a,07h                         ; 4B6B
	jr L4B75                               ; 4B6D
L4B6F:	ld a,08h                         ; 4B6F
	jr L4B75                               ; 4B71
L4B73:	ld a,09h                         ; 4B73
L4B75:	ld (L5028),a                     ; 4B75
L4B78:	ret                              ; 4B78
L4B79:	ld hl,(L502D)                    ; 4B79
	ld a,(L5031)                           ; 4B7C
	dec a                                  ; 4B7F
	jr nz,L4B87                            ; 4B80
	ld de,L5F1D                            ; 4B82
	jr L4B9A                               ; 4B85
L4B87:	dec a                            ; 4B87
	jr nz,L4B8F                            ; 4B88
	ld de,L5DDD                            ; 4B8A
	jr L4B9A                               ; 4B8D
L4B8F:	dec a                            ; 4B8F
	jr nz,L4B97                            ; 4B90
	ld de,L605D                            ; 4B92
	jr L4B9A                               ; 4B95
L4B97:	ld de,L615D                      ; 4B97
L4B9A:	ld hl,(L502D)                    ; 4B9A
	call put16x16                          ; 4B9D
	ret                                    ; 4BA0
L4BA1:	ld a,(L5031)                     ; 4BA1
	dec a                                  ; 4BA4
	jr nz,L4BAD                            ; 4BA5
	ld de,L5FDD                            ; 4BA7
	jp L4C4D                               ; 4BAA
L4BAD:	dec a                            ; 4BAD
	jr nz,L4BB6                            ; 4BAE
	ld de,L5E9D                            ; 4BB0
	jp L4C4D                               ; 4BB3
L4BB6:	dec a                            ; 4BB6
	jr nz,L4BBF                            ; 4BB7
	ld de,L60DD                            ; 4BB9
	jp L4C4D                               ; 4BBC
L4BBF:	ld de,L61DD                      ; 4BBF
	jp L4C4D                               ; 4BC2
L4BC5:	ld a,(player_state)              ; 4BC5
	and a                                  ; 4BC8
	jp m,L4CA1                             ; 4BC9
	jp nz,L4C55                            ; 4BCC
	ld a,(L5028)                           ; 4BCF
	and a                                  ; 4BD2
	jp z,L4C54                             ; 4BD3
	cp 06h                                 ; 4BD6
	jr c,L4BE8                             ; 4BD8
	cp 07h                                 ; 4BDA
	jr c,L4BFE                             ; 4BDC
	cp 08h                                 ; 4BDE
	jr c,L4C0B                             ; 4BE0
	cp 09h                                 ; 4BE2
	jr c,L4C18                             ; 4BE4
	jr L4C25                               ; 4BE6
L4BE8:	dec a                            ; 4BE8
	jr nz,L4C08                            ; 4BE9
	ld hl,(L502D)                          ; 4BEB
	ld de,0140h                            ; 4BEE
	add hl,de                              ; 4BF1
	call clr16x8                           ; 4BF2
	ld de,0280h                            ; 4BF5
	or a                                   ; 4BF8
	sbc hl,de                              ; 4BF9
	ld (L502D),hl                          ; 4BFB
L4BFE:	ld de,L5F1D                      ; 4BFE
	ld hl,(L502D)                          ; 4C01
	call put16x16                          ; 4C04
	ret                                    ; 4C07
L4C08:	dec a                            ; 4C08
	jr nz,L4C15                            ; 4C09
L4C0B:	ld de,L5DDD                      ; 4C0B
	ld hl,(L502D)                          ; 4C0E
	call put16x16                          ; 4C11
	ret                                    ; 4C14
L4C15:	dec a                            ; 4C15
	jr nz,L4C22                            ; 4C16
L4C18:	ld de,L605D                      ; 4C18
	ld hl,(L502D)                          ; 4C1B
	call put16x16                          ; 4C1E
	ret                                    ; 4C21
L4C22:	dec a                            ; 4C22
	jr nz,L4C2F                            ; 4C23
L4C25:	ld de,L615D                      ; 4C25
	ld hl,(L502D)                          ; 4C28
	call put16x16                          ; 4C2B
	ret                                    ; 4C2E
L4C2F:	ld a,(L5031)                     ; 4C2F
	dec a                                  ; 4C32
	jr nz,L4C3A                            ; 4C33
	ld de,L601D                            ; 4C35
	jr L4C4D                               ; 4C38
L4C3A:	dec a                            ; 4C3A
	jr nz,L4C42                            ; 4C3B
	ld de,L5EDD                            ; 4C3D
	jr L4C4D                               ; 4C40
L4C42:	dec a                            ; 4C42
	jr nz,L4C4A                            ; 4C43
	ld de,L611D                            ; 4C45
	jr L4C4D                               ; 4C48
L4C4A:	ld de,L621D                      ; 4C4A
L4C4D:	ld hl,(L502D)                    ; 4C4D
	call put16x16                          ; 4C50
	ret                                    ; 4C53
L4C54:	ret                              ; 4C54
L4C55:	ld a,(player_state)              ; 4C55
	cp 14h                                 ; 4C58
	jp nc,L4C93                            ; 4C5A
	dec a                                  ; 4C5D
	jr nz,L4C8B                            ; 4C5E
	ex af,af'                              ; 4C60
	ld a,(L5028)                           ; 4C61
	dec a                                  ; 4C64
	jp nz,L4C72                            ; 4C65
	ld hl,(L502B)                          ; 4C68
	ld de,0028h                            ; 4C6B
	add hl,de                              ; 4C6E
	ld (L502B),hl                          ; 4C6F
L4C72:	ld hl,L502A                      ; 4C72
	inc (hl)                               ; 4C75
	ld hl,(L502D)                          ; 4C76
	call clr16x8                           ; 4C79
	ld de,0140h                            ; 4C7C
	add hl,de                              ; 4C7F
	ld (L502D),hl                          ; 4C80
	ld hl,(L502B)                          ; 4C83
	xor a                                  ; 4C86
	ld (hl),a                              ; 4C87
	inc hl                                 ; 4C88
	ld (hl),a                              ; 4C89
	ex af,af'                              ; 4C8A
L4C8B:	rra                              ; 4C8B
	jr c,L4C93                             ; 4C8C
	ld de,L62DD                            ; 4C8E
	jr L4C96                               ; 4C91
L4C93:	ld de,L62FD                      ; 4C93
L4C96:	ld hl,(L502D)                    ; 4C96
	call put16x8                           ; 4C99
	ld hl,player_state                     ; 4C9C
	inc (hl)                               ; 4C9F
	ret                                    ; 4CA0
L4CA1:	ld a,(player_state)              ; 4CA1
	and 7Fh                                ; 4CA4
	cp 0Eh                                 ; 4CA6
	jr c,L4CB8                             ; 4CA8
	ret nz                                 ; 4CAA
	ld hl,(L502B)                          ; 4CAB
	xor a                                  ; 4CAE
	ld (hl),a                              ; 4CAF
	inc hl                                 ; 4CB0
	ld (hl),a                              ; 4CB1
	ld hl,(L502D)                          ; 4CB2
	call clr16x8                           ; 4CB5
L4CB8:	ld a,(player_state)              ; 4CB8
	inc a                                  ; 4CBB
	ld (player_state),a                    ; 4CBC
	ret                                    ; 4CBF
L4CC0:	ld a,b                           ; 4CC0
	cp 60h                                 ; 4CC1
	jp nc,L4CDB                            ; 4CC3
	and 0Fh                                ; 4CC6
	add a,a                                ; 4CC8
	add a,a                                ; 4CC9
	add a,a                                ; 4CCA
	exx                                    ; 4CCB
	ld hl,L50B2                            ; 4CCC
	ld d,00h                               ; 4CCF
	ld e,a                                 ; 4CD1
	add hl,de                              ; 4CD2
	ld a,(hl)                              ; 4CD3
	and a                                  ; 4CD4
	jp nz,L4CDA                            ; 4CD5
	ld (hl),01h                            ; 4CD8
L4CDA:	exx                              ; 4CDA
L4CDB:	ret                              ; 4CDB
L4CDC:	ld a,01h                         ; 4CDC
	ld (player_state),a                    ; 4CDE
	jp L4B78                               ; 4CE1
L4CE4:	ld a,(L5033)                     ; 4CE4
	or a                                   ; 4CE7
	ret z                                  ; 4CE8
	ld c,a                                 ; 4CE9
L4CEA:	push bc                          ; 4CEA
	call random                            ; 4CEB
	ld b,a                                 ; 4CEE
	ld a,(L5033)                           ; 4CEF
	sub c                                  ; 4CF2
	add a,a                                ; 4CF3
	ld d,00h                               ; 4CF4
	ld e,a                                 ; 4CF6
	ld c,a                                 ; 4CF7
	ld hl,L5035                            ; 4CF8
	add hl,de                              ; 4CFB
	ld a,(hl)                              ; 4CFC
	or a                                   ; 4CFD
	jp nz,L4D33                            ; 4CFE
	dec hl                                 ; 4D01
	ld a,(hl)                              ; 4D02
	cp 08h                                 ; 4D03
	jr z,L4D0F                             ; 4D05
	jp nc,L4EB0                            ; 4D07
	inc a                                  ; 4D0A
	ld (hl),a                              ; 4D0B
	jp L4EB0                               ; 4D0C
L4D0F:	inc a                            ; 4D0F
	ld (hl),a                              ; 4D10
	ld hl,L5054                            ; 4D11
	add hl,de                              ; 4D14
	ld e,(hl)                              ; 4D15
	inc hl                                 ; 4D16
	ld d,(hl)                              ; 4D17
	ld hl,0028h                            ; 4D18
	add hl,de                              ; 4D1B
	xor a                                  ; 4D1C
	ld (hl),a                              ; 4D1D
	inc hl                                 ; 4D1E
	ld (hl),a                              ; 4D1F
	ld b,00h                               ; 4D20
	ld hl,L5074                            ; 4D22
	add hl,bc                              ; 4D25
	ld e,(hl)                              ; 4D26
	inc hl                                 ; 4D27
	ld d,(hl)                              ; 4D28
	ld hl,0140h                            ; 4D29
	add hl,de                              ; 4D2C
	call clr16x8                           ; 4D2D
	jp L4EB0                               ; 4D30
L4D33:	ld hl,L5094                      ; 4D33
	srl e                                  ; 4D36
	add hl,de                              ; 4D38
	sla e                                  ; 4D39
	ld a,(hl)                              ; 4D3B
	cp 02h                                 ; 4D3C
	jp c,L4D47                             ; 4D3E
	call L4F37                             ; 4D41
	jp L4EB0                               ; 4D44
L4D47:	ex af,af'                        ; 4D47
	ld hl,L5035                            ; 4D48
	add hl,de                              ; 4D4B
	ld a,(hl)                              ; 4D4C
	ld hl,L502A                            ; 4D4D
	xor (hl)                               ; 4D50
	jr z,L4D72                             ; 4D51
L4D53:	ex af,af'                        ; 4D53
	and a                                  ; 4D54
	jp z,L4D65                             ; 4D55
	srl b                                  ; 4D58
	jp po,L4E24                            ; 4D5A
	srl b                                  ; 4D5D
	jp po,L4E24                            ; 4D5F
	jp L4DB2                               ; 4D62
L4D65:	srl b                            ; 4D65
	jp pe,L4DB2                            ; 4D67
	srl b                                  ; 4D6A
	jp pe,L4DB2                            ; 4D6C
	jp L4E24                               ; 4D6F
L4D72:	ld a,(L5029)                     ; 4D72
	ld hl,L5034                            ; 4D75
	add hl,de                              ; 4D78
	sub (hl)                               ; 4D79
	jp p,L4D99                             ; 4D7A
	neg                                    ; 4D7D
	cp 06h                                 ; 4D7F
	jr c,L4DB2                             ; 4D81
	cp 0Bh                                 ; 4D83
	jr nc,L4D53                            ; 4D85
	add a,a                                ; 4D87
	add a,a                                ; 4D88
	ld h,a                                 ; 4D89
	add a,50h                              ; 4D8A
	sub h                                  ; 4D8C
	ld h,a                                 ; 4D8D
	ld a,b                                 ; 4D8E
	and a                                  ; 4D8F
	jp m,L4DB2                             ; 4D90
	cp h                                   ; 4D93
	jr c,L4DB2                             ; 4D94
	jp L4E24                               ; 4D96
L4D99:	cp 06h                           ; 4D99
	jp c,L4E24                             ; 4D9B
	cp 0Bh                                 ; 4D9E
	jr nc,L4D53                            ; 4DA0
	add a,a                                ; 4DA2
	add a,a                                ; 4DA3
	ld h,a                                 ; 4DA4
	add a,50h                              ; 4DA5
	sub h                                  ; 4DA7
	ld h,a                                 ; 4DA8
	ld a,b                                 ; 4DA9
	and a                                  ; 4DAA
	jp p,L4E24                             ; 4DAB
	cp h                                   ; 4DAE
	jp c,L4E24                             ; 4DAF
L4DB2:	ld b,00h                         ; 4DB2
	ld hl,L5054                            ; 4DB4
	add hl,bc                              ; 4DB7
	ld e,(hl)                              ; 4DB8
	inc hl                                 ; 4DB9
	ld d,(hl)                              ; 4DBA
	dec de                                 ; 4DBB
	ld hl,0028h                            ; 4DBC
	add hl,de                              ; 4DBF
	ld a,(de)                              ; 4DC0
	cp 30h                                 ; 4DC1
	jp nc,L4EA3                            ; 4DC3
	cp 20h                                 ; 4DC6
	jp nc,L4DD9                            ; 4DC8
	ld a,(hl)                              ; 4DCB
	cp 30h                                 ; 4DCC
	jp nc,L4EA3                            ; 4DCE
	cp 20h                                 ; 4DD1
	jp nc,L4E94                            ; 4DD3
	jp L4DE2                               ; 4DD6
L4DD9:	ld a,(hl)                        ; 4DD9
	cp 30h                                 ; 4DDA
	jp nc,L4EA3                            ; 4DDC
	jp L4E94                               ; 4DDF
L4DE2:	ld a,c                           ; 4DE2
	srl a                                  ; 4DE3
	or 30h                                 ; 4DE5
	ld (hl),a                              ; 4DE7
	ld (de),a                              ; 4DE8
	ld hl,L5054                            ; 4DE9
	add hl,bc                              ; 4DEC
	ld (hl),e                              ; 4DED
	inc hl                                 ; 4DEE
	ld (hl),d                              ; 4DEF
	inc de                                 ; 4DF0
	inc de                                 ; 4DF1
	xor a                                  ; 4DF2
	ld (de),a                              ; 4DF3
	ld hl,0028h                            ; 4DF4
	add hl,de                              ; 4DF7
	ld (hl),a                              ; 4DF8
	ld hl,L5034                            ; 4DF9
	add hl,bc                              ; 4DFC
	dec (hl)                               ; 4DFD
	ld hl,L5094                            ; 4DFE
	srl c                                  ; 4E01
	add hl,bc                              ; 4E03
	ld (hl),00h                            ; 4E04
	sla c                                  ; 4E06
	ld hl,L5074                            ; 4E08
	add hl,bc                              ; 4E0B
	ld e,(hl)                              ; 4E0C
	inc hl                                 ; 4E0D
	ld d,(hl)                              ; 4E0E
	dec de                                 ; 4E0F
	ld (hl),d                              ; 4E10
	dec hl                                 ; 4E11
	ld (hl),e                              ; 4E12
	inc de                                 ; 4E13
	ex de,hl                               ; 4E14
	inc hl                                 ; 4E15
	call clr8x16                           ; 4E16
	dec hl                                 ; 4E19
	dec hl                                 ; 4E1A
	ld de,L638D                            ; 4E1B
	call put16x16                          ; 4E1E
	jp L4EB0                               ; 4E21
L4E24:	ld b,00h                         ; 4E24
	ld hl,L5054                            ; 4E26
	add hl,bc                              ; 4E29
	ld e,(hl)                              ; 4E2A
	inc hl                                 ; 4E2B
	ld d,(hl)                              ; 4E2C
	inc de                                 ; 4E2D
	inc de                                 ; 4E2E
	ld hl,0028h                            ; 4E2F
	add hl,de                              ; 4E32
	ld a,(de)                              ; 4E33
	cp 30h                                 ; 4E34
	jp nc,L4EA7                            ; 4E36
	cp 20h                                 ; 4E39
	jp nc,L4E4C                            ; 4E3B
	ld a,(hl)                              ; 4E3E
	cp 30h                                 ; 4E3F
	jp nc,L4EA7                            ; 4E41
	cp 20h                                 ; 4E44
	jp nc,L4E94                            ; 4E46
	jp L4E55                               ; 4E49
L4E4C:	ld a,(hl)                        ; 4E4C
	cp 30h                                 ; 4E4D
	jp nc,L4EA7                            ; 4E4F
	jp L4E94                               ; 4E52
L4E55:	ld a,c                           ; 4E55
	srl a                                  ; 4E56
	or 30h                                 ; 4E58
	ld (hl),a                              ; 4E5A
	ld (de),a                              ; 4E5B
	ld hl,L5054                            ; 4E5C
	add hl,bc                              ; 4E5F
	dec de                                 ; 4E60
	ld (hl),e                              ; 4E61
	inc hl                                 ; 4E62
	ld (hl),d                              ; 4E63
	dec de                                 ; 4E64
	xor a                                  ; 4E65
	ld (de),a                              ; 4E66
	ld hl,0028h                            ; 4E67
	add hl,de                              ; 4E6A
	ld (hl),a                              ; 4E6B
	ld hl,L5034                            ; 4E6C
	add hl,bc                              ; 4E6F
	inc (hl)                               ; 4E70
	ld hl,L5094                            ; 4E71
	srl c                                  ; 4E74
	add hl,bc                              ; 4E76
	ld (hl),01h                            ; 4E77
	sla c                                  ; 4E79
	ld hl,L5074                            ; 4E7B
	add hl,bc                              ; 4E7E
	ld e,(hl)                              ; 4E7F
	inc hl                                 ; 4E80
	ld d,(hl)                              ; 4E81
	inc de                                 ; 4E82
	ld (hl),d                              ; 4E83
	dec hl                                 ; 4E84
	ld (hl),e                              ; 4E85
	dec de                                 ; 4E86
	ex de,hl                               ; 4E87
	call clr8x16                           ; 4E88
	inc hl                                 ; 4E8B
	ld de,L640D                            ; 4E8C
	call put16x16                          ; 4E8F
	jr L4EB0                               ; 4E92
L4E94:	ld a,(player_state)              ; 4E94
	and a                                  ; 4E97
	jp nz,L4EA0                            ; 4E98
	ld a,01h                               ; 4E9B
	ld (player_state),a                    ; 4E9D
L4EA0:	jp L4EB0                         ; 4EA0
L4EA3:	ld a,01h                         ; 4EA3
	jr L4EA9                               ; 4EA5
L4EA7:	ld a,00h                         ; 4EA7
L4EA9:	ld hl,L5094                      ; 4EA9
	srl c                                  ; 4EAC
	add hl,bc                              ; 4EAE
	ld (hl),a                              ; 4EAF
L4EB0:	pop bc                           ; 4EB0
	dec c                                  ; 4EB1
	jp nz,L4CEA                            ; 4EB2
	ret                                    ; 4EB5
L4EB6:	ld a,(L5033)                     ; 4EB6
	or a                                   ; 4EB9
	ret z                                  ; 4EBA
	ld b,a                                 ; 4EBB
L4EBC:	push bc                          ; 4EBC
	ld a,(L5033)                           ; 4EBD
	sub b                                  ; 4EC0
	add a,a                                ; 4EC1
	ld d,00h                               ; 4EC2
	ld e,a                                 ; 4EC4
	ld hl,L5035                            ; 4EC5
	add hl,de                              ; 4EC8
	ld a,(hl)                              ; 4EC9
	or a                                   ; 4ECA
	jp nz,L4F00                            ; 4ECB
	dec hl                                 ; 4ECE
	ld a,(hl)                              ; 4ECF
	cp 08h                                 ; 4ED0
	jr z,L4EDC                             ; 4ED2
	jp nc,L4F31                            ; 4ED4
	inc a                                  ; 4ED7
	ld (hl),a                              ; 4ED8
	jp L4F31                               ; 4ED9
L4EDC:	inc a                            ; 4EDC
	ld (hl),a                              ; 4EDD
	push de                                ; 4EDE
	ld hl,L5054                            ; 4EDF
	add hl,de                              ; 4EE2
	ld e,(hl)                              ; 4EE3
	inc hl                                 ; 4EE4
	ld d,(hl)                              ; 4EE5
	ld hl,0028h                            ; 4EE6
	add hl,de                              ; 4EE9
	xor a                                  ; 4EEA
	ld (hl),a                              ; 4EEB
	inc hl                                 ; 4EEC
	ld (hl),a                              ; 4EED
	pop de                                 ; 4EEE
	ld hl,L5074                            ; 4EEF
	add hl,de                              ; 4EF2
	ld e,(hl)                              ; 4EF3
	inc hl                                 ; 4EF4
	ld d,(hl)                              ; 4EF5
	ld hl,0140h                            ; 4EF6
	add hl,de                              ; 4EF9
	call clr16x8                           ; 4EFA
	jp L4F31                               ; 4EFD
L4F00:	ld hl,L5094                      ; 4F00
	srl e                                  ; 4F03
	add hl,de                              ; 4F05
	sla e                                  ; 4F06
	ld a,(hl)                              ; 4F08
	cp 02h                                 ; 4F09
	jp c,L4F14                             ; 4F0B
	call L4F37                             ; 4F0E
	jp L4F31                               ; 4F11
L4F14:	ld hl,L5074                      ; 4F14
	add hl,de                              ; 4F17
	ld e,(hl)                              ; 4F18
	inc hl                                 ; 4F19
	ld d,(hl)                              ; 4F1A
	ex de,hl                               ; 4F1B
	and a                                  ; 4F1C
	jp nz,L4F29                            ; 4F1D
	ld de,L634D                            ; 4F20
	call put16x16                          ; 4F23
	jp L4F31                               ; 4F26
L4F29:	ld de,L63CD                      ; 4F29
	call put16x16                          ; 4F2C
	jr L4F31                               ; 4F2F
L4F31:	pop bc                           ; 4F31
	dec b                                  ; 4F32
	jp nz,L4EBC                            ; 4F33
	ret                                    ; 4F36
L4F37:	ld b,a                           ; 4F37
	push de                                ; 4F38
	exx                                    ; 4F39
	ld hl,L5074                            ; 4F3A
	pop de                                 ; 4F3D
	add hl,de                              ; 4F3E
	ld e,(hl)                              ; 4F3F
	inc hl                                 ; 4F40
	ld d,(hl)                              ; 4F41
	ex de,hl                               ; 4F42
	sub 06h                                ; 4F43
	jp c,L4F70                             ; 4F45
	srl a                                  ; 4F48
	srl a                                  ; 4F4A
	srl a                                  ; 4F4C
	srl a                                  ; 4F4E
	cp 01h                                 ; 4F50
	jp c,L4F64                             ; 4F52
	cp 0Ah                                 ; 4F55
	jp nc,L4F97                            ; 4F57
	rra                                    ; 4F5A
	jp nc,L4F6A                            ; 4F5B
	ld de,L654D                            ; 4F5E
	jp L4FAE                               ; 4F61
L4F64:	ld de,L634D                      ; 4F64
	jp L4FAE                               ; 4F67
L4F6A:	ld de,L658D                      ; 4F6A
	jp L4FAE                               ; 4F6D
L4F70:	cp 0FCh                          ; 4F70
	jp nz,L4F7B                            ; 4F72
	ld de,L644D                            ; 4F75
	jp L4FAE                               ; 4F78
L4F7B:	cp 0FDh                          ; 4F7B
	jp nz,L4F86                            ; 4F7D
	ld de,L648D                            ; 4F80
	jp L4FAE                               ; 4F83
L4F86:	cp 0FEh                          ; 4F86
	jp nz,L4F91                            ; 4F88
	ld de,L64CD                            ; 4F8B
	jp L4FAE                               ; 4F8E
L4F91:	ld de,L650D                      ; 4F91
	jp L4FAE                               ; 4F94
L4F97:	exx                              ; 4F97
	ld a,b                                 ; 4F98
	exx                                    ; 4F99
	cp 0AEh                                ; 4F9A
	jp c,L4F6A                             ; 4F9C
	cp 0C8h                                ; 4F9F
	jp c,L4F64                             ; 4FA1
	ld de,L634D                            ; 4FA4
	call put16x16                          ; 4FA7
	xor a                                  ; 4FAA
	exx                                    ; 4FAB
	ld (hl),a                              ; 4FAC
	ret                                    ; 4FAD
L4FAE:	call put16x16                    ; 4FAE
	exx                                    ; 4FB1
	inc b                                  ; 4FB2
	ld (hl),b                              ; 4FB3
	ret                                    ; 4FB4
	; SAPI: MZ: XOR A + LD (L5028),A (input_hook does it).
L4FB5:	call input_hook
	nop
	ld a,(L5C1A)                           ; 4FB9
	or a                                   ; 4FBC
	jr z,L4FE0                             ; 4FBD
	call read_dir                          ; 4FBF
	and 02h                                ; 4FC2
	jp nz,L501C                            ; 4FC4
	ld a,(L5C1A)                           ; 4FC7
	call read_joy                          ; 4FCA
	rla                                    ; 4FCD
	rla                                    ; 4FCE
	rla                                    ; 4FCF
	rla                                    ; 4FD0
	jr c,L4FF8                             ; 4FD1
	rla                                    ; 4FD3
	jr c,L5008                             ; 4FD4
	rla                                    ; 4FD6
	jr c,L500D                             ; 4FD7
	rla                                    ; 4FD9
	jr c,L5012                             ; 4FDA
	rla                                    ; 4FDC
	jr c,L5017                             ; 4FDD
	ret                                    ; 4FDF
L4FE0:	call read_dir                    ; 4FE0
	rla                                    ; 4FE3
	jr c,L4FF8                             ; 4FE4
	rla                                    ; 4FE6
	rla                                    ; 4FE7
	jr c,L500D                             ; 4FE8
	rla                                    ; 4FEA
	jr c,L5008                             ; 4FEB
	rla                                    ; 4FED
	jr c,L5012                             ; 4FEE
	rla                                    ; 4FF0
	jr c,L5017                             ; 4FF1
	rla                                    ; 4FF3
	jp c,L501C                             ; 4FF4
	ret                                    ; 4FF7
L4FF8:	ld a,(player_state)              ; 4FF8
	and a                                  ; 4FFB
	jp z,L5003                             ; 4FFC
	xor a                                  ; 4FFF
	jp L5024                               ; 5000
L5003:	ld a,05h                         ; 5003
	jp L5024                               ; 5005
L5008:	ld a,04h                         ; 5008
	jp L5021                               ; 500A
L500D:	ld a,03h                         ; 500D
	jp L5021                               ; 500F
L5012:	ld a,02h                         ; 5012
	jp L5021                               ; 5014
L5017:	ld a,01h                         ; 5017
	jp L5021                               ; 5019
L501C:	ld a,0FFh                        ; 501C
	jp L5024                               ; 501E
L5021:	ld (L5031),a                     ; 5021
L5024:	ld (L5028),a                     ; 5024
	ret                                    ; 5027
L5028:	defb 00h                         ; 5028
L5029:	defb 00h                         ; 5029
L502A:	defb 00h                         ; 502A
L502B:	defb 00h,00h                     ; 502B
L502D:	defb 00h,00h                     ; 502D
lives:	defb 00h                         ; 502F
L5030:	defb 00h                         ; 5030
L5031:	defb 00h                         ; 5031
player_state:	defb 00h                  ; 5032
L5033:	defb 00h                         ; 5033
L5034:	defb 00h                         ; 5034
L5035:	defs 31                          ; 5035
L5054:	defs 32                          ; 5054
L5074:	defs 32                          ; 5074
L5094:	defs 16                          ; 5094
L50A4:	defb 00h,00h                     ; 50A4
L50A6:	defb 00h,00h,00h,00h,00h,00h     ; 50A6
L50AC:	defb 00h,00h,00h,00h,00h,00h     ; 50AC
L50B2:	defs 109                         ; 50B2
	defb 2Ah,1Ch,50h,2Ah,1Fh,50h,0CDh,0A8h,3Bh,11h,0D3h,5Dh,0CDh; 511F
clear_screen_seq:	ld hl,(L5029)         ; 512C
	call vaddr_field                       ; 512F
	ld de,L5DDD                            ; 5132
	call put16x16                          ; 5135
	ld a,14h                               ; 5138
	call delay                             ; 513A
	ld b,03h                               ; 513D
L513F:	ld de,L625D                      ; 513F
	call put16x16                          ; 5142
	ld a,14h                               ; 5145
	call delay                             ; 5147
	ld de,L629D                            ; 514A
	call put16x16                          ; 514D
	ld a,01h                               ; 5150
	call delay                             ; 5152
	ld de,L5DDD                            ; 5155
	call put16x16                          ; 5158
	ld a,0Ch                               ; 515B
	call delay                             ; 515D
	djnz L513F                             ; 5160
	ld a,0Ah                               ; 5162
	call delay                             ; 5164
	di                                     ; 5167
	ld hl,0BB8h                            ; 5168
	call L062A                             ; 516B
	ld a,(L3F4A)                           ; 516E
	and a                                  ; 5171
	jr z,L519E                             ; 5172
L5174:	ld hl,(L3F06)                    ; 5174
	ld de,0001h                            ; 5177
	add hl,de                              ; 517A
	ld (L3F06),hl                          ; 517B
	ld a,(L3F4A)                           ; 517E
	dec a                                  ; 5181
	push af                                ; 5182
	ld (L3F4A),a                           ; 5183
	ld hl,L535F                            ; 5186
	ld de,L5361                            ; 5189
	ld a,(L738D)                           ; 518C
	and a                                  ; 518F
	call L3F43                             ; 5190
	call L3EED                             ; 5193
	pop af                                 ; 5196
	jr nz,L5174                            ; 5197
	ld a,14h                               ; 5199
	call delay                             ; 519B
L519E:	ld a,02h                         ; 519E
	ld (text_colour),a                     ; 51A0
	ld a,05h                               ; 51A3
	ld (L3EE9),a                           ; 51A5
L51A8:	ld hl,(time_left)                ; 51A8
	ld de,000Dh                            ; 51AB
	and a                                  ; 51AE
	sbc hl,de                              ; 51AF
	jr c,L51D0                             ; 51B1
	ld (time_left),hl                      ; 51B3
	call L3F19                             ; 51B6
	ld hl,(L3F06)                          ; 51B9
	inc hl                                 ; 51BC
	ld (L3F06),hl                          ; 51BD
	ld hl,L535F                            ; 51C0
	ld de,L5361                            ; 51C3
	ld a,(L738D)                           ; 51C6
	and a                                  ; 51C9
	call L3EED                             ; 51CA
	jp L51A8                               ; 51CD
L51D0:	ld hl,0000h                      ; 51D0
	ld (time_left),hl                      ; 51D3
	call L3F19                             ; 51D6
	ld a,1Eh                               ; 51D9
	call delay                             ; 51DB
	call music_off                         ; 51DE
	ld hl,9E00h                            ; 51E1
	ld de,L5C5D                            ; 51E4
	call pattern_rows                      ; 51E7
	; SAPI: the MZ code below clears the field in the VRAM: replaced by wipe_s.
wipe:	jp wipe_s
	ld c,0A0h                              ; 51ED
	ld a,81h                               ; 51EF
	out (0CCh),a                           ; 51F1
L51F3:	xor a                            ; 51F3
	dec hl                                 ; 51F4
	ld b,26h                               ; 51F5
L51F7:	ld (hl),a                        ; 51F7
	dec hl                                 ; 51F8
	djnz L51F7                             ; 51F9
	dec hl                                 ; 51FB
	dec c                                  ; 51FC
	jr nz,L51F3                            ; 51FD
L51FF:	call L523C                       ; 51FF
	ld a,(L5029)                           ; 5202
	ld b,a                                 ; 5205
	ld a,(lives)                           ; 5206
	add a,a                                ; 5209
	dec a                                  ; 520A
	sub b                                  ; 520B
	jr z,L521F                             ; 520C
	ld a,(L5029)                           ; 520E
	jr c,L5216                             ; 5211
	inc a                                  ; 5213
	jr L5217                               ; 5214
L5216:	dec a                            ; 5216
L5217:	call L5250                       ; 5217
	ld (L5029),a                           ; 521A
	jr L51FF                               ; 521D
L521F:	call L523C                       ; 521F
	ld a,(L502A)                           ; 5222
	ld b,a                                 ; 5225
	ld a,01h                               ; 5226
	sub b                                  ; 5228
	jr z,L525C                             ; 5229
	ld a,(L502A)                           ; 522B
	jr c,L5233                             ; 522E
	inc a                                  ; 5230
	jr L5234                               ; 5231
L5233:	dec a                            ; 5233
L5234:	call L5250                       ; 5234
	ld (L502A),a                           ; 5237
	jr L521F                               ; 523A
L523C:	push af                          ; 523C
	ld hl,(L5029)                          ; 523D
	call vaddr_field                       ; 5240
	ld de,L633D                            ; 5243
	call put8x8                            ; 5246
	ld a,01h                               ; 5249
	call delay                             ; 524B
	pop af                                 ; 524E
	ret                                    ; 524F
L5250:	push af                          ; 5250
	ld hl,(L5029)                          ; 5251
	call vaddr_field                       ; 5254
	call clr8                              ; 5257
	pop af                                 ; 525A
	ret                                    ; 525B
L525C:	call L5250                       ; 525C
	ld hl,8140h                            ; 525F
	ld a,(lives)                           ; 5262
	add a,a                                ; 5265
	dec a                                  ; 5266
	ld d,00h                               ; 5267
	ld e,a                                 ; 5269
	add hl,de                              ; 526A
	ld de,L625D                            ; 526B
	call put16x16                          ; 526E
	ld a,12h                               ; 5271
	call delay                             ; 5273
	ld de,L629D                            ; 5276
	call put16x16                          ; 5279
	ld a,04h                               ; 527C
	call delay                             ; 527E
	ld de,L5DDD                            ; 5281
	call put16x16                          ; 5284
	ld a,(keyword_idx)                     ; 5287
	add a,04h                              ; 528A
	ld c,a                                 ; 528C
	ld a,(stage)                           ; 528D
	cp c                                   ; 5290
	ret c                                  ; 5291
	ld hl,090Eh                            ; 5292
	ld de,L6F81                            ; 5295
	call vaddr                             ; 5298
	call print_big                         ; 529B
	ld hl,0914h                            ; 529E
	ld a,(keyword_idx)                     ; 52A1
	ld d,00h                               ; 52A4
	ld e,a                                 ; 52A6
	ld a,02h                               ; 52A7
	ld (text_colour),a                     ; 52A9
	ld a,00h                               ; 52AC
	ld (L3EE9),a                           ; 52AE
	call vaddr                             ; 52B1
	call print_num                         ; 52B4
	ld a,02h                               ; 52B7
	ld de,L5362                            ; 52B9
	call print                             ; 52BC
	ld a,(stage)                           ; 52BF
	ld d,00h                               ; 52C2
	ld e,a                                 ; 52C4
	call print_num                         ; 52C5
	ld hl,0B0Dh                            ; 52C8
	ld de,L5364                            ; 52CB
	ld a,02h                               ; 52CE
	call vaddr                             ; 52D0
	call print                             ; 52D3
	push hl                                ; 52D6
	ld a,(keyword_idx)                     ; 52D7
	dec a                                  ; 52DA
	ld hl,keywords                         ; 52DB
	ld d,00h                               ; 52DE
	ld e,a                                 ; 52E0
	add hl,de                              ; 52E1
	ld de,keyword_buf                      ; 52E2
	ld bc,0005h                            ; 52E5
	ldir                                   ; 52E8
	ld a,(stage_count)                     ; 52EA
	ld c,a                                 ; 52ED
	ld a,(keyword_idx)                     ; 52EE
	add a,05h                              ; 52F1
	ld (keyword_idx),a                     ; 52F3
	cp c                                   ; 52F6
	jr c,L52FE                             ; 52F7
	ld a,01h                               ; 52F9
	ld (keyword_idx),a                     ; 52FB
L52FE:	pop hl                           ; 52FE
	ld de,keyword_buf                      ; 52FF
	ld a,03h                               ; 5302
	call print                             ; 5304
	ld hl,0F0Dh                            ; 5307
	ld de,L536E                            ; 530A
	ld a,01h                               ; 530D
	call vaddr                             ; 530F
	call print                             ; 5312
	ld a,(L5C1A)                           ; 5315
	and a                                  ; 5318
	jr z,L5322                             ; 5319
	dec a                                  ; 531B
	jr z,L5332                             ; 531C
	dec a                                  ; 531E
	jr z,L5344                             ; 531F
	ret                                    ; 5321
L5322:	ld de,L5373                      ; 5322
	ld a,01h                               ; 5325
	call print                             ; 5327
L532A:	call read_dir                    ; 532A
	and 80h                                ; 532D
	ret nz                                 ; 532F
	jr L532A                               ; 5330
L5332:	ld de,L537D                      ; 5332
	ld a,01h                               ; 5335
	call print                             ; 5337
L533A:	ld a,01h                         ; 533A
	call read_joy                          ; 533C
	and 10h                                ; 533F
	ret nz                                 ; 5341
	jr L533A                               ; 5342
L5344:	ld de,L537D                      ; 5344
	ld a,01h                               ; 5347
	call print                             ; 5349
L534C:	ld a,02h                         ; 534C
	call read_joy                          ; 534E
	and 10h                                ; 5351
	ret nz                                 ; 5353
	jr L534C                               ; 5354
	defb 4Fh,35h,56h,31h,31h,4Ch,36h,34h,00h; 5356
L535F:	defb 43h,45h                     ; 535F
L5361:	defb 00h                         ; 5361
L5362:	defb 2Dh,00h                     ; 5362
L5364:	defb 4Bh,65h,79h,20h,77h,6Fh,72h,64h,20h,00h; 5364
L536E:	defb 48h,69h,74h,20h,00h         ; 536E
L5373:	defb 53h,50h,41h,43h,45h,20h,4Bh,45h,59h,00h; 5373
L537D:	defb 54h,52h,49h,47h,47h,45h,52h,00h; 537D
draw_field_bg:	call L3F19               ; 5385
	xor a                                  ; 5388
	ld (L3F4A),a                           ; 5389
	call L3F43                             ; 538C
	ld a,82h                               ; 538F
	; SAPI: MZ: OUT (0CCh),A: GDG write format (wf_set).
	rst 08h
	nop
	; SAPI: the MZ code below fills the field into the VRAM: replaced by fill_field_s.
	jp fill_field_s
	ld c,16h                               ; 5396
L5398:	push hl                          ; 5398
	ld hl,L5C65                            ; 5399
	ld (L53A4),hl                          ; 539C
	pop hl                                 ; 539F
	ld b,08h                               ; 53A0
L53A2:	push bc                          ; 53A2
	ld a,(L0000)                           ; 53A3
L53A4            equ $-2
	ld c,a                                 ; 53A6
	ld b,28h                               ; 53A7
L53A9:	ld (hl),c                        ; 53A9
	inc hl                                 ; 53AA
	djnz L53A9                             ; 53AB
	push hl                                ; 53AD
	ld hl,(L53A4)                          ; 53AE
	inc hl                                 ; 53B1
	ld (L53A4),hl                          ; 53B2
	pop hl                                 ; 53B5
	pop bc                                 ; 53B6
	djnz L53A2                             ; 53B7
	dec c                                  ; 53B9
	jr nz,L5398                            ; 53BA
field_bg_end:
	ld a,03h                               ; 53BC
	ld (text_colour),a                     ; 53BE
	ld a,01h                               ; 53C1
	ld (L3EE9),a                           ; 53C3
	ld hl,0A10h                            ; 53C6
	ld de,L6F81                            ; 53C9
	call vaddr_field                       ; 53CC
	call print_big                         ; 53CF
	call clr8                              ; 53D2
	inc hl                                 ; 53D5
	ld a,(stage)                           ; 53D6
	ld d,00h                               ; 53D9
	ld e,a                                 ; 53DB
	call print_num                         ; 53DC
	ret                                    ; 53DF
load_stage:	ld hl,stage_data            ; 53E0
	ld a,(stage)                           ; 53E3
	ld c,a                                 ; 53E6
	ld d,00h                               ; 53E7
L53E9:	dec c                            ; 53E9
	jr z,L53FE                             ; 53EA
	ld e,1Eh                               ; 53EC
	add hl,de                              ; 53EE
	ld b,04h                               ; 53EF
L53F1:	ld a,(hl)                        ; 53F1
	inc hl                                 ; 53F2
	add a,a                                ; 53F3
	ld e,a                                 ; 53F4
	add hl,de                              ; 53F5
	djnz L53F1                             ; 53F6
	ld e,04h                               ; 53F8
	add hl,de                              ; 53FA
	jp L53E9                               ; 53FB
L53FE:	ld (L5735),hl                    ; 53FE
	ex de,hl                               ; 5401
	ld hl,map_buf_29                       ; 5402
	ld (L5737),hl                          ; 5405
	ld hl,0101h                            ; 5408
	call vaddr_field                       ; 540B
	ld b,0Ah                               ; 540E
L5410:	push bc                          ; 5410
	call L5429                             ; 5411
	pop bc                                 ; 5414
	djnz L5410                             ; 5415
	ld (L5735),de                          ; 5417
	ld hl,(L5737)                          ; 541B
	ld c,70h                               ; 541E
	ld b,27h                               ; 5420
L5422:	ld (hl),c                        ; 5422
	inc hl                                 ; 5423
	djnz L5422                             ; 5424
	jp L547C                               ; 5426
L5429:	push de                          ; 5429
	call L5432                             ; 542A
	pop de                                 ; 542D
	call L5432                             ; 542E
	ret                                    ; 5431
L5432:	ld b,08h                         ; 5432
	call L5452                             ; 5434
	ld b,08h                               ; 5437
	call L5452                             ; 5439
	ld b,03h                               ; 543C
	call L5452                             ; 543E
	push de                                ; 5441
	ld de,011Ah                            ; 5442
	add hl,de                              ; 5445
	ld de,(L5737)                          ; 5446
	inc de                                 ; 544A
	inc de                                 ; 544B
	ld (L5737),de                          ; 544C
	pop de                                 ; 5450
	ret                                    ; 5451
L5452:	ld a,(de)                        ; 5452
	ld c,a                                 ; 5453
	inc de                                 ; 5454
	push de                                ; 5455
L5456:	rlc c                            ; 5456
	jr c,L5462                             ; 5458
	call clr16x8                           ; 545A
	ld a,00h                               ; 545D
	jp L546A                               ; 545F
L5462:	ld de,L5C3D                      ; 5462
	call put16x8                           ; 5465
	ld a,70h                               ; 5468
L546A:	inc hl                           ; 546A
	inc hl                                 ; 546B
	push hl                                ; 546C
	ld hl,(L5737)                          ; 546D
	ld (hl),a                              ; 5470
	inc hl                                 ; 5471
	ld (hl),a                              ; 5472
	inc hl                                 ; 5473
	ld (L5737),hl                          ; 5474
	pop hl                                 ; 5477
	djnz L5456                             ; 5478
	pop de                                 ; 547A
	ret                                    ; 547B
L547C:	ld hl,(L5735)                    ; 547C
	ld de,L5C9D                            ; 547F
	ld c,50h                               ; 5482
	call L549A                             ; 5484
	ld de,L634D                            ; 5487
	ld c,30h                               ; 548A
	call L549A                             ; 548C
	ld de,L65ED                            ; 548F
	ld c,40h                               ; 5492
	call L549A                             ; 5494
	jp L54C2                               ; 5497
L549A:	ld b,(hl)                        ; 549A
	inc hl                                 ; 549B
	ld a,b                                 ; 549C
	or a                                   ; 549D
	ret z                                  ; 549E
L549F:	push hl                          ; 549F
	ld a,(hl)                              ; 54A0
	inc hl                                 ; 54A1
	ld h,(hl)                              ; 54A2
	ld l,a                                 ; 54A3
	push hl                                ; 54A4
	call vaddr_field                       ; 54A5
	call put16x16                          ; 54A8
	pop hl                                 ; 54AB
	call map_addr                          ; 54AC
	ld (hl),c                              ; 54AF
	inc hl                                 ; 54B0
	ld (hl),c                              ; 54B1
	push de                                ; 54B2
	ld de,0027h                            ; 54B3
	add hl,de                              ; 54B6
	pop de                                 ; 54B7
	ld (hl),c                              ; 54B8
	inc hl                                 ; 54B9
	ld (hl),c                              ; 54BA
	inc c                                  ; 54BB
	pop hl                                 ; 54BC
	inc hl                                 ; 54BD
	inc hl                                 ; 54BE
	djnz L549F                             ; 54BF
	ret                                    ; 54C1
L54C2:	ld de,L6ACD                      ; 54C2
	ld c,10h                               ; 54C5
	ld b,(hl)                              ; 54C7
	inc hl                                 ; 54C8
	ld a,b                                 ; 54C9
	or a                                   ; 54CA
	jp z,L54F2                             ; 54CB
L54CE:	push hl                          ; 54CE
	ld a,(hl)                              ; 54CF
	inc hl                                 ; 54D0
	ld h,(hl)                              ; 54D1
	ld l,a                                 ; 54D2
	ld (L54E5),hl                          ; 54D3
	call map_addr                          ; 54D6
	ld a,(hl)                              ; 54D9
	cp 70h                                 ; 54DA
	jr z,L54E2                             ; 54DC
	cp 00h                                 ; 54DE
	jr nz,L54ED                            ; 54E0
L54E2:	ld (hl),c                        ; 54E2
	inc c                                  ; 54E3
	ld hl,0000h                            ; 54E4
L54E5            equ $-2
	call vaddr_field                       ; 54E7
	call put8x8                            ; 54EA
L54ED:	pop hl                           ; 54ED
	inc hl                                 ; 54EE
	inc hl                                 ; 54EF
	djnz L54CE                             ; 54F0
L54F2:	ld e,(hl)                        ; 54F2
	inc hl                                 ; 54F3
	ld d,(hl)                              ; 54F4
	inc hl                                 ; 54F5
	push hl                                ; 54F6
	ex de,hl                               ; 54F7
	push hl                                ; 54F8
	call vaddr_field                       ; 54F9
	ld de,L5D9D                            ; 54FC
	call put16x16                          ; 54FF
	pop hl                                 ; 5502
	call map_addr                          ; 5503
	ld c,60h                               ; 5506
	ld (hl),c                              ; 5508
	inc hl                                 ; 5509
	ld (hl),c                              ; 550A
	ld de,0027h                            ; 550B
	add hl,de                              ; 550E
	ld (hl),c                              ; 550F
	inc hl                                 ; 5510
	ld (hl),c                              ; 5511
	pop hl                                 ; 5512
	ld e,(hl)                              ; 5513
	inc hl                                 ; 5514
	ld d,(hl)                              ; 5515
	ex de,hl                               ; 5516
	push hl                                ; 5517
	call vaddr_field                       ; 5518
	ld de,L5C6D                            ; 551B
	call put16x8                           ; 551E
	pop hl                                 ; 5521
	call map_addr                          ; 5522
	ld c,80h                               ; 5525
	ld (hl),c                              ; 5527
	inc hl                                 ; 5528
	ld (hl),c                              ; 5529
	ld ix,(L5735)                          ; 552A
	ld a,(ix+0)                            ; 552E
	ld (L5BED),a                           ; 5531
	inc ix                                 ; 5534
	and a                                  ; 5536
	jp z,L5575                             ; 5537
	ld iy,L50AC                            ; 553A
	ld de,0008h                            ; 553E
L5541:	push af                          ; 5541
	ld c,(ix+0)                            ; 5542
	ld b,(ix+1)                            ; 5545
	ld (iy+0),c                            ; 5548
	ld (iy+1),b                            ; 554B
	ld h,b                                 ; 554E
	ld l,c                                 ; 554F
	call map_addr                          ; 5550
	ld (iy+2),l                            ; 5553
	ld (iy+3),h                            ; 5556
	ld h,b                                 ; 5559
	ld l,c                                 ; 555A
	call vaddr_field                       ; 555B
	ld (iy+4),l                            ; 555E
	ld (iy+5),h                            ; 5561
	xor a                                  ; 5564
	ld (iy+6),a                            ; 5565
	ld (iy+7),a                            ; 5568
	inc ix                                 ; 556B
	inc ix                                 ; 556D
	add iy,de                              ; 556F
	pop af                                 ; 5571
	dec a                                  ; 5572
	jr nz,L5541                            ; 5573
L5575:	ld a,(ix+0)                      ; 5575
	ld (L5033),a                           ; 5578
	inc ix                                 ; 557B
	and a                                  ; 557D
	jp z,L55D3                             ; 557E
	ld hl,L5094                            ; 5581
	ld c,00h                               ; 5584
	ld b,a                                 ; 5586
L5587:	ld (hl),c                        ; 5587
	inc hl                                 ; 5588
	djnz L5587                             ; 5589
	ld hl,L5034                            ; 558B
	ld de,L5054                            ; 558E
	ld bc,L5074                            ; 5591
L5594:	push af                          ; 5594
	push hl                                ; 5595
	push hl                                ; 5596
	pop iy                                 ; 5597
	ld l,(ix+0)                            ; 5599
	ld h,(ix+1)                            ; 559C
	ld (iy+0),l                            ; 559F
	ld (iy+1),h                            ; 55A2
	push de                                ; 55A5
	pop iy                                 ; 55A6
	call map_addr                          ; 55A8
	ld (iy+0),l                            ; 55AB
	ld (iy+1),h                            ; 55AE
	push bc                                ; 55B1
	pop iy                                 ; 55B2
	ld l,(ix+0)                            ; 55B4
	ld h,(ix+1)                            ; 55B7
	call vaddr_field                       ; 55BA
	ld (iy+0),l                            ; 55BD
	ld (iy+1),h                            ; 55C0
	pop hl                                 ; 55C3
	inc ix                                 ; 55C4
	inc ix                                 ; 55C6
	inc hl                                 ; 55C8
	inc hl                                 ; 55C9
	inc de                                 ; 55CA
	inc de                                 ; 55CB
	inc bc                                 ; 55CC
	inc bc                                 ; 55CD
	pop af                                 ; 55CE
	dec a                                  ; 55CF
	jp nz,L5594                            ; 55D0
L55D3:	ld a,(ix+0)                      ; 55D3
	ld (L425D),a                           ; 55D6
	inc ix                                 ; 55D9
	and a                                  ; 55DB
	jp z,L560F                             ; 55DC
	ld iy,L425E                            ; 55DF
	ld de,0008h                            ; 55E3
	ld c,00h                               ; 55E6
	ld b,a                                 ; 55E8
L55E9:	ld l,(ix+0)                      ; 55E9
	ld h,(ix+1)                            ; 55EC
	ld (iy+0),l                            ; 55EF
	ld (iy+1),h                            ; 55F2
	ld (iy+2),c                            ; 55F5
	ld (iy+3),c                            ; 55F8
	ld (iy+4),c                            ; 55FB
	ld (iy+5),c                            ; 55FE
	ld (iy+6),c                            ; 5601
	ld (iy+7),c                            ; 5604
	inc ix                                 ; 5607
	inc ix                                 ; 5609
	add iy,de                              ; 560B
	djnz L55E9                             ; 560D
L560F:	ld a,(ix+0)                      ; 560F
	ld (L46EB),a                           ; 5612
	inc ix                                 ; 5615
	and a                                  ; 5617
	jp z,L5642                             ; 5618
	ld iy,L46EC                            ; 561B
	ld de,0005h                            ; 561F
	ld c,00h                               ; 5622
	ld b,a                                 ; 5624
L5625:	ld l,(ix+0)                      ; 5625
	ld h,(ix+1)                            ; 5628
	ld (iy+0),l                            ; 562B
	ld (iy+1),h                            ; 562E
	ld (iy+2),c                            ; 5631
	ld (iy+3),c                            ; 5634
	ld (iy+4),c                            ; 5637
	inc ix                                 ; 563A
	inc ix                                 ; 563C
	add iy,de                              ; 563E
	djnz L5625                             ; 5640
L5642:	ld iy,L50A4                      ; 5642
	ld l,(ix+0)                            ; 5646
	ld h,(ix+1)                            ; 5649
	ld (iy+0),l                            ; 564C
	ld (iy+1),h                            ; 564F
	call map_addr                          ; 5652
	ld (iy+2),l                            ; 5655
	ld (iy+3),h                            ; 5658
	ld l,(ix+0)                            ; 565B
	ld h,(ix+1)                            ; 565E
	call vaddr_field                       ; 5661
	ld (iy+4),l                            ; 5664
	ld (iy+5),h                            ; 5667
	xor a                                  ; 566A
	ld (iy+6),a                            ; 566B
	ld (iy+7),a                            ; 566E
	ret                                    ; 5671
L5672:	ld hl,8141h                      ; 5672
	ld b,04h                               ; 5675
	jr L5682                               ; 5677
L5679:	call clr16x8                     ; 5679
	push de                                ; 567C
	ld de,0140h                            ; 567D
	add hl,de                              ; 5680
	pop de                                 ; 5681
L5682:	ld de,L625D                      ; 5682
	call put16x16                          ; 5685
	ld a,0Ch                               ; 5688
	call delay                             ; 568A
	ld de,L629D                            ; 568D
	call put16x16                          ; 5690
	ld a,0Ch                               ; 5693
	call delay                             ; 5695
	djnz L5679                             ; 5698
	ld de,L5DDD                            ; 569A
	ld (L502D),hl                          ; 569D
	call put16x16                          ; 56A0
	xor a                                  ; 56A3
	ld (player_state),a                    ; 56A4
	ld a,01h                               ; 56A7
	ld (L5030),a                           ; 56A9
	ld a,02h                               ; 56AC
	ld (L5031),a                           ; 56AE
	ld hl,0101h                            ; 56B1
	ld (L5029),hl                          ; 56B4
	call map_addr                          ; 56B7
	ld (L502B),hl                          ; 56BA
	ld a,20h                               ; 56BD
	ld de,0027h                            ; 56BF
	ld (hl),a                              ; 56C2
	inc hl                                 ; 56C3
	ld (hl),a                              ; 56C4
	add hl,de                              ; 56C5
	ld (hl),a                              ; 56C6
	inc hl                                 ; 56C7
	ld (hl),a                              ; 56C8
	ld hl,83C1h                            ; 56C9
	ld de,L5C3D                            ; 56CC
	call put16x8                           ; 56CF
	ld a,28h                               ; 56D2
	call delay                             ; 56D4
	ld a,(lives)                           ; 56D7
	cp 02h                                 ; 56DA
	ret c                                  ; 56DC
	ld hl,8143h                            ; 56DD
	call L56F2                             ; 56E0
	call L56FF                             ; 56E3
	call L56F2                             ; 56E6
	call L56FF                             ; 56E9
	call L56F2                             ; 56EC
	jp L571D                               ; 56EF
L56F2:	ld de,L605D                      ; 56F2
	push hl                                ; 56F5
	call L5710                             ; 56F6
	pop hl                                 ; 56F9
	ld a,1Eh                               ; 56FA
	jp delay                               ; 56FC
L56FF:	dec hl                           ; 56FF
	ld de,L609D                            ; 5700
	push hl                                ; 5703
	call L5710                             ; 5704
	call clr8x16                           ; 5707
	pop hl                                 ; 570A
	ld a,0Fh                               ; 570B
	jp delay                               ; 570D
L5710:	ld a,(lives)                     ; 5710
	dec a                                  ; 5713
	ld b,a                                 ; 5714
L5715:	call put16x16                    ; 5715
	inc hl                                 ; 5718
	inc hl                                 ; 5719
	djnz L5715                             ; 571A
	ret                                    ; 571C
L571D:	ld hl,8141h                      ; 571D
	ld de,L5DDD                            ; 5720
	ld a,(lives)                           ; 5723
	dec a                                  ; 5726
	ld b,a                                 ; 5727
L5728:	call put16x16                    ; 5728
	ld a,28h                               ; 572B
	call delay                             ; 572D
	inc hl                                 ; 5730
	inc hl                                 ; 5731
	djnz L5728                             ; 5732
	ret                                    ; 5734
L5735:	defb 00h,00h                     ; 5735
L5737:	defb 00h,00h                     ; 5737
clear_map:	ld hl,8000h                  ; 5739
	ld de,L5C5D                            ; 573C
	call pattern_rows                      ; 573F
	call pattern_cols4                     ; 5742
	call pattern_cols4                     ; 5745
	call pattern_rows                      ; 5748
	ld b,14h                               ; 574B
L574D:	push bc                          ; 574D
	call pattern_cols2                     ; 574E
	pop bc                                 ; 5751
	djnz L574D                             ; 5752
	call pattern_rows                      ; 5754
	ld hl,map_buf                          ; 5757
	ld c,70h                               ; 575A
	ld b,28h                               ; 575C
L575E:	ld (hl),c                        ; 575E
	inc hl                                 ; 575F
	djnz L575E                             ; 5760
	ld de,0027h                            ; 5762
	ld b,14h                               ; 5765
L5767:	ld (hl),c                        ; 5767
	add hl,de                              ; 5768
	ld (hl),c                              ; 5769
	inc hl                                 ; 576A
	djnz L5767                             ; 576B
	ld b,28h                               ; 576D
L576F:	ld (hl),c                        ; 576F
	inc hl                                 ; 5770
	djnz L576F                             ; 5771
	ld hl,814Dh                            ; 5773
	ld de,L6DDD                            ; 5776
	ld a,02h                               ; 5779
	ld (text_colour),a                     ; 577B
	call print_big                         ; 577E
	call L3EED                             ; 5781
	ld hl,815Ch                            ; 5784
	ld de,L6E06                            ; 5787
	call print_big                         ; 578A
	call L3F19                             ; 578D
	ld hl,829Dh                            ; 5790
	ld de,L6E27                            ; 5793
	ld a,03h                               ; 5796
	ld (text_colour),a                     ; 5798
	call print_big                         ; 579B
	ld hl,8141h                            ; 579E
	ld de,L5DDD                            ; 57A1
	ld a,(lives)                           ; 57A4
	ld b,a                                 ; 57A7
L57A8:	call put16x16                    ; 57A8
	inc hl                                 ; 57AB
	inc hl                                 ; 57AC
	djnz L57A8                             ; 57AD
	call L3F43                             ; 57AF
	ret                                    ; 57B2
pattern_rows:	push hl                   ; 57B3
	; SAPI: MZ: LD HL,L57DF (the routine writes into the VRAM).
	ld hl,pat_rows_s
	jp pattern_draw                        ; 57B7
pattern_cols4:	push hl                  ; 57BA
	; SAPI: MZ: LD HL,L57F3 (the routine writes into the VRAM).
	ld hl,pat_cols4_s
	jp pattern_draw                        ; 57BE
pattern_cols2:	push hl                  ; 57C1
	; SAPI: MZ: LD HL,L580D (the routine writes into the VRAM).
	ld hl,pat_cols2_s
	; SAPI: MZ: LD (L57CF),HL, the code below sets the WF register.
pattern_draw:	jp pattern_draw_s
	ld (L57D7),hl                          ; 57C8
	pop hl                                 ; 57CB
	push de                                ; 57CC
	push hl                                ; 57CD
	call L0000                             ; 57CE
L57CF            equ $-2
	pop hl                                 ; 57D1
	ld a,82h                               ; 57D2
	out (0CCh),a                           ; 57D4
	call L0000                             ; 57D6
L57D7            equ $-2
	ld a,21h                               ; 57D9
	out (0CCh),a                           ; 57DB
	pop de                                 ; 57DD
	ret                                    ; 57DE
L57DF:	ld c,08h                         ; 57DF
L57E1:	ld a,(de)                        ; 57E1
	inc de                                 ; 57E2
	ld b,0Ah                               ; 57E3
L57E5:	ld (hl),a                        ; 57E5
	inc hl                                 ; 57E6
	ld (hl),a                              ; 57E7
	inc hl                                 ; 57E8
	ld (hl),a                              ; 57E9
	inc hl                                 ; 57EA
	ld (hl),a                              ; 57EB
	inc hl                                 ; 57EC
	djnz L57E5                             ; 57ED
	dec c                                  ; 57EF
	jr nz,L57E1                            ; 57F0
	ret                                    ; 57F2
L57F3:	ld b,08h                         ; 57F3
L57F5:	ld a,(de)                        ; 57F5
	inc de                                 ; 57F6
	push de                                ; 57F7
	ld (hl),a                              ; 57F8
	ld de,000Bh                            ; 57F9
	add hl,de                              ; 57FC
	ld (hl),a                              ; 57FD
	ld de,000Fh                            ; 57FE
	add hl,de                              ; 5801
	ld (hl),a                              ; 5802
	ld de,000Dh                            ; 5803
	add hl,de                              ; 5806
	ld (hl),a                              ; 5807
	inc hl                                 ; 5808
	pop de                                 ; 5809
	djnz L57F5                             ; 580A
	ret                                    ; 580C
L580D:	ld b,08h                         ; 580D
L580F:	ld a,(de)                        ; 580F
	inc de                                 ; 5810
	ld (hl),a                              ; 5811
	push de                                ; 5812
	ld de,0027h                            ; 5813
	add hl,de                              ; 5816
	pop de                                 ; 5817
	ld (hl),a                              ; 5818
	inc hl                                 ; 5819
	djnz L580F                             ; 581A
	ret                                    ; 581C
L581D:	xor a                            ; 581D
	ld (L5BEE),a                           ; 581E
	ld a,(L5BED)                           ; 5821
	inc a                                  ; 5824
	ld (L5835),a                           ; 5825
	ld hl,L5BF1                            ; 5828
	ld d,13h                               ; 582B
L582D:	ld ix,L50A4                      ; 582D
	ld e,d                                 ; 5831
	ld d,00h                               ; 5832
	ld b,00h                               ; 5834
L5835            equ $-1
L5836:	ld a,(ix+6)                      ; 5836
	cp 06h                                 ; 5839
	jr nc,L585B                            ; 583B
	ld a,(ix+1)                            ; 583D
	cp e                                   ; 5840
	jr z,L584B                             ; 5841
	jr nc,L585B                            ; 5843
	cp d                                   ; 5845
	jr c,L585B                             ; 5846
	ld d,a                                 ; 5848
	jr L585B                               ; 5849
L584B:	push de                          ; 584B
	push ix                                ; 584C
	pop de                                 ; 584E
	ld (hl),e                              ; 584F
	inc hl                                 ; 5850
	ld (hl),d                              ; 5851
	inc hl                                 ; 5852
	pop de                                 ; 5853
	ld a,(L5BEE)                           ; 5854
	inc a                                  ; 5857
	ld (L5BEE),a                           ; 5858
L585B:	push de                          ; 585B
	ld de,0008h                            ; 585C
	add ix,de                              ; 585F
	pop de                                 ; 5861
	djnz L5836                             ; 5862
	ld a,d                                 ; 5864
	and a                                  ; 5865
	jp nz,L582D                            ; 5866
	ld hl,L5BF1                            ; 5869
	ld (L5BEF),hl                          ; 586C
	ld a,(L5BEE)                           ; 586F
L5872:	push af                          ; 5872
	ld hl,(L5BEF)                          ; 5873
	ld a,(hl)                              ; 5876
	inc hl                                 ; 5877
	ld h,(hl)                              ; 5878
	ld l,a                                 ; 5879
	push hl                                ; 587A
	pop ix                                 ; 587B
	ld a,(ix+6)                            ; 587D
	and a                                  ; 5880
	jp nz,L5987                            ; 5881
	ld l,(ix+2)                            ; 5884
	ld h,(ix+3)                            ; 5887
	ld de,0050h                            ; 588A
	add hl,de                              ; 588D
	ld (L58F8),hl                          ; 588E
	ld a,(hl)                              ; 5891
	ld (L5C13),a                           ; 5892
	and 0F0h                               ; 5895
	cp 50h                                 ; 5897
	jp nc,L5951                            ; 5899
	inc hl                                 ; 589C
	ld a,(hl)                              ; 589D
	ld (L5C14),a                           ; 589E
	and 0F0h                               ; 58A1
	cp 50h                                 ; 58A3
	jp nc,L5951                            ; 58A5
	ld a,(L5C13)                           ; 58A8
	and 0Fh                                ; 58AB
	cp 0Fh                                 ; 58AD
	jp z,L58F7                             ; 58AF
	ld a,(L5C14)                           ; 58B2
	and 0Fh                                ; 58B5
	cp 0Fh                                 ; 58B7
	jp z,L58F7                             ; 58B9
	ld a,(L5C13)                           ; 58BC
	ld c,a                                 ; 58BF
	and 0F0h                               ; 58C0
	cp 20h                                 ; 58C2
	jp c,L58D4                             ; 58C4
	call z,L5A13                           ; 58C7
	cp 30h                                 ; 58CA
	call z,L5A8A                           ; 58CC
	cp 40h                                 ; 58CF
	call z,L5B0E                           ; 58D1
L58D4:	ld a,(L5C13)                     ; 58D4
	ld c,a                                 ; 58D7
	ld a,(L5C14)                           ; 58D8
	cp c                                   ; 58DB
	jp z,L58F7                             ; 58DC
	ld a,(L5C14)                           ; 58DF
	ld c,a                                 ; 58E2
	and 0F0h                               ; 58E3
	cp 20h                                 ; 58E5
	jp c,L58F7                             ; 58E7
	call z,L5A13                           ; 58EA
	cp 30h                                 ; 58ED
	call z,L5A8A                           ; 58EF
	cp 40h                                 ; 58F2
	call z,L5B0E                           ; 58F4
L58F7:	ld hl,0000h                      ; 58F7
L58F8            equ L58F7+1
	ld a,(hl)                              ; 58FA
	and 0F0h                               ; 58FB
	cp 20h                                 ; 58FD
	jp nc,L5955                            ; 58FF
	inc hl                                 ; 5902
	ld a,(hl)                              ; 5903
	and 0F0h                               ; 5904
	cp 20h                                 ; 5906
	jp nc,L5955                            ; 5908
	inc (ix+1)                             ; 590B
	ld l,(ix+2)                            ; 590E
	ld h,(ix+3)                            ; 5911
	ld c,(hl)                              ; 5914
	ld a,00h                               ; 5915
	ld (hl),a                              ; 5917
	inc hl                                 ; 5918
	ld (hl),a                              ; 5919
	dec hl                                 ; 591A
	ld de,0028h                            ; 591B
	add hl,de                              ; 591E
	ld (ix+2),l                            ; 591F
	ld (ix+3),h                            ; 5922
	add hl,de                              ; 5925
	ld (hl),c                              ; 5926
	inc hl                                 ; 5927
	ld (hl),c                              ; 5928
	ld l,(ix+4)                            ; 5929
	ld h,(ix+5)                            ; 592C
	call clr16x8                           ; 592F
	ld de,0140h                            ; 5932
	add hl,de                              ; 5935
	ld a,c                                 ; 5936
	and 0F0h                               ; 5937
	cp 60h                                 ; 5939
	jr z,L5942                             ; 593B
	ld de,L5C9D                            ; 593D
	jr L5945                               ; 5940
L5942:	ld de,L5D9D                      ; 5942
L5945:	ld (ix+4),l                      ; 5945
	ld (ix+5),h                            ; 5948
	call put16x16                          ; 594B
	jp L5955                               ; 594E
L5951:	ld (ix+7),00h                    ; 5951
L5955:	ld hl,(L5BEF)                    ; 5955
	inc hl                                 ; 5958
	inc hl                                 ; 5959
	ld (L5BEF),hl                          ; 595A
	pop af                                 ; 595D
	dec a                                  ; 595E
	jp nz,L5872                            ; 595F
	ld a,00h                               ; 5962
L5963            equ $-1
	and a                                  ; 5964
	jp z,L5971                             ; 5965
	ld a,81h                               ; 5968
	ld (player_state),a                    ; 596A
	xor a                                  ; 596D
	ld (L5963),a                           ; 596E
L5971:	ld hl,(L50A6)                    ; 5971
	ld de,0050h                            ; 5974
	add hl,de                              ; 5977
	ld a,(hl)                              ; 5978
	cp 80h                                 ; 5979
	ret nz                                 ; 597B
	inc hl                                 ; 597C
	ld a,(hl)                              ; 597D
	cp 80h                                 ; 597E
	ret nz                                 ; 5980
	ld a,01h                               ; 5981
	ld (stage_clear),a                     ; 5983
	ret                                    ; 5986
L5987:	cp 06h                           ; 5987
	jr nc,L5955                            ; 5989
	inc a                                  ; 598B
	ld (ix+6),a                            ; 598C
	dec a                                  ; 598F
	ld l,(ix+4)                            ; 5990
	ld h,(ix+5)                            ; 5993
	dec a                                  ; 5996
	jr z,L59C1                             ; 5997
	dec a                                  ; 5999
	jr z,L59DC                             ; 599A
	dec a                                  ; 599C
	jr z,L59E5                             ; 599D
	dec a                                  ; 599F
	jr z,L5A06                             ; 59A0
	ld l,(ix+2)                            ; 59A2
	ld h,(ix+3)                            ; 59A5
	ld de,0028h                            ; 59A8
	add hl,de                              ; 59AB
	ld c,00h                               ; 59AC
	ld (hl),c                              ; 59AE
	inc hl                                 ; 59AF
	ld (hl),c                              ; 59B0
	ld l,(ix+4)                            ; 59B1
	ld h,(ix+5)                            ; 59B4
	ld de,0140h                            ; 59B7
	add hl,de                              ; 59BA
	call clr16x8                           ; 59BB
	jp L5955                               ; 59BE
L59C1:	ld de,L5CDD                      ; 59C1
	call put16x16                          ; 59C4
	ld l,(ix+2)                            ; 59C7
	ld h,(ix+3)                            ; 59CA
	ld c,70h                               ; 59CD
	ld (hl),c                              ; 59CF
	inc hl                                 ; 59D0
	ld (hl),c                              ; 59D1
	ld de,0027h                            ; 59D2
	add hl,de                              ; 59D5
	ld (hl),c                              ; 59D6
	inc hl                                 ; 59D7
	ld (hl),c                              ; 59D8
	jp L5955                               ; 59D9
L59DC:	ld de,L5D1D                      ; 59DC
	call put16x16                          ; 59DF
	jp L5955                               ; 59E2
L59E5:	call clr16x8                     ; 59E5
	ld l,(ix+2)                            ; 59E8
	ld h,(ix+3)                            ; 59EB
	ld c,00h                               ; 59EE
	ld (hl),c                              ; 59F0
	inc hl                                 ; 59F1
	ld (hl),c                              ; 59F2
	ld l,(ix+4)                            ; 59F3
	ld h,(ix+5)                            ; 59F6
	ld de,0140h                            ; 59F9
	add hl,de                              ; 59FC
	ld de,L5D5D                            ; 59FD
	call put16x8                           ; 5A00
	jp L5955                               ; 5A03
L5A06:	ld de,0140h                      ; 5A06
	add hl,de                              ; 5A09
	ld de,L5D7D                            ; 5A0A
	call put16x8                           ; 5A0D
	jp L5955                               ; 5A10
L5A13:	push af                          ; 5A13
	ld a,(player_state)                    ; 5A14
	cp 80h                                 ; 5A17
	jp nc,L5A88                            ; 5A19
	and 7Fh                                ; 5A1C
	jp nz,L5A6B                            ; 5A1E
	ld hl,(L5029)                          ; 5A21
	call map_addr                          ; 5A24
	ld c,00h                               ; 5A27
	ld (hl),c                              ; 5A29
	inc hl                                 ; 5A2A
	ld (hl),c                              ; 5A2B
	ld de,0027h                            ; 5A2C
	add hl,de                              ; 5A2F
	ld (L502B),hl                          ; 5A30
	ld c,2Fh                               ; 5A33
	ld (hl),c                              ; 5A35
	inc hl                                 ; 5A36
	ld (hl),c                              ; 5A37
	ld a,(L5028)                           ; 5A38
	and a                                  ; 5A3B
	jr z,L5A5C                             ; 5A3C
	cp 03h                                 ; 5A3E
	jr nc,L5A5C                            ; 5A40
	ld a,(L2245)                           ; 5A42
	and a                                  ; 5A45
	jr z,L5A5C                             ; 5A46
	ld de,0027h                            ; 5A48
	add hl,de                              ; 5A4B
	ld c,00h                               ; 5A4C
	ld (hl),c                              ; 5A4E
	inc hl                                 ; 5A4F
	ld (hl),c                              ; 5A50
	ld hl,(L5029)                          ; 5A51
	inc h                                  ; 5A54
	inc h                                  ; 5A55
	call vaddr_field                       ; 5A56
	call clr16x8                           ; 5A59
L5A5C:	ld hl,(L5029)                    ; 5A5C
	call vaddr_field                       ; 5A5F
	call clr16x8                           ; 5A62
	ld de,0140h                            ; 5A65
	add hl,de                              ; 5A68
	jr L5A7A                               ; 5A69
L5A6B:	ld hl,(L5029)                    ; 5A6B
	call map_addr                          ; 5A6E
	ld (L502B),hl                          ; 5A71
	ld hl,(L5029)                          ; 5A74
	call vaddr_field                       ; 5A77
L5A7A:	ld (L502D),hl                    ; 5A7A
	ld de,L631D                            ; 5A7D
	call put16x8                           ; 5A80
	ld a,01h                               ; 5A83
	ld (L5963),a                           ; 5A85
L5A88:	pop af                           ; 5A88
	ret                                    ; 5A89
L5A8A:	push af                          ; 5A8A
	ld a,c                                 ; 5A8B
	and 0Fh                                ; 5A8C
	ld de,0000h                            ; 5A8E
	jr z,L5A98                             ; 5A91
	ld b,a                                 ; 5A93
L5A94:	inc de                           ; 5A94
	inc de                                 ; 5A95
	djnz L5A94                             ; 5A96
L5A98:	ld (L5AF7),de                    ; 5A98
	ld iy,L5034                            ; 5A9C
	add iy,de                              ; 5AA0
	ld a,(iy+1)                            ; 5AA2
	and a                                  ; 5AA5
	jr nz,L5AAA                            ; 5AA6
L5AA8:	pop af                           ; 5AA8
	ret                                    ; 5AA9
L5AAA:	xor a                            ; 5AAA
	ld (iy+0),a                            ; 5AAB
	ld (iy+1),a                            ; 5AAE
	ld hl,L5094                            ; 5AB1
	ld d,00h                               ; 5AB4
	ld a,c                                 ; 5AB6
	and 0Fh                                ; 5AB7
	ld e,a                                 ; 5AB9
	add hl,de                              ; 5ABA
	ld (hl),00h                            ; 5ABB
	ld hl,L5054                            ; 5ABD
	call L5AED                             ; 5AC0
	ld c,00h                               ; 5AC3
	ld (hl),c                              ; 5AC5
	inc hl                                 ; 5AC6
	ld (hl),c                              ; 5AC7
	ld de,0027h                            ; 5AC8
	add hl,de                              ; 5ACB
	ld c,3Fh                               ; 5ACC
	ld (hl),c                              ; 5ACE
	inc hl                                 ; 5ACF
	ld (hl),c                              ; 5AD0
	ld hl,L5074                            ; 5AD1
	call L5AED                             ; 5AD4
	call clr16x8                           ; 5AD7
	ld de,0140h                            ; 5ADA
	add hl,de                              ; 5ADD
	ld de,L65CD                            ; 5ADE
	call put16x8                           ; 5AE1
	ld de,0003h                            ; 5AE4
	call L5AF9                             ; 5AE7
	jp L5AA8                               ; 5AEA
L5AED:	ld de,(L5AF7)                    ; 5AED
	add hl,de                              ; 5AF1
	ld e,(hl)                              ; 5AF2
	inc hl                                 ; 5AF3
	ld d,(hl)                              ; 5AF4
	ex de,hl                               ; 5AF5
	ret                                    ; 5AF6
L5AF7:	defb 00h,00h                     ; 5AF7
L5AF9:	ld b,(ix+7)                      ; 5AF9
	inc b                                  ; 5AFC
	ld (ix+7),b                            ; 5AFD
	ld hl,(L3F06)                          ; 5B00
L5B03:	add hl,de                        ; 5B03
	djnz L5B03                             ; 5B04
	ld (L3F06),hl                          ; 5B06
	call L3EED                             ; 5B09
	ret                                    ; 5B0C
	defb 0F5h                              ; 5B0D
L5B0E:	push af                          ; 5B0E
	ld iy,L425E                            ; 5B0F
	ld a,c                                 ; 5B13
	and 0Fh                                ; 5B14
	jr z,L5B20                             ; 5B16
	ld de,0008h                            ; 5B18
	ld b,a                                 ; 5B1B
L5B1C:	add iy,de                        ; 5B1C
	djnz L5B1C                             ; 5B1E
L5B20:	ld a,(iy+1)                      ; 5B20
	and a                                  ; 5B23
	jp nz,L5B29                            ; 5B24
L5B27:	pop af                           ; 5B27
	ret                                    ; 5B28
L5B29:	ld a,(iy+5)                      ; 5B29
	cp 02h                                 ; 5B2C
	jp nc,L5BA4                            ; 5B2E
	ld a,(iy+4)                            ; 5B31
	and a                                  ; 5B34
	jp z,L5BA4                             ; 5B35
	ld l,(iy+0)                            ; 5B38
	ld h,(iy+1)                            ; 5B3B
	ld a,(iy+2)                            ; 5B3E
	ld (iy+2),00h                          ; 5B41
	dec a                                  ; 5B45
	jr z,L5B51                             ; 5B46
	dec a                                  ; 5B48
	jr z,L5B68                             ; 5B49
	dec a                                  ; 5B4B
	jr z,L5B6D                             ; 5B4C
	jp L5B91                               ; 5B4E
L5B51:	inc h                            ; 5B51
	dec (iy+1)                             ; 5B52
L5B55:	push hl                          ; 5B55
	call map_addr                          ; 5B56
	ld c,00h                               ; 5B59
	ld (hl),c                              ; 5B5B
	inc hl                                 ; 5B5C
	ld (hl),c                              ; 5B5D
	pop hl                                 ; 5B5E
	call vaddr_field                       ; 5B5F
	call clr16x8                           ; 5B62
	jp L5BA4                               ; 5B65
L5B68:	inc h                            ; 5B68
	inc h                                  ; 5B69
	jp L5B55                               ; 5B6A
L5B6D:	ld a,(ix+0)                      ; 5B6D
	sub l                                  ; 5B70
	jr c,L5B8A                             ; 5B71
	dec l                                  ; 5B73
L5B74:	push hl                          ; 5B74
	call map_addr                          ; 5B75
	ld c,00h                               ; 5B78
	ld (hl),c                              ; 5B7A
	ld de,0028h                            ; 5B7B
	add hl,de                              ; 5B7E
	ld (hl),c                              ; 5B7F
	pop hl                                 ; 5B80
	call vaddr_field                       ; 5B81
	call clr8x16                           ; 5B84
	jp L5BA4                               ; 5B87
L5B8A:	inc l                            ; 5B8A
	dec (iy+0)                             ; 5B8B
	jp L5B74                               ; 5B8E
L5B91:	ld a,l                           ; 5B91
	inc a                                  ; 5B92
	sub (ix+0)                             ; 5B93
	jp c,L5B9E                             ; 5B96
	inc l                                  ; 5B99
	inc l                                  ; 5B9A
	jp L5B74                               ; 5B9B
L5B9E:	inc (iy+0)                       ; 5B9E
	jp L5B74                               ; 5BA1
L5BA4:	ld l,(iy+0)                      ; 5BA4
	ld h,(iy+1)                            ; 5BA7
	call map_addr                          ; 5BAA
	ld c,00h                               ; 5BAD
	ld (hl),c                              ; 5BAF
	inc hl                                 ; 5BB0
	ld (hl),c                              ; 5BB1
	ld de,0027h                            ; 5BB2
	add hl,de                              ; 5BB5
	ld c,4Fh                               ; 5BB6
	ld (hl),c                              ; 5BB8
	inc hl                                 ; 5BB9
	ld (hl),c                              ; 5BBA
	ld l,(iy+0)                            ; 5BBB
	ld h,(iy+1)                            ; 5BBE
	call vaddr_field                       ; 5BC1
	call clr16x8                           ; 5BC4
	ld de,0140h                            ; 5BC7
	add hl,de                              ; 5BCA
	ld de,L6AAD                            ; 5BCB
	call put16x8                           ; 5BCE
	ld de,0005h                            ; 5BD1
	call L5AF9                             ; 5BD4
	ld a,(iy+0)                            ; 5BD7
	ld (iy+6),a                            ; 5BDA
	ld a,(iy+1)                            ; 5BDD
	ld (iy+7),a                            ; 5BE0
	xor a                                  ; 5BE3
	ld (iy+0),a                            ; 5BE4
	ld (iy+1),a                            ; 5BE7
	jp L5B27                               ; 5BEA
L5BED:	defb 00h                         ; 5BED
L5BEE:	defb 00h                         ; 5BEE
L5BEF:	defb 00h,00h                     ; 5BEF
L5BF1:	defs 23                          ; 5BF1
	defb 05h,00h,00h,05h,0DCh,05h,04h,01h,00h,01h,01h; 5C08
L5C13:	defb 00h                         ; 5C13
L5C14:	defb 00h                         ; 5C14
L5C15:	defb 05h                         ; 5C15
L5C16:	defb 0DCh,05h                    ; 5C16
L5C18:	defb 04h                         ; 5C18
tick_div:	defb 01h                      ; 5C19
L5C1A:	defb 00h                         ; 5C1A
stage:	defb 01h                         ; 5C1B
keyword_idx:	defb 01h                   ; 5C1C
L5C1D:	defs 32                          ; 5C1D
L5C3D:	defs 16                          ; 5C3D
	defb 7Fh,7Fh,7Fh,7Fh,7Fh,7Fh,00h,00h,0F7h,0F7h,0F7h,0F7h,0F7h,0F7h,00h,00h; 5C4D
L5C5D:	defb 00h,00h,00h,00h,00h,00h,00h,00h; 5C5D
L5C65:	defb 7Fh,7Fh,7Fh,00h,0F7h,0F7h,0F7h,00h; 5C65
L5C6D:	defb 7Fh,7Fh,7Fh,7Fh,7Fh,7Fh,00h,00h,0F7h,0F7h,0F7h,0F7h,0F7h,0F7h,00h,00h; 5C6D
	defs 16                                ; 5C7D
L5C8D:	defb 7Fh,7Fh,7Fh,00h,0F7h,0F7h,0F7h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 5C8D
L5C9D:	defb 00h,00h,00h,0Ah,00h,10h,00h,28h,00h,40h,00h,20h,00h,40h,00h,20h; 5C9D
	defs 16                                ; 5CAD
	defb 50h,15h,0A8h,2Ah,54h,55h,0A2h,0AAh,51h,55h,0AAh,0AAh,55h,55h,0AAh,0AAh; 5CBD
	defb 55h,55h,88h,0AAh,11h,55h,28h,0A8h,51h,54h,82h,2Ah,04h,11h,0A8h,0Ah; 5CCD
L5CDD:	defb 00h,00h,00h,0Ah,00h,10h,00h,08h,00h,40h,00h,20h,00h,40h,00h,20h; 5CDD
	defs 16                                ; 5CED
	defb 10h,15h,28h,2Ah,54h,14h,20h,8Ah,51h,44h,22h,0A0h,05h,51h,8Ah,0A2h; 5CFD
	defb 45h,05h,80h,02h,10h,50h,28h,0A0h,51h,44h,02h,22h,00h,00h,0A8h,08h; 5D0D
L5D1D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Ah,00h,10h,00h,00h; 5D1D
	defb 00h,40h,00h,20h,00h,40h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 5D2D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,10h,15h,28h,2Ah,54h,14h,20h,8Ah; 5D3D
	defb 51h,44h,22h,0A0h,05h,51h,8Ah,0A2h,45h,05h,80h,02h,55h,54h,0AAh,0AAh; 5D4D
L5D5D:	defb 00h,00h,00h,08h,00h,10h,00h,00h,00h,40h,00h,20h,00h,00h,00h,00h; 5D5D
	defb 10h,15h,28h,2Ah,54h,14h,20h,8Ah,51h,44h,0A2h,0A2h,55h,55h,0AAh,0AAh; 5D6D
L5D7D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,08h,00h,40h,00h,00h; 5D7D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,10h,00h,2Ah,0Ah,55h,55h,0AAh,0AAh; 5D8D
L5D9D:	defb 50h,15h,0A8h,2Ah,54h,55h,0A2h,0AAh,51h,55h,0AAh,0AAh,55h,55h,0AAh,0AAh; 5D9D
	defb 55h,55h,88h,0AAh,11h,55h,28h,0A8h,51h,54h,82h,2Ah,04h,11h,0A8h,0Ah; 5DAD
	defb 00h,00h,00h,0Ah,00h,10h,00h,28h,00h,40h,00h,20h,00h,40h,00h,20h; 5DBD
	defs 16                                ; 5DCD
L5DDD:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,17h; 5DDD
	defb 0E8h,17h,6Ch,36h,0FCh,3Fh,0FCh,3Fh,0F8h,1Fh,0F8h,1Fh,0F8h,1Fh,78h,1Eh; 5DED
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,17h; 5DFD
	defb 0E8h,17h,0ECh,37h,0FCh,3Fh,0FCh,3Fh,0F8h,1Fh,0F8h,1Fh,0F8h,1Fh,78h,1Eh; 5E0D
L5E1D:	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,37h,0E8h,37h,6Ch,36h,0FCh,1Fh,0FCh,1Fh; 5E1D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,80h,0Fh,00h,07h,00h,00h,00h,00h,00h,00h; 5E2D
	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,37h,0E8h,37h,0ECh,37h,0FCh,1Fh,0FCh,1Fh; 5E3D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,80h,0Fh,00h,07h,00h,00h,00h,00h,00h,00h; 5E4D
L5E5D:	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0ECh,17h,0ECh,17h,6Ch,36h,0F8h,3Fh,0F8h,3Fh; 5E5D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,0F0h,01h,0E0h,00h,00h,00h,00h,00h,00h,00h; 5E6D
	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0ECh,17h,0ECh,17h,0ECh,37h,0F8h,3Fh,0F8h,3Fh; 5E7D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,0F0h,01h,0E0h,00h,00h,00h,00h,00h,00h,00h; 5E8D
L5E9D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0E0h,01h,0F8h,07h,0FCh,0Fh,0F4h,0Bh; 5E9D
	defb 0F6h,0Bh,36h,0Bh,0FEh,1Fh,0FCh,1Fh,7Ch,1Fh,0BCh,0Fh,0B8h,07h,78h,00h; 5EAD
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0E0h,01h,0F8h,07h,0FEh,0Fh,0F7h,0Bh; 5EBD
	defb 0F7h,0Bh,0F6h,0Bh,0FEh,1Fh,0FCh,1Fh,7Ch,1Fh,0BCh,0Fh,0B8h,07h,78h,00h; 5ECD
L5EDD:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,80h,07h,0E0h,1Fh; 5EDD
	defb 0F0h,3Fh,0D0h,6Fh,0D0h,6Fh,0D8h,6Ch,0F8h,3Fh,0F8h,3Fh,70h,3Fh,00h,1Eh; 5EED
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,80h,07h,0E0h,1Fh; 5EFD
	defb 0F0h,3Fh,0D0h,6Fh,0D0h,6Fh,0D8h,6Fh,0F8h,3Fh,0F8h,3Fh,70h,3Fh,00h,1Eh; 5F0D
L5F1D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,03h,0F0h,0Fh,0F8h,1Fh,0F8h,1Fh; 5F1D
	defb 0F8h,1Fh,0FCh,3Fh,0FCh,3Fh,0FCh,3Fh,0F8h,1Fh,0F8h,1Fh,0F8h,1Fh,78h,1Eh; 5F2D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,03h,0F0h,0Fh,0F8h,1Fh,0F8h,1Fh; 5F3D
	defb 0F8h,1Fh,0FCh,3Fh,0FCh,3Fh,0FCh,3Fh,0F8h,1Fh,0F8h,1Fh,0F8h,1Fh,78h,1Eh; 5F4D
L5F5D:	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0F8h,3Fh,0F8h,3Fh,0FCh,3Fh,0FCh,1Fh,0FCh,1Fh; 5F5D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,80h,0Fh,00h,07h,00h,00h,00h,00h,00h,00h; 5F6D
	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0F8h,3Fh,0F8h,3Fh,0FCh,3Fh,0FCh,1Fh,0FCh,1Fh; 5F7D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,80h,0Fh,00h,07h,00h,00h,00h,00h,00h,00h; 5F8D
L5F9D:	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0FCh,1Fh,0FCh,1Fh,0FCh,3Fh,0F8h,3Fh,0F8h,3Fh; 5F9D
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,0F0h,01h,0E0h,00h,00h,00h,00h,00h,00h,00h; 5FAD
	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0FCh,1Fh,0FCh,1Fh,0FCh,3Fh,0F8h,3Fh,0F8h,3Fh; 5FBD
	defb 0F8h,1Fh,0F8h,1Fh,0F0h,0Fh,0F0h,01h,0E0h,00h,00h,00h,00h,00h,00h,00h; 5FCD
L5FDD:	defb 00h,00h,00h,00h,00h,00h,00h,00h,80h,07h,0E0h,1Fh,0F0h,3Fh,0F8h,3Fh; 5FDD
	defb 0F8h,1Fh,0F8h,0Fh,0F0h,7Fh,0F0h,7Fh,0F0h,7Fh,0F0h,3Fh,0E0h,3Eh,00h,1Eh; 5FED
	defb 00h,00h,00h,00h,00h,00h,00h,00h,80h,07h,0E0h,1Fh,0F0h,3Fh,0F8h,3Fh; 5FFD
	defb 0F8h,7Fh,0F8h,0FFh,0F0h,0FFh,0F0h,7Fh,0F0h,7Fh,0F0h,3Fh,0E0h,3Eh,00h,1Eh; 600D
L601D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0E0h,0Dh,0F8h,1Fh,0FCh,1Fh,0FCh,1Fh; 601D
	defb 0FCh,1Fh,0FEh,0Fh,0FEh,0Fh,0FEh,0Fh,0FCh,0Fh,0FCh,0Fh,0FCh,07h,78h,00h; 602D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0E0h,0Dh,0F8h,1Fh,0FCh,1Fh,0FCh,1Fh; 603D
	defb 0FCh,1Fh,0FEh,0Fh,0FEh,0Fh,0FEh,0Fh,0FCh,0Fh,0FCh,0Fh,0FCh,07h,78h,00h; 604D
L605D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0E0h,03h,0F8h,0Fh,0E8h,1Fh,0E8h,1Fh; 605D
	defb 0ECh,19h,0F8h,17h,0F8h,17h,0F8h,19h,0F8h,1Fh,0F8h,1Fh,0FCh,3Fh,38h,1Ch; 606D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0E0h,03h,0F8h,0Fh,0E8h,1Fh,0ECh,1Fh; 607D
	defb 0ECh,19h,0F8h,17h,0F8h,17h,0F8h,19h,0F8h,1Fh,0F8h,1Fh,0FCh,3Fh,38h,1Ch; 608D
L609D:	defb 00h,00h,00h,00h,00h,00h,00h,1Fh,0C0h,7Fh,40h,0FFh,40h,0FFh,60h,0FFh; 609D
	defb 0C0h,0FFh,0C0h,0DFh,0C0h,0BFh,0C0h,0BFh,0C0h,0C7h,80h,7Fh,00h,1Eh,00h,0Fh; 60AD
	defb 00h,00h,00h,00h,00h,00h,00h,1Fh,0C0h,7Fh,40h,0FFh,60h,0FFh,60h,0FFh; 60BD
	defb 0C0h,0FFh,0C0h,0DFh,0C0h,0BFh,0C0h,0BFh,0C0h,0C7h,80h,7Fh,00h,1Eh,00h,0Fh; 60CD
L60DD:	defb 00h,00h,00h,00h,00h,00h,80h,0Fh,0E0h,3Fh,0A0h,7Fh,0A0h,7Fh,0B0h,79h; 60DD
	defb 0F0h,7Eh,0F0h,0FEh,0F0h,0FDh,0E0h,0FFh,0F0h,7Fh,0F0h,3Fh,0E0h,3Ch,00h,1Ch; 60ED
	defb 00h,00h,00h,00h,00h,00h,80h,0Fh,0E0h,3Fh,0A0h,7Fh,0B0h,7Fh,0B0h,0F9h; 60FD
	defb 0F0h,0FEh,0F0h,0FEh,0F0h,0FDh,0E0h,0FFh,0F0h,7Fh,0F0h,3Fh,0E0h,3Ch,00h,1Ch; 610D
L611D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0F8h,00h,0FEh,03h,0FAh,07h,0FAh,07h; 611D
	defb 7Bh,06h,0BEh,05h,0FEh,05h,0FEh,07h,0FEh,0Fh,0FEh,0Fh,0FEh,0Fh,0Fh,06h; 612D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0F8h,00h,0FEh,03h,0FAh,07h,0FBh,07h; 613D
	defb 7Bh,06h,0BEh,05h,0FEh,05h,0FEh,07h,0FEh,0Fh,0FEh,0Fh,0FEh,0Fh,0Fh,06h; 614D
L615D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,07h,0F0h,1Fh,0F8h,17h,0F8h,17h; 615D
	defb 98h,37h,0E8h,1Fh,0E8h,1Fh,98h,1Fh,0F8h,1Fh,0F8h,1Fh,0FCh,3Fh,38h,1Ch; 616D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,07h,0F0h,1Fh,0F8h,17h,0F8h,37h; 617D
	defb 98h,37h,0E8h,1Fh,0E8h,1Fh,98h,1Fh,0F8h,1Fh,0F8h,1Fh,0FCh,3Fh,38h,1Ch; 618D
L619D:	defb 00h,00h,00h,00h,00h,00h,0F8h,00h,0FEh,03h,0FFh,02h,0FFh,02h,0FFh,06h; 619D
	defb 0FFh,03h,0FBh,03h,0FDh,03h,0FDh,03h,0E3h,03h,0FEh,01h,78h,00h,0F0h,00h; 61AD
	defb 00h,00h,00h,00h,00h,00h,0F8h,00h,0FEh,03h,0FFh,02h,0FFh,06h,0FFh,06h; 61BD
	defb 0FFh,03h,0FBh,03h,0FDh,03h,0FDh,03h,0E3h,03h,0FEh,01h,78h,00h,0F0h,00h; 61CD
L61DD:	defb 00h,00h,00h,00h,00h,00h,0F0h,01h,0FCh,07h,0FEh,05h,0FEh,05h,0F8h,0Dh; 61DD
	defb 0F0h,0Fh,0F7h,0Fh,0F7h,0Fh,0FFh,07h,0FEh,0Fh,0FCh,0Fh,3Ch,07h,38h,00h; 61ED
	defb 00h,00h,00h,00h,00h,00h,0F0h,01h,0FCh,07h,0FEh,05h,0FEh,0Dh,0FEh,0Dh; 61FD
	defb 0FFh,0Fh,0F7h,0Fh,0F7h,0Fh,0FFh,07h,0FEh,0Fh,0FCh,0Fh,3Ch,07h,38h,00h; 620D
L621D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,1Fh,0C0h,7Fh,0E0h,5Fh,0E0h,5Fh; 621D
	defb 0E0h,0DCh,0E0h,7Bh,0E0h,7Bh,0E0h,7Dh,0F0h,7Fh,0F0h,7Fh,0F0h,7Fh,60h,0F0h; 622D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,1Fh,0C0h,7Fh,0E0h,5Fh,0E0h,0DFh; 623D
	defb 0E0h,0DCh,0E0h,7Bh,0E0h,7Bh,0E0h,7Dh,0F0h,7Fh,0F0h,7Fh,0F0h,7Fh,60h,0F0h; 624D
L625D:	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,17h,0ECh,37h,6Ch,36h,0FCh,3Fh,0F8h,1Fh; 625D
	defb 0FCh,3Fh,0FCh,3Fh,0FCh,3Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 626D
	defb 0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,17h,0ECh,37h,0ECh,37h,0FCh,3Fh,0F8h,1Fh; 627D
	defb 0FCh,3Fh,0FCh,3Fh,0FCh,3Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 628D
L629D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,17h; 629D
	defb 0ECh,37h,6Ch,36h,0FCh,3Fh,0F8h,1Fh,0FCh,3Fh,0FCh,3Fh,0FCh,3Fh,00h,00h; 62AD
	defb 00h,00h,00h,00h,00h,00h,00h,00h,0C0h,03h,0F0h,0Fh,0F8h,1Fh,0E8h,17h; 62BD
	defb 0ECh,37h,0ECh,37h,0FCh,3Fh,0F8h,1Fh,0FCh,3Fh,0FCh,3Fh,0FCh,3Fh,00h,00h; 62CD
L62DD:	defb 00h,00h,70h,00h,0F8h,0Fh,0F8h,3Fh,0FCh,3Fh,0FCh,3Fh,0FCh,1Fh,0F8h,1Fh; 62DD
	defb 00h,00h,70h,00h,0F8h,0Fh,0F8h,3Fh,0FCh,3Fh,0FCh,3Fh,0FCh,1Fh,0F8h,1Fh; 62ED
L62FD:	defb 00h,00h,00h,0Eh,0F0h,1Fh,0FCh,1Fh,0FCh,3Fh,0FCh,3Fh,0F8h,3Fh,0F8h,1Fh; 62FD
	defb 00h,00h,00h,0Eh,0F0h,1Fh,0FCh,1Fh,0FCh,3Fh,0FCh,3Fh,0F8h,3Fh,0F8h,1Fh; 630D
L631D:	defb 0E0h,07h,0F8h,1Fh,0E8h,17h,0ECh,37h,6Ch,36h,0FCh,3Fh,0F8h,1Fh,78h,1Eh; 631D
	defb 0E0h,07h,0F8h,1Fh,0E8h,17h,0ECh,37h,0ECh,37h,0FCh,3Fh,0F8h,1Fh,78h,1Eh; 632D
L633D:	defb 00h,38h,7Ch,0FEh,0FEh,0FEh,7Ch,38h,00h,38h,7Ch,0FEh,0FEh,0FEh,7Ch,38h; 633D
L634D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0E0h,07h,0F0h,0Fh,38h,1Fh; 634D
	defb 38h,1Fh,0F8h,1Fh,0F0h,1Fh,0E0h,1Fh,0E0h,1Fh,0E0h,1Fh,0E0h,1Fh,0E0h,1Fh; 635D
	defb 00h,00h,00h,00h,00h,00h,40h,00h,0C0h,00h,00h,00h,0C0h,00h,20h,01h; 636D
	defb 20h,01h,0C0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 637D
L638D:	defb 00h,00h,00h,00h,80h,1Fh,0C0h,3Fh,0E0h,7Ch,0E0h,7Ch,0E0h,7Fh,0C0h,7Fh; 638D
	defb 80h,0FFh,80h,0FFh,00h,7Fh,00h,1Fh,00h,06h,00h,00h,00h,00h,00h,00h; 639D
	defb 00h,01h,00h,03h,00h,00h,00h,03h,80h,04h,80h,04h,00h,03h,00h,00h; 63AD
	defs 16                                ; 63BD
L63CD:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0E0h,07h,0F0h,0Fh,0F8h,1Ch; 63CD
	defb 0F8h,1Ch,0F8h,1Fh,0F8h,0Fh,0F8h,07h,0F8h,07h,0F8h,07h,0F8h,07h,0F8h,07h; 63DD
	defb 00h,00h,00h,00h,00h,00h,00h,02h,00h,03h,00h,00h,00h,03h,80h,04h; 63ED
	defb 80h,04h,00h,03h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 63FD
L640D:	defb 00h,00h,00h,00h,0F8h,01h,0FCh,03h,3Eh,07h,3Eh,07h,0FEh,07h,0FEh,03h; 640D
	defb 0FFh,01h,0FFh,01h,0FEh,00h,0F8h,00h,60h,00h,00h,00h,00h,00h,00h,00h; 641D
	defb 80h,00h,0C0h,00h,00h,00h,0C0h,00h,20h,01h,20h,01h,0C0h,00h,00h,00h; 642D
	defs 16                                ; 643D
L644D:	defb 0E0h,07h,0F8h,1Fh,0FCh,3Fh,0FEh,7Fh,0FEh,7Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh; 644D
	defb 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0F8h,1Fh,0E0h,07h; 645D
	defb 0E0h,07h,0F8h,1Fh,0FCh,3Fh,0FEh,7Fh,0FEh,7Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh; 646D
	defb 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0F8h,1Fh,0E0h,07h; 647D
L648D:	defb 0C0h,01h,0F0h,16h,0F8h,3Eh,7Ch,7Ah,88h,71h,0E6h,0CFh,0FEh,1Fh,0FDh,8Fh; 648D
	defb 0BBh,7Fh,0FFh,0DFh,0FEh,0DFh,0FEh,0FFh,0FCh,7Fh,0E8h,7Fh,0E8h,3Fh,0F0h,1Fh; 649D
	defb 0C0h,01h,0F0h,16h,0F8h,3Eh,7Ch,7Ah,0C8h,71h,0C6h,0CEh,0EEh,1Ch,0FDh,0A7h; 64AD
	defb 0A3h,6Dh,0CFh,0C6h,0FEh,0CDh,0DEh,0F8h,1Ch,73h,0C8h,77h,0E8h,3Bh,0F0h,1Dh; 64BD
L64CD:	defb 0C0h,06h,20h,08h,68h,18h,8Ch,22h,66h,0Ch,0F1h,0DFh,0F6h,7Fh,0BDh,1Fh; 64CD
	defb 79h,0BFh,0FEh,3Fh,0F4h,9Fh,0EBh,5Fh,0EEh,7Fh,0F2h,3Fh,0E8h,3Fh,0E0h,1Fh; 64DD
	defb 0C0h,06h,20h,08h,68h,18h,0CCh,22h,0E6h,0Ch,31h,0D8h,0C6h,72h,0B5h,15h; 64ED
	defb 69h,0B1h,0C6h,22h,74h,84h,0ABh,4Dh,0Eh,62h,52h,33h,68h,3Ah,0C0h,0Ch; 64FD
L650D:	defb 40h,08h,08h,40h,00h,01h,02h,00h,10h,88h,0E1h,07h,0F0h,0Fh,38h,3Fh; 650D
	defb 3Ch,1Fh,0F8h,9Fh,0F1h,1Fh,0E0h,1Fh,0F0h,5Fh,0E2h,1Fh,0E0h,3Fh,0F0h,1Fh; 651D
	defb 40h,08h,08h,40h,00h,01h,42h,00h,0D0h,88h,01h,02h,0C0h,00h,20h,21h; 652D
	defb 24h,09h,0C0h,80h,01h,00h,80h,08h,10h,40h,02h,00h,00h,21h,10h,04h; 653D
L654D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,40h,00h,80h,07h,0C0h,1Fh,0C0h,3Fh; 654D
	defb 0C0h,3Eh,0C0h,7Dh,80h,7Bh,80h,3Fh,0C0h,3Fh,0C0h,1Fh,0E0h,1Fh,0E0h,1Fh; 655D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,40h,20h,00h,30h,00h,00h,00h,06h; 656D
	defb 00h,0Eh,00h,0Dh,00h,02h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 657D
L658D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0E6h,07h,0FFh,0Fh,0FFh,1Fh; 658D
	defb 1Eh,1Eh,0F8h,1Fh,0F0h,1Fh,0E0h,1Fh,0E0h,1Fh,0E0h,1Fh,0E0h,1Fh,0E0h,1Fh; 659D
	defb 00h,00h,00h,00h,00h,00h,40h,00h,0C0h,00h,06h,00h,0CFh,00h,0E7h,01h; 65AD
	defb 06h,00h,0C0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 65BD
L65CD:	defb 0Ch,30h,0F2h,4Fh,0F3h,0CFh,7Fh,0FEh,0FFh,0FFh,0FCh,3Fh,0FCh,3Fh,0F8h,1Fh; 65CD
	defb 8Ch,31h,12h,48h,13h,0C8h,0Fh,0F0h,03h,0C0h,00h,00h,00h,00h,00h,00h; 65DD
L65ED:	defb 00h,00h,00h,00h,0Ch,30h,12h,48h,12h,48h,0Ch,30h,00h,00h,18h,18h; 65ED
	defb 06h,60h,07h,0E0h,1Fh,0F8h,06h,60h,00h,00h,00h,00h,00h,00h,00h,00h; 65FD
	defb 00h,00h,60h,06h,0CCh,33h,0F2h,4Fh,0F2h,4Fh,7Ch,3Eh,0FCh,3Fh,0E6h,67h; 660D
	defb 0F8h,1Fh,0F8h,1Fh,20h,04h,00h,00h,30h,0Ch,7Eh,7Eh,7Eh,7Eh,3Ch,3Ch; 661D
L662D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Ch,30h,12h,48h; 662D
	defb 12h,48h,0Ch,30h,00h,00h,00h,78h,00h,0F8h,1Eh,0E0h,1Fh,60h,07h,00h; 663D
	defb 06h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 664D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,60h,06h,0CCh,33h,0F2h,4Fh; 665D
	defb 0F2h,4Fh,7Ch,3Eh,0FCh,3Fh,0FEh,07h,0FEh,07h,20h,1Ch,00h,18h,00h,00h; 666D
	defb 00h,00h,70h,1Eh,00h,3Fh,00h,3Fh,00h,1Eh,00h,00h,00h,00h,00h,00h; 667D
L668D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Ch,30h,12h,48h; 668D
	defb 12h,48h,0Ch,30h,00h,00h,1Eh,00h,1Fh,00h,07h,78h,06h,0F8h,00h,0E0h; 669D
	defs 26                                ; 66AD
	defb 60h,06h,0CCh,33h,0F2h,4Fh,0F2h,4Fh,7Ch,3Eh,0FCh,3Fh,0E0h,7Fh,0E0h,7Fh; 66C7
	defb 38h,04h,18h,00h,00h,00h,00h,00h,78h,0Eh,0FCh,00h,0FCh,00h,78h,00h; 66D7
	defb 00h,00h,00h,00h,00h,00h           ; 66E7
L66ED:	defb 00h,00h,00h,00h,0Ch,30h,06h,64h,02h,48h,00h,00h,00h,00h,00h,00h; 66ED
	defb 01h,80h,01h,80h,01h,80h,02h,40h,00h,00h,00h,00h,00h,00h,00h,00h; 66FD
	defb 00h,00h,60h,06h,0CCh,33h,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0FCh,3Fh,0FEh,7Fh; 670D
	defb 0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0C0h,03h,1Eh,78h,7Eh,7Eh,3Ch,3Ch; 671D
L672D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Ch,30h,06h,64h; 672D
	defb 02h,48h,00h,00h,00h,00h,00h,80h,00h,80h,00h,80h,03h,40h,07h,00h; 673D
	defb 06h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 674D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,60h,06h,0CCh,33h,0FEh,7Fh; 675D
	defb 0FEh,7Fh,0FCh,3Fh,0FCh,3Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0C0h,03h; 676D
	defb 00h,1Ch,30h,3Eh,00h,3Fh,00h,3Fh,00h,1Eh,00h,00h,00h,00h,00h,00h; 677D
L678D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Ch,30h,06h,64h; 678D
	defb 02h,48h,00h,00h,00h,00h,01h,00h,01h,00h,01h,00h,02h,0C0h,00h,0E0h; 679D
	defb 00h,60h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 67AD
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,60h,06h,0CCh,33h,0FEh,7Fh; 67BD
	defb 0FEh,7Fh,0FCh,3Fh,0FCh,3Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0C0h,03h; 67CD
	defb 38h,00h,7Ch,0Ch,0FCh,00h,0FCh,00h,78h,00h,00h,00h,00h,00h,00h,00h; 67DD
L67ED:	defb 00h,00h,00h,00h,00h,30h,00h,49h,0C0h,48h,20h,30h,00h,00h,00h,0C0h; 67ED
	defb 00h,3Eh,0C0h,3Fh,0C0h,0FFh,80h,3Fh,00h,0Eh,00h,00h,00h,00h,00h,00h; 67FD
	defb 00h,00h,00h,0C0h,00h,7Eh,0C0h,0CFh,0F0h,4Fh,0F8h,0FFh,0FCh,7Fh,0FCh,3Fh; 680D
	defb 0FEh,01h,3Eh,00h,3Fh,00h,1Eh,00h,00h,40h,1Fh,0F0h,3Fh,0FCh,1Eh,78h; 681D
L682D:	defb 00h,00h,00h,00h,00h,03h,00h,80h,04h,00h,84h,04h,00h,03h,03h,80h; 682D
	defb 00h,00h,00h,00h,00h,00h,0E0h,0Fh,00h,0FCh,0Fh,00h,0FCh,03h,00h,0F8h; 683D
	defb 03h,00h,0E0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 684D
	defb 00h,00h,0Ch,00h,0E0h,07h,00h,0FCh,0Ch,00h,0FFh,04h,80h,0FFh,0Fh,0C0h; 685D
	defb 0FFh,07h,0C0h,0FFh,03h,0E0h,1Fh,00h,0E0h,03h,00h,0F0h,03h,00h,0E0h,07h; 686D
	defb 00h,00h,00h,00h,00h,1Ch,00h,00h,7Eh,00h,00h,7Eh,00h,00h,7Ch,00h; 687D
L688D:	defb 00h,00h,00h,00h,0Ch,00h,92h,00h,12h,03h,0Ch,04h,00h,00h,03h,00h; 688D
	defb 7Ch,00h,0FCh,03h,0FFh,03h,0FCh,01h,70h,00h,00h,00h,00h,00h,00h,00h; 689D
	defb 00h,00h,03h,00h,7Eh,00h,0F3h,03h,0F2h,0Fh,0FFh,1Fh,0FEh,3Fh,0FCh,3Fh; 68AD
	defb 80h,7Fh,00h,7Ch,00h,0FCh,00h,78h,02h,00h,0Fh,0F8h,3Fh,0FCh,1Eh,78h; 68BD
L68CD:	defb 00h,00h,00h,0C0h,00h,00h,20h,01h,00h,20h,21h,00h,0C0h,0C0h,00h,00h; 68CD
	defb 00h,01h,00h,00h,00h,0F0h,07h,00h,0F0h,3Fh,00h,0C0h,3Fh,00h,0C0h,1Fh; 68DD
	defb 00h,00h,07h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 68ED
	defb 30h,00h,00h,0E0h,07h,00h,30h,3Fh,00h,20h,0FFh,00h,0F0h,0FFh,01h,0E0h; 68FD
	defb 0FFh,03h,0C0h,0FFh,03h,00h,0F8h,07h,00h,0C0h,07h,00h,0C0h,0Fh,00h,0E0h; 690D
	defb 07h,00h,00h,00h,00h,38h,00h,00h,7Eh,00h,00h,7Eh,00h,00h,3Eh,00h; 691D
L692D:	defb 0E0h,07h,0F8h,1Fh,0FCh,3Fh,0FEh,7Fh,0FEh,7Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh; 692D
	defb 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh,0F8h,1Fh,0E0h,07h; 693D
	defb 0E0h,07h,0F8h,1Fh,0FCh,3Fh,0FEh,7Fh,0FEh,7Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh; 694D
	defb 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FCh,3Fh; 695D
L696D:	defb 18h,0Eh,04h,3Bh,0ECh,70h,7Eh,6Fh,36h,0DEh,0ACh,0DBh,0C6h,73h,0FBh,7Eh; 696D
	defb 37h,68h,77h,0FEh,0FFh,0FFh,5Fh,0E7h,0FEh,68h,0CEh,67h,9Ch,3Bh,78h,1Ch; 697D
	defb 18h,0Eh,64h,3Fh,0ECh,73h,0FEh,6Fh,0F6h,0DFh,0FCh,0BFh,0FEh,7Fh,0E7h,67h; 698D
	defb 0FFh,3Fh,0FDh,0BFh,0ECh,9Fh,59h,0C7h,0FEh,6Ch,0FEh,7Fh,0FEh,7Fh,7Ch,3Ch; 699D
L69AD:	defb 14h,1Ah,42h,61h,3Ch,0B0h,1Fh,0FAh,89h,4Dh,2Eh,0B8h,0C4h,11h,38h,3Ah; 69AD
	defb 27h,60h,0Fh,0ECh,3Fh,0FEh,16h,0E3h,23h,40h,0C2h,31h,24h,18h,18h,0Dh; 69BD
	defb 14h,1Ah,62h,67h,0FCh,0B3h,0FFh,0FFh,0E9h,4Fh,7Eh,0BEh,0FCh,3Fh,0EEh,77h; 69CD
	defb 0FBh,5Fh,0F9h,3Fh,32h,0A6h,14h,0C3h,33h,4Ch,0FEh,7Fh,7Eh,7Eh,3Ch,3Dh; 69DD
L69ED:	defb 04h,08h,02h,41h,0Ch,30h,12h,0C9h,13h,4Ah,2Ch,30h,10h,00h,19h,19h; 69ED
	defb 06h,60h,0Fh,0E8h,1Fh,0F8h,06h,62h,01h,00h,20h,20h,04h,00h,00h,04h; 69FD
	defb 04h,08h,62h,47h,0CCh,33h,0F2h,0CFh,0F3h,4Fh,7Ch,3Eh,0FCh,3Fh,0E7h,67h; 6A0D
	defb 0F8h,1Fh,0F8h,5Fh,22h,04h,00h,02h,31h,0Ch,7Eh,7Eh,7Eh,7Eh,3Ch,3Ch; 6A1D
L6A2D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,80h,00h,60h,06h,0Ch,30h; 6A2D
	defb 1Eh,78h,00h,00h,0Ch,30h,06h,60h,1Fh,0F8h,2Fh,0F4h,0Eh,70h,18h,18h; 6A3D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,60h,07h,98h,19h,0FCh,3Fh; 6A4D
	defb 0FEh,7Fh,0E0h,07h,0FEh,7Fh,78h,1Eh,0E0h,07h,0D0h,0Bh,30h,0Ch,04h,20h; 6A5D
L6A6D:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,80h,08h; 6A6D
	defb 60h,06h,0Ch,30h,1Eh,78h,00h,00h,0Eh,70h,3Fh,0FCh,0Fh,0F0h,3Eh,7Ch; 6A7D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0E0h,07h,78h,17h; 6A8D
	defb 9Ch,39h,0FEh,7Fh,0FEh,7Fh,0E0h,07h,0F0h,0Fh,40h,02h,0F0h,0Fh,00h,00h; 6A9D
L6AAD:	defb 0Ch,30h,12h,48h,13h,0C8h,0Fh,0F0h,1Bh,0D8h,07h,0E0h,07h,0E0h,1Eh,78h; 6AAD
	defb 6Ch,36h,0D2h,48h,0F3h,0CFh,7Fh,0FEh,0E7h,0E7h,0F8h,1Fh,0F8h,1Fh,20h,04h; 6ABD
L6ACD:	defb 00h,00h,00h,00h,00h,00h,18h,0Ch,00h,00h,00h,18h,3Ch,7Eh,18h,0Ch; 6ACD
font:	defb 00h,00h,00h,00h,00h,00h,00h,00h,18h,18h,18h,18h,18h,00h,18h,00h; 6ADD
	defb 6Ch,6Ch,24h,00h,00h,00h,00h,00h,6Ch,6Ch,0FEh,6Ch,0FEh,6Ch,6Ch,00h; 6AED
	defb 18h,3Eh,78h,3Ch,1Eh,7Ch,18h,00h,00h,0C6h,0CCh,18h,30h,66h,0C6h,00h; 6AFD
	defb 70h,0D8h,0D8h,70h,0DEh,0DCh,76h,00h,38h,38h,18h,30h,00h,00h,00h,00h; 6B0D
	defb 08h,30h,60h,60h,60h,30h,08h,00h,20h,18h,0Ch,0Ch,0Ch,18h,20h,00h; 6B1D
	defb 00h,18h,5Ah,3Ch,3Ch,5Ah,18h,00h,00h,18h,18h,7Eh,7Eh,18h,18h,00h; 6B2D
	defb 00h,00h,00h,00h,38h,38h,18h,30h,00h,00h,00h,7Ch,7Ch,00h,00h,00h; 6B3D
	defb 00h,00h,00h,00h,38h,38h,00h,00h,00h,06h,0Ch,18h,30h,60h,0C0h,00h; 6B4D
L6B5D:	defb 7Ch,0EEh,0EEh,0EEh,0EEh,0EEh,7Ch,00h,38h,78h,38h,38h,38h,38h,7Ch,00h; 6B5D
	defb 7Ch,0EEh,0Eh,3Ch,70h,0FEh,0FEh,00h,7Ch,0EEh,0Eh,3Ch,0Eh,0EEh,7Ch,00h; 6B6D
	defb 3Ch,7Ch,0DCh,0DEh,0FEh,1Ch,1Ch,00h,0FEh,0E0h,0FCh,0Eh,0Eh,0EEh,7Ch,00h; 6B7D
	defb 7Ch,0EEh,0E0h,0FCh,0EEh,0EEh,7Ch,00h,0FEh,0EEh,0Eh,1Ch,38h,38h,38h,00h; 6B8D
	defb 7Ch,0EEh,0EEh,7Ch,0EEh,0EEh,7Ch,00h,7Ch,0EEh,0EEh,7Eh,0Eh,0EEh,7Ch,00h; 6B9D
	defb 00h,38h,38h,00h,38h,38h,00h,00h,00h,38h,38h,00h,38h,38h,18h,30h; 6BAD
	defb 1Eh,38h,70h,0E0h,70h,38h,1Eh,00h,00h,7Eh,7Eh,00h,7Eh,7Eh,00h,00h; 6BBD
	defb 78h,1Ch,0Eh,07h,0Eh,1Ch,78h,00h,7Ch,0EEh,0Eh,1Ch,38h,00h,38h,38h; 6BCD
	defb 7Ch,0C6h,06h,66h,0D6h,0D6h,7Ch,00h,7Ch,0FEh,0E6h,0E6h,0FEh,0E6h,0E6h,00h; 6BDD
	defb 0FCh,7Eh,66h,7Ch,66h,7Eh,0FCh,00h,7Ch,0FEh,0E6h,0E0h,0E6h,0FEh,7Ch,00h; 6BED
	defb 0FCh,7Eh,66h,66h,66h,7Eh,0FCh,00h,7Eh,0FEh,0F8h,0FEh,0F8h,0FEh,7Eh,00h; 6BFD
	defb 7Eh,0FEh,0F8h,0FEh,0F8h,0F8h,78h,00h,7Ch,0E6h,0E0h,0EEh,0E6h,0FEh,7Ch,00h; 6C0D
	defb 66h,0E6h,0E6h,0FEh,0E6h,0E6h,0E6h,00h,7Eh,3Ch,3Ch,3Ch,3Ch,3Ch,7Eh,00h; 6C1D
	defb 0Eh,0Eh,0Eh,0EEh,0EEh,0FEh,7Ch,00h,0EEh,0FEh,0FCh,0FCh,0FCh,0FEh,0EEh,00h; 6C2D
	defb 70h,0F0h,0F0h,0F0h,0F0h,0FEh,7Eh,00h,0C6h,0EEh,0FEh,0FEh,0FEh,0D6h,0C6h,00h; 6C3D
	defb 0E6h,0F6h,0FEh,0FEh,0FEh,0EEh,0E6h,00h,7Ch,0E6h,0E6h,0E6h,0E6h,0FEh,7Ch,00h; 6C4D
	defb 0FCh,0E6h,0E6h,0FEh,0FCh,0E0h,0E0h,00h,7Ch,0E6h,0E6h,0E6h,0EEh,0FCh,7Eh,00h; 6C5D
	defb 0FCh,0E6h,0E6h,0FEh,0FCh,0FEh,0EEh,00h,7Ch,0FEh,0F8h,7Ch,3Eh,0FEh,7Ch,00h; 6C6D
	defb 0FEh,0FEh,38h,38h,38h,38h,38h,00h,0E6h,0E6h,0E6h,0E6h,0E6h,0FEh,7Ch,00h; 6C7D
	defb 0E6h,0E6h,0E6h,0E6h,64h,7Ch,38h,00h,0C6h,0C6h,0C6h,0D6h,0FEh,0FEh,6Ch,00h; 6C8D
	defb 0EEh,0FEh,7Ch,38h,7Ch,0FEh,0EEh,00h,0EEh,0EEh,0FEh,7Ch,38h,38h,38h,00h; 6C9D
	defb 0FEh,0FEh,3Ch,78h,0FEh,0FEh,0FEh,00h,3Ch,30h,30h,30h,30h,30h,3Ch,00h; 6CAD
	defb 0CCh,78h,0FCh,30h,0FCh,30h,30h,00h,3Ch,0Ch,0Ch,0Ch,0Ch,0Ch,3Ch,00h; 6CBD
	defb 18h,3Ch,76h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,7Eh,7Eh; 6CCD
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,7Ch,0Ch,7Ch,0ECh,7Eh,00h; 6CDD
	defb 0E0h,0E0h,0FCh,0E6h,0E6h,0E6h,0FCh,00h,00h,00h,7Ch,0E6h,0E0h,0E6h,7Ch,00h; 6CED
	defb 0Eh,0Eh,7Eh,0CEh,0CEh,0CEh,7Eh,00h,00h,00h,7Ch,0E6h,0FEh,0E0h,7Ch,00h; 6CFD
	defb 1Ch,3Ah,38h,0FEh,38h,38h,38h,00h,00h,00h,7Eh,0CEh,0CEh,7Eh,0Eh,7Ch; 6D0D
	defb 0E0h,0E0h,0FCh,0E6h,0E6h,0E6h,0E6h,00h,38h,00h,78h,38h,38h,38h,7Ch,00h; 6D1D
	defb 1Ch,00h,1Ch,1Ch,1Ch,0DCh,0DCh,78h,0E0h,0E0h,0EEh,0FCh,0F8h,0FCh,0EEh,00h; 6D2D
	defb 78h,38h,38h,38h,38h,38h,7Ch,00h,00h,00h,0FCh,0DAh,0DAh,0DAh,0DAh,00h; 6D3D
	defb 00h,00h,0FCh,0E6h,0E6h,0E6h,0E6h,00h,00h,00h,7Ch,0E6h,0E6h,0E6h,7Ch,00h; 6D4D
	defb 00h,00h,0FCh,0E6h,0E6h,0FCh,0E0h,0E0h,00h,00h,7Eh,0CEh,0CEh,7Eh,0Eh,0Eh; 6D5D
	defb 00h,00h,0ECh,0FEh,0F6h,0E0h,0E0h,00h,00h,00h,7Eh,0F8h,7Ch,3Eh,0FCh,00h; 6D6D
	defb 30h,30h,0FCh,30h,30h,36h,1Ch,00h,00h,00h,0E6h,0E6h,0E6h,0FEh,7Eh,00h; 6D7D
	defb 00h,00h,0E6h,0E6h,0E6h,7Ch,38h,00h,00h,00h,0C6h,0D6h,0D6h,0D6h,6Ch,00h; 6D8D
	defb 00h,00h,0EEh,7Ch,38h,7Ch,0EEh,00h,00h,00h,0CEh,0CEh,0CEh,7Eh,0Eh,7Ch; 6D9D
	defb 00h,00h,0FEh,1Ch,38h,70h,0FEh,00h,00h,00h,00h,00h,00h,00h,00h,0FFh; 6DAD
	defb 00h,00h,00h,00h,00h,00h,00h,0FFh,00h,00h,00h,00h,00h,00h,00h,0FFh; 6DBD
	defb 00h,00h,00h,00h,00h,00h,00h,0FFh,00h,00h,00h,00h,00h,00h,00h,0FFh; 6DCD
L6DDD:	defb 0A0h,7Ch,0FEh,0F8h,7Ch,3Eh,0FEh,7Ch,00h,00h,7Ch,0E6h,0E0h,0E6h,0FEh,7Ch; 6DDD
	defb 00h,00h,7Ch,0E6h,0E6h,0E6h,0FEh,7Ch,00h,00h,0FCh,0E6h,0E6h,0FCh,0FEh,0EEh; 6DED
	defb 00h,00h,7Eh,0F8h,0FEh,0F8h,0FEh,7Eh,00h; 6DFD
L6E06:	defb 20h,00h,0FEh,0FEh,38h,38h,38h,38h,00h,00h,7Ch,38h,38h,38h,38h,7Ch; 6E06
	defb 00h,00h,0FCh,0FEh,0DAh,0DAh,0DAh,0DAh,00h,00h,7Eh,0F8h,0FEh,0F8h,0FEh,7Eh; 6E16
	defb 00h                               ; 6E26
L6E27:	defb 10h,3Ch,42h,99h,0A1h,0A1h,99h,42h,3Ch,00h,06h,3Eh,7Eh,66h,66h,3Eh; 6E27
	defb 00h,0FCh,7Eh,66h,7Ch,66h,7Eh,0FCh,00h,00h,00h,00h,38h,38h,00h,00h; 6E37
	defb 00h,7Ch,0FEh,0F8h,7Ch,3Eh,0FEh,7Ch,00h,00h,7Ch,0E6h,0E6h,0E6h,0FEh,7Ch; 6E47
	defb 00h,00h,7Eh,0F8h,0FEh,0F8h,0F8h,78h,00h,00h,0FEh,0FEh,38h,38h,38h,38h; 6E57
	defb 00h,0E0h,00h,06h,3Eh,7Eh,66h,66h,3Eh,00h,0FCh,7Eh,66h,7Ch,66h,7Eh; 6E67
	defb 0FCh,00h,00h,00h,00h,38h,38h,00h,00h,00h,7Ch,0FEh,0F8h,7Ch,3Eh,0FEh; 6E77
	defb 7Ch,00h,00h,7Ch,0E6h,0E6h,0E6h,0FEh,7Ch,00h,00h,7Eh,0F8h,0FEh,0F8h,0F8h; 6E87
	defb 78h,00h,00h,0FEh,0FEh,38h,38h,38h,38h,00h; 6E97
L6EA1:	defb 3Ch,42h,99h,0A1h,0A1h,99h,42h,3Ch,3Ch,42h,99h,0A1h,0A1h,99h,42h,3Ch; 6EA1
	defb 00h,06h,3Eh,7Eh,66h,66h,3Eh,00h,00h,06h,3Eh,7Eh,66h,66h,3Eh,00h; 6EB1
	defb 0FCh,7Eh,66h,7Ch,66h,7Eh,0FCh,00h,0FCh,7Eh,66h,7Ch,66h,7Eh,0FCh,00h; 6EC1
	defb 00h,00h,00h,38h,38h,00h,00h,00h,00h,00h,00h,38h,38h,00h,00h,00h; 6ED1
	defb 7Ch,0FEh,0F8h,7Ch,3Eh,0FEh,7Ch,00h,7Ch,0FEh,0F8h,7Ch,3Eh,0FEh,7Ch,00h; 6EE1
	defb 00h,7Ch,0E6h,0E6h,0E6h,0FEh,7Ch,00h,00h,7Ch,0E6h,0E6h,0E6h,0FEh,7Ch,00h; 6EF1
	defb 00h,7Eh,0F8h,0FEh,0F8h,0F8h,78h,00h,00h,7Eh,0F8h,0FEh,0F8h,0F8h,78h,00h; 6F01
	defb 00h,0FEh,0FEh,38h,38h,38h,38h,00h,00h,0FEh,0FEh,38h,38h,38h,38h,00h; 6F11
L6F21:	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0E0h,0F9h,0E5h,0E4h,0F9h,00h; 6F21
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0B0h,0F6h,76h,0E0h,00h; 6F31
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,7Eh,0F8h,7Ch,3Eh,0FCh,00h; 6F41
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,7Eh,0F8h,7Ch,3Eh,0FCh,00h; 6F51
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,0EEh,0FEh,0FCh,0FCh,0FEh,0EEh,00h; 6F61
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,7Ch,0E6h,0E6h,0E6h,0FEh,7Ch,00h; 6F71
L6F81:	defb 60h,7Ch,0FEh,0F8h,7Ch,3Eh,0FEh,7Ch,00h,00h,7Ch,0E6h,0E0h,0E6h,0FEh,7Ch; 6F81
	defb 00h,00h,7Eh,0F8h,0FEh,0F8h,0FEh,7Eh,00h,00h,0FCh,0FEh,0E6h,0E6h,0E6h,0E6h; 6F91
	defb 00h,00h,7Eh,0F8h,0FEh,0F8h,0FEh,7Eh,00h,00h,00h,00h,00h,00h,00h,00h; 6FA1
	defb 00h                               ; 6FB1
L6FB2:	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Eh,78h,1Ch,38h,18h,18h,1Eh,78h; 6FB2
	defb 1Eh,78h,1Eh,78h,1Eh,78h,1Eh,78h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 6FC2
	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Eh,78h,1Ch,38h,18h,18h,1Eh,78h; 6FD2
	defb 1Eh,78h,1Eh,78h,1Eh,78h,1Eh,78h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 6FE2
L6FF2:	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Eh,78h,1Eh,78h,1Eh,78h,1Eh,78h; 6FF2
	defb 1Eh,78h,18h,18h,1Ch,38h,1Eh,78h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 7002
	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Eh,78h,1Eh,78h,1Eh,78h,1Eh,78h; 7012
	defb 1Eh,78h,18h,18h,1Ch,38h,1Eh,78h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 7022
L7032:	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Fh,0F8h,1Dh,0F8h,19h,0F8h,10h,08h; 7032
	defb 10h,08h,19h,0F8h,1Dh,0F8h,1Fh,0F8h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 7042
	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Fh,0F8h,1Dh,0F8h,19h,0F8h,10h,08h; 7052
	defb 10h,08h,19h,0F8h,1Dh,0F8h,1Fh,0F8h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 7062
L7072:	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Fh,0F8h,1Fh,0B8h,1Fh,98h,10h,08h; 7072
	defb 10h,08h,1Fh,98h,1Fh,0B8h,1Fh,0F8h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 7082
	defb 00h,00h,00h,00h,00h,00h,1Fh,0F8h,1Fh,0F8h,1Fh,0B8h,1Fh,98h,10h,08h; 7092
	defb 10h,08h,1Fh,98h,1Fh,0B8h,1Fh,0F8h,1Fh,0F8h,00h,00h,00h,00h,00h,00h; 70A2
L70B2:	defb 00h,00h,00h,00h,3Fh,0FFh,20h,00h,20h,00h,27h,0EFh,2Fh,8Eh,27h,0CEh; 70B2
	defb 23h,0EFh,2Fh,0CEh,20h,0Eh,20h,00h,20h,00h,3Fh,0FFh,00h,00h,00h,00h; 70C2
	defb 00h,00h,00h,00h,3Fh,0FFh,20h,00h,20h,00h,27h,0EFh,2Fh,8Eh,27h,0CEh; 70D2
	defb 23h,0EFh,2Fh,0CEh,20h,0Eh,20h,00h,20h,00h,3Fh,0FFh,00h,00h,00h,00h; 70E2
L70F2:	defb 00h,00h,00h,00h,0FFh,0FFh,00h,00h,00h,00h,0C7h,0C7h,60h,0CEh,67h,0CEh; 70F2
	defb 0CEh,0CEh,07h,0E7h,00h,00h,00h,00h,00h,00h,0FFh,0FFh,00h,00h,00h,00h; 7102
	defb 00h,00h,00h,00h,0FFh,0FFh,00h,00h,00h,00h,0C7h,0C7h,60h,0CEh,67h,0CEh; 7112
	defb 0CEh,0CEh,07h,0E7h,00h,00h,00h,00h,00h,00h,0FFh,0FFh,00h,00h,00h,00h; 7122
L7132:	defb 00h,00h,00h,00h,0FFh,0FCh,00h,04h,00h,04h,0C7h,0C4h,6Eh,64h,0Fh,0E4h; 7132
	defb 6Eh,04h,0C7h,0C4h,00h,04h,00h,04h,00h,04h,0FFh,0FCh,00h,00h,00h,00h; 7142
	defb 00h,00h,00h,00h,0FFh,0FCh,00h,04h,00h,04h,0C7h,0C4h,6Eh,64h,0Fh,0E4h; 7152
	defb 6Eh,04h,0C7h,0C4h,00h,04h,00h,04h,00h,04h,0FFh,0FCh,00h,00h,00h,00h; 7162
L7172:	defb 00h,00h,3Fh,0FCh,7Fh,0FEh,7Fh,0FEh,7Eh,7Eh,7Eh,7Eh,7Eh,00h,7Eh,0FEh; 7172
	defb 7Eh,0FEh,7Eh,0FEh,7Eh,7Eh,7Eh,7Eh,7Fh,0FEh,7Fh,0FEh,3Fh,0FCh,00h,00h; 7182
	defs 32                                ; 7192
L71B2:	defb 00h,00h,3Fh,0FCh,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh; 71B2
	defb 7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,00h,00h; 71C2
	defs 32                                ; 71D2
L71F2:	defb 00h,00h,7Fh,0FCh,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Bh,0DEh,7Bh,0DEh,7Bh,0DEh; 71F2
	defb 7Bh,0DEh,7Bh,0DEh,7Bh,0DEh,7Bh,0DEh,7Bh,0DEh,7Bh,0DEh,7Bh,0DEh,00h,00h; 7202
	defs 32                                ; 7212
L7232:	defb 00h,00h,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,78h,00h,7Fh,0F8h,7Fh,0F8h; 7232
	defb 7Fh,0F8h,7Fh,0F8h,78h,00h,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,7Fh,0FEh,00h,00h; 7242
	defs 32                                ; 7252
L7272:	defb 00h,00h,3Fh,0FCh,7Fh,0FEh,7Fh,0FEh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh; 7272
	defb 7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Fh,0FEh,7Fh,0FEh,3Fh,0FCh,00h,00h; 7282
	defs 32                                ; 7292
L72B2:	defb 00h,00h,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh; 72B2
	defb 7Eh,7Eh,3Eh,7Ch,3Eh,7Ch,1Fh,0F8h,1Fh,0F8h,0Fh,0F0h,0Fh,0F0h,00h,00h; 72C2
	defs 32                                ; 72D2
L72F2:	defb 00h,00h,7Fh,0FCh,7Fh,0FEh,7Fh,0FEh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh; 72F2
	defb 7Fh,0FEh,7Fh,0FCh,7Fh,0FCh,7Eh,0FEh,7Eh,7Eh,7Eh,7Eh,7Eh,7Eh,00h,00h; 7302
	defs 32                                ; 7312
L7332:	defb 0C3h,41h,73h,0C3h,3Eh,73h,0C3h,79h,73h,0C3h,0CBh,77h,21h,13h,79h,0F3h; 7332
	defb 0E5h,0DDh,0E1h,0DDh,5Eh,00h,0DDh,56h,01h,0E5h,19h,22h,0AEh,73h,0E1h,0DDh; 7342
	defb 5Eh,02h,0DDh,56h,03h,19h,22h,0B1h,73h,0AFh,32h,0E6h,74h,3Ch,32h,0E2h; 7352
	defb 74h,21h,79h,73h,22h,06h,0FAh,0CDh,60h,74h,0AFh,32h,0BCh,73h,3Eh,0Ah; 7362
	defb 1Eh,00h,0CDh,8Bh,78h,0FBh,0C9h,0F3h,0E5h,0D5h,0C5h,0D9h,0E5h,0D5h,0C5h,0F5h; 7372
	defb 08h,0F5h,3Eh,00h,3Ch,28h,03h,32h,85h,73h,3Eh; 7382
L738D:	defb 00h,0B7h,28h,16h,0AFh,32h,0BCh,73h,3Eh,08h,1Eh,00h,0CDh,8Bh,78h,3Ch; 738D
	defb 0CDh,8Bh,78h,3Ch,0CDh,8Bh,78h,0C3h,51h,74h,3Ah,0E6h,74h,0B7h,20h,0Bh; 739D
	defb 21h,00h,00h,11h,00h,00h,0CDh,69h,74h,18h,03h,0CDh,9Eh,74h,3Eh,00h; 73AD
	defb 0B7h,0CAh,51h,74h,0F2h,1Eh,74h,0FEh,80h,20h,36h,0AFh,32h,0BCh,73h,3Ah; 73BD
	defb 0EBh,77h,0E6h,0DFh,0F6h,04h,32h,0EBh,77h,5Fh,3Eh,07h,0CDh,8Bh,78h,3Eh; 73CD
	defb 06h,1Eh,05h,0CDh,8Bh,78h,3Eh,0Ah,1Eh,10h,0CDh,8Bh,78h,3Ch,1Eh,01h; 73DD
	defb 0CDh,8Bh,78h,3Ch,1Eh,02h,0CDh,8Bh,78h,3Ch,1Eh,04h,0CDh,8Bh,78h,18h; 73ED
	defb 53h,3Ah,0EBh,77h,0E6h,0FBh,0F6h,20h,32h,0EBh,77h,5Fh,3Eh,07h,0CDh,8Bh; 73FD
	defb 78h,21h,21h,79h,22h,2Dh,74h,3Eh,01h,32h,1Fh,74h,32h,0BCh,73h,3Eh; 740D
	defb 01h,3Eh,01h,3Dh,32h,1Fh,74h,20h,2Bh,3Ah,1Dh,74h,32h,1Fh,74h,21h; 741D
	defb 00h,00h,7Eh,23h,22h,2Dh,74h,0B7h,20h,05h,32h,0BCh,73h,18h,15h,0F2h; 742D
	defb 4Bh,74h,5Eh,23h,22h,2Dh,74h,3Eh,02h,0CDh,0Ch,78h,18h,0E1h,0CDh,42h; 743D
	defb 78h,0CDh,12h,78h,0CDh,60h,74h,0F1h,08h,0F1h,0C1h,0D1h,0E1h,0D9h,0C1h,0D1h; 744D
	defb 0E1h,0FBh,0C9h,3Eh,00h,0D3h,0B0h,0C9h,0AFh,32h,0E2h,74h,22h,0F6h,74h,0EDh; 745D
	defb 53h,0Bh,75h,3Eh,03h,32h,0E6h,74h,32h,9Fh,74h,32h,0C0h,74h,3Ah,0EBh; 746D
	defb 78h,32h,0A8h,74h,32h,0CAh,74h,3Ah,0EBh,77h,0E6h,3Ch,32h,0EBh,77h,5Fh; 747D
	defb 0CDh,0FFh,77h,0CDh,0EBh,74h,0CDh,0FFh,74h,3Ah,0E2h,74h,0B7h,0C0h,0CDh,0D8h; 748D
	defb 77h,3Eh,03h,0B7h,28h,1Ch,0AFh,0CDh,0E9h,76h,3Eh,10h,3Dh,32h,0A8h,74h; 749D
	defb 20h,10h,3Ah,0EBh,78h,32h,0A8h,74h,3Ah,10h,79h,3Dh,32h,10h,79h,0CCh; 74AD
	defb 0EBh,74h,3Eh,03h,0B7h,28h,1Dh,3Eh,01h,0CDh,0E9h,76h,3Eh,10h,3Dh,32h; 74BD
	defb 0CAh,74h,20h,10h,3Ah,0EBh,78h,32h,0CAh,74h,3Ah,11h,79h,3Dh,32h,11h; 74CD
	defb 79h,0CCh,0FFh,74h,3Eh,00h,0B7h,0C0h,3Eh,03h,0B7h,20h,0B1h,0C9h,21h,9Fh; 74DD
	defb 74h,22h,0E3h,76h,0AFh,32h,0C6h,77h,21h,00h,00h,0CDh,14h,75h,22h,0F6h; 74ED
	defb 74h,0C9h,21h,0C0h,74h,22h,0E3h,76h,3Eh,01h,32h,0C6h,77h,21h,00h,00h; 74FD
	defb 0CDh,14h,75h,22h,0Bh,75h,0C9h,0AFh,32h,7Ah,76h,32h,7Fh,76h,7Eh,23h; 750D
	defb 0FEh,23h,28h,5Ah,0FEh,24h,28h,5Ah,0FEh,2Bh,28h,61h,0FEh,2Dh,28h,65h; 751D
	defb 0FEh,3Ch,0CAh,0B2h,75h,0FEh,3Eh,0CAh,0BAh,75h,0FEh,5Eh,0CAh,75h,75h,0FEh; 752D
	defb 3Ah,0CAh,0CDh,76h,0FEh,20h,0CAh,1Bh,75h,0E6h,0DFh,0FEh,56h,28h,76h,0FEh; 753D
	defb 4Ch,0CAh,0EFh,75h,0FEh,4Fh,28h,45h,0FEh,53h,0CAh,23h,76h,0FEh,4Dh,0CAh; 754D
	defb 31h,76h,0E5h,21h,0C3h,78h,06h,08h,0BEh,23h,0CAh,6Eh,76h,23h,10h,0F8h; 755D
	defb 0E1h,0B7h,0CAh,0CDh,76h,0C3h,1Bh,75h,32h,7Fh,76h,0C3h,1Bh,75h,3Eh,01h; 756D
	defb 18h,02h,3Eh,0FFh,32h,7Ah,76h,0CDh,0BAh,78h,23h,18h,0D5h,0D9h,0CDh,95h; 757D
	defb 77h,0D9h,3Ch,18h,11h,0D9h,0CDh,95h,77h,0D9h,3Dh,18h,09h,0CDh,93h,78h; 758D
	defb 7Bh,0B7h,20h,02h,3Eh,04h,3Dh,0E6h,07h,3Ch,08h,0D9h,0CDh,95h,77h,08h; 759D
	defb 77h,0D9h,0C3h,1Bh,75h,0D9h,0CDh,9Fh,77h,0D9h,3Ch,18h,1Dh,0D9h,0CDh,9Fh; 75AD
	defb 77h,0D9h,3Dh,18h,10h,0CDh,0BAh,78h,0CDh,0B5h,78h,38h,04h,3Eh,0Ch,18h; 75BD
	defb 04h,0CDh,93h,78h,7Bh,0B7h,0F2h,0D7h,75h,0AFh,0FEh,10h,38h,02h,3Eh,0Fh; 75CD
	defb 08h,0D9h,0CDh,9Fh,77h,08h,77h,0D9h,5Fh,3Ah,0C6h,77h,0CDh,0Ch,78h,0C3h; 75DD
	defb 1Bh,75h,0CDh,93h,78h,7Bh,0B7h,20h,02h,3Eh,04h,0D9h,2Eh,40h,57h,0CDh; 75ED
	defb 62h,78h,7Dh,0D9h,5Fh,08h,0CDh,0BAh,78h,0FEh,2Eh,20h,08h,0CBh,3Bh,08h; 75FD
	defb 83h,08h,23h,18h,0F1h,08h,0B7h,20h,02h,3Eh,10h,08h,0D9h,0CDh,9Ah,77h; 760D
	defb 08h,77h,0D9h,0C3h,1Bh,75h,0CDh,93h,78h,7Bh,0D9h,5Fh,0CDh,0A4h,77h,73h; 761D
	defb 0D9h,0C3h,1Bh,75h,0CDh,0BAh,78h,0E6h,0DFh,0FEh,55h,28h,15h,0FEh,46h,28h; 762D
	defb 1Dh,0FEh,44h,0C2h,1Bh,75h,23h,0CDh,93h,78h,7Bh,0D9h,5Fh,0CDh,0B3h,77h; 763D
	defb 18h,16h,23h,0CDh,93h,78h,7Bh,0D9h,5Fh,0CDh,0A9h,77h,18h,0Ah,23h,0CDh; 764D
	defb 93h,78h,7Bh,0D9h,5Fh,0CDh,0AEh,77h,73h,23h,23h,23h,73h,0D9h,0C3h,1Bh; 765D
	defb 75h,7Eh,08h,0CDh,95h,77h,47h,3Ah,0C6h,77h,4Fh,08h,0C6h,00h,0CDh,16h; 766D
	defb 78h,3Eh,00h,0B7h,20h,0Bh,0CDh,7Dh,77h,0CDh,0B8h,77h,36h,00h,0CDh,0ECh; 767D
	defb 76h,0E1h,0CDh,0BAh,78h,0CDh,0B5h,78h,38h,07h,0D9h,0CDh,9Ah,77h,0D9h,18h; 768D
	defb 27h,0CDh,93h,78h,7Bh,0B7h,28h,0F2h,0D9h,2Eh,40h,57h,0CDh,62h,78h,7Dh; 769D
	defb 0D9h,5Fh,08h,0CDh,0BAh,78h,0FEh,2Eh,20h,08h,0CBh,3Bh,08h,83h,08h,23h; 76AD
	defb 18h,0F1h,08h,0B7h,20h,02h,3Eh,10h,0D9h,5Fh,0CDh,0C2h,77h,73h,0D9h,0C9h; 76BD
	defb 3Ah,0C6h,77h,47h,0CDh,05h,78h,2Fh,5Fh,3Ah,0E6h,74h,0A3h,32h,0E6h,74h; 76CD
	defb 78h,0CDh,0F3h,77h,0D9h,21h,9Fh,74h,36h,00h,0D9h,0C9h,32h,0C6h,77h,0CDh; 76DD
	defb 0B8h,77h,3Dh,28h,3Dh,3Dh,28h,4Bh,3Dh,0C8h,0CDh,0A9h,77h,0B7h,20h,11h; 76ED
	defb 0CDh,0B8h,77h,36h,01h,0CDh,9Fh,77h,5Fh,0CDh,0BDh,77h,73h,0CDh,09h,78h; 76FD
	defb 0C9h,21h,0FBh,78h,0CDh,0C5h,77h,35h,20h,13h,0E5h,0CDh,0A9h,77h,0E1h,77h; 770D
	defb 0CDh,0BDh,77h,34h,5Eh,0CDh,9Fh,77h,0BBh,28h,0D5h,18h,0DCh,0CDh,0BDh,77h; 771D
	defb 18h,0D6h,21h,01h,79h,0CDh,0C5h,77h,0B7h,28h,02h,35h,0C9h,0CDh,0B8h,77h; 772D
	defb 36h,02h,0C9h,0CDh,0B3h,77h,0B7h,20h,1Eh,0CDh,0B8h,77h,0E5h,0CDh,0A4h,77h; 773D
	defb 06h,03h,0B7h,28h,05h,0CDh,7Dh,77h,06h,00h,0E1h,70h,0CDh,0BDh,77h,36h; 774D
	defb 00h,1Eh,00h,0CDh,09h,78h,0C9h,21h,07h,79h,0CDh,0C5h,77h,35h,0C0h,0E5h; 775D
	defb 0CDh,0B3h,77h,0E1h,77h,0CDh,0BDh,77h,35h,28h,0CEh,5Eh,0CDh,09h,78h,0C9h; 776D
	defb 11h,03h,00h,0CDh,0A9h,77h,19h,77h,0CDh,0AEh,77h,19h,77h,0CDh,0B3h,77h; 777D
	defb 19h,77h,0CDh,0BDh,77h,36h,00h,0C9h,21h,0EFh,78h,18h,2Bh,21h,0F2h,78h; 778D
	defb 18h,26h,21h,0ECh,78h,18h,21h,21h,0F5h,78h,18h,1Ch,21h,0F8h,78h,18h; 779D
	defb 17h,21h,0FEh,78h,18h,12h,21h,04h,79h,18h,0Dh,21h,0Ah,79h,18h,08h; 77AD
	defb 21h,0Dh,79h,18h,03h,21h,10h,79h,01h,00h,00h,09h,7Eh,0C9h,54h,5Dh; 77BD
	defb 01h,0B8h,0Bh,0CDh,72h,78h,79h,32h,0D9h,77h,0C9h,06h,32h,3Eh,12h,3Dh; 77CD
	defb 20h,0FDh,10h,0F9h,06h,0Ah,10h,0FEh,0C9h,0CDh,05h,78h,2Fh,1Eh,3Ch,0A3h; 77DD
	defb 5Fh,32h,0EBh,77h,18h,0Ch,0CDh,05h,78h,5Fh,3Ah,0EBh,77h,0B3h,32h,0EBh; 77ED
	defb 77h,5Fh,3Eh,07h,0CDh,8Bh,78h,0C9h,87h,0C0h,3Ch,0C9h,3Ah,0C6h,77h,0C6h; 77FD
	defb 08h,0CDh,8Bh,78h,0C9h,0Eh,02h,18h,05h,0C5h,0CDh,27h,78h,0C1h,79h,0CBh; 780D
	defb 27h,0CDh,8Bh,78h,3Ch,5Ah,0CDh,8Bh,78h,0C9h,0F5h,0FEh,0Ch,28h,12h,0FEh; 781D
	defb 0FFh,28h,09h,0FEh,80h,20h,17h,11h,00h,00h,0F1h,0C9h,3Eh,0Bh,05h,18h; 782D
	defb 0Dh,0AFh,04h,18h,09h,0F5h,6Fh,16h,0Ch,0CDh,62h,78h,45h,7Ch,87h,5Fh; 783D
	defb 16h,00h,21h,0D3h,78h,19h,5Eh,23h,56h,78h,0B7h,28h,06h,0CBh,3Ah,0CBh; 784D
	defb 1Bh,10h,0FAh,0F1h,0C9h,06h,08h,26h,00h,29h,7Ch,0BAh,0FAh,6Fh,78h,92h; 785D
	defb 67h,2Ch,10h,0F5h,0C9h,3Eh,10h,21h,00h,00h,0CBh,21h,0CBh,10h,0EDh,6Ah; 786D
	defb 0EDh,52h,30h,05h,19h,3Dh,20h,0F2h,0C9h,0Ch,3Dh,20h,0EDh,0C9h,0Eh,0A0h; 787D
	defb 0EDh,79h,0Ch,0EDh,59h,0C9h,0CDh,0BAh,78h,0D9h,21h,00h,00h,0D9h,7Eh,0CDh; 788D
	defb 0B5h,78h,30h,0Fh,23h,0D9h,29h,54h,5Dh,29h,29h,19h,5Fh,16h,00h,19h; 789D
	defb 0D9h,18h,0EBh,0D9h,0E5h,0D9h,0D1h,0C9h,0C6h,0D0h,0FEh,0Ah,0C9h,7Eh,0B7h,0C8h; 78AD
	defb 0FEh,21h,0D0h,23h,18h,0F7h,43h,00h,44h,02h,45h,04h,46h,05h,47h,07h; 78BD
	defb 41h,09h,42h,0Bh,52h,80h,0DCh,1Dh,2Fh,1Ch,9Ah,1Ah,1Ch,19h,0B3h,17h; 78CD
	defb 5Eh,16h,1Dh,15h,0EEh,13h,0CFh,12h,0C1h,11h,0C2h,10h,0D1h,0Fh; 78DD
L78EB:	defb 10h,12h,12h,12h,04h,04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h; 78EB
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,01h,01h,00h,00h,00h,00h; 78FB
	defb 00h,00h,00h,00h,00h,10h,10h,10h,08h,00h,08h,00h,08h,00h,08h,00h; 790B
	defb 56h,30h,5Eh,52h,31h,00h,80h,0Fh,50h,4Fh,4Eh,4Dh,4Ch,4Bh,4Ah,49h; 791B
	defb 48h,47h,80h,0Eh,46h,45h,44h,43h,42h,41h,40h,3Fh,3Eh,3Dh,80h,0Dh; 792B
	defb 3Ch,3Bh,3Ah,39h,38h,37h,36h,35h,34h,33h,80h,0Ch,32h,31h,30h,2Fh; 793B
	defb 2Eh,2Dh,2Ch,2Bh,2Ah,29h,80h,0Bh,28h,27h,26h,25h,24h,23h,22h,21h; 794B
	defb 20h,1Fh,80h,0Ah,1Eh,1Dh,1Ch,1Bh,1Ah,19h,18h,17h,16h,15h,80h,09h; 795B
	defb 14h,13h,12h,11h,10h,0Fh,0Eh,0Dh,0Ch,0Bh,80h,00h,00h; 796B
ending:	call cls                        ; 7978
	ld a,0Eh                               ; 797B
	ld (L78EB),a                           ; 797D
	ld hl,1210h                            ; 7980
	call music_start                       ; 7983
	xor a                                  ; 7986
L7987:	ld (L7BEA),a                     ; 7987
	ld b,a                                 ; 798A
	srl a                                  ; 798B
	inc a                                  ; 798D
	ld (L7BEB),a                           ; 798E
	xor a                                  ; 7991
	ld (ticks),a                           ; 7992
	ld c,00h                               ; 7995
	ld a,b                                 ; 7997
	bit 0,a                                ; 7998
	jr nz,L79A3                            ; 799A
	ld hl,L7BEB                            ; 799C
	dec (hl)                               ; 799F
	jp L79B2                               ; 79A0
L79A3:	ld a,c                           ; 79A3
	bit 0,a                                ; 79A4
	jr z,L79AE                             ; 79A6
	call L7B84                             ; 79A8
	jp L79B1                               ; 79AB
L79AE:	call L7B7E                       ; 79AE
L79B1:	inc c                            ; 79B1
L79B2:	ld a,(L7BEB)                     ; 79B2
	cp c                                   ; 79B5
	jp nz,L79A3                            ; 79B6
	call delay_2000                        ; 79B9
	ld c,00h                               ; 79BC
	ld a,(L7BEA)                           ; 79BE
	bit 0,a                                ; 79C1
	jp nz,L79CA                            ; 79C3
	ld hl,L7BEB                            ; 79C6
	inc (hl)                               ; 79C9
L79CA:	ld a,(L7BEA)                     ; 79CA
	bit 0,a                                ; 79CD
	jr nz,L79DE                            ; 79CF
	ld d,c                                 ; 79D1
	sla d                                  ; 79D2
	cp d                                   ; 79D4
	jp nz,L79DE                            ; 79D5
	call L7B59                             ; 79D8
	jp L7A34                               ; 79DB
L79DE:	ld ix,L7C64                      ; 79DE
	ld iy,L7BEC                            ; 79E2
	ld b,00h                               ; 79E6
	add ix,bc                              ; 79E8
	sla c                                  ; 79EA
	add iy,bc                              ; 79EC
	srl c                                  ; 79EE
	ld b,(ix+0)                            ; 79F0
	ld a,(ix+60)                           ; 79F3
	cp b                                   ; 79F6
	push af                                ; 79F7
	call z,L7BC6                           ; 79F8
	pop af                                 ; 79FB
	jp nc,L7A34                            ; 79FC
	inc (ix+60)                            ; 79FF
	ld e,a                                 ; 7A02
	ld a,c                                 ; 7A03
	bit 0,a                                ; 7A04
	jr z,L7A0E                             ; 7A06
	ld hl,L7D19                            ; 7A08
	jp L7A11                               ; 7A0B
L7A0E:	ld hl,L7CDC                      ; 7A0E
L7A11:	ld d,00h                         ; 7A11
	add hl,de                              ; 7A13
	ld (L346D),hl                          ; 7A14
	ld a,(iy+0)                            ; 7A17
	ld (L346B),a                           ; 7A1A
	ld a,(iy+1)                            ; 7A1D
	ld (L346C),a                           ; 7A20
	push bc                                ; 7A23
	call L29A8                             ; 7A24
	pop bc                                 ; 7A27
	ld a,(L346B)                           ; 7A28
	ld (iy+0),a                            ; 7A2B
	ld a,(L346C)                           ; 7A2E
	ld (iy+1),a                            ; 7A31
L7A34:	inc c                            ; 7A34
	ld a,(L7BEB)                           ; 7A35
	cp c                                   ; 7A38
	jp nz,L79CA                            ; 7A39
L7A3C:	ld a,(ticks)                     ; 7A3C
	cp 80h                                 ; 7A3F
	jr c,L7A3C                             ; 7A41
	ld a,(L7BEA)                           ; 7A43
	inc a                                  ; 7A46
	cp 76h                                 ; 7A47
	jp c,L7987                             ; 7A49
	ld hl,9B94h                            ; 7A4C
	ld de,L5DDD                            ; 7A4F
	call put16x16                          ; 7A52
	ld bc,1FF0h                            ; 7A55
	; SAPI: MZ: OUT (C),B to the palette (0F0h), pal_write.
	rst 18h
	nop
	ld hl,0204h                            ; 7A5A
	call vaddr                             ; 7A5D
	ld de,0078h                            ; 7A60
	add hl,de                              ; 7A63
	ld de,L7D54                            ; 7A64
	ld a,01h                               ; 7A67
	call print                             ; 7A69
	ld hl,0408h                            ; 7A6C
	call vaddr                             ; 7A6F
	ld de,L7D74                            ; 7A72
	ld a,01h                               ; 7A75
	call print                             ; 7A77
	ld hl,0505h                            ; 7A7A
	call vaddr                             ; 7A7D
	ld de,L7D8C                            ; 7A80
	ld a,01h                               ; 7A83
	call print                             ; 7A85
	ld hl,060Dh                            ; 7A88
	call vaddr                             ; 7A8B
	ld de,L7DAA                            ; 7A8E
	ld a,01h                               ; 7A91
	call print                             ; 7A93
	ld hl,0707h                            ; 7A96
	call vaddr                             ; 7A99
	ld de,L7DB9                            ; 7A9C
	ld a,01h                               ; 7A9F
	call print                             ; 7AA1
	ld hl,080Ch                            ; 7AA4
	call vaddr                             ; 7AA7
	ld de,L7DD4                            ; 7AAA
	ld a,01h                               ; 7AAD
	call print                             ; 7AAF
	ld hl,0904h                            ; 7AB2
	call vaddr                             ; 7AB5
	ld de,L7DE5                            ; 7AB8
	ld a,01h                               ; 7ABB
	call print                             ; 7ABD
	ld hl,0A03h                            ; 7AC0
	call vaddr                             ; 7AC3
	ld de,L7E1F                            ; 7AC6
	ld a,01h                               ; 7AC9
	call print                             ; 7ACB
	ld hl,0B08h                            ; 7ACE
	call vaddr                             ; 7AD1
	ld de,L7E05                            ; 7AD4
	ld a,01h                               ; 7AD7
	call print                             ; 7AD9
	ld hl,0C03h                            ; 7ADC
	call vaddr                             ; 7ADF
	ld de,L7E42                            ; 7AE2
	ld a,01h                               ; 7AE5
	call print                             ; 7AE7
	ld hl,0E05h                            ; 7AEA
	call vaddr                             ; 7AED
	ld de,L7E64                            ; 7AF0
	ld a,01h                               ; 7AF3
	call print                             ; 7AF5
	ld hl,0F07h                            ; 7AF8
	call vaddr                             ; 7AFB
	ld de,L7E83                            ; 7AFE
	ld a,01h                               ; 7B01
	call print                             ; 7B03
	ld hl,1006h                            ; 7B06
	call vaddr                             ; 7B09
	ld de,L7E9E                            ; 7B0C
	ld a,01h                               ; 7B0F
	call print                             ; 7B11
	ld hl,1103h                            ; 7B14
	call vaddr                             ; 7B17
	ld de,L7EBB                            ; 7B1A
	ld a,01h                               ; 7B1D
	call print                             ; 7B1F
	ld hl,1206h                            ; 7B22
	call vaddr                             ; 7B25
	ld de,L7EDD                            ; 7B28
	ld a,01h                               ; 7B2B
	call print                             ; 7B2D
	ld hl,1403h                            ; 7B30
	call vaddr                             ; 7B33
	ld de,L7EF9                            ; 7B36
	ld a,01h                               ; 7B39
	call print                             ; 7B3B
	ld hl,1503h                            ; 7B3E
	call vaddr                             ; 7B41
	ld de,L7F1C                            ; 7B44
	ld a,01h                               ; 7B47
	call print                             ; 7B49
	ld b,00h                               ; 7B4C
L7B4E:	call delay_2000                  ; 7B4E
	djnz L7B4E                             ; 7B51
	ld bc,11F0h                            ; 7B53
	; SAPI: MZ: OUT (C),B to the palette (0F0h), pal_write.
	rst 18h
	nop
	ret                                    ; 7B58
L7B59:	push bc                          ; 7B59
	ld ix,L7BEC                            ; 7B5A
	ld hl,L7CA0                            ; 7B5E
	ld d,00h                               ; 7B61
	ld e,a                                 ; 7B63
	add ix,de                              ; 7B64
	ld b,00h                               ; 7B66
	add hl,bc                              ; 7B68
	ld (ix+0),12h                          ; 7B69
	ld (ix+1),16h                          ; 7B6D
	ld (hl),00h                            ; 7B71
	ld hl,9B92h                            ; 7B73
	ld de,L5DDD                            ; 7B76
	call put16x16                          ; 7B79
	pop bc                                 ; 7B7C
	ret                                    ; 7B7D
L7B7E:	ld hl,L7CDC                      ; 7B7E
	jp L7B87                               ; 7B81
L7B84:	ld hl,L7D19                      ; 7B84
L7B87:	ld ix,L7C64                      ; 7B87
	ld iy,L7BEC                            ; 7B8B
	ld b,00h                               ; 7B8F
	add ix,bc                              ; 7B91
	sla c                                  ; 7B93
	add iy,bc                              ; 7B95
	srl c                                  ; 7B97
	ld b,(ix+0)                            ; 7B99
	ld a,(ix+60)                           ; 7B9C
	cp b                                   ; 7B9F
	ret nc                                 ; 7BA0
	ld d,00h                               ; 7BA1
	ld e,a                                 ; 7BA3
	add hl,de                              ; 7BA4
	ld (L346D),hl                          ; 7BA5
	ld a,(iy+0)                            ; 7BA8
	ld (L346B),a                           ; 7BAB
	ld a,(iy+1)                            ; 7BAE
	ld (L346C),a                           ; 7BB1
	push bc                                ; 7BB4
	call L2900                             ; 7BB5
	pop bc                                 ; 7BB8
	ld a,(L346B)                           ; 7BB9
	ld (iy+0),a                            ; 7BBC
	ld a,(L346C)                           ; 7BBF
	ld (iy+1),a                            ; 7BC2
	ret                                    ; 7BC5
L7BC6:	ld l,(iy+0)                      ; 7BC6
	ld h,(iy+1)                            ; 7BC9
	call vaddr                             ; 7BCC
	ld de,L5DDD                            ; 7BCF
	call put16x16                          ; 7BD2
	inc (ix+60)                            ; 7BD5
	ret                                    ; 7BD8
	defb 3Eh,10h,08h,1Ah,77h,13h,23h,1Ah,77h,13h,09h,08h,3Dh,0C2h,0DBh,7Bh; 7BD9
	defb 0C9h                              ; 7BE9
L7BEA:	defb 00h                         ; 7BEA
L7BEB:	defb 00h                         ; 7BEB
L7BEC:	defs 120                         ; 7BEC
L7C64:	defb 3Ch,3Ah,3Ah,38h,38h,36h,36h,34h,34h,32h,32h,30h,30h,2Eh,2Eh,2Ch; 7C64
	defb 2Ch,2Ah,2Ah,28h,28h,26h,26h,24h,24h,22h,22h,20h,20h,1Eh,1Eh,1Ch; 7C74
	defb 1Ch,1Ah,1Ah,18h,18h,16h,16h,14h,14h,12h,12h,10h,10h,0Eh,0Eh,0Ch; 7C84
	defb 0Ch,0Ah,0Ah,08h,08h,06h,06h,04h,04h,02h,00h,00h; 7C94
L7CA0:	defs 60                          ; 7CA0
L7CDC:	defb 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h; 7CDC
	defb 04h,04h,04h,04h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h; 7CEC
	defb 01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,03h,03h,03h,03h,03h,03h; 7CFC
	defb 03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,0FFh; 7D0C
L7D19:	defb 03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h; 7D19
	defb 03h,03h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h,01h; 7D29
	defb 01h,01h,01h,01h,01h,01h,01h,01h,04h,04h,04h,04h,04h,04h,04h,04h; 7D39
	defb 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0FFh; 7D49
L7D54:	defb 2Ah,20h,43h,65h,72h,74h,69h,66h,69h,63h,61h,74h,65h,20h,6Fh,66h; 7D54
	defb 20h,43h,6Fh,6Dh,6Dh,65h,6Eh,64h,61h,74h,69h,6Fh,6Eh,20h,2Ah,00h; 7D64
L7D74:	defb 54h,68h,69h,73h,20h,69h,73h,20h,74h,6Fh,20h,63h,65h,72h,74h,69h; 7D74
	defb 66h,79h,20h,74h,68h,61h,74h,00h   ; 7D84
L7D8C:	defb 79h,6Fh,75h,20h,68h,61h,76h,65h,20h,73h,75h,63h,63h,65h,73h,73h; 7D8C
	defb 66h,75h,6Ch,6Ch,79h,20h,63h,61h,72h,72h,69h,65h,64h,00h; 7D9C
L7DAA:	defb 61h,6Ch,6Ch,20h,6Fh,66h,20h,74h,68h,65h,20h,32h,30h,30h,00h; 7DAA
L7DB9:	defb 42h,6Ch,75h,65h,20h,53h,74h,6Fh,6Eh,65h,73h,20h,69h,6Eh,74h,6Fh; 7DB9
	defb 20h,42h,6Ch,75h,65h,20h,41h,72h,65h,61h,00h; 7DC9
L7DD4:	defb 75h,73h,69h,6Eh,67h,20h,79h,6Fh,75h,72h,20h,6Dh,69h,6Eh,64h,2Ch; 7DD4
	defb 00h                               ; 7DE4
L7DE5:	defb 6Dh,6Fh,74h,6Fh,72h,20h,73h,6Bh,69h,6Ch,6Ch,73h,20h,61h,6Eh,64h; 7DE5
	defb 20h,72h,65h,66h,6Ch,65h,78h,20h,61h,63h,74h,69h,6Fh,6Eh,73h,00h; 7DF5
L7E05:	defb 72h,75h,62h,62h,69h,6Eh,67h,20h,79h,6Fh,75h,72h,20h,64h,72h,6Fh; 7E05
	defb 77h,73h,79h,20h,65h,79h,65h,73h,2Eh,00h; 7E15
L7E1F:	defb 61h,6Eh,64h,20h,61h,74h,20h,74h,69h,6Dh,65h,73h,20h,61h,6Ch,6Ch; 7E1F
	defb 20h,79h,6Fh,75h,72h,20h,6Eh,65h,76h,65h,72h,73h,20h,77h,68h,69h; 7E2F
	defb 6Ch,65h,00h                       ; 7E3F
L7E42:	defb 59h,6Fh,75h,72h,20h,70h,65h,72h,73h,65h,76h,65h,72h,61h,6Eh,63h; 7E42
	defb 65h,20h,69h,73h,20h,63h,6Fh,6Dh,6Dh,65h,6Eh,64h,61h,62h,6Ch,65h; 7E52
	defb 2Eh,00h                           ; 7E62
L7E64:	defb 54h,68h,65h,20h,64h,42h,2Dh,53h,4Fh,46h,54h,20h,49h,6Eh,63h,2Eh; 7E64
	defb 20h,68h,65h,72h,65h,62h,79h,20h,68h,6Fh,6Eh,6Fh,72h,73h,00h; 7E74
L7E83:	defb 79h,6Fh,75h,20h,66h,6Fh,72h,20h,79h,6Fh,75h,72h,20h,69h,6Eh,74h; 7E83
	defb 65h,6Ch,6Ch,69h,67h,65h,6Eh,63h,65h,2Ch,00h; 7E93
L7E9E:	defb 70h,68h,79h,73h,69h,63h,61h,6Ch,20h,73h,74h,72h,65h,6Eh,67h,74h; 7E9E
	defb 68h,2Ch,20h,66h,69h,67h,68h,74h,20h,61h,6Eh,64h,00h; 7EAE
L7EBB:	defb 66h,6Fh,72h,20h,79h,6Fh,75h,72h,20h,68h,61h,76h,65h,69h,6Eh,67h; 7EBB
	defb 20h,61h,6Dh,70h,6Ch,65h,20h,66h,72h,65h,65h,20h,74h,69h,6Dh,65h; 7ECB
	defb 2Eh,00h                           ; 7EDB
L7EDD:	defb 59h,6Fh,75h,20h,61h,72h,65h,20h,61h,20h,77h,6Fh,6Eh,64h,65h,72h; 7EDD
	defb 66h,75h,6Ch,20h,70h,65h,72h,73h,6Fh,6Eh,2Eh,00h; 7EED
L7EF9:	defb 2Ah,20h,50h,72h,6Fh,67h,72h,61h,6Dh,20h,44h,69h,72h,65h,63h,74h; 7EF9
	defb 6Fh,72h,20h,53h,68h,6Fh,69h,63h,68h,69h,20h,53h,68h,69h,62h,61h; 7F09
	defb 74h,61h,00h                       ; 7F19
L7F1C:	defb 2Ah,20h,50h,72h,6Fh,67h,72h,61h,6Dh,6Dh,65h,72h,20h,20h,20h,20h; 7F1C
	defb 20h,20h,4Bh,61h,7Ah,75h,79h,75h,6Bh,69h,20h,4Fh,6Bh,75h,79h,61h; 7F2C
	defb 6Dh,61h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; 7F3C
	defs 180                               ; 7F4C

; ======================================================================
; stage data (loaded from 8000h) B000-E2FF

	; SAPI: the stage data is at 8000h (MZ: B000h), the VRAM of the MZ was there.
	org 8000h
stage_count:	defb 0C8h                  ; B000
stage_data:	defb 00h,00h,00h,0DFh,0FBh,0E0h,01h,00h,00h,00h,00h,00h,0Eh,0DDh,0E0h,00h; B001
	defb 40h,00h,0FBh,77h,0E0h,00h,00h,00h,7Fh,0DEh,0E0h,00h,00h,00h,04h,13h; B011
	defb 07h,13h,0Fh,21h,07h,17h,07h,03h,13h,13h,01h,05h,21h,0Bh,00h,07h; B021
	defb 1Ch,08h,1Eh,0Ch,25h,14h,02h,14h,0Ah,0Ch,1Ah,02h,0Ah,02h,13h,01h; B031
	defb 01h,15h,00h,00h,00h,00h,00h,00h,20h,0BFh,80h,31h,83h,00h,3Bh,86h; B041
	defb 00h,2Eh,8Ch,00h,24h,98h,00h,20h,0BFh,80h,00h,00h,00h,00h,00h,00h; B051
	defb 06h,1Fh,0Dh,11h,03h,15h,03h,17h,03h,05h,03h,19h,0Dh,02h,13h,13h; B061
	defb 13h,11h,02h,0Bh,0Fh,03h,0Fh,03h,0Eh,14h,0Ch,14h,0Ah,14h,11h,01h; B071
	defb 19h,0Fh,00h,00h,00h,75h,0FBh,0E0h,00h,00h,00h,7Ch,3Fh,0C0h,00h,00h; B081
	defb 00h,0DEh,0F6h,0E0h,80h,00h,00h,9Bh,0EEh,0E0h,00h,00h,00h,1Fh,0EFh,0E0h; B091
	defb 06h,0Bh,01h,09h,09h,11h,0Dh,13h,11h,17h,09h,1Dh,05h,00h,02h,25h; B0A1
	defb 01h,25h,13h,04h,06h,06h,05h,06h,04h,06h,03h,06h,03h,01h,01h,15h; B0B1
	defb 00h,00h,00h,75h,0D7h,40h,5Dh,75h,0C0h,00h,00h,00h,2Eh,0BAh,0C0h,6Bh; B0C1
	defb 0AEh,80h,00h,00h,00h,75h,0D7h,40h,5Dh,75h,0C0h,00h,00h,00h,05h,07h; B0D1
	defb 01h,05h,07h,17h,01h,1Fh,01h,23h,07h,02h,13h,13h,13h,0Dh,01h,21h; B0E1
	defb 0Fh,05h,16h,10h,04h,0Eh,04h,0Ah,0Dh,08h,04h,02h,0Fh,01h,23h,0Fh; B0F1
	defb 00h,07h,0C0h,7Bh,0D0h,00h,10h,1Fh,0A0h,5Dh,0C0h,20h,40h,0Dh,0A0h,7Bh; B101
	defb 88h,00h,00h,0C1h,0C0h,0EEh,08h,00h,80h,3Bh,0C0h,1Bh,80h,00h,06h,07h; B111
	defb 09h,11h,11h,19h,0Dh,1Bh,07h,1Fh,07h,13h,05h,03h,11h,01h,05h,0Dh; B121
	defb 1Dh,0Fh,00h,01h,11h,0Ah,1Bh,03h,01h,15h,00h,00h,00h,4Dh,7Fh,40h; B131
	defb 15h,0D5h,40h,80h,40h,40h,37h,7Fh,0C0h,00h,00h,00h,00h,00h,00h,00h; B141
	defb 00h,00h,00h,00h,00h,00h,00h,00h,06h,05h,07h,05h,05h,05h,03h,05h; B151
	defb 01h,09h,01h,13h,01h,01h,0Dh,07h,03h,15h,05h,19h,05h,1Dh,05h,02h; B161
	defb 01h,06h,26h,14h,03h,01h,01h,14h,00h,00h,00h,00h,00h,40h,00h,00h; B171
	defb 40h,00h,00h,40h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; B181
	defb 00h,00h,00h,00h,00h,00h,00h,00h,04h,25h,07h,25h,05h,25h,03h,25h; B191
	defb 01h,05h,03h,03h,05h,03h,07h,03h,09h,03h,0Bh,03h,23h,01h,21h,15h; B1A1
	defb 00h,00h,00h,55h,55h,40h,00h,00h,00h,2Ah,0AAh,80h,00h,00h,00h,55h; B1B1
	defb 55h,40h,00h,00h,00h,22h,0AAh,80h,2Ah,0AAh,80h,2Ah,0AAh,80h,04h,07h; B1C1
	defb 01h,0Bh,01h,0Fh,01h,09h,0Fh,00h,02h,23h,13h,25h,13h,02h,03h,0Ah; B1D1
	defb 04h,0Ah,03h,01h,13h,15h,00h,00h,00h,1Bh,1Bh,00h,0Ah,0Ah,00h,20h; B1E1
	defb 40h,80h,38h,0E3h,80h,01h,0F0h,00h,63h,0F8h,0C0h,07h,0FCh,00h,0CFh,0FEh; B1F1
	defb 60h,1Fh,0FFh,00h,06h,21h,0Bh,21h,05h,1Fh,01h,07h,01h,0Fh,01h,05h; B201
	defb 05h,03h,05h,0Bh,09h,07h,25h,13h,01h,25h,0Fh,06h,01h,14h,03h,14h; B211
	defb 05h,14h,11h,08h,14h,06h,16h,08h,17h,01h,21h,15h,00h,00h,00h,00h; B221
	defb 00h,00h,06h,78h,00h,06h,0FCh,00h,06h,0CCh,00h,06h,0CCh,00h,06h,0CCh; B231
	defb 00h,06h,0FCh,00h,06h,78h,00h,00h,00h,00h,05h,0Bh,0Fh,0Dh,0Fh,15h; B241
	defb 05h,17h,05h,19h,05h,00h,03h,15h,0Dh,17h,0Dh,11h,0Fh,06h,11h,06h; B251
	defb 12h,06h,0Eh,04h,0Dh,04h,0Ch,04h,0Bh,04h,13h,05h,0Dh,11h,00h,00h; B261
	defs 19                                ; B271
	defb 02h,00h,00h,02h,04h,00h,02h,04h,00h,0Bh,0Dh,05h,0Dh,07h,0Dh,09h; B284
	defb 0Dh,0Bh,0Dh,0Dh,1Bh,0Fh,1Bh,0Dh,1Bh,0Bh,1Bh,09h,1Bh,07h,1Bh,05h; B294
	defb 03h,14h,0Dh,14h,0Bh,14h,09h,00h,02h,01h,14h,26h,14h,0Dh,03h,1Dh; B2A4
	defb 15h,00h,43h,00h,47h,03h,00h,07h,38h,00h,70h,3Bh,60h,76h,00h,60h; B2B4
	defb 76h,0E4h,00h,00h,0E1h,0C0h,18h,0E1h,0C0h,58h,0Dh,0C0h,00h,0Ch,00h,07h; B2C4
	defb 23h,05h,1Fh,05h,19h,03h,15h,03h,11h,09h,0Dh,07h,03h,05h,00h,03h; B2D4
	defb 21h,13h,23h,13h,25h,13h,04h,0Eh,02h,0Dh,02h,0Ch,02h,0Bh,02h,0Fh; B2E4
	defb 01h,25h,15h,00h,40h,00h,00h,40h,00h,00h,40h,00h,00h,40h,00h,0FFh; B2F4
	defb 1Fh,0E0h,00h,00h,00h,00h,40h,00h,00h,40h,00h,00h,40h,00h,00h,40h; B304
	defb 00h,02h,12h,0Bh,13h,09h,00h,03h,01h,13h,25h,13h,25h,01h,02h,01h; B314
	defb 08h,02h,08h,23h,07h,15h,15h,00h,02h,00h,16h,72h,00h,74h,02h,00h; B324
	defb 04h,82h,00h,01h,0D6h,00h,21h,00h,00h,38h,15h,80h,03h,95h,0E0h,60h; B334
	defb 0D4h,00h,00h,00h,00h,07h,1Eh,0Bh,1Fh,09h,20h,07h,21h,05h,22h,03h; B344
	defb 17h,07h,17h,01h,02h,11h,05h,19h,0Bh,02h,25h,13h,1Bh,13h,04h,15h; B354
	defb 02h,05h,04h,09h,0Ch,10h,0Eh,23h,01h,25h,0Fh,00h,40h,00h,57h,5Dh; B364
	defb 40h,50h,01h,40h,57h,1Dh,40h,00h,40h,00h,00h,40h,00h,57h,1Dh,40h; B374
	defb 50h,01h,40h,57h,5Dh,40h,00h,40h,00h,06h,1Fh,0Bh,13h,07h,03h,0Bh; B384
	defb 0Bh,0Bh,0Fh,0Bh,0Dh,05h,00h,03h,25h,11h,25h,13h,23h,13h,04h,03h; B394
	defb 02h,04h,02h,02h,14h,01h,14h,07h,01h,25h,15h,00h,00h,00h,55h,55h; B3A4
	defb 40h,00h,00h,00h,55h,55h,40h,00h,00h,00h,55h,55h,40h,00h,00h,00h; B3B4
	defb 55h,55h,40h,00h,00h,00h,55h,55h,40h,08h,13h,01h,1Fh,01h,0Fh,11h; B3C4
	defb 13h,0Dh,17h,09h,1Bh,0Dh,07h,0Dh,0Bh,05h,00h,03h,15h,13h,1Dh,13h; B3D4
	defb 25h,13h,04h,05h,14h,01h,14h,09h,14h,0Dh,14h,23h,01h,01h,15h,00h; B3E4
	defb 00h,00h,00h,40h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0F0h,01h; B3F4
	defb 0E0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Bh,09h; B404
	defb 0Bh,0Bh,0Bh,0Dh,0Bh,0Fh,0Bh,11h,0Bh,13h,0Bh,15h,0Bh,17h,0Bh,19h; B414
	defb 0Bh,1Bh,0Bh,1Dh,0Bh,00h,02h,01h,0Ah,26h,0Ah,13h,01h,12h,15h,00h; B424
	defb 00h,00h,0EFh,0FFh,0E0h,00h,00h,00h,0FFh,0BFh,0E0h,00h,00h,00h,0DFh,0BFh; B434
	defb 60h,00h,00h,00h,00h,00h,00h,00h,00h,00h,10h,01h,00h,06h,13h,13h; B444
	defb 13h,11h,13h,0Fh,13h,0Dh,07h,09h,1Fh,09h,02h,01h,05h,25h,05h,02h; B454
	defb 25h,13h,01h,13h,02h,13h,02h,14h,02h,11h,05h,13h,15h,00h,00h,00h; B464
	defb 71h,0B1h,0C0h,03h,0B8h,00h,67h,0BCh,0C0h,07h,0BCh,00h,40h,00h,40h,07h; B474
	defb 0BCh,00h,67h,0BCh,0C0h,03h,0B8h,00h,71h,0B1h,0C0h,09h,23h,0Dh,23h,09h; B484
	defb 23h,05h,15h,01h,11h,01h,07h,01h,03h,05h,03h,09h,03h,0Dh,02h,13h; B494
	defb 0Bh,03h,11h,02h,13h,13h,13h,01h,03h,1Fh,12h,23h,12h,08h,12h,1Fh; B4A4
	defb 01h,13h,15h,00h,00h,00h,7Eh,0Fh,0C0h,78h,43h,0C0h,60h,40h,0C0h,04h; B4B4
	defb 0E4h,00h,04h,0E4h,00h,60h,40h,0C0h,78h,43h,0C0h,7Eh,0Fh,0C0h,00h,00h; B4C4
	defb 00h,05h,19h,0Fh,0Dh,0Fh,0Bh,07h,13h,03h,1Dh,01h,02h,0Bh,0Dh,1Bh; B4D4
	defb 07h,02h,25h,01h,25h,13h,06h,09h,0Eh,0Ah,0Eh,0Dh,02h,0Eh,02h,15h; B4E4
	defb 08h,16h,08h,23h,0Bh,01h,15h,00h,00h,00h,00h,00h,00h,00h,00h,00h; B4F4
	defs 21                                ; B504
	defb 0Fh,05h,13h,07h,13h,09h,13h,0Bh,13h,0Dh,13h,0Fh,13h,11h,13h,13h; B519
	defb 13h,15h,13h,17h,13h,19h,13h,1Bh,13h,1Dh,13h,1Fh,13h,21h,13h,00h; B529
	defb 01h,23h,13h,00h,03h,13h,25h,15h,02h,02h,00h,03h,1Eh,00h,01h,10h; B539
	defb 00h,01h,10h,00h,01h,0D0h,00h,00h,50h,00h,00h,50h,00h,00h,00h,00h; B549
	defb 00h,00h,00h,00h,00h,00h,09h,14h,01h,12h,01h,10h,01h,15h,03h,13h; B559
	defb 03h,11h,03h,12h,05h,14h,05h,13h,07h,00h,03h,21h,01h,23h,01h,25h; B569
	defb 01h,03h,02h,14h,04h,14h,06h,14h,16h,01h,1Bh,03h,7Fh,0BFh,0C0h,00h; B579
	defb 00h,00h,7Fh,0BFh,0C0h,00h,00h,00h,7Fh,0BFh,0C0h,00h,00h,00h,7Fh,0BFh; B589
	defb 0C0h,00h,00h,00h,7Fh,0FFh,0C0h,00h,00h,00h,00h,00h,03h,05h,13h,07h; B599
	defb 13h,09h,13h,0Ah,03h,04h,04h,04h,05h,04h,06h,04h,07h,04h,08h,04h; B5A9
	defb 09h,04h,0Ah,04h,0Bh,04h,0Ch,04h,03h,13h,01h,15h,00h,00h,00h,01h; B5B9
	defb 0F0h,00h,07h,1Ch,00h,1Ch,07h,00h,70h,41h,0C0h,40h,00h,40h,00h,00h; B5C9
	defb 00h,00h,00h,00h,00h,00h,00h,15h,55h,00h,05h,13h,07h,13h,0Bh,13h; B5D9
	defb 0Dh,13h,0Fh,13h,11h,00h,03h,21h,13h,23h,13h,25h,13h,04h,1Ch,04h; B5E9
	defb 1Ah,04h,0Dh,04h,0Bh,04h,13h,05h,07h,13h,00h,00h,00h,75h,57h,60h; B5F9
	defb 05h,50h,00h,75h,55h,80h,05h,00h,0E0h,70h,74h,00h,07h,07h,0A0h,50h; B609
	defb 50h,0A0h,57h,56h,0A0h,00h,10h,00h,05h,24h,0Bh,23h,13h,1Fh,05h,0Dh; B619
	defb 0Fh,05h,09h,03h,09h,13h,0Bh,01h,1Bh,01h,03h,23h,11h,23h,0Fh,23h; B629
	defb 0Dh,02h,23h,08h,25h,08h,1Bh,05h,25h,15h,00h,00h,00h,78h,00h,00h; B639
	defb 00h,7Eh,00h,00h,02h,00h,0Fh,00h,00h,40h,18h,00h,7Ch,00h,80h,00h; B649
	defb 7Bh,80h,30h,00h,00h,00h,00h,00h,06h,09h,01h,0Bh,07h,0Bh,0Bh,13h; B659
	defb 03h,19h,09h,13h,0Dh,02h,09h,05h,0Bh,0Fh,03h,25h,13h,25h,0Ah,25h; B669
	defb 01h,05h,07h,02h,06h,02h,05h,02h,04h,02h,03h,02h,19h,03h,03h,0Bh; B679
	defb 00h,00h,00h,28h,0A2h,80h,08h,20h,80h,08h,20h,80h,08h,20h,80h,00h; B689
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,02h,11h; B699
	defb 01h,05h,01h,00h,03h,25h,13h,25h,11h,25h,0Fh,02h,01h,14h,02h,14h; B6A9
	defb 1Dh,01h,01h,15h,00h,00h,00h,0EFh,0FFh,0E0h,00h,00h,00h,0FFh,0BFh,0E0h; B6B9
	defb 00h,00h,00h,0DFh,0BFh,60h,00h,0A0h,00h,00h,0A0h,00h,00h,90h,00h,10h; B6C9
	defb 01h,00h,06h,13h,13h,13h,11h,13h,0Fh,13h,0Dh,07h,09h,1Fh,09h,02h; B6D9
	defb 25h,05h,01h,05h,02h,25h,13h,01h,13h,02h,13h,02h,14h,02h,11h,05h; B6E9
	defb 13h,15h,00h,00h,00h,01h,0F0h,00h,00h,00h,00h,00h,00h,00h,00h,00h; B6F9
	defs 16                                ; B709
	defb 01h,0Eh,01h,00h,04h,10h,01h,12h,01h,14h,01h,16h,01h,08h,10h,02h; B719
	defb 11h,02h,12h,02h,13h,02h,14h,02h,15h,02h,16h,02h,17h,02h,18h,01h; B729
	defb 13h,15h,00h,20h,40h,00h,80h,00h,25h,11h,00h,42h,0Ah,00h,80h,04h; B739
	defb 00h,01h,10h,00h,44h,0A4h,40h,28h,42h,80h,10h,01h,00h,02h,20h,00h; B749
	defb 06h,0Bh,0Bh,17h,09h,11h,01h,0Ah,03h,06h,03h,1Fh,03h,02h,13h,11h; B759
	defb 11h,09h,02h,25h,01h,25h,13h,06h,10h,04h,05h,04h,06h,0Eh,05h,0Eh; B769
	defb 14h,0Eh,24h,0Ch,17h,03h,01h,15h,00h,00h,00h,1Ch,07h,00h,00h,0E0h; B779
	defb 00h,22h,08h,80h,23h,0B8h,80h,20h,00h,80h,07h,0FCh,00h,60h,00h,40h; B789
	defb 47h,0FCh,0C0h,10h,01h,00h,02h,09h,01h,1Dh,01h,00h,02h,12h,13h,14h; B799
	defb 13h,04h,12h,10h,13h,10h,14h,10h,15h,10h,13h,03h,13h,11h,00h,00h; B7A9
	defb 00h,00h,00h,00h,04h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; B7B9
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,09h,0Dh,03h,0Dh; B7C9
	defb 05h,0Dh,07h,0Dh,09h,0Dh,0Bh,0Dh,0Dh,0Dh,0Fh,0Dh,11h,0Dh,13h,00h; B7D9
	defb 04h,1Fh,13h,21h,13h,23h,13h,25h,13h,00h,0Dh,01h,0Bh,05h,00h,01h; B7E9
	defb 00h,80h,00h,80h,40h,04h,40h,00h,08h,20h,10h,10h,20h,08h,20h,20h; B7F9
	defb 04h,40h,80h,02h,80h,80h,00h,00h,00h,1Fh,0F6h,0E0h,05h,06h,07h,1Ch; B809
	defb 03h,0Fh,11h,21h,11h,22h,0Bh,01h,19h,11h,02h,23h,11h,05h,13h,03h; B819
	defb 01h,13h,02h,13h,06h,06h,20h,0Bh,01h,14h,02h,00h,00h,0Ah,0FDh,80h; B829
	defb 0Ah,00h,0C0h,08h,3Eh,40h,0DAh,0E2h,40h,0Ah,20h,00h,7Bh,0BFh,40h,08h; B839
	defb 00h,00h,0EFh,0FDh,0C0h,00h,00h,00h,05h,09h,01h,03h,07h,19h,0Bh,1Fh; B849
	defb 01h,11h,07h,00h,05h,01h,13h,13h,13h,25h,01h,25h,13h,13h,01h,06h; B859
	defb 07h,08h,08h,08h,18h,06h,19h,06h,1Ah,06h,1Bh,06h,1Bh,01h,13h,15h; B869
	defb 3Fh,0FFh,0E0h,02h,00h,00h,14h,05h,00h,10h,04h,00h,14h,05h,00h,14h; B879
	defb 05h,00h,14h,05h,00h,00h,00h,00h,0FFh,03h,0C0h,00h,00h,00h,09h,23h; B889
	defb 13h,21h,13h,1Fh,13h,1Dh,0Fh,1Fh,0Fh,1Ch,07h,08h,07h,09h,0Fh,0Bh; B899
	defb 0Fh,03h,0Bh,02h,1Dh,01h,1Fh,02h,02h,1Dh,0Bh,09h,0Bh,02h,0Ah,0Eh; B8A9
	defb 01h,10h,1Dh,13h,01h,15h,03h,0FEh,00h,00h,30h,00h,44h,40h,00h,5Fh; B8B9
	defb 42h,40h,44h,42h,80h,44h,82h,00h,44h,0C2h,00h,44h,0AAh,40h,59h,31h; B8C9
	defb 80h,00h,00h,00h,07h,20h,07h,0Ah,10h,15h,0Fh,1Dh,0Dh,21h,0Eh,1Dh; B8D9
	defb 05h,07h,0Fh,02h,05h,13h,0Dh,13h,02h,25h,01h,25h,13h,04h,1Fh,10h; B8E9
	defb 20h,10h,09h,06h,07h,06h,22h,05h,21h,10h,00h,00h,00h,1Fh,0BFh,00h; B8F9
	defb 00h,0A0h,00h,1Eh,0AFh,00h,02h,0A8h,00h,1Ah,0ABh,00h,0Ah,0AAh,00h,00h; B909
	defb 00h,00h,00h,00h,00h,00h,00h,00h,02h,1Dh,09h,1Bh,05h,00h,03h,1Bh; B919
	defb 01h,25h,13h,13h,13h,02h,07h,02h,08h,02h,09h,01h,25h,15h,02h,11h; B929
	defb 00h,7Eh,0D4h,40h,00h,97h,80h,0DEh,60h,0A0h,11h,0Eh,80h,45h,0F0h,40h; B939
	defb 59h,07h,40h,46h,7Ch,40h,7Ah,0C7h,0C0h,00h,10h,00h,00h,00h,04h,0Bh; B949
	defb 01h,09h,01h,07h,01h,05h,01h,02h,12h,10h,11h,10h,11h,13h,0Fh,15h; B959
	defb 48h,00h,00h,68h,1Bh,0A0h,00h,08h,80h,6Bh,02h,20h,00h,42h,80h,38h; B969
	defb 08h,80h,00h,0Dh,80h,0D2h,40h,00h,11h,0Dh,60h,00h,21h,00h,05h,13h; B979
	defb 07h,13h,05h,13h,03h,1Fh,01h,05h,05h,01h,19h,01h,02h,25h,13h,23h; B989
	defb 13h,03h,1Ah,0Ah,10h,06h,04h,0Eh,13h,01h,0Dh,0Fh,08h,02h,00h,00h; B999
	defb 0E0h,00h,18h,43h,00h,10h,01h,00h,12h,49h,00h,18h,03h,00h,80h,00h; B9A9
	defb 20h,0C0h,40h,60h,0E2h,08h,0E0h,0FFh,0FFh,0E0h,07h,11h,01h,15h,01h,13h; B9B9
	defb 07h,19h,07h,0Dh,07h,0Dh,0Fh,13h,0Dh,02h,1Fh,0Dh,0Bh,0Bh,00h,02h; B9C9
	defb 19h,10h,1Ah,10h,07h,03h,21h,11h,01h,00h,20h,12h,08h,40h,20h,92h; B9D9
	defb 00h,04h,41h,00h,42h,10h,40h,20h,88h,20h,09h,01h,00h,90h,42h,00h; B9E9
	defb 44h,90h,80h,02h,08h,40h,06h,1Fh,0Bh,1Dh,03h,17h,07h,17h,0Fh,0Bh; B9F9
	defb 05h,09h,0Bh,01h,17h,0Dh,02h,25h,13h,25h,11h,04h,08h,02h,02h,0Eh; BA09
	defb 0Ch,10h,24h,08h,11h,09h,21h,15h,00h,40h,00h,00h,40h,40h,00h,00h; BA19
	defb 40h,00h,00h,40h,00h,00h,40h,80h,00h,0C0h,80h,00h,0C0h,0C0h,01h,0C0h; BA29
	defb 0E0h,03h,0C0h,0F8h,0Fh,0C0h,00h,00h,02h,15h,13h,17h,13h,03h,0Bh,14h; BA39
	defb 0Ch,14h,0Dh,14h,22h,01h,25h,15h,77h,0BDh,0C0h,77h,0BDh,0C0h,00h,00h; BA49
	defb 00h,77h,0BDh,0C0h,77h,0BDh,0C0h,77h,0BDh,80h,00h,00h,00h,77h,0BDh,0C0h; BA59
	defb 77h,0BDh,0C0h,77h,0BDh,0C0h,07h,23h,0Dh,24h,0Bh,1Ch,0Dh,1Dh,0Bh,12h; BA69
	defb 0Dh,13h,0Bh,12h,05h,03h,21h,05h,21h,0Dh,18h,0Dh,00h,04h,04h,0Eh; BA79
	defb 03h,0Eh,03h,06h,04h,06h,13h,03h,25h,15h,00h,00h,00h,00h,00h,00h; BA89
	defs 24                                ; BA99
	defb 02h,13h,09h,13h,07h,00h,03h,25h,13h,23h,13h,21h,13h,04h,02h,14h; BAB1
	defb 04h,14h,06h,14h,08h,14h,13h,05h,13h,0Bh,00h,08h,0A0h,28h,80h,00h; BAC1
	defb 10h,01h,40h,00h,21h,0E0h,05h,04h,00h,82h,0Ch,00h,05h,08h,80h,00h; BAD1
	defb 18h,00h,40h,88h,00h,00h,00h,00h,02h,1Bh,07h,23h,03h,00h,02h,07h; BAE1
	defb 03h,25h,03h,01h,24h,02h,06h,01h,25h,15h,00h,00h,00h,00h,00h,00h; BAF1
	defb 0FFh,0DFh,0C0h,00h,00h,00h,7Fh,0BFh,0E0h,00h,00h,00h,0FFh,0DFh,0C0h,00h; BB01
	defb 00h,00h,7Fh,0BFh,0E0h,00h,00h,00h,05h,12h,13h,16h,0Fh,12h,0Bh,16h; BB11
	defb 07h,12h,03h,04h,12h,0Fh,16h,0Bh,12h,07h,16h,03h,00h,03h,03h,04h; BB21
	defb 02h,04h,01h,04h,13h,01h,13h,15h,00h,00h,00h,00h,34h,00h,00h,00h; BB31
	defb 00h,00h,6Ch,00h,00h,00h,00h,00h,0D8h,00h,00h,00h,00h,01h,0B0h,00h; BB41
	defb 00h,00h,00h,03h,0E0h,00h,05h,13h,11h,0Fh,11h,1Bh,01h,19h,05h,17h; BB51
	defb 09h,01h,1Dh,09h,03h,11h,11h,17h,05h,17h,07h,01h,1Ch,06h,15h,05h; BB61
	defb 11h,13h,00h,00h,00h,20h,40h,80h,00h,80h,00h,10h,21h,00h,00h,00h; BB71
	defb 00h,20h,40h,80h,00h,00h,00h,10h,21h,00h,00h,80h,00h,20h,40h,80h; BB81
	defb 00h,00h,02h,05h,01h,03h,13h,06h,02h,14h,01h,14h,13h,0Ah,14h,0Ah; BB91
	defb 21h,02h,22h,02h,13h,01h,11h,15h,0Eh,0EEh,00h,68h,02h,0E0h,23h,0A0h; BBA1
	defb 00h,28h,0B9h,0A0h,6Eh,20h,20h,02h,0A2h,0A0h,0F8h,0Eh,00h,00h,00h,0C0h; BBB1
	defb 7Bh,2Eh,80h,01h,0E8h,80h,06h,03h,01h,09h,05h,11h,09h,15h,0Fh,1Dh; BBC1
	defb 09h,1Fh,05h,02h,09h,0Bh,03h,13h,02h,25h,13h,17h,13h,04h,04h,08h; BBD1
	defb 04h,0Ch,06h,0Ch,08h,0Ch,19h,05h,0Fh,11h,00h,00h,00h,0Fh,9Ch,00h; BBE1
	defb 0Fh,0B6h,00h,0Ch,36h,00h,0Fh,36h,00h,0Fh,0B6h,00h,01h,0B6h,00h,0Fh; BBF1
	defb 0BEh,00h,0Fh,1Ch,00h,00h,00h,00h,06h,11h,0Dh,15h,0Dh,1Bh,0Dh,1Dh; BC01
	defb 0Dh,15h,07h,13h,13h,01h,19h,0Dh,03h,17h,0Dh,17h,07h,0Fh,0Dh,06h; BC11
	defb 0Eh,02h,0Dh,02h,0Ch,02h,0Bh,02h,0Ah,02h,09h,02h,0Dh,0Dh,19h,0Fh; BC21
	defb 40h,10h,00h,0Eh,01h,00h,28h,0F7h,40h,23h,04h,00h,39h,51h,40h,00h; BC31
	defb 1Ch,00h,4Dh,11h,40h,65h,0A4h,00h,00h,0Dh,60h,08h,00h,00h,06h,22h; BC41
	defb 0Fh,21h,0Dh,21h,0Bh,13h,07h,13h,03h,09h,01h,00h,03h,25h,13h,20h; BC51
	defb 13h,23h,13h,04h,13h,14h,14h,14h,15h,14h,16h,14h,21h,09h,25h,11h; BC61
	defs 30                                ; BC71
	defb 07h,1Ch,13h,1Bh,11h,1Ah,0Fh,19h,0Dh,18h,0Bh,17h,09h,16h,07h,00h; BC8F
	defb 05h,01h,13h,03h,13h,05h,13h,07h,13h,09h,13h,00h,15h,05h,1Fh,15h; BC9F
	defb 00h,00h,00h,00h,00h,00h,20h,80h,00h,71h,0EEh,00h,24h,42h,0C0h,78h; BCAF
	defb 0F4h,80h,0A4h,24h,40h,0B4h,68h,40h,0A5h,08h,80h,48h,0E7h,00h,05h,23h; BCBF
	defb 05h,23h,07h,0Bh,07h,11h,05h,06h,13h,02h,0Bh,0Fh,0Bh,0Dh,01h,19h; BCCF
	defb 11h,04h,0Fh,14h,10h,14h,08h,0Eh,07h,0Eh,23h,03h,11h,13h,1Fh,03h; BCDF
	defb 0E0h,0C0h,78h,00h,77h,53h,0C0h,00h,06h,00h,0BBh,0ECh,0C0h,00h,00h,00h; BCEF
	defb 0DFh,6Eh,0E0h,00h,00h,00h,77h,0B7h,0C0h,00h,00h,00h,04h,21h,0Bh,17h; BCFF
	defb 0Fh,07h,0Bh,0Dh,03h,04h,1Fh,13h,1Bh,0Bh,0Dh,0Fh,05h,07h,00h,05h; BD0F
	defb 05h,04h,15h,02h,1Bh,06h,21h,08h,03h,0Ch,13h,07h,01h,15h,00h,00h; BD1F
	defb 00h,00h,18h,00h,37h,0DFh,80h,00h,00h,00h,37h,0BDh,80h,00h,00h,00h; BD2F
	defb 37h,0BDh,80h,00h,00h,00h,00h,00h,00h,2Ah,0AAh,80h,06h,1Fh,0Bh,1Fh; BD3F
	defb 07h,19h,01h,11h,03h,0Bh,03h,0Dh,0Bh,00h,02h,23h,13h,25h,13h,04h; BD4F
	defb 07h,04h,06h,04h,05h,04h,08h,04h,1Fh,03h,01h,15h,10h,0Ch,00h,0D7h; BD5F
	defb 61h,0C0h,04h,0Ch,00h,71h,0DDh,0C0h,07h,00h,00h,0F1h,6Eh,0C0h,64h,00h; BD6F
	defb 40h,0Eh,0FBh,40h,0DEh,01h,60h,00h,5Ch,00h,04h,05h,09h,0Bh,0Bh,13h; BD7F
	defb 05h,0Dh,01h,02h,1Bh,09h,17h,0Dh,03h,01h,0Dh,25h,13h,25h,0Fh,06h; BD8F
	defb 1Fh,14h,21h,0Ah,13h,0Eh,0Bh,14h,08h,06h,16h,02h,1Fh,01h,01h,15h; BD9F
	defb 00h,00h,00h,64h,90h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; BDAF
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,08h,17h; BDBF
	defb 01h,11h,01h,0Bh,01h,25h,13h,25h,11h,25h,0Fh,25h,0Dh,25h,0Bh,00h; BDCF
	defb 04h,23h,13h,23h,11h,23h,0Fh,23h,0Dh,04h,06h,02h,05h,02h,04h,02h; BDDF
	defb 03h,02h,25h,07h,25h,15h,00h,00h,00h,00h,0A0h,00h,03h,10h,00h,1Fh; BDEF
	defb 0BFh,00h,0F0h,01h,0E0h,30h,01h,80h,1Fh,1Fh,00h,07h,0BCh,00h,00h,00h; BDFF
	defb 00h,0FFh,0D5h,0E0h,0Ah,14h,05h,12h,05h,07h,09h,05h,09h,12h,0Dh,14h; BE0F
	defb 0Dh,13h,0Fh,13h,11h,13h,0Bh,20h,0Bh,00h,02h,22h,0Bh,1Eh,0Bh,02h; BE1F
	defb 1Eh,0Dh,1Dh,0Dh,11h,01h,1Fh,13h,00h,00h,00h,00h,00h,00h,0E0h,00h; BE2F
	defb 00h,00h,00h,00h,1Eh,00h,00h,00h,00h,00h,0FDh,0E0h,00h,00h,00h,00h; BE3F
	defb 0FBh,0DEh,00h,00h,00h,20h,03h,07h,07h,0Fh,0Bh,17h,0Fh,03h,05h,13h; BE4F
	defb 05h,0Fh,05h,0Bh,00h,04h,03h,04h,03h,0Ch,03h,10h,03h,14h,05h,03h; BE5F
	defb 25h,13h,77h,0BDh,0C0h,77h,0BDh,0C0h,00h,00h,00h,77h,0BDh,0C0h,77h,0BDh; BE6F
	defb 0C0h,77h,0BDh,80h,00h,00h,00h,77h,0BDh,0C0h,77h,0BDh,0C0h,77h,0BDh,0C0h; BE7F
	defb 07h,24h,0Dh,25h,0Bh,1Ch,0Dh,1Dh,0Bh,12h,0Dh,12h,05h,13h,03h,03h; BE8F
	defb 18h,0Dh,21h,0Dh,21h,05h,00h,04h,04h,06h,03h,06h,04h,0Eh,03h,0Eh; BE9F
	defb 13h,01h,25h,15h,00h,00h,00h,00h,00h,00h,00h,08h,00h,02h,00h,00h; BEAF
	defb 00h,08h,00h,02h,00h,00h,00h,0Ch,00h,02h,20h,00h,00h,2Ch,00h,06h; BEBF
	defb 40h,00h,07h,0Dh,11h,0Dh,0Dh,0Dh,09h,0Dh,05h,19h,07h,19h,0Bh,19h; BECF
	defb 0Fh,00h,01h,01h,13h,04h,0Ch,12h,0Bh,12h,1Bh,0Ch,1Ch,0Ch,19h,03h; BEDF
	defb 01h,15h,00h,00h,00h,67h,70h,40h,20h,13h,40h,20h,10h,40h,20h,14h; BEEF
	defb 40h,20h,10h,40h,20h,10h,40h,20h,10h,00h,77h,73h,80h,00h,00h,00h; BEFF
	defb 05h,22h,0Fh,23h,0Dh,17h,0Fh,05h,0Dh,05h,0Bh,04h,0Ah,03h,10h,03h; BF0F
	defb 11h,0Fh,11h,13h,00h,02h,04h,10h,03h,10h,03h,01h,25h,14h,00h,00h; BF1F
	defb 00h,7Ch,47h,0C0h,10h,41h,00h,11h,0F1h,00h,00h,00h,00h,00h,00h,00h; BF2F
	defb 11h,0F1h,00h,10h,41h,00h,7Ch,47h,0C0h,00h,00h,00h,05h,0Bh,0Fh,07h; BF3F
	defb 01h,13h,0Bh,0Fh,05h,17h,05h,02h,13h,09h,13h,13h,02h,23h,0Fh,1Bh; BF4F
	defb 0Fh,04h,03h,10h,04h,10h,04h,02h,03h,02h,1Fh,01h,07h,0Dh,00h,00h; BF5F
	defs 30                                ; BF6F
	defb 03h,01h,13h,25h,13h,25h,01h,00h,23h,13h,25h,15h,71h,00h,20h,11h; BF8D
	defb 7Eh,0E0h,0DDh,10h,20h,05h,57h,0A0h,0EDh,01h,20h,05h,6Dh,60h,0DDh,45h; BF9D
	defb 40h,05h,51h,40h,7Dh,0FDh,40h,00h,00h,00h,05h,13h,05h,1Bh,05h,1Bh; BFAD
	defb 09h,0Bh,03h,03h,03h,02h,07h,07h,07h,0Fh,03h,17h,01h,15h,01h,13h; BFBD
	defb 01h,04h,07h,0Ch,09h,0Ch,04h,0Ch,02h,0Ch,1Dh,01h,15h,11h,00h,00h; BFCD
	defb 00h,00h,00h,00h,0DEh,0EFh,60h,00h,00h,00h,21h,55h,00h,00h,00h,00h; BFDD
	defb 01h,55h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,05h,0Eh,0Bh,1Dh; BFED
	defb 03h,19h,03h,0Bh,03h,07h,03h,00h,08h,10h,0Bh,12h,0Bh,14h,0Bh,16h; BFFD
	defb 0Bh,18h,0Bh,1Ah,0Bh,1Ch,0Bh,1Eh,0Bh,01h,04h,04h,20h,0Bh,01h,15h; C00D
	defb 00h,00h,00h,00h,40h,00h,00h,00h,00h,7Eh,4Fh,0C0h,00h,00h,00h,00h; C01D
	defb 40h,00h,00h,00h,00h,00h,40h,00h,0EEh,0EEh,0E0h,0BBh,0BBh,0A0h,05h,1Eh; C02D
	defb 05h,08h,05h,13h,01h,13h,05h,13h,09h,00h,02h,23h,0Fh,25h,0Fh,04h; C03D
	defb 23h,06h,24h,06h,04h,06h,03h,06h,13h,0Dh,05h,11h,00h,00h,00h,7Bh; C04D
	defb 88h,20h,00h,8Bh,80h,78h,39h,00h,02h,21h,40h,7Ah,00h,00h,03h,0C7h; C05D
	defb 0E0h,0FEh,00h,00h,00h,0Eh,0E0h,00h,20h,00h,08h,06h,09h,06h,05h,11h; C06D
	defb 01h,19h,01h,1Dh,03h,23h,07h,11h,0Bh,1Dh,0Fh,03h,0Bh,13h,09h,13h; C07D
	defb 1Fh,0Bh,01h,25h,13h,05h,02h,0Eh,01h,0Eh,0Eh,02h,0Dh,02h,0Fh,0Ch; C08D
	defb 03h,01h,01h,15h,00h,00h,00h,7Eh,03h,0E0h,00h,00h,00h,1Fh,0F1h,80h; C09D
	defb 00h,20h,80h,0FCh,18h,80h,20h,04h,0C0h,1Fh,80h,00h,00h,43h,80h,00h; C0AD
	defb 00h,00h,06h,0Bh,05h,0Bh,09h,03h,09h,1Bh,0Bh,1Fh,01h,1Fh,05h,01h; C0BD
	defb 0Bh,0Dh,01h,01h,13h,04h,22h,02h,23h,02h,24h,02h,25h,02h,0Bh,01h; C0CD
	defb 01h,15h,00h,00h,00h,39h,04h,00h,00h,07h,80h,00h,20h,00h,33h,20h; C0DD
	defb 80h,00h,00h,0C0h,09h,00h,00h,19h,80h,00h,00h,35h,00h,00h,10h,00h; C0ED
	defb 07h,21h,01h,21h,03h,15h,05h,15h,01h,0Fh,07h,07h,07h,05h,01h,02h; C0FD
	defb 23h,01h,0Bh,05h,02h,1Bh,13h,25h,13h,04h,05h,08h,0Ah,0Ch,10h,02h; C10D
	defb 22h,08h,15h,03h,1Fh,11h,03h,88h,00h,78h,0AEh,00h,0Eh,23h,80h,02h; C11D
	defb 80h,00h,42h,0B7h,80h,7Ah,20h,00h,7Bh,7Bh,20h,7Bh,00h,00h,7Ah,0BFh; C12D
	defb 60h,08h,00h,00h,06h,03h,0Bh,05h,0Dh,08h,09h,07h,07h,22h,07h,10h; C13D
	defb 13h,00h,02h,05h,0Bh,0Bh,13h,02h,03h,08h,10h,12h,04h,07h,05h,0Fh; C14D
	defb 55h,55h,40h,00h,00h,00h,55h,55h,40h,00h,00h,00h,55h,55h,40h,00h; C15D
	defb 00h,00h,55h,55h,40h,00h,00h,00h,55h,55h,40h,00h,00h,00h,07h,1Fh; C16D
	defb 0Bh,1Bh,07h,17h,0Bh,13h,07h,0Fh,0Bh,0Bh,07h,07h,0Bh,00h,03h,11h; C17D
	defb 01h,15h,01h,19h,01h,05h,0Ch,0Ch,10h,08h,14h,0Ch,18h,08h,1Ch,0Ch; C18D
	defb 23h,03h,01h,15h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h; C19D
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,02h,00h,00h; C1AD
	defb 00h,00h,01h,1Bh,13h,04h,25h,11h,23h,11h,21h,11h,1Fh,11h,05h,1Dh; C1BD
	defb 13h,1Fh,13h,21h,13h,23h,13h,25h,13h,06h,1Ah,14h,19h,14h,18h,14h; C1CD
	defb 17h,14h,16h,14h,15h,14h,13h,13h,25h,15h,00h,00h,00h,10h,00h,00h; C1DD
	defb 7Dh,0E4h,00h,10h,14h,00h,7Ch,14h,40h,10h,14h,40h,38h,24h,40h,54h; C1ED
	defb 44h,40h,20h,02h,00h,0Dh,30h,0E0h,07h,23h,07h,17h,09h,16h,0Bh,07h; C1FD
	defb 0Bh,07h,07h,07h,05h,0Bh,11h,02h,11h,11h,18h,0Bh,03h,05h,0Fh,1Dh; C20D
	defb 13h,1Fh,13h,05h,03h,0Eh,02h,14h,0Bh,0Eh,1Eh,10h,1Dh,10h,07h,03h; C21D
	defb 1Dh,15h,00h,01h,80h,5Dh,0DCh,00h,50h,01h,60h,07h,87h,40h,0C0h,00h; C22D
	defb 00h,5Bh,9Dh,80h,00h,91h,00h,4Eh,80h,60h,62h,1Eh,00h,00h,0C0h,0C0h; C23D
	defb 05h,0Fh,01h,1Bh,01h,1Bh,0Fh,1Bh,09h,03h,01h,02h,1Bh,13h,09h,13h; C24D
	defb 02h,25h,13h,25h,01h,05h,08h,02h,0Ah,02h,0Ah,0Ah,08h,0Ah,09h,0Eh; C25D
	defb 0Fh,05h,25h,15h,06h,04h,60h,2Ch,16h,40h,6Ch,30h,00h,66h,61h,80h; C26D
	defb 33h,4Ch,0C0h,18h,06h,40h,4Eh,63h,00h,60h,31h,80h,31h,19h,0A0h,07h; C27D
	defb 03h,20h,05h,19h,0Fh,19h,0Dh,12h,05h,13h,03h,0Dh,0Bh,01h,13h,0Bh; C28D
	defb 02h,25h,03h,1Bh,13h,04h,25h,10h,10h,10h,18h,02h,18h,0Eh,1Bh,07h; C29D
	defb 15h,15h,00h,00h,00h,55h,0B7h,40h,55h,0B7h,40h,01h,0B3h,00h,5Dh,0B6h; C2AD
	defb 40h,5Dh,0B6h,40h,18h,33h,00h,5Dh,0B7h,40h,5Dh,0B7h,40h,00h,00h,00h; C2BD
	defb 03h,23h,07h,11h,01h,07h,01h,02h,13h,13h,1Dh,01h,02h,1Bh,07h,1Bh; C2CD
	defb 0Dh,06h,09h,08h,04h,0Eh,09h,14h,1Ch,14h,1Fh,0Ch,17h,02h,0Bh,01h; C2DD
	defb 0Bh,0Fh,04h,1Ch,00h,6Ch,04h,00h,20h,00h,0C0h,06h,08h,40h,62h,4Eh; C2ED
	defb 40h,40h,02h,00h,58h,00h,00h,13h,45h,20h,31h,29h,80h,00h,10h,00h; C2FD
	defb 07h,12h,07h,11h,05h,10h,03h,0Fh,01h,1Dh,13h,1Dh,07h,23h,03h,01h; C30D
	defb 17h,0Dh,02h,25h,01h,25h,11h,04h,12h,14h,06h,10h,1Ah,06h,20h,0Eh; C31D
	defb 12h,03h,25h,15h,10h,00h,00h,00h,03h,00h,46h,00h,00h,02h,02h,0C0h; C32D
	defb 32h,68h,80h,00h,00h,80h,00h,00h,00h,4Ah,0E0h,00h,78h,00h,00h,00h; C33D
	defb 00h,00h,09h,0Dh,0Dh,07h,07h,13h,05h,15h,05h,16h,03h,14h,03h,12h; C34D
	defb 03h,1Dh,01h,23h,05h,01h,13h,13h,02h,25h,13h,25h,01h,03h,1Eh,06h; C35D
	defb 16h,0Eh,03h,0Eh,14h,07h,19h,09h,00h,00h,00h,0DEh,0F6h,0E0h,00h,00h; C36D
	defb 00h,0F7h,0BEh,0E0h,00h,02h,00h,0BDh,0EEh,0E0h,00h,02h,00h,0EFh,7Ah,0E0h; C37D
	defb 00h,02h,00h,00h,02h,0E0h,08h,07h,09h,0Dh,05h,11h,09h,13h,01h,20h; C38D
	defb 05h,20h,09h,20h,0Dh,20h,11h,00h,04h,25h,11h,25h,0Dh,25h,09h,25h; C39D
	defb 05h,04h,25h,02h,24h,02h,23h,02h,22h,02h,1Dh,05h,1Fh,15h,61h,0E8h; C3AD
	defb 20h,0Ch,03h,0A0h,0E9h,0B6h,00h,0Ch,02h,0C0h,61h,6Bh,80h,6Ch,08h,20h; C3BD
	defb 0C5h,0DEh,0E0h,10h,10h,20h,7Dh,0B5h,0A0h,20h,01h,00h,05h,0Bh,01h,0Fh; C3CD
	defb 07h,11h,0Fh,1Dh,0Bh,1Fh,01h,03h,11h,03h,11h,0Bh,15h,13h,02h,23h; C3DD
	defb 13h,03h,13h,06h,04h,08h,04h,10h,0Bh,0Ah,1Bh,14h,19h,08h,22h,06h; C3ED
	defb 15h,07h,07h,15h,00h,00h,00h,51h,59h,40h,03h,08h,00h,50h,63h,40h; C3FD
	defb 03h,0FDh,00h,50h,01h,40h,03h,38h,00h,51h,0C9h,40h,02h,10h,00h,50h; C40D
	defb 0D1h,40h,05h,07h,0Dh,03h,05h,14h,0Bh,1Fh,0Dh,1Fh,01h,02h,13h,01h; C41D
	defb 1Fh,11h,03h,09h,13h,25h,01h,25h,13h,03h,04h,0Eh,04h,12h,08h,12h; C42D
	defb 13h,09h,13h,0Fh,00h,00h,00h,6Eh,0EEh,0C0h,00h,00h,00h,7Fh,0FFh,0C0h; C43D
	defs 18                                ; C44D
	defb 04h,09h,01h,11h,01h,19h,01h,21h,01h,04h,1Fh,05h,17h,05h,0Fh,05h; C45F
	defb 07h,05h,01h,25h,13h,04h,03h,02h,04h,02h,05h,02h,06h,02h,03h,05h; C46F
	defb 21h,07h,00h,00h,00h,7Dh,53h,0C0h,11h,00h,00h,11h,0E3h,0C0h,11h,00h; C47F
	defb 40h,11h,1Ch,40h,11h,00h,40h,11h,00h,40h,7Ch,0E3h,0C0h,00h,00h,00h; C48F
	defb 06h,17h,01h,19h,09h,23h,0Fh,07h,0Fh,07h,05h,07h,03h,00h,03h,0Fh; C49F
	defb 0Fh,24h,11h,21h,07h,06h,03h,10h,04h,10h,1Ch,0Ah,17h,0Ah,0Ch,02h; C4AF
	defb 0Ah,02h,23h,07h,03h,11h,00h,00h,00h,00h,00h,00h,7Bh,80h,00h,0Ah; C4BF
	defb 0AAh,80h,00h,00h,00h,1Dh,0E3h,80h,05h,3Eh,00h,07h,00h,00h,00h,00h; C4CF
	defb 00h,00h,00h,00h,03h,19h,05h,1Dh,05h,0Fh,03h,01h,25h,05h,02h,25h; C4DF
	defb 07h,25h,09h,06h,07h,0Ah,08h,0Ah,09h,0Ah,0Ah,0Ah,0Dh,0Eh,0Eh,0Eh; C4EF
	defb 06h,03h,24h,14h,6Dh,0B6h,0C0h,00h,00h,00h,0EEh,0EEh,0E0h,00h,00h,00h; C4FF
	defb 0F7h,5Dh,0E0h,00h,00h,00h,0DDh,0F7h,60h,00h,00h,00h,77h,0BDh,0C0h,00h; C50F
	defb 00h,00h,02h,13h,13h,19h,03h,04h,13h,0Fh,13h,0Bh,13h,07h,13h,03h; C51F
	defb 00h,04h,04h,04h,03h,04h,02h,04h,01h,04h,13h,11h,13h,15h,00h,00h; C52F
	defb 00h,6Ch,06h,0C0h,00h,00h,00h,36h,0Dh,80h,00h,00h,00h,1Bh,1Bh,00h; C53F
	defb 00h,00h,00h,0Dh,0B6h,00h,00h,00h,00h,06h,0ECh,00h,09h,03h,01h,05h; C54F
	defb 05h,0Bh,05h,0Dh,09h,19h,09h,1Bh,05h,1Dh,01h,23h,01h,21h,05h,02h; C55F
	defb 13h,05h,13h,11h,01h,25h,13h,04h,1Eh,0Eh,20h,0Ah,09h,0Eh,07h,0Ah; C56F
	defb 09h,01h,1Fh,0Bh,22h,10h,00h,0Ah,15h,0C0h,0F0h,85h,00h,00h,21h,0C0h; C57F
	defb 7Eh,3Eh,00h,21h,03h,0C0h,0ACh,9Ah,00h,24h,7Bh,0A0h,75h,8Ah,00h,04h; C58F
	defb 20h,00h,04h,14h,05h,13h,03h,10h,03h,17h,0Bh,03h,25h,11h,25h,0Dh; C59F
	defb 23h,09h,01h,1Dh,07h,01h,26h,14h,0Fh,01h,17h,0Dh,00h,00h,00h,00h; C5AF
	defb 09h,00h,03h,80h,00h,50h,00h,00h,76h,0E1h,00h,00h,00h,00h,44h,0F9h; C5BF
	defb 00h,00h,00h,00h,00h,00h,00h,4Fh,7Ch,00h,0Ah,03h,0Bh,03h,11h,0Dh; C5CF
	defb 03h,11h,03h,11h,07h,15h,07h,1Fh,01h,1Fh,07h,1Fh,0Bh,0Bh,0Bh,01h; C5DF
	defb 13h,0Fh,02h,23h,13h,25h,13h,03h,1Ah,02h,0Eh,08h,12h,14h,03h,05h; C5EF
	defb 07h,07h,00h,00h,00h,6Dh,0B6h,0C0h,49h,24h,00h,03h,0Dh,80h,70h,41h; C5FF
	defb 00h,46h,0DBh,40h,1Ch,10h,40h,71h,0B6h,0C0h,47h,24h,80h,00h,00h,00h; C60F
	defb 06h,07h,07h,11h,0Dh,13h,07h,19h,09h,1Bh,0Dh,19h,13h,00h,03h,01h; C61F
	defb 13h,25h,13h,25h,01h,05h,20h,06h,16h,0Eh,0Dh,0Ah,04h,08h,21h,14h; C62F
	defb 0Fh,01h,01h,15h,04h,00h,60h,31h,99h,20h,1Fh,33h,80h,4Eh,67h,00h; C63F
	defb 64h,0CEh,40h,31h,0E0h,0C0h,38h,0F9h,80h,72h,73h,20h,27h,26h,60h,80h; C64F
	defb 00h,0E0h,01h,13h,11h,00h,03h,1Bh,13h,1Dh,13h,1Fh,13h,06h,08h,0Ah; C65F
	defb 0Ch,04h,18h,0Ch,1Fh,02h,24h,08h,0Eh,0Eh,14h,13h,03h,15h,00h,00h; C66F
	defb 00h,39h,0F4h,0C0h,00h,00h,00h,34h,03h,00h,65h,28h,00h,40h,38h,60h; C67F
	defb 40h,03h,00h,08h,20h,00h,1Ah,20h,0E0h,3Ah,0F9h,0E0h,06h,07h,01h,0Fh; C68F
	defb 07h,22h,01h,1Eh,05h,1Bh,01h,1Eh,0Bh,02h,13h,0Dh,13h,05h,01h,25h; C69F
	defb 0Fh,02h,0Fh,02h,05h,06h,13h,01h,15h,0Fh,4Ch,00h,00h,00h,33h,60h; C6AF
	defb 61h,12h,40h,47h,33h,00h,65h,00h,40h,40h,03h,0E0h,6Ch,51h,00h,02h; C6BF
	defb 0F4h,00h,6Ah,05h,00h,00h,00h,00h,09h,22h,13h,23h,11h,22h,0Fh,03h; C6CF
	defb 0Fh,0Bh,05h,05h,03h,05h,01h,15h,01h,1Fh,01h,00h,03h,1Fh,13h,1Fh; C6DF
	defb 0Fh,0Dh,13h,04h,03h,04h,04h,04h,10h,04h,17h,02h,21h,0Dh,25h,15h; C6EF
	defb 00h,00h,00h,6Dh,0B6h,0C0h,00h,00h,00h,00h,00h,00h,6Dh,0B6h,0C0h,00h; C6FF
	defb 00h,00h,00h,00h,00h,6Dh,0B6h,0C0h,00h,00h,00h,00h,00h,00h,06h,0Fh; C70F
	defb 0Dh,0Fh,07h,09h,07h,15h,07h,15h,01h,0Fh,01h,00h,03h,25h,03h,25h; C71F
	defb 09h,25h,0Fh,04h,05h,08h,0Bh,0Eh,17h,0Eh,1Dh,08h,1Bh,01h,09h,0Fh; C72F
	defb 00h,00h,00h,0Ah,81h,0C0h,00h,10h,00h,40h,38h,40h,1Ah,10h,00h,47h; C73F
	defb 0C1h,40h,50h,00h,00h,00h,10h,00h,77h,0F9h,00h,00h,01h,00h,0Ah,09h; C74F
	defb 01h,0Dh,01h,11h,01h,03h,09h,07h,0Bh,03h,0Fh,1Fh,09h,23h,09h,23h; C75F
	defb 05h,23h,01h,00h,03h,25h,13h,23h,13h,21h,13h,02h,07h,08h,08h,08h; C76F
	defb 03h,05h,25h,15h,00h,10h,00h,00h,18h,80h,00h,1Ah,80h,18h,10h,20h; C77F
	defb 24h,01h,40h,24h,0FCh,00h,18h,0FCh,80h,00h,0FCh,00h,00h,0FDh,40h,00h; C78F
	defb 0FDh,00h,02h,11h,0Ah,13h,09h,01h,25h,03h,01h,25h,13h,01h,1Dh,14h; C79F
	defb 21h,01h,1Dh,15h,4Ch,38h,00h,66h,8Bh,0A0h,0Ch,22h,00h,68h,8Ah,0C0h; C7AF
	defb 02h,0D8h,00h,60h,4Ah,0C0h,3Bh,18h,40h,0A2h,63h,00h,0A8h,3Ah,40h,8Bh; C7BF
	defb 00h,0C0h,05h,21h,01h,15h,03h,11h,01h,0Dh,07h,09h,0Fh,02h,1Bh,13h; C7CF
	defb 11h,0Bh,02h,25h,13h,25h,01h,04h,04h,06h,03h,06h,0Bh,14h,17h,0Ch; C7DF
	defb 05h,05h,0Fh,13h,00h,36h,0C0h,6Dh,0B6h,0C0h,6Dh,00h,00h,00h,1Bh,60h; C7EF
	defb 0B0h,0DBh,60h,0B6h,0C0h,00h,00h,0Dh,0A0h,0DBh,6Dh,0A0h,0DBh,60h,00h,00h; C7FF
	defb 2Eh,0C0h,06h,13h,0Dh,1Bh,0Bh,1Fh,05h,0Bh,09h,05h,07h,09h,01h,02h; C80F
	defb 0Fh,07h,03h,13h,02h,13h,13h,25h,01h,06h,1Dh,12h,22h,0Ch,13h,08h; C81F
	defb 0Fh,0Eh,09h,0Eh,01h,08h,0Fh,01h,25h,15h,3Ch,00h,00h,61h,0B6h,0C0h; C82F
	defb 00h,01h,00h,60h,0FDh,80h,21h,00h,80h,61h,0FDh,80h,41h,55h,00h,68h; C83F
	defb 00h,00h,23h,0BBh,0A0h,7Eh,0EEh,0E0h,09h,09h,0Dh,09h,0Bh,09h,09h,09h; C84F
	defb 07h,09h,05h,16h,05h,16h,01h,1Ch,01h,10h,01h,01h,17h,0Fh,01h,19h; C85F
	defb 0Fh,04h,02h,14h,13h,12h,1Bh,12h,23h,12h,22h,01h,01h,15h,00h,00h; C86F
	defb 00h,1Ch,0E3h,80h,3Dh,0F7h,0C0h,3Dh,0F7h,0C0h,1Dh,0B6h,0C0h,1Dh,0B6h,0C0h; C87F
	defb 1Dh,0F7h,0C0h,1Dh,0F7h,0C0h,1Ch,0E3h,80h,00h,00h,00h,01h,05h,05h,00h; C88F
	defb 03h,07h,05h,09h,05h,09h,07h,02h,01h,14h,02h,14h,0Bh,05h,25h,15h; C89F
	defb 00h,00h,00h,0FFh,78h,00h,00h,4Fh,80h,7Fh,40h,00h,01h,40h,00h,00h; C8AF
	defb 40h,00h,0FCh,78h,80h,07h,0Fh,80h,00h,00h,00h,0FFh,0FAh,80h,07h,0Fh; C8BF
	defb 0Dh,0Dh,0Dh,0Dh,0Bh,06h,12h,15h,01h,1Bh,03h,1Dh,03h,01h,11h,05h; C8CF
	defb 02h,15h,05h,17h,05h,03h,12h,12h,13h,12h,14h,12h,03h,05h,25h,14h; C8DF
	defb 50h,81h,00h,46h,0EDh,0C0h,10h,00h,00h,0D7h,7Bh,20h,10h,11h,80h,41h; C8EF
	defb 0D4h,20h,5Fh,00h,0E0h,00h,74h,00h,0D7h,05h,0A0h,01h,5Ch,00h,05h,07h; C8FF
	defb 03h,0Dh,01h,03h,0Fh,13h,0Dh,1Dh,05h,03h,07h,13h,0Fh,09h,11h,05h; C90F
	defb 02h,21h,01h,25h,13h,05h,02h,06h,04h,0Ah,07h,0Ch,10h,10h,1Bh,0Eh; C91F
	defb 1Bh,01h,01h,15h,38h,00h,0C0h,03h,0B6h,00h,72h,83h,0C0h,1Ah,0E0h,00h; C92F
	defb 40h,07h,60h,77h,70h,40h,00h,47h,40h,5Dh,52h,40h,51h,18h,00h,04h; C93F
	defb 49h,0A0h,04h,1Dh,07h,15h,01h,07h,03h,0Fh,0Dh,02h,09h,0Dh,0Dh,09h; C94F
	defb 02h,25h,01h,25h,0Bh,04h,16h,06h,14h,06h,06h,04h,04h,04h,1Dh,01h; C95F
	defb 17h,0Bh,00h,00h,00h,57h,0BDh,40h,00h,00h,00h,76h,0ADh,0C0h,00h,00h; C96F
	defb 00h,56h,0EDh,40h,56h,0EDh,40h,00h,00h,00h,77h,0BDh,0C0h,00h,00h,00h; C97F
	defb 05h,07h,05h,15h,09h,1Bh,09h,19h,05h,17h,01h,02h,13h,0Fh,13h,13h; C98F
	defb 02h,25h,13h,25h,01h,00h,0Fh,01h,1Bh,07h,00h,00h,40h,70h,0CDh,40h; C99F
	defb 16h,05h,00h,0D0h,0E4h,40h,06h,01h,40h,62h,37h,00h,03h,80h,40h,70h; C9AF
	defb 30h,0C0h,03h,0E0h,00h,40h,04h,0C0h,06h,03h,01h,03h,0Dh,13h,01h,15h; C9BF
	defb 05h,1Fh,01h,23h,0Bh,02h,1Dh,11h,17h,0Dh,01h,25h,01h,02h,04h,06h; C9CF
	defb 02h,06h,0Dh,07h,13h,11h,00h,00h,00h,60h,0A0h,0C0h,6Dh,0B6h,0C0h,00h; C9DF
	defb 00h,00h,6Ah,0AAh,0C0h,6Ah,0AAh,0C0h,00h,00h,00h,6Dh,0B6h,0C0h,60h,0A0h; C9EF
	defb 0C0h,00h,00h,00h,06h,21h,07h,19h,07h,1Bh,03h,0Bh,03h,0Dh,07h,05h; C9FF
	defb 07h,04h,13h,01h,13h,07h,13h,0Dh,13h,13h,02h,25h,13h,25h,0Dh,04h; CA0F
	defb 09h,14h,0Bh,14h,1Ch,14h,1Eh,14h,23h,13h,03h,15h,00h,00h,00h,6Dh; CA1F
	defb 77h,40h,00h,00h,00h,40h,1Ch,0C0h,6Eh,0C0h,00h,01h,00h,20h,60h,79h; CA2F
	defb 00h,40h,02h,0C0h,54h,06h,00h,14h,20h,00h,08h,0Bh,0Fh,05h,0Bh,09h; CA3F
	defb 07h,13h,01h,15h,09h,15h,0Bh,15h,11h,11h,13h,01h,11h,0Fh,03h,0Dh; CA4F
	defb 13h,17h,13h,25h,13h,04h,04h,02h,06h,02h,0Ah,02h,0Ch,02h,1Dh,01h; CA5F
	defb 25h,15h,00h,00h,00h,09h,22h,00h,12h,11h,00h,00h,00h,00h,1Fh,88h; CA6F
	defb 80h,00h,0FFh,80h,0F0h,80h,00h,10h,03h,0E0h,00h,00h,00h,7Dh,9Fh,0C0h; CA7F
	defb 04h,09h,01h,0Fh,01h,15h,01h,1Dh,01h,00h,02h,25h,13h,25h,11h,06h; CA8F
	defb 01h,0Ch,02h,0Ch,03h,0Ch,04h,0Ch,05h,0Ch,06h,0Ch,07h,07h,1Bh,13h; CA9F
	defb 00h,40h,00h,10h,01h,00h,38h,43h,80h,6Ch,06h,0C0h,00h,40h,00h,10h; CAAF
	defb 03h,80h,01h,50h,00h,10h,0E1h,00h,00h,40h,00h,10h,01h,00h,05h,13h; CABF
	defb 03h,07h,09h,1Fh,09h,1Fh,07h,1Fh,0Dh,01h,13h,0Bh,02h,23h,13h,25h; CACF
	defb 13h,04h,1Fh,02h,20h,02h,07h,02h,08h,02h,07h,07h,13h,15h,45h,04h; CADF
	defb 00h,11h,55h,40h,45h,04h,00h,11h,55h,40h,44h,00h,00h,11h,0FFh,80h; CAEF
	defb 45h,04h,00h,11h,55h,40h,45h,55h,40h,11h,00h,00h,07h,24h,0Dh,1Bh; CAFF
	defb 13h,1Bh,09h,0Bh,0Fh,07h,11h,03h,0Bh,07h,09h,00h,04h,1Dh,13h,11h; CB0F
	defb 13h,19h,01h,25h,01h,03h,18h,02h,24h,02h,25h,14h,0Fh,09h,11h,15h; CB1F
	defb 01h,0E0h,00h,06h,18h,00h,08h,04h,00h,13h,32h,00h,10h,02h,00h,10h; CB2F
	defb 0C2h,00h,08h,04h,00h,26h,18h,80h,71h,21h,0C0h,60h,00h,0C0h,06h,0Fh; CB3F
	defb 05h,07h,08h,07h,0Ah,1Dh,0Ah,1Dh,08h,12h,09h,02h,16h,09h,0Eh,09h; CB4F
	defb 02h,10h,0Bh,14h,0Bh,07h,13h,0Eh,09h,0Ch,1Ch,0Ch,25h,14h,26h,14h; CB5F
	defb 02h,14h,01h,14h,15h,05h,13h,0Fh,00h,01h,00h,1Fh,0C0h,40h,0F0h,40h; CB6F
	defb 0C0h,10h,7Fh,0C0h,40h,00h,00h,7Fh,0E3h,0E0h,40h,23h,0E0h,40h,3Fh,0E0h; CB7F
	defb 40h,23h,0E0h,00h,00h,00h,03h,05h,09h,13h,13h,21h,03h,00h,05h,15h; CB8F
	defb 13h,17h,13h,19h,13h,05h,07h,21h,01h,08h,07h,0Ah,05h,04h,04h,14h; CB9F
	defb 05h,14h,06h,14h,13h,0Ah,13h,02h,1Ah,0Eh,23h,13h,25h,15h,55h,55h; CBAF
	defb 40h,00h,00h,00h,0AAh,0AAh,0A0h,00h,00h,00h,55h,55h,40h,00h,00h,00h; CBBF
	defb 0AAh,0AAh,0A0h,00h,00h,00h,55h,55h,40h,00h,00h,00h,00h,00h,03h,23h; CBCF
	defb 13h,1Fh,13h,1Bh,13h,07h,22h,0Ch,16h,04h,0Ch,08h,13h,10h,07h,14h; CBDF
	defb 04h,08h,09h,04h,0Dh,03h,25h,15h,00h,00h,00h,0Eh,1Fh,0C0h,0Ah,12h; CBEF
	defb 40h,0Eh,12h,40h,00h,1Fh,0C0h,3Bh,92h,40h,2Ah,92h,40h,3Bh,9Fh,0C0h; CBFF
	defb 00h,00h,00h,35h,55h,40h,0Ah,09h,01h,0Dh,01h,05h,09h,11h,09h,17h; CC0F
	defb 0Dh,1Dh,0Dh,1Dh,0Bh,1Dh,09h,1Dh,07h,23h,0Dh,00h,04h,1Bh,0Bh,1Fh; CC1F
	defb 0Bh,1Fh,07h,1Bh,07h,06h,03h,14h,04h,14h,11h,14h,12h,14h,22h,0Eh; CC2F
	defb 1Ch,0Eh,23h,01h,01h,15h,68h,28h,40h,03h,0Bh,40h,0EBh,60h,00h,00h; CC3F
	defb 06h,0A0h,6Bh,0B4h,80h,0Ah,01h,0C0h,0E0h,0ECh,00h,0Ah,00h,0C0h,63h,0B6h; CC4F
	defb 80h,28h,00h,00h,04h,09h,07h,15h,07h,1Bh,0Fh,1Fh,01h,03h,0Fh,13h; CC5F
	defb 13h,0Bh,0Fh,07h,02h,03h,13h,25h,13h,05h,04h,0Ch,06h,0Ch,06h,04h; CC6F
	defb 14h,04h,0Eh,0Eh,0Fh,01h,1Dh,15h,00h,00h,00h,0FEh,0Eh,80h,09h,0D8h; CC7F
	defb 80h,22h,8Ah,80h,50h,08h,40h,05h,25h,40h,52h,48h,40h,25h,2Ah,80h; CC8F
	defb 50h,48h,40h,05h,0Fh,40h,01h,11h,03h,00h,03h,25h,09h,25h,0Bh,25h; CC9F
	defb 0Dh,04h,03h,02h,04h,02h,05h,02h,06h,02h,1Dh,05h,21h,15h,03h,40h; CCAF
	defb 00h,78h,1Dh,0A0h,03h,90h,20h,52h,07h,60h,76h,0E0h,00h,00h,23h,80h; CCBF
	defb 0DBh,0A8h,00h,80h,0Eh,00h,0B7h,63h,80h,82h,40h,00h,05h,07h,01h,0Fh; CCCF
	defb 03h,13h,07h,21h,0Fh,19h,01h,02h,0Dh,0Fh,0Dh,0Bh,03h,15h,13h,25h; CCDF
	defb 11h,25h,01h,05h,05h,02h,06h,02h,03h,06h,07h,06h,0Ch,08h,1Bh,05h; CCEF
	defb 21h,11h,18h,0Fh,0E0h,11h,0E0h,00h,03h,0F1h,80h,07h,0F8h,80h,0CFh,0FCh; CCFF
	defb 00h,0CFh,0FCh,00h,80h,0C0h,60h,81h,0E0h,00h,83h,0E3h,00h,83h,0CFh,80h; CD0F
	defb 08h,03h,07h,23h,0Bh,16h,01h,11h,03h,0Fh,05h,0Bh,07h,09h,09h,0Dh; CD1F
	defb 05h,03h,11h,0Dh,0Bh,11h,0Bh,13h,02h,13h,0Dh,25h,13h,07h,01h,08h; CD2F
	defb 02h,08h,26h,0Ch,25h,0Ch,0Dh,04h,0Bh,06h,09h,08h,0Fh,03h,0Dh,11h; CD3F
	defb 00h,00h,00h,00h,00h,00h,41h,10h,40h,22h,08h,80h,14h,45h,00h,08h; CD4F
	defb 0E2h,00h,14h,45h,00h,22h,08h,80h,41h,10h,40h,00h,00h,00h,05h,13h; CD5F
	defb 07h,13h,05h,17h,03h,23h,03h,03h,03h,00h,03h,23h,13h,17h,13h,0Fh; CD6F
	defb 13h,00h,0Fh,03h,19h,0Fh,00h,00h,00h,77h,0FBh,0A0h,00h,00h,00h,0D9h; CD7F
	defb 0CEh,0E0h,00h,10h,00h,0B8h,07h,0C0h,02h,20h,00h,7Bh,0BBh,60h,00h,00h; CD8F
	defb 00h,0FFh,0BFh,0E0h,05h,03h,05h,1Dh,01h,13h,05h,23h,09h,03h,0Dh,02h; CD9F
	defb 13h,12h,23h,01h,01h,23h,11h,02h,09h,06h,0Ah,06h,13h,01h,13h,14h; CDAF
	defb 00h,3Fh,0E0h,00h,00h,00h,51h,00h,00h,4Bh,0F7h,40h,49h,10h,40h,45h; CDBF
	defb 17h,40h,45h,70h,40h,45h,00h,40h,45h,77h,0C0h,00h,00h,00h,08h,0Ch; CDCF
	defb 05h,07h,03h,0Ch,03h,18h,05h,1Dh,05h,03h,03h,24h,05h,22h,06h,02h; CDDF
	defb 15h,09h,15h,13h,01h,01h,13h,06h,0Bh,0Ah,0Ch,0Ah,1Bh,07h,1Ch,07h; CDEF
	defb 13h,0Ch,15h,0Ch,07h,01h,1Bh,11h,00h,00h,00h,7Eh,0EEh,00h,00h,00h; CDFF
	defb 00h,6Ch,77h,00h,00h,00h,00h,78h,3Bh,80h,00h,00h,00h,70h,1Dh,0C0h; CE0F
	defb 00h,00h,00h,60h,4Fh,0E0h,08h,15h,01h,19h,01h,17h,05h,1Dh,05h,15h; CE1F
	defb 09h,1Fh,0Dh,07h,0Dh,03h,09h,03h,0Dh,13h,1Fh,11h,25h,01h,01h,1Bh; CE2F
	defb 01h,04h,21h,0Ah,05h,0Eh,09h,06h,04h,02h,0Dh,01h,0Bh,07h,00h,00h; CE3F
	defb 00h,00h,00h,00h,07h,1Ch,00h,00h,0A0h,00h,10h,41h,00h,00h,00h,00h; CE4F
	defb 08h,02h,00h,04h,04h,00h,02h,08h,00h,01h,0F0h,00h,0Ah,08h,0Bh,08h; CE5F
	defb 07h,09h,05h,0Fh,01h,17h,03h,1Bh,03h,1Dh,05h,1Eh,07h,1Eh,0Bh,17h; CE6F
	defb 11h,00h,02h,13h,0Bh,25h,0Bh,00h,0Fh,03h,13h,12h,00h,00h,00h,00h; CE7F
	defb 00h,00h,65h,0FDh,0C0h,00h,00h,40h,71h,0FDh,0C0h,00h,00h,40h,74h,0FEh; CE8F
	defb 40h,04h,00h,00h,75h,0BFh,0C0h,05h,00h,00h,06h,0Eh,0Fh,0Dh,0Dh,0Ch; CE9F
	defb 0Bh,0Bh,09h,0Ah,07h,03h,07h,02h,18h,0Fh,18h,13h,02h,01h,13h,21h; CEAF
	defb 07h,06h,03h,04h,04h,04h,05h,04h,06h,04h,0Bh,04h,0Ch,04h,09h,05h; CEBF
	defb 25h,15h,00h,00h,00h,7Fh,0FEh,00h,40h,00h,00h,7Fh,0FEh,00h,40h,00h; CECF
	defb 40h,5Fh,0FEh,00h,40h,00h,20h,40h,00h,0C0h,40h,00h,00h,00h,00h,00h; CEDF
	defb 07h,23h,07h,1Dh,05h,13h,0Dh,13h,0Bh,13h,09h,13h,05h,13h,03h,00h; CEEF
	defb 02h,01h,13h,05h,13h,05h,05h,06h,06h,06h,25h,0Ch,26h,0Ch,26h,14h; CEFF
	defb 03h,01h,13h,0Fh,00h,00h,00h,6Bh,1Ah,0C0h,22h,08h,80h,08h,02h,00h; CF0F
	defb 1Ch,47h,00h,08h,0E2h,00h,00h,40h,00h,01h,10h,00h,03h,58h,00h,00h; CF1F
	defb 00h,00h,05h,13h,0Fh,13h,07h,1Dh,05h,09h,05h,0Dh,01h,02h,09h,0Dh; CF2F
	defb 1Dh,0Dh,03h,25h,01h,25h,13h,01h,13h,03h,0Ah,02h,06h,02h,04h,02h; CF3F
	defb 19h,01h,0Dh,11h,04h,00h,00h,24h,82h,0C0h,31h,80h,00h,1Bh,01h,80h; CF4F
	defb 40h,10h,00h,6Ch,01h,40h,08h,00h,80h,5Ah,81h,40h,0C2h,0D4h,00h,06h; CF5F
	defb 00h,00h,06h,18h,07h,19h,05h,1Ah,03h,1Bh,01h,21h,05h,09h,09h,01h; CF6F
	defb 1Dh,01h,03h,25h,01h,25h,09h,25h,13h,05h,06h,0Ah,04h,0Eh,12h,02h; CF7F
	defb 18h,10h,1Eh,14h,19h,01h,11h,0Fh,00h,09h,0E0h,00h,09h,0E0h,00h,08h; CF8F
	defb 0E0h,00h,08h,0E0h,00h,08h,60h,00h,08h,60h,00h,08h,20h,00h,08h,20h; CF9F
	defb 00h,08h,00h,00h,00h,00h,09h,25h,13h,24h,11h,23h,0Fh,22h,0Dh,21h; CFAF
	defb 0Bh,20h,09h,1Fh,07h,1Eh,05h,1Dh,03h,07h,0Ch,13h,0Ch,11h,0Ch,0Fh; CFBF
	defb 0Ch,0Dh,0Ch,0Bh,0Ch,09h,0Ch,07h,00h,00h,1Ch,01h,1Ch,15h,00h,00h; CFCF
	defb 00h,30h,41h,80h,00h,00h,00h,6Ch,06h,0C0h,00h,00h,00h,1Bh,1Bh,00h; CFDF
	defb 00h,00h,00h,06h,0ECh,00h,00h,00h,00h,01h,0B0h,00h,07h,0Fh,09h,13h; CFEF
	defb 01h,1Fh,09h,19h,0Dh,07h,01h,0Bh,05h,23h,05h,01h,13h,0Dh,02h,21h; CFFF
	defb 13h,25h,13h,04h,08h,0Ah,06h,02h,05h,02h,0Ah,06h,03h,05h,1Fh,0Bh; D00F
	defb 00h,00h,00h,0F7h,0BDh,0E0h,10h,01h,00h,0F7h,0BDh,0E0h,00h,00h,00h,0F7h; D01F
	defb 0FDh,0C0h,00h,00h,00h,1Fh,0BFh,00h,2Ah,0AAh,80h,55h,55h,40h,07h,13h; D02F
	defb 09h,13h,07h,0Bh,01h,09h,0Bh,09h,0Dh,1Dh,0Dh,1Dh,0Bh,01h,13h,05h; D03F
	defb 04h,13h,11h,13h,0Fh,03h,05h,23h,05h,03h,08h,02h,07h,02h,06h,02h; D04F
	defb 1Bh,01h,13h,13h,00h,00h,0A0h,00h,00h,00h,7Dh,93h,0C0h,04h,12h,40h; D05F
	defb 05h,94h,40h,7Ch,11h,40h,04h,10h,0C0h,04h,00h,40h,7Dh,0E7h,80h,00h; D06F
	defb 18h,00h,06h,17h,0Dh,16h,0Fh,0Bh,0Dh,0Bh,09h,1Fh,09h,23h,09h,02h; D07F
	defb 21h,13h,11h,07h,02h,23h,0Fh,22h,11h,05h,0Ah,04h,09h,04h,08h,04h; D08F
	defb 07h,04h,06h,04h,17h,03h,23h,15h,00h,00h,00h,55h,55h,0E0h,00h,75h; D09F
	defb 00h,2Ah,41h,00h,00h,5Fh,0C0h,55h,55h,40h,00h,55h,40h,2Ah,55h,40h; D0AF
	defb 00h,55h,40h,55h,40h,00h,01h,03h,01h,00h,04h,23h,13h,1Fh,13h,1Bh; D0BF
	defb 13h,17h,13h,06h,12h,14h,0Eh,14h,0Ah,14h,06h,14h,26h,02h,25h,02h; D0CF
	defb 23h,07h,25h,15h,00h,00h,00h,6Dh,0B6h,0C0h,00h,00h,00h,1Bh,1Bh,00h; D0DF
	defb 00h,00h,00h,36h,0Dh,80h,02h,08h,00h,6Dh,12h,0C0h,00h,00h,00h,18h; D0EF
	defb 03h,00h,0Ch,13h,13h,0Fh,05h,11h,01h,0Bh,01h,05h,01h,09h,05h,15h; D0FF
	defb 01h,17h,05h,19h,09h,1Dh,05h,1Bh,01h,21h,01h,01h,13h,11h,01h,25h; D10F
	defb 13h,02h,0Ah,0Eh,04h,0Eh,0Dh,09h,19h,0Bh,20h,00h,80h,40h,00h,40h; D11F
	defb 4Fh,0FEh,40h,40h,00h,40h,4Eh,0EFh,40h,0Fh,0E0h,00h,00h,00h,00h,00h; D12F
	defb 03h,80h,00h,0F4h,00h,38h,08h,00h,07h,0Bh,07h,1Dh,07h,14h,0Fh,21h; D13F
	defb 0Dh,1Dh,0Dh,0Bh,03h,14h,07h,01h,14h,03h,02h,23h,01h,25h,01h,05h; D14F
	defb 10h,0Ah,0Fh,0Ah,08h,12h,07h,12h,20h,08h,1Dh,03h,09h,11h,3Fh,0FFh; D15F
	defb 0E0h,06h,00h,00h,14h,0Dh,00h,10h,0Dh,00h,14h,09h,00h,14h,08h,00h; D16F
	defb 14h,0Dh,00h,00h,00h,00h,0FFh,83h,0C0h,00h,00h,00h,08h,08h,07h,09h; D17F
	defb 0Fh,0Bh,0Fh,1Ch,0Fh,1Eh,0Fh,1Ch,0Bh,1Fh,13h,21h,13h,03h,1Dh,01h; D18F
	defb 1Fh,02h,09h,02h,03h,09h,0Bh,1Ah,0Bh,1Dh,0Dh,02h,01h,10h,0Ah,0Eh; D19F
	defb 1Dh,13h,01h,15h,00h,00h,00h,07h,0Ch,40h,20h,04h,00h,20h,14h,0C0h; D1AF
	defb 27h,14h,80h,00h,15h,00h,0FFh,80h,20h,00h,0Fh,40h,00h,00h,00h,15h; D1BF
	defb 15h,40h,06h,0Fh,01h,05h,03h,23h,01h,23h,05h,1Bh,01h,0Fh,07h,03h; D1CF
	defb 13h,0Bh,13h,09h,13h,07h,01h,25h,13h,08h,01h,0Ch,02h,0Ch,03h,0Ch; D1DF
	defb 04h,0Ch,05h,0Ch,0Ch,02h,0Bh,02h,25h,12h,0Bh,07h,01h,15h,00h,00h; D1EF
	defb 00h,00h,00h,00h,0FEh,4Fh,0E0h,00h,00h,00h,7Bh,0A0h,00h,02h,27h,0E0h; D1FF
	defb 00h,20h,00h,00h,2Bh,0E0h,0FFh,0E0h,00h,00h,08h,00h,08h,19h,11h,23h; D20F
	defb 09h,0Dh,03h,09h,03h,05h,03h,0Dh,07h,1Eh,03h,1Ah,03h,01h,23h,07h; D21F
	defb 01h,01h,0Fh,04h,24h,04h,25h,04h,02h,04h,03h,04h,22h,03h,25h,15h; D22F
	defb 77h,78h,00h,00h,08h,00h,0EDh,0D8h,00h,00h,08h,00h,0BFh,0B8h,00h,00h; D23F
	defb 08h,00h,0DDh,0F8h,00h,00h,08h,00h,7Bh,0DCh,00h,00h,00h,00h,00h,05h; D24F
	defb 0Bh,13h,0Bh,0Fh,0Bh,0Bh,0Bh,07h,0Bh,03h,01h,25h,01h,00h,23h,13h; D25F
	defb 25h,15h,60h,04h,00h,02h,01h,20h,02h,31h,00h,30h,01h,40h,01h,85h; D26F
	defb 00h,40h,01h,40h,46h,00h,00h,10h,71h,0E0h,10h,35h,00h,04h,80h,00h; D27F
	defb 05h,15h,0Dh,24h,0Dh,05h,05h,15h,01h,15h,03h,01h,23h,03h,02h,25h; D28F
	defb 13h,23h,13h,04h,03h,0Ah,1Ch,08h,12h,12h,0Eh,02h,22h,0Dh,0Dh,15h; D29F
	defb 1Fh,0FFh,00h,00h,00h,00h,0FFh,3Fh,0E0h,40h,00h,00h,7Fh,0FCh,0C0h,00h; D2AF
	defb 00h,40h,5Fh,7Ch,40h,50h,03h,40h,57h,0E8h,0C0h,00h,0Ch,00h,05h,05h; D2BF
	defb 13h,05h,11h,15h,03h,19h,0Fh,0Fh,03h,02h,1Dh,09h,1Dh,11h,01h,1Dh; D2CF
	defb 07h,03h,1Dh,0Eh,1Eh,0Eh,1Fh,0Eh,0Fh,0Bh,05h,15h,00h,00h,00h,00h; D2DF
	defb 00h,00h,1Fh,8Fh,00h,0F0h,00h,00h,1Fh,9Ah,00h,00h,04h,00h,0FFh,0E0h; D2EF
	defb 00h,00h,0Dh,80h,0EEh,0E5h,00h,00h,07h,00h,08h,17h,08h,15h,0Bh,1Dh; D2FF
	defb 07h,19h,03h,1Ch,03h,1Fh,03h,15h,0Fh,0Dh,0Fh,01h,07h,0Bh,02h,07h; D30F
	defb 13h,07h,0Fh,05h,1Bh,04h,19h,02h,1Ah,02h,1Ch,02h,1Dh,02h,11h,03h; D31F
	defb 1Dh,13h,04h,00h,0C0h,55h,0B2h,40h,10h,07h,00h,15h,0C2h,80h,55h,10h; D32F
	defb 20h,50h,33h,80h,53h,08h,00h,56h,6Bh,40h,50h,22h,40h,19h,00h,00h; D33F
	defb 06h,03h,01h,1Dh,01h,1Fh,07h,1Fh,09h,17h,07h,15h,01h,00h,01h,05h; D34F
	defb 11h,04h,25h,08h,26h,08h,04h,08h,03h,08h,0Fh,01h,0Bh,15h,00h,00h; D35F
	defb 00h,7Fh,0FFh,0C0h,40h,00h,00h,4Eh,0F7h,0E0h,60h,00h,00h,5Dh,0DEh,0E0h; D36F
	defb 40h,00h,00h,61h,0DDh,0A0h,4Eh,00h,00h,00h,0FEh,0E0h,03h,17h,0Dh,15h; D37F
	defb 05h,09h,09h,02h,25h,09h,05h,07h,01h,05h,0Bh,05h,01h,14h,02h,14h; D38F
	defb 05h,0Ah,05h,09h,04h,05h,1Bh,09h,01h,15h,00h,00h,00h,02h,0A8h,00h; D39F
	defb 00h,00h,00h,00h,00h,00h,0Ah,0AAh,00h,00h,00h,00h,0EAh,0AAh,0E0h,00h; D3AF
	defb 00h,00h,00h,00h,00h,0FFh,0BBh,40h,04h,15h,01h,19h,01h,1Eh,0Bh,08h; D3BF
	defb 0Bh,00h,0Ah,1Ch,0Bh,1Ah,0Bh,18h,0Bh,16h,0Bh,14h,0Bh,12h,0Bh,10h; D3CF
	defb 0Bh,0Eh,0Bh,0Ch,0Bh,0Ah,0Bh,02h,0Dh,02h,0Eh,02h,11h,01h,25h,15h; D3DF
	defb 00h,40h,00h,53h,19h,40h,22h,48h,80h,53h,19h,40h,00h,40h,00h,00h; D3EF
	defb 02h,00h,6Bh,1Ah,0C0h,48h,02h,40h,6Bh,1Ah,0C0h,08h,02h,00h,06h,13h; D3FF
	defb 03h,09h,0Bh,09h,0Dh,0Fh,0Fh,17h,0Fh,23h,0Fh,01h,13h,0Bh,02h,1Dh; D40F
	defb 0Dh,1Dh,11h,05h,0Eh,0Ch,06h,14h,0Fh,02h,20h,02h,24h,0Ch,13h,07h; D41F
	defb 01h,15h,48h,0A4h,00h,02h,0A4h,0E0h,7Eh,0A4h,00h,48h,24h,0E0h,02h,0E4h; D42F
	defb 00h,7Eh,0F4h,0E0h,48h,04h,00h,02h,0FCh,0E0h,7Eh,0FEh,00h,00h,00h,0E0h; D43F
	defb 03h,03h,09h,03h,0Fh,03h,03h,00h,03h,13h,01h,17h,01h,1Dh,01h,04h; D44F
	defb 23h,06h,24h,06h,25h,06h,26h,06h,21h,01h,25h,03h,6Dh,0B6h,0C0h,00h; D45F
	defb 00h,00h,6Dh,0B6h,0C0h,00h,00h,00h,6Dh,0B6h,0C0h,00h,00h,00h,6Dh,0B6h; D46F
	defb 0C0h,00h,00h,00h,6Dh,0B6h,0C0h,6Dh,0B6h,0C0h,06h,0Ch,03h,12h,07h,18h; D47F
	defb 0Bh,1Eh,0Fh,1Dh,03h,05h,07h,02h,13h,0Bh,13h,0Fh,02h,25h,01h,25h; D48F
	defb 13h,06h,12h,0Ch,10h,0Ch,0Ch,08h,0Ah,08h,06h,04h,04h,04h,0Dh,01h; D49F
	defb 25h,15h,00h,00h,40h,00h,80h,00h,64h,33h,00h,88h,20h,40h,01h,03h; D4AF
	defb 0C0h,30h,0B8h,00h,04h,01h,40h,61h,48h,40h,10h,85h,00h,42h,10h,00h; D4BF
	defb 06h,0Fh,07h,0Bh,03h,1Dh,01h,1Fh,01h,1Fh,0Bh,19h,09h,03h,15h,0Dh; D4CF
	defb 09h,09h,05h,01h,02h,23h,13h,25h,13h,04h,03h,04h,04h,04h,11h,02h; D4DF
	defb 12h,02h,1Eh,03h,0Fh,15h,00h,00h,00h,55h,0B5h,40h,54h,05h,40h,55h; D4EF
	defb 0B5h,40h,00h,00h,00h,00h,00h,00h,6Dh,56h,0C0h,01h,50h,00h,6Dh,56h; D4FF
	defb 0C0h,00h,00h,00h,08h,03h,01h,07h,01h,0Bh,01h,13h,0Bh,0Fh,0Bh,17h; D50F
	defb 0Bh,1Bh,01h,1Fh,01h,02h,19h,09h,0Dh,09h,02h,0Dh,13h,19h,13h,08h; D51F
	defb 03h,0Ch,04h,0Ch,05h,0Ch,06h,0Ch,24h,0Ch,23h,0Ch,22h,0Ch,21h,0Ch; D52F
	defb 23h,01h,03h,11h,00h,00h,00h,1Dh,0F3h,80h,3Dh,0F7h,0C0h,1Dh,86h,0C0h; D53F
	defb 1Dh,0E6h,0C0h,1Dh,0F6h,0C0h,1Ch,36h,0C0h,1Dh,0F7h,0C0h,1Dh,0E3h,80h,00h; D54F
	defb 00h,00h,07h,15h,0Dh,1Dh,03h,1Fh,03h,21h,03h,0Bh,03h,07h,03h,0Bh; D55F
	defb 0Dh,02h,09h,03h,09h,0Dh,02h,17h,0Dh,1Fh,0Fh,00h,07h,0Dh,17h,0Fh; D56F
	defb 00h,00h,00h,15h,55h,60h,15h,54h,00h,1Fh,0FFh,40h,00h,00h,00h,00h; D57F
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,04h,1Dh; D58F
	defb 13h,1Dh,11h,22h,05h,20h,05h,00h,04h,25h,13h,23h,13h,21h,13h,1Fh; D59F
	defb 13h,06h,1Bh,02h,17h,02h,13h,02h,0Fh,02h,0Bh,02h,07h,02h,1Dh,0Fh; D5AF
	defb 25h,11h,00h,00h,00h,03h,0F1h,80h,60h,06h,00h,0Ch,67h,40h,00h,01h; D5BF
	defb 40h,21h,0F6h,40h,06h,00h,00h,00h,1Fh,80h,69h,0C0h,00h,00h,00h,00h; D5CF
	defb 07h,05h,03h,17h,01h,0Dh,01h,19h,05h,1Bh,09h,1Ah,07h,21h,01h,00h; D5DF
	defb 02h,25h,13h,25h,01h,02h,06h,0Ah,05h,0Ah,0Bh,05h,0Bh,14h,00h,00h; D5EF
	defb 00h,0EFh,0DDh,0E0h,00h,00h,00h,6Fh,80h,00h,00h,0FEh,0E0h,0EEh,00h,00h; D5FF
	defb 0E0h,1Eh,0E0h,0CFh,0C0h,00h,80h,00h,00h,3Eh,1Fh,0E0h,05h,13h,07h,15h; D60F
	defb 07h,13h,02h,0Bh,05h,09h,05h,01h,25h,05h,02h,25h,11h,25h,0Fh,08h; D61F
	defb 11h,14h,12h,14h,13h,14h,14h,14h,15h,14h,16h,14h,05h,02h,06h,02h; D62F
	defb 09h,01h,14h,13h,00h,00h,00h,00h,0Eh,0C0h,3Fh,82h,80h,00h,0F0h,00h; D63F
	defb 0C4h,02h,80h,20h,0E0h,00h,08h,0Ah,00h,42h,0Eh,0C0h,01h,0A0h,00h,28h; D64F
	defb 30h,00h,07h,03h,0Dh,09h,0Bh,0Bh,07h,1Dh,01h,21h,01h,21h,07h,1Dh; D65F
	defb 07h,00h,03h,25h,13h,25h,11h,25h,0Fh,05h,07h,04h,08h,04h,09h,04h; D66F
	defb 0Ah,04h,0Bh,04h,05h,03h,03h,15h,3Eh,98h,00h,08h,91h,80h,48h,90h; D67F
	defb 00h,48h,91h,80h,5Dh,10h,00h,49h,11h,80h,49h,10h,00h,5Ch,88h,0C0h; D68F
	defb 48h,89h,00h,4Bh,0A9h,00h,0Ch,19h,0Fh,14h,11h,13h,0Fh,0Fh,0Bh,09h; D69F
	defb 0Bh,09h,0Dh,11h,03h,17h,03h,21h,01h,21h,05h,21h,09h,21h,0Dh,00h; D6AF
	defb 03h,25h,06h,1Fh,06h,15h,06h,00h,09h,07h,1Fh,11h,00h,00h,00h,00h; D6BF
	defb 00h,00h,0FCh,01h,0E0h,15h,05h,00h,44h,89h,00h,10h,50h,40h,44h,51h; D6CF
	defb 00h,11h,04h,40h,44h,01h,00h,00h,50h,00h,0Bh,14h,11h,16h,11h,15h; D6DF
	defb 0Fh,15h,0Dh,15h,0Bh,0Fh,05h,0Bh,03h,07h,03h,03h,03h,1Bh,05h,1Fh; D6EF
	defb 03h,00h,01h,25h,13h,02h,15h,14h,16h,14h,23h,03h,01h,15h,08h,08h; D6FF
	defb 40h,03h,0B8h,40h,0B1h,11h,00h,04h,44h,00h,31h,71h,0C0h,00h,01h,0C0h; D70F
	defb 6Dh,18h,00h,00h,00h,00h,2Ch,6Ch,80h,21h,00h,80h,0Bh,05h,03h,07h; D71F
	defb 07h,05h,0Bh,05h,0Fh,0Eh,11h,12h,0Fh,11h,0Dh,12h,0Bh,13h,05h,14h; D72F
	defb 01h,1Fh,03h,01h,0Fh,07h,03h,13h,03h,17h,01h,25h,13h,01h,13h,0Eh; D73F
	defb 12h,01h,21h,11h,00h,00h,00h,50h,82h,40h,56h,0DAh,0C0h,02h,00h,80h; D74F
	defb 02h,0ECh,00h,50h,00h,80h,57h,03h,80h,50h,18h,00h,54h,01h,0C0h,05h; D75F
	defb 44h,00h,04h,1Bh,07h,17h,03h,07h,09h,03h,01h,01h,05h,13h,02h,09h; D76F
	defb 0Bh,05h,11h,06h,04h,0Ah,03h,0Ah,01h,14h,02h,14h,10h,0Ch,0Fh,0Ch; D77F
	defb 17h,01h,0Dh,15h,00h,00h,00h,00h,20h,00h,00h,10h,00h,00h,80h,00h; D78F
	defb 00h,04h,00h,02h,00h,00h,00h,01h,00h,88h,00h,00h,50h,00h,40h,2Ah; D79F
	defb 95h,20h,07h,0Ah,0Dh,0Eh,09h,12h,05h,15h,01h,1Ah,07h,1Eh,0Bh,22h; D7AF
	defb 0Fh,01h,0Bh,11h,03h,25h,11h,25h,0Fh,25h,0Dh,05h,09h,12h,0Ah,12h; D7BF
	defb 05h,12h,03h,10h,01h,0Eh,1Fh,11h,09h,13h,00h,00h,00h,6Ah,0EEh,0E0h; D7CF
	defb 8Ah,0AAh,0A0h,8Ah,0AAh,0A0h,4Eh,0ECh,0E0h,2Ah,0AAh,80h,2Ah,0AAh,80h,0CAh; D7DF
	defb 0AAh,80h,00h,00h,00h,00h,08h,00h,04h,0Dh,01h,1Dh,01h,1Ah,13h,15h; D7EF
	defb 01h,02h,01h,12h,25h,11h,01h,25h,01h,05h,0Ch,08h,1Eh,03h,19h,13h; D7FF
	defb 18h,14h,17h,14h,1Ah,11h,01h,14h,18h,03h,00h,03h,0F8h,00h,0F8h,03h; D80F
	defb 0E0h,03h,0B8h,00h,00h,00h,00h,03h,18h,00h,00h,00h,00h,0FAh,0Bh,0E0h; D81F
	defb 00h,00h,00h,18h,03h,00h,04h,09h,0Dh,09h,03h,13h,01h,1Dh,0Dh,02h; D82F
	defb 1Dh,09h,09h,09h,02h,11h,0Fh,15h,0Fh,02h,15h,06h,12h,06h,1Dh,03h; D83F
	defb 13h,15h,00h,1Ch,0C0h,40h,86h,00h,31h,0E2h,40h,23h,0F0h,0C0h,47h,0F9h; D84F
	defb 0E0h,07h,0F9h,00h,63h,0F8h,40h,31h,0F8h,0C0h,11h,0F9h,0C0h,71h,0F8h,60h; D85F
	defb 0Fh,05h,03h,07h,03h,03h,0Bh,07h,0Dh,0Bh,09h,0Dh,09h,0Dh,07h,11h; D86F
	defb 03h,13h,07h,15h,07h,17h,07h,19h,09h,17h,09h,15h,09h,13h,09h,08h; D87F
	defb 0Dh,01h,0Fh,09h,0Fh,07h,11h,09h,11h,07h,10h,05h,1Fh,07h,0Ah,0Bh; D88F
	defb 00h,04h,01h,14h,02h,14h,11h,02h,12h,02h,07h,01h,1Ch,15h,00h,00h; D89F
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0EFh,0BEh,0E0h; D8AF
	defb 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Bh,13h,0Eh; D8BF
	defb 13h,10h,13h,12h,21h,13h,21h,11h,21h,0Fh,21h,0Dh,05h,0Dh,05h,0Fh; D8CF
	defb 05h,11h,05h,13h,01h,25h,09h,04h,24h,0Ah,1Ch,0Ah,0Bh,0Ah,03h,0Ah; D8DF
	defb 23h,13h,21h,15h,00h,00h,00h,00h,00h,00h,81h,0B0h,20h,41h,0B0h,40h; D8EF
	defb 20h,0E0h,80h,10h,01h,00h,08h,02h,00h,04h,04h,00h,00h,00h,00h,0F7h; D8FF
	defb 0FFh,0E0h,01h,15h,03h,00h,03h,13h,07h,12h,05h,14h,05h,02h,18h,12h; D90F
	defb 17h,12h,11h,03h,0Fh,13h,00h,00h,00h,00h,00h,00h,60h,00h,00h,0Ch; D91F
	defb 00h,00h,01h,80h,00h,00h,30h,00h,00h,04h,00h,00h,01h,00h,00h,00h; D92F
	defb 00h,0FFh,0FFh,00h,0Ah,05h,03h,09h,05h,0Bh,05h,0Fh,07h,11h,07h,15h; D93F
	defb 09h,17h,09h,1Bh,0Bh,1Fh,0Dh,1Fh,0Bh,03h,1Fh,12h,1Fh,09h,1Fh,07h; D94F
	defb 01h,21h,13h,00h,03h,03h,22h,15h,00h,08h,00h,0Eh,0C8h,00h,0E2h,01h; D95F
	defb 00h,00h,00h,40h,3Fh,0FCh,40h,00h,03h,00h,36h,0DBh,0C0h,00h,00h,00h; D96F
	defb 00h,00h,00h,0F1h,0E3h,0C0h,09h,1Fh,03h,1Fh,01h,23h,05h,23h,03h,1Fh; D97F
	defb 0Ah,18h,0Bh,12h,0Bh,0Ch,0Bh,06h,0Bh,00h,02h,25h,13h,25h,11h,00h; D98F
	defb 13h,07h,25h,15h,00h,00h,00h,00h,3Eh,00h,07h,0AAh,00h,01h,3Eh,00h; D99F
	defb 01h,2Ah,00h,03h,0BEh,00h,01h,08h,00h,01h,1Ch,00h,07h,88h,00h,00h; D9AF
	defb 3Eh,00h,07h,15h,05h,15h,09h,19h,09h,19h,05h,19h,03h,19h,0Dh,19h; D9BF
	defb 11h,00h,01h,1Dh,09h,05h,01h,14h,03h,14h,05h,14h,07h,14h,09h,14h; D9CF
	defb 1Dh,05h,1Dh,0Bh,40h,80h,00h,54h,09h,40h,52h,50h,80h,04h,58h,00h; D9DF
	defb 0E4h,08h,40h,01h,00h,80h,51h,21h,00h,22h,24h,80h,40h,00h,00h,01h; D9EF
	defb 22h,00h,07h,1Fh,01h,13h,03h,23h,07h,15h,11h,0Fh,09h,0Bh,01h,07h; D9FF
	defb 0Bh,02h,0Dh,13h,19h,0Bh,02h,1Bh,13h,25h,01h,07h,17h,04h,1Fh,0Ch; DA0F
	defb 1Eh,12h,0Dh,0Eh,07h,0Ah,02h,08h,01h,08h,19h,01h,01h,15h,00h,00h; DA1F
	defb 00h,00h,00h,00h,60h,00h,00h,94h,0A4h,00h,94h,28h,0C0h,94h,0B1h,20h; DA2F
	defb 0F5h,0A9h,20h,94h,0A5h,20h,1Eh,0A4h,0C0h,00h,00h,00h,05h,25h,13h,05h; DA3F
	defb 07h,05h,05h,0Eh,0Bh,15h,07h,02h,11h,09h,0Bh,09h,02h,25h,11h,03h; DA4F
	defb 07h,06h,1Ah,0Ch,19h,0Ch,0Dh,0Bh,0Dh,0Ch,0Ch,06h,0Bh,06h,0Bh,01h; DA5F
	defb 25h,15h,00h,00h,00h,65h,48h,0C0h,04h,24h,00h,40h,01h,40h,01h,54h; DA6F
	defb 00h,45h,46h,00h,7Dh,40h,80h,01h,4Fh,80h,39h,40h,00h,01h,43h,80h; DA7F
	defb 0Ch,1Bh,0Dh,21h,0Bh,1Fh,05h,23h,05h,21h,01h,1Bh,07h,17h,07h,19h; DA8F
	defb 01h,0Fh,01h,03h,01h,03h,05h,03h,09h,00h,02h,23h,13h,25h,13h,02h; DA9F
	defb 07h,10h,08h,10h,13h,01h,17h,15h,00h,00h,00h,0DFh,0DFh,0C0h,00h,00h; DAAF
	defb 00h,0EEh,0FCh,0E0h,00h,00h,00h,70h,54h,00h,00h,40h,00h,0DCh,57h,80h; DABF
	defb 00h,00h,00h,00h,00h,00h,08h,10h,09h,11h,0Bh,11h,0Dh,11h,0Fh,11h; DACF
	defb 11h,11h,13h,19h,05h,1Ch,09h,00h,05h,1Ah,09h,18h,09h,16h,09h,14h; DADF
	defb 09h,12h,09h,00h,0Dh,01h,0Eh,15h,00h,00h,00h,2Fh,27h,80h,00h,00h; DAEF
	defb 0A0h,00h,0Ch,20h,64h,44h,0E0h,48h,14h,00h,4Ch,95h,60h,04h,10h,00h; DAFF
	defb 30h,02h,60h,01h,5Bh,00h,07h,11h,0Bh,17h,09h,1Bh,05h,0Bh,07h,0Ch; DB0F
	defb 0Bh,0Fh,01h,15h,01h,02h,1Fh,0Fh,15h,05h,01h,25h,01h,03h,19h,06h; DB1F
	defb 06h,02h,05h,02h,21h,01h,01h,13h,00h,80h,00h,0F0h,1Fh,80h,0FFh,0B1h; DB2F
	defb 0C0h,00h,04h,40h,7Fh,0BFh,40h,10h,02h,40h,0D0h,02h,0C0h,17h,0C2h,60h; DB3F
	defb 70h,03h,00h,43h,0FFh,0C0h,03h,13h,0Dh,13h,0Bh,13h,09h,00h,03h,01h; DB4F
	defb 13h,25h,13h,25h,0Dh,04h,12h,08h,13h,08h,14h,08h,15h,08h,18h,11h; DB5F
	defb 05h,15h,00h,00h,00h,0FFh,0FFh,00h,00h,10h,60h,2Bh,45h,60h,0A1h,11h; DB6F
	defb 60h,04h,5Bh,00h,16h,0C1h,00h,0B0h,55h,0E0h,03h,10h,40h,10h,07h,00h; DB7F
	defb 04h,05h,05h,13h,09h,1Fh,05h,23h,03h,00h,06h,21h,0Bh,23h,0Bh,25h; DB8F
	defb 0Bh,25h,0Dh,23h,0Dh,21h,0Dh,06h,1Eh,12h,22h,09h,06h,02h,05h,02h; DB9F
	defb 04h,02h,03h,02h,07h,0Bh,01h,15h,00h,04h,00h,00h,04h,00h,00h,04h; DBAF
	defb 00h,00h,80h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,04h,00h; DBBF
	defb 00h,04h,00h,00h,04h,00h,00h,04h,1Bh,0Dh,1Bh,0Bh,1Bh,09h,1Bh,07h; DBCF
	defb 00h,06h,0Bh,01h,09h,03h,07h,05h,05h,07h,03h,09h,01h,0Bh,11h,05h; DBDF
	defb 15h,14h,00h,00h,00h,0FCh,65h,00h,01h,14h,0C0h,22h,02h,00h,0Ah,90h; DBEF
	defb 80h,42h,4Dh,00h,12h,41h,20h,82h,14h,20h,22h,63h,40h,0Ah,00h,00h; DBFF
	defb 05h,0Dh,05h,11h,07h,1Bh,09h,21h,07h,1Bh,01h,02h,17h,0Dh,09h,0Bh; DC0F
	defb 03h,01h,13h,03h,13h,05h,13h,06h,20h,02h,01h,0Eh,02h,0Eh,07h,0Ch; DC1F
	defb 08h,0Ch,26h,14h,09h,07h,01h,15h,00h,00h,40h,63h,0F0h,0C0h,47h,0F8h; DC2F
	defb 00h,4Fh,0FCh,00h,4Dh,0ECh,00h,5Dh,0EEh,0C0h,5Fh,0FEh,0C0h,5Fh,0FEh,0C0h; DC3F
	defb 4Fh,0FCh,00h,06h,18h,40h,0Fh,05h,01h,20h,07h,1Fh,05h,1Eh,03h,1Dh; DC4F
	defb 01h,08h,05h,0Eh,13h,0Ch,13h,0Ah,13h,16h,13h,18h,13h,1Ah,13h,12h; DC5F
	defb 0Bh,21h,09h,07h,09h,03h,21h,01h,0Dh,0Bh,17h,0Bh,03h,12h,13h,17h; DC6F
	defb 09h,0Dh,09h,08h,02h,14h,03h,02h,04h,02h,1Eh,0Ah,1Ch,06h,1Ah,04h; DC7F
	defb 14h,02h,0Ah,06h,12h,01h,01h,15h,48h,80h,80h,08h,82h,20h,4Bh,0E0h; DC8F
	defb 00h,40h,80h,40h,58h,87h,00h,00h,00h,00h,0Eh,0E3h,0A0h,09h,03h,0E0h; DC9F
	defb 78h,03h,0E0h,40h,07h,0E0h,09h,0Fh,13h,03h,0Fh,09h,07h,0Dh,03h,15h; DCAF
	defb 03h,1Dh,01h,1Fh,07h,1Bh,07h,23h,05h,01h,1Ah,13h,01h,23h,01h,01h; DCBF
	defb 03h,0Eh,03h,03h,25h,0Dh,41h,11h,40h,59h,11h,00h,40h,17h,0A0h,77h; DCCF
	defb 10h,00h,01h,0F5h,40h,00h,00h,00h,7Dh,8Dh,0A0h,02h,40h,00h,20h,37h; DCDF
	defb 0A0h,20h,00h,00h,0Bh,1Bh,03h,1Fh,07h,23h,07h,21h,13h,17h,13h,11h; DCEF
	defb 0Bh,13h,07h,13h,05h,13h,01h,09h,01h,05h,0Fh,02h,0Bh,13h,03h,0Bh; DCFF
	defb 01h,23h,03h,02h,06h,06h,21h,0Ch,13h,03h,25h,11h,02h,00h,00h,62h; DD0F
	defb 7Eh,0C0h,62h,00h,00h,0Fh,86h,0E0h,0C0h,03h,0E0h,00h,00h,00h,0Fh,11h; DD1F
	defb 0C0h,08h,50h,00h,2Fh,17h,0C0h,60h,10h,00h,08h,09h,0Bh,05h,0Fh,03h; DD2F
	defb 07h,09h,05h,13h,0Dh,23h,0Bh,1Bh,05h,1Bh,01h,00h,04h,15h,13h,13h; DD3F
	defb 13h,11h,13h,25h,13h,04h,06h,02h,11h,12h,13h,12h,15h,12h,23h,01h; DD4F
	defb 01h,14h,00h,00h,00h,00h,00h,00h,1Ch,00h,00h,06h,0C0h,00h,00h,00h; DD5F
	defb 00h,0Fh,6Ch,00h,1Bh,00h,00h,37h,0E0h,00h,6Ch,0F0h,00h,58h,00h,00h; DD6F
	defb 03h,0Bh,03h,13h,05h,12h,03h,02h,11h,0Dh,11h,09h,01h,01h,13h,06h; DD7F
	defb 0Ah,04h,09h,04h,13h,0Eh,14h,0Eh,15h,0Eh,16h,0Eh,07h,03h,1Ah,15h; DD8F
	defb 00h,00h,00h,1Fh,0FFh,00h,00h,00h,00h,00h,00h,00h,0FFh,0FFh,0E0h,0FFh; DD9F
	defb 0FFh,0E0h,0FFh,0FFh,0E0h,0FFh,0FFh,0E0h,0FFh,0FFh,0E0h,0FFh,0FFh,0E0h,06h,01h; DDAF
	defb 13h,01h,11h,01h,0Fh,01h,0Dh,01h,0Bh,01h,09h,00h,01h,25h,07h,00h; DDBF
	defb 03h,07h,01h,15h,10h,00h,00h,14h,44h,40h,11h,11h,00h,0C4h,44h,40h; DDCF
	defb 51h,11h,00h,70h,00h,00h,02h,0AAh,80h,00h,00h,00h,55h,55h,40h,00h; DDDF
	defb 00h,00h,08h,07h,07h,11h,05h,13h,05h,15h,05h,16h,03h,16h,07h,10h; DDEF
	defb 07h,03h,0Fh,00h,02h,05h,09h,01h,09h,03h,01h,06h,02h,06h,03h,01h; DDFF
	defb 10h,03h,1Fh,11h,40h,41h,00h,5Fh,1Ch,00h,10h,41h,0C0h,77h,0FFh,0C0h; DE0F
	defb 00h,00h,40h,7Fh,5Fh,40h,41h,40h,00h,1Bh,6Ah,0C0h,70h,3Dh,40h,07h; DE1F
	defb 80h,00h,05h,21h,04h,09h,0Ah,0Dh,12h,0Fh,11h,24h,0Dh,01h,1Dh,0Dh; DE2F
	defb 04h,25h,0Fh,25h,11h,25h,13h,23h,13h,06h,08h,0Ah,07h,0Ah,06h,0Ah; DE3F
	defb 05h,0Ah,04h,0Ah,03h,0Ah,23h,03h,25h,15h,08h,10h,00h,08h,10h,00h; DE4F
	defb 08h,10h,00h,08h,10h,00h,00h,10h,00h,0FFh,7Eh,0E0h,00h,00h,00h,00h; DE5F
	defb 80h,00h,00h,81h,00h,00h,81h,00h,06h,11h,0Dh,11h,0Bh,09h,09h,1Fh; DE6F
	defb 0Bh,1Fh,0Dh,1Fh,0Fh,00h,03h,25h,13h,15h,09h,01h,13h,06h,01h,0Ah; DE7F
	defb 02h,0Ah,03h,0Ah,04h,0Ah,05h,0Ah,06h,0Ah,1Bh,09h,22h,15h,41h,00h; DE8F
	defb 00h,00h,14h,0C0h,66h,1Ch,40h,00h,0D5h,40h,22h,00h,40h,3Bh,17h,80h; DE9F
	defb 00h,48h,00h,28h,02h,0C0h,00h,32h,80h,87h,10h,00h,06h,09h,0Dh,13h; DEAF
	defb 0Bh,05h,07h,17h,01h,1Fh,05h,1Bh,09h,02h,1Dh,01h,13h,0Fh,02h,25h; DEBF
	defb 13h,25h,01h,04h,05h,04h,05h,0Eh,14h,06h,1Eh,0Eh,0Bh,03h,01h,13h; DECF
	defb 00h,00h,00h,00h,00h,00h,03h,18h,00h,06h,0Ch,00h,0Ch,06h,00h,78h; DEDF
	defb 03h,0C0h,88h,02h,20h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,17h; DEEF
	defb 03h,00h,06h,25h,13h,25h,11h,25h,0Fh,23h,13h,23h,11h,23h,0Fh,06h; DEFF
	defb 10h,02h,0Fh,02h,0Eh,04h,0Dh,04h,0Ch,06h,0Bh,06h,0Fh,03h,01h,15h; DF0F
	defb 00h,00h,20h,5Dh,0BEh,0E0h,00h,00h,80h,7Fh,8Eh,80h,00h,08h,00h,0F7h; DF1F
	defb 0AEh,0E0h,04h,20h,00h,75h,0FEh,0C0h,20h,00h,00h,04h,00h,20h,04h,0Fh; DF2F
	defb 0Dh,15h,09h,1Dh,05h,1Dh,01h,01h,0Dh,05h,01h,23h,01h,03h,19h,07h; DF3F
	defb 03h,03h,04h,03h,0Fh,05h,1Fh,15h,00h,00h,00h,01h,0B0h,00h,21h,10h; DF4F
	defb 80h,01h,10h,00h,49h,0B2h,40h,68h,00h,0C0h,05h,0F0h,00h,04h,00h,00h; DF5F
	defb 0F9h,57h,20h,00h,00h,00h,08h,03h,07h,09h,07h,09h,05h,0Fh,0Bh,23h; DF6F
	defb 07h,23h,05h,1Dh,05h,1Dh,07h,01h,13h,07h,02h,01h,13h,03h,13h,04h; DF7F
	defb 1Fh,10h,20h,10h,02h,10h,01h,10h,17h,0Bh,25h,11h,00h,00h,00h,40h; DF8F
	defb 3Eh,00h,4Fh,80h,0C0h,42h,03h,00h,01h,0F8h,00h,00h,00h,00h,1Eh,30h; DF9F
	defb 00h,01h,01h,80h,0FDh,06h,00h,00h,00h,00h,06h,21h,0Dh,1Bh,01h,07h; DFAF
	defb 0Bh,07h,09h,0Fh,0Bh,0Fh,0Dh,03h,0Dh,09h,1Bh,09h,07h,13h,01h,13h; DFBF
	defb 13h,03h,09h,04h,0Ah,04h,0Bh,04h,07h,07h,13h,11h,00h,38h,20h,6Eh; DFCF
	defb 13h,0A0h,00h,0C0h,00h,0BBh,9Ch,0E0h,00h,00h,00h,76h,80h,40h,42h,99h; DFDF
	defb 40h,00h,00h,00h,0B3h,19h,0C0h,12h,73h,00h,07h,0Dh,01h,09h,05h,05h; DFEF
	defb 01h,19h,0Bh,1Bh,05h,21h,05h,13h,03h,01h,13h,09h,01h,21h,13h,03h; DFFF
	defb 02h,06h,05h,06h,07h,06h,05h,0Fh,01h,11h,00h,00h,00h,74h,77h,00h; E00F
	defb 44h,50h,00h,74h,77h,0E0h,47h,54h,00h,00h,05h,00h,77h,55h,00h,55h; E01F
	defb 55h,00h,77h,20h,00h,44h,07h,00h,05h,1Fh,09h,1Dh,0Fh,1Eh,11h,0Bh; E02F
	defb 03h,03h,05h,02h,23h,11h,0Dh,0Bh,03h,15h,13h,23h,13h,25h,13h,04h; E03F
	defb 21h,06h,22h,06h,03h,02h,04h,02h,23h,05h,25h,15h,00h,00h,00h,00h; E04F
	defb 01h,0C0h,20h,0E0h,00h,20h,02h,00h,07h,02h,00h,00h,02h,80h,0F8h,0F0h; E05F
	defb 80h,08h,10h,80h,00h,00h,00h,0FAh,0ABh,0E0h,06h,0Dh,07h,0Fh,07h,11h; E06F
	defb 03h,13h,03h,15h,03h,21h,01h,03h,13h,09h,09h,07h,09h,0Bh,00h,07h; E07F
	defb 01h,0Ch,02h,0Ch,03h,0Ch,04h,0Ch,05h,0Ch,06h,0Ch,07h,0Ch,05h,03h; E08F
	defb 1Bh,15h,00h,00h,00h,03h,0F8h,00h,00h,00h,00h,3Fh,0FFh,80h,00h,00h; E09F
	defb 00h,2Ah,0Ah,80h,00h,00h,00h,00h,00h,00h,0CFh,80h,60h,0FFh,0B6h,0E0h; E0AF
	defb 08h,17h,11h,19h,09h,21h,09h,1Dh,09h,05h,09h,09h,09h,0Dh,09h,0Bh; E0BF
	defb 10h,00h,03h,13h,13h,19h,13h,1Fh,13h,04h,12h,06h,13h,06h,14h,06h; E0CF
	defb 15h,06h,13h,01h,0Fh,11h,00h,00h,00h,12h,00h,00h,00h,00h,00h,0FFh; E0DF
	defb 0C0h,00h,0FFh,0E0h,00h,0FFh,0F0h,00h,0FFh,0F8h,00h,0FFh,0FCh,00h,0FFh,0FEh; E0EF
	defb 00h,0FFh,0FFh,00h,08h,21h,13h,1Fh,11h,1Dh,0Fh,1Bh,0Dh,19h,0Bh,17h; E0FF
	defb 09h,15h,07h,0Dh,01h,08h,0Ah,05h,0Ah,03h,25h,12h,25h,10h,25h,0Eh; E10F
	defb 25h,0Ch,25h,0Ah,25h,08h,00h,00h,07h,01h,25h,14h,00h,00h,00h,70h; E11F
	defb 00h,00h,43h,90h,60h,5Ch,9Bh,80h,00h,00h,00h,1Dh,9Fh,0C0h,0B6h,0D1h; E12F
	defb 00h,20h,02h,00h,00h,02h,0C0h,03h,0D9h,00h,04h,03h,01h,13h,11h,17h; E13F
	defb 11h,1Bh,09h,04h,02h,0Dh,15h,0Bh,15h,07h,15h,05h,00h,06h,07h,06h; E14F
	defb 08h,06h,09h,06h,0Ah,06h,0Bh,06h,0Ch,06h,17h,03h,03h,15h,1Fh,82h; E15F
	defb 00h,40h,02h,00h,48h,00h,00h,00h,0CDh,80h,00h,00h,20h,98h,10h,00h; E16F
	defb 00h,37h,00h,70h,80h,40h,06h,00h,0C0h,00h,0DCh,00h,03h,11h,05h,03h; E17F
	defb 01h,13h,11h,01h,07h,05h,02h,15h,13h,25h,07h,04h,03h,0Eh,04h,0Eh; E18F
	defb 02h,0Ah,01h,0Ah,1Bh,05h,1Fh,15h,00h,00h,00h,00h,00h,00h,0FFh,80h; E19F
	defb 00h,00h,00h,00h,0F7h,0FFh,80h,00h,00h,00h,0FFh,36h,80h,00h,2Dh,60h; E1AF
	defb 00h,00h,00h,0FFh,80h,00h,04h,15h,07h,19h,07h,1Dh,07h,21h,07h,01h; E1BF
	defb 0Ah,11h,01h,0Ah,09h,06h,01h,04h,02h,04h,03h,04h,04h,04h,05h,04h; E1CF
	defb 06h,04h,11h,03h,02h,13h,00h,00h,00h,00h,00h,00h,5Fh,0DFh,0C0h,58h; E1DF
	defb 0D8h,0C0h,58h,0D8h,0C0h,5Fh,0DFh,0C0h,40h,0C0h,0C0h,58h,0D8h,0C0h,5Fh,0DFh; E1EF
	defb 0C0h,00h,00h,00h,0Ah,17h,0Fh,19h,10h,13h,0Dh,11h,0Dh,17h,09h,19h; E1FF
	defb 09h,19h,07h,17h,07h,21h,0Dh,23h,0Dh,00h,01h,13h,0Bh,02h,1Ah,0Fh; E20F
	defb 19h,0Fh,19h,05h,1Fh,0Fh,00h,00h,00h,3Fh,00h,80h,10h,00h,80h,10h; E21F
	defb 00h,80h,1Eh,3Eh,80h,10h,0A0h,00h,10h,0A2h,00h,38h,0A2h,80h,00h,00h; E22F
	defb 00h,00h,40h,00h,06h,11h,09h,11h,07h,07h,07h,07h,05h,1Dh,0Dh,1Eh; E23F
	defb 0Bh,04h,1Bh,0Ah,19h,0Ah,17h,0Ah,1Eh,0Fh,01h,25h,13h,05h,0Dh,02h; E24F
	defb 0Eh,02h,0Fh,02h,10h,02h,0Ch,02h,07h,03h,23h,0Eh,0Eh,00h,3Ah,00h; E25F
	defb 3Ah,00h,3Ah,00h,3Ah,00h,3Ah,00h,3Ah,00h,3Ah,00h,3Ah,00h,3Ah,00h; E26F
	defs 129                               ; E27F

; ======================================================================
; SAPI: platform layer

	include platform.asm
	include colours.asm

code_end:
map_buf:	equ (code_end + 0FFh) & 0FF00h	; 880 bytes, MZ: A000h (not in the .COM)
ram_end:	equ map_buf + 880
	if ram_end > 0C000h
	.error "code over C000h (CGA-1V)"
	endif

	end
