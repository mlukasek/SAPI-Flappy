"""shot.py OUT.png: screenshot of the CGA-1V of the running SAPIemu."""
import base64, sys
import sapimcp as m
s = m.call('screenshot', display='CGA-1V')
for c in s:
    if isinstance(c, dict) and c.get('data'):
        open(sys.argv[1], 'wb').write(base64.b64decode(c['data']))
