



from .messenger import Messenger
from .cw import CW
from .subtool import Subtool
###(subtools)
from .subtools import (
    cd,
    config,
    cwd,
    get,
    home,
    install,
    ls,
    make,
    new,
    promote,
    run,
    source,
)
subtools = {
    'cd': cd,
    'config': config,
    'cwd': cwd,
    'get': get,
    'home': home,
    'install': install,
    'ls': ls,
    'make': make,
    'new': new,
    'promote': promote,
    'run': run,
    'source': source,
}
###(subtools)


class Head(Messenger):
    """
    `dgcalc` tool Head instance.
    Propagates command line arguments to
    the appropriate subtool.

    Arguments:

        args (list of string):
            command line arguments

    """

    def __init__(
            self,
            args,
    ):
        super().__init__()
        not_ok_msg = None
        self.cw = CW(head=self)
        try:
            self.cw.init(head=self, clean=False)
        except FileNotFoundError as e:
            not_ok_msg = f"Error: The file '{e.filename}' was not found."
        except PermissionError as e:
            not_ok_msg = f"Error: You do not have permission to read '{e.filename}'."
        except Exception as e:
            not_ok_msg = f"An unexpected error occurred: {e}"
        if not_ok_msg:
            try:
                self.cw.init(head=self, clean=True)
            except Exception as e:
                self.msg(f"An error occured during loading: {not_ok_msg}")
                self.msg(f"After this error, a critical error occurred: {e}")
                exit(0)
        if len(args) <= 1:
            # print help message if called with no arguments
            args.append('-h')
        modifiers = []
        found = False
        for i in range(1,len(args)):
            arg = args[i]
            if arg not in subtools:
                modifiers.append(arg)
            else:
                subtools[arg](args=modifiers+args[i+1:], head=self)
                found = True
        if not found:
            _ = Subtool(args=args[1:], head=self)


