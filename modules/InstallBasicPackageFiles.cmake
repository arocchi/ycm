#.rst:
# InstallBasicPackageFiles
# ------------------------
#
# Create and install a basic version of cmake files for your project::
#
#  install_basic_package_files(<name>
#                              VERSION <version>
#                              COMPATIBILITY <compatibility>
#                              TARGETS_PROPERTY <property_name>
#                              [NO_SET_AND_CHECK_MACRO]
#                              [NO_CHECK_REQUIRED_COMPONENTS_MACRO]
#                              [VARS_PREFIX <prefix>] # (default = "<name>")
#                              [DESTINATION <destination>]
#                              [NAMESPACE <namespace>] # (default = "<name>::")
#                              [EXTRA_PATH_VARS_SUFFIX path1 [path2 ...]]
#                             )
#
# This function generates 3 files:
#
#  - `<Name>ConfigVersion.cmake`
#  - `<Name>Config.cmake`
#  - `<Name>Targets.cmake`
#
# Each file is generated twice, one for the build directory and one for
# the installation directory.  The `DESTINATION` argument can be passed
# to install the files in a location different from the default one
# (`CMake` on Windows, `${CMAKE_INSTALL_LIBDIR}/cmake/${name}` on other
# platforms.
#
#
# The `<Name>ConfigVersion.cmake` is generated using
# `write_basic_package_version_file`.  The `VERSION`, `COMPATIBILITY`,
# `NO_SET_AND_CHECK_MACRO`, and `NO_CHECK_REQUIRED_COMPONENTS_MACRO` are
# passed to this function.  See the documentation for the
# `CMakePackageConfigHelpers` module for further information.
# The files in the build and install directory are exactly the same.
#
#
# The `<Name>Config.cmake` is generated using
# `configure_package_config_file`.  See the documentation for the
# `CMakePackageConfigHelpers` module for further information.
#  The module expects to find a `<Name>Config.cmake.in` file in the root
# directory of the project.
# If the file does not exist, a very basic file is created.
#
# A set of variables are checked and passed to
# `configure_package_config_file` as `PATH_VARS`.  Default
# PATH_VARS_SUFFIX are::
#
#   BINDIR          BIN_DIR
#   SBINDIR         SBIN_DIR
#   LIBEXECDIR      LIBEXEC_DIR
#   SYSCONFDIR      SYSCONF_DIR
#   SHAREDSTATEDIR  SHAREDSTATE_DIR
#   LOCALSTATEDIR   LOCALSTATE_DIR
#   LIBDIR          LIB_DIR
#   INCLUDEDIR      INCLUDE_DIR
#   OLDINCLUDEDIR   OLDINCLUDE_DIR
#   DATAROOTDIR     DATAROOT_DIR
#   DATADIR         DATA_DIR
#   INFODIR         INFO_DIR
#   LOCALEDIR       LOCALE_DIR
#   MANDIR          MAN_DIR
#   DOCDIR          DOC_DIR
#
# more suffixes can be added using the EXTRA_PATH_VARS_SUFFIX argument.
#
# For each PATH_VARS_SUFFIX, if one of the variables
#
#     <VARS_PREFIX>_(BUILD|INSTALL)_<SUFFIX>
#     (BUILD|INSTALL)_<VARS_PREFIX>_<SUFFIX>
#
# is defined, the <VARS_PREFIX>_<SUFFIX> variable will be defined before
# configuring the package.  In order to use that variable in the config
# file, a line ou can access to that variable in the config
# file by using::
#
#   set_and_check(<VARS_PREFIX>_<SUFFIX> \"@PACKAGE_<VARS_PREFIX>_<SUFFIX>@\")
#
# These variable will have different values whether you are using the
# package from the build tree or from the install directory.  Also these
# files will contain only relative paths, meaning that you can move the
# whole installation and the CMake files will still work.
#
#
# The `<name>Targets*.cmake` is generated using `export(TARGETS)` in the
# build tree and install(EXPORT) in the installation directory.
# The targets are exported using the value for the `NAMESPACE` argument
# as namespace.
# The targets should be listed in a global property, that must be passed
# to the function using the `TARGETS_PROPERTY` argument

#=============================================================================
# Copyright 2013  iCub Facility, Istituto Italiano di Tecnologia
#     @author Daniele E. Domenichelli <daniele.domenichelli@iit.it>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)


if(COMMAND install_basic_package_files)
    return()
endif()


include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(CMakeParseArguments)


function(INSTALL_BASIC_PACKAGE_FILES name)

    set(_options NO_SET_AND_CHECK_MACRO
                 NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    set(_oneValueArgs VERSION
                      COMPATIBILITY
                      TARGETS_PROPERTY
                      VARS_PREFIX
                      DESTINATION
                      NAMESPACE)
    set(_multiValueArgs EXTRA_PATH_VARS_SUFFIX)
    cmake_parse_arguments(_IBPF "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" "${ARGN}")

    if(NOT DEFINED _IBPF_VARS_PREFIX)
        set(_IBPF_VARS_PREFIX ${name})
    endif()

    if(NOT DEFINED _IBPF_VERSION)
        message(FATAL_ERROR "VERSION argument is required")
    endif()

    if(NOT DEFINED _IBPF_COMPATIBILITY)
        message(FATAL_ERROR "COMPATIBILITY argument is required")
    endif()

    if(NOT DEFINED _IBPF_TARGETS_PROPERTY)
        message(FATAL_ERROR "TARGETS_PROPERTY argument is required")
    endif()

    # Path for installed cmake files
    if(NOT DEFINED _IBPF_DESTINATION)
        if(WIN32 AND NOT CYGWIN)
            set(_IBPF_DESTINATION CMake)
        else()
            set(_IBPF_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${name})
        endif()
    endif()

    if(NOT DEFINED _IBPF_NAMESPACE)
        set(_IBPF_NAMESPACE "${name}::")
    endif()

    if(_IBPF_NO_SET_AND_CHECK_MACRO)
        list(APPEND configure_package_config_file_extra_args NO_SET_AND_CHECK_MACRO)
    endif()

    if(_IBPF_NO_CHECK_REQUIRED_COMPONENTS_MACRO)
        list(APPEND configure_package_config_file_extra_args NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    endif()


    # Make relative paths absolute (needed later on) and append the
    # defined variables to _(build|install)_path_vars_suffix
    foreach(p BINDIR          BIN_DIR
              SBINDIR         SBIN_DIR
              LIBEXECDIR      LIBEXEC_DIR
              SYSCONFDIR      SYSCONF_DIR
              SHAREDSTATEDIR  SHAREDSTATE_DIR
              LOCALSTATEDIR   LOCALSTATE_DIR
              LIBDIR          LIB_DIR
              INCLUDEDIR      INCLUDE_DIR
              OLDINCLUDEDIR   OLDINCLUDE_DIR
              DATAROOTDIR     DATAROOT_DIR
              DATADIR         DATA_DIR
              INFODIR         INFO_DIR
              LOCALEDIR       LOCALE_DIR
              MANDIR          MAN_DIR
              DOCDIR          DOC_DIR
              ${_IBPF_EXTRA_PATH_VARS_SUFFIX})
        set(var ${_IBPF_VARS_PREFIX}_BUILD_${p})
        if(DEFINED ${var})
            if(NOT IS_ABSOLUTE "${${var}}")
                get_filename_component(${var} "${CMAKE_BINARY_DIR}/${${var}}" ABSOLUTE)
            endif()
            list(APPEND _build_path_vars_suffix ${p})
            list(APPEND _build_path_vars "${_IBPF_VARS_PREFIX}_${p}")
        endif()
        set(var BUILD_${_IBPF_VARS_PREFIX}_${p})
        if(DEFINED ${var})
            if(NOT IS_ABSOLUTE "${${var}}")
                get_filename_component(${var} "${CMAKE_BINARY_DIR}/${${var}}" ABSOLUTE)
            endif()
            list(APPEND _build_path_vars_suffix ${p})
            list(APPEND _build_path_vars "${_IBPF_VARS_PREFIX}_${p}")
        endif()
        set(var ${_IBPF_VARS_PREFIX}_INSTALL_${p})
        if(DEFINED ${var})
            if(NOT IS_ABSOLUTE "${${var}}")
                get_filename_component(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}" ABSOLUTE)
            endif()
            list(APPEND _install_path_vars_suffix ${p})
            list(APPEND _install_path_vars "${_IBPF_VARS_PREFIX}_${p}")
        endif()
        set(var _INSTALL${_IBPF_VARS_PREFIX}_${p})
        if(DEFINED ${var})
            if(NOT IS_ABSOLUTE "${${var}}")
                get_filename_component(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}" ABSOLUTE)
            endif()
            list(APPEND _install_path_vars_suffix ${p})
            list(APPEND _install_path_vars "${_IBPF_VARS_PREFIX}_${p}")
        endif()
    endforeach()



    # Get targets from GLOBAL PROPERTY
    get_property(_targets GLOBAL PROPERTY ${_IBPF_TARGETS_PROPERTY})
    foreach(_target ${_targets})
        list(APPEND ${_IBPF_VARS_PREFIX}_TARGETS ${name}::${_target})
    endforeach()
    list(GET ${_IBPF_VARS_PREFIX}_TARGETS 0 _target)



    # <name>ConfigVersion.cmake file (same for build tree and intall)
    write_basic_package_version_file(${CMAKE_BINARY_DIR}/${name}ConfigVersion.cmake
                                    VERSION ${_IBPF_VERSION}
                                    COMPATIBILITY ${_IBPF_COMPATIBILITY})
    install(FILES ${CMAKE_BINARY_DIR}/${name}ConfigVersion.cmake
            DESTINATION ${_IBPF_DESTINATION})



    # If there is no Config.cmake.in file, write a basic one
    set(_config_cmake_in ${CMAKE_SOURCE_DIR}/${name}Config.cmake.in)
    if(NOT EXISTS ${_config_cmake_in})
        set(_config_cmake_in ${CMAKE_BINARY_DIR}/${name}Config.cmake.in)
        file(WRITE ${_config_cmake_in}
"set(${_IBPF_VARS_PREFIX}_VERSION \@${_IBPF_VARS_PREFIX}_VERSION\@)

@PACKAGE_INIT@

set_and_check(${_IBPF_VARS_PREFIX}_INCLUDEDIR \"@PACKAGE_${_IBPF_VARS_PREFIX}_INCLUDEDIR@\")

if(NOT TARGET ${_target})
  include(\"\${CMAKE_CURRENT_LIST_DIR}/${name}Targets.cmake\")
endif()

# Compatibility
set(${name}_LIBRARIES ${${_IBPF_VARS_PREFIX}_TARGETS})
set(${name}_INCLUDE_DIRS \${${_IBPF_VARS_PREFIX}_INCLUDEDIR})
")
    endif()

    # <name>Config.cmake (build tree)
    foreach(p ${_build_path_vars_suffix})
        if(DEFINED ${_IBPF_VARS_PREFIX}_BUILD_${p})
            set(${_IBPF_VARS_PREFIX}_${p} "${${_IBPF_VARS_PREFIX}_BUILD_${p}}")
        elseif(DEFINED BUILD_${_IBPF_VARS_PREFIX}_${p})
            set(${_IBPF_VARS_PREFIX}_${p} "${BUILD_${_IBPF_VARS_PREFIX}_${p}}")
        endif()
    endforeach()
    configure_package_config_file(${_config_cmake_in}
                                  ${CMAKE_BINARY_DIR}/${name}Config.cmake
                                  INSTALL_DESTINATION ${CMAKE_BINARY_DIR}
                                  PATH_VARS ${_build_path_vars}
                                  ${configure_package_config_file_extra_args})

    # <name>Config.cmake (installed)
    foreach(p ${_install_path_vars_suffix})
        set(${_IBPF_VARS_PREFIX}_${p} "${${_IBPF_VARS_PREFIX}_INSTALL_${p}}")
    endforeach()
    configure_package_config_file(${_config_cmake_in}
                                  ${CMAKE_BINARY_DIR}/${name}Config.cmake.install
                                  INSTALL_DESTINATION ${_IBPF_DESTINATION}
                                  PATH_VARS ${_install_path_vars}
                                  ${configure_package_config_file_extra_args})
    install(FILES ${CMAKE_BINARY_DIR}/${name}Config.cmake.install
            DESTINATION ${_IBPF_DESTINATION}
            RENAME ${name}Config.cmake)



    # <name>Targets.cmake (build tree)
    export(TARGETS ${_targets}
           NAMESPACE ${_IBPF_NAMESPACE}
           FILE ${CMAKE_BINARY_DIR}/${name}Targets.cmake)

    # <name>Targets.cmake (installed)
    install(EXPORT ${name}
            NAMESPACE ${_IBPF_NAMESPACE}
            DESTINATION ${_IBPF_DESTINATION}
            FILE ${name}Targets.cmake)

endfunction()
