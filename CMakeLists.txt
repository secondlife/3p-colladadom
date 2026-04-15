cmake_minimum_required (VERSION 3.22.0)
project (collada-dom)
set( CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS TRUE )

# Define here the needed parameters
set (COLLADA_DOM_VERSION_MAJOR 2)
set (COLLADA_DOM_VERSION_MINOR 3)
set (COLLADA_DOM_VERSION_PATCH 2)
set (COLLADA_DOM_VERSION ${COLLADA_DOM_VERSION_MAJOR}.${COLLADA_DOM_VERSION_MINOR}.${COLLADA_DOM_VERSION_PATCH})
set (COLLADA_DOM_SOVERSION ${COLLADA_DOM_VERSION_MAJOR}.${COLLADA_DOM_VERSION_MINOR})

message(STATUS "Compiling Collada DOM Version ${COLLADA_DOM_VERSION}")
message(STATUS "Using cmake version ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" )

# Use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH  FALSE)

# When building, don't use the install RPATH already
# (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

# The RPATH to be used when installing
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}")

# Add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

message(STATUS "installing to ${CMAKE_INSTALL_PREFIX}")

##############################################################################
# Custom CMake options
##############################################################################

option(OPT_COLLADA14 "Enable collada 1.4 compilation" ON)
option(OPT_COLLADA15 "Enable collada 1.5 compilation" OFF)

find_package(ZLIB REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(Boost REQUIRED COMPONENTS filesystem regex)

find_package(PkgConfig REQUIRED)
pkg_check_modules(MINIZIP REQUIRED IMPORTED_TARGET GLOBAL minizip)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
set(COLLADA14_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include/1.4)
set(COLLADA15_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include/1.5)
file(GLOB dae_files ${CMAKE_CURRENT_SOURCE_DIR}/src/dae/*.cpp)
file(GLOB libxmlplugin_files ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/LIBXMLPlugin/*.cpp)
file(GLOB stddatabase_files ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/STLDatabase/*.cpp)
file(GLOB stderrplugin_files ${CMAKE_CURRENT_SOURCE_DIR}/src/modules/stdErrPlugin/*.cpp)

set(COLLADA_BASE_SOURCES ${dae_files} ${libxmlplugin_files} ${stddatabase_files} ${stderrplugin_files})
set(COLLADA_COMPILE_FLAGS "${EXTRA_COMPILE_FLAGS}")

if( LIBXML2_FOUND )
  set(COLLADA_COMPILE_FLAGS "${COLLADA_COMPILE_FLAGS} -DDOM_INCLUDE_LIBXML")
endif()

if (BUILD_SHARED_LIBS)
  # Dynamic library flags
  set(COLLADA_COMPILE_FLAGS "${COLLADA_COMPILE_FLAGS} -DDOM_DYNAMIC -DDOM_EXPORT")
endif()

set(COLLADA_DOM_INCLUDE_INSTALL_DIR "include/collada-dom")

if( OPT_COLLADA15 )
  add_subdirectory(src/1.5)
  install(DIRECTORY ${COLLADA15_INCLUDE_DIR} DESTINATION ${COLLADA_DOM_INCLUDE_INSTALL_DIR} PATTERN ".svn" EXCLUDE PATTERN ".~" EXCLUDE)
endif()
if( OPT_COLLADA14 )
  add_subdirectory(src/1.4)
  install(DIRECTORY ${COLLADA14_INCLUDE_DIR} DESTINATION ${COLLADA_DOM_INCLUDE_INSTALL_DIR} PATTERN ".svn" EXCLUDE PATTERN ".~" EXCLUDE)
endif()

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/dae DESTINATION ${COLLADA_DOM_INCLUDE_INSTALL_DIR} PATTERN ".svn" EXCLUDE PATTERN ".~" EXCLUDE)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/modules DESTINATION ${COLLADA_DOM_INCLUDE_INSTALL_DIR} PATTERN ".svn" EXCLUDE PATTERN ".~" EXCLUDE)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/dae.h ${CMAKE_CURRENT_SOURCE_DIR}/include/dae.h DESTINATION ${COLLADA_DOM_INCLUDE_INSTALL_DIR})
