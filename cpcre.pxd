cdef extern from "pcre.h":
    ctypedef struct pcre:
        pass
    ctypedef struct pcre_jit_stack:
        pass
    ctypedef struct pcre_extra:
        unsigned long int flags        # Bits for which fields are set
        unsigned char **mark           # For passing back a mark pointer
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

cdef extern from *:
    void* pcre_malloc(size_t)
    void pcre_free(void*)
    void* pcre_stack_malloc(size_t)
    void pcre_stack_free(void*)
    int pcre_callout(pcre_callout_block*)

# TODO: add UTF-16 data structures and functions
