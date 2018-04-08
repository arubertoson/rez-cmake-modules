# -----------------------------------------------------------------------------

project(cmake_modules NONE)


include(RezBuild)


file(GLOB modules "cmake/*.cmake")
REZ_INSTALL_FILES(
  ${modules}
  DESTINATION .
  LOCAL_SYMLINK
)

# -----------------------------------------------------------------------------
