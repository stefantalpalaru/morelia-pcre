Introduction
************

For a long time, Python programmers have secretly envied Perl monks for their miraculous regex spells. The 're' module was offering little comfort and the various replacements never came close. It is time to bow our heads in awe and accepts the one true reusable incarnation: `Perl Compatible Regular Expressions (PCRE) <http://www.pcre.org>`_.

`morelia-pcre <https://github.com/stefantalpalaru/morelia-pcre>`_ is a set of Python bindings to PCRE, created using `Cython <http://www.cython.org>`_ for hackability and performance.

Short Example
=============

Here we go::

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

And the output::

    2 matches:
     "'foob'"
     "'foo'"
    named substrings:
    {'sna': 'foo'}
    *** find all ***
     "'foob'"
     "'foo'"
     "'FoOb'"
     "'FoO'"
