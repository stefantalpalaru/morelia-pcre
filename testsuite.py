#!/usr/bin/env python

from pcre import *
from pprint import pprint
import sys
import re
import argparse

PCRE_NEWLINE_BITS =\
        PCRE_NEWLINE_CR |\
        PCRE_NEWLINE_LF |\
        PCRE_NEWLINE_ANY |\
        PCRE_NEWLINE_ANYCRLF

PCRE_RCH_CASELESS = 0x00000080 # caseless requested char
PCRE_FCH_CASELESS = 0x00000020  # caseless first char

class Tester:
    options = {
        'i': PCRE_CASELESS,
        'J': PCRE_DUPNAMES,
        'm': PCRE_MULTILINE,
        's': PCRE_DOTALL,
        'x': PCRE_EXTENDED,
        'X': PCRE_EXTRA,
        'Y': PCRE_NO_START_OPTIMIZE,
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
        #self.set_options = 0
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

    def test_match(self, regex, opts, data, use_jit=False, first_data=False):
        self.find_all = False
        self.show_rest = False
        self.do_mark = False
        self.do_study = False
        self.force_study = False
        self.no_force_study = False
        self.last_regex = regex
        self.last_opts = opts
        self.last_data = data
        self.set_options = 0
        self.study_options = 0
        self.do_showinfo = False
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
                    self.no_force_study = True
                else:
                    self.do_study = True
            elif opt == 'I':
                    self.do_showinfo = True
            else:
                self.unhandled_opts.add(opt)
        if use_jit:
            self.study_options |= PCRE_STUDY_JIT_COMPILE
            self.force_study = True
        self.data = self.process_data(data)
        try:
            compiled = pcre_compile(regex, self.set_options)
        except Exception, e:
            self.verify_output("%s\n" % e)
            self.verify_output(data, 'data')
            return
        extra = None
        if self.do_study or (self.force_study and not self.no_force_study):
            extra = pcre_study(compiled, self.study_options)
        if self.do_mark:
            if extra is None:
                extra = pcre_create_empty_study()
            extra.flags |= PCRE_EXTRA_MARK
        if self.do_showinfo and first_data:
            try:
                info_count = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_CAPTURECOUNT)
                info_backrefmax = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_BACKREFMAX)
                info_first_char = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_FIRSTCHARACTER)
                info_first_char_set = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_FIRSTCHARACTERFLAGS)
                info_need_char = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_REQUIREDCHAR)
                info_need_char_set = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_REQUIREDCHARFLAGS)
                info_nameentrysize = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_NAMEENTRYSIZE)
                info_namecount = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_NAMECOUNT)
                info_nametable = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_NAMETABLE)
                info_okpartial = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_OKPARTIAL)
                info_jchanged = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_JCHANGED)
                info_hascrorlf = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_HASCRORLF)
                info_match_empty = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_MATCH_EMPTY)
                info_maxlookbehind = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_MAXLOOKBEHIND)
                info_options = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_OPTIONS)

                self.verify_output("Capturing subpattern count = %d\n" % info_count)
                if info_backrefmax > 0:
                    self.verify_output( "Max back reference = %d\n" % info_backrefmax)
                if info_maxlookbehind > 0:
                    self.verify_output("Max lookbehind = %d\n" % info_maxlookbehind)
                try:
                    info_match_limit = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_MATCHLIMIT)
                    self.verify_output("Match limit = %d\n" % info_match_limit)
                except:
                    pass
                try:
                    info_recursion_limit = pcre_fullinfo_wrapper(compiled, extra, PCRE_INFO_RECURSIONLIMIT)
                    self.verify_output("Recursion limit = %d\n" % info_recursion_limit)
                except:
                    pass
                if info_namecount:
                    self.verify_output("Named capturing subpatterns:\n")

                if not info_okpartial:
                    self.verify_output("Partial matching not supported\n")
                if info_hascrorlf:
                    self.verify_output("Contains explicit CR or LF match\n")
                if info_match_empty:
                    self.verify_output("May match empty string\n")
                if info_options == 0:
                    self.verify_output("No options\n")
                else:
                    self.verify_output("Options:%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n" % (
                        " anchored" if ((info_options & PCRE_ANCHORED) != 0) else "",
                        " caseless" if ((info_options & PCRE_CASELESS) != 0) else "",
                        " extended" if ((info_options & PCRE_EXTENDED) != 0) else "",
                        " multiline" if ((info_options & PCRE_MULTILINE) != 0) else "",
                        " firstline" if ((info_options & PCRE_FIRSTLINE) != 0) else "",
                        " dotall" if ((info_options & PCRE_DOTALL) != 0) else "",
                        " bsr_anycrlf" if ((info_options & PCRE_BSR_ANYCRLF) != 0) else "",
                        " bsr_unicode" if ((info_options & PCRE_BSR_UNICODE) != 0) else "",
                        " dollar_endonly" if ((info_options & PCRE_DOLLAR_ENDONLY) != 0) else "",
                        " extra" if ((info_options & PCRE_EXTRA) != 0) else "",
                        " ungreedy" if ((info_options & PCRE_UNGREEDY) != 0) else "",
                        " no_auto_capture" if ((info_options & PCRE_NO_AUTO_CAPTURE) != 0) else "",
                        " no_auto_possessify" if ((info_options & PCRE_NO_AUTO_POSSESS) != 0) else "",
                        " utf" if ((info_options & PCRE_UTF8) != 0) else "",
                        " ucp" if ((info_options & PCRE_UCP) != 0) else "",
                        " no_utf_check" if ((info_options & PCRE_NO_UTF8_CHECK) != 0) else "",
                        " no_start_optimize" if ((info_options & PCRE_NO_START_OPTIMIZE) != 0) else "",
                        " dupnames" if ((info_options & PCRE_DUPNAMES) != 0) else "",
                        " never_utf" if ((info_options & PCRE_NEVER_UTF) != 0) else "",
                    ))
                if info_jchanged:
                    self.verify_output("Duplicate name status changes\n")
                if info_options & PCRE_NEWLINE_BITS == PCRE_NEWLINE_CR:
                    self.verify_output("Forced newline sequence: CR\n")
                elif info_options & PCRE_NEWLINE_BITS == PCRE_NEWLINE_LF:
                    self.verify_output("Forced newline sequence: LF\n")
                elif info_options & PCRE_NEWLINE_BITS == PCRE_NEWLINE_CRLF:
                    self.verify_output("Forced newline sequence: CRLF\n")
                elif info_options & PCRE_NEWLINE_BITS == PCRE_NEWLINE_ANYCRLF:
                    self.verify_output("Forced newline sequence: ANYCRLF\n")
                elif info_options & PCRE_NEWLINE_BITS == PCRE_NEWLINE_ANY:
                    self.verify_output("Forced newline sequence: ANY\n")
                if info_first_char_set == 2:
                    self.verify_output("First char at start or follows newline\n")
                elif info_first_char_set == 1:
                    info_caseless = "" if ((info_options & PCRE_FCH_CASELESS) == 0) else " (caseless)"
                    self.verify_output("First char = \'%c\'%s\n" % (info_first_char, info_caseless))
                else:
                    self.verify_output("No first char\n")
                if info_need_char_set == 0:
                    self.verify_output("No need char\n")
                else:
                    info_caseless = "" if ((info_options & PCRE_RCH_CASELESS) == 0) else " (caseless)"
                    self.verify_output("Need char = \'%c\'%s\n" % (info_need_char, info_caseless))
            except Exception, e:
                print e
                pass
        self.verify_output(data, 'data')
        if self.find_all:
            results = pcre_find_all(compiled, self.data, extra=extra)
        else:
            result = pcre_exec(compiled, self.data, extra=extra)
            results = [result]
        return results

    def verify_output(self, line, state=''):
        #if state != '':
            #print '%d: state = "%s"' % (self.testinput_line_no, state)
        if self.testoutput:
            output_line = self.testoutput.readline()
            self.testoutput_line_no += 1
            if line != output_line:
                self.failed_tests += 1
                print 'error: testinput line %d, testoutput line %d' % (self.testinput_line_no, self.testoutput_line_no)
                print 'expected:\n%sgot:\n%s' % (output_line, line)
                print 'regex:\n"%s"\nopts:\n"%s"\nset_options:\n"0x%X"\ndata:\n"%s"\n' % (self.last_regex, self.last_opts, self.set_options, self.last_data)
        else:
            print line,

def main(args):
    tester = Tester()
    tester.testinput = args.testinput
    tester.testoutput = args.testoutput
    state = 'start' # 'start', 'empty line', 'regex', 'data', 'comment'
    regex = ''
    multiline_regex = False
    opts = ''
    data = ''

    sep = '' # regex separator
    for line in tester.testinput:
        tester.testinput_line_no += 1
        if len(line.strip()) == 0 and not state == 'regex':
            # empty line
            state = 'empty line'
            tester.verify_output(line, state)
            continue
        if line.startswith('/--') or (state == 'empty line' and line.startswith('  ')):
            state = 'comment'
            tester.verify_output(line, state)
            continue
        if line.startswith('< ') and not (state == 'regex' and multiline_regex):
            state = 'comment'
            tester.verify_output(line, state)
            continue
        if state == 'comment':
            tester.verify_output(line, state)
            continue
        if multiline_regex:
            tester.verify_output(line, state)
            regex_end = line.rfind(sep)
            if not(regex_end == -1 or line[regex_end - 1] == '\\'):
                # last regex line
                regex += line[:regex_end]
                opts = line[regex_end+1:-1]
                multiline_regex = False
            else:
                regex += line
            continue
        if state in ['start', 'empty line']:
            # regex
            state = 'regex'
            sep = line[0]
            regex_start = 0
            if sep == ' ':
                sep = line[1]
                regex_start = 1
            regex_end = line.rfind(sep)
            if regex_end in [-1, 0] or line[regex_end - 1] == '\\':
                multiline_regex = True
                regex = line[regex_start+1:]
                tester.verify_output(line, state)
                continue
            regex = line[regex_start+1:regex_end]
            opts = line[regex_end+1:-1].strip()
            tester.verify_output(line, state)
            continue
        # it can be only data
        first_data = False
        if state != 'data':
            first_data = True
        state = 'data'
        try:
            results = tester.test_match(regex, opts, line, use_jit=args.jit, first_data=first_data)
            data = tester.data # the processed data
        except Exception, e:
            print 'error: ', e
        else:
            if len(line.strip()):
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
                            #print 'mark:\n"%s"\n' % result.mark
                            line_out = 'MK: %s\n' % tester.process_output(result.mark)
                            tester.verify_output(line_out)
                    else:
                        line_out = 'No match\n'
                        if result.mark is not None:
                            line_out = 'No match, mark = %s\n' % result.mark
                        tester.verify_output(line_out)
        if len(line.strip()) == 0:
            state = 'empty line'
    if args.testoutput:
        if tester.failed_tests:
            print '\n%d failed tests' % tester.failed_tests
        else:
            print 'all tests passed'
        if tester.unhandled_opts:
            print 'unhandled options: %s' % ', '.join(tester.unhandled_opts)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='morelia-pcre test runner')
    parser.add_argument('--jit', action='store_true')
    parser.add_argument('testinput', type=argparse.FileType('r'))
    parser.add_argument('testoutput', nargs='?', type=argparse.FileType('r'))
    args = parser.parse_args()
    main(args)

