#!/usr/bin/env python

from pcre import *
from pprint import pprint
import sys
import re

class Tester:
    options = {
        'i': PCRE_CASELESS,
        'J': PCRE_DUPNAMES,
        'm': PCRE_MULTILINE,
        's': PCRE_DOTALL,
        'x': PCRE_EXTENDED,
        'Y': PCRE_NO_START_OPTIMISE,
    } # simple options
    testinput_line_no = 0
    testoutput_line_no = 0
    failed_tests = 0
    last_regex = ''
    last_opts = ''
    last_data = ''
    unhandled_opts = set()

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
        ### option setting
        self.set_options = 0
        # \A
        opt_pat = r'([^\\]?)\\A'
        match = re.search(opt_pat, data)
        if match:
            self.set_options |= PCRE_ANCHORED
            data = re.sub(opt_pat, '\\1', data)
        # \B
        opt_pat = r'([^\\]?)\\B'
        match = re.search(opt_pat, data)
        if match:
            self.set_options |= PCRE_NOTBOL
            data = re.sub(opt_pat, '\\1', data)
        # eval
        data = eval('"""%s"""' % data)
        #pprint(data)
        return data

    def process_output(self, output):
        skip = 1
        if isinstance(output, unicode):
            skip = 2
        output = repr(output)[skip:-1]
        output = re.sub(r'\\t', '\\x09', output)
        output = re.sub(r'\\n', '\\x0a', output)
        output = re.sub(r'\\r', '\\x0d', output)
        output = re.sub(r'\\\'', '\'', output)
        output = re.sub(r'\\\\', r'\\', output)
        return output

    def test_match(self, regex, opts, data):
        self.find_all = False
        self.show_rest = False
        self.do_mark = False
        self.do_study = False
        self.last_regex = regex
        self.last_opts = opts
        self.last_data = data
        self.set_options = 0
        for opt in list(opts):
            if opt in self.options:
                self.set_options |= self.options[opt]
            elif opt == 'g':
                self.find_all = True
            elif opt == '+':
                self.show_rest = True
            elif opt == 'K':
                self.do_mark = True
            elif opt == 'S':
                if self.do_study:
                    self.do_study = False
                else:
                    self.do_study = True
            else:
                self.unhandled_opts.add(opt)
        compiled = pcre_compile(regex, self.set_options)
        extra = None
        if self.do_study:
            extra = pcre_study(compiled)
        if self.do_mark:
            if extra is None:
                extra = pcre_create_empty_study()
            extra.flags |= PCRE_EXTRA_MARK
        # process the data after compilation and study so exec-only options can be added now
        self.data = self.process_data(data)
        if self.find_all:
            results = pcre_find_all(compiled, self.data, extra=extra)
        else:
            result = pcre_exec(compiled, self.data, extra=extra)
            results = [result]
        return results

    def verify_output(self, line):
        output_line = self.testoutput.readline()
        self.testoutput_line_no += 1
        if line != output_line:
            self.failed_tests += 1
            print 'error: testinput line %d, testoutput line %d' % (self.testinput_line_no, self.testoutput_line_no)
            print 'expected:\n%sgot:\n%s' % (output_line, line)
            print 'regex:\n"%s"\nopts:\n"%s"\ndata:\n"%s"\n' % (self.last_regex, self.last_opts, self.last_data)

def main(*args):
    tester = Tester()
    tester.testinput = open(args[0])
    tester.testoutput = open(args[1])
    state = 'start' # 'start', 'empty line', 'regex', 'data'
    regex = ''
    multiline_regex = False
    opts = ''
    data = ''

    sep = '' # regex separator
    for line in tester.testinput:
        tester.testinput_line_no += 1
        if len(line) == 1 or len(line.strip()) == 0:
            # empty line
            state = 'empty line'
            tester.verify_output(line)
            continue
        if multiline_regex:
            tester.verify_output(line)
            regex_end = line.rfind(sep)
            if not(regex_end == -1 or line[regex_end - 1] == '\\'):
                # last regex line
                regex += line[:regex_end]
                opts = line[regex_end+1:-1]
                multiline_regex = False
            else:
                regex += line
            continue
        if line[0] != ' ' and state in ('start', 'empty line'):
            # regex
            state = 'regex'
            sep = line[0]
            regex_end = line.rfind(sep)
            if regex_end in [-1, 0] or line[regex_end - 1] == '\\':
                multiline_regex = True
                regex = line[1:]
                tester.verify_output(line)
                continue
            regex = line[1:regex_end]
            opts = line[regex_end+1:-1].strip()
            tester.verify_output(line)
            continue
        # it can be only data
        state = 'data'
        tester.verify_output(line)
        try:
            results = tester.test_match(regex, opts, line)
            data = tester.data # the processed data
        except Exception, e:
            print 'error: ', e
        for result in results:
            if result.num_matches:
                for i in xrange(result.num_matches):
                    match = tester.process_output(result.matches[i])
                    if result.matches[i] is None:
                        # unset match
                        match = '<unset>'
                    line_out = '%2d: %s\n' % (i, match)
                    tester.verify_output(line_out)
                    if tester.show_rest and i == 0:
                        line_out = '%2d+ %s\n' % (i, data[result.end_offsets[i]:])
                        tester.verify_output(line_out)
                if result.mark:
                    line_out = 'MK: %s\n' % tester.process_output(result.mark)
                    tester.verify_output(line_out)
            else:
                line_out = 'No match\n'
                if result.mark:
                    line_out = 'No match, mark = %s\n' % result.mark
                tester.verify_output(line_out)
    if tester.failed_tests:
        print '\n%d failed tests' % tester.failed_tests
    else:
        print 'all tests passed'
    if tester.unhandled_opts:
        print 'unhandled options: %s' % ', '.join(tester.unhandled_opts)

def usage():
    print 'usage: %s testinput testoutput' % sys.argv[0]

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) != 2:
        usage()
        exit(1)
    main(*args)

