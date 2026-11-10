// Temporary proxy for letting existing code find bundled NL include files
// without changing it

#ifndef GEOGRAM_NL_MATRIX
#define GEOGRAM_NL_MATRIX

#ifdef __cplusplus
extern "C" {
#endif

#ifdef GEOGRAM_USE_BUILTIN_DEPS
#include <geogram/third_party/OpenNL/nl_matrix.h>
#else
#include <nl_matrix.h>
#endif

#ifdef __cplusplus
}
#endif

#endif
