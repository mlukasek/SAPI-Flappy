# Ověření na skutečném hardwaru

**2026-10-07: autor ověřil, že port funguje na skutečném SAPI-1 v sestavě V** (JPR-1V, RAM-1V, CGA-1V,
MPH-1V). Hra na železe funguje, tím se potvrdilo i to, na čem stojí a co bylo do té doby ověřené jen
v SAPIemu:

- CGA-1V v režimu CGA (CONFIG = 04h) s COLMASK 11h: barva bodu podle obou půlbajtů, paleta na položkách 0, 1,
  16, 17;
- přerušení F2 z MPH-1V přes /INT0 na JPR-1V v IM 1 (RST 38h), IACK, IEN A8h, vnořené přerušení během hudby;
- zpoždění podle stavu T0 čítače 0;
- čtení klávesnice (STROBE, ACK);
- zvuk na YM3812.

Podrobnosti (typ klávesnice, takt CPU, joystick) nejsou zapsané; když se zjistí, doplnit sem.

## Poznámky

- Barvy jsou převzaté z mz800emu (`tools/make_tables.py`); jestli odpovídají skutečnému MZ-800, je otázka
  originálu, ne SAPI.
- Nové otázky k ověření na HW psát sem.
