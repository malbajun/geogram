// Temporary proxy for letting existing code find bundled NL include files
// without changing it

#ifndef GEOGRAM_NL_EXT
#define GEOGRAM_NL_EXT

#ifdef GEOGRAM_USE_BUILTIN_DEPS
#include <geogram/third_party/OpenNL/nl_ext.h>
#else
#include <nl_ext.h>
#endif

#endif
