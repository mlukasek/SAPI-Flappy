# Originál: Flappy pro Sharp MZ-800

Rozbor z disassembleru (`orig/flappy.asm`) a z běhu v mz800emu (CDL, breakpointy, měření), 2026-10-06.

## Soubor

- `SHARP/Flappy.mzf` (v repozitáři není, jen lokálně, viz [vyvoj.md](vyvoj.md)): páska MZF, 128 B hlavička
  a 44 033 B programu. Jméno `FLAPPY` + kana + ` 1.0A`, nahrání i start 1E00h, v komentáři hlavičky `MZ-800`.
- MD5 celého souboru: `4b0c9d7ba183f924e97476c7b92dc3d6`.
- Zavaděč na 1E00h: `IM 0`, `LD SP,0`, `IN A,(0E1h)`, `OUT (0E1h),A`, `OUT (0E0h),A` (celá RAM, bez ROM),
  přesune B400–C7FF → 0100–14FF, 8000–B2FF → C000–F2FF → B000–E2FF (přes C000h, aby se bloky nepřekrývaly)
  a skočí na 2000h. Zbytek souboru (B300–B3FF, C800–CA00) jsou nuly.

## Paměť po zavaděči

| Adresa | Obsah |
|---|---|
| 0038h | `JP 01A9h` (zapíše `music_start`) |
| 0100–14FF | přerušení a hudba: **interpret MML** (noty jako text `#`, `$`, `+`, `-`, `<`, `>`, `^`, `:`), melodie od 1210h; 0100h tabulka skoků (nepoužitá), 0166h/0186h pauza (nepoužitá) |
| 2000–5BEC | program |
| 5BED–7331 | proměnné, grafika (dlaždice ve dvou rovinách), písmo 6ADDh (8 B na znak) |
| 7332–7977 | **mrtvý kód** (ovladač zvuku, který hra nevolá); živé jsou jen proměnné 738Dh a 78EBh |
| 7978–7BD8 | závěrečná sekvence po 200. úrovni, za ní její texty a proměnné |
| 7F40–7FFF | nuly |
| 8000–9F3F | VRAM (mapovaná `IN A,(0E0h)`, s ní i CG ROM na 1000h); RAM pod ní hra nepoužívá |
| A000–A36F | `map_buf`: mapa hrací plochy 40 × 22 buněk |
| B000–E2FF | úrovně: B000h počet (200), od B001h data |
| FA00h | 24 B: tabulka vektorů pro cizí program (kopíruje ji 36FAh, nevolané; hra jen zapisuje FA02h) |
| FFB2–FFFF | zásobník (SP = 0), v menu až FF14h |

- Při startu (2027h) se bitově zrcadlí bajty 6ADD–7331h (písmo a část grafiky měly bit 7 vlevo).
- Náhoda (`random`, 3B82h): XOR dvou bajtů z ukazatele, který prochází kód 204E–7F3Fh, a registru R; ukazatel
  pak skáče i do RAM nad A000h.

## Porty

| Port | Použití |
|---|---|
| CCh | GDG WF (zápisový režim): 81h, 82h REPLACE, 21h, 22h XOR, 41h OR |
| CDh | GDG RF (čtení): 01h, 02h (jedna rovina) |
| CEh | režim zobrazení: jednou 0 (320 × 200, 4 barvy, rámec A) |
| CFh | scroll: jednou registr 6 = 0 |
| F0h | zápis paleta (4×: 00h, 11h, 22h, 36h; závěr 1Fh a 11h), čtení joystick 1 |
| F1h | čtení joystick 2 |
| D0h, D1h | 8255: sloupec matice klávesnice (E0h–E9h), řádek (aktivní 0) |
| D5h–D7h | 8253: čítač 1 (režim 2, 2) a 2 (režim 0, 14, v obsluze 11) |
| F2h | PSG SN76489 (F3h = druhé PSG MZ-1500, jen v nepoužité větvi) |
| E0h, E1h | mapování paměti (IN) |
| A0h–A2h | AY-3-8910 (joystick?), nedosažitelný kód 3B58h |

ROM ani znakový generátor hra nečte (CDL).

## Grafika

- Režim 320 × 200 se 4 barvami, rámec A: roviny I a II, 40 B na řádek, bit 0 = levý bod. Adresa buňky 8×8:
  `vaddr` (3BC5h) = 8000h + řádek × 320 + sloupec, `vaddr_field` (3BB2h) totéž od 83C0h (hrací plocha od
  řádku 3).
- Zápisové režimy GDG ověřené v mz800emu (před zápisem I = 0Fh, II = F0h, data 3Ch):

| WF | Výsledek | Význam |
|---|---|---|
| 81h REPLACE I | I = 3Ch, II = 00h | vybrané roviny = data, ostatní 0 (celý bajt) |
| 82h REPLACE II | I = 00h, II = 3Ch | |
| 83h REPLACE I+II | I = II = 3Ch | |
| C1h PSET I | I = 3Fh, II = C0h | body s 1 dostanou barvu, ostatní beze změny |
| 21h XOR I | I = 33h, II = F0h | jen vybrané roviny |

- Dlaždice se kreslí dvakrát: rovina I s REPLACE (81h), pak rovina II s XOR (22h) – výsledek je přesně obě
  roviny dlaždice. Rutiny 16×16, 24×16, 16×24 kopírují `LDI` se zásobníkem jako krokem (DI).
- Jediné čtení VRAM: test pádu (2A3Ah) čte rovinu II dvou bajtů pod objektem (RF = 02h); posun loga (2E3Bh)
  kopíruje VRAM → VRAM po rovinách.
- Logo FLAPPY se skládá z cihel (`logo_row` 2E4Bh, 2 bity na buňku: dlaždice 5C5Dh, 5C8Dh, nic, smazat).
- Vzory (57C5h) volají kreslicí rutinu dvakrát: poprvé s WF, které zbylo z předchozího kreslení, podruhé
  s 82h (REPLACE II), takže první průchod se přepíše.

## Přerušení a časování

- 8253: čítač 1 režim 2 s 2, čítač 2 režim 0 s 14; v obsluze (konec, 0258h) se čítač 2 nabije znovu 11.
  Perioda je tedy 11 taktů čítače + doba obsluhy: **ve hře průměrně 2,16 ms, v titulku 2,33 ms** (mz800emu,
  medián ve hře 2,11 ms, v titulku 2,29 ms; při DI v kreslení občas tik vypadne).
- Obsluha (01A9h): `IN A,(0E1h)`, přičte `ticks` (operand na 01B7h, nejvýš FFh), krok hudby, nabití 8253,
  `IN A,(0E0h)`. Běžně 1 618 T (0,46 ms), při nových notách až 5 214 T (1,5 ms).
- Hra (`main_loop` 20B1h) má dva půlkroky, každý začne `ticks` = 0 a končí `wait_ticks` (2217h): čeká, až
  `ticks` ≥ `tick_div` (5C19h z `speed_table` 225Bh podle rychlosti 0–9; výchozí 5 = 51 tiků). Krok hry tedy
  trvá 2 × 51 tiků = 220,6 ms. Titulek a menu čekají v `wait_ticks2` (2F48h) nebo smyčkami s `delay_2000`.
- `delay` (3BA0h): A × 200 × 71 T = A × 4 ms při 3,5469 MHz; `delay_2000` (2236h): 2000h × 26 T = 60 ms.

## Hudba

- Tři hlasy MML, každý tik se pro každý hlas volá `0548h` (podle všeho obálka a hlasitost), na konci noty se čte další znak melodie (0366h) a
  počítá dělitel z tabulky not (`note_table` 0764h, 12 půltónů pro nejnižší oktávu, posun doprava za oktávy).
- PSG: tón `psg_tone` (0673h, dva zápisy: 1cc0 nnnn a 00nn nnnn), hlasitost `psg_vol` (064Ch, 1cc1 vvvv),
  šum 06BAh. Dělitel 1 slouží jako pauza.
- Hodiny PSG 3,5469 MHz: f = 110 840 / N (např. N = 1710 → 64,8 Hz, C2).

## Vstup

- `read_dir` (393Fh): sloupce 6 (mezerník), 7 (šipky), 8 (BREAK) → bajt směru (80h mezerník, 02h BREAK,
  šipky 10h, 08h, 04h…), uloží `dir_state` 398Fh.
- `read_key` (3990h): projde sloupce 5, 4, 3, 2 (`key_row` 3B24h), 6, 7, 8, 1, 0, 9 a vrátí kód (ASCII,
  CR 0Dh, F1–F5 = F0h–F4h, šipky 1Ch–1Fh); se SHIFT (sloupec 8 bit 0) malá písmena a `!`–`)`.
- `read_joy` (3B3Ah): F0h, když nic, tak F1h; po CPL: D0 nahoru, D1 dolů, D2 vlevo, D3 vpravo, D4/D5 palba.
- Vstup hry `4FB5h` jednou za krok: příkaz 5028h (4 vpravo, 3 vlevo, 2, 1, 5 mezerník, FFh BREAK = vzdát).
  Hra se ovládá zařízením, kterým se spustila (5C1Ah: 0 klávesnice, 1, 2 joystick).
- Jedno přečtení směru posune hráče o jednu jednotku (8 bodů); poloha hráče 5029h/502Ah.
- F1–F5 za hry a v menu: `speed_req` (3748h). Menu (2FD5h): F1 rychlost, F2 heslo, CR demo, mezerník hra.
  Heslo (3885h): čte klávesu každých 60 ms bez čekání na puštění.

## Proměnné a hesla

| Adresa | Význam |
|---|---|
| 01B7h | `ticks` |
| 2243h | odpočet při umírání |
| 2246h | `stage_clear`: 1 = úroveň splněna (nastaví 5983h, když jsou v mapě na určeném místě dvě buňky 80h) |
| 3F32h | `time_left` |
| 502Fh | `lives` |
| 5032h | `player_state` |
| 5C19h | `tick_div` |
| 5C1Bh | `stage` (1–200) |
| 5C1Ch | `keyword_idx` |
| 3939h | `keyword_buf` (5 znaků) |

- Hesla jsou souvislý řetězec v `keywords` (2266h), po 5 znacích pro úrovně 1, 6, 11… (`shiba`, `MegmI`,
  `Peiki`…). Rozlišují velikost písmen. Shoda nastaví `stage` = `keyword_idx`.
- Dokončení úrovně se dá vyvolat zápisem 1 do 2246h, závěr hry zápisem 200 do 5C1Bh a pak 1 do 2246h (tak
  testuje `tools/compare.py` a `tools/mz/cover.py`).

## Zvláštnosti

- **Hra opouští podprogramy skokem:** `poll_keys` (2F66h) při CR skočí do menu (2FA6h), menu do titulku;
  s drženou klávesou zásobník roste asi o 24 B na kolo. Na MZ je od FFFFh dolů dost místa.
- Samomodifikující kód: operandy instrukcí jako proměnné (`ticks`, `clr8_rows` 3D21h…), posun `DJNZ` na 3EADh
  (vypisování čísel, cíle 3E67h, 3E6Eh, 3E75h, 3E7Ch), cíle volání na 57CEh/57D6h.
- Několik `DI … EI` kolem výpisů textu, čtení kláves a kreslení se zásobníkem.
