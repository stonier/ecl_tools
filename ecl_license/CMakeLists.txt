##############################################################################
# Cmake
##############################################################################

cmake_minimum_required(VERSION 3.5)
project(ecl_license)

##############################################################################
# ament
##############################################################################

find_package(ament_cmake)


##############################################################################
# Installs
##############################################################################


install(DIRECTORY licenses 
        DESTINATION share
        PATTERN ".svn" EXCLUDE
        PATTERN "CMakeLists.txt" EXCLUDE
       )

ament_export_include_directories(include)
ament_export_libraries(${PROJECT_NAME})
ament_package()
