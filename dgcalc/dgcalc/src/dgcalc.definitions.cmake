# dgcalc.definitions.cmake Created by Lucius Schoenbaum February 3, 2023
# revised April 2025, August 2026, October 2026


message("CMake dgcalc project")

if (DEFINED PROJECT_BUILD_TYPE AND NOT "${PROJECT_BUILD_TYPE}" STREQUAL "")
    message("Project build type: ${PROJECT_BUILD_TYPE}")
    set(CMAKE_BUILD_TYPE ${PROJECT_BUILD_TYPE} CACHE STRING "Build type")
else()
    message("No project build type specified: using defualt (Debug).")
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type")
endif()
set(CMAKE_CXX_FLAGS_RELEASE "-Ofast -DNDEBUG" CACHE STRING "Release build flags" FORCE)
set(CMAKE_C_FLAGS_RELEASE "-Ofast -DNDEBUG" CACHE STRING "Release build flags" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g" CACHE STRING "Debug build flags" FORCE)
set(CMAKE_C_FLAGS_DEBUG "-O0 -g" CACHE STRING "Debug build flags" FORCE)


# diagnostic string
function(dump_cmake_variables)
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        if (ARGV0)
            unset(MATCHED)
            string(REGEX MATCH ${ARGV0} MATCHED ${_variableName})
            if (NOT MATCHED)
                continue()
            endif()
        endif()
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endfunction()

# string in list helper
function(is_in_list varstring varlist out)
    if("${varstring}" IN_LIST ${varlist})
        set(${out} TRUE PARENT_SCOPE)
    else()
        set(${out} FALSE PARENT_SCOPE)
    endif()
endfunction()

# list is empty helper
function(is_empty varlist out)
    # check if variable -is not defined- OR if -its expanded value is empty-
    if(NOT DEFINED ${varlist} OR "${${mylist}}" STREQUAL "")
        set(${out} TRUE PARENT_SCOPE)
    else()
        # ensure it's not just a string containing empty elements/whitespace
        string(STRIP "${${varlist}}" stripped_list)
        if("${stripped_list}" STREQUAL "")
            set(${out} TRUE PARENT_SCOPE)
        else()
            set(${out} FALSE PARENT_SCOPE)
        endif()
    endif()
endfunction()

# ending in list helper
function(any_ends_with varendings varlist out)
    set(${out} FALSE PARENT_SCOPE)
    foreach(file IN LISTS ${varlist})
        foreach(ending IN LISTS ${varendings})
            # Check if the file string ends with the current ending
            if(file MATCHES "${ending}$")
                set(${out} TRUE PARENT_SCOPE)
                return()
            endif()
        endforeach()
    endforeach()
endfunction()

# helper to `/..` a path string, i.e., strip away the top stem.
# Should work for windows (few things here would).
function(strip_top_stem path_var result_var)
    # Normalize slashes and remove double slashes
    cmake_path(NORMAL_PATH ${path_var} NORMALIZE OUTPUT_VARIABLE clean_path)
    # Remove leading slashes if present (e.g., "/a/b/c" -> "a/b/c")
    string(REGEX REPLACE "^/+" "" clean_path "${clean_path}")
    # Find the first slash
    string(FIND "${clean_path}" "/" slash_index)
    if(slash_index EQUAL -1)
        # No subdirectory exists (e.g., "foo" or "foo.txt"), return empty
        set(${result_var} "" PARENT_SCOPE)
    else()
        # Extract everything after the first slash
        math(EXPR start_index "${slash_index} + 1")
        string(SUBSTRING "${clean_path}" ${start_index} -1 relative_tail)
        set(${result_var} "${relative_tail}" PARENT_SCOPE)
    endif()
endfunction()

# helper to parse a version string in either ddd format or <major>.<minor>.<patch> format.
function(split_version str major_out minor_out patch_out)
    string(FIND "${str}" "." idx1)
    if(idx1 EQUAL -1)
        # No subdivisions found: assume ddd format
        string(SUBSTRING ${str} 0 1 major)
        string(SUBSTRING ${str} 1 1 minor)
        string(SUBSTRING ${str} 2 1 patch)
        set(${major_out} "${major}" PARENT_SCOPE)
        set(${minor_out} "${minor}" PARENT_SCOPE)
        set(${patch_out} "${patch}" PARENT_SCOPE)
        return()
    endif()
    # split major
    string(SUBSTRING "${str}" 0 ${idx1} major)
    math(EXPR idx1plus1 "${idx1} + 1")
    string(SUBSTRING "${str}" ${idx1plus1} -1 remainder1)
    string(FIND "${remainder1}" "." idx2)
    if(idx2 EQUAL -1)
        # Only two subdivisions found: assume <major>.<minor>
        set(${major_out} "${major}" PARENT_SCOPE)
        set(${minor_out} "${remainder1}" PARENT_SCOPE)
        set(${patch_out} "" PARENT_SCOPE)
        return()
    endif()
    string(SUBSTRING "${remainder1}" 0 ${idx2} minor)
    math(EXPR idx2plus1 "${idx2} + 1")
    string(SUBSTRING "${remainder1}" ${idx2plus1} -1 patch)
    set(${major_out} "${major}" PARENT_SCOPE)
    set(${minor_out} "${minor}" PARENT_SCOPE)
    set(${patch_out} "${patch}" PARENT_SCOPE)
endfunction()

# helper to get the version directly from the CMakeLists.txt.
function(get_version_from_lists file_path version_out)
    # Check if the file exists first
    if(NOT EXISTS "${file_path}")
        message(WARNING "File not found: ${file_path}")
        set(${version_out} "" PARENT_SCOPE)
        return()
    endif()
    file(READ "${file_path}" contents)
    # Use regex match with a capture group () to pull out the contents inside the quotes
    # \s+ matches any whitespace (spaces/tabs/newlines) between the word and the quote
    if(contents MATCHES "PROJECT_VERSION[ \t]*\"([^\"]*)\"")
        # ${CMAKE_MATCH_1} holds the content captured by the first set of parentheses
        set(${version_out} "${CMAKE_MATCH_1}" PARENT_SCOPE)
    else()
        # Pattern wasn't found in the file
        set(${version_out} "" PARENT_SCOPE)
    endif()
endfunction()

# split name_latest helper: split a string like
# "X:worktree" into X and worktree.
# If the variable `str` is a variable `var`, you must 
# call with `split_name_latest("${var}" out1 out2)`
# in quotes (!!!) because the colon ":" is used internally
# by CMake to pass lists into and out of functions.
function(split_name_latest str out1 out2)
    string(FIND "${str}" ":" idx)
    if(idx EQUAL -1)
        # No work tree specified. Use the default work tree "latest".
        set(${out1} "${str}" PARENT_SCOPE)
        set(${out2} "latest" PARENT_SCOPE)
    else()
        # split
        string(SUBSTRING "${str}" 0 ${idx} out1_)
        math(EXPR idx2 "${idx} + 1")
        string(SUBSTRING "${str}" ${idx2} -1 out2_)
        set(${out1} "${out1_}" PARENT_SCOPE)
        set(${out2} "${out2_}" PARENT_SCOPE)
    endif()
endfunction()



function(link_dependency DEPNAME)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(${DEPNAME} STREQUAL "mpi")
            message("handling MPI...")
            pkg_check_modules(OMPI REQUIRED IMPORTED_TARGET ompi)
            target_include_directories(${PROJECT_NAME} PRIVATE ${OMPI_INCLUDE_DIRS})
            target_link_libraries(${PROJECT_NAME} PRIVATE PkgConfig::OMPI)
            #        elseif(${DEPNAME} STREQUAL "siloh5")
            #            message("handling siloh5...")
        elseif(${DEPNAME} STREQUAL "eigen")
            message("handling Eigen...")
            find_package(Eigen3)
            if(EIGEN3_FOUND)
                target_link_libraries(your_target PRIVATE Eigen3::Eigen)
            else()
                message("Warning: Eigen not found")
            endif()
            message("handling Eigen9...")
            find_package(Eigen9)
            if(EIGEN9_FOUND)
                target_link_libraries(your_target PRIVATE Eigen3::Eigen)
            else()
                message("Warning: Eigen9 not found")
            endif()
        else()
            message("handling ${DEPNAME}...")
            pkg_check_modules(${DEPNAME} REQUIRED IMPORTED_TARGET ${DEPNAME})
            target_include_directories(${PROJECT_NAME} PRIVATE ${${DEPNAME}_INCLUDE_DIRS})
            target_link_libraries(${PROJECT_NAME} PRIVATE PkgConfig::${DEPNAME})
        endif()
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        if(${DEPNAME} STREQUAL "mpi")
            execute_process(COMMAND pkg-config --variable=prefix ompi OUTPUT_VARIABLE DEPHOME OUTPUT_STRIP_TRAILING_WHITESPACE)
            message("handling MPI (exceptional case)...")
            target_include_directories(${PROJECT_NAME} SYSTEM PRIVATE "${DEPHOME}/include")
            target_link_libraries(${PROJECT_NAME} PRIVATE "${DEPHOME}/lib/libmpi.dylib")
        elseif(${DEPNAME} STREQUAL "siloh5")
            message("handling Siloh5 (exceptional case)...")
            execute_process(COMMAND pkg-config --variable=prefix siloh5 OUTPUT_VARIABLE DEPHOME OUTPUT_STRIP_TRAILING_WHITESPACE)
            target_include_directories(${PROJECT_NAME} PRIVATE "${DEPHOME}/include/silo/include")
            target_link_libraries(${PROJECT_NAME} PRIVATE "${DEPHOME}/lib/libsiloh5.dylib")
            target_link_directories(${PROJECT_NAME} PUBLIC "${DEPHOME}")
        elseif(${DEPNAME} STREQUAL "eigen")
            message("handling Eigen (exceptional case)...")
            execute_process(COMMAND pkg-config --variable=prefix eigen OUTPUT_VARIABLE DEPHOME OUTPUT_STRIP_TRAILING_WHITESPACE)
            target_include_directories(${PROJECT_NAME} PRIVATE "${DEPHOME}/include")
        else()
            message("handling ${DEPNAME} (normal case)...")
            execute_process(COMMAND pkg-config --variable=prefix ${DEPNAME} OUTPUT_VARIABLE DEPHOME OUTPUT_STRIP_TRAILING_WHITESPACE)
            target_include_directories(${PROJECT_NAME} PRIVATE "${DEPHOME}/include")
            target_link_libraries(${PROJECT_NAME} PRIVATE "${DEPHOME}/lib/lib${DEPNAME}.dylib")
        endif()
        message("dependency ${DEPNAME}: home ${DEPHOME}")
    else()
        message("Cannot link ${DEPNAME}: unrecognized system name ${CMAKE_SYSTEM_NAME}")
    endif()
endfunction()


