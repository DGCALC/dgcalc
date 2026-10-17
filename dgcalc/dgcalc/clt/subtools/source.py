






from ..subtool import Subtool
from ..post_sys import create_dir, create_stem, ttyRead

from pathlib import Path

import os
import shutil


class source(Subtool):
    """
    Print the current working directory for the `dgcalc` tool.

    dgcalc source <name>

    """
    def add_arguments(self, parser):
        parser.add_argument(
            "name",
            metavar="name",
            type=str,
            help="Name of source to fetch",
        )

    def __init__(self, args, head):
        super().__init__(args, head)
        # location in the dgcalc source tree
        src = Path(os.path.abspath(__file__)).parents[2] / "src"
        if self.pargs.name == '1':
            # maneuver through the dgcalc source tree
            definitions = src / "dgcalc.definitions.cmake"
            accel1 = src / "dgcalc.accel.1.cmake"
            try:
                # fname
                with open(definitions, 'r') as f:
                    content = f.read()
                with open(accel1, 'r') as f:
                    content += f.read()
            except:
                self.msg("Could not read files.")
            self.msg_raw(content)
        elif self.pargs.name == '2':
            gatherpkgs = src / "dgcalc.gatherpkgs.cmake"
            gatherlocal = src / "dgcalc.gatherlocal.cmake"
            runtargets = src / "dgcalc.runtargets.cmake"
            accel2 = src / "dgcalc.accel.2.cmake"
            # fname
            try:
                with open(gatherpkgs, 'r') as f:
                    content = f.read()
                with open(gatherlocal, 'r') as f:
                    content += f.read()
                with open(runtargets, 'r') as f:
                    content += f.read()
                with open(accel2, 'r') as f:
                    content += f.read()
            except:
                self.msg("Could not read files.")
            self.msg_raw(content)
        else:
            self.msg(f'unrecognized argument {self.pargs.name}')




