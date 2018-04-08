#
# function:
# SET_PIP_ARCHIVE
#
# usage:
# SET_PIP_ARCHIVE(NAME VERSION RELATIVE_PATH)
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


FUNCTION(SET_PIP_ARCHIVE)

  parse_arguments(PIP "NAME;VERSION;RELATIVE_PATH" "" ${ARGN})


  IF(NOT DEFINED REZ_NAME OR NOT DEFINED REZ_VERSION)
    MESSAGE(FATAL_ERROR 
      "REZ_SET_PIP_ARCHIVE requires that NAME and VERSION are given.")
  ENDIF()


  # We can't determine location of archives without the rez repo variable set
  IF(NOT DEFINED ENV{PIP_REPO_PAYLOAD_DIR})
    MESSAGE(FATAL_ERROR "PIP_REPO_PAYLOAD_DIR environment variable is not set")
  ENDIF()


  # Optional relative path under rez repo
  IF(NOT DEFINED PIP_RELATIVE_PATH)
    SET(PIP_SUBDIR pip)
  ELSE()
    SET(PIP_SUBDIR ${REZ_RELATIVE_PATH})
  ENDIF()


  SET(PIP_ARCHIVE "$ENV{REZ_REPO_PAYLOAD_DIR}/${SUBDIR}/${REZ_NAME}")
  MESSAGE("ARCHIVE: ${PIP_ARCHIVE}")
  IF(NOT EXISTS PIP_ARCHIVE)
    FILE(MAKE_DIRECTORY "${PIP_ARCHIVE}")
  ENDIF()

  # We try to avoid fetching wheels as they come prebuilt and is most of the
  # time not what we want, if we want to use wheels you have to be explicit and
  # download it manually.
  EXECUTE_PROCESS(
    COMMAND 
      pip download 
        --no-deps "${PIP_NAME}==${REZ_VERSION}"
        --no-binary ${PIP_NAME}
      WORKING_DIRECTORY ${PIP_ARCHIVE}
  )
  FILE(GLOB PACKAGE_ARCHIVE "${PIP_ARCHIVE}/${REZ_NAME}*${REZ_VERSION}*")


  IF(PACKAGE_ARCHIVE) 
    SET(REZ_PIP_ARCHIVE ${PACKAGE_ARCHIVE} PARENT_SCOPE)
  ELSE()
    MESSAGE(FATAL_ERROR "Couldn't perform pip download, consider manually downloading and using rez_set_archive instead.")
  ENDIF()

ENDFUNCTION()

