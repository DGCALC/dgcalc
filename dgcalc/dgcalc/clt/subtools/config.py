




from ..subtool import Subtool

import subprocess


class config(Subtool):
    """
    Configure a project.
    This is a CMake prerequite to building (i.e., making) the project.
    It is a similar operation to Autotools `configure`,
    and performs steps that will speed up the building step.

    dgcalc config <build-dir (optional)>

    """
    def add_arguments(self, parser):
        parser.add_argument(
            "build_dir",
            metavar="stem",
            type=str,
            default="None_Specified",
            help="Name of build directory",
        )

    def __init__(self, args, head):
        super().__init__(args, head)
        # self.msg(self.pargs)
        # self.msg(head.cw.w)
        # self.msg(head.cw.p)
        if self.pargs.build_dir == "None_Specified":
            subprocess.run(['cmake', '-S', '.', '--fresh'])
        elif self.pargs.build_dir == 'make':
            # todo generalize
            imm_pred = 'build'
            subprocess.run(['cmake', '-B', imm_pred, '-S', '.', '--fresh'])
            subprocess.run(['cmake', '--build', imm_pred, '--target', 'main', '--parallel'])
        else:
            subprocess.run(['cmake', '-B', self.pargs.build_dir, '-S', '.', '--fresh'])




