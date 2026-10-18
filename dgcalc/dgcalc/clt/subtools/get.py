




from ..subtool import Subtool
from ..post_sys import create_dir, create_stem, ttyRead

import os
import argparse
import subprocess


class get(Subtool):
    """
    Pull dgcalc groups onto the local system.

    dgcalc get <group_list>

    """
    def add_arguments(self, parser):
        parser.add_argument(
            "group_list",
            metavar="group",
            nargs=argparse.REMAINDER,
            type=str,
            help="Groups to get",
        )
        # todo this should update DGCALC_HOME, this will be done soon.

    def __init__(self, args, head):
        super().__init__(args, head)
        # self.msg(self.pargs)
        # self.msg(head.cw.w)
        # self.msg(head.cw.p)
        for group in self.pargs.group_list:
            self.msg(group)
            self.vmsg(f"git clone https://github.com/{group}/.github.git")
            subprocess.run(["git", "clone", "--recurse-submodules", f"https://github.com/{group}/.github.git", group])




