#!/usr/bin/env python

import pcre
from pprint import pprint

pattern = r'(?<sna>fo{2})b'
subject = 'foobar FoObaz'
options = pcre.PCRE_CASELESS

compiled = pcre.pcre_compile(pattern, options)
extra = pcre.pcre_study(compiled)
result = pcre.pcre_exec(compiled, subject, extra=extra)

# find the first match
print('%d matches:' % result.num_matches)
for i in xrange(result.num_matches):
    print(' "%s"' % repr(result.matches[i]))
print('named substrings:')
pprint(result.named_matches)

# find all the matches
results = pcre.pcre_find_all(compiled, subject, extra=extra)
print '*** find all ***'
for result in results:
    for i in xrange(result.num_matches):
        print(' "%s"' % repr(result.matches[i]))
