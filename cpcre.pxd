cdef extern from "pcre.h":
    ctypedef struct pcre:
        pass
    ctypedef struct pcre_jit_stack:
        pass
    ctypedef struct pcre_extra:
        unsigned long int flags                 # Bits for which fields are set
        unsigned long int match_limit           # Maximum number of calls to match()
        unsigned long int match_limit_recursion # Max recursive calls to match()
        unsigned char **mark                    # For passing back a mark pointer
    ctypedef struct pcre_callout_block:
        pass
    ctypedef pcre_jit_stack* (*pcre_jit_callback)(void*)
    pcre* pcre_compile(char*, int, char**, int*, unsigned char*)
    pcre* pcre_compile2(char*, int, int*, char**, int*, unsigned char*)
    int pcre_config(int, void*)
    int pcre_copy_named_substring(pcre*, char*, int*, int, char*, char*, int)
    int pcre_copy_substring(char*, int*, int, int, char*, int)
    int pcre_dfa_exec(pcre*, pcre_extra*, char*, int, int, int, int*, int , int*, int)
    int pcre_exec(pcre*, pcre_extra*, char*, int, int, int, int*, int)
    void pcre_free_substring(char*)
    void pcre_free_substring_list(char**)
    int pcre_fullinfo(pcre*, pcre_extra*, int, void*)
    int pcre_get_named_substring(pcre*, char*, int*, int, char*, char**)
    int pcre_get_stringnumber(pcre*, char*)
    int pcre_get_stringtable_entries(pcre*, char *, char**, char**)
    int pcre_get_substring(char*, int*, int, int, char**)
    int pcre_get_substring_list(char*, int*, int, char***)
    unsigned char* pcre_maketables()
    int pcre_refcount(pcre*, int)
    pcre_extra* pcre_study(pcre*, int, char**)
    void pcre_free_study(pcre_extra*)
    char* pcre_version()
    pcre_jit_stack* pcre_jit_stack_alloc(int, int)
    void pcre_jit_stack_free(pcre_jit_stack*)
    void pcre_assign_jit_stack(pcre_extra*, pcre_jit_callback, void*)

    # copied from _globals.pxd (generated by generate_globals.py)
    int _PCRE_CASELESS "PCRE_CASELESS"
    int _PCRE_MULTILINE "PCRE_MULTILINE"
    int _PCRE_DOTALL "PCRE_DOTALL"
    int _PCRE_EXTENDED "PCRE_EXTENDED"
    int _PCRE_ANCHORED "PCRE_ANCHORED"
    int _PCRE_DOLLAR_ENDONLY "PCRE_DOLLAR_ENDONLY"
    int _PCRE_EXTRA "PCRE_EXTRA"
    int _PCRE_NOTBOL "PCRE_NOTBOL"
    int _PCRE_NOTEOL "PCRE_NOTEOL"
    int _PCRE_UNGREEDY "PCRE_UNGREEDY"
    int _PCRE_NOTEMPTY "PCRE_NOTEMPTY"
    int _PCRE_UTF8 "PCRE_UTF8"
    int _PCRE_UTF16 "PCRE_UTF16"
    int _PCRE_UTF32 "PCRE_UTF32"
    int _PCRE_NO_AUTO_CAPTURE "PCRE_NO_AUTO_CAPTURE"
    int _PCRE_NO_UTF8_CHECK "PCRE_NO_UTF8_CHECK"
    int _PCRE_NO_UTF16_CHECK "PCRE_NO_UTF16_CHECK"
    int _PCRE_NO_UTF32_CHECK "PCRE_NO_UTF32_CHECK"
    int _PCRE_AUTO_CALLOUT "PCRE_AUTO_CALLOUT"
    int _PCRE_PARTIAL_SOFT "PCRE_PARTIAL_SOFT"
    int _PCRE_PARTIAL "PCRE_PARTIAL"
    int _PCRE_NEVER_UTF "PCRE_NEVER_UTF"
    int _PCRE_DFA_SHORTEST "PCRE_DFA_SHORTEST"
    int _PCRE_NO_AUTO_POSSESS "PCRE_NO_AUTO_POSSESS"
    int _PCRE_DFA_RESTART "PCRE_DFA_RESTART"
    int _PCRE_FIRSTLINE "PCRE_FIRSTLINE"
    int _PCRE_DUPNAMES "PCRE_DUPNAMES"
    int _PCRE_NEWLINE_CR "PCRE_NEWLINE_CR"
    int _PCRE_NEWLINE_LF "PCRE_NEWLINE_LF"
    int _PCRE_NEWLINE_CRLF "PCRE_NEWLINE_CRLF"
    int _PCRE_NEWLINE_ANY "PCRE_NEWLINE_ANY"
    int _PCRE_NEWLINE_ANYCRLF "PCRE_NEWLINE_ANYCRLF"
    int _PCRE_BSR_ANYCRLF "PCRE_BSR_ANYCRLF"
    int _PCRE_BSR_UNICODE "PCRE_BSR_UNICODE"
    int _PCRE_JAVASCRIPT_COMPAT "PCRE_JAVASCRIPT_COMPAT"
    int _PCRE_NO_START_OPTIMIZE "PCRE_NO_START_OPTIMIZE"
    int _PCRE_NO_START_OPTIMISE "PCRE_NO_START_OPTIMISE"
    int _PCRE_PARTIAL_HARD "PCRE_PARTIAL_HARD"
    int _PCRE_NOTEMPTY_ATSTART "PCRE_NOTEMPTY_ATSTART"
    int _PCRE_UCP "PCRE_UCP"
    int _PCRE_ERROR_NOMATCH "PCRE_ERROR_NOMATCH"
    int _PCRE_ERROR_NULL "PCRE_ERROR_NULL"
    int _PCRE_ERROR_BADOPTION "PCRE_ERROR_BADOPTION"
    int _PCRE_ERROR_BADMAGIC "PCRE_ERROR_BADMAGIC"
    int _PCRE_ERROR_UNKNOWN_OPCODE "PCRE_ERROR_UNKNOWN_OPCODE"
    int _PCRE_ERROR_UNKNOWN_NODE "PCRE_ERROR_UNKNOWN_NODE"
    int _PCRE_ERROR_NOMEMORY "PCRE_ERROR_NOMEMORY"
    int _PCRE_ERROR_NOSUBSTRING "PCRE_ERROR_NOSUBSTRING"
    int _PCRE_ERROR_MATCHLIMIT "PCRE_ERROR_MATCHLIMIT"
    int _PCRE_ERROR_CALLOUT "PCRE_ERROR_CALLOUT"
    int _PCRE_ERROR_BADUTF8 "PCRE_ERROR_BADUTF8"
    int _PCRE_ERROR_BADUTF16 "PCRE_ERROR_BADUTF16"
    int _PCRE_ERROR_BADUTF32 "PCRE_ERROR_BADUTF32"
    int _PCRE_ERROR_BADUTF8_OFFSET "PCRE_ERROR_BADUTF8_OFFSET"
    int _PCRE_ERROR_BADUTF16_OFFSET "PCRE_ERROR_BADUTF16_OFFSET"
    int _PCRE_ERROR_PARTIAL "PCRE_ERROR_PARTIAL"
    int _PCRE_ERROR_BADPARTIAL "PCRE_ERROR_BADPARTIAL"
    int _PCRE_ERROR_INTERNAL "PCRE_ERROR_INTERNAL"
    int _PCRE_ERROR_BADCOUNT "PCRE_ERROR_BADCOUNT"
    int _PCRE_ERROR_DFA_UITEM "PCRE_ERROR_DFA_UITEM"
    int _PCRE_ERROR_DFA_UCOND "PCRE_ERROR_DFA_UCOND"
    int _PCRE_ERROR_DFA_UMLIMIT "PCRE_ERROR_DFA_UMLIMIT"
    int _PCRE_ERROR_DFA_WSSIZE "PCRE_ERROR_DFA_WSSIZE"
    int _PCRE_ERROR_DFA_RECURSE "PCRE_ERROR_DFA_RECURSE"
    int _PCRE_ERROR_RECURSIONLIMIT "PCRE_ERROR_RECURSIONLIMIT"
    int _PCRE_ERROR_NULLWSLIMIT "PCRE_ERROR_NULLWSLIMIT"
    int _PCRE_ERROR_BADNEWLINE "PCRE_ERROR_BADNEWLINE"
    int _PCRE_ERROR_BADOFFSET "PCRE_ERROR_BADOFFSET"
    int _PCRE_ERROR_SHORTUTF8 "PCRE_ERROR_SHORTUTF8"
    int _PCRE_ERROR_SHORTUTF16 "PCRE_ERROR_SHORTUTF16"
    int _PCRE_ERROR_RECURSELOOP "PCRE_ERROR_RECURSELOOP"
    int _PCRE_ERROR_JIT_STACKLIMIT "PCRE_ERROR_JIT_STACKLIMIT"
    int _PCRE_ERROR_BADMODE "PCRE_ERROR_BADMODE"
    int _PCRE_ERROR_BADENDIANNESS "PCRE_ERROR_BADENDIANNESS"
    int _PCRE_ERROR_DFA_BADRESTART "PCRE_ERROR_DFA_BADRESTART"
    int _PCRE_ERROR_JIT_BADOPTION "PCRE_ERROR_JIT_BADOPTION"
    int _PCRE_ERROR_BADLENGTH "PCRE_ERROR_BADLENGTH"
    int _PCRE_ERROR_UNSET "PCRE_ERROR_UNSET"
    int _PCRE_UTF8_ERR0 "PCRE_UTF8_ERR0"
    int _PCRE_UTF8_ERR1 "PCRE_UTF8_ERR1"
    int _PCRE_UTF8_ERR2 "PCRE_UTF8_ERR2"
    int _PCRE_UTF8_ERR3 "PCRE_UTF8_ERR3"
    int _PCRE_UTF8_ERR4 "PCRE_UTF8_ERR4"
    int _PCRE_UTF8_ERR5 "PCRE_UTF8_ERR5"
    int _PCRE_UTF8_ERR6 "PCRE_UTF8_ERR6"
    int _PCRE_UTF8_ERR7 "PCRE_UTF8_ERR7"
    int _PCRE_UTF8_ERR8 "PCRE_UTF8_ERR8"
    int _PCRE_UTF8_ERR9 "PCRE_UTF8_ERR9"
    int _PCRE_UTF8_ERR10 "PCRE_UTF8_ERR10"
    int _PCRE_UTF8_ERR11 "PCRE_UTF8_ERR11"
    int _PCRE_UTF8_ERR12 "PCRE_UTF8_ERR12"
    int _PCRE_UTF8_ERR13 "PCRE_UTF8_ERR13"
    int _PCRE_UTF8_ERR14 "PCRE_UTF8_ERR14"
    int _PCRE_UTF8_ERR15 "PCRE_UTF8_ERR15"
    int _PCRE_UTF8_ERR16 "PCRE_UTF8_ERR16"
    int _PCRE_UTF8_ERR17 "PCRE_UTF8_ERR17"
    int _PCRE_UTF8_ERR18 "PCRE_UTF8_ERR18"
    int _PCRE_UTF8_ERR19 "PCRE_UTF8_ERR19"
    int _PCRE_UTF8_ERR20 "PCRE_UTF8_ERR20"
    int _PCRE_UTF8_ERR21 "PCRE_UTF8_ERR21"
    int _PCRE_UTF8_ERR22 "PCRE_UTF8_ERR22"
    int _PCRE_UTF16_ERR0 "PCRE_UTF16_ERR0"
    int _PCRE_UTF16_ERR1 "PCRE_UTF16_ERR1"
    int _PCRE_UTF16_ERR2 "PCRE_UTF16_ERR2"
    int _PCRE_UTF16_ERR3 "PCRE_UTF16_ERR3"
    int _PCRE_UTF16_ERR4 "PCRE_UTF16_ERR4"
    int _PCRE_UTF32_ERR0 "PCRE_UTF32_ERR0"
    int _PCRE_UTF32_ERR1 "PCRE_UTF32_ERR1"
    int _PCRE_UTF32_ERR2 "PCRE_UTF32_ERR2"
    int _PCRE_UTF32_ERR3 "PCRE_UTF32_ERR3"
    int _PCRE_INFO_OPTIONS "PCRE_INFO_OPTIONS"
    int _PCRE_INFO_SIZE "PCRE_INFO_SIZE"
    int _PCRE_INFO_CAPTURECOUNT "PCRE_INFO_CAPTURECOUNT"
    int _PCRE_INFO_BACKREFMAX "PCRE_INFO_BACKREFMAX"
    int _PCRE_INFO_FIRSTBYTE "PCRE_INFO_FIRSTBYTE"
    int _PCRE_INFO_FIRSTCHAR "PCRE_INFO_FIRSTCHAR"
    int _PCRE_INFO_FIRSTTABLE "PCRE_INFO_FIRSTTABLE"
    int _PCRE_INFO_LASTLITERAL "PCRE_INFO_LASTLITERAL"
    int _PCRE_INFO_NAMEENTRYSIZE "PCRE_INFO_NAMEENTRYSIZE"
    int _PCRE_INFO_NAMECOUNT "PCRE_INFO_NAMECOUNT"
    int _PCRE_INFO_NAMETABLE "PCRE_INFO_NAMETABLE"
    int _PCRE_INFO_STUDYSIZE "PCRE_INFO_STUDYSIZE"
    int _PCRE_INFO_DEFAULT_TABLES "PCRE_INFO_DEFAULT_TABLES"
    int _PCRE_INFO_OKPARTIAL "PCRE_INFO_OKPARTIAL"
    int _PCRE_INFO_JCHANGED "PCRE_INFO_JCHANGED"
    int _PCRE_INFO_HASCRORLF "PCRE_INFO_HASCRORLF"
    int _PCRE_INFO_MINLENGTH "PCRE_INFO_MINLENGTH"
    int _PCRE_INFO_JIT "PCRE_INFO_JIT"
    int _PCRE_INFO_JITSIZE "PCRE_INFO_JITSIZE"
    int _PCRE_INFO_MAXLOOKBEHIND "PCRE_INFO_MAXLOOKBEHIND"
    int _PCRE_INFO_FIRSTCHARACTER "PCRE_INFO_FIRSTCHARACTER"
    int _PCRE_INFO_FIRSTCHARACTERFLAGS "PCRE_INFO_FIRSTCHARACTERFLAGS"
    int _PCRE_INFO_REQUIREDCHAR "PCRE_INFO_REQUIREDCHAR"
    int _PCRE_INFO_REQUIREDCHARFLAGS "PCRE_INFO_REQUIREDCHARFLAGS"
    int _PCRE_INFO_MATCHLIMIT "PCRE_INFO_MATCHLIMIT"
    int _PCRE_INFO_RECURSIONLIMIT "PCRE_INFO_RECURSIONLIMIT"
    int _PCRE_INFO_MATCH_EMPTY "PCRE_INFO_MATCH_EMPTY"
    int _PCRE_CONFIG_UTF8 "PCRE_CONFIG_UTF8"
    int _PCRE_CONFIG_NEWLINE "PCRE_CONFIG_NEWLINE"
    int _PCRE_CONFIG_LINK_SIZE "PCRE_CONFIG_LINK_SIZE"
    int _PCRE_CONFIG_POSIX_MALLOC_THRESHOLD "PCRE_CONFIG_POSIX_MALLOC_THRESHOLD"
    int _PCRE_CONFIG_MATCH_LIMIT "PCRE_CONFIG_MATCH_LIMIT"
    int _PCRE_CONFIG_STACKRECURSE "PCRE_CONFIG_STACKRECURSE"
    int _PCRE_CONFIG_UNICODE_PROPERTIES "PCRE_CONFIG_UNICODE_PROPERTIES"
    int _PCRE_CONFIG_MATCH_LIMIT_RECURSION "PCRE_CONFIG_MATCH_LIMIT_RECURSION"
    int _PCRE_CONFIG_BSR "PCRE_CONFIG_BSR"
    int _PCRE_CONFIG_JIT "PCRE_CONFIG_JIT"
    int _PCRE_CONFIG_UTF16 "PCRE_CONFIG_UTF16"
    int _PCRE_CONFIG_JITTARGET "PCRE_CONFIG_JITTARGET"
    int _PCRE_CONFIG_UTF32 "PCRE_CONFIG_UTF32"
    int _PCRE_CONFIG_PARENS_LIMIT "PCRE_CONFIG_PARENS_LIMIT"
    int _PCRE_STUDY_JIT_COMPILE "PCRE_STUDY_JIT_COMPILE"
    int _PCRE_STUDY_JIT_PARTIAL_SOFT_COMPILE "PCRE_STUDY_JIT_PARTIAL_SOFT_COMPILE"
    int _PCRE_STUDY_JIT_PARTIAL_HARD_COMPILE "PCRE_STUDY_JIT_PARTIAL_HARD_COMPILE"
    int _PCRE_STUDY_EXTRA_NEEDED "PCRE_STUDY_EXTRA_NEEDED"
    int _PCRE_EXTRA_STUDY_DATA "PCRE_EXTRA_STUDY_DATA"
    int _PCRE_EXTRA_MATCH_LIMIT "PCRE_EXTRA_MATCH_LIMIT"
    int _PCRE_EXTRA_CALLOUT_DATA "PCRE_EXTRA_CALLOUT_DATA"
    int _PCRE_EXTRA_TABLES "PCRE_EXTRA_TABLES"
    int _PCRE_EXTRA_MATCH_LIMIT_RECURSION "PCRE_EXTRA_MATCH_LIMIT_RECURSION"
    int _PCRE_EXTRA_MARK "PCRE_EXTRA_MARK"
    int _PCRE_EXTRA_EXECUTABLE_JIT "PCRE_EXTRA_EXECUTABLE_JIT"

cdef extern from *:
    void* pcre_malloc(size_t)
    void pcre_free(void*)
    void* pcre_stack_malloc(size_t)
    void pcre_stack_free(void*)
    int pcre_callout(pcre_callout_block*)

# TODO: add UTF-16 and UTF-32 data structures and functions
