#!/usr/bin/env python3
"""Run the original Flappy in mz800emu with the Code/Data Logger on and export it.

Covers the title / attract loop and then plays with pseudo-random input.
Usage: cdl_run.py OUT_DIR [--title N] [--play N] [--seed S]
"""
import argparse, os, random
from mzemu import Emu

KEYS = ['LEFT', 'RIGHT', 'UP', 'DOWN', 'SPACE']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out')
    ap.add_argument('--title', type=int, default=3000)
    ap.add_argument('--play', type=int, default=6000)
    ap.add_argument('--seed', type=int, default=1)
    a = ap.parse_args()
    rnd = random.Random(a.seed)
    out = os.path.abspath(a.out)
    os.makedirs(out, exist_ok=True)
    e = Emu()
    try:
        e.load_mzf()
        e.run_until(0x2000)
        e.data('cdl_reset')
        e.data('cdl_start')
        e.run_frames(a.title)
        e.screenshot(os.path.join(out, 'title.png'))
        done = 0
        shot = 0
        while done < a.play:
            k = rnd.choice(KEYS + ['SPACE', None])
            n = rnd.randint(5, 60)
            if k:
                e.press(k)
            e.run_frames(n)
            if k:
                e.release(k)
            done += n
            if done // 1000 != shot:
                shot = done // 1000
                e.screenshot(os.path.join(out, 'play%02d.png' % shot))
        e.data('cdl_stop')
        print(e.data('cdl_export', {'path': os.path.join(out, 'flappy.json')}))
    finally:
        e.close()


if __name__ == '__main__':
    main()
