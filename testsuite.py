#!/usr/bin/env python

from pcre import *
from pprint import pprint
import sys
import re

class Tester:
    options = {
        'i': PCRE_CASELESS,
        'x': PCRE_EXTENDED,
        's': PCRE_DOTALL,
        'm': PCRE_MULTILINE,
    }
    find_all = False
    show_rest = False
    testinput_line_no = 0
    testoutput_line_no = 0
    failed_tests = 0

    def process_data(self, data):
        #print 'data processing:'
        #pprint(data)
        data = data.strip()
        # strip trailing backslash if alone
        if ((len(data) >= 2 and data[-2] != '\\') or (len(data) == 1)) and data[-1] == '\\':
            data = data[:-1]
        # fix escapes valid in C but invalid in python
        data = re.sub(r'\\x([0-9][^0-9a-f])', '\\x0\\1', data)
        data = re.sub(r'\\x([0-9][^0-9a-f])', '\\x0\\1', data) # done twice for '\\x0\\x0'
        data = re.sub(r'\\e', '\\x1b', data)
        data = re.sub(r'\\\$', '$', data)
        # escape double quotes
        data = re.sub(r'\\"', '\\x22', data)
        data = re.sub(r'"', '\\x22', data)
        # '@' doesn't need escaping
        data = re.sub(r'\\@', '@', data)
        # eval
        data = eval('"""%s"""' % data)
        #pprint(data)
        return data

    def process_output(self, output):
        output = repr(output)[1:-1]
        output = re.sub(r'\\t', '\\x09', output)
        output = re.sub(r'\\n', '\\x0a', output)
        output = re.sub(r'\\r', '\\x0d', output)
        output = re.sub(r'\\\'', '\'', output)
        output = re.sub(r'\\\\', r'\\', output)
        return output

    def test_match(self, regex, opts, data):
        self.find_all = False
        self.show_rest = False
        options = 0
        for opt in list(opts):
            if opt in self.options:
                options |= self.options[opt]
            elif opt == 'g':
                self.find_all = True
            elif opt == '+':
                self.show_rest = True
        compiled = pcre_compile(regex, options)
        extra = pcre_study(compiled)
        if self.find_all:
            results = pcre_find_all(compiled, data, extra=extra)
        else:
            result = pcre_exec(compiled, data, extra=extra)
            results = [result]
        return results

    def verify_output(self, line):
        output_line = self.testoutput.readline()
        self.testoutput_line_no += 1
        if line != output_line:
            self.failed_tests += 1
            print 'error: testinput line %d, testoutput line %d' % (self.testinput_line_no, self.testoutput_line_no)
            print 'expected:\n%sgot:\n%s' % (output_line, line)

def main(*args):
    tester = Tester()
    tester.testinput = open(args[0])
    tester.testoutput = open(args[1])
    state = '' # 'comment', 'empty line', 'regex', 'data'
    regex = ''
    multiline_regex = False
    opt = ''

    sep = '' # regex separator
    for line in tester.testinput:
        tester.testinput_line_no += 1
        if state == 'comment':
            # inside a comment
            if line[-4:] == '--/\n':
                state = ''
            #out_file.write(line)
            tester.verify_output(line)
            continue
        if len(line) > 3 and line[:3] == '/--':
            # the start of a comment
            if line[-4:] != '--/\n':
                state = 'comment'
            #out_file.write(line)
            tester.verify_output(line)
            continue
        if len(line) == 1 or len(line.strip()) == 0:
            # empty line
            state = 'empty line'
            #out_file.write(line)
            tester.verify_output(line)
            continue
        if multiline_regex:
            #out_file.write(line)
            tester.verify_output(line)
            regex_end = line.rfind(sep)
            if not(regex_end == -1 or line[regex_end - 1] == '\\'):
                # last regex line
                regex += line[1:regex_end]
                opts = line[regex_end+1:-1]
                multiline_regex = False
            else:
                regex += line
            continue
        if line[0] != ' ' and state == 'empty line':
            # regex
            state = 'regex'
            sep = line[0]
            regex_end = line.rfind(sep)
            if regex_end in [-1, 0] or line[regex_end - 1] == '\\':
                multiline_regex = True
                regex = line[1:]
                #out_file.write(line)
                tester.verify_output(line)
                continue
            regex = line[1:regex_end]
            opts = line[regex_end+1:-1]
            #out_file.write(line)
            tester.verify_output(line)
            continue
        # it can be only data
        state = 'data'
        #out_file.write(line)
        tester.verify_output(line)
        #pprint([line_no, regex, opts, line])
        data = tester.process_data(line)
        #pprint([line_no, regex, opts, data])
        try:
            results = tester.test_match(regex, opts, data)
        except Exception, e:
            print 'error: ', e
        for result in results:
            if result.num_matches:
                for i in xrange(result.num_matches):
                    match = tester.process_output(result.matches[i])
                    if len(match) == 0:
                        if not result.set_matches[i]:
                            # unset match
                            match = '<unset>'
                    line_out = '%2d: %s\n' % (i, match)
                    #out_file.write(line_out)
                    tester.verify_output(line_out)
                    #print line_out,
                    if tester.show_rest:
                        line_out = '%2d+ %s\n' % (i, data[result.end_offsets[i]:])
                        #out_file.write(line_out)
                        tester.verify_output(line_out)
                        #print line_out,
            else:
                line_out = 'No match\n'
                #out_file.write(line_out)
                tester.verify_output(line_out)
                #print line_out,
    if tester.failed_tests:
        print '\n%d failed tests' % tester.failed_tests

def usage():
    print 'usage: %s testinput testoutput' % sys.argv[0]

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) != 2:
        usage()
        exit(1)
    main(*args)

