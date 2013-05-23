#!/usr/bin/env python

import sys, os
from pcre import *
from pprint import pprint

MAX_CODE_LEN = 62

def main(fname):
    if not os.path.exists(fname):
        print 'no such file: "%s"' % fname
        exit(1)
    pxd_file = open('_globals.pxd', 'w')
    py_file = open('_globals.py', 'w')
    pattern = pcre_compile(r'^#define (PCRE_\S+)\s+(\S+)(.*)$')
    extra = pcre_study(pattern)
    start_processing = False
    max_code_len = 0
    with open(fname) as header:
        for line in header:
            #print line,
            result = pcre_exec(pattern, line, extra=extra)
            if result.num_matches:
                if result.matches[1] == 'PCRE_DATE':
                    start_processing = True
                    continue
                if result.matches[1] == 'PCRE_UCHAR16':
                    break
                if start_processing:
                    #print '"%s" "%s" "%s"' % tuple(result.matches[1:])
                    pxd_file.write('    int _%s "%s"\n' % (result.matches[1], result.matches[1]))
                    comment = ''
                    if len(result.matches[3]):
                        code_len = len(result.matches[1]) * 2 + 10
                        if code_len > max_code_len:
                            max_code_len = code_len
                        comment = '%s# %s' % ((MAX_CODE_LEN - code_len + 1) * ' ', result.matches[3].strip().strip('/*'))
                    py_file.write('%s = cpcre._%s%s\n' % (result.matches[1], result.matches[1], comment))
    pxd_file.close()
    py_file.close()
    print 'max_code_len =', max_code_len

def usage():
    print 'usage: %s pcre.h' % sys.argv[0]

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) != 1:
        usage()
        exit(1)
    main(*args)

