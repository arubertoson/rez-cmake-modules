#
#
#
#


IF(NOT REZ_BUILD_ENV)
  MESSAGE(FATAL_ERROR "RezPipInstall requires that RezBuild has been included")
ENDIF()


IF(NOT DEFINED ENV{REZ_REPO_PAYLOAD_DIR})
  MESSAGE(FATAL_ERROR "REZ_REPO_PAYLOAD_DIR environment variable is not set")
ENDIF()


FUNCTION(_GET_PLATFORM variable)
  IF($ENV{REZ_USED_REQUEST} MATCHES "platform-windows")
    SET(platform win32)
  ELSEIF($ENV{REZ_USED_REQUEST} MATCHES "platform-linux")
    SET(platform linux)
  ENDIF()
  SET(${variable} ${platform} PARENT_SCOPE)
ENDFUNCTION()


FUNCTION(_GET_ARCHIVE_DIR variable)
  IF(NOT DEFINED REZ_RELATIVE_PATH)
    SET(REZ_RELATIVE_PATH "external")
  ENDIF()

  SET(ARCHIVE_DIR 
    "$ENV{REZ_REPO_PAYLOAD_DIR}/${REZ_RELATIVE_PATH}/${REZ_NAME}")
  IF(NOT EXISTS ${ARCHIVE_DIR})
    FILE(MAKE_DIRECTORY ${ARCHIVE_DIR})
  ENDIF()
  SET(${variable} ${ARCHIVE_DIR} PARENT_SCOPE)
ENDFUNCTION()


FUNCTION(ARCHIVE_RESOLVE)
  PARSE_ARGUMENTS(REZ "RELATIVE_PATH;URL" "" ${ARGN})

  SET(REZ_NAME ${PROJECT_NAME})
  SET(REZ_VERSION $ENV{REZ_BUILD_PROJECT_VERSION})

  # Get archive directory
  _GET_ARCHIVE_DIR(REZ_ARCHIVE_DIR)

  # Query Platform and look for matching archive
  _GET_PLATFORM(PLATFORM)

  # Put priority to finding platform specific archive, then just a source
  # archive, if neither is available raise error.
  FILE(GLOB PACKAGE_ARCHIVE 
    "${REZ_ARCHIVE_DIR}/${REZ_NAME}*${REZ_VERSION}*${PLATFORM}*")
  IF(NOT PACKAGE_ARCHIVE)
    FILE(GLOB PACKAGE_ARCHIVE 
      "${REZ_ARCHIVE_DIR}/${REZ_NAME}*${REZ_VERSION}*")
    IF(NOT PACKAGE_ARCHIVE)
      SET(FATAL_MESSAGE 
        "${REZ_NAME} archive could not be found in: ${REZ_ARCHIVE_DIR}"
        "If not locally accessible download from ${REZ_URL}"
      )
      STRING(REPLACE ";" ${FATAL_MESSAGE})
      MESSAGE(FATAL_ERROR ${FATAL_MESSAGE})
    ELSE()
      SET(REZ_PACKAGE_ARCHIVE ${PACKAGE_ARCHIVE} PARENT_SCOPE)
    ENDIF()
  ENDIF()
ENDFUNCTION()

