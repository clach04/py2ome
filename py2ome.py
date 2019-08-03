#!/usr/bin/env python
from pyome.gen import ome_c_code
import sys

"""Script to Generate OME wrapper code around Python functions so they can
be used in the INGRES RDBMS.

"""

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.stderr.write('Usage: py2ome MODULENAME\n')
        exit(1)
    module = __import__(sys.argv[1])
    print ome_c_code(module)
