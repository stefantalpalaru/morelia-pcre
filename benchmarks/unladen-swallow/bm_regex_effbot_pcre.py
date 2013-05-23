#!/usr/bin/env python

"""Benchmarks for Python's regex engine.

These are some of the original benchmarks used to tune Python's regex engine
in 2000 written by Fredrik Lundh. Retreived from
http://mail.python.org/pipermail/python-dev/2000-August/007797.html and
integrated into Unladen Swallow's perf.py in 2009 by David Laing.

These benchmarks are of interest since they helped to guide the original
optimization of the sre engine, and we shouldn't necessarily ignore them just
because they're "old".
"""

# Python imports
import optparse
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))
import pcre_re as re
import time

# Local imports
import util

# These are the regular expressions to be tested. These sync up,
# index-for-index with the list of strings generated by gen_string_table()
# below.
regexs = [
    re.compile('Python|Perl'),
    re.compile('Python|Perl'),
    re.compile('(Python|Perl)'),
    re.compile('(?:Python|Perl)'),
    re.compile('Python'),
    re.compile('Python'),
    re.compile('.*Python'),
    re.compile('.*Python.*'),
    re.compile('.*(Python)'),
    re.compile('.*(?:Python)'),
    re.compile('Python|Perl|Tcl'),
    re.compile('Python|Perl|Tcl'),
    re.compile('(Python|Perl|Tcl)'),
    re.compile('(?:Python|Perl|Tcl)'),
    re.compile('(Python)\\1'),
    re.compile('(Python)\\1'),
    re.compile('([0a-z][a-z0-9]*,)+'),
    re.compile('(?:[0a-z][a-z0-9]*,)+'),
    re.compile('([a-z][a-z0-9]*,)+'),
    re.compile('(?:[a-z][a-z0-9]*,)+'),
    re.compile('.*P.*y.*t.*h.*o.*n.*')]


def gen_string_table(n):
    """Generates the list of strings that will be used in the benchmarks.

    All strings have repeated prefixes and suffices, and n specifies the
    number of repetitions.
    """
    strings = []
    strings.append('-'*n+'Perl'+'-'*n)
    strings.append('P'*n+'Perl'+'P'*n)
    strings.append('-'*n+'Perl'+'-'*n)
    strings.append('-'*n+'Perl'+'-'*n)
    strings.append('-'*n+'Python'+'-'*n)
    strings.append('P'*n+'Python'+'P'*n)
    strings.append('-'*n+'Python'+'-'*n)
    strings.append('-'*n+'Python'+'-'*n)
    strings.append('-'*n+'Python'+'-'*n)
    strings.append('-'*n+'Python'+'-'*n)
    strings.append('-'*n+'Perl'+'-'*n)
    strings.append('P'*n+'Perl'+'P'*n)
    strings.append('-'*n+'Perl'+'-'*n)
    strings.append('-'*n+'Perl'+'-'*n)
    strings.append('-'*n+'PythonPython'+'-'*n)
    strings.append('P'*n+'PythonPython'+'P'*n)
    strings.append('-'*n+'a5,b7,c9,'+'-'*n)
    strings.append('-'*n+'a5,b7,c9,'+'-'*n)
    strings.append('-'*n+'a5,b7,c9,'+'-'*n)
    strings.append('-'*n+'a5,b7,c9,'+'-'*n)
    strings.append('-'*n+'Python'+'-'*n)
    return strings

# A cache for the generated strings.
string_tables = {}

def init_benchmarks(n_values=None):
    """Initialize the strings we'll run the regexes against.

    The strings used in the benchmark are prefixed and suffixed by
    strings that are repeated n times.

    The sequence n_values contains the values for n.
    If n_values is None the values of n from the original benchmark
    are used.

    The generated list of strings is cached in the string_tables
    variable, which is indexed by n.

    Returns:
    A list of string prefix/suffix lengths.
    """
    if n_values is None:
        n_values = [0, 5, 50, 250, 1000, 5000, 10000]

    for n in n_values:
        string_tables[n] = gen_string_table(n)
    return n_values


def run_benchmarks(n):
    """Runs all of the benchmarks for a given value of n."""
    for id in xrange(len(regexs)):
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])
        re.search(regexs[id], string_tables[n][id])


def test_regex_effbot(iterations):
    sizes = init_benchmarks()

    # Warm up.
    for size in sizes:
        run_benchmarks(size)

    times = []
    for i in xrange(iterations):
        t0 = time.time()
        for size in sizes:
            run_benchmarks(size)
        t1 = time.time()
        times.append(t1 - t0)
    return times


if __name__ == '__main__':
    parser = optparse.OptionParser(
        usage="%prog [options]",
        description=("Test the performance of regexps using Fredik Lundh's "
                     "benchmarks."))
    util.add_standard_options_to(parser)
    options, args = parser.parse_args()

    util.run_benchmark(options, options.num_runs, test_regex_effbot)
