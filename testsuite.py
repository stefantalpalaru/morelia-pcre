#!/usr/bin/env python

from pcre import *
from pprint import pprint
import sys
import re

OPTIONS = {
    'i': PCRE_CASELESS,
    'x': PCRE_EXTENDED,
}

def test_match(regex, opts, data):
    options = 0
    for opt in list(opts):
        if opt in OPTIONS:
            options |= OPTIONS[opt]
    compiled = pcre_compile(regex, options)
    extra = pcre_study(compiled)
    result = pcre_exec(compiled, data, extra=extra)
    return result

def process_regex(regex):
    # handle C style escapes
    regex = eval('"""%s"""' % regex)
    return regex

def process_data(data):
    # escape unescaped '"'
    data = re.sub('[^\\\\]\("\)', '\\"', data)
    # eval
    data = eval('"""%s"""' % data)
    data = data.strip()
    return data

def main(*args):
    in_file = open(args[0])
    out_file = open(args[1], 'w')
    is_comment = False
    is_data = False
    regex = ''
    multiline_regex = False
    opt = ''
    line_no = 0
    for line in in_file:
        line_no += 1
        if is_comment:
            # inside a comment
            if line[-4:] == '--/\n':
                is_comment = False
            out_file.write(line)
            continue
        if len(line) > 3 and line[:3] == '/--':
            # the start of a comment
            if line[-4:] != '--/\n':
                is_comment = True
            out_file.write(line)
            continue
        if len(line) == 1:
            # empty line
            is_data = False
            out_file.write(line)
            continue
        if multiline_regex:
            regex_end = line.rfind('/')
            if not(regex_end == -1 or line[regex_end - 1] == '\\'):
                # last regex line
                regex += line[1:regex_end]
                regex = process_regex(regex)
                opts = line[regex_end+1:-1]
                multiline_regex = False
            else:
                regex += line
            continue
        if line[0] == '/':
            # regex
            regex_end = line.rfind('/')
            if regex_end in [-1, 0] or line[regex_end - 1] == '\\':
                multiline_regex = True
                regex = line[1:]
                out_file.write(line)
                continue
            regex = process_regex(line[1:regex_end])
            opts = line[regex_end+1:-1]
            out_file.write(line)
            continue
        # it can be only data
        is_data = True
        out_file.write(line)
        pprint([line_no, regex, opts, line])
        data = process_data(line)
        pprint([line_no, regex, opts, data])
        result = test_match(regex, opts, data)
        if result.num_matches:
            for i in xrange(result.num_matches):
                out_file.write('%2d: %s\n' % (i, repr(result.matches[i])[1:-1]))
        else:
            out_file.write('No match\n')
    # close files
    in_file.close()
    out_file.close()

def usage():
    print 'usage: %s infile outfile' % sys.argv[0]

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) != 2:
        usage()
        exit(1)
    main(*args)

