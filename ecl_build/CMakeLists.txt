##############################################################################
# Cmake
##############################################################################

cmake_minimum_required(VERSION 3.5)
project(ecl_build)

##############################################################################
# ament
##############################################################################

find_package(ament_cmake REQUIRED)

set(${PROJECT_NAME}_MODULES "")
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_platform_detection.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_package.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_find_sse.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_build_utilities.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/ecl_cx11.cmake)
list(APPEND ${PROJECT_NAME}_MODULES ${CMAKE_SOURCE_DIR}/cmake/cotire.cmake)

ament_export_include_directories(include)
ament_export_libraries(${PROJECT_NAME})
ament_package(CONFIG_EXTRAS ${${PROJECT_NAME}_MODULES})

##############################################################################
# Work
##############################################################################

install(DIRECTORY cmake
        DESTINATION share
)

