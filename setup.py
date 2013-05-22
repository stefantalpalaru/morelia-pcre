#!/usr/bin/env python

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name = 'morelia-pcre',
    version = '0.1',
    description = 'Python bindings for the Perl Compatible Regular Expressions (PCRE) library',
    author = 'Stefan Talpalaru',
    author_email = 'stefan.talpalaru@od-eon.com',
    url = 'https://github.com/stefantalpalaru/morelia-pcre',
    license = 'BSD',
    py_modules = ['pcre_re'],
    ext_modules = cythonize(Extension("pcre", ["pcre.pyx"], libraries=["pcre"]))
)
