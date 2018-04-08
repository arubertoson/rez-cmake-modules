#
# function:
# PIP_INSTALL
#
# Function for installing python modules using pip.
#
# Usage:
# PIP_INSTALL(URL [ARG1,ARG2 ...])
#


IF(NOT REZ_BUILD_ENV)
  MESSAGE(FATAL_ERROR "RezPipInstall requires that RezBuild has been included")
ENDIF()


FUNCTION(PIP_INSTALL)

  PARSE_ARGUMENTS(PIP "URL;ARGS" "" ${ARGN})

  IF(NOT DEFINED PIP_URL)
    MESSAGE(FATAL_ERROR "PIP_INSTALL needs to be given URL.")
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
        --install-option=--install-scripts=${STAGE_DIR}/bin
        --install-option=--install-lib=${STAGE_DIR}/python
        ${PIP_URL}
    )
  ENDIF()


  INSTALL(CODE
    "EXECUTE_PROCESS(
      COMMAND ${CMAKE_COMMAND} -E 
        copy_directory ${STAGE_DIR} ${CMAKE_INSTALL_PREFIX}
    )"
  )

ENDFUNCTION()
