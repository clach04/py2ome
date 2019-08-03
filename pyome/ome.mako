<%!
from pyome import VARCHAR, INTEGER, FLOAT

def wrapper_name(name, params, ret):
    return 'wrapper_' + name + (ret and '_ret_%s_' % ret or '') + (params and 'args_'+ '_'.join(map(str,params)) or '')

def name_to_char_array(name):
    return ','.join("'%s'" % (c == '\0' and '\\0' or c) for c in name+'\0'[:32])

def param_def_id(params):
    return 'PARAMS_' + ('_'.join(params) or 'NONE')

%>
##START OF FILE
#include <iiadd.h>
#include <Python.h>

#define     min(a,b)    ((a) <= (b) ? (a) : (b))

static  II_STATUS   (*Ingres_trace_function)() = 0;
#ifdef __STDC__
GLOBALDEF II_ERROR_WRITER *usc_error = 0;
GLOBALDEF II_INIT_FILTER  *usc_setup_workspace = 0;
GLOBALDEF II_LO_HANDLER   *usc_lo_handler = 0;
GLOBALDEF II_LO_FILTER    *usc_lo_filter = 0;
#else
GLOBALDEF (*usc_error)() = 0;
GLOBALDEF (*usc_setup_workspace)() = 0;
GLOBALDEF (*usc_lo_handler)() = 0;
GLOBALDEF (*usc_lo_filter)() = 0;
#endif



/*{
** Name:    byte_copy   - copy bytes from one place to another
**
** Description:
**  Simply copies one string of bytes from one place to another.
*/
#ifdef __STDC__
void byte_copy(char *c_from ,
               int  length ,
               char *c_to )
#else
void byte_copy(c_from, length, c_to)
char    *c_from;
int length;
char    *c_to;
#endif
{
    int         i;

    for (i = 0;
        i < length;
        i++, c_from++, c_to++)
    {
    *c_to = *c_from;
    }
}

/*{
** Name:    us_error -- fill in error block
**
** Description:
**      This routine merely fills in the error block according to RTI
**      specification.  It is supplied the user error and string by the caller.
**
**  Inputs:
**      scb                             The scb to fill in
**      error_code                      The error code to supply
**      error_string                    The error string to fill in
**
**  Outputs:
**      scb->scb_error                  Filled with the aforementioned
**                                      information.
## History:
##      13-jun-89 (fred)
##          Created.
##      25-nov-1992 (stevet)
##          Replaced generic_error with SQLSTATE error.
##      17-aug-1993 (stevet)
##          Set er_usererr to error_code, that value
##          is put in the SQLCA error block, not er_errocde.
*/
#ifdef __STDC__
void us_error(II_SCB       *scb ,
              long         error_code ,
              char         *error_string )
#else
void us_error(scb, error_code, error_string )
II_SCB     *scb;
long       error_code;
char       *error_string;
#endif
{
    char *src = II_SQLSTATE_MISC_ERROR;
    char *dest = scb->scb_error.er_sqlstate_err;
    int  i;

    scb->scb_error.er_class = II_EXTERNAL_ERROR;
    scb->scb_error.er_usererr = error_code;
    for(i=0; i < II_SQLSTATE_STRING_LEN; i++, src++, dest++)
        *dest = *src;
    if ((scb->scb_error.er_ebuflen > 0)
                && scb->scb_error.er_errmsgp)
    {
        scb->scb_error.er_emsglen = min(scb->scb_error.er_ebuflen,
                                        strlen(error_string));
       byte_copy(      error_string,
                        scb->scb_error.er_emsglen,
                        scb->scb_error.er_errmsgp);
    }
    else
    {
        scb->scb_error.er_emsglen = 0;
    }
}

PyObject *convert_anytext(II_DATA_VALUE *value)
{
    return PyString_FromStringAndSize(((II_VLEN*)value->db_data)->vlen_array, (Py_ssize_t)((II_VLEN*)value->db_data)->vlen_length);
}

PyObject *convert_anyint(II_DATA_VALUE *value)
{
    switch (value->db_length)
    {
        case 1:
            return PyLong_FromLongLong((PY_LONG_LONG)*(char*)value);
        case 2:
            return PyLong_FromLongLong((PY_LONG_LONG)*(short*)value);
        case 4:
            return PyLong_FromLongLong((PY_LONG_LONG)*(int*)value);
        case 8:
            return PyLong_FromLongLong((PY_LONG_LONG)*(PY_LONG_LONG*)value);
        default:
            return NULL;
    }
}

PyObject *convert_anyfloat(II_DATA_VALUE *value)
{
    switch (value->db_length)
    {
        case 4:
            return PyFloat_FromDouble((double)*(float*)value);
        case 8:
            return PyFloat_FromDouble(*(double*)value);
        default:
            return NULL;
    }
}

% for opid, ipid, name, params, ret, type in instances:
## START OF WRAPPER FUNCTION
II_STATUS ${wrapper_name(name, params, ret)} (II_SCB *scb\
% for i in range(len(params)):
, II_DATA_VALUE *p${i+1}\
% endfor
% if ret:
, II_DATA_VALUE *rdv\
% endif
)
{
    static PyObject *pFunc;

    PyObject *pModule;
    PyObject *pArgs;
    PyObject *pValue;

    PyObject *pErrType;
    PyObject *pErrValue;
    PyObject *pErrTraceback;
    PyGILState_STATE gstate;

    gstate = PyGILState_Ensure();
    if (pFunc == NULL)
    {
        pModule = PyImport_ImportModule("${module_name}");
        if (pModule != NULL)
        {
            pFunc = PyObject_GetAttrString(pModule, "${name}");
            if (pFunc == NULL || !PyCallable_Check(pFunc))
            {
                us_error(scb, 0x200002, "Could not get function on was not callable '${name}'");
                PyGILState_Release(gstate);
                return II_ERROR;
            }
        }
        else
        {
            us_error(scb, 0x200001, "Could not load module '${module_name}', did you set PYTHONPATH correctly?");
            PyGILState_Release(gstate);
            return II_ERROR;
        }
    }
    pArgs = PyTuple_New(${len(params)});
    % for num, param in enumerate(params):
        % if param == VARCHAR:
    pValue = convert_anytext(p${num+1});
        % elif param == INTEGER:
    pValue = convert_anyint(p${num+1});
        % elif param == FLOAT:
    pValue = convert_anyfloat(p${num+1});
        % endif
    if (!pValue) {
        Py_DECREF(pArgs);
        us_error(scb, 0x200003, "Could not convert parameter p${num+1} type '${param}'");
        PyGILState_Release(gstate);
        return II_ERROR;
    }
    PyTuple_SetItem(pArgs, ${num}, pValue);
    % endfor

    pValue = PyObject_CallObject(pFunc, pArgs);
    Py_DECREF(pArgs);
    if (PyErr_Occurred() != NULL)
    {
        if (pValue)
        {
            Py_DECREF(pValue);
        }
        PyErr_Fetch(&pErrType, &pErrValue, &pErrTraceback);
        PyErr_NormalizeException(&pErrType, &pErrValue, &pErrTraceback);
        pValue = PyObject_Str(pErrValue);
        us_error(scb, 0x200000, PyString_AsString(pValue));
        Py_DECREF(pErrType);
        Py_DECREF(pErrValue);
        Py_DECREF(pErrTraceback);
        Py_DECREF(pValue);
        PyGILState_Release(gstate);
        return II_ERROR;
    }
    if (pValue == NULL)
    {
        us_error(scb, 0x200004, "Python function call failed");
        return II_ERROR;
    }
    % if ret == VARCHAR:
    if (PyString_Size(pValue) > ${ret.size})
    {
        ((II_VLEN*)rdv->db_data)->vlen_length = (short)${ret.size};
        memcpy(((II_VLEN*)rdv->db_data)->vlen_array, PyString_AsString(pValue), ${ret.size});
    }
    else
    {
        ((II_VLEN*)rdv->db_data)->vlen_length = (short)PyString_Size(pValue);
        memcpy(((II_VLEN*)rdv->db_data)->vlen_array, PyString_AsString(pValue), PyString_Size(pValue));
    }
    % elif ret == INTEGER:
        % if ret.size == 1:
    *(char *)rdv->db_data = (char)PyInt_AsLong(pValue);
        % elif ret.size == 2:
    *(short *)rdv->db_data = (short)PyInt_AsLong(pValue);
        % elif ret.size == 4:
    *(int *)rdv->db_data = (int)PyInt_AsLong(pValue);
        % elif ret.size == 8:
    *(PY_LONG_LONG *)rdv->db_data = (PY_LONG_LONG)PyLong_AsLongLong(pValue);
        % else:
    /* UNSUPPORTED INTEGER SIZE ${ret.size} */
        % endif
    % elif ret == FLOAT:
        % if ret.size == 4:
    *(float *)rdv->db_data = (float)PyFloat_AsDouble(pValue);
        % elif ret.size == 8:
    *(double *)rdv->db_data = PyFloat_AsDouble(pValue);
        % else:
    /* UNSUPPORTED FLOAT SIZE ${ret.size} */
        %endif
    % endif
    Py_DECREF(pValue);
    PyGILState_Release(gstate);
    return II_OK;
};
## END OF WRAPPER FUNCTION
% endfor

static IIADD_FO_DFN function_definitions[] = {
% for opid, name in funcs:
    { II_O_OPERATION,
      {${name_to_char_array(name)}},
      II_OPSTART+${opid},
      II_NORMAL
    },
% endfor
};

% for params in [list(i) for i in inparams]:
static  II_DT_ID ${param_def_id(params)} [] = \
{ ${', '.join(params)} };
% endfor

static IIADD_FI_DFN   function_instances[] = {
<%
first = True
%>
% for opid, ipid, name, params, ret, type in instances:
% if not first:
    ,\
% else:
    \
<%
first = False
%>
% endif
{
        II_O_FUNCTION_INSTANCE,
        II_FISTART+${ipid},
        II_NO_FI,
        II_OPSTART+${opid},
        ${type},
        II_FID_F0_NOFLAGS,
        0,
        ${len(params)},
        ${param_def_id((param.ing_name for param in params))},
        ${ret.ing_name},
        II_RES_FIXED,
        ${ret.size},
        0,
        ${wrapper_name(name, params, ret)},
        0
    }\
% endfor

};

static IIADD_DEFINITION register_block =
{
    NULL,
    NULL,
    sizeof(IIADD_DEFINITION),
    IIADD_DFN2_TYPE,
    0,
    0,
    0,
    0,
    IIADD_INCONSISTENT,
    1,
    0,
    ${len("Python User Defined Functions")},
    "Python User Defined Functions",
    IIADD_T_FAIL_MASK | IIADD_T_LOG_MASK,
    0,
    0,
    NULL,
    (sizeof(function_definitions)/sizeof(IIADD_FO_DFN)),
    function_definitions,
    (sizeof(function_instances)/sizeof(IIADD_FI_DFN)),
    function_instances
};

static PyThreadState *maintstat;

/*{
** Name: IIUDADT_REGISTER   - Add the datatype to the server
**
** Description:
**      This routine is called by the DBMS server to add obtain information to
**  add the datatype to the server.  It simply fills in the provided
**  structure and returns.
**
** Inputs:
**      ui_block                        Pointer to user information block.
**  callback_block          Pointer to an II_CALLBACKS structure
**                  which contains information about INGRES
**                  callbacks which are available.
**
**                  Note that after this routine returns
**                  the address of this block is no longer
**                  valid.  Therefore, this routine must
**                  copy the contents in which it is
**                  interested before returning.
**
** Outputs:
**      *ui_block                       User information block
**
**  Returns:
**      II_STATUS
**  Exceptions:
**      none
**
** Side Effects:
**      none
**
## History:
##      02-Mar-1989 (fred)
##          Created.
[@history_template@]...
*/
II_STATUS
#ifdef __STDC__
IIudadt_register(IIADD_DEFINITION  **ui_block_ptr ,
                  II_CALLBACKS  *callback_block )
#else
IIudadt_register(ui_block_ptr, callback_block)
IIADD_DEFINITION  **ui_block_ptr;
II_CALLBACKS      *callback_block;
#endif
{
    register_block.add_count = register_block.add_dt_cnt +
                register_block.add_fo_cnt +
                register_block.add_fi_cnt;
    *ui_block_ptr = &register_block;

    if (callback_block && callback_block->ii_cb_version >= II_CB_V1) {
        Ingres_trace_function = callback_block->ii_cb_trace;
        if (callback_block->ii_cb_version >= II_CB_V2)
        {
            usc_lo_handler      = callback_block->ii_lo_handler_fcn;
            usc_lo_filter       = callback_block->ii_filter_fcn;
            usc_setup_workspace = callback_block->ii_init_filter_fcn;
            usc_error           = callback_block->ii_error_fcn;
        }
    }
    else
    {
        Ingres_trace_function = 0;
    };

    /* Initialize python interpreter */
    Py_InitializeEx(0);
    PyEval_InitThreads();
    PyThreadState_Get();
    PyEval_ReleaseLock();;
    return II_OK;
}
