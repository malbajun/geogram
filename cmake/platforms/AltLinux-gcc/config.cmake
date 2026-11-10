# Define architecture to pass it to source files
message(STATUS "Using arch: ${CMAKE_SYSTEM_PROCESSOR}")
add_definitions(-DARCH=${CMAKE_SYSTEM_PROCESSOR})

set(VORPALINE_BUILD_DYNAMIC true)

if(ARCH MATCHES i586|arm)
   set(VORPALINE_ARCH_32 true)
elseif(ARCH MATCHES aarch64|x86_64|ppc64le|loongarch64)
   set(VORPALINE_ARCH_64 true)
endif()

include(${GEOGRAM_SOURCE_DIR}/cmake/platforms/Linux-gcc.cmake)

if(ARCH MATCHES i586)
   # Configure FPU to use SSE instructions (IEEE rounding semantics)
   # In the default 387 mode, rounding is unpredictable
   add_definitions(-mfpmath=sse)
elseif(ARCH MATCHES arm|aarch64)
   add_definitions(-mlittle-endian)
endif()
