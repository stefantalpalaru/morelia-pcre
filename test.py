#!/usr/bin/env python

from pcre import *
from pprint import pprint

print pcre_version()
for pattern, subject, options in [
    [r'(?<bob>f)(.)(?<jim>o)', 'barfoObazfoo', 0 | PCRE_CASELESS],
    ['abcd\t\n\r\x0c\x07\\e9;\\$\\\\?caxyz', 'abcd\t\n\r\x0c\x07\\e9;\\$\\?caxyz', 0],
]:
    print 'pattern = "%s"' % pattern
    compiled = pcre_compile(pattern, options)
    print 'subject = "%s"' % subject
    extra = pcre_study(compiled)
    result = pcre_exec(compiled, subject, extra=extra)
    print '%d matches:' % result.num_matches
    for i in xrange(result.num_matches):
        print ' "%s"' % result.matches[i]
    pprint(result.named_matches)

