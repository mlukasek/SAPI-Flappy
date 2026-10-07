# Rozhodnutí a poznatky

Nové rozhodnutí vždy dopsat sem, s datem a důvodem.

## Postup portu (2026-10-06)

- **Disassembler a úprava zdroje, ne binární záplaty.** Hra nemá zdroják; disassembler (`tools/mkdis.py`)
  spojuje rekurzivní průchod s CDL z mz800emu (co se opravdu provedlo) a přeloží se bajt po bajtu stejně.
  Port je čitelný zdroj se změnami `SAPI:`, jako u Bombermana.
- **Adresy originálu se nemění.** Data hry obsahují ukazatele, které disassembler nepozná (tabulky, struktury
  objektů); posun kódu by je rozbil. Změny jsou stejně dlouhé nebo skok do platformy, `check_addr.py` to
  hlídá. Přemístily se jen úrovně (B000h → 8000h, odkazy jen přes `stage_count`/`stage_data`) a buffery mimo
  obraz (mapa, zásobník, vektory FA00h).
- **Adresy VRAM MZ zůstávají v datech hry**, převádí je až platforma (C000h + 2 × posun). Hra s nimi počítá
  (souřadnice, objekty) a jinak než kreslicími rutinami do VRAM nesahá.
- **Kreslicí rutiny se nahrazují celé**, ne emulací GDG po bajtech: dlaždice a písmo by byly pomalé. Obecná
  emulace WF (`vw_hl`) jen pro vzácné zápisy (rámečky, vzory).
- **Tabulky převodu bodů za běhu, ne předpřevedená grafika.** Předpřevod by potřeboval znát rozměry všech
  dlaždic (stejná data se kreslí i jako vzor, např. 5C5Dh) a paměť navíc. Za běhu je to při 2 MHz dost
  rychlé (60 ms práce ze 110 ms).
- **CGA-1V v režimu CGA** (2 bity na bod), ne EGA: 4 barvy na bod jako MZ-800, jeden bajt MZ = dva bajty CGA,
  adresa jde spočítat posunem.

## Paměť (2026-10-06)

- `.COM` od 0100h do BFFFh, CGA-1V na C000h je namapovaná celou hru; CP/M pod ní zůstává, ESC vrací do CP/M.
- **Mapa (880 B) v mrtvém kódu MZ 7332–7977h** (nevolaný ovladač zvuku): za kódem už nebylo místo. Proměnné
  738Dh a 78EBh v tom bloku jsou živé, mapa je mezi nimi (7390–76FFh).
- **Zásobník 1,7 KB** (1500–1BFFh): hra opouští podprogramy skokem a s drženou klávesou zásobník roste
  (v menu se dostal o 1,3 KB, když test držel CR).

## Časování (2026-10-06)

- **Pevný tik 2,163 ms** (82C54, 121), průměr originálu ve hře. Originál má periodu závislou na délce
  obsluhy (nabíjí 8253 až na jejím konci), v titulku 2,33 ms. Napodobit to přesně by závislo na taktu CPU
  (2/4 MHz, přepínatelné za chodu). Hra tak běží stejně rychle, hudba v titulku o 7 % rychleji.
- **Tik se počítá na vstupu přerušení, hudba běží s povoleným přerušením.** Hudba (interpret MML) trvá při
  2 MHz až 8,6 ms; dřív se tiky ztrácely (potvrzení F2 až na konci smazalo nový tik) a hra byla o 8 %
  pomalejší. Vnořené přerušení jen přičte tik (`isr_busy`).
- **Zpoždění podle čítače 0** (T0), ne busy smyčkou: nezávisí na taktu a funguje i se zakázaným přerušením
  (původní `delay` se volá i v DI).

## Zvuk (2026-10-06)

- SN76489 → YM3812 napodobením registrů PSG (`psg_write` na místě `OUT (0F2h),A`), hudební ovladač hry zůstal
  beze změny. F-number dělením (konstanta K), ne tabulkou (2 KB by se nevešly).
- Dělitel N < 18 = ticho (hra má N = 1 jako pauzu; na YM3812 by to bylo pískání 6 kHz).

## Klávesnice (2026-10-06 a 07)

- **Napodobení matice MZ** (`kbd_row` místo `OUT (0D0h)` + `IN (0D1h)`), ne úprava herní logiky: hra si
  klávesy čte sama, stejně jako na MZ (menu, heslo, F-klávesy, BREAK).
- **Klávesa drží, dokud ji hra nepřečte** (+17 ms), protože klávesnice SAPI nehlásí puštění:
  - pevná doba nefungovala: 100 ms dávalo v hesle písmena dvakrát (menu čte každých 60 ms), kratší doba by
    ve hře stisk přehlédla (vstup se čte jednou za 220 ms);
  - „přečte“ se pozná podle volající rutiny (návratová adresa): `read_key` pro znaky, `read_dir` mimo
    `wait_ticks` a `input_hook` pro pohyb;
  - +17 ms, protože menu čte klávesu v jednom kole dvakrát (3727h a 3885h).
- **Jeden stisk šipky = jeden krok** (8 bodů) jako krátký stisk na MZ; plynulý pohyb dává autorepeat nebo
  joystick. Úprava „dojít na celé políčko“ (jako v Bombermanovi) zatím ne: v Flappy se stojí i na půlce.
- **SHIFT podle kódu SAPI** (malá písmena, `!`–`)`): hesla rozlišují velikost písmen.
- **F-klávesy jako Ctrl+písmeno** (a Consul ROL, COPY, 61–63): na klávesnicích SAPI nejsou; Ctrl+D/E/S/X
  nejdou, jsou to šipky EKL-1 (WordStar).
- **STROBE se čte jen jednou** (2026-10-07): druhé čtení hned po prvním mohlo pulz Consulu (1 ms) minout
  a klávesa se ztratila (první písmeno hesla). SAPIemu se chová věrně, chyba byla v portu.

## Ověřování (2026-10-06)

- **Porovnání obrazovek s originálem v každém kroku** (`compare.py`) místo porovnání se starou verzí portu:
  ověřuje rovnou správnost převodu grafiky i herní logiky. Determinismus: stejná náhoda (LFSR), vstup přes
  testovací bajty, synchronizace na čekání na tiky (počet tiků mezi body se v emulátorech liší, logika ne).
- Hudba se mezi emulátory porovnat nedá (běží na tiky nezávisle na krocích hry), proto zvlášť `sound_check.py`
  a test `ym_fnum` proti Pythonu.

## Repozitář (2026-10-07)

- Repo je veřejné. **`SHARP/Flappy.mzf` (originál) byl odstraněn z celé historie** (`git filter-branch`,
  force push) a je jen lokálně (`.gitignore`). Lokálně zůstala záložní větev `backup-pred-odstranenim-mzf`
  se starou historií (nepushovat).
- Testy a ladění portu běží na **SAPIemu-release** (0.3.0-alpha), ne na vývojovém repu `SAPIemu`, které autor
  souběžně vyvíjí.
- Zdrojáky (`orig/flappy.asm`, `sapi/flappy_sapi.asm`, obsahují celý program hry) zůstávají ve veřejném repu,
  rozhodl autor (Flappy je klasika, volně dostupná). Necommituje se jen soubor originálu MZF.

## Vydání 1.0.0 (2026-10-07)

- Autor ověřil port na skutečném SAPI-1 v sestavě V (`docs/hw-otazky.md`).
- Vydání 1.0.0: tag `v1.0.0`, GitHub Release s `FLAPPY.COM` a `FLAPPY.HEX` (`docs/release-notes/v1.0.0.md`).
  Kód je stejný jako v portu ověřeném porovnáním s originálem (všechny scénáře `compare.py`).
