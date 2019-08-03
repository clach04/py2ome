"""Ingres User Defined Functions in Python

This module can be use to write python modules which define database
function for the Ingres database managment system and generate wrapper
code which can be called in SQL.

To use this module markup your functions with the ome_function_instance
decorator then use the py2ome script to generate the C code.

"""

class INGRES_TYPE_META(type):
    def __str__(klass):
        return klass.name

    def __eq__(klass, other):
        if hasattr(other, 'name') and other.name == klass.name:
            return True
        else:
            return False

class INGRES_TYPE(object):
    def __init__(self, size):
        self.size = size

    def __str__(self):
        return self.name

    def __eq__(self, other):
        if hasattr(other, 'name') and other.name == self.name:
            return True
        else:
            return False

class VARCHAR(INGRES_TYPE):
    """VARCHAR - use with ome function decorator.

       Not can be use with and without a size e.g.

       @ome_funtionc_instance(ret=VARCHAR)
       [function def]
       or
       @ome_funtionc_instance(ret=VARCHAR(100))
       [fucntion def

       Size defaults to MAX - not a Ingres default behaviour, this
       may cause poor performance especially with VARCHARs.

       Size's are ignored for parameters but not return values.

    """
    __metaclass__ = INGRES_TYPE_META
    name = "VARCHAR"
    ing_name = "II_VARCHAR"
    size = 32000


class INTEGER(INGRES_TYPE):
    """INTEGER - use with ome function decorator.

    See VARCHAR help for details.

    """
    __metaclass__ = INGRES_TYPE_META
    name = "INTEGER"
    ing_name = "II_INTEGER"
    size = 4

class FLOAT(INGRES_TYPE):
    """FLOAT - use with ome function decorator.

    See VARCHAR help for details.

    """
    __metaclass__ = INGRES_TYPE_META
    name = "FLOAT"
    ing_name = "II_FLOAT"
    size = 8

NORMAL = 'II_NORMAL'

def ome_function_instance(ret=None, params=[], type=NORMAL):
    """ome function decorator.

    Add metadata to the function used by the ome_c_code function to
    generate c code to wrap this function. This decorator can be nested
    to allow multiple instances of the same function.

    ret    - possible return type of the function or None.
    params - possible parameter types for function.
    type   - function type NORMAL.

    """
    def decorator(f):
        if not hasattr(f, '__INGRES_OME__'):
            f.__INGRES_OME__ = []
        f.__INGRES_OME__.append(dict(ret=ret, params=params, type=type))
        return f
    return decorator

ALL = [ome_function_instance, VARCHAR, FLOAT, INTEGER,
         NORMAL]

