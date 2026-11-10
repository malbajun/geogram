// Temporary proxy for letting existing code find bundled NL include files
// without changing it

#ifndef GEOGRAM_NL_CONTEXT
#define GEOGRAM_NL_CONTEXT

#ifdef __cplusplus
extern "C" {
#endif

#ifdef GEOGRAM_USE_BUILTIN_DEPS
#include <geogram/third_party/OpenNL/nl_context.h>
#else
#include <nl_context.h>
#endif

#ifdef __cplusplus
}
#endif

#endif
