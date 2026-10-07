# SAPI-Flappy – kontext projektu

Port Flappy (dB-SOFT 1984, Sharp MZ-800) na Tesla SAPI-1, sestavu V (JPR-1V, RAM-1V, CGA-1V, MPH-1V), jako CP/M
`.COM`. Autor: Martin Lukášek (mlukasek). Komunikace s autorem **česky**.

## Kde co je

- `README.md`: pro uživatele (co to je, snímky, spuštění, ovládání, rozdíly proti MZ-800).
- **Pro práci začni v `docs/vyvoj.md`** (jiný počítač, zdroje, nástroje, ověřování, pasti). Dál `docs/port.md`
  (jak je port udělaný, paměť, porty, měření), `docs/original.md` (rozbor originálu MZ-800),
  `docs/rozhodnuti.md` (rozhodnutí s důvody, nové dopisovat), `docs/hw-otazky.md` (ověření na HW).
- **Zdroj:** `sapi/flappy_sapi.asm` (disassembler originálu, změny `SAPI:`), `sapi/platform.asm` (HW vrstva),
  `sapi/tables.asm` a `sapi/colours.asm` (generuje `tools/make_tables.py`, needitovat). Disassembler originálu
  `orig/flappy.asm` (generuje `tools/mkdis.py` s `tools/annot.py`).
- **Emulátory:** **`..\SAPIemu-release`** (SAPIemu 0.3.0-alpha, sestava `machines/sapi1v.sapi`, MCP;
  `tools\emu\sapiemu.cmd`) a **mz800emu** Michala Hučíka v `..\mz800emu` (MCP přes pipe, skripty v `tools/mz/`
  ho spouštějí samy). **Vývojové repo `..\SAPIemu` nepoužívat** (autor ho vyvíjí souběžně), nanejvýš číst
  dokumentaci desek.

## Pravidla

- **Repo je veřejné. Originál `SHARP/Flappy.mzf` nikdy necommitovat** (autorské právo; je v `.gitignore`,
  z historie odstraněný). Lokální větev `backup-pred-odstranenim-mzf` nepushovat.
- **Jazyk:** kód a komentáře v asm a skriptech **anglicky**, dokumentace **česky**.
- **Styl asm:** pasmo 0.5.3. Komentáře s adresami MZ (`; 1D46`) zachovat. Každou změnu označit `SAPI:` a popsat,
  co dělal MZ.
- **Adresy originálu se nesmí posunout** (hra má v datech ukazatele, které nejsou návěští). `build.cmd` spouští
  `tools/check_addr.py`. Změna je stejně dlouhá, nebo skok na novou rutinu v `platform.asm`.
- **Herní logika se nesmí změnit.** Každou změnu ověřit `tools/compare.py` (obrazovka portu = originál v každém
  kroku, scénáře `title`, `play`, `clear`, `menu`, `keyword`, `ending`).
- **Měřit v emulátoru**, nehádat: `tools/bench.py` (krok hry SAPI 2/4 MHz proti MZ-800).
- **Paměť je těsná:** kód smí končit nejvýš na BFFFh (nad tím CGA-1V), teď končí na BC90h. Volné místo viz
  `docs/port.md`.
- **Pasti:** `docs/vyvoj.md` (Pasti). Hlavně: lokální návěští `.x` jsou globální; hra opouští podprogramy
  skokem (zásobník roste); `read_memory` nejvýš 4096 B; `cycles` v MCP SAPIemu počítá takty 4 MHz.
- **Dokumentace:** důležité poznatky zapisovat do `docs/` (na projektu se pracuje z více počítačů).
- **Git:** lokální commity průběžně, push jen na výslovné vyžádání. Na konec commitu řádek Co-Authored-By.
- **Reálný HW:** autor ho má, port na něm ověřil 2026-10-07 (verze 1.0.0). Nové otázky k ověření sbírat
  v `docs/hw-otazky.md`.
- **Vydání:** verze v `README.md`, poznámky v `docs/release-notes/`, tag `vX.Y.Z`, na GitHubu Release
  s `FLAPPY.COM` a `FLAPPY.HEX` (postup v `docs/vyvoj.md`).
- **Disk C: emulátoru** (`..\SAPIemu-release\work\ide\sapi_hdd.img`) je mimo repo. Hru na něj nahrávat podle
  `docs/vyvoj.md` a emulátor pak vypnout přes `power off`, ne zabít.
