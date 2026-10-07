# Jak je port udělaný

Rozbor originálu je v [original.md](original.md), důvody rozhodnutí v [rozhodnuti.md](rozhodnuti.md).

## Princip

- `sapi/flappy_sapi.asm` je disassembler originálu (`orig/flappy.asm`) se změnami označenými `SAPI:`, komentáře
  s adresami jsou adresy MZ-800.
- **Všechna návěští originálu zůstala na svých adresách** (kromě úrovní, ty jsou o 3000h níž). Hra má v datech
  ukazatele, které nejsou návěští, kód se proto nesmí posunout. Hlídá to `tools/check_addr.py` při každém
  překladu (1234 návěští).
- Změna v kódu je buď stejně dlouhá (`OUT (0CCh),A` → `RST 08h` + `NOP`, `OUT (0D0h),A` + `IN A,(0D1h)` →
  `CALL kbd_row` + `NOP`), nebo skok na novou rutinu v `sapi/platform.asm`; zbytek původní rutiny zůstane jako
  mrtvý kód.
- Hra dál počítá s adresami VRAM MZ-800 (8000h + y × 40 + x / 8) a ukládá je do svých dat. Na CGA je převádí až
  platforma: **CGA = C000h + 2 × (adresa − 8000h)** (`cga_addr`).

## Paměť (SAPI)

| Adresa | Obsah |
|---|---|
| 0000–00FF | CP/M; port si uloží 08h–3Fh a dá tam `JP` pro RST 08h (WF), 10h (PSG), 18h (paleta), 38h (přerušení), při ESC je vrátí |
| 0100–14FF | jako MZ: přerušení, hudba (0100h: `JP sapi_init`) |
| 1500–1BFF | uložená stránka 0 (`page0_save`), `ext_vectors` (MZ FA00h), zásobník od 1C00h dolů (1,7 KB) |
| 1C00–1FFF | převodní tabulky bodů `pix_lo1`, `pix_hi1`, `pix_lo2`, `pix_hi2` (4 stránky) |
| 2000–7FFF | jako MZ; **`map_buf` na 7390h** (880 B v mrtvém kódu MZ 7332–7977h, MZ A000h) |
| 8000–B2FF | 200 úrovní (MZ B000h) |
| B300–BC90 | platforma (`platform.asm`, `colours.asm`) |
| C000–FFFF | během hry CGA-1V (`OUT 63h,C0h`); pod ní CP/M (CCP CE00h, BDOS D606h, BIOS E400h) |

- `.COM` má 47,9 KB (0100–BC90h), v CP/M `SAVE 188 FLAPPY.COM`. TPA sestavy V sahá do D5FFh.
- Volné místo: zbytek pod C000h (asi 880 B), mrtvý kód MZ 7332–738Ch a 7700–78EAh (proměnné 738Dh a 78EBh jsou
  živé, hra je čte).

## Porty (SAPI)

| Port | Použití |
|---|---|
| 01h | klávesnice: STROBE (čtení D0), ACK a bzučák (zápis D0, D1) |
| 02h | klávesnice: kód (invertovaný) |
| 50h, 52h, 53h | 82C54: čítač 0 (zpoždění), čítač 2 (tik), řídicí slovo; čtení 53h = STATUS (D7 F2, D3 T0) |
| 54h | zápis IEN (A8h = přerušení F2, hradla G2 a G0), čtení joystick K4 |
| 55h | IACK (80h = F2) |
| 56h, 57h | YM3812 adresa, data |
| 63h | MAP (C0h = CGA-1V na C000h) |

Nic jiného port nepoužívá (ověřeno `io_log` v SAPIemu za běhu titulku a hry).

## Přehled náhrad

| MZ-800 | SAPI-1 V |
|---|---|
| VRAM 8000h, 40 B na řádek, bit 0 vlevo, roviny I a II | CGA-1V v režimu CGA (CONFIG 04h): 80 B na řádek, horní půlbajt = rovina I, dolní = rovina II (D7/D3 vlevo), COLMASK 11h |
| zápisové režimy GDG (WF, port CCh) | dlaždice, písmo, výplně a mazání přímo přes tabulky `pix_*`; vzácné zápisy (rámečky, vzory) obecně přes `vw_hl` podle uloženého WF (`wf_set`, RST 08h) |
| čtení roviny II (test pádu, 2A44h) | `plane2_test` (dolní půlbajty CGA) |
| paleta F0h (4 barvy z 16) | Bt476: položka (n & 1) + 16 × (n >> 1), barvy podle mz800emu (`colours.asm`), `pal_write` (RST 18h) |
| 8253, přerušení RST 38h, nabití v obsluze | 82C54 čítač 2 v režimu 2 (121 = 2,163 ms) → F2 → /INT0 → `isr_entry` |
| busy smyčky 3BA0h (A × 4 ms) a 2236h (60 ms) | čítač 0 v režimu 3 (224 = 4,005 ms), stav T0 (`delay_units`, funguje i se zakázaným přerušením) |
| PSG SN76489 (F2h) | YM3812: kanály 0–2 tóny, 3 šum (`psg_write`, RST 10h) |
| klávesnice: matice 10 sloupců (D0h/D1h) | `kbd_row`: sloupec matice se skládá z kódu klávesnice SAPI (`key_map`) |
| joystick F0h (D0 nahoru, D1 dolů, D2 vlevo, D3 vpravo, D4/D5 palba, aktivní 0) | MPH-1V K4 (`joy_k4`); joystick F1h → nic (`joy_none`) |
| mapování paměti E0h/E1h | odpadlo (NOP), CGA je namapovaná celou dobu |
| SP = 0 | `stack_top` = 1C00h |

## Grafika

- Hra kreslí jen několika rutinami. Nahrazené (vstup originálu → rutina platformy):
  - dlaždice 8×8 (3BF1h), 16×8 (3C1Ch), 16×16 (3C4Dh), 24×16 (3C8Dh), 16×24 (3CD1h) → `put_tile`; data jsou
    rovina I (šířka × výška bajtů), pak rovina II;
  - mazání 8×8/8×16 (3D11h, počet řádků v `clr8_rows`) a 16×8 (3D2Ah) → `clr_box`;
  - znak písma 8×8 v barvě (3E06h: C bit 0 rovina I, bit 1 rovina II, bit 2 inverze; vypnutá rovina dostane
    bajty z `char_blank` = 5C1Dh) → `put_char_s`;
  - smazání obrazovky (2E9Fh) a řádků 72–199 (2ECFh) → `cls_s`, `cls_lower_s` (PUSH se zakázaným přerušením,
    končí EI jako originál);
  - posun loga o 8 řádků (2DFEh) → `scroll_logo_s` (LDIR po 8 řádcích, mezi nimi `poll_keys`);
  - rámečky (2EFAh, 2F08h, 2F13h, 2F21h) → kopie s `vw_de`;
  - výplň pozadí hrací plochy (5393h) → `fill_field_s`; vymazání plochy (51EAh) → `wipe_s`;
  - vzory (57C5h a rutiny 57DFh, 57F3h, 580Dh) → `pattern_draw_s` a kopie s `vw_hl`.
- Všechna místa zápisu do VRAM našly breakpointy v mz800emu (`tools/mz/vram_sites.py`) a kontrola kódu, který
  se při záznamech nespustil (`tools/uncovered.py`).
- Rutiny nastaví `wf` na hodnotu, kterou originál nechá v registru WF (tile 22h, mazání 81h…): vzory běží
  napoprvé s WF, které zůstalo z předchozího kreslení.
- `put_tile` dělá obě roviny jedním průchodem: IX na bajt roviny I, IX + N na bajt roviny II (N = šířka ×
  výška, nejvýš 48, posun se zapisuje do instrukce), H = stránka tabulky:
  `bajt0 = pix_lo1[I] | pix_lo2[II]`, `bajt1 = pix_hi1[I] | pix_hi2[II]`.
- Grafika hry je v datech jako na MZ (bit 0 vlevo); bitové zrcadlení 6ADD–7331h při startu zůstalo.

## Časování a přerušení

- **Tik:** čítač 2 v režimu 2 dělí 55 930,4 Hz 121 → 2,163 ms (462 Hz). Odpovídá průměru originálu ve hře
  (2,16 ms), nezávisí na taktu CPU. Originál měl v titulku 2,33 ms (perioda závisí na délce obsluhy, viz
  original.md), hudba titulku tu proto hraje asi o 7 % rychleji.
- **`isr_entry`** (vektor 0038h, zapisuje ho i `music_start` na 0157h): potvrdí F2, přičte tik (`ticks` =
  operand instrukce na 01B6h, nejvýš FFh) a skočí do původní obsluhy 01A9h. Ta po přičtení tiku (01B8h) povolí
  přerušení a hraje hudbu. Přerušení během hudby jen přičte tik (`isr_busy`), hudbu znovu nespouští.
  Důvod: hudba je interpret MML a při nových notách trvá při 2 MHz až 8,6 ms (na MZ 1,5 ms); dřív se tím
  ztrácely tiky a hra zpomalovala o 8 %.
- Na konci obsluhy (místo nabití 8253 na 0258h) `isr_hook`: klávesnice, stárnutí klávesy, `isr_busy` = 0.
- **Zpoždění** 3BA0h (A × 4 ms) a 2236h (60 ms) čekají na náběžné hrany OUT0 (čítač 0, 4,005 ms), takže
  nezávisí na taktu ani na přerušení; během čekání se čte klávesnice.

### Měření (SAPIemu, `tools/bench.py`, 2026-10-06)

| | MZ-800 (mz800emu) | SAPI 2 MHz | SAPI 4 MHz |
|---|---|---|---|
| krok hry (medián) | 220,6 ms | 220,7 ms | 220,7 ms |
| práce do prvního čekání v kroku | 10,5 ms | 60 ms | 20 ms |
| obsluha přerušení (běžná / nejdelší) | 0,46 / 1,5 ms | 0,62 / 8,6 ms | 0,31 / neměřeno |
| start úrovně (mezerník → první krok) | 3,4 s | 3,9 s | 3,1 s |

- Rozpočet půlkroku při rychlosti 5 je 51 tiků = 110 ms, při 2 MHz zbývá přes 40 ms.
- Start úrovně je hlavně čekání; MZ čeká busy smyčkou, kterou zdržuje přerušení, port podle 82C54.

## Zvuk

- `psg_write` (RST 10h, místo `OUT (0F2h),A`) napodobuje registry SN76489: latch (1 rrr dddd) a data
  (0 x dddddd), tóny 10 bitů, útlum 4 bity, šum. YM3812 se zapisuje jen při změně (`ym_b0`, `ym_lastn`).
- Kmitočet PSG: f = 3 546 895 / 32 / N = 110 840 / N Hz. YM3812: **F-number = K / (N << blok)**, K = 110 840 ×
  2²⁰ / 49 716 = 23ABECh; blok je nejmenší, při kterém N << blok > K >> 10 (`ym_fnum`, dělení 10 bity, ověřeno
  proti Pythonu pro 62 dělitelů).
- Dělitel N < 18 (nad 6 kHz) je ticho: hra používá N = 1 (110 kHz) jako pauzu, na MZ je neslyšitelná.
- Útlum 2 dB na krok → TL 0,75 dB (`ym_tl`); útlum 15 = klíč vypnut.
- Nástroj: kanály 0–2 modulátor se zpětnou vazbou 6 (bzučivý, podobný obdélníku), nosná s trvalou obálkou;
  kanál 3 (šum) modulátor s násobkem 15 a plnou zpětnou vazbou, kmitočet podle rychlosti šumu (N = 16, 32, 64
  nebo kanál 2). Hra šum skoro nepoužívá.
- Zápis do YM3812: 3,3 µs po adrese, 23 µs po datech (`ym_write`, jako v Bombermanovi).
- Druhé PSG na F3h (MZ-1500) se ignoruje.

## Klávesnice a joystick

- Čte se v přerušení (`isr_hook`), při každém čtení sloupce matice hrou (`kbd_row`) a v čekání
  (`delay_units`). Postup jako MikroMon: STROBE (P0-IN0 = 0), kód (P1, invertovaný), ACK (`OUT 01h,03h`),
  dokud STROBE nezhasne (nejvýš 256 čtení), `OUT 01h,02h`. **STROBE se čte jen jednou** (`kbd_poll_di` →
  `kbd_read`): pulz Consulu bez 7474 (1 ms) může skončit hned po prvním čtení.
- `key_map`: kód SAPI → klávesa MZ (bit << 4 | sloupec, bit 7 = klávesa pohybu). Malá písmena a `!`–`)` mají
  SHIFT (sloupec 8, bit 0). ESC = konec (`sapi_exit`).
- **Klávesy SAPI nehlásí puštění.** Klávesa je stisknutá, dokud ji hra nepřečte, a ještě 17 ms (`KEY_MIN`)
  potom, nejvýš 570 ms (`KEY_MAX`). „Přečte“ (`kbd_seen` podle návratové adresy):
  - písmena, číslice, CR, F: `read_key` (volání `kbd_row` z 3990h–3B37h). Menu hesla čte klávesu každých
    60 ms a nečeká na puštění (delší stisk = písmeno dvakrát), ale v jednom kole ji čte dvakrát (3727h a
    3885h), proto ještě 17 ms;
  - šipky, mezerník, BREAK: `read_dir`, kromě volání z `wait_ticks` (2228h), které jen čeká na puštění, a vstup
    hry (`input_hook` na 4FB5h, jednou za krok).
- Stejná klávesa znovu (autorepeat) prodlouží stisk, jiná jde do fronty (8 kláves s příznakem SHIFT); mezi
  klávesami je 27 ms (`KEY_GAP`) vše puštěné.
- Jeden přečtený stisk šipky = jeden krok o 8 bodů, stejně jako krátký stisk na MZ.
- Ověřeno v SAPIemu s Consul 262.3 (s 7474 i bez) a EKL-1 při 2 i 4 MHz: start, chůze, BREAK, menu, heslo
  `MegmI` → úroveň 6, ESC do CP/M.

## Start a konec

- `sapi_init` (0100h): DI, zásobník, uloží 08h–3Fh a dá tam vektory, `OUT 63h,C0h`, smaže obě stránky CGA,
  paleta černá, COLMASK 11h, čítače 0 a 2, IEN 28h (bez přerušení), YM3812, `JP start` (2000h).
- Přerušení F2 povolí až `music_start` (013Fh: IACK, IEN A8h), jako originál programoval 8253.
- `sapi_exit` (ESC): DI, IEN bez přerušení, ticho, vrátí stránku 0, `OUT 63h,00h`, `JP 0` (teplý start CP/M).
  Obraz na CGA zůstane.
