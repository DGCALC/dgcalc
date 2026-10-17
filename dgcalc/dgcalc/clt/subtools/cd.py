






from ..subtool import Subtool
import os

class cd(Subtool):
    """

    """

    def add_arguments(self, parser):
        parser.add_argument(
            "path",
            metavar="path",
            type=str,
            help="Destination dgcalc path",
        )

    def __init__(self, args, head):
        super().__init__(args, head)
        self.msg(self.pargs)
        self.msg(head.cw.w)
        self.msg(head.cw.p)

