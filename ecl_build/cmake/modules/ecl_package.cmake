###############################################################################
# Building ecl packages (c.f. rosbuild.cmake for ros)
###############################################################################
#
# NOT FOR REGULAR CONSUMPTION! THIS IS ONLY USED BY ECL PACKAGES!
#

#ifdef DOXYGEN_SHOULD_SKIP_THIS

###############################################################################
# Version
###############################################################################

# Set the ecl version.
macro(ecl_version)
    set(PROJECT_VERSION "0.44.0")
    set(PROJECT_VERSION_MAJOR "0")
    set(PROJECT_VERSION_MINOR "44")
    set(PROJECT_VERSION_PATCH "0")
endmacro()

###############################################################################
# Source Installer
###############################################################################
#
# Collects all *.c, *.cpp, *.h, *.hpp files together and installs them to
# CMAKE_INSTALL_PREFIX under the include/pkg_name and src/pkg_name 
# directories respectively.
#
# This is useful for collecting sources for firmware builds in another ide.
#
macro(ecl_roll_source_installs)
  FILE(GLOB_RECURSE PACKAGE_HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} FOLLOW_SYMLINKS *.h *.hpp)
  FILE(GLOB_RECURSE PACKAGE_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} FOLLOW_SYMLINKS src/lib/*.c src/lib/*.cpp)
  add_custom_target(sources
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "Installing sources."
    )
  foreach(_file ${PACKAGE_HEADERS})
    get_filename_component(_dir ${_file} PATH)
    get_filename_component(_filename ${_file} NAME)
    string(REGEX REPLACE "/" "_" _target_name ${_file})
    add_custom_target(include_${_target_name}
      ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${_dir}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_file} ${CMAKE_INSTALL_PREFIX}/${_file}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    add_dependencies(sources include_${_target_name})
  endforeach(_file ${PACKAGE_HEADERS})
  foreach(_file ${PACKAGE_SOURCES})
    set(_dir ${CMAKE_INSTALL_PREFIX}/src/${PROJECT_NAME})
    get_filename_component(_filename ${_file} NAME)
    string(REGEX REPLACE "/" "_" _target_name ${_file})
    # Should probably convert slashes to underscores instead here.
    add_custom_target(source_${_target_name}
      ${CMAKE_COMMAND} -E make_directory ${_dir}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_file} ${_dir}/${_filename}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    add_dependencies(sources source_${_target_name})
  endforeach(_file ${PACKAGE_SOURCES})
endmacro()

###############################################################################
# CPack
###############################################################################

# Currently it just builds debian packages. It needs some prerequisites to
# function, currently:
#
# - you must include ecl_platform_detection, ecl_ros_utilities
# - you must have called ecl_detect_distro (or ecl_detect_platform) first
#   - this sets DISTRO_NAME, DISTRO_VERSION_STRING which is needed by this script
#
# Ultimately in the ecl packages, all that is needed is to call ecl_init
# first (which preps all of the above), then after including your subdirectories
# call this macro.
#
macro(ecl_roll_cpack_packages)
    # Distro
    if(NOT DISTRO_NAME STREQUAL "Ubuntu")
        message(STATUS "CPack configuration aborted : not ubuntu.")
        set(CPACK_DEBIAN_ABORT TRUE)
        # return() this doesn't work...automatically causes the parent macro to return as well.
    endif()
    # Build type
    if(NOT CPACK_DEBIAN_ABORT)
        if(${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo")
            set(CPACK_BUILD_TYPE_POSTFIX "-debug")
        elseif(${CMAKE_BUILD_TYPE} STREQUAL "Release")
            set(CPACK_BUILD_TYPE_POSTFIX "")
        else()
            message(STATUS "CPack configuration : aborted, invalid build mode (only RelWithDebInfo|Release).")
            set(CPACK_DEBIAN_ABORT TRUE)
        endif()
    endif()
    if(NOT CPACK_DEBIAN_ABORT)
        # Architecture
        if(PLATFORM_IS_32_BIT)
            set(UBUNTU_ARCH "i386")
        else() # 64 bit
            set(UBUNTU_ARCH "amd64")
        endif()
        # Description
        ecl_ros_manifest_brief_desc() # -> MANIFEST_SHORT_DESC
        # Dependencies
        ecl_ros_get_dependency_list() # -> ${PROJECT_NAME}_DEPENDENCIES
        # CPack    
        set(CPACK_PACKAGE_NAME ${PROJECT_NAME}${CPACK_BUILD_TYPE_POSTFIX})
        set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
        set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
        set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
        set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
        set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}${CPACK_BUILD_TYPE_POSTFIX}-${CPACK_PACKAGE_VERSION})
        set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${MANIFEST_BRIEF_DESC}")
        set(CPACK_INSTALL_PREFIX /usr)
        set(CPACK_DEBIAN_PACKAGE_SECTION "universe/libdevel")
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "")
        # Need to weed out rosbuild (used by ecl_build) from tainting this list
        foreach(dep ${${PROJECT_NAME}_DEPENDENCIES})
            if ( NOT dep STREQUAL "rosbuild")
                if("${CPACK_DEBIAN_PACKAGE_DEPENDS}" STREQUAL "")
                    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${dep}${CPACK_BUILD_TYPE_POSTFIX} (>= ${PROJECT_VERSION})")
                else()
                    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS}, ${dep}${CPACK_BUILD_TYPE_POSTFIX} (>= ${PROJECT_VERSION})")
                endif()
            endif()
        endforeach()
        # If no dependencies, make the base dependency string.
        if ( CPACK_DEBIAN_PACKAGE_DEPENDS STREQUAL "")
            set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.9-4), libgcc1 (>= 1:4.3.3-5), libstdc++6 (>= 4.1.1)")
        endif() 
        set(CPACK_SET_DESTDIR ON)
        set(CPACK_GENERATOR "DEB")
        set(CPACK_PACKAGE_CONTACT "d.stonier@gmail.com")
        set(CPACK_DEBIAN_ARCHITECTURE "${UBUNTU_ARCH}")
        set(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};${CPACK_PACKAGE_NAME};ALL;/")
        set(CPACK_MODULE_PATH "${CMAKE_MODULE_PATH}")
        set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
        include(CPack)
    
        # Uploading
        set(PKG_HOST_URL "snorriheim.dnsdojo.com")
        set(PKG_HOST_HTTP "http://${PKG_HOST_URL}")
        set(PKG_HOST_SSH "snorri@${PKG_HOST_URL}")
        set(UBUNTU_REPO_URL "${PKG_HOST_HTTP}/packages/dists/${DISTRO_VERSION_STRING}/${UBUNTU_ARCH}")
        set(UBUNTU_REPO_SSH "${PKG_HOST_SSH}:/mnt/froody/servers/packages/dists/${DISTRO_VERSION_STRING}/${UBUNTU_ARCH}/")
        
        add_custom_target(upload
            COMMAND scp ${CMAKE_BINARY_DIR}/*.deb ${UBUNTU_REPO_SSH}
            COMMAND ssh ${PKG_HOST_SSH} '/mnt/froody/servers/scripts/update_ubuntu_repos'
            COMMENT "Uploading .debs to the package repository."
        )
        message(STATUS "CPack debian packaging configured.")
        message("")
    endif()
    
endmacro()

# A summary of the cpack results.
macro(ecl_summary_cpack)
    if(NOT CPACK_DEBIAN_ABORT)
        message("-------------------------------------------------------------------")
        message("CPack Summary")
        message("-------------------------------------------------------------------")
        message("")
        # For some reason CPACK_PACKAGE_FILE_NAME gets overwritten by include(CPack)
        # so I can't print it correctly here...but the debian file is still correctly named 
        # in the long run.
        message("Package name....................${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
        message("Build mode......................${CMAKE_BUILD_TYPE}")
        message("Description.....................${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
        if(NOT ${CPACK_DEBIAN_PACKAGE_DEPENDS} STREQUAL "")
            message("Dependencies....................${CPACK_DEBIAN_PACKAGE_DEPENDS}")
        endif()
    endif()
    message("")
endmacro()

###############################################################################
# Custom target
###############################################################################
# These are nice in that they let us have targets outside the mainstream
# build process. You can either target an executable for a
# example/benchmark/utility build or build all of them together under the
# apps umbrella
#
macro(ecl_add_example exe)
  message(STATUS "Adding ${exe} to the examples target.")
  add_custom_target(apps)
  add_custom_target(examples)
  rosbuild_add_executable(${exe} EXCLUDE_FROM_ALL ${ARGN})
  add_dependencies(apps ${exe})
  add_dependencies(examples ${exe})
endmacro(ecl_add_example)

macro(ecl_add_benchmark exe)
  message(STATUS "Adding ${exe} to the benchmarks target.")
  add_custom_target(apps)
  add_custom_target(benchmarks)
  rosbuild_add_executable(${exe} EXCLUDE_FROM_ALL ${ARGN})
  add_dependencies(apps ${exe})
  add_dependencies(benchmarks ${exe})
endmacro(ecl_add_benchmark)

macro(ecl_add_utility exe)
  message(STATUS "Adding ${exe} to the utilities target.")
  add_custom_target(apps)
  add_custom_target(utilities)
  rosbuild_add_executable(${exe} EXCLUDE_FROM_ALL ${ARGN})
  add_dependencies(apps ${exe})
  add_dependencies(utilities ${exe})
endmacro(ecl_add_utility)


###############################################################################
# Libraries
###############################################################################

macro(ecl_add_library lib_target)
  message(STATUS "Building library ${lib}.")
  rosbuild_add_library(${lib_target} ${ARGN})
  # Visibility support
  if(ROS_BUILD_SHARED_LIBS)
    if(CMAKE_COMPILER_IS_GNUCXX)
      rosbuild_add_compile_flags(${lib_target} -DECL_BUILDING_SHARED_LIB -fvisibility=hidden)
    endif()
    if(MSVC)
      rosbuild_add_compile_flags(${lib_target} -DECL_BUILDING_SHARED_LIB)
    endif()
  endif()
endmacro()

###############################################################################
# Init for a generic ecl package (aka rosbuild_init())
###############################################################################
# This must be called after rosbuild_init has been called - i.e. usually
#
# include($ENV{ROS_ROOT}/core/rosbuild/rosbuild.cmake)
# rosbuild_init()
# rosbuild_include(ecl_build eclbuild.cmake)
#
macro(ecl_package_init)

    # Modules
    rosbuild_find_ros_package(ecl_build)
    set(CMAKE_MODULE_PATH ${ecl_build_PACKAGE_PATH}/cmake/modules)
    include(ecl_platform_detection)
    include(ecl_build_utilities)
    include(ecl_ros_utilities)

    # Ecl configuration
    ecl_version()
    ecl_detect_platform()
    ecl_set_platform_cflags()
    ecl_link_as_needed(ECL_LINK_AS_NEEDED_FLAG)
    set(ROS_LINK_FLAGS "${ROS_LINK_FLAGS} ${ECL_LINK_AS_NEEDED_FLAG}")
    ecl_add_uninstall_target()
    ecl_roll_source_installs()
    ecl_roll_cpack_packages()
    ecl_ros_output_paths()
endmacro()

macro(ecl_package_finalise)
    ecl_summary_platform()
    ecl_summary_cpack()
endmacro()

#endif DOXYGEN_SHOULD_SKIP_THIS

