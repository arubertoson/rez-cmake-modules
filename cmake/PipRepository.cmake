#
# function:
# SET_PIP_ARCHIVE
#
# usage:
# SET_PIP_ARCHIVE(NAME VERSION RELATIVE_PATH)
#
# This module contains functionality for managing pip archives, it will download
# new archives if it can't find existing archives for package version.
# Additionally if you want to upgrade a package you can specify -DUPGRADE=True
# when invoking the build command, the function will then check if newer version
# is available, download it and bump the package.py version to the new one.
#
# DEFINES:
#
# REZ_PIP_ARCHIVE   :Path to pip archive
#

# Bump package version to newest after performing an upgrade
FUNCTION(BUMP_PACKAGE_VERSION VERSION)
  file(READ package.py data)
  string(REGEX REPLACE "\n" ";" FILE_LINES "${data}")

  # Iterate over line until we find a match
  foreach(line ${FILE_LINES})
    
    string(REGEX MATCH 
      ".*version[ =]+\'(.*)\'.*" VERSION_MATCH "${line}")
    IF(VERSION_MATCH)
      # It's a bit clunky but we replace the entire line with the matched version
      # to extract the current version and place it in a variable.
      STRING(REGEX REPLACE 
        ".*version[ =]+\'(.*)\'.*" "\\1" CURRENT_VERSION "${VERSION_MATCH}")
      BREAK()
    ENDIF()

  endforeach()

  # Finally we replace the new version with the current one and write to file.
  STRING(REGEX REPLACE "${CURRENT_VERSION}" "${VERSION}" data ${data})
  file(WRITE package.py "${data}")
ENDFUNCTION()


# Get new version number from downloaded pip archive
FUNCTION(GET_NEW_VERSION_FROM_OUTPUT version OUTPUT)
  IF("${OUTPUT}" MATCHES "already downloaded")
    RETURN()
  ENDIF()

  STRING(REGEX REPLACE 
    ".*[-](.*)\.(tar|tgz|tbz2|txz|bz2|7z|zip).*" "\\1" VERSION "${OUTPUT}")
  SET(${version} ${VERSION} PARENT_SCOPE)
ENDFUNCTION()


FUNCTION(SET_PIP_ARCHIVE)

  parse_arguments(PIP "NAME;VERSION;UPGRADE;RELATIVE_PATH" "" ${ARGN})

  IF(NOT DEFINED PIP_NAME OR NOT DEFINED PIP_VERSION)
    MESSAGE(FATAL_ERROR 
      "SET_PIP_ARCHIVE requires that NAME and VERSION are given.")
  ENDIF()


  # We can't determine location of archives without the rez repo variable set
  IF(NOT DEFINED ENV{REZ_REPO_PAYLOAD_DIR})
    MESSAGE(FATAL_ERROR "PIP_REPO_PAYLOAD_DIR environment variable is not set")
  ENDIF()


  # Optional relative path under REZ_REPO_PAYLOAD_DIR to store pip archive
  IF(NOT DEFINED PIP_RELATIVE_PATH)
    SET(PIP_SUBDIR pip)
  ELSE()
    SET(PIP_SUBDIR ${REZ_RELATIVE_PATH})
  ENDIF()


  # Create archive directory, by default we store pip archives under a "pip"
  # subfolder to keep python packages sepparated from others.
  SET(PIP_ARCHIVE "$ENV{REZ_REPO_PAYLOAD_DIR}/${PIP_SUBDIR}/${PIP_NAME}")
  IF(NOT EXISTS PIP_ARCHIVE)
    FILE(MAKE_DIRECTORY "${PIP_ARCHIVE}")
  ENDIF()


  # If UPGRADE definition was given as a build argument we want to upgrade to 
  # the latest version, otherwise we specify package version.
  IF(UPGRADE)
    SET(PIP_COMMAND "${PIP_NAME}")
  ELSE()
    SET(PIP_COMMAND "${PIP_NAME}==${PIP_VERSION}")
  ENDIF()
  # We try to avoid fetching wheels as they come prebuilt and is most of the
  # time not what we want, if we want to use wheels you have to be explicit and
  # download it manually.
  EXECUTE_PROCESS(
    COMMAND 
      pip download 
        --no-deps "${PIP_COMMAND}"
        --no-binary ${PIP_NAME}
        --no-cache-dir
    WORKING_DIRECTORY ${PIP_ARCHIVE}
    OUTPUT_VARIABLE PIP_OUT
  )


  # If new version is returned from the pip command we bump the package version
  # by replacing the old version with the new in package.py
  GET_NEW_VERSION_FROM_OUTPUT(VERSION ${PIP_OUT})
  IF(VERSION AND NOT VERSION VERSION_EQUAL PIP_VERSION)
    SET(PIP_VERSION ${VERSION})
    BUMP_PACKAGE_VERSION(${PIP_VERSION})
  ENDIF()


  # Finally glob for the current archive and return with parent scope variable
  FILE(GLOB PACKAGE_ARCHIVE "${PIP_ARCHIVE}/${PIP_NAME}*${PIP_VERSION}*")
  IF(PACKAGE_ARCHIVE) 
    SET(REZ_PIP_ARCHIVE ${PACKAGE_ARCHIVE} PARENT_SCOPE)
  ELSE()
    MESSAGE(FATAL_ERROR "Couldn't perform pip download, consider manually downloading and using rez_set_archive instead.")
  ENDIF()

ENDFUNCTION()

