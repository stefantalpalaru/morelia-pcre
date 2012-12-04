#
# Secret Labs' Regular Expression Engine
#
# re-compatible interface for the sre matching engine
#
# Copyright (c) 1998-2001 by Secret Labs AB.  All rights reserved.
#
# This version of the SRE library can be redistributed under CNRI's
# Python 1.6 license.  For any other use, please contact Secret Labs
# AB (info@pythonware.com).
#
# Portions of this engine have been developed in cooperation with
# CNRI.  Hewlett-Packard provided funding for 1.6 integration and
# other compatibility work.
#
# 2012: ported to morelia-pcre by Stefan Talpalaru <stefan.talpalaru@od-eon.com>

r"""Support for regular expressions (RE).

This module provides regular expression matching operations similar to
those found in Perl.  It supports both 8-bit and Unicode strings; both
the pattern and the strings being processed can contain null bytes and
characters outside the US ASCII range.

Regular expressions can contain both special and ordinary characters.
Most ordinary characters, like "A", "a", or "0", are the simplest
regular expressions; they simply match themselves.  You can
concatenate ordinary characters, so last matches the string 'last'.

The special characters are:
    "."      Matches any character except a newline.
    "^"      Matches the start of the string.
    "$"      Matches the end of the string or just before the newline at
             the end of the string.
    "*"      Matches 0 or more (greedy) repetitions of the preceding RE.
             Greedy means that it will match as many repetitions as possible.
    "+"      Matches 1 or more (greedy) repetitions of the preceding RE.
    "?"      Matches 0 or 1 (greedy) of the preceding RE.
    *?,+?,?? Non-greedy versions of the previous three special characters.
    {m,n}    Matches from m to n repetitions of the preceding RE.
    {m,n}?   Non-greedy version of the above.
    "\\"     Either escapes special characters or signals a special sequence.
    []       Indicates a set of characters.
             A "^" as the first character indicates a complementing set.
    "|"      A|B, creates an RE that will match either A or B.
    (...)    Matches the RE inside the parentheses.
             The contents can be retrieved or matched later in the string.
    (?iLmsux) Set the I, L, M, S, U, or X flag for the RE (see below).
    (?:...)  Non-grouping version of regular parentheses.
    (?P<name>...) The substring matched by the group is accessible by name.
    (?P=name)     Matches the text matched earlier by the group named name.
    (?#...)  A comment; ignored.
    (?=...)  Matches if ... matches next, but doesn't consume the string.
    (?!...)  Matches if ... doesn't match next.
    (?<=...) Matches if preceded by ... (must be fixed length).
    (?<!...) Matches if not preceded by ... (must be fixed length).
    (?(id/name)yes|no) Matches yes pattern if the group with id/name matched,
                       the (optional) no pattern otherwise.

The special sequences consist of "\\" and a character from the list
below.  If the ordinary character is not on the list, then the
resulting RE will match the second character.
    \number  Matches the contents of the group of the same number.
    \A       Matches only at the start of the string.
    \Z       Matches only at the end of the string.
    \b       Matches the empty string, but only at the start or end of a word.
    \B       Matches the empty string, but not at the start or end of a word.
    \d       Matches any decimal digit; equivalent to the set [0-9].
    \D       Matches any non-digit character; equivalent to the set [^0-9].
    \s       Matches any whitespace character; equivalent to [ \t\n\r\f\v].
    \S       Matches any non-whitespace character; equiv. to [^ \t\n\r\f\v].
    \w       Matches any alphanumeric character; equivalent to [a-zA-Z0-9_].
             With LOCALE, it will match the set [0-9_] plus characters defined
             as letters for the current locale.
    \W       Matches the complement of \w.
    \\       Matches a literal backslash.

This module exports the following functions:
    match    Match a regular expression pattern to the beginning of a string.
    search   Search a string for the presence of a pattern.
    sub      Substitute occurrences of a pattern found in a string.
    subn     Same as sub, but also return the number of substitutions made.
    split    Split a string by the occurrences of a pattern.
    findall  Find all occurrences of a pattern in a string.
    finditer Return an iterator yielding a match object for each match.
    compile  Compile a pattern into a RegexObject.
    purge    Clear the regular expression cache.
    escape   Backslash all non-alphanumerics in a string.

Some of the functions in this module takes flags as optional parameters:
    I  IGNORECASE  Perform case-insensitive matching.
    L  LOCALE      Make \w, \W, \b, \B, dependent on the current locale.
    M  MULTILINE   "^" matches the beginning of lines (after a newline)
                   as well as the string.
                   "$" matches the end of lines (before a newline) as well
                   as the end of the string.
    S  DOTALL      "." matches any character at all, including the newline.
    X  VERBOSE     Ignore whitespace and comments for nicer looking RE's.
    U  UNICODE     Make \w, \W, \b, \B, dependent on the Unicode locale.

This module also defines an exception 'error'.

"""

import sys
#import sre_compile
import sre_parse
import re
from pcre import *

# public symbols
__all__ = [ "match", "search", "sub", "subn", "split", "findall",
    "compile", "purge", "template", "escape", "I", "L", "M", "S", "X",
    "U", "IGNORECASE", "LOCALE", "MULTILINE", "DOTALL", "VERBOSE",
    "UNICODE", "error" ]

__version__ = "2.2.1"

# flags
#I = IGNORECASE = sre_compile.SRE_FLAG_IGNORECASE # ignore case
I = IGNORECASE = PCRE_CASELESS # ignore case
#L = LOCALE = sre_compile.SRE_FLAG_LOCALE # assume current 8-bit locale
L = LOCALE = 0 # assume current 8-bit locale
#U = UNICODE = sre_compile.SRE_FLAG_UNICODE # assume unicode locale
U = UNICODE = PCRE_UCP|PCRE_UTF8 # assume unicode locale
#M = MULTILINE = sre_compile.SRE_FLAG_MULTILINE # make anchors look for newline
M = MULTILINE = PCRE_MULTILINE # make anchors look for newline
#S = DOTALL = sre_compile.SRE_FLAG_DOTALL # make dot match newline
S = DOTALL = PCRE_DOTALL # make dot match newline
#X = VERBOSE = sre_compile.SRE_FLAG_VERBOSE # ignore whitespace and comments
X = VERBOSE = PCRE_EXTENDED # ignore whitespace and comments

# sre extensions (experimental, don't rely on these)
#T = TEMPLATE = sre_compile.SRE_FLAG_TEMPLATE # disable backtracking
#DEBUG = sre_compile.SRE_FLAG_DEBUG # dump pattern after compilation

# sre exception
#error = sre_compile.error
error = PcreException

# --------------------------------------------------------------------
# classes

class SRE_Match(object):
    lastindex = None
    lastgroup = None
    def __init__(self, exec_result, re, string, pos=0, endpos=None):
        self.pcre_exec_result = exec_result
        self.re = re
        self.string = string
        self.pos = pos
        self.endpos = endpos
        self.regs = tuple(zip(exec_result.start_offsets, exec_result.end_offsets))
        # lastindex and lastgroup
        if re.groups > 0:
            last_index = 0
            end_offset = -1
            length = 0
            for i in xrange(1, exec_result.num_matches):
                if exec_result.matches[i] is None:
                    m_len = 0
                else:
                    m_len = len(exec_result.matches[i])
                if exec_result.end_offsets[i] > end_offset:
                    end_offset = exec_result.end_offsets[i]
                    length = m_len
                    last_index = i
                elif exec_result.end_offsets[i] == end_offset:
                    if m_len > length:
                        length = m_len
                        last_index = i
            if last_index:
                self.lastindex = last_index
                for name in re.groupindex:
                    if re.groupindex[name] == last_index:
                        self.lastgroup = name
                        break
    def expand(self, template):
        return _expand(self.re, self, template)
    def group(self, *args):
        pargs = [] # processed args
        for arg in args:
            if _isstring(arg):
                try:
                    pargs.append(self.re.groupindex[arg])
                except:
                    raise IndexError('no such group')
            else:
                pargs.append(arg)
        try:
            if len(pargs) == 0:
                res = self.pcre_exec_result.matches[0]
            elif len(pargs) == 1:
                res = self.pcre_exec_result.matches[pargs[0]]
            else:
                res = tuple([self.pcre_exec_result.matches[arg] for arg in pargs])
        except:
            raise IndexError('no such group')
        return res
    def groups(self, default=None):
        return tuple([default if m is None else m for m in self.pcre_exec_result.matches[1:]])
    def groupdict(self, default=None):
        return dict([(n, default if m is None else m) for n, m in self.pcre_exec_result.named_matches.items()])
    def start(self, group=0):
        try:
            return self.pcre_exec_result.start_offsets[group]
        except:
            raise IndexError('no such group')
    def end(self, group=0):
        try:
            return self.pcre_exec_result.end_offsets[group]
        except:
            raise IndexError('no such group')
    def span(self, group=0):
        return (self.start(group), self.end(group))

class SRE_Pattern(object):
    def __init__(self, pattern, flags):
        self.pattern = pattern
        self.flags = flags
        # handle internal options with a different syntax from PCRE
        pat = pcre_sub(pcre_compile(r'(\(\?[imsux]*)L([imsux]*\))'), r'{0}{1}', pattern)
        pat = pcre_sub(pcre_compile(r'(\(\?[imsx]*)u([imsx]*\))'), r'(*UTF)(*UCP){0}{1}', pat)
        self.pcre_compiled = pcre_compile(pat, flags)
        self.pcre_extra = pcre_study(self.pcre_compiled, flags)
        pcre_info(self.pcre_compiled, self.pcre_extra)
        self.groups = self.pcre_compiled.groups
        self.groupindex = self.pcre_compiled.groupindex
    def search(self, string, pos=0, endpos=None):
        if not _isstring(string):
            string = unicode(string)
        orig_string = string
        if endpos is not None:
            if endpos < pos:
                return None
            string = string[:endpos]
        else:
            endpos = len(string)
        exec_result = pcre_exec(self.pcre_compiled, string, self.flags, self.pcre_extra, pos)
        if exec_result.num_matches == 0:
            return None
        match = SRE_Match(exec_result, self, orig_string, pos, endpos)
        return match
    def match(self, string, pos=0, endpos=None):
        if not _isstring(string):
            string = unicode(string)
        already_anchored = self.flags & PCRE_ANCHORED
        if not already_anchored:
            self.flags |= PCRE_ANCHORED
        res = self.search(string, pos, endpos)
        if not already_anchored:
            self.flags &= ~PCRE_ANCHORED
        return res
    def split(self, string, maxsplit=0):
        if not _isstring(string):
            raise TypeError('expected string or buffer')
        return pcre_split(self.pcre_compiled, string, maxsplit, self.flags, self.pcre_extra)
    def findall(self, string, pos=0, endpos=None):
        if not _isstring(string):
            raise TypeError('expected string or buffer')
        if endpos is not None:
            if endpos < pos:
                return None
            string = string[:endpos]
        res = []
        for result in pcre_find_all(self.pcre_compiled, string, self.flags, self.pcre_extra, pos):
            matches = ['' if match is None else match for match in result.matches]
            if len(matches) == 1:
                res.append(matches[0])
            elif len(matches) == 2:
                res.append(matches[1])
            else:
                res.append(tuple(matches[1:]))
        return res
    def finditer(self, string, pos=0, endpos=None):
        if not _isstring(string):
            raise TypeError('expected string or buffer')
        orig_string = string
        if endpos is not None:
            if endpos < pos:
                return None
            string = string[:endpos]
        else:
            endpos = len(string)
        class Iterator():
            def __init__(self, string, orig_string, pos, endpos, re):
                self.orig_string = orig_string
                self.re = re
                self.pos = pos
                self.endpos = endpos
                self.results = pcre_find_all(re.pcre_compiled, string, re.flags, re.pcre_extra, pos)
                self.index = -1
            def __iter__(self):
                return self
            def next(self):
                try:
                    self.index += 1
                    return SRE_Match(self.results[self.index], self.re, self.orig_string, self.pos, self.endpos)
                except IndexError:
                    raise StopIteration
        return Iterator(string, orig_string, pos, endpos, self)
    def subn(self, repl, string, count=0):
        last_index = 0
        last_match = ''
        counter = 0
        pieces = []
        if not hasattr(repl, '__call__'):
            repl = lambda match, template=repl: match.expand(template)
        for match in self.finditer(string):
            if last_match != '' and match.group() == '' and last_index == match.pcre_exec_result.start_offsets[0]:
                continue
            last_match = match.group()
            counter += 1
            pieces.append(string[last_index:match.pcre_exec_result.start_offsets[0]])
            last_index = match.pcre_exec_result.end_offsets[0]
            try:
                pieces.append(repl(match))
            except IndexError:
                raise
            except Exception, e:
                raise error(e)
            if count and count == counter:
                break
        pieces.append(string[last_index:])
        return string[:0].join(pieces), counter
    def sub(self, repl, string, count=0):
        return self.subn(repl, string, count)[0]
    def scanner(self, *args):
        """
        undocumented but appears in tests and might be used in the wild
        so let's have it but don't bother converting it to PCRE
        """
        return re.compile(self.pattern, self.flags).scanner(*args)



# --------------------------------------------------------------------
# public interface

def match(pattern, string, flags=0):
    """Try to apply the pattern at the start of the string, returning
    a match object, or None if no match was found."""
    return _compile(pattern, flags).match(string)

def search(pattern, string, flags=0):
    """Scan through string looking for a match to the pattern, returning
    a match object, or None if no match was found."""
    return _compile(pattern, flags).search(string)

def sub(pattern, repl, string, count=0, flags=0):
    """Return the string obtained by replacing the leftmost
    non-overlapping occurrences of the pattern in string by the
    replacement repl.  repl can be either a string or a callable;
    if a string, backslash escapes in it are processed.  If it is
    a callable, it's passed the match object and must return
    a replacement string to be used."""
    return _compile(pattern, flags).sub(repl, string, count)

def subn(pattern, repl, string, count=0, flags=0):
    """Return a 2-tuple containing (new_string, number).
    new_string is the string obtained by replacing the leftmost
    non-overlapping occurrences of the pattern in the source
    string by the replacement repl.  number is the number of
    substitutions that were made. repl can be either a string or a
    callable; if a string, backslash escapes in it are processed.
    If it is a callable, it's passed the match object and must
    return a replacement string to be used."""
    return _compile(pattern, flags).subn(repl, string, count)

def split(pattern, string, maxsplit=0, flags=0):
    """Split the source string by the occurrences of the pattern,
    returning a list containing the resulting substrings."""
    return _compile(pattern, flags).split(string, maxsplit)

def findall(pattern, string, flags=0):
    """Return a list of all non-overlapping matches in the string.

    If one or more groups are present in the pattern, return a
    list of groups; this will be a list of tuples if the pattern
    has more than one group.

    Empty matches are included in the result."""
    return _compile(pattern, flags).findall(string)

if sys.hexversion >= 0x02020000:
    __all__.append("finditer")
    def finditer(pattern, string, flags=0):
        """Return an iterator over all non-overlapping matches in the
        string.  For each match, the iterator returns a match object.

        Empty matches are included in the result."""
        return _compile(pattern, flags).finditer(string)

def compile(pattern, flags=0):
    "Compile a regular expression pattern, returning a pattern object."
    return _compile(pattern, flags)

def purge():
    "Clear the regular expression cache"
    _cache.clear()
    _cache_repl.clear()

def template(pattern, flags=0):
    "Compile a template pattern, returning a pattern object"
    return _compile(pattern, flags|T)

_alphanum = frozenset(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

def escape(pattern):
    "Escape all non-alphanumeric characters in pattern."
    s = list(pattern)
    alphanum = _alphanum
    for i, c in enumerate(pattern):
        if c not in alphanum:
            if c == "\000":
                s[i] = "\\000"
            else:
                s[i] = "\\" + c
    return pattern[:0].join(s)

# --------------------------------------------------------------------
# internals

_cache = {}
_cache_repl = {}

#_pattern_type = type(sre_compile.compile("", 0))
_pattern_type = SRE_Pattern

_MAXCACHE = 100

def _compile(*key):
    # internal: compile pattern
    cachekey = (type(key[0]),) + key
    p = _cache.get(cachekey)
    if p is not None:
        return p
    pattern, flags = key
    if isinstance(pattern, _pattern_type):
        if flags:
            raise ValueError('Cannot process flags argument with a compiled pattern')
        return pattern
    #if not sre_compile.isstring(pattern):
    if not _isstring(pattern):
        raise TypeError, "first argument must be string or compiled pattern"
    try:
        #p = sre_compile.compile(pattern, flags)
        p = SRE_Pattern(pattern, flags)
    except error, v:
        raise error, v # invalid expression
    if len(_cache) >= _MAXCACHE:
        _cache.clear()
    _cache[cachekey] = p
    return p

def _compile_repl(*key):
    # internal: compile replacement pattern
    p = _cache_repl.get(key)
    if p is not None:
        return p
    repl, pattern = key
    try:
        p = sre_parse.parse_template(repl, pattern)
    except error, v:
        raise error, v # invalid expression
    if len(_cache_repl) >= _MAXCACHE:
        _cache_repl.clear()
    _cache_repl[key] = p
    return p

def _expand(pattern, match, template):
    # internal: match.expand implementation hook
    template = sre_parse.parse_template(template, pattern)
    return sre_parse.expand_template(template, match)

def _subx(pattern, template):
    # internal: pattern.sub/subn implementation helper
    template = _compile_repl(template, pattern)
    if not template[0] and len(template[1]) == 1:
        # literal replacement
        return template[1][0]
    def filter(match, template=template):
        return sre_parse.expand_template(template, match)
    return filter

def _isstring(s):
    if isinstance(s, str) or isinstance(s, unicode):
        return 1
    return 0

# register myself for pickling

import copy_reg

def _pickle(p):
    return _compile, (p.pattern, p.flags)

copy_reg.pickle(_pattern_type, _pickle, _compile)

# --------------------------------------------------------------------
# experimental stuff (see python-dev discussions for details)

class Scanner:
    def __init__(self, lexicon, flags=0):
        from sre_constants import BRANCH, SUBPATTERN
        self.lexicon = lexicon
        # combine phrases into a compound pattern
        p = []
        s = sre_parse.Pattern()
        s.flags = flags
        for phrase, action in lexicon:
            p.append(sre_parse.SubPattern(s, [
                (SUBPATTERN, (len(p)+1, sre_parse.parse(phrase, flags))),
                ]))
        s.groups = len(p)+1
        p = sre_parse.SubPattern(s, [(BRANCH, (None, p))])
        self.scanner = sre_compile.compile(p)
    def scan(self, string):
        result = []
        append = result.append
        match = self.scanner.scanner(string).match
        i = 0
        while 1:
            m = match()
            if not m:
                break
            j = m.end()
            if i == j:
                break
            action = self.lexicon[m.lastindex-1][1]
            if hasattr(action, '__call__'):
                self.match = m
                action = action(self, m.group())
            if action is not None:
                append(action)
            i = j
        return result, string[i:]
