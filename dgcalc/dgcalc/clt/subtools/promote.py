





from ..subtool import Subtool

class promote(Subtool):
    """

    """
    def add_arguments(self, parser):
        # todo wip
        parser.add_argument(
            "type",
            metavar="type",
            type=str,
            help="Type of object to create",
        )
        parser.add_argument(
            "name",
            metavar="name",
            type=str,
            help="Name of object to create",
        )


    def __init__(self, args, head):
        super().__init__(args, head)
        self.msg(self.pargs)
        self.msg(head.cw.w)
        self.msg(head.cw.p)
