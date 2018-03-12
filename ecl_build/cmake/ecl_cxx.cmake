##############################################################################
# Detect
##############################################################################

macro(ecl_check_for_cxx14_compiler CX14_COMPILER_FOUND)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-std=c++14" CXX14_COMPILER_FOUND)
endmacro()

macro(ecl_check_for_cxx11_compiler CX11_COMPILER_FOUND)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-std=c++11" CXX11_COMPILER_FOUND)
endmacro()

macro(ecl_check_for_cxx0x_compiler CXX0X_COMPILER_FOUND)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-std=c++0x" CXX0X_COMPILER_FOUND)
endmacro()

##############################################################################
# Enable
##############################################################################

# Might prefer to handle it better using the cmake variables
# e.g. https://github.com/ros2/realtime_support/blob/master/tlsf_cpp/CMakeLists.txt#L10
macro(ecl_enable_cxx14_compiler)
  ecl_check_for_cxx14_compiler(CXX14_COMPILER_FOUND)
  if(CXX14_COMPILER_FOUND)
    # Includes additional flags that the ros2 libraries build in by default
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -Wall -Wextra -Wl,--no-as-needed")
  else()
    message(FATAL_ERROR "Requested cxx14 flags, but this compiler does not support it.")
  endif()
endmacro()

# This is tricky, it won't be default in g++ until version 6.0
# and in that, it will be c++14, not c++11. And this is
# forever away.
#
# CMake has alot of help coming...starting in 2.8.12 and much
# more in 3.1. The problem with using this macro below
# directly, is that every user of a library also has to
# enable it himself. To make the dependency transitive, i.e.
# embed information in the library, you should add compile
# options/features to the target.
#
# For examples, see what we did in ecl_linear algebra, or
# what ceres-solver has done in
#
#    https://ceres-solver.googlesource.com/ceres-solver/+/master/internal/ceres/CMakeLists.txt
#
# Note, there are better ways of doing this in 3.1+.
macro(ecl_enable_cxx11_compiler)
  ecl_check_for_cxx11_compiler(CXX11_COMPILER_FOUND)
  if(CXX11_COMPILER_FOUND)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  else()
    message(FATAL_ERROR "Requested cxx11 flags, but this compiler does not support it.")
  endif()
endmacro()

macro(ecl_enable_cxx0x_compiler)
  ecl_check_for_cxx0x_compiler(CXX0X_COMPILER_FOUND)
  if(CXX0X_COMPILER_FOUND)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
  else()
    message(FATAL_ERROR "Requested cxx0x flags, but this compiler does not support it.")
  endif()
endmacro()

