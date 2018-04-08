#
# function:
# _REZ_PIP_INSTALL
#
# Function for installing python modules using pip.
#
# Usage:
# _REZ_PIP_INSTALL(URL [ARG1,ARG2 ...])
#


IF(NOT REZ_BUILD_ENV)
  MESSAGE(FATAL_ERROR "RezPipInstall requires that RezBuild has been included")
ENDIF()


FUNCTION(_REZ_PIP_INSTALL)

  PARSE_ARGUMENTS(REZ "URL;ARGS" "" ${ARGN})

  IF(NOT DEFINED REZ_URL)
    MESSAGE(FATAL_ERROR "_REZ_PIP_INSTALL needs to be given URL.")
  ENDIF()


  # Create stageing directory where pip will install into
  SET(STAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/stage")
  FILE(TO_NATIVE_PATH ${STAGE_DIR} STAGE_DIR)
  # Only create and unpack if directory does not exists
  IF(NOT EXISTS ${STAGE_DIR})
    FILE(MAKE_DIRECTORY ${STAGE_DIR})
    EXECUTE_PROCESS( COMMAND
      pip install
        --prefix=${STAGE_DIR}
        --ignore-installed
        --no-deps
        --no-cache-dir
        ${REZ_URL}
    )
  ENDIF()


  # Install target executables with correct permissions
  INSTALL(
    DIRECTORY ${STAGE_DIR}/bin/
    DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    FILE_PERMISSIONS ${REZ_EXECUTABLE_FILE_INSTALL_PERMISSIONS}
  )

  # Install all other files excluding bin
  INSTALL(
    DIRECTORY ${STAGE_DIR}/
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    PATTERN "bin" EXCLUDE
  )

ENDFUNCTION()
