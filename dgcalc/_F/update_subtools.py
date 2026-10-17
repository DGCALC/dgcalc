



from pathlib import Path
import os
import re


dir_path = Path("../dgcalc/dgcalc/clt/subtools")
init = '__init__.py'


subtools = [f.name.split('.')[0] for f in dir_path.iterdir() if f.is_file() and f.name != init and f.name != '.DS_Store']
print(f"[update_subtools] found subtools: {','.join(subtools)}")


print(f"[update_subtools] Writing to subtools/__init__.py...")

with open(os.path.join(dir_path, init), 'w') as f:
    f.write("__all__ = [\n")
    for fn in subtools:
        f.write(f'    "{fn}",\n')
    f.write("]\n\n")
    for fn in subtools:
        f.write(f'from .{fn} import {fn}\n')

print(f"[update_subtools] Writing to head.py...")


dir_path2 = Path("../dgcalc/dgcalc/clt/")

injectee = "\n###(subtools)\nfrom .subtools import (\n"
for fn in subtools:
    injectee += f"    {fn},\n"
injectee += ")\nsubtools = {\n"
for fn in subtools:
    injectee += f"    '{fn}': {fn},\n"
injectee += "}\n###(subtools)\n"

with open(os.path.join(dir_path2, 'head.py'), 'r') as f:
    content = f.read()

groups = re.split("\n###\(subtools\)\n", content)
if len(groups) != 3:
    print("[update_subtools] while scanning head.py: Could not locate subtool lists. Exiting...")
    exit(0)
content = groups[0] + injectee + groups[2]

with open(os.path.join(dir_path2, 'head.py'), 'w') as f:
    f.write(content)


# todo - add an entry to descriptions: '{fn}: "to do"'

print(f"[update_subtools] Done.")
