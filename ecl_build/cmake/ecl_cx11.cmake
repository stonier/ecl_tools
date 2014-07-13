macro(ecl_check_for_cxx11_compiler CX11_COMPILER_FOUND)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-std=c++11" CXX11_COMPILER_FOUND)
endmacro()

macro(ecl_check_for_cxx0x_compiler CXX0X_COMPILER_FOUND)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-std=c++0x" CXX0X_COMPILER_FOUND)
endmacro()


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

