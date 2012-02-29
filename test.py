#!/usr/bin/env python

from pcre import *
from pprint import pprint

print pcre_version()
pattern = r'(?<bob>f)(.)(?<jim>o)'
#pattern = r'(xfo)o'
print 'pattern = "%s"' % pattern
compiled = pcre_compile(pattern)
#pprint(compiled)

subject = 'barfoobazfoo'
print 'subject = "%s"' % subject

extra = pcre_study(compiled)
result = pcre_exec(compiled, subject, extra=extra)
print '%d matches:' % result.num_matches
for i in xrange(result.num_matches):
    print ' "%s"' % result.matches[i]
pprint(result.named_matches)

