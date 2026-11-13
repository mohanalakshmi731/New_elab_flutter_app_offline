cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# eLabs or MathZoro: the same IS_MATHZORO switch as android/app/build.gradle.kts.
# `flutter build/run ... --dart-define=IS_MATHZORO=true` writes the defines
# into generated_config.cmake (rewritten and re-read on every build), each one
# base64-encoded on its own, so "IS_MATHZORO=true" is always the same text.
# Runner.rc uses APP_IS_MATHZORO to pick the exe icon and file description.
set(FLUTTER_GENERATED_CONFIG "${FLUTTER_MANAGED_DIR}/ephemeral/generated_config.cmake")
if(EXISTS "${FLUTTER_GENERATED_CONFIG}")
  file(READ "${FLUTTER_GENERATED_CONFIG}" FLUTTER_GENERATED_CONFIG_TEXT)
  # SVNfTUFUSFpPUk89dHJ1ZQ== is base64("IS_MATHZORO=true").
  if(FLUTTER_GENERATED_CONFIG_TEXT MATCHES "[=,]SVNfTUFUSFpPUk89dHJ1ZQ==[,\"]")
    target_compile_definitions(${BINARY_NAME} PRIVATE "APP_IS_MATHZORO")
  endif()
endif()

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
