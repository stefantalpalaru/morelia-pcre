cimport cpcre

cdef extern from "Python.h":
    object PyString_FromStringAndSize(char *, Py_ssize_t)

cdef class Pcre:
    cdef cpcre.pcre *_c_pcre
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")
    def __dealloc__(self):
        if self._c_pcre is not NULL:
            cpcre.pcre_free(self._c_pcre)

cdef class PcreExtra:
    cdef cpcre.pcre_extra *_c_pcre_extra
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")
    def __dealloc__(self):
        if self._c_pcre_extra is not NULL:
            cpcre.pcre_free(self._c_pcre_extra)

cdef class ExecResult:
    cdef readonly:
        int result
        int num_matches
        bint captured_all
        object matches
        object named_matches
    def __cinit__(self):
        self.num_matches = 0
        self.captured_all = 1
        self.matches = []
        self.named_matches = {}

cpdef pcre_version():
    return cpcre.pcre_version()

cpdef pcre_compile(char *pattern, int options=0):
    cdef:
        char *error
        int erroffset
        cpcre.pcre *re
        Pcre pcre = Pcre.__new__(Pcre)

    re = cpcre.pcre_compile(pattern, options, &error, &erroffset, NULL)
    if re is NULL:
        raise Exception('PCRE compilation failed at offset %d (%s)' % (erroffset, error))
    pcre._c_pcre = re
    return pcre

cpdef pcre_study(Pcre re, int options=0):
    cdef:
        cpcre.pcre_extra *sd
        PcreExtra pcre_extra = PcreExtra.__new__(PcreExtra)
        char *error

    sd = cpcre.pcre_study(re._c_pcre, options, &error)
    if error is not NULL:
        raise Exception(error)
    pcre_extra._c_pcre_extra = sd
    return pcre_extra

cpdef pcre_exec(Pcre re, char *subject, int options=0, PcreExtra extra=None, int offset=0):
    cdef:
        int rc
        int subject_length = len(subject)
        int oveccount = 30
        int *ovector
        ExecResult exec_result = ExecResult()
        char **match_list
        int res
        int capture_count
        int namecount
        char *name_table
        int name_entry_size
        char *tabptr
        int i, n

    # replace the default with (the actual number of capturing subpatterns + 1) * 3
    res = cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, cpcre.PCRE_INFO_CAPTURECOUNT, &capture_count)
    if res == 0:
        oveccount = (capture_count + 1) * 3

    ovector = <int*>cpcre.pcre_malloc(oveccount * sizeof(int))
    if ovector is NULL:
        raise MemoryError()

    if extra is None:
        extra = PcreExtra.__new__(PcreExtra)
    rc = cpcre.pcre_exec(re._c_pcre, extra._c_pcre_extra, subject, subject_length, offset, options, ovector, oveccount)
    exec_result.result = rc
    if rc == 0:
        rc = oveccount / 3
        exec_result.captured_all = 0
    if rc > 0:
        exec_result.num_matches = rc
        res = cpcre.pcre_get_substring_list(subject, ovector, rc, &match_list)
        if res == 0:
            for i in range(rc):
                exec_result.matches.append(match_list[i])
            cpcre.pcre_free_substring_list(match_list)

    # named substringss
    cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, cpcre.PCRE_INFO_NAMECOUNT, &namecount)
    if namecount > 0:
        cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, cpcre.PCRE_INFO_NAMETABLE, &name_table)
        cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, cpcre.PCRE_INFO_NAMEENTRYSIZE, &name_entry_size)
        tabptr = name_table
        for i in range(namecount):
            n = (tabptr[0] << 8) | tabptr[1]
            substring_name = PyString_FromStringAndSize(tabptr + 2, name_entry_size - 3)
            #print 'named substring: %d, "%s", "%s"' % (n, substring_name, exec_result.matches[n])
            exec_result.named_matches[substring_name] = exec_result.matches[n]
            tabptr += name_entry_size


    return exec_result

