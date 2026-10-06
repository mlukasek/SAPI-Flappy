#!/usr/bin/env python3
"""Coverage scenarios for the original Flappy in mz800emu (CDL export per scenario).

cover.py SCEN [SCEN...]  -> build/cdl_<scen>/flappy.json + screenshots
Scenarios use pokes into game variables (addresses of the MZ-800 original):
  5C1B stage, B000 number of stages, 2246 stage clear flag, 502F lives, 3F32 time.
"""
import os, random, sys
from mzemu import Emu, ROOT

KEYS = ['LEFT', 'RIGHT', 'UP', 'DOWN', 'SPACE', 'SPACE', None]


class Run:
    def __init__(self, name, seed=1):
        self.name = name
        self.out = os.path.join(ROOT, 'build', 'cdl_' + name)
        os.makedirs(self.out, exist_ok=True)
        self.e = Emu()
        self.rnd = random.Random(seed)
        self.shots = 0
        self.e.load_mzf()
        self.e.run_until(0x2000)
        self.e.data('cdl_reset')
        self.e.data('cdl_start')

    def shot(self, tag=''):
        self.e.screenshot(os.path.join(self.out, '%02d%s.png' % (self.shots, tag)))
        self.shots += 1

    def frames(self, n):
        self.e.run_frames(n)

    def key(self, k, n=10):
        self.e.press(k)
        self.e.run_frames(n)
        self.e.release(k)

    def play(self, n):
        done = 0
        while done < n:
            k = self.rnd.choice(KEYS)
            t = self.rnd.randint(5, 60)
            if k:
                self.e.press(k)
            self.e.run_frames(t)
            if k:
                self.e.release(k)
            done += t

    def start_game(self):
        self.frames(300)
        self.key('SPACE')
        self.frames(200)

    def finish(self):
        self.e.data('cdl_stop')
        self.e.data('cdl_export', {'path': os.path.join(self.out, 'flappy.json')})
        self.e.close()


def scen_attract(r):
    for _ in range(12):
        r.frames(500)
        r.shot()


def scen_clear(r):
    r.start_game()
    r.play(500)
    r.shot('play')
    r.e.poke(0x2246, 1)
    for _ in range(8):
        r.frames(150)
        r.shot('clear')
    r.play(500)
    r.shot('stage2')


def scen_ending(r):
    r.start_game()
    n = r.e.peek(0xB000)[0]
    r.e.poke(0x5C1B, n)
    r.e.poke(0x2246, 1)
    for _ in range(20):
        r.frames(250)
        r.shot('end')
    r.key('SPACE')
    r.frames(500)
    r.shot('after')


def scen_gameover(r):
    r.start_game()
    r.e.poke(0x502F, 1)
    r.e.poke(0x3F32, b'\x05\x00')
    for _ in range(4):
        r.frames(200)
        r.shot('over')
    for _ in range(10):
        r.key('CR', 5)
        r.frames(50)
    r.shot('menu')
    for k in ('F1', '3', 'F1', '9', 'F2', 'S', 'H', 'I', 'B', 'A', 'CR', 'F2', 'X', 'Y', 'Z', 'Q', 'W', 'CR'):
        r.key(k)
        r.frames(60)
        r.shot(k)
    r.frames(300)
    r.key('CR')
    for _ in range(10):
        r.frames(300)
        r.shot('demo')
    r.key('SPACE')
    r.frames(300)
    r.shot('game')


def scen_fkeys(r):
    r.start_game()
    for k in ('F1', 'F2', 'F3', 'F4', 'F5'):
        r.key(k, 20)
        r.play(300)
        r.shot(k)
    r.key('ESC', 20)
    r.frames(500)
    r.shot('esc')


SCEN = {'attract': scen_attract, 'clear': scen_clear, 'ending': scen_ending,
        'gameover': scen_gameover, 'fkeys': scen_fkeys}


def main():
    for name in sys.argv[1:]:
        r = Run(name)
        try:
            SCEN[name](r)
        finally:
            r.finish()
        print(name, 'done')


if __name__ == '__main__':
    main()
