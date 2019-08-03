CCFLAGS=-c -fPIC -g -O0 -o$@
LDFLAGS=-shared
CC=gcc
INC=-I${II_SYSTEM}/ingres/files -I/usr/include/python2.5
LIBPATH=-L${II_SYSTEM}/ingres/lib
LIBS=-lpython

all: pyome.o
	$(CC) $(LDFLAGS) -olibpyome.so pyome.o

pyome.o: pyome.c
	$(CC) pyome.c $(CCFLAGS) $(LIBPATH) $(INC)

