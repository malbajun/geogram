include(${PROJECT_SOURCE_DIR}/cmake/opengl.cmake)

configure_file(geogram_gfx.pc.in ${PROJECT_BINARY_DIR}/${GEOGRAMGFX_SYSTEM_NAME}.pc @ONLY)

set(GEOGRAMGFX_INCLUDE_SUBPATH ${GEOGRAMGFX_SYSTEM_NAME} CACHE PATH "Header install subpath for geogram gfx")

add_definitions(-DIMGUI_USER_CONFIG="geogram_imconfig.h")

if(GEOGRAM_WITH_THIRD_PARTIES)
   add_subdirectory(third_party)
endif()

aux_source_directories(SOURCES "Source Files"                .)
aux_source_directories(SOURCES "Source Files\\imgui_ext"     imgui_ext)
aux_source_directories(SOURCES "Source Files\\api"           api)
aux_source_directories(SOURCES "Source Files\\basic"         basic)
aux_source_directories(SOURCES "Source Files\\mesh"          mesh)
aux_source_directories(SOURCES "Source Files\\GLUP"          GLUP)
aux_source_directories(SOURCES "Source Files\\GLUP\\shaders" GLUP/shaders)
aux_source_directories(SOURCES "Source Files\\full_screen_effects" full_screen_effects)
aux_source_directories(SOURCES "Source Files\\gui"           gui)

if(GEOGRAM_WITH_LUA)
aux_source_directories(SOURCES "Source Files\\lua"           lua)
endif()

if(GEOGRAM_WITH_THIRD_PARTIES)
   add_library(geogram_gfx SHARED ${SOURCES} $<TARGET_OBJECTS:geogram_gfx_third_party>)

   target_include_directories(geogram_gfx PUBLIC ${PROJECT_SOURCE_DIR}/src/lib/geogram_gfx/third_party)
   target_include_directories(geogram_gfx PRIVATE ${PROJECT_SOURCE_DIR}/src/lib/geogram_gfx/third_party/imgui)
else()
   # from 3rdparty since autogenerate the glad project is too complex
   aux_source_directories(SOURCES "Source Files\\third_party\\glad"      third_party/glad)

   add_library(geogram_gfx SHARED ${SOURCES})

   find_package(libmeshb REQUIRED)

   if(GEOGRAM_USE_SYSTEM_GLFW3)
      add_definitions(-DGEO_USE_SYSTEM_GLFW3)
   endif()

   find_package(imgui REQUIRED)
   target_link_libraries(geogram_gfx PUBLIC ${imgui_LIBRARIES})
   target_include_directories(geogram_gfx PRIVATE ${imgui_INCLUDE_DIRS})

   find_package(ImGuiColorTextEdit REQUIRED)
   target_link_libraries(geogram_gfx PUBLIC ${ImGuiColorTextEdit_LIBRARIES})
   target_include_directories(geogram_gfx PRIVATE ${ImGuiColorTextEdit_INCLUDE_DIRS})
endif()

if(ANDROID)
target_include_directories(geogram_gfx PRIVATE
${ANDROID_NDK}/sources/android/native_app_glue
)
message(STATUS "building for Android")
endif()

set_target_properties(geogram_gfx PROPERTIES
VERSION ${VORPALINE_VERSION}
SOVERSION ${VORPALINE_VERSION_MAJOR}
FOLDER "GEOGRAM")

if(NOT ANDROID)
   target_link_libraries(geogram_gfx PUBLIC glfw)
endif()

if(VORPALINE_BUILD_DYNAMIC)
# Must provide all symbols at link time
   target_link_libraries(geogram_gfx PUBLIC geogram)
   target_link_libraries(geogram_gfx PUBLIC ${OPENGL_LIBRARIES})
endif()

# Install the library
install_devkit_targets(geogram_gfx)

# Install include files for the standard devkit
install(
   DIRECTORY .
   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${GEOGRAMGFX_INCLUDE_SUBPATH}
   COMPONENT devkit
   FILES_MATCHING PATTERN *.h
)

# Install include files for the full devkit
install(
   DIRECTORY .
   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${GEOGRAMGFX_INCLUDE_SUBPATH}
   COMPONENT devkit-full
   FILES_MATCHING PATTERN *.h
)

install(
   FILES "${PROJECT_BINARY_DIR}/${GEOGRAMGFX_SYSTEM_NAME}.pc"
   DESTINATION lib${LIB_SUFFIX}/pkgconfig
)
