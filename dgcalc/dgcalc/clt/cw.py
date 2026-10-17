


from os import (
    environ as os_environ,
)
import os
from .post_sys import (
    create_dir,
)
from ..ossys.ossys import (
    default_conf_stemlist,
    path_file,
    cw_file,
)



class CW:
    """
    Current Working structure.
    """

    # Todo PLAN: this is the only entity that knows absolute paths,
    #  and its API access point can be passed to subtools.

    def __init__(self, head):
        self.conf_dir = create_dir(os_environ["HOME"], default_conf_stemlist)
        self.cw_dir = os.path.join(self.conf_dir, cw_file)
        self.path_dir = os.path.join(self.conf_dir, path_file)
        self.w = None
        self.p = None
        self.path = None
        head.vmsg(f"init: cw_dir {self.cw_dir} path_dir {self.path_dir}")

    def init(self, head, clean):
        # > try to get the cw structure
        # todo quiet down messages
        if os.path.exists(self.cw_dir):
            head.vmsg(f"found {self.cw_dir}")
            with open(self.cw_dir, 'r', encoding="utf-8") as f:
                cw = f.read()
                self.w, self.p = cw.split('/')
                head.vmsg(f"cwg {self.w} cwp {self.p}")
        else:
            if clean:
                # Possibly a new system, possibly a missing file
                # > point to the trivial address
                self.w = '0'
                self.p = '1'
                self.writeback()
            else:
                # ordinary initialization point of failure
                raise FileNotFoundError(f"File {self.cw_dir} not found.")
        if os.path.exists(self.path_dir):
            head.vmsg(f"found {self.path_dir}")
            with open(self.path_dir, 'r', encoding="utf-8") as f:
                path = f.read()
                split = path.split('\n')
                self.path = dict([x.split(':') for x in split if x != ''])
                head.vmsg(f"path {self.path}")
        else:
            if clean:
                # Possibly a new system, possibly a missing file
                with open(self.path_dir, 'w', encoding="utf-8") as f:
                    f.write(f"0:{os.environ['HOME']}\n")
            else:
                # ordinary initialization point of failure
                raise FileNotFoundError(f"File {self.path_dir} not found.")


    def writeback(self):
        with open(self.cw_dir, 'w', encoding="utf-8") as f:
            f.write('/'.join([self.w, self.p]))



