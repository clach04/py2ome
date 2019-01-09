PythonOmeFunctions
==================

**Using Python and OME to Write User Defined Functions for Ingres**

**Written By: Anthony Simpson**

Contents
--------

*   [1 Introduction](#Introduction)
    *   [1.1 Python](#Python)
    *   [1.2 SQL](#SQL)
*   [2 py2ome and pyome](#py2ome_and_pyome)
    *   [2.1 Requirements](#Requirements)
    *   [2.2 Usage](#Usage)
    *   [2.3 Building](#Building)
    *   [2.4 Install](#Install)
    *   [2.5 Help / Suggestions](#Help_.2F_Suggestions)
*   [3 Bugs, Issues and Enhancements](#Bugs.2C_Issues_and_Enhancements)
    *   [3.1 Bugs](#Bugs)
    *   [3.2 Enhancements](#Enhancements)
*   [4 Links](#Links)


Introduction
------------

For an introduction to OME and user defined functions see [OME User Defined Functions](http://community.ingres.com/wiki/OME:_User_Defined_Functions "http://community.ingres.com/wiki/OME:_User_Defined_Functions"), keywords UDT, UDF

This article will describe a Python script (py2ome) which can be used to generate wrapper C code for python functions to expose them in the Ingres RDBMS. A simple python function can be called directly through SQL:


#### Python

    @`ome_function_instance`(ret=INTEGER, params=[VARCHAR])
    def dehex(hex):
        return int(hex, 16)


#### SQL

    * select dehex(hex(26612))\g
    Executing . . .


    +-------------+
    ¦col1         ¦
    +-------------+
    ¦        26612¦
    +-------------+
    (1 row)
    continue

At the moment it is very limited and can only generate code for "normal" functions (no aggregate functions) using integers, floats and varchars.

**It would not be a very good idea to use this code on a production machine!**


py2ome and pyome
----------------


#### Requirements

Python 2.x from 2.3 or later, you will need the development files (python library and C header files), these come with the Windows installer available from [python.org](http://www.python.org "http://www.python.org"), Python comes installed on most Linux distributions but you may need to install the development files separately.

Python Mako template module available

The Ingres RDBMS, I have tested against 2006, 9.3 and 10.0(alpha build) so I think any 2006 or later should work.

An ANSI C compiler, on Windows I have tested with the Visual Studio 2003 C compiler, on Linux I have used gcc 3.3 and 3.4.

A capable version of the make utility, on Windows one is available in [UnixUtils](http://unxutils.sourceforge.net/ "http://unxutils.sourceforge.net/").

The python script and example [DOWNLOAD](http://community.ingres.com/wiki/Image:Py2ome.zip "http://community.ingres.com/wiki/Image:Py2ome.zip").


#### Usage

After extracting the code to a directory you should find the py2ome script, a pyome module, the iiudf.py example module and two example make files.

Open the iiudf.py example, you will see that it imports from the pyome module:

    from pyome import ome_function_instance, VARCHAR, INTEGER, FLOAT

`ome_function_instance` is a decorator which adds metadata to functions so wrapper C code can be generated for them. VARCHAR, INTEGER and FLOAT are python classes representing types in the Ingres RDBMS, they can be used with or which out a size e.g. INTEGER(2) or INTEGER.

To generate C code for the iiudf module you would use the following command line:

    python py2ome.py iiudf > pyome.c

The py2ome script can be used on any module in the python include path (current directory is normally in included) but will only output wrapper functions for functions with the `ome_function_instance` decorator.

The `ome_function_instance` decorator can be stacked on a single function if you want it to accept different types or numbers of parameters, see b64encode in iiudf.py for an example.


#### Building

This section is more difficult than I feel it should be, if anyone has any ideas as to how it could be simpler let me know.

Generate the pyome.c file using the py2ome script.

    python py2ome.py [MODULE] > pyome.c

The two make files included in the code are the product of extreme laziness so you may need to alter them for your environment.

You will need `II_SYSTEM` set in your environment to run the make file.

The Windows make file (makefile.w32) is set up build the iilibudt.dll, you may need to change the path to the python library etc. The iilibudt.dll can be copied into `%II_SYSTEM%`

    make -f makefile.w32

The Linux make file builds libpyome.so which can be linked to iimerge using iilink, you need to add -lpython2.5 (or other version) to the **LDLIBMACH** and **LDLIBMACH64** list in the `$II_SYSTEM/ingres/utility/iisysdep` to use iilink.


#### Install

After installing iilibudt.dll on Windows or linking libpyome.so on Linux you will need to make sure that the python module you generated the OME wrapper for is on the python include path, you can put it in the python site-packages directory or set the PYTHONPATH variable to include the directory containing it. You will then need to restart Ingres.


#### Help / Suggestions

I've started a thread in the Ingres forums if you want help or to make suggestions please go [here](http://community.ingres.com/forum/contributors-forum/10991-user-defined-functions-ingres-sort.html "http://community.ingres.com/forum/contributors-forum/10991-user-defined-functions-ingres-sort.html").


Bugs, Issues and Enhancements
-----------------------------


#### Bugs

*   The Python interpreter is not cleanly shutdown as I do not know who to get code run when the DBMS server shuts down;
*   Opening files in Python seems to fail.


#### Enhancements

There are two enhancements I feel are really needed and I'm disappointed that I couldn't figure out how to implement them before releasing this:

*   Support LONG VARCHARs as Python Iterators;
*   Support AGGREGATE function types.

I also wish that it was possible to compile and link the OME extensions using a cross platform build script, but I think this would be very complicated to write.


Links
-----

*   [Python](http://www.python.org "http://www.python.org")
*   [Python C API](http://archive-www.python.org/doc/2.5.2/api/api.html "http://archive-www.python.org/doc/2.5.2/api/api.html")
*   [Embeding Python](http://docs.python.org/extending/index.html "http://docs.python.org/extending/index.html")

Retrieved from "[http://community.ingres.com/wiki/PythonOmeFunctions](http://community.ingres.com/wiki/PythonOmeFunctions)"
