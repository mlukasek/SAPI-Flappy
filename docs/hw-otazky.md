# Nejasnosti k ověření na skutečném hardwaru

Port je zatím vyzkoušený jen v SAPIemu 0.3.0-alpha. Na skutečném SAPI-1 ověřit:

- **CGA-1V v režimu CGA** (CONFIG = 04h, D2 = 1) s COLMASK 11h: barva bodu podle obou půlbajtů (horní =
  rovina I → index +1, dolní = rovina II → index +16), paleta na položkách 0, 1, 16, 17. Program CGATEST
  režim CGA netestuje, používá ho jen REMBRAN2.
- **Přerušení F2 z MPH-1V** přes /INT0 na JPR-1V v IM 1 (RST 38h), potvrzení IACK (`OUT 55h,80h`), IEN A8h.
  JPR-1V nemá obvod pro vektor, v IM 1 to nevadí.
- **Vnořené přerušení** během hudby (obsluha povolí přerušení) – v emulátoru v pořádku, na HW jen potvrdit.
- **Stav T0** (STATUS D3) čítače 0 v režimu 3 pro zpoždění (4,005 ms).
- **Klávesnice Consul 262.3 bez 7474** (STROBE jen 1 ms): čte se v přerušení každých 2,16 ms, při každém čtení
  sloupce hrou a v čekání. Neztratí se stisk, když přerušení s novými notami trvá při 2 MHz až 8,6 ms?
  (SAPIemu klávesu, kterou program během pulzu vůbec nečetl, pošle znovu; skutečný Consul ne.)
- **ACK klávesnice** (`OUT 01h,03h`) s Consulem bez 7474 a s EKL-1 na JPR-1V (stejné jako v Bombermanovi).
- **Barvy:** paleta je převzatá z mz800emu (`tools/make_tables.py`), skutečné MZ-800 může mít jiné odstíny.
- **Zvuk:** YM3812 (3,3 µs po adrese, 23 µs po datech) a jak zní nástroj místo obdélníku PSG; šum.
- **Rychlost:** krok hry 220,7 ms při 2 i 4 MHz (emulátor), práce kroku při 2 MHz asi 60 ms ze 110 ms.
- **Čekací stavy CGA-1V** při kreslení (emulace je přibližná, viz `..\SAPIemu-release\docs\desky\CGA-1V.md`).
