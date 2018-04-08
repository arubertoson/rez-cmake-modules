project(bm_cmake_modules NONE)

include(RezBuild)

file(GLOB_RECURSE cmake_modules "cmake/*.cmake")
REZ_INSTALL_FILES(
  ${cmake_modules}
  DESTINATION .
  LOCAL_SYMLINK
)
