#
# function:
# REZ_SET_PIP_ARCHIVE
#
# usage:
# REZ_SET_PIP_ARCHIVE(NAME VERSION RELATIVE_PATH)
#
# This macro checks for the existance of a pip archive at the relative path,
# under the path specified by $REZ_REPO_PAYLOAD_DIR. It will ask pip to download
# the archive to a location, if the file already exists it will only set the
# variable to the archive otherwise it'll download and set the variable.
#
# DEFINES:
#
# REZ_PIP_ARCHIVE   :Path to pip archive
#


FUNCTION(REZ_SET_PIP_ARCHIVE)

  parse_arguments(REZ "NAME;VERSION;RELATIVE_PATH" "" ${ARGN})


  IF(NOT DEFINED REZ_NAME OR NOT DEFINED REZ_VERSION)
    MESSAGE(FATAL_ERROR 
      "REZ_SET_PIP_ARCHIVE requires that NAME and VERSION are given.")
  ENDIF()


  # We can't determine location of archives without the rez repo variable set
  IF(NOT DEFINED ENV{REZ_REPO_PAYLOAD_DIR})
    MESSAGE(FATAL_ERROR "REZ_REPO_PAYLOAD_DIR environment variable is not set")
  ENDIF()


  # Optional relative path under rez repo
  IF(NOT DEFINED REZ_RELATIVE_PATH)
    SET(REZ_SUBDIR pip)
  ELSE()
    SET(REZ_SUBDIR ${REZ_RELATIVE_PATH})
  ENDIF()


  SET(REZ_ARCHIVE "$ENV{REZ_REPO_PAYLOAD_DIR}/${SUBDIR}/${REZ_NAME}")
  MESSAGE("ARCHIVE: ${REZ_ARCHIVE}")
  IF(NOT EXISTS REZ_ARCHIVE)
    FILE(MAKE_DIRECTORY "${REZ_ARCHIVE}")
  ENDIF()

  # We try to avoid fetching wheels as they come prebuilt and is most of the
  # time not what we want, if we want to use wheels you have to be explicit and
  # download it manually.
  EXECUTE_PROCESS(
    COMMAND 
      pip download 
        --no-deps "${REZ_NAME}==${REZ_VERSION}"
        --no-binary ${REZ_NAME}
      WORKING_DIRECTORY ${REZ_ARCHIVE}
  )
  FILE(GLOB PACKAGE_ARCHIVE "${REZ_ARCHIVE}/${REZ_NAME}*${REZ_VERSION}*")


  IF(PACKAGE_ARCHIVE) 
    SET(REZ_PIP_ARCHIVE ${PACKAGE_ARCHIVE} PARENT_SCOPE)
  ELSE()
    MESSAGE(FATAL_ERROR "Couldn't perform pip download, consider manually downloading and using rez_set_archive instead.")
  ENDIF()

ENDFUNCTION()

