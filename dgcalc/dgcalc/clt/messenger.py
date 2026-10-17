




from ..ossys.ossys import (
    ttyRead
)

class Messenger:
    """
    Base class for all message-capable classes.
    """

    def __init__(self, verbose = False):
        self.prompt = "[dgcalc>" if self.__class__.__name__ == 'Head' else f"[dgcalc:{self.__class__.__name__}>"
        self.verbose = verbose

    def msg(self, msg, always = True):
        """Generic message utility"""
        if always or self.verbose:
            print(f"{self.prompt} {msg}", flush=True)

    def msg_raw(self, msg):
        """Raw message utility"""
        print(msg, flush=True)

    def vmsg(self, msg):
        """Verbose-only message."""
        self.msg(msg, always=False)

    @staticmethod
    def asktoproceed():
        print("Proceed? (y/n)", end="", flush=True)
        x = ttyRead()
        print("")
        return not x.lower() == 'n'

    # if self.asktoproceed():
    #     self.msg("Proceed.")
    # else:
    #     self.msg("Taking no action.")
    #     return

