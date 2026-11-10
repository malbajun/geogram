// Temporary proxy for letting existing code find bundled NL include files
// without changing it

#ifndef GEOGRAM_NL_BLAS
#define GEOGRAM_NL_BLAS

#ifdef __cplusplus
extern "C" {
#endif

#ifdef GEOGRAM_USE_BUILTIN_DEPS
#include <geogram/third_party/OpenNL/nl_blas.h>
#else
#include <nl_blas.h>
#endif

#ifdef __cplusplus
}
#endif

#endif
