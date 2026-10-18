


from .messenger import Messenger
import argparse



from .state import descriptions


class Subtool(Messenger):
    """
    Base class for a subtool.
    """

    def add_arguments(self, parser):
        """
        Define to add arguments to the argument parser.
        This method is overridden by individual subtools.
        """
        pass

    def __init__(self, args, head):
        super().__init__()
        # generic front door for subtools.
        parser = argparse.ArgumentParser(
            description=descriptions[self.name()],
            prog=f"dgcalc {self.name()}",
            epilog="",
        )
        parser.add_argument(
            "-V", "--verbose",
            action="count",
            default=0,
            help="Increase verbosity level (-V: info -VV: debug -VVV: trace)"
        )
        parser.add_argument(
            "-v", "--version",
            action="version",
            # The following line is regex-matched by _F/update_version.py
            version = "dgcalc 0.3.0",
        )
        self.add_arguments(parser)
        # set pargs for main method
        self.pargs = parser.parse_args(args)
        if self.vlevel() > 0:
            head.msg(f"Verbosity level {self.vlevel()}")
            self.verbose = True


    # GENERIC SUBTOOL API:

    def vlevel(self):
        """
        The verbosity level 1: info 2: debug 3: step

        Returns:

            integer
        """
        return self.pargs.verbose

    def name(self):
        return self.__class__.__name__

    def description(self):
        return descriptions[self.name()]


