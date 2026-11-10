# Tetgen (by Hang Si) is currently included by default.
# Triangle (by Jonathan Shewchuk) is currently included by default.

configure_file(geogram.pc.in ${PROJECT_BINARY_DIR}/${GEOGRAM_SYSTEM_NAME}.pc @ONLY)

set(GEOGRAM_INCLUDE_SUBPATH ${GEOGRAM_SYSTEM_NAME} CACHE PATH "Header install subpath for geogram")
configure_file(basic/build_config.h.in basic/build_config.h)
foreach(component devkit devkit-full)
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/basic/build_config.h"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${GEOGRAM_INCLUDE_SUBPATH}/basic
    COMPONENT ${component})
endforeach()

if(GEOGRAM_WITH_GEOGRAMPLUS)
   add_subdirectory(geogramplus)
   list(APPEND SOURCES $<TARGET_OBJECTS:geogramplus> $<TARGET_OBJECTS:geogramplus_third_party>)
   target_include_directories(
      geogramplus PRIVATE
      ${PROJECT_SOURCE_DIR}/src/lib/geogram/
   )
   install_devkit_targets(mini-gmp-plus)
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


add_library(geogram ${SOURCES})

if(GEOGRAM_WITH_THIRD_PARTIES)
   target_sources(geogram PRIVATE $<TARGET_OBJECTS:geogram_third_party>)
endif()

target_compile_features(geogram PUBLIC cxx_std_17)

target_include_directories(geogram PRIVATE
${PROJECT_SOURCE_DIR}/src/lib/geogram/third_party/amgcl
)

add_definitions("-DGEOGRAM_VERSION=\"${VORPALINE_VERSION_PLAIN}\"")

if(GEOGRAM_WITH_GEOGRAMPLUS)
target_include_directories(geogram PUBLIC
${PROJECT_SOURCE_DIR}/src/lib/geogram/
${PROJECT_SOURCE_DIR}/src/lib/geogram/geogramplus/third_party
)
target_link_libraries(geogram mini-gmp-plus)
endif()

if(GEOGRAM_WITH_TBB)
   if(GEOGRAM_WITH_THIRD_PARTIES)
      target_link_libraries(geogram PUBLIC TBB::tbb)
   endif()
   target_compile_definitions(geogram PRIVATE GEO_TBB)
endif()

# The standard library's parallel algorithms also use TBB when its headers
# are available, independently of Geogram's explicit TBB implementation.
if(LINUX AND NOT GEOGRAM_WITH_EMSCRIPTEN AND NOT GEOGRAM_WITH_TBB)
   target_link_libraries(geogram PUBLIC tbb)
endif()

if(GEOGRAM_WITH_THIRD_PARTIES)
   target_include_directories(geogram PRIVATE ${PROJECT_SOURCE_DIR}/src/lib/geogram/third_party/OpenNL)
else(GEOGRAM_WITH_THIRD_PARTIES)
   find_package(PkgConfig REQUIRED)

   pkg_check_modules(ZLIB REQUIRED IMPORTED_TARGET zlib)
   target_link_libraries(geogram PUBLIC PkgConfig::ZLIB)

   if(GEOGRAM_WITH_TBB)
      pkg_check_modules(TBB REQUIRED IMPORTED_TARGET tbb)
      target_link_libraries(geogram PUBLIC PkgConfig::TBB)
   endif()

   find_package(triangle REQUIRED)
   message(STATUS "Found triangle library")
   target_link_libraries(geogram PUBLIC ${triangle_LIBRARIES})
   target_include_directories(geogram PUBLIC ${triangle_INCLUDE_DIRS})

   find_package(tetgen REQUIRED)
   message(STATUS "Found tetgen library")
   target_link_libraries(geogram PUBLIC ${tetgen_LIBRARIES})
   target_include_directories(geogram PUBLIC ${tetgen_INCLUDE_DIRS})

   find_package(xatlas REQUIRED)
   message(STATUS "Found xatlas library")
   target_link_libraries(geogram PUBLIC xatlas)

   find_package(rply REQUIRED)
   message(STATUS "Found rply library")
   target_link_libraries(geogram PUBLIC rply)
   target_include_directories(geogram PUBLIC ${RPLY_INCLUDE_DIR}/rply)

   find_package(libmeshb REQUIRED)
   message(STATUS "Found libmeshb library")
   target_link_libraries(geogram PUBLIC ${libMeshb_LIBRARIES})
   target_include_directories(geogram PUBLIC ${libMeshb_INCLUDE_DIRS})

   find_package(OpenNL REQUIRED)
   message(STATUS "Found OpenNL library")
   target_link_libraries(geogram PUBLIC ${OpenNL_LIBRARIES})
   target_include_directories(geogram PUBLIC ${OpenNL_INCLUDE_DIRS})
   # Public GUI headers declare Lua types even with the interpreter disabled.
   find_package(Lua 5.4 REQUIRED)
   target_include_directories(geogram PUBLIC ${LUA_INCLUDE_DIR})
   if(GEOGRAM_WITH_LUA)
      target_link_libraries(geogram PUBLIC ${LUA_LIBRARIES})
   endif()
endif()

# Jeremie/Maxence: avoids the need to redeclare geogram include
# path for targets that depend on geogram.
# See: https://cmake.org/cmake/help/v3.3/command/target_include_directories.html
# https://stackoverflow.com/questions/26243169/cmake-target-include-directories-meaning-of-scope
target_include_directories(geogram PUBLIC
  ${PROJECT_SOURCE_DIR}/src/lib
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/src/lib>)

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
  target_link_libraries(geogram PUBLIC pthread dl)
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
