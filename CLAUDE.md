# SAPI-Flappy – kontext projektu

Port Flappy (dB-SOFT 1984, Sharp MZ-800) na Tesla SAPI-1, sestavu V (JPR-1V, RAM-1V, CGA-1V, MPH-1V), jako CP/M
`.COM`. Autor: Martin Lukášek (mlukasek). Komunikace s autorem **česky**.

## Kde co je

- **Začni tady:** `README.md`. Je v něm stav, ovládání, spuštění, paměť a porty originálu i portu, jak je port
  udělaný (grafika, časování, zvuk, klávesnice), ověřování, pasti a nejasnosti k ověření na HW.
- **Zdroj:** `sapi/flappy_sapi.asm` (disassembler originálu, změny označené `SAPI:`), `sapi/platform.asm` (HW
  vrstva), `sapi/tables.asm` a `sapi/colours.asm` (generuje `tools/make_tables.py`, needitovat). Originál
  `SHARP/Flappy.mzf`, jeho disassembler `orig/flappy.asm` (generuje `tools/mkdis.py` s `tools/annot.py`).
- **Emulátory:** `..\SAPIemu` (sestava `machines/sapi1v.sapi`, MCP, dokumentace desek v `docs/desky/`) a
  **mz800emu** Michala Hučíka v `..\mz800emu` (MCP přes pipe, skripty v `tools/mz/` ho spouštějí samy).

## Pravidla

- **Jazyk:** kód a komentáře v asm a skriptech **anglicky**, dokumentace **česky**.
- **Styl asm:** pasmo 0.5.3. Komentáře s adresami MZ (`; 1D46`) zachovat. Každou změnu označit `SAPI:` a popsat,
  co dělal MZ.
- **Adresy originálu se nesmí posunout** (hra má v datech ukazatele, které nejsou návěští). `build.cmd` spouští
  `tools/check_addr.py`: každé návěští originálu musí být na své adrese (úrovně −3000h). Změna v kódu je stejně
  dlouhá, nebo skok na novou rutinu v `platform.asm` (zbytek původní rutiny zůstane jako mrtvý kód).
- **Herní logika se nesmí změnit.** Každou změnu ověřit `tools/compare.py` (obrazovka portu = originál v každém
  kroku, scénáře `title`, `play`, `clear`, `menu`, `keyword`, `ending`).
- **Měřit v emulátoru**, nehádat: `tools/bench.py` (krok hry SAPI 2/4 MHz proti MZ-800).
- **Paměť je těsná:** kód smí končit nejvýš na BFFFh (nad tím CGA-1V), teď končí kolem BC80h. Volné: konec
  pod C000h, zásobník 1500–1BFFh, mrtvý kód MZ 7332–7977h (kromě proměnných 738Dh, 78EBh; je tam `map_buf`).
- **Pasti:** `README.md` (Pasti), pasti pasma v `..\SAPIemu\CLAUDE.md`. Hlavně: lokální návěští `.x` jsou
  globální; hra opouští podprogramy skokem (zásobník roste); `read_memory` nejvýš 4096 B; `cycles` v MCP
  SAPIemu počítá takty 4 MHz.
- **Git:** lokální commity průběžně, push jen na výslovné vyžádání. Na konec commitu řádek Co-Authored-By.
- **Reálný HW:** autor ho má. Otázky k ověření sbírat v README do „Nejasností k ověření na HW“.
- **Disk C: emulátoru** (`..\SAPIemu\work\ide\sapi_hdd.img`) je mimo repo. Hru na něj nahrávat podle README
  (Spuštění) a emulátor pak vypnout přes `power off`, ne zabít.
