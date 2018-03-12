##############################################################################
# Cmake
##############################################################################

cmake_minimum_required(VERSION 3.5)
project(ecl_build)

##############################################################################
# Find Packages
##############################################################################

find_package(ament_cmake REQUIRED)

##############################################################################
# CMake Modules
##############################################################################

set(${PROJECT_NAME}_MODULES "")
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_platform_detection.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_package.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_find_sse.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_build_utilities.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_cxx.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/cotire.cmake)

##############################################################################
# Exports
##############################################################################

ament_package(CONFIG_EXTRAS ${${PROJECT_NAME}_MODULES})

##############################################################################
# Installs
##############################################################################

install(DIRECTORY cmake
        DESTINATION share
)

