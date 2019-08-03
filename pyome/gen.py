import os
from mako.template import Template
from itertools import count

def ome_c_code(module):
    """Generate C code from a Python Module containing functions marked up
    with the ome_function_instance decorator.

    """
    module_name = module.__name__
    funcs       = []
    instances   = []
    inparams    = []
    opid_offset = count(0).next
    ipid_offset = count(0).next
    for var in (getattr(module, i) for i in dir(module)):
        if callable(var):
            if hasattr(var, '__INGRES_OME__'):
                opid = opid_offset()
                funcs.append([opid, var.__name__])
                for instance in var.__INGRES_OME__:
                    instances.append([opid, ipid_offset(), var.__name__, instance['params'], instance['ret'], instance['type']])
                    inparam_desc = tuple(param.ing_name for param in instance['params'])
                    if inparam_desc not in inparams:
                        inparams.append(inparam_desc)
    return Template(filename=os.path.join(os.path.dirname(__file__), 'ome.mako')).render(module_name=module_name, funcs=funcs, instances=instances, inparams=inparams)
