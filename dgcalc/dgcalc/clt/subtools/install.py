



from ..subtool import Subtool
import os

class install(Subtool):
    """
    Install a part.
    """
    def add_arguments(self, parser):
        # todo optional argument,
        #  if missing use cwp
        pass

    def __init__(self, args, head):
        super().__init__(args, head)
        self.msg(self.pargs)
        self.msg(head.cw.w)
        self.msg(head.cw.p)
