file(GLOB dom_files ${CMAKE_CURRENT_SOURCE_DIR}/dom/*.cpp)
include_directories(${COLLADA14_INCLUDE_DIR})
add_library(collada14dom ${COLLADA_BASE_SOURCES} ${dom_files})
target_link_libraries(collada14dom Boost::disable_autolinking Boost::headers Boost::filesystem LibXml2::LibXml2 PkgConfig::MINIZIP ZLIB::ZLIB)
set_target_properties(collada14dom PROPERTIES
  COMPILE_FLAGS "${COLLADA_COMPILE_FLAGS}"
  CLEAN_DIRECT_OUTPUT 1
  SOVERSION ${COLLADA_DOM_SOVERSION}
  VERSION ${COLLADA_DOM_VERSION})
install(TARGETS collada14dom DESTINATION lib${LIB_SUFFIX})
