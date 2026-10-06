#!/usr/bin/env python3
"""Drive mz800emu (Michal Hucik) headless over its JSONL pipe transport.

Used to run the original MZ-800 Flappy: code/data logging, screenshots,
reference runs for comparing the SAPI port. Emulator path: MZ800EMU
(default E:\\SAPI_GIT\\mz800emu\\mz800emu.exe).
"""
import base64, json, os, subprocess, time

EMU = os.environ.get('MZ800EMU', r'E:\SAPI_GIT\mz800emu\mz800emu.exe')
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
MZF = os.path.join(ROOT, 'SHARP', 'Flappy.mzf')


class Emu:
    def __init__(self, exe=EMU, extra=()):
        work = os.path.join(ROOT, 'build', 'mzemu')
        os.makedirs(work, exist_ok=True)
        self.errlog = open(os.path.join(work, 'stderr_%d.log' % os.getpid()), 'w')
        self.p = subprocess.Popen([exe, '--mcp-pipe', '--headless', '--no-first-run-windows',
                                   '--cfg-dir', work, '--no-save-ini', *extra],
                                  stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                  stderr=self.errlog, text=True, bufsize=1,
                                  cwd=os.path.dirname(exe))
        self.req_id = 0
        self.hello = json.loads(self.p.stdout.readline())
        for _ in range(100):
            if self.call('get_state', check=False).get('success'):
                break
            time.sleep(0.1)

    def call(self, cmd, data=None, check=True):
        self.req_id += 1
        req = {'req_id': self.req_id, 'cmd': cmd}
        if data is not None:
            req['data'] = data
        self.p.stdin.write(json.dumps(req) + '\n')
        self.p.stdin.flush()
        while True:
            line = self.p.stdout.readline()
            if not line:
                raise RuntimeError('emulator exited (%s)' % self.p.poll())
            r = json.loads(line)
            if r.get('type') == 'response' and r.get('req_id') == self.req_id:
                break
        if check and not r.get('success'):
            raise RuntimeError(f'{cmd}: {r.get("error")}')
        return r

    def data(self, cmd, data=None):
        return self.call(cmd, data).get('data')

    def close(self):
        try:
            self.call('shutdown', check=False)
        except Exception:
            pass
        try:
            self.p.stdin.close()
            self.p.wait(timeout=5)
        except Exception:
            self.p.kill()

    # ---- helpers
    def load_mzf(self, path=MZF, speed='max'):
        hdr = open(path, 'rb').read(128)
        exec_addr = hdr[22] | (hdr[23] << 8)
        self.call('pause')
        self.data('media_load_mzf', {'path': os.path.abspath(path)})
        self.data('set_register', {'reg': 'SP', 'value': 0x10F0})
        self.data('set_register', {'reg': 'PC', 'value': exec_addr})
        if speed:
            self.call('set_speed', {'mode': speed}, check=False)
        return exec_addr

    def run_frames(self, n):
        out = None
        while n > 0:
            k = min(n, 1000)
            out = self.data('run', {'frames': k})
            n -= k
        return out

    def wait_stopped(self):
        while True:
            s = self.call('get_state', check=False)
            if s.get('success') and not s['data'].get('running'):
                return
            time.sleep(0.001)

    def run_until(self, addr, max_cycles=200_000_000):
        for _ in range(200):
            r = self.call('run_until_addr', {'addr': addr, 'max_cycles': max_cycles}, check=False)
            if r.get('success'):
                break
            time.sleep(0.005)
        else:
            raise RuntimeError('run_until_addr refused: ' + str(r.get('error')))
        while True:
            s = self.call('get_state', check=False)
            if s.get('success') and not s['data'].get('running'):
                r = self.call('get_registers', check=False)
                if r.get('success'):
                    return r['data']
            time.sleep(0.001)

    def regs(self):
        return self.data('get_registers')

    def poke(self, addr, data):
        if isinstance(data, int):
            data = bytes([data])
        return self.data('mem_write', {'addr': addr, 'data_hex': bytes(data).hex()})

    def peek(self, addr, n=1):
        d = self.data('mem_read', {'addr': addr, 'len': n})
        return base64.b64decode(d['data_b64'])

    def press(self, key):
        return self.data('input_press_key', {'key': key})

    def release(self, key=''):
        return self.data('input_release_key', {'key': key})

    def screenshot(self, path):
        return self.data('screenshot_save_to_file', {'path': os.path.abspath(path), 'format': 'png'})
