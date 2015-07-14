#!/usr/bin/env python
import dis
import sys
import os

def compile_source():
    infile = open(sys.argv[1])
    co = compile(infile.read(), os.path.basename(sys.argv[1]), 'exec')
    infile.close()
    return co

def print_co(co):
    print 'name:', co.co_name, '----------------------------------------'
    print 'consts:', co.co_consts
    print 'names:', co.co_names
    print 'varnames:', co.co_varnames
    print 'freevars:', co.co_freevars
    print 'cellvars:', co.co_cellvars
    print 'lnotab:'
    print dis.dis(co)

def re_print_co(co):
    print_co(co)

    for const in co.co_consts:
        if isinstance(const, type(co)):
            re_print_co(const)


co = compile_source()
re_print_co(co)
