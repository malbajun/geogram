aux_source_directories(SOURCES "" .)

vor_reset_warning_level()

if(GEOGRAM_USE_BUILTIN_DEPS)
aux_source_directories(SOURCES "" ./third_party/ANN)
endif()

vor_add_executable(test_nn_search ${SOURCES})

target_link_libraries(test_nn_search geogram)
if(NOT GEOGRAM_USE_BUILTIN_DEPS)
    find_path(ANN_INCLUDE_DIR ANN/ANN.h)
    find_library(ANN_LIBRARY NAMES ANN ann)
    if(NOT ANN_INCLUDE_DIR OR NOT ANN_LIBRARY)
        message(FATAL_ERROR "The unbundled nearest-neighbor test requires ANN development files")
    endif()
    target_include_directories(test_nn_search PRIVATE ${ANN_INCLUDE_DIR})
    target_link_libraries(test_nn_search ${ANN_LIBRARY})
endif()

set_target_properties(test_nn_search PROPERTIES FOLDER "GEOGRAM/Tests")
