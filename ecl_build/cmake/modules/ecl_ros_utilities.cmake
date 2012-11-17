###############################################################################
# Ecl-Ros Utilities
###############################################################################
#
#ifdef DOXYGEN_SHOULD_SKIP_THIS
#
# This parses the package's manifest for the package's short description.
# Could easily extend this to a more general macro for *any* package, but
# haven't a need for it yet, so no need to complicate it.
#
# This sets the following variable:
#
# - MANIFEST_SHORT_DESC
macro(ecl_ros_manifest_brief_desc)

    file(READ ${CMAKE_SOURCE_DIR}/manifest.xml MANIFEST_XML)
    #if( ${ARGC} EQUAL 0 )
        # Read this package's manifest.
        #file(READ ${CMAKE_SOURCE_DIR}/manifest.xml MANIFEST_XML)
        # parse CMAKE_SOURCE_DIR for the package name
    #else()
    #    rosbuild_find_ros_package(${ARGV0})
    #    file(READ ${${ARGV0}_PACKAGE_PATH}/manifest.xml MANIFEST_XML)
    #endif()
    string(REGEX REPLACE ".*<description brief=\"(.*)\">.*" "\\1" MANIFEST_BRIEF_DESC ${MANIFEST_XML})
endmacro()

# This gathers the dependencies of the current project as a cmake list.
# Again, could easily extend this to a more general macro for *any*
# package, but dont have a need for that yet.
#
# This sets the following variable:
#
# - ${PROJECT_NAME}_DEPENDENCIES
#
macro(ecl_ros_get_dependency_list)
    rosbuild_invoke_rospack(${PROJECT_NAME} _pkg dependencies "depends")
    string(REGEX REPLACE "\n" ";" ${PROJECT_NAME}_DEPENDENCIES "${_pkg_dependencies}")
endmacro()

# Define standard output paths for ecl-ros packages
macro(ecl_ros_output_paths)
    set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
    set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
    link_directories("${PROJECT_SOURCE_DIR}/lib") # Find the local library for tests and utilities.
endmacro()

#endif DOXYGEN_SHOULD_SKIP_THIS
