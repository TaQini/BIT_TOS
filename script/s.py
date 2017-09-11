#!/usr/bin/python
from sys import *
f = open(argv[1], 'r')
def tr(s):
    buf = ""
    l = s.split()
    for c in l:
        if chr(int(c,16)) in "12345 67890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM:/,_":
            buf += chr(int(c,16))
    return buf
for i in range(eval(argv[2])*4):
    print tr(f.readline())[1:]
