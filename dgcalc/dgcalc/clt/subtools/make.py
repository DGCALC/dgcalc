




from ..subtool import Subtool
from ..post_sys import create_dir, create_stem, ttyRead

import subprocess


class make(Subtool):
    """
    Build a project, very similar to the role of the original `make` tool.

    dgcalc make

    """
    def add_arguments(self, parser):
        parser.add_argument(
            "type",
            metavar="type",
            type=str,
            help="Type of object to create",
        )

    def __init__(self, args, head):
        super().__init__(args, head)
        self.msg(self.pargs)
        self.msg(head.cw.w)
        self.msg(head.cw.p)
        if self.pargs.build_dir == "None_Specified":
            subprocess.run(['cmake', '-S', '.', '--fresh'])
        elif self.pargs.build_dir == 'make':
            # todo generalize
            imm_pred = 'build'
            subprocess.run(['cmake', '-B', imm_pred, '-S', '.', '--fresh'])
            subprocess.run(['cmake', '--build', imm_pred, '--target', 'main', '--parallel'])
        else:
            subprocess.run(['cmake', '-B', self.pargs.build_dir, '-S', '.', '--fresh'])





