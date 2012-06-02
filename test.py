#!/usr/bin/env python

from pcre import *
from pprint import pprint

print pcre_version()
for pattern, subject, options in [
    [r'(?<bob>f)(.)(?<jim>o)', 'barfoObazfoo', 0 | PCRE_CASELESS],
    ['abcd\\t\\n\\r\\f\\a\\e\\071\\x3b\\$\\\\\\?caxyz', 'abcd\\t\\n\\r\\f\\a\\e9;\\$\\\\?caxyz', 0],
    [r'abcd\t\n\r\f\a\e\071\x3b\$\\\?caxyz', 'abcd\t\n\r\f\a\x1b9;\$\\?caxyz', 0],
    [r'abcd\t\n\r\f\a\e\071\x3b\$\\\?caxyz', 'abcd\t\n\r\f\a\x1b9;$\\?caxyz', 0],
    [r'foo@bar', 'foo\@bar', 0],
    ['foo\\0bar', 'foo\0bar', 0],
    ['foo\\0bar\\00baz', 'foo\0bar\00baz', 0],
    ['abc\\0def\\00pqr\\000xyz\\0000AB', 'abc\0def\00pqr\000xyz\0000AB', 0],
    ['a.b', 'xaabcaxbaybzzzaaaBbbx', PCRE_CASELESS],
    ['\\b', 'abc', 0],
    ['', 'abc', 0],
]:
    print 'pattern = "%r"' % pattern
    compiled = pcre_compile(pattern, options)
    print 'subject = "%r"' % subject
    extra = pcre_study(compiled)
    result = pcre_exec(compiled, subject, extra=extra)
    print '%d matches:' % result.num_matches
    for i in xrange(result.num_matches):
        print ' "%s"' % repr(result.matches[i])
    pprint(result.named_matches)
    # find all
    results = pcre_find_all(compiled, subject, extra=extra)
    if len(results) > 1:
        print '*** find all ***'
        for result in results:
            for i in xrange(result.num_matches):
                print ' "%s"' % repr(result.matches[i])

