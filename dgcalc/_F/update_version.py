

import os
import re
from pathlib import Path

# Assumed: This file ends with <version>/dgcalc/_F
# Assumed: no alpha or beta SemVer.
path = Path(os.path.abspath('.'))
components = path.parts
version = components[-3]
if not bool(re.match(r"^[0-9.]+$", version)):
    print(f"[update_version] {version} is not a valid version for this script. No action taken.")
    exit(0)


print(f"[update_version] Found version {version}...")

print("[update_version] Updating pyproject.toml...")


fname = 'pyproject.toml'
fname = os.path.join("..", fname)
with open(fname, 'r') as f:
    content = f.read()

content = re.sub('\nversion\s*=\s*"([.\d]+)"', f'\nversion = "{version}"', content)

with open(fname, 'w') as f:
    f.write(content)

print("[update_version] Updating subtool.py...")

fname = 'subtool.py'
fname = os.path.join('../dgcalc/dgcalc/clt/', fname)
with open(fname, 'r') as f:
    content = f.read()

content = re.sub('version\s*=\s*"dgcalc ([.\d]+)"', f'version = "dgcalc {version}"', content)

with open(fname, 'w') as f:
    f.write(content)

print("[update_version] Done.")

