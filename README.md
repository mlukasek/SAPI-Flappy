# SAPI-Flappy

Port hry Flappy (dB-SOFT 1984, verze pro Sharp MZ-800) na **Tesla SAPI-1**, sestavu „V“ Libora Lasoty
s barevnou grafikou **CGA-1V** a zvukovou kartou **MPH-1V**, jako CP/M `.COM`.

Neveřejné repo: hra je chráněná autorským právem dB-SOFT.

## Stav (2026-10-06)

- Hra je hratelná v SAPIemu se sestavou `machines/sapi1v.sapi`: titulek a demo, návod, hra, 200 úrovní, menu
  (rychlost, heslo), konec hry, závěrečná sekvence, hudba, joystick, klávesnice Consul 262.3 i EKL-1, návrat
  do CP/M.
- **Obrazovka je v každém herním kroku bajt po bajtu stejná jako u originálu v emulátoru MZ-800** (ověřeno
  `tools/compare.py`, viz Ověřování).
- Hra běží stejně rychle jako na MZ-800 při 2 i 4 MHz (krok hry 220,7 ms, MZ-800 220,6 ms).
- Na skutečném HW zatím nevyzkoušeno.

## Ovládání

| Akce | Joystick (K4) | Klávesnice Consul 262.3 | Klávesnice EKL-1 |
|---|---|---|---|
| pohyb | páka | šipky C1–C4 | šipky (kódy WordStar 05, 18, 04, 13) |
| start hry z titulku | palba (FL) | mezerník | mezerník |
| akce ve hře (originál: SPACE) | palba | mezerník | mezerník |
| vzdát úroveň (originál: BREAK) | | BREAK nebo Backspace | Backspace (08) |
| menu (po konci hry) | | CR | CR |
| F1 rychlost, F2 heslo (menu), F1–F5 rychlost ve hře | | ROL (F1), COPY (F2), klávesy 61–63 (F3–F5), Ctrl+A/B/C/F/G | Ctrl+A, B, C, F, G |
| konec, návrat do CP/M | | ESC | ESC |

- Hra se ovládá tím zařízením, kterým se spustila (mezerník = klávesnice, palba = joystick), jako na MZ-800.
- **Jedno stisknutí šipky = jeden krok o 8 bodů** (půl políčka), stejně jako krátký stisk na MZ-800. Klávesnice
  SAPI nehlásí puštění klávesy, port proto drží klávesu stisknutou, dokud ji hra nepřečte (viz Klávesnice).
  S autorepeatem (PC v emulátoru) nebo joystickem jde postava plynule. Consul 262.3 autorepeat nemá: chůze
  = opakované ťukání nebo joystick.
- **Hesla (Key word) rozlišují velikost písmen** (např. `shiba`, `MegmI`, `STONE`, `hiki!`). Na MZ se malá
  písmena a `!`–`)` píšou se SHIFT, port to dělá sám podle kódu klávesy SAPI.
- Hesla ukazuje obrazovka po dokončení každé páté úrovně; heslo začne hru od úrovně, ke které patří.

## Spuštění

- **Překlad:** `build.cmd` → `build\flappy.com`, `build\flappy.hex` (od 0100h), `build\flappy.sym`. Na konci
  vypíše počet stránek pro `SAVE` (teď 188). Potřebuje Python 3 (jen standardní knihovna) a pasmo 0.5.3
  (`E:\SAPI_GIT\Tools\pasmo-0.5.3\pasmo.exe`, jinde proměnná `PASMO`).
- **V SAPIemu do paměti:** v CP/M Soubor → Nahrát program do paměti (`build\flappy.hex`), pak `SAVE 188
  FLAPPY.COM` (nebo rovnou na disk C:, viz Bomberman). Přes MCP: `load_binary` souboru `flappy.com` na 0100h
  a `set_registers` s `pc` = 0100h, když CP/M čeká na příkaz.
- Velikost: `.COM` má 47,9 KB (0100–BC00h). TPA sestavy V sahá do D5FFh (BDOS D606h), vejde se.

## Soubory

| Soubor | Co |
|---|---|
| `SHARP/Flappy.mzf` | originál pro MZ-800 (páska MZF: 128 B hlavička, program od 1E00h) |
| `orig/flappy.asm` | disassembler originálu (paměť po zavaděči), přeloží se bajt po bajtu stejně (`tools/check_orig.py`) |
| `sapi/flappy_sapi.asm` | port: `orig/flappy.asm` se změnami označenými `SAPI:` |
| `sapi/platform.asm` | náhrada hardwaru MZ-800: CGA-1V, 82C54, YM3812, klávesnice, joystick |
| `sapi/tables.asm`, `sapi/colours.asm` | převodní tabulky bodů a paleta, generuje `tools/make_tables.py` (needitovat) |
| `tools/` | disassembler, kontroly, ověřování v emulátorech (viz Vývoj) |

## Originál (MZ-800)

- Páska `FLAPPY 1.0A`, nahrává se na 1E00h. Zavaděč na 1E00h vypne ROM (`OUT E0h, E1h`) a přesune bloky:
  B400–C7FF → 0100–14FF, 8000–B2FF → B000–E2FF (přes C000), pak `JP 2000h`.
- Paměť po zavaděči:

| Adresa | Obsah |
|---|---|
| 0038h | `JP 01A9h` (zapíše `music_start`) |
| 0100–14FF | přerušení, hudba: **interpret MML** (noty jako text, `#`, `<`, `>`…), melodie od 1210h |
| 2000–5BEC | program |
| 5BED–7331 | proměnné, grafika (dlaždice ve 2 rovinách), písmo 6ADDh (při startu se bitově zrcadlí) |
| 7332–7977 | mrtvý kód (nevolaný ovladač zvuku), živé jsou jen proměnné 738Dh a 78EBh |
| 7978–7BD8 | závěrečná sekvence po 200. úrovni, za ní její texty |
| 8000–9F3F | VRAM (320×200, 4 barvy, roviny I a II, mapované `IN A,(0E0h)`) |
| A000–A36F | mapa hrací plochy 40×22 |
| B000–E2FF | 200 úrovní (B000h počet, od B001h data) |
| FA00h | tabulka vektorů pro cizí program (hra ji jen zapisuje) |
| FFxx | zásobník (SP = 0) |

- Porty: GDG CCh (WF), CDh (RF), CEh (režim), CFh (scroll), F0h (paleta), D0h/D1h klávesnice 8255, F0h/F1h
  joystick, F2h PSG SN76489, D4h–D7h 8253, E0h/E1h mapování. Na A0h–A2h je nedosažitelný kód (AY-3-8910).
  ROM ani znakový generátor hra nepoužívá.
- Přerušení: 8253 čítač 2 v režimu 0, v obsluze se znovu nabije 11 (1,84 ms) až na konci, perioda je tedy
  11 taktů + doba obsluhy: ve hře 2,16 ms, v titulku 2,33 ms (změřeno v mz800emu). Obsluha přičte tik
  (`ticks`, 01B7h) a hraje hudbu. Hra čeká v každém půlkroku na `tick_div` tiků (rychlost 0–9, výchozí 5 =
  51 tiků).

## Paměť a porty (SAPI)

| Adresa | Obsah |
|---|---|
| 0000–00FF | CP/M; port si uloží 08h–3Fh a dá tam `JP` pro RST 08h (WF), 10h (PSG), 18h (paleta), 38h (přerušení) |
| 0100–14FF | jako MZ (0100h: `JP sapi_init`) |
| 1500–1BFF | uložená stránka 0, `ext_vectors` (MZ FA00h), zásobník (od 1C00h dolů, 1,7 KB) |
| 1C00–1FFF | převodní tabulky bodů (4 stránky) |
| 2000–7FFF | jako MZ, **`map_buf` na 7390h** (v mrtvém kódu, MZ A000h) |
| 8000–B2FF | úrovně (MZ B000h) |
| B300–BC00 | platforma (`platform.asm`) |
| C000–FFFF | během hry CGA-1V (`OUT 63h,C0h`), CP/M pod ní (CCP CE00h, BDOS D606h) |

- **Všechna návěští originálu jsou na svých adresách** (kromě úrovní, −3000h), hlídá to `tools/check_addr.py`
  při každém překladu. Hra má v datech ukazatele, které nejsou návěští, kód se proto nesmí posunout. Změny
  v kódu jsou stejně dlouhé, nebo skok na novou rutinu v platformě (zbytek původní rutiny zůstává jako mrtvý).
- Porty: 01h, 02h klávesnice (JPR-1V), 50h–57h MPH-1V (82C54, STATUS, IEN, joystick, IACK, YM3812), 63h MAP.
  Nic jiného port nepoužívá (ověřeno `io_log` v SAPIemu).

## Jak je port udělaný

| MZ-800 | SAPI-1 V |
|---|---|
| VRAM 8000h, 40 B na řádek, bit 0 vlevo, 2 roviny | CGA-1V v režimu CGA: 80 B na řádek, horní půlbajt = rovina I, dolní = rovina II (D7/D3 vlevo), COLMASK 11h |
| adresy VRAM v datech hry | zůstávají, převádí je až platforma: CGA = C000h + 2 × (adresa − 8000h) (`cga_addr`) |
| zápisové režimy GDG (WF) | dlaždice, písmo, výplně a mazání přímo (tabulky `pix_*`); vzácné zápisy (rámečky, vzory) obecně přes `vw_hl` podle WF |
| čtení roviny II (test pádu, 2A44h) | `plane2_test` (dolní půlbajty CGA) |
| paleta F0h (4 z 16 barev) | Bt476: položka (n & 1) + 16 × (n >> 1), barvy podle mz800emu (`colours.asm`) |
| 8253, přerušení RST 38h | 82C54 čítač 2 v režimu 2 (121 = 2,163 ms) → F2 → INT0 → `isr_entry` |
| busy smyčky 3BA0h (A × 4 ms), 2236h (60 ms) | čítač 0 v režimu 3 (224 = 4,005 ms), stav T0 (funguje i se zakázaným přerušením) |
| PSG SN76489 (F2h) | YM3812: kanály 0–2 tóny, 3 šum; F-number a blok z dělitele N, útlum → TL |
| klávesnice: matice 10 sloupců (D0h/D1h) | `kbd_row`: matice se skládá z kódu klávesnice SAPI (`key_map`) |
| joystick F0h | MPH-1V K4 (`joy_k4`), druhý joystick (F1h) není |

### Grafika

- Hra kreslí jen několika rutinami: dlaždice 8×8, 16×8, 16×16, 24×16, 16×24 (data: rovina I, pak rovina II),
  mazání, znak písma 8×8 v barvě, smazání obrazovky, posun loga, rámečky, výplň pozadí, vzory. Všechna místa
  zápisu do VRAM našly breakpointy v mz800emu (`tools/mz/vram_sites.py`) a statická kontrola nepokrytého
  kódu.
- Režimy GDG ověřené v mz800emu: **REPLACE** zapíše vybrané roviny a ostatní vynuluje (celý bajt), **PSET**
  mění jen body s 1, XOR/OR/RESET jen vybrané roviny. Hra používá 81h, 82h (REPLACE), 21h, 22h (XOR) a 41h (OR).
- `put_tile` dělá obě roviny jedním průchodem (IX na rovinu I, IX + N na rovinu II, tabulky `pix_lo1` …
  `pix_hi2` po stránkách).

### Časování a přerušení

- Perioda tiku je pevná 2,163 ms (průměr originálu ve hře), nezávisí na taktu CPU. Hudba v titulku proto hraje
  asi o 7 % rychleji než na MZ.
- **Hudba (interpret MML) v přerušení trvá při nových notách i několik milisekund** (při 2 MHz až 8,6 ms,
  na MZ 1,5 ms). Proto `isr_entry` hned potvrdí F2 a přičte tik a zbytek obsluhy běží s povoleným přerušením.
  Přerušení během hudby jen přičte tik (`isr_busy`), hudbu nespouští znovu. Hra tak nezpomalí.
- Práce jednoho půlkroku hry: MZ 10 ms, SAPI 4 MHz 20 ms, 2 MHz 60 ms (rozpočet 110 ms). Obsluha přerušení
  zabere při 2 MHz asi 0,6 ms z 2,16 ms.
- Start úrovně (od mezerníku po první krok, většinou čekání): MZ 3,4 s, SAPI 2 MHz 3,9 s, 4 MHz 3,1 s. Čekací
  smyčky MZ (3BA0h) zdržuje přerušení, port čeká podle 82C54 přesně.

### Zvuk

- `psg_write` (RST 10h) napodobuje registry SN76489 (latch a data), YM3812 se zapisuje jen při změně.
- F-number = K / (N << blok), K = 110840 × 2^20 / 49716 = 23ABECh (`ym_fnum`, ověřeno proti výpočtu v Pythonu
  pro 62 dělitelů). Dělitel N = 1 (110 kHz) používá hra jako pauzu, na YM3812 je to ticho.
- Útlum 2 dB na krok → TL 0,75 dB (`ym_tl`), útlum 15 = klíč vypnut.
- Barva tónu: modulátor se zpětnou vazbou (bzučivý jako obdélník PSG). Šum (kanál 3) je přibližný: modulátor
  s velkým násobkem a plnou zpětnou vazbou. Hra šum skoro nepoužívá.

### Klávesnice

- Čte se v přerušení (`isr_hook`) i při každém čtení sloupce matice hrou (`kbd_row`). Postup jako MikroMon:
  STROBE, kód, ACK, dokud STROBE nezhasne (nejvýš 256 čtení), ACK pryč. **STROBE se čte jen jednou:** pulz
  Consulu (1 ms) může skončit hned po prvním čtení a emulátor (věrně) klávesu, kterou program viděl, neopakuje.
- `key_map`: kód SAPI → klávesa MZ (sloupec, bit), malá písmena a `!`–`)` se SHIFT (sloupec 8, bit 0).
- Klávesa je stisknutá, dokud ji hra nepřečte, a ještě 17 ms potom (nejvýš 570 ms):
  - písmena, číslice, CR, F: přečte je `read_key` (volání `kbd_row` z 3990h–3B37h). Menu hesla čte klávesu
    každých 60 ms a nečeká na puštění, delší stisk by dal písmeno dvakrát; menu ji ale čte dvakrát za kolo,
    proto ještě 17 ms;
  - šipky, mezerník, BREAK: přečte je `read_dir` (kromě volání z `wait_ticks` 2228h, to jen čeká na
    puštění) nebo vstup hry (`input_hook` na 4FB5h, jednou za krok).
- Mezi dvěma klávesami jsou všechny 27 ms puštěné, další čekají ve frontě (8).
- Ověřeno v SAPIemu s Consul 262.3 (s 7474 i bez), EKL-1 při 2 i 4 MHz: start, chůze po krocích, BREAK, menu,
  heslo `MegmI` → úroveň 6, ESC do CP/M.

## Vývoj a ověřování

Potřeba: Python 3, **SAPIemu** (`sapiemu-cli --machine machines/sapi1v.sapi --mcp --mcp-port 8591` ze složky
SAPIemu, na pozadí; jiný port: proměnná `SAPIEMU_MCP`) a **mz800emu** Michala Hučíka s MCP
(`E:\SAPI_GIT\mz800emu`, jinde proměnná `MZ800EMU`; skripty si ho spouštějí samy bez okna, JSONL přes stdin).
Skripty si samy nabootují CP/M v SAPIemu (volba 1) a uloží stav `cpm` do paměti emulátoru.

| Skript | Co dělá |
|---|---|
| `tools/compare.py --scen S --steps N [--every K] [--dump DIR]` | **porovná obrazovku portu a originálu v každém kroku hry** |
| `tools/bench.py [--turbo] [--mz]` | délka kroku hry a práce do prvního čekání (SAPI 2/4 MHz, MZ-800) |
| `tools/sound_check.py` | noty z PSG originálu proti notám z YM3812 portu (`io_log`; viz Pasti) |
| `tools/check_addr.py`, `tools/check_orig.py` | adresy návěští portu = originál; `orig/flappy.asm` = originál |
| `tools/mkdis.py`, `tools/annot.py`, `tools/z80dis.py` | disassembler: CDL z mz800emu + rekurzivní průchod, jména v `annot.py` |
| `tools/mz/cover.py`, `cdl_run.py`, `vram_sites.py`, `cdl.py` | pokrytí kódu originálu (CDL), místa zápisů a čtení VRAM |
| `tools/mz/mzemu.py`, `tools/emu/sapimcp.py` | klienti mz800emu (pipe) a SAPIemu (HTTP) |
| `tools/show.py ADDR` | výpis disassembleru od adresy |

**`compare.py`:** obě verze dostanou stejné testovací záplaty (`TEST_PATCH`): náhoda bez registru R a bajtů kódu
(LFSR), směr z bajtu 7F80h, kód klávesy z 7F81h (8 čtení), joystick vypnutý a synchronizační bod 7F90h při
každém čekání na tiky (2217h, 2F48h), v `delay_2000` a ve smyčce „Hit SPACE KEY“. Skript vede oba emulátory
od bodu k bodu, nastaví vstup podle scénáře a porovná roviny I a II MZ (regiony 8 a 9) s CGA. Scénáře:
`title` (600 kroků), `play` (500), `clear` (dokončení úrovně přes zápis do 2246h), `menu` (konec hry, menu,
rychlost, heslo, návod, demo, 900), `keyword` (heslo `MegmI`, úroveň 6 v obou), `ending` (200. úroveň, závěr,
1700). **Všechny obrazovky shodné** (2026-10-06).

**Disassembler:** `mkdis.py asm orig/flappy.asm` (pak `check_orig.py`). Kód hledá rekurzivní průchod od vstupů
(`annot.ENTRIES`, mimo jiné cíle samomodifikovaného `DJNZ` na 3EADh a nepřímých volání 57CEh) a všechno, co
CDL záznam mz800emu viděl provést (`build/cdl*`, `tools/mz/cover.py`). `sapi/flappy_sapi.asm` vznikl
z `orig/flappy.asm` jednorázově, dál se edituje ručně.

## Pasti

- **Lokální návěští pasma `.x` jsou globální** (dvakrát `.pw_end` = chyba překladu).
- **Testy v reálném čase:** start úrovně trvá přes 3 s, stisk v té době hra ignoruje.
- **Hra opouští podprogramy skokem:** `poll_keys` (2F66h) při CR skočí do menu, titulek se volá znovu.
  S drženou klávesou zásobník roste asi o 24 B na kolo (i na MZ, tam má celou paměť). Proto 1,7 KB zásobníku.
- **Menu a „Hit SPACE KEY“ čekají bez čekání na tiky** (smyčky s `delay_2000` nebo jen čtení kláves). Pro
  `compare.py` tam jsou synchronizační body navíc.
- **mz800emu:** `mem_write` do VRAM nejde (kontrola regionu), čtení rovin `region_read` regionů 8 a 9;
  breakpoint přes `bp_create_with_init` s plochým payloadem (`type`, `addr_end`, `addr_match_mode`, `action`)
  a se zapnutým debuggerem (`debugger_activate`), `log` jde do stderr; v logu je PC až po načtení opkódu.
  Názvy kláves `LEFT`, `RIGHT`, `UP`, `DOWN`, `SPACE`, `CR`, `F1`… Breakpointy se ukládají do `.bpt`
  v cfg-dir, skripty ho mažou.
- **SAPIemu:** `run_for` bere celé milisekundy (0,5 = 0). `io_log` při průběžném čtení a mazání ztrácí
  záznamy, páry adresa/data YM3812 se pak špatně spárují (`sound_check.py` je proto jen orientační). `read_memory`
  vrací nejvýš 4096 bajtů.
- **Unární minus v pasmo** a další pasti: viz `..\SAPIemu\CLAUDE.md`.

## Nejasnosti k ověření na HW

- CGA-1V v režimu CGA (CONFIG D2 = 1) s COLMASK 11h: barvy bodů podle obou půlbajtů.
- Přerušení F2 z MPH-1V přes /INT0 na JPR-1V v IM 1 (RST 38h), potvrzení IACK (`OUT 55h,80h`).
- Stav T0 (STATUS D3) čítače 0 pro zpoždění.
- Klávesnice: Consul 262.3 bez 7474 (STROBE jen 1 ms) se čte v přerušení každých 2,16 ms a při každém čtení
  sloupce hrou; v čekacích smyčkách hry často. Může se stisk ztratit? (v emulátoru ne, ten pulz opakuje).
- Barvy: paleta je převzatá z mz800emu, skutečné MZ-800 může vypadat jinak.
- Rychlost a zvuk na skutečné desce (YM3812: 3,3 µs po adrese, 23 µs po datech).
