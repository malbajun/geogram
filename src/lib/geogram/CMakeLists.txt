# Tetgen (by Hang Si) is currently included by default.
# Triangle (by Jonathan Shewchuk) is currently included by default.

configure_file(geogram.pc.in ${PROJECT_BINARY_DIR}/${GEOGRAM_SYSTEM_NAME}.pc @ONLY)

set(GEOGRAM_INCLUDE_SUBPATH ${GEOGRAM_SYSTEM_NAME} CACHE PATH "Header install subpath for geogram")

if(GEOGRAM_WITH_GEOGRAMPLUS)
   add_subdirectory(geogramplus)
   list(APPEND SOURCES $<TARGET_OBJECTS:geogramplus> $<TARGET_OBJECTS:geogramplus_third_party>)
   target_include_directories(
      geogramplus PRIVATE
      ${PROJECT_SOURCE_DIR}/src/lib/geogram/
   )
   if(GEOGRAM_WITH_THIRD_PARTIES)
      target_include_directories(${PROJECT_SOURCE_DIR}/src/lib/geogram/geogramplus/third_party)
   endif()
endif()

if(GEOGRAM_WITH_THIRD_PARTIES)
   add_subdirectory(third_party)
else()
   aux_source_directories(SOURCES "Source Files\\third_party\\PoissonRecon"      third_party/PoissonRecon)
endif()

aux_source_directories(SOURCES "Source Files"           .)
aux_source_directories(SOURCES "Source Files\\basic"    basic)
aux_source_directories(SOURCES "Source Files\\numerics" numerics)
aux_source_directories(SOURCES "Source Files\\mesh"     mesh)
aux_source_directories(SOURCES "Source Files\\delaunay" delaunay)
aux_source_directories(SOURCES "Source Files\\voronoi"  voronoi)
aux_source_directories(SOURCES "Source Files\\points"   points)
aux_source_directories(SOURCES "Source Files\\api"      api)
#aux_source_directories(SOURCES "Source Files\\NL"       NL)
aux_source_directories(SOURCES "Source Files\\image"    image)
aux_source_directories(SOURCES "Source Files\\parameterization" parameterization)
aux_source_directories(SOURCES "Source Files\\bibliography" bibliography)

if(GEOGRAM_WITH_LUA)
aux_source_directories(SOURCES "Source Files\\lua"      lua)
endif()

# Parallel Delaunay now works on both Windows and Unix !
add_definitions(-DGEOGRAM_WITH_PDEL)

# Activate AMGCL support in OpenNL (algebraic multigrid solver)
add_definitions(-DNL_WITH_AMGCL)

# Copy the default version info to the build directory
configure_file(basic/version.h.in version.h @ONLY)
list(APPEND SOURCES version.h)
set_source_files_properties(version.h PROPERTIES GENERATED true)

include_directories(${PROJECT_BINARY_DIR}/src/lib)

add_library(geogram ${SOURCES})

if(GEOGRAM_WITH_THIRD_PARTIES)
   target_include_directories(geogram PRIVATE $<TARGET_OBJECTS:geogram_third_party>)
endif()

target_compile_features(geogram PUBLIC cxx_std_17)

target_include_directories(geogram PRIVATE
${PROJECT_SOURCE_DIR}/src/lib/geogram/third_party/amgcl
)

if(GEOGRAM_WITH_GEOGRAMPLUS)
target_include_directories(geogram PUBLIC
${PROJECT_SOURCE_DIR}/src/lib/geogram/
${PROJECT_SOURCE_DIR}/src/lib/geogram/geogramplus/third_party
)
target_link_libraries(geogram mini-gmp-plus)
endif()

if(GEOGRAM_WITH_TBB)
target_link_libraries(geogram TBB::tbb) # TODO: Use PRIVATE keyword here
target_compile_definitions(geogram PRIVATE -DGEO_TBB)
endif()

if(NOT GEOGRAM_WITH_THIRD_PARTIES)
   find_package(PkgConfig REQUIRED)

   pkg_check_modules(ZLIB REQUIRED IMPORTED_TARGET zlib)
   if (ZLIB_FOUND)
      target_link_libraries(geogram PUBLIC ${ZLIB_LIBRARIES})
   endif()

   find_package(triangle REQUIRED)
   if(triangle_FOUND)
      message(STATUS "Found triangle library")
      target_link_libraries(geogram PUBLIC ${triangle_LIBRARIES})
      target_include_directories(geogram PUBLIC ${triangle_INCLUDE_DIRS})
   endif()

   find_package(tetgen REQUIRED)
   if(tetgen_FOUND)
      message(STATUS "Found tetgen library")
      target_link_libraries(geogram PUBLIC ${tetgen_LIBRARIES})
      target_include_directories(geogram PUBLIC ${tetgen_INCLUDE_DIRS})
   endif()

   find_package(xatlas REQUIRED)
   if(xatlas_FOUND)
      message(STATUS "Found xatlas library")
      target_link_libraries(geogram PUBLIC xatlas)
      #target_include_directories(geogram PUBLIC ${xatlas_INCLUDE_DIRS})
   endif()

   find_package(rply REQUIRED)
   if(RPLY_LIBRARY)
      message(STATUS "Found rply library")
      target_link_libraries(geogram PUBLIC rply)
      target_include_directories(geogram PUBLIC ${RPLY_INCLUDE_DIR}/rply)
   endif()

   find_package(libmeshb REQUIRED)
   if(libMeshb_FOUND)
      message(STATUS "Found libmeshb library")
      target_link_libraries(geogram PUBLIC ${libMeshb_LIBRARIES})
   endif()
endif()

# Jeremie/Maxence: avoids the need to redeclare geogram include
# path for targets that depend on geogram.
# See: https://cmake.org/cmake/help/v3.3/command/target_include_directories.html
# https://stackoverflow.com/questions/26243169/cmake-target-include-directories-meaning-of-scope
target_include_directories(geogram PUBLIC ${PROJECT_SOURCE_DIR}/src/lib)

if(ANDROID)
target_include_directories(geogram PRIVATE
${ANDROID_NDK}/sources/android/native_app_glue
)
message(STATUS "building for Android")
endif()


set_target_properties(geogram PROPERTIES
VERSION ${VORPALINE_VERSION}
SOVERSION ${VORPALINE_VERSION_MAJOR}.${VORPALINE_VERSION_MINOR}.${VORPALINE_VERSION_PATCH}
FOLDER "GEOGRAM")

if(UNIX AND VORPALINE_BUILD_DYNAMIC)
if (ANDROID)
   target_link_libraries(geogram dl)
else()
  if(GEOGRAM_USE_BUILTIN_DEPS)
      target_link_libraries(geogram pthread dl)
  else()
      target_link_libraries(geogram pthread dl lua5.4 z triangle Meshb.7 rply)
  endif()
endif()
endif()

if(WIN32)
target_link_libraries(geogram psapi)
endif()

if(GEOGRAM_WITH_GEOGRAMPLUS)
target_link_libraries(geogram ${GEOGRAMPLUS_LIBS})
endif()

if(GEOGRAM_USE_BUILTIN_DEPS)
    target_compile_definitions(geogram PUBLIC -DGEOGRAM_USE_BUILTIN_DEPS)
endif()

# Install the library
install_devkit_targets(geogram)

# Install include files for the standard devkit
install(
   DIRECTORY api
   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${GEOGRAM_INCLUDE_SUBPATH}
   COMPONENT devkit
   FILES_MATCHING PATTERN *.h
)

# Install include files for the full devkit
install(
   DIRECTORY .
   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${GEOGRAM_INCLUDE_SUBPATH}
   COMPONENT devkit-full
   FILES_MATCHING PATTERN *.h
   # Exclude all files related to licensing
   REGEX /license/ EXCLUDE
)

install(
   FILES "${PROJECT_BINARY_DIR}/${GEOGRAM_SYSTEM_NAME}.pc"
   DESTINATION ${GEOGRAM_INSTALL_PKGCONFIG_DIR}
)
