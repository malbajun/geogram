# Documentation generation is optional; install release/license information
# regardless of whether Doxygen is available on the build host.
include(${PROJECT_SOURCE_DIR}/cmake/doxygen.cmake)
configure_file(VERSION.txt.in VERSION.txt @ONLY)
install(FILES "${PROJECT_SOURCE_DIR}/README.md" "${PROJECT_SOURCE_DIR}/LICENSE"
  "${CMAKE_CURRENT_BINARY_DIR}/VERSION.txt"
  DESTINATION ${CMAKE_INSTALL_DOCDIR} COMPONENT runtime)
if(DOXYGEN_FOUND)
  add_doc_target(devkit)
  add_doc_target(devkit-full)
  add_doc_target(devkit-internal)
  add_doc_target(devkit-internal-light)
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/devkit/html
    DESTINATION ${CMAKE_INSTALL_DOCDIR}/devkit COMPONENT doc-devkit OPTIONAL)
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/devkit-full/html
    DESTINATION ${CMAKE_INSTALL_DOCDIR}/devkit-full COMPONENT doc-devkit-full OPTIONAL)
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/devkit-internal/html
    DESTINATION ${CMAKE_INSTALL_DOCDIR}/devkit-internal COMPONENT doc-devkit-internal OPTIONAL)
endif()
