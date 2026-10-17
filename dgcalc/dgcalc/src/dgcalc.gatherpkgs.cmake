# dgcalc.gatherpkgs.cmake Created by Lucius Schoenbaum February 3, 2023
# revised April 2025, August 2026




function(dependency_src NAME_LATEST HOME)
    # This is redundant code to set up the project
    # and grab the latest versions of the dependencies.
    split_name_latest("${NAME_LATEST}" NAME LATEST)
    set(PROJECT_DIR "${HOME}/${NAME}")
    set(INC_DIR "${PROJECT_DIR}/wrk/${LATEST}/pkg/inc")
    set(INC_DIRS ${INC_DIRS} ${INC_DIR} PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I${INC_DIR}")
    set(SRC_DIR "${PROJECT_DIR}/wrk/${LATEST}/pkg/src")
    set(SRC_DIRS ${SRC_DIRS} ${SRC_DIR} PARENT_SCOPE)
endfunction()

function(dependency_lib NAME_LATEST HOME)
    split_name_latest("${NAME_LATEST}" NAME LATEST)
    set(PROJECT_DIR "${HOME}/${NAME}")
    if (IS_DIRECTORY "${PROJECT_DIR}/wrk/${LATEST}")
        set(INC_DIR "${PROJECT_DIR}/wrk/${LATEST}/pkg/inc")
        set(INC_DIRS ${INC_DIRS} ${INC_DIR} PARENT_SCOPE)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I${INC_DIR}")
        if (DEPENDENCY_LIB_TYPE STREQUAL "s")
            # Pull the version directly from the CMakeLists.txt.
            get_version_from_lists("${PROJECT_DIR}/wrk/${LATEST}/CMakeLists.txt" VERSION_STRING)
            split_version(${VERSION_STRING} LATEST_MAJOR LATEST_MINOR LATEST_PATCH)
            if(LATEST_PATCH STREQUAL "")
                set(SHARED_VERSION ${LATEST_MAJOR}.${LATEST_MINOR})
            else()
                set(SHARED_VERSION ${LATEST_MAJOR}.${LATEST_MINOR}.${LATEST_PATCH})
            endif()
            set(LIBRARY_FILE ${CMAKE_SHARED_LIBRARY_PREFIX}${NAME}.${SHARED_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX})
            set(LIBRARY_PATH_JUMP "lib")
        elseif(DEPENDENCY_LIB_TYPE STREQUAL "a")
            set(LIBRARY_FILE ${CMAKE_STATIC_LIBRARY_PREFIX}${NAME}${LATEST}${CMAKE_STATIC_LIBRARY_SUFFIX})
            set(LIBRARY_PATH_JUMP "static")
        else()
            message(FATAL_ERROR "Invalid library type.")
        endif()
        message("Library file: ${LIBRARY_FILE}")
        set(LIB "${PROJECT_DIR}/share/${LIBRARY_PATH_JUMP}/${LIBRARY_FILE}")
        if(EXISTS ${LIB})
            message("Library ${NAME} found.")
            set(LIBRARIES ${LIBRARIES} ${LIB} PARENT_SCOPE)
        else()
            # if the latest version library does not exist, revert to source.
            message("Library ${NAME} not found, using source.")
            set(DEP_SRC ${DEP_SRC} ${NAME} PARENT_SCOPE)
        endif()
    else()
        message(FATAL_ERROR "Requested work tree ${LATEST} was not found in directory ${PROJECT_DIR}/wrk.")
    endif()
endfunction()


