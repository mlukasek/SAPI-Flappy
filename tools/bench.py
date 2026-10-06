#!/usr/bin/env python3
"""Game step timing: ms between arrivals at main_loop (20B1h), SAPI port vs MZ-800 original.

The game waits for interrupt ticks (wait_ticks), so a step lasts tick_div ticks
(2 x 2.29 ms x tick_div) as long as its work fits in. Longer steps = the port is too slow.
Also the work of a step: ms from main_loop to the first wait for ticks (wait_ticks 2217h).

  bench.py [--steps N] [--turbo] [--mz]
"""
import argparse, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'emu'))
sys.path.insert(0, os.path.join(HERE, 'mz'))
import sapimcp as sm

ROOT = os.path.normpath(os.path.join(HERE, '..'))
MAIN_LOOP = 0x20B1
WAIT = 0x2217


def sapi(steps, turbo):
    sm.call('pause')
    sm.call('load_state', name='cpm')
    sm.call('cpu_turbo', on=turbo)
    sm.call('load_binary', address='0100', path=os.path.join(ROOT, 'build', 'flappy.com'))
    sm.call('set_registers', pc='0100')
    sm.call('run_for', ms=4000)
    sm.call('joystick', pressed=['fire1'])
    run = lambda a: sm.call('run_until', address='%04X' % a, timeout_ms=10000)['cycles']
    run(MAIN_LOOP)
    sm.call('joystick', pressed=[])
    out = []
    for i in range(steps):
        if i % 20 == 5:
            sm.call('joystick', pressed=[['right', 'left', 'down', 'up'][(i // 20) % 4]])
        c0 = run(MAIN_LOOP)
        c1 = run(WAIT)
        c2 = run(MAIN_LOOP)
        out.append(((c2 - c0) / 4000, (c1 - c0) / 4000))
        sm.call('run_until', address='%04X' % MAIN_LOOP, timeout_ms=10000)
    sm.call('joystick', pressed=[])
    return out


def mz(steps):
    from mzemu import Emu
    e = Emu()
    try:
        e.load_mzf()
        e.run_until(0x2000)
        e.run_frames(250)
        e.press('SPACE')
        e.run_frames(5)
        e.release('SPACE')
        cyc = lambda: e.data('get_raster_pos')['total_cycles']
        e.run_until(MAIN_LOOP)
        out = []
        for i in range(steps):
            e.run_until(MAIN_LOOP)
            c0 = cyc()
            e.run_until(WAIT)
            c1 = cyc()
            e.run_until(MAIN_LOOP)
            c2 = cyc()
            out.append(((c2 - c0) / 3546.9, (c1 - c0) / 3546.9))
        return out
    finally:
        e.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--steps', type=int, default=30)
    ap.add_argument('--turbo', action='store_true')
    ap.add_argument('--mz', action='store_true')
    a = ap.parse_args()
    r = mz(a.steps) if a.mz else sapi(a.steps, a.turbo)
    step = sorted(x[0] for x in r)
    work = sorted(x[1] for x in r)
    print('step ms: min %.1f median %.1f max %.1f' % (step[0], step[len(step) // 2], step[-1]))
    print('work until the first wait ms: min %.1f median %.1f max %.1f' % (work[0], work[len(work) // 2], work[-1]))


if __name__ == '__main__':
    main()
