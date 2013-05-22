#cython: embedsignature=True, infer_types=True, profile=True

cimport cpcre, cython
from libc.stdlib cimport malloc
from libc.string cimport const_char

# Options. Some are compile-time only, some are run-time only, and some are
# both, so we keep them all distinct. However, almost all the bits in the options
# word are now used. In the long run, we may have to re-use some of the
# compile-time only bits for runtime options, or vice versa. In the comments
# below, "compile", "exec", and "DFA exec" mean that the option is permitted to
# be set for those functions; "used in" means that an option may be set only for
# compile, but is subsequently referenced in exec and/or DFA exec. Any of the
# compile-time options may be inspected during studying (and therefore JIT
# compiling).

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
PCRE_ERROR_DFA_BADRESTART = (-30)
PCRE_ERROR_JIT_BADOPTION =  (-31)
PCRE_ERROR_BADLENGTH =      (-32)


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

PCRE_STUDY_JIT_COMPILE =              0x0001
PCRE_STUDY_JIT_PARTIAL_SOFT_COMPILE = 0x0002
PCRE_STUDY_JIT_PARTIAL_HARD_COMPILE = 0x0004

# Bit flags for the pcre_extra structure. Do not re-arrange or redefine
# these bits, just add new ones on the end, in order to remain compatible.

PCRE_EXTRA_STUDY_DATA =             0x0001
PCRE_EXTRA_MATCH_LIMIT =            0x0002
PCRE_EXTRA_CALLOUT_DATA =           0x0004
PCRE_EXTRA_TABLES =                 0x0008
PCRE_EXTRA_MATCH_LIMIT_RECURSION =  0x0010
PCRE_EXTRA_MARK =                   0x0020
PCRE_EXTRA_EXECUTABLE_JIT =         0x0040

# compute some bit masks to avoid errors when supplying wrong options to some functions
PCRE_COMPILE_OPTIONS_MASK =\
        PCRE_CASELESS |\
        PCRE_MULTILINE |\
        PCRE_DOTALL |\
        PCRE_EXTENDED |\
        PCRE_ANCHORED |\
        PCRE_DOLLAR_ENDONLY |\
        PCRE_EXTRA |\
        PCRE_UNGREEDY |\
        PCRE_UTF8 |\
        PCRE_NO_AUTO_CAPTURE |\
        PCRE_NO_UTF8_CHECK |\
        PCRE_AUTO_CALLOUT |\
        PCRE_FIRSTLINE |\
        PCRE_DUPNAMES |\
        PCRE_NEWLINE_CR |\
        PCRE_NEWLINE_LF |\
        PCRE_NEWLINE_CRLF |\
        PCRE_NEWLINE_ANY |\
        PCRE_NEWLINE_ANYCRLF |\
        PCRE_BSR_ANYCRLF |\
        PCRE_BSR_UNICODE |\
        PCRE_JAVASCRIPT_COMPAT |\
        PCRE_NO_START_OPTIMIZE |\
        PCRE_UCP

PCRE_EXEC_OPTIONS_MASK =\
        PCRE_ANCHORED |\
        PCRE_NOTBOL |\
        PCRE_NOTEOL |\
        PCRE_NOTEMPTY |\
        PCRE_NO_UTF8_CHECK |\
        PCRE_PARTIAL_SOFT |\
        PCRE_NEWLINE_CR |\
        PCRE_NEWLINE_LF |\
        PCRE_NEWLINE_CRLF |\
        PCRE_NEWLINE_ANY |\
        PCRE_NEWLINE_ANYCRLF |\
        PCRE_BSR_ANYCRLF |\
        PCRE_BSR_UNICODE |\
        PCRE_NO_START_OPTIMIZE |\
        PCRE_PARTIAL_HARD |\
        PCRE_NOTEMPTY_ATSTART

PCRE_STUDY_OPTIONS_MASK =\
        PCRE_STUDY_JIT_COMPILE |\
        PCRE_STUDY_JIT_PARTIAL_SOFT_COMPILE |\
        PCRE_STUDY_JIT_PARTIAL_HARD_COMPILE

class PcreException(Exception):
    pass

cdef extern from "Python.h":
    object PyString_FromString(char *)
    object PyString_FromStringAndSize(char *s, Py_ssize_t len)

cdef class Pcre:
    cdef cpcre.pcre *_c_pcre
    cdef readonly:
        bint info_available
        int groups
        object groupindex
    def __cinit__(self):
        self._c_pcre = NULL
        self.info_available = 0
        self.groups = 0
        self.groupindex = {}
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")
    def __dealloc__(self):
        if self._c_pcre is not NULL:
            cpcre.pcre_free(self._c_pcre)

cdef class PcreExtra:
    cdef cpcre.pcre_extra *_c_pcre_extra
    def __cinit__(self):
        self._c_pcre_extra = NULL
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")
    def __dealloc__(self):
        if self._c_pcre_extra is not NULL:
            cpcre.pcre_free_study(self._c_pcre_extra)
    property flags:
        def __get__(self):
            if self._c_pcre_extra is NULL:
                return 0
            return self._c_pcre_extra.flags
        def __set__(self, value):
            if self._c_pcre_extra is not NULL:
                self._c_pcre_extra.flags = value

cdef class ExecResult:
    cdef:
        int *ovector
        public unsigned char *markptr
    cdef readonly:
        int offset
        int result
        int num_matches
        bint captured_all
        object start_offsets
        object end_offsets
        object matches
        object named_matches
        object lastindex
        object lastgroup
    def __cinit__(self):
        self.num_matches = 0
        self.captured_all = 1
        self.start_offsets = []
        self.end_offsets = []
        self.matches = []
        self.named_matches = {}
        self.ovector = NULL
        self.markptr = NULL
        self.lastindex = None
        self.lastgroup = None
    def __dealloc__(self):
        if self.ovector is not NULL:
            cpcre.pcre_free(self.ovector)
    property mark:
        def __get__(self):
            if self.markptr is NULL:
                return None
            return self.markptr

@cython.profile(False)
cdef inline process_text(text):
    if isinstance(text, unicode):
        text = text.encode('UTF-8')
    return text

@cython.profile(False)
cdef inline unicode tounicode(char* s):
    return s.decode('UTF-8', 'strict')

@cython.profile(False)
cdef inline unicode tounicode_with_length(char* s, size_t length):
    return s[:length].decode('UTF-8', 'strict')

ERROR_CODES = {
    PCRE_ERROR_MATCHLIMIT: 'maximum match limit exceeded',
    PCRE_ERROR_RECURSIONLIMIT: 'maximum recursion limit exceeded',
    PCRE_ERROR_NULL: 'NULL parameter',
    PCRE_ERROR_BADOPTION: 'unrecognized option (flag)',
    PCRE_ERROR_BADMAGIC: 'magic number not present',
    PCRE_ERROR_UNKNOWN_OPCODE: 'unknown opcode',
    PCRE_ERROR_NOMEMORY: 'out of memory',
    PCRE_ERROR_BADUTF8: 'invalid UTF-8 byte sequence',
    PCRE_ERROR_BADUTF8_OFFSET: 'invalid UTF-8 offset',
    PCRE_ERROR_INTERNAL: 'unexpected internal error',
    PCRE_ERROR_BADCOUNT: 'invalid value for ovecsize',
    PCRE_ERROR_BADNEWLINE: 'invalid combination of PCRE_NEWLINE_xxx options',
    PCRE_ERROR_BADOFFSET: 'invalid offset',
    PCRE_ERROR_SHORTUTF8: 'short UTF-8 byte sequence',
    PCRE_ERROR_RECURSELOOP: 'recursion loop within the pattern',
    PCRE_ERROR_JIT_STACKLIMIT: 'out of JIT memory',
    PCRE_ERROR_BADMODE: 'a pattern that was compiled by the 8-bit library is passed to a 16-bit or 32-bit library function, or vice versa',
    PCRE_ERROR_BADENDIANNESS: 'a pattern that was compiled and saved is reloaded on a host with different endianness',
    PCRE_ERROR_JIT_BADOPTION: 'invalid option in JIT mode',
    PCRE_ERROR_BADLENGTH: 'pcre_exec() was called with a negative value for the length argument',
}

@cython.profile(False)
cdef inline process_exec_error(int rc):
    if rc in ERROR_CODES:
        raise PcreException(ERROR_CODES[rc])

cpdef pcre_version():
    return cpcre.pcre_version()

cpdef pcre_compile(pattern, int options=0):
    cdef:
        const_char *error
        int erroffset
        cpcre.pcre *re
        Pcre pcre = Pcre.__new__(Pcre)

    if isinstance(pattern, unicode):
        options |= PCRE_UTF8 | PCRE_UCP
    pattern = process_text(pattern)
    re = cpcre.pcre_compile(pattern, options & PCRE_COMPILE_OPTIONS_MASK, &error, &erroffset, NULL)
    if re is NULL:
        raise PcreException('PCRE compilation failed at offset %d (%s)' % (erroffset, error))
    pcre._c_pcre = re
    return pcre

cpdef pcre_study(Pcre re, int options=0):
    cdef:
        cpcre.pcre_extra *sd
        PcreExtra pcre_extra = PcreExtra.__new__(PcreExtra)
        const_char *error

    sd = cpcre.pcre_study(re._c_pcre, options & PCRE_STUDY_OPTIONS_MASK, &error)
    if error is not NULL:
        raise PcreException(error)
    pcre_extra._c_pcre_extra = sd
    return pcre_extra

cpdef pcre_create_empty_study():
    cdef:
        PcreExtra pcre_extra = PcreExtra.__new__(PcreExtra)
    pcre_extra._c_pcre_extra = <cpcre.pcre_extra *>malloc(sizeof(cpcre.pcre_extra))
    pcre_extra._c_pcre_extra.flags = 0
    return pcre_extra

cdef pcre_fullinfo_wrapper(cpcre.pcre* code, cpcre.pcre_extra* extra, int what, void* where):
    res = cpcre.pcre_fullinfo(code, extra, what, where)
    if res != 0:
        s = 'pcre_fullinfo() failed: %s'
        if res == PCRE_ERROR_NULL:
            raise PcreException(s % 'NULL pointer')
        elif res == PCRE_ERROR_BADMAGIC:
            raise PcreException(s % 'magic number not found in pattern')
        elif res == PCRE_ERROR_BADENDIANNESS:
            raise PcreException(s % 'the pattern was compiled with different endianness')
        elif res == PCRE_ERROR_BADOPTION:
            raise PcreException(s % 'invalid option number')
        else:
            raise PcreException(s % 'unknown')

cpdef pcre_info(Pcre re, PcreExtra extra=None):
    cdef:
        int capture_count
        int namecount
        char *name_table
        int name_entry_size
        char *tabptr
        int i, n

    re.info_available = 1

    # number of captures
    pcre_fullinfo_wrapper(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_CAPTURECOUNT, &capture_count)
    re.groups = capture_count
    
    # named substrings
    pcre_fullinfo_wrapper(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_NAMECOUNT, &namecount)
    if namecount > 0:
        pcre_fullinfo_wrapper(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_NAMETABLE, &name_table)
        pcre_fullinfo_wrapper(re._c_pcre, extra._c_pcre_extra, PCRE_INFO_NAMEENTRYSIZE, &name_entry_size)
        tabptr = name_table
        for i in range(namecount):
            n = (tabptr[0] << 8) | tabptr[1]
            substring_name = PyString_FromString(tabptr + 2)
            re.groupindex[substring_name] = n
            tabptr += name_entry_size

cpdef pcre_exec(Pcre re, subject, int options=0, PcreExtra extra=None, int offset=0):
    cdef:
        int rc
        int subject_length
        int oveccount = 30
        int *ovector
        ExecResult exec_result = ExecResult()
        const_char *match_ptr
        int i, n
        int start, end
        bint subject_is_unicode = isinstance(subject, unicode)
        int last_index, end_offset, length, m_len

    subject = process_text(subject)
    subject_length = len(subject)
    if extra is None:
        extra = PcreExtra.__new__(PcreExtra)

    # mark handling
    if extra._c_pcre_extra is not NULL and extra._c_pcre_extra.flags & PCRE_EXTRA_MARK:
        extra._c_pcre_extra.mark = &exec_result.markptr

    # get the pcre info if we don't have it already
    if re.info_available == 0:
        pcre_info(re, extra)
    
    # replace the default with (the actual number of capturing subpatterns + 1) * 3
    oveccount = (re.groups + 1) * 3

    ovector = <int*>cpcre.pcre_malloc(oveccount * sizeof(int))
    if ovector is NULL:
        raise MemoryError()

    rc = cpcre.pcre_exec(re._c_pcre, extra._c_pcre_extra, subject, subject_length, offset, options & PCRE_EXEC_OPTIONS_MASK, ovector, oveccount)
    exec_result.result = rc
    exec_result.ovector = ovector
    exec_result.offset = offset
    if rc == 0:
        rc = oveccount / 3
        exec_result.captured_all = 0
    if rc > 0:
        exec_result.num_matches = rc
        for i in range(rc):
            match_len = cpcre.pcre_get_substring(subject, ovector, rc, i, &match_ptr)
            if match_len < 0:
                raise PcreException('error getting the match #%d' % i)
            if ovector[i * 2] >= 0:
                match = match_ptr[:match_len]
                if subject_is_unicode:
                    try:
                        match = tounicode_with_length(<char*>match_ptr, match_len)
                    except:
                        pass
                exec_result.matches.append(match)
            else:
                exec_result.matches.append(None)
            start = ovector[i * 2]
            end = ovector[i * 2 + 1]
            if subject_is_unicode and start >= 0:
                try:
                    str_before = tounicode_with_length(<char*>subject, ovector[i * 2])
                    start = len(str_before)
                    end = start + len(match)
                except:
                    pass
            exec_result.start_offsets.append(start)
            exec_result.end_offsets.append(end)
            cpcre.pcre_free_substring(match_ptr)
        # if the unmatched groups are at the end, PCRE doesn't bother reporting them
        # so we have to do it ourselves
        for i in range(oveccount / 3 - rc):
            exec_result.matches.append(None)
            exec_result.start_offsets.append(-1)
            exec_result.end_offsets.append(-1)

        # named substrings
        for substring_name in re.groupindex:
            n = re.groupindex[substring_name]
            exec_result.named_matches[substring_name] = exec_result.matches[n]

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
                exec_result.lastindex = last_index
                for name in re.groupindex:
                    if re.groupindex[name] == last_index:
                        exec_result.lastgroup = name
                        break
    elif rc < 0:
        process_exec_error(rc)

    return exec_result

cpdef pcre_find_all(Pcre re, subject, int options=0, PcreExtra extra=None, int offset=0):
    """
    translated and adapted from pcredemo.c
    """
    orig_subject = subject
    subject = process_text(subject)
    exec_results = []
    cdef:
        ExecResult exec_result = ExecResult()
        unsigned int option_bits
        int utf8
        int d
        int crlf_is_newline
        char* c_subject = subject
        int subject_length = len(c_subject)
        int start_offset
        int end_offset

    # Before running the loop, check for UTF-8 and whether CRLF is a valid newline
    # sequence. First, find the options with which the regex was compiled; extract
    # the UTF-8 state, and mask off all but the newline options.

    pcre_fullinfo_wrapper(re._c_pcre, NULL, PCRE_INFO_OPTIONS, &option_bits);
    utf8 = option_bits & PCRE_UTF8
    option_bits &= PCRE_NEWLINE_CR|PCRE_NEWLINE_LF | PCRE_NEWLINE_CRLF | PCRE_NEWLINE_ANY | PCRE_NEWLINE_ANYCRLF

    # If no newline options were set, find the default newline convention from the
    # build configuration.
    if option_bits == 0:
        cpcre.pcre_config(PCRE_CONFIG_NEWLINE, &d)
        #print 'd = %d' % d
        # Note that these values are always the ASCII ones, even in
        # EBCDIC environments. CR = 13, NL = 10.
        option_bits = PCRE_NEWLINE_CR if d == 13 else (
            PCRE_NEWLINE_LF if d == 10 else (
                PCRE_NEWLINE_CRLF if d == (13<<8 | 10) else (
                    PCRE_NEWLINE_ANYCRLF if d == -2 else (
                        PCRE_NEWLINE_ANY if d == -1 else 0
                    )
                )
            )
        )
    #print 'utf8 = %d, option_bits = 0x%X' % (utf8, option_bits)

    # See if CRLF is a valid newline sequence.
    crlf_is_newline = option_bits == PCRE_NEWLINE_ANY or option_bits == PCRE_NEWLINE_CRLF or option_bits == PCRE_NEWLINE_ANYCRLF

    not_empty_options = 0
    end_offset = offset
    while True:
        start_offset = end_offset # Start at end of previous match
        # Run the matching operation
        exec_result = pcre_exec(re, orig_subject, (options | not_empty_options) & PCRE_EXEC_OPTIONS_MASK, extra, start_offset)

        exec_result.offset = start_offset
        end_offset = exec_result.ovector[1]

        # This time, a result of NOMATCH isn't an error. If the value in "not_empty_options"
        # is zero, it just means we have found all possible matches, so the loop ends.
        # Otherwise, it means we have failed to find a non-empty-string match at a
        # point where there was a previous empty-string match. In this case, we do what
        # Perl does: advance the matching position by one character, and continue. We
        # do this by setting the "end of previous match" offset, because that is picked
        # up at the top of the loop as the point at which to start again.

        # There are two complications: (a) When CRLF is a valid newline sequence, and
        # the current position is just before it, advance by an extra byte. (b)
        # Otherwise we must ensure that we skip an entire UTF-8 character if we are in
        # UTF-8 mode.
        
        if exec_result.result == PCRE_ERROR_NOMATCH:
            if not_empty_options == 0:
                break                                   # All matches found
            end_offset = start_offset + 1               # Advance one byte
            not_empty_options = 0
                                                        # If CRLF is newline & we are at CRLF,
            if crlf_is_newline and \
               start_offset < subject_length - 1 and \
               c_subject[start_offset] == '\r' and \
               c_subject[start_offset + 1] == '\n':
                end_offset += 1                         # Advance by one more.
            elif utf8:                                  # Otherwise, ensure we advance a whole UTF-8
                while end_offset < subject_length:      # character.
                    if (c_subject[end_offset] & 0xc0) != 0x80:
                        break
                    end_offset += 1
            continue # Go round the loop again

        # Other matching errors are not recoverable.
        if exec_result.result < 0:
            break

        # Match succeded
        exec_results.append(exec_result)

        # If the previous match was for an empty string, we are finished if we are
        # at the end of the subject. Otherwise, arrange to run another match at the
        # same point to see if a non-empty match can be found.
        not_empty_options = 0
        if exec_result.ovector[0] == exec_result.ovector[1]:
            if exec_result.ovector[0] == subject_length:
                break
            not_empty_options = PCRE_NOTEMPTY_ATSTART | PCRE_ANCHORED
    return exec_results

cpdef pcre_split(Pcre re, string, int maxsplit=0, int options=0, PcreExtra extra=None):
    cdef:
        int last_index = 0
        int counter = 0
    
    string = process_text(string)
    res = []
    for result in pcre_find_all(re, string, options | PCRE_NOTEMPTY, extra):
        counter += 1
        res.append(string[last_index:result.start_offsets[0]])
        last_index = result.end_offsets[0]
        if len(result.matches) > 1:
            res.extend(result.matches[1:])
        if counter == maxsplit:
            break
    res.append(string[last_index:])
    return res

# TODO: test this function
cpdef pcre_fsubn(Pcre re, repl, string, int count=0, int options=0, PcreExtra extra=None):
    cdef:
        int last_index = 0
        int counter = 0
        bint is_callable = 0
    
    orig_string = string
    string = process_text(string)
    pieces = []
    if hasattr(repl, '__call__'):
        is_callable = 1
    for result in pcre_find_all(re, string, options, extra):
        counter += 1
        pieces.append(string[last_index:result.start_offsets[0]])
        last_index = result.end_offsets[0]
        if is_callable:
            replacement = repl(result)
        else:
            replacement = repl.format(*result.matches, **result.named_matches)
        pieces.append(replacement)
        if count == counter:
            break
    pieces.append(orig_string[last_index:])
    return orig_string[:0].join(pieces), counter

cpdef pcre_fsub(Pcre re, repl, string, int count=0, int options=0, PcreExtra extra=None):
    return pcre_fsubn(re, repl, string, count, options, extra)[0]

cpdef pcre_subn(Pcre re, repl, string, int count=0, int options=0, PcreExtra extra=None):
    cdef:
        int last_index = 0
        int counter = 0
        bint is_callable = 0
    
    orig_string = string
    string = process_text(string)
    pieces = []
    if hasattr(repl, '__call__'):
        is_callable = 1
    last_match = ''
    for result in pcre_find_all(re, string, options, extra):
        if last_match != '' and result.matches[0] == '' and last_index == result.start_offsets[0]:
            continue
        last_match = result.matches[0]
        counter += 1
        if result.start_offsets[0] > last_index:
            pieces.append(string[last_index:result.start_offsets[0]])
        last_index = result.end_offsets[0]
        if is_callable:
            replacement = repl(result)
        else:
            replacement = pcre_expand(re, result.matches, repl, string)
        pieces.append(replacement)
        if count == counter:
            break
    if len(string) > last_index:
        pieces.append(string[last_index:])
    if len(pieces) == 1 and isinstance(orig_string, str):
        return pieces[0], counter # 're' bug 1140 compatibility
    return orig_string[:0].join(pieces), counter

cpdef pcre_sub(Pcre re, repl, string, int count=0, int options=0, PcreExtra extra=None):
    return pcre_subn(re, repl, string, count, options, extra)[0]

### code from the original 're' module:

MARK = "mark"
DIGITS = set("0123456789")
OCTDIGITS = set("01234567")
LITERAL = "literal"
ESCAPES = {
    r"\a": (LITERAL, ord("\a")),
    r"\b": (LITERAL, ord("\b")),
    r"\f": (LITERAL, ord("\f")),
    r"\n": (LITERAL, ord("\n")),
    r"\r": (LITERAL, ord("\r")),
    r"\t": (LITERAL, ord("\t")),
    r"\v": (LITERAL, ord("\v")),
    r"\\": (LITERAL, ord("\\"))
}

cdef class Tokenizer:
    cdef:
        object string, next
        int index
    def __init__(self, string):
        self.string = string
        self.index = 0
        self.__next()
    cdef __next(self):
        if self.index >= len(self.string):
            self.next = None
            return
        char = self.string[self.index]
        if char[0] == "\\":
            try:
                c = self.string[self.index + 1]
            except IndexError:
                raise PcreException, "bogus escape (end of line)"
            char = char + c
        self.index = self.index + len(char)
        self.next = char
    cdef match(self, _char, skip=1):
        if _char == self.next:
            if skip:
                self.__next()
            return 1
        return 0
    cdef get(self):
        this = self.next
        self.__next()
        return this
    cdef tell(self):
        return self.index, self.next
    cdef seek(self, index):
        self.index, self.next = index

@cython.profile(False)
cdef inline isident(char* _char):
    return b"a" <= _char <= b"z" or b"A" <= _char <= b"Z" or _char == b"_"

@cython.profile(False)
cdef inline bint isdigit(char* _char):
    return b"0" <= _char <= b"9"

@cython.profile(False)
cdef inline bint isname(name):
    # check that group name is a valid string
    if not isident(name[0]):
        return False
    for _char in name[1:]:
        if not isident(_char) and not isdigit(_char):
            return False
    return True

@cython.profile(False)
cdef inline literal(literal, p):
    if p and p[-1][0] is LITERAL:
        p[-1] = LITERAL, p[-1][1] + literal
    else:
        p.append((LITERAL, literal))

cdef inline parse_template(source, pattern):
    # parse 're' replacement string into list of literals and
    # group references

    cdef:
        Tokenizer s = Tokenizer(source)

    p = []
    a = p.append
    sep = source[:0]
    if type(sep) is type(""):
        makechar = chr
    else:
        makechar = unichr
    while 1:
        this = s.get()
        if this is None:
            break # end of replacement string
        if this and this[0] == "\\":
            # group
            c = this[1:2]
            if c == "g":
                name = ""
                if s.match("<"):
                    while 1:
                        char = s.get()
                        if char is None:
                            raise PcreException, "unterminated group name"
                        if char == ">":
                            break
                        name = name + char
                if not name:
                    raise PcreException, "bad group name"
                try:
                    index = int(name)
                    if index < 0:
                        raise PcreException, "negative group number"
                except ValueError:
                    if not isname(name):
                        raise PcreException, "bad character in group name"
                    try:
                        index = pattern.groupindex[name]
                    except KeyError:
                        raise IndexError, "unknown group name"
                a((MARK, index))
            elif c == "0":
                if s.next in OCTDIGITS:
                    this = this + s.get()
                    if s.next in OCTDIGITS:
                        this = this + s.get()
                literal(makechar(int(this[1:], 8) & 0xff), p)
            elif c in DIGITS:
                isoctal = False
                if s.next in DIGITS:
                    this = this + s.get()
                    if (c in OCTDIGITS and this[2] in OCTDIGITS and
                        s.next in OCTDIGITS):
                        this = this + s.get()
                        isoctal = True
                        literal(makechar(int(this[1:], 8) & 0xff), p)
                if not isoctal:
                    a((MARK, int(this[1:])))
            else:
                try:
                    this = makechar(ESCAPES[this][1])
                except KeyError:
                    pass
                literal(this, p)
        else:
            literal(this, p)
    # convert template to groups and literals lists
    i = 0
    groups = []
    groupsappend = groups.append
    literals = [None] * len(p)
    for c, ss in p:
        if c is MARK:
            groupsappend((i, ss))
            # literal[i] is already None
        else:
            literals[i] = ss
        i = i + 1
    return groups, literals

cdef inline expand_template(template, matches, string):
    groups, literals = template
    literals = literals[:]
    try:
        for index, group in groups:
            literals[index] = s = matches[group]
            if s is None:
                raise PcreException, "unmatched group"
    except IndexError:
        raise PcreException, "invalid group reference"
    return string[:0].join(literals)

cpdef pcre_expand(Pcre pattern, matches, template, string):
    template = parse_template(template, pattern)
    return expand_template(template, matches, string)

