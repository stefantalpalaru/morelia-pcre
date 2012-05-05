#cython: embedsignature=True

cimport cpcre

PCRE_CASELESS =           0x00000001  # Compile 
PCRE_MULTILINE =          0x00000002  # Compile 
PCRE_DOTALL =             0x00000004  # Compile 
PCRE_EXTENDED =           0x00000008  # Compile 
PCRE_ANCHORED =           0x00000010  # Compile, exec, DFA exec 
PCRE_DOLLAR_ENDONLY =     0x00000020  # Compile, used in exec, DFA exec 
PCRE_EXTRA =              0x00000040  # Compile 
PCRE_NOTBOL =             0x00000080  # Exec, DFA exec 
PCRE_NOTEOL =             0x00000100  # Exec, DFA exec 
PCRE_UNGREEDY =           0x00000200  # Compile 
PCRE_NOTEMPTY =           0x00000400  # Exec, DFA exec 
PCRE_UTF8 =               0x00000800  # Compile (same as PCRE_UTF16)
PCRE_UTF16 =              0x00000800  # Compile (same as PCRE_UTF8)
PCRE_NO_AUTO_CAPTURE =    0x00001000  # Compile 
PCRE_NO_UTF8_CHECK =      0x00002000  # Compile (same as PCRE_NO_UTF16_CHECK)
PCRE_NO_UTF16_CHECK =     0x00002000  # Compile (same as PCRE_NO_UTF8_CHECK)
PCRE_AUTO_CALLOUT =       0x00004000  # Compile 
PCRE_PARTIAL_SOFT =       0x00008000  # Exec, DFA exec 
PCRE_PARTIAL =            0x00008000  # Backwards compatible synonym 
PCRE_DFA_SHORTEST =       0x00010000  # DFA exec 
PCRE_DFA_RESTART =        0x00020000  # DFA exec 
PCRE_FIRSTLINE =          0x00040000  # Compile, used in exec, DFA exec 
PCRE_DUPNAMES =           0x00080000  # Compile 
PCRE_NEWLINE_CR =         0x00100000  # Compile, exec, DFA exec 
PCRE_NEWLINE_LF =         0x00200000  # Compile, exec, DFA exec 
PCRE_NEWLINE_CRLF =       0x00300000  # Compile, exec, DFA exec 
PCRE_NEWLINE_ANY =        0x00400000  # Compile, exec, DFA exec 
PCRE_NEWLINE_ANYCRLF =    0x00500000  # Compile, exec, DFA exec 
PCRE_BSR_ANYCRLF =        0x00800000  # Compile, exec, DFA exec 
PCRE_BSR_UNICODE =        0x01000000  # Compile, exec, DFA exec 
PCRE_JAVASCRIPT_COMPAT =  0x02000000  # Compile, used in exec 
PCRE_NO_START_OPTIMIZE =  0x04000000  # Compile, exec, DFA exec 
PCRE_NO_START_OPTIMISE =  0x04000000  # Synonym 
PCRE_PARTIAL_HARD =       0x08000000  # Exec, DFA exec 
PCRE_NOTEMPTY_ATSTART =   0x10000000  # Exec, DFA exec 
PCRE_UCP =                0x20000000  # Compile, used in exec, DFA exec 

# Exec-time and get/set-time error codes

PCRE_ERROR_NOMATCH =         (-1)
PCRE_ERROR_NULL =            (-2)
PCRE_ERROR_BADOPTION =       (-3)
PCRE_ERROR_BADMAGIC =        (-4)
PCRE_ERROR_UNKNOWN_OPCODE =  (-5)
PCRE_ERROR_UNKNOWN_NODE =    (-5)  # For backward compatibility 
PCRE_ERROR_NOMEMORY =        (-6)
PCRE_ERROR_NOSUBSTRING =     (-7)
PCRE_ERROR_MATCHLIMIT =      (-8)
PCRE_ERROR_CALLOUT =         (-9)  # Never used by PCRE itself 
PCRE_ERROR_BADUTF8 =        (-10)
PCRE_ERROR_BADUTF16 =        (-10)
PCRE_ERROR_BADUTF8_OFFSET = (-11)
PCRE_ERROR_BADUTF16_OFFSET = (-11)
PCRE_ERROR_PARTIAL =        (-12)
PCRE_ERROR_BADPARTIAL =     (-13)
PCRE_ERROR_INTERNAL =       (-14)
PCRE_ERROR_BADCOUNT =       (-15)
PCRE_ERROR_DFA_UITEM =      (-16)
PCRE_ERROR_DFA_UCOND =      (-17)
PCRE_ERROR_DFA_UMLIMIT =    (-18)
PCRE_ERROR_DFA_WSSIZE =     (-19)
PCRE_ERROR_DFA_RECURSE =    (-20)
PCRE_ERROR_RECURSIONLIMIT = (-21)
PCRE_ERROR_NULLWSLIMIT =    (-22)  # No longer actually used 
PCRE_ERROR_BADNEWLINE =     (-23)
PCRE_ERROR_BADOFFSET =      (-24)
PCRE_ERROR_SHORTUTF8 =      (-25)
PCRE_ERROR_SHORTUTF16 =      (-25)
PCRE_ERROR_RECURSELOOP =    (-26)
PCRE_ERROR_JIT_STACKLIMIT = (-27)
PCRE_ERROR_BADMODE =        (-28)
PCRE_ERROR_BADENDIANNESS =  (-29)


# Specific error codes for UTF-8 validity checks 

PCRE_UTF8_ERR0 =               0
PCRE_UTF8_ERR1 =               1
PCRE_UTF8_ERR2 =               2
PCRE_UTF8_ERR3 =               3
PCRE_UTF8_ERR4 =               4
PCRE_UTF8_ERR5 =               5
PCRE_UTF8_ERR6 =               6
PCRE_UTF8_ERR7 =               7
PCRE_UTF8_ERR8 =               8
PCRE_UTF8_ERR9 =               9
PCRE_UTF8_ERR10 =             10
PCRE_UTF8_ERR11 =             11
PCRE_UTF8_ERR12 =             12
PCRE_UTF8_ERR13 =             13
PCRE_UTF8_ERR14 =             14
PCRE_UTF8_ERR15 =             15
PCRE_UTF8_ERR16 =             16
PCRE_UTF8_ERR17 =             17
PCRE_UTF8_ERR18 =             18
PCRE_UTF8_ERR19 =             19
PCRE_UTF8_ERR20 =             20
PCRE_UTF8_ERR21 =             21

# Specific error codes for UTF-16 validity checks 

PCRE_UTF16_ERR0 =              0
PCRE_UTF16_ERR1 =              1
PCRE_UTF16_ERR2 =              2
PCRE_UTF16_ERR3 =              3
PCRE_UTF16_ERR4 =              4

# Request types for pcre_fullinfo() 

PCRE_INFO_OPTIONS =            0
PCRE_INFO_SIZE =               1
PCRE_INFO_CAPTURECOUNT =       2
PCRE_INFO_BACKREFMAX =         3
PCRE_INFO_FIRSTBYTE =          4
PCRE_INFO_FIRSTCHAR =          4  # For backwards compatibility 
PCRE_INFO_FIRSTTABLE =         5
PCRE_INFO_LASTLITERAL =        6
PCRE_INFO_NAMEENTRYSIZE =      7
PCRE_INFO_NAMECOUNT =          8
PCRE_INFO_NAMETABLE =          9
PCRE_INFO_STUDYSIZE =         10
PCRE_INFO_DEFAULT_TABLES =    11
PCRE_INFO_OKPARTIAL =         12
PCRE_INFO_JCHANGED =          13
PCRE_INFO_HASCRORLF =         14
PCRE_INFO_MINLENGTH =         15
PCRE_INFO_JIT =               16
PCRE_INFO_JITSIZE =           17

# Request types for pcre_config(). Do not re-arrange, in order to remain compatible.

PCRE_CONFIG_UTF8 =                    0
PCRE_CONFIG_NEWLINE =                 1
PCRE_CONFIG_LINK_SIZE =               2
PCRE_CONFIG_POSIX_MALLOC_THRESHOLD =  3
PCRE_CONFIG_MATCH_LIMIT =             4
PCRE_CONFIG_STACKRECURSE =            5
PCRE_CONFIG_UNICODE_PROPERTIES =      6
PCRE_CONFIG_MATCH_LIMIT_RECURSION =   7
PCRE_CONFIG_BSR =                     8
PCRE_CONFIG_JIT =                     9
PCRE_CONFIG_UTF16 =                  10
PCRE_CONFIG_JITTARGET =              11

# Request types for pcre_study(). Do not re-arrange, in order to remain compatible.

PCRE_STUDY_JIT_COMPILE =            0x0001

# Bit flags for the pcre_extra structure. Do not re-arrange or redefine
# these bits, just add new ones on the end, in order to remain compatible.

PCRE_EXTRA_STUDY_DATA =             0x0001
PCRE_EXTRA_MATCH_LIMIT =            0x0002
PCRE_EXTRA_CALLOUT_DATA =           0x0004
PCRE_EXTRA_TABLES =                 0x0008
PCRE_EXTRA_MATCH_LIMIT_RECURSION =  0x0010
PCRE_EXTRA_MARK =                   0x0020
PCRE_EXTRA_EXECUTABLE_JIT =         0x0040

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
        object set_matches # list of booleans indicaing if the corresponding 'matches' elements are set
        object matches
        object named_matches
    def __cinit__(self):
        self.num_matches = 0
        self.captured_all = 1
        self.set_matches = []
        self.matches = []
        self.named_matches = {}

cdef process_text(text):
    if isinstance(text, unicode):
        text = text.encode('UTF-8')
    return text

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

cpdef pcre_exec(Pcre re, subject, int options=0, PcreExtra extra=None, int offset=0):
    subject = process_text(subject)
    cdef:
        int rc
        int subject_length = len(subject)
        int oveccount = 30
        int *ovector
        ExecResult exec_result = ExecResult()
        char *match_ptr
        int res
        int capture_count
        int namecount
        char *name_table
        int name_entry_size
        char *tabptr
        int i, n

    # replace the default with (the actual number of capturing subpatterns + 1) * 3
    res = cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_CAPTURECOUNT, &capture_count)
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
        for i in range(rc):
            match_len = cpcre.pcre_get_substring(subject, ovector, rc, i, &match_ptr)
            if match_len < 0:
                raise Exception('error getting the match #%d' % i)
            exec_result.matches.append(match_ptr[:match_len])
            exec_result.set_matches.append(True if ovector[i * 2] >= 0 else False)
            cpcre.pcre_free_substring(match_ptr)

    # named substrings
    cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_NAMECOUNT, &namecount)
    if namecount > 0:
        cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_NAMETABLE, &name_table)
        cpcre.pcre_fullinfo(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_NAMEENTRYSIZE, &name_entry_size)
        tabptr = name_table
        for i in range(namecount):
            n = (tabptr[0] << 8) | tabptr[1]
            substring_name = PyString_FromStringAndSize(tabptr + 2, name_entry_size - 3)
            #print 'named substring: %d, "%s", "%s"' % (n, substring_name, exec_result.matches[n])
            if exec_result.num_matches > n:
                exec_result.named_matches[substring_name] = exec_result.matches[n]
            tabptr += name_entry_size

    return exec_result

