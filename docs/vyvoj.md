# Vývoj

Jak je port udělaný: [port.md](port.md). Originál: [original.md](original.md). Rozhodnutí: [rozhodnuti.md](rozhodnuti.md).

## Začít na jiném počítači

Složky vedle sebe (u autora `E:\SAPI_GIT\`):

| Složka | Co | K čemu |
|---|---|---|
| `SAPI-Flappy` | toto repo (github mlukasek/SAPI-Flappy) | |
| `SAPIemu-release` | **vydaná verze SAPIemu (0.3.0-alpha)** | běh a testy portu (`sapiemu-cli` s MCP) |
| `mz800emu` | emulátor MZ-800 Michala Hučíka s MCP (github michalhucik/mz800emu, build pro Windows) | originál: rozbor, porovnání |
| `Tools\pasmo-0.5.3\pasmo.exe` | assembler | překlad; jinde proměnná `PASMO` |
| `SAPIemu` | vývojová verze emulátoru (repo) | **nepoužívat**, autor ji vyvíjí souběžně; jen jako dokumentace (`docs/desky/`) |

1. **Python 3** (jen standardní knihovna) pro skripty.
2. **Originál `SHARP/Flappy.mzf` není v repozitáři** (autorské právo, repo je veřejné). Je potřeba ho dát do
   `SHARP/` ručně (MD5 `4b0c9d7ba183f924e97476c7b92dc3d6`). Je v `.gitignore` (`SHARP/`, `*.mzf`).
   Překlad portu (`build.cmd`, i `check_addr.py`) ho nepotřebuje. Potřebují ho nástroje nad originálem:
   `mkdis.py`, `check_orig.py`, `tools/mz/*`, `compare.py`, `bench.py --mz`, `sound_check.py`.
3. **Překlad:** `build.cmd` → `build\flappy.com`, `.hex`, `.sym`; spustí `make_tables.py` a `check_addr.py`
   a vypíše počet stránek pro `SAVE` (teď 188). Složky `build\` a `work\` jsou v `.gitignore`.
4. **Emulátor SAPI pro skripty:** `tools\emu\sapiemu.cmd` spustí `sapiemu-cli` ze `SAPIemu-release`
   (proměnná `SAPIEMU_DIR`) s MCP na portu 8591 (jinak proměnná `SAPIEMU_MCP`). Skripty si samy nabootují
   CP/M (volba 1) a uloží stav `cpm` do paměti emulátoru.
5. **mz800emu:** skripty ho spouštějí samy (pipe, bez okna), cesta `E:\SAPI_GIT\mz800emu\mz800emu.exe` nebo
   proměnná `MZ800EMU`. Pracovní složka a logy v `build\mzemu\`.

## Zdroje

| Soubor | Co |
|---|---|
| `sapi/flappy_sapi.asm` | port: disassembler originálu se změnami `SAPI:` (edituje se ručně) |
| `sapi/platform.asm` | náhrada hardwaru MZ-800 |
| `sapi/tables.asm`, `sapi/colours.asm` | generuje `tools/make_tables.py` (needitovat) |
| `orig/flappy.asm` | disassembler originálu, generuje `tools/mkdis.py asm orig/flappy.asm` |
| `tools/annot.py` | vstupní body, jména, čísla vs. adresy pro disassembler |
| `build.cmd` | překlad |
| `docs/img/` | snímky do README (SAPIemu, `screenshot` CGA-1V, přeuložené `tools/png.py`) |

`sapi/flappy_sapi.asm` vznikl jednorázově z `orig/flappy.asm` skriptem (147 úprav podle adres) a dál se
edituje ručně. Když se změní jména v `annot.py`, `orig/flappy.asm` se dá vygenerovat znovu, port ne.

## Pravidla pro změny

- Adresy originálu se nesmí posunout (`check_addr.py`, spouští ho `build.cmd`).
- Změna je stejně dlouhá, nebo `JP` na novou rutinu v `platform.asm`; nová data a kód jen do volného místa
  (viz [port.md](port.md), Paměť).
- Herní logika se nesmí změnit: po každé změně `tools/compare.py` (aspoň `play`, `menu`), u kreslení všechny
  scénáře.
- Lokální návěští `.x` jsou v pasmu globální: v platformě mají předponu podle rutiny (`.pw_`, `.ps_`…).

## Nástroje

| Skript | Co dělá |
|---|---|
| `tools/compare.py --scen S --steps N [--every K] [--dump DIR] [--sp]` | **porovná obrazovku portu (SAPIemu) s originálem (mz800emu) v každém kroku hry** |
| `tools/bench.py [--turbo] [--mz] [--steps N]` | délka kroku hry a práce do prvního čekání (SAPI 2/4 MHz, MZ-800) |
| `tools/sound_check.py [--game]` | noty PSG originálu proti notám YM3812 portu (orientační, viz Pasti) |
| `tools/check_addr.py` | návěští portu = návěští originálu (úrovně −3000h), konec kódu |
| `tools/check_orig.py` | `orig/flappy.asm` se přeloží na obraz paměti originálu |
| `tools/mkdis.py report` / `asm OUT` | disassembler: CDL z mz800emu (`build/cdl*`) + rekurzivní průchod |
| `tools/z80dis.py` | dekodér instrukcí Z80 (pasmo syntaxe) |
| `tools/uncovered.py [N]` | kód, který žádný záznam CDL nespustil |
| `tools/show.py ADDR [N] [FILE]` | výpis disassembleru od adresy |
| `tools/make_tables.py` | převodní tabulky bodů a paleta |
| `tools/png.py` | čtení a zápis PNG bez knihoven |
| `tools/mz/mzemu.py` | klient mz800emu (pipe JSONL): `load_mzf`, `run_until`, `poke`, `peek`, `press`, `screenshot` |
| `tools/mz/cdl_run.py`, `cover.py` | záznam CDL originálu: náhodné hraní, scénáře (`attract`, `clear`, `ending`, `gameover`, `fkeys`) |
| `tools/mz/vram_sites.py [--read] [--skip lo-hi,…]` | místa zápisů a čtení VRAM (breakpointy s logem PC) |
| `tools/mz/cdl.py DIR…` | souhrn CDL (rozsahy X/W/R, porty, VRAM) |
| `tools/emu/sapimcp.py` | klient MCP SAPIemu (HTTP); `python sapimcp.py TOOL '{json}'` |
| `tools/emu/shot.py OUT.png` | snímek CGA-1V |
| `tools/emu/sapiemu.cmd` | spustí `sapiemu-cli` ze `SAPIemu-release` |

## Ověřování: `compare.py`

- Obě verze dostanou stejné testovací záplaty (`TEST_PATCH`, v obou bez vlivu na grafiku):
  - náhoda: 16bitový LFSR místo bajtů kódu a registru R (3B82h);
  - `read_dir` vrací bajt 7F80h, `read_key` vrací 7F81h po 7F82h čtení (2: menu čte dvakrát za kolo),
    `read_joy` nic;
  - synchronizační bod 7F90h (RET) při každém čekání na tiky (2217h, 2F48h), v `delay_2000` (2236h, pro
    každou verzi jiný mezikus) a ve smyčce „Hit SPACE KEY“ (532Ah).
- Skript vede oba emulátory od bodu k bodu, nastaví vstup a zápisy podle scénáře a porovná roviny I a II MZ
  (`region_read` regionů 8 a 9, převedené jako v portu) s CGA (C000h, 16 000 B).
- Scénáře (`SCEN`, krok = jeden synchronizační bod): `title` (600), `play` (500), `clear` (dokončení úrovně
  zápisem 2246h, 450), `menu` (konec hry, menu, rychlost, heslo, návod, demo, 900), `keyword` (`MegmI` →
  úroveň 6 v obou, 520), `ending` (200. úroveň, závěr, 1700), `fkeys`.
- **Výsledek 2026-10-06: všechny obrazovky shodné.** Trvání: 500 kroků asi 2,5 min (`--every` zrychlí).
- Kroky se do synchronizace musí trefit: smyčka bez čekání na tiky (nové menu, nový text „Hit … KEY“) skript
  zasekne (timeout `run_until`); pak přidat synchronizační bod do `TEST_PATCH`.

## Ověřování v reálném čase (SAPIemu)

- Postup jako v `bench.py`: `load_state cpm`, `load_binary` `build\flappy.com` na 0100h, `set_registers pc
  0100`, `run_for`, `joystick`, `type_text`, `press_key`, `screenshot display=CGA-1V`.
- Start úrovně trvá přes 3 s, stisk v té době hra ignoruje; test kláves před tím nic neudělá.
- Klávesnice: `set_keyboard` (`Consul 262.3 (bez 7474)` je výchozí v `sapi1v.sapi`, dále `Consul 262.3`,
  `EKL-1`), F2 = `type_text "\x02"`, BREAK = `press_key backspace`.
- Proměnné hry pro kontrolu: `stage` 5C1Bh, `lives` 502Fh, `keyword_buf` 3939h, poloha hráče 5029h.

## Disassembler

- `mkdis.py asm orig/flappy.asm`, pak `check_orig.py` (musí být shodný).
- Kód = rekurzivní průchod od `annot.ENTRIES` + začátky úseků, které CDL viděl provést (`build/cdl*`,
  vznikají `tools/mz/cdl_run.py` a `cover.py`; složka `build` se nepřenáší, CDL je potřeba nahrát znovu).
  Bez CDL by chyběl kód, kam vedou samomodifikované skoky (3E6Eh…, 57DFh…; ty jsou i v `ENTRIES`).
- `IMM_RANGES`: 16bitové konstanty v 2000–7FFF a B000–E2FF se berou jako adresy; výjimky (porty, počty)
  v `IMM_NUM`. Dolní blok 0100–14FF zůstává číselně (souřadnice by se pletly s adresami).

## Nahrání na disk C: emulátoru

- SAPIemu-release: `work\ide\sapi_hdd.img`. Boot volbou **3** (B, C: HDD), `load_hex` `build\flappy.hex`,
  `SAVE 188 C:FLAPPY.COM`, pak **`power off`** (obraz se zapisuje přes buffer), teprve pak zavřít.
- 2026-10-07 je tam `C:FLAPPY.COM` z aktuálního překladu (kód beze změny od commitu s klávesnicí a SHIFT).

## Pasti

- **pasmo:** lokální návěští `.x` jsou globální; unární minus na začátku výrazu neguje celý zbytek; operand
  začínající závorkou je adresa; `REPT` funguje, `DEFL` v něm ne (viz globální poznámky autora).
- **Hra opouští podprogramy skokem** (zásobník roste při držené klávese), proto 1,7 KB zásobníku.
- **Menu a „Hit SPACE KEY“ čekají bez čekání na tiky**, proto synchronizační body navíc v `compare.py`.
- **mz800emu:**
  - `mem_write` do VRAM nejde (kontrola regionu), čtení rovin `region_read` regionů 8 a 9;
  - breakpoint: `bp_create_with_init` s plochým payloadem (`type` MEM_W/MEM_R/IORQ_W, `addr_end`,
    `addr_match_mode` RANGE, `action`, `enabled`) a předtím `debugger_activate`; `log` jde na stderr
    (`build/mzemu/stderr_*.log`), PC v logu je až za opkódem; breakpointy se ukládají do `.bpt` v cfg-dir
    (skripty ho mažou);
  - `total_cycles` = takty CPU 3,5469 MHz; jména kláves `LEFT`, `RIGHT`, `UP`, `DOWN`, `SPACE`, `CR`, `F1`…,
    `SHIFT` zvlášť (`press`); joystick není připojený, originál se testuje klávesnicí;
  - `run_frames` nejvýš 1000 snímků na volání; po ukončení se `.ini` neukládá (`--no-save-ini`).
- **SAPIemu:**
  - `run_for` bere celé milisekundy (0,5 = 0);
  - `io_log` při průběžném čtení a mazání ztrácí záznamy, páry adresa/data YM3812 se pak špatně spárují
    (`sound_check.py` je proto jen orientační);
  - `read_memory` nejvýš 4096 B; `cycles` = takty 4 MHz i při CPU 2 MHz;
  - screenshot je nekomprimované PNG (750 KB), do repa přeuložit přes `tools/png.py`;
  - Consul bez 7474: pulz 1 ms a klávesu, kterou program během pulzu přečetl, emulátor neopakuje (věrné HW).
