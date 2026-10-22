












from ..subtool import Subtool
import os

class collect(Subtool):
    """
    Collect projects on systems where only pure runs
    are needed.

    collect <project_list>
    """
    def add_arguments(self, parser):
        # todo lsw vs. lsp
        parser.add_argument(
            "path",
            nargs="?",
            help="File path. If missing, cwp is used."
        )

    def __init__(self, args, head):
        super().__init__(args, head)
        self.msg(self.pargs)
        self.msg(head.cw.w)
        self.msg(head.cw.p)

