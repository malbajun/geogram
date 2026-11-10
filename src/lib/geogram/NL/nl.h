// Temporary proxy for letting existing code find bundled NL include files
// without changing it

#ifndef GEOGRAM_NL
#define GEOGRAM_NL

#ifdef GEOGRAM_USE_BUILTIN_DEPS
#include <geogram/third_party/OpenNL/nl.h>
#else
#include <nl.h>
#endif

#endif
