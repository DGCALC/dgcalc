# dgcalc.gatherlocal.cmake Created by Lucius Schoenbaum February 3, 2023
# revised April 2025, September 2026

# this allows for some customization for manual workflows.
if (CUSTOM_FILELIST)
	set(PKG_SRC_FILES ${CUSTOM_FILELIST})
	set(PKG_INC_FILES "")
else()
    file(GLOB_RECURSE PKG_SRC_FILES
        pkg/src/*.h pkg/src/*.hh pkg/src/*.hpp pkg/src/*.cuh
        pkg/src/*.c pkg/src/*.cc pkg/src/*.cpp pkg/src/*.cu
    )
    file(GLOB_RECURSE PKG_INC_FILES
        pkg/inc/*.h pkg/inc/*.hh pkg/inc/*.hpp pkg/inc/*.cuh
    )
endif()
## static target
if (PKG_SRC_FILES)
    set(STATIC_TARGET_NAME ${PROJECT_FAMILY_NAME}${PROJECT_VERSION})
    set(STATIC_TARGET_DIR ${PROJECT_SOURCE_DIR}/../../share/static)
    add_library(${STATIC_TARGET_NAME} STATIC ${PKG_SRC_FILES})
    set_target_properties(${STATIC_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${STATIC_TARGET_DIR})
    message("Created target: ${STATIC_TARGET_NAME}")
endif()
# set_target_properties(${STATIC_TARGET_NAME} PROPERTIES LINKER_LANGUAGE ${PROJECT_LANGUAGES})
## shared target
if (PKG_SRC_FILES)
    set(SHARED_TARGET_NAME ${PROJECT_FAMILY_NAME})
    # Supported version syntax is ddd (digit, digit, digit, older syntax)
    # and <major>.<minor>.<patch> (new syntax, allows greater flexibility).
    split_version(${PROJECT_VERSION} PROJECT_VERSION_MAJOR PROJECT_VERSION_MINOR PROJECT_VERSION_PATCH)
    if (${PROJECT_VERSION_PATCH} STREQUAL "")
        set(SHARED_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})
    else()
        set(SHARED_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
    endif()
    set(SHARED_TARGET_DIR ${PROJECT_SOURCE_DIR}/../../share/lib)
    add_library(${SHARED_TARGET_NAME} SHARED ${PKG_SRC_FILES})
    set_target_properties(${SHARED_TARGET_NAME} PROPERTIES VERSION ${SHARED_VERSION})
    set_target_properties(${SHARED_TARGET_NAME} PROPERTIES SOVERSION ${PROJECT_VERSION_MAJOR})
    # > this may be necessary in some cases
    # set_target_properties(${SHARED_TARGET_NAME} PROPERTIES PUBLIC_HEADER ${PKG_INC_FILES})
    set_target_properties(${SHARED_TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${SHARED_TARGET_DIR})
    # set_target_properties(${SHARED_TARGET_NAME} PROPERTIES LINKER_LANGUAGE ${PROJECT_LANGUAGES})
    message("Created target: ${SHARED_TARGET_NAME}")
endif()
## sources+library dependencies
# Add groups manually by setting GROUPS. 
# The following groups are always checked.
# Other groups must be specified explicitly in the user-facing CMake file.
# DGCALC
set(GROUPS ${GROUPS} DGCALC)
foreach(GROUP IN LISTS GROUPS)
    # Set LOCAL_ROOT in user Cmake files to work in some chosen
    # location without modifying the environment. Should be a last resort,
    # other ways are more convenient.
    if (DEFINED LOCAL_ROOT)
        set(HOME "${LOCAL_ROOT}/${GROUP}")
    elseif (DEFINED ENV{${GROUP}_HOME} AND NOT "$ENV{${GROUP}_HOME}" STREQUAL "")
        # Individual overrides (older, deprecated path resolution method)
		message("Using environment ${GROUP}_HOME variable, namely: $ENV{${GROUP}_HOME}")
	    set(HOME $ENV{${GROUP}_HOME})
    else()
        if (DEFINED ENV{${DGCALC_HOME} AND NOT "$ENV{DGCALC_HOME}" STREQUAL "")
            # Assume that DGCALC sits alongside all the other groups.
            strip_top_stem($ENV{${GROUP}_HOME} ROOT_TMP)
            set(HOME "${ROOT_TMP}/${GROUP}")
        else()
            # Assume the location is the home directory.
            set(HOME "$ENV{HOME}/${GROUP}")
        endif()
    endif()
    # todo deprecated, ensure cleared and delete
#    foreach(DEP IN LISTS ${GROUP}_DEPENDENCY_LIB_STABLE)
#        dependency_lib_stable(${DEP} ${HOME})
#    endforeach()
    foreach(DEP IN LISTS ${GROUP}_DEPENDENCY_LIB)
        dependency_lib(${DEP} ${HOME})
    endforeach()
    foreach(DEP IN LISTS ${GROUP}_DEPENDENCY_SRC)
        dependency_src(${DEP} ${HOME})
    endforeach()
endforeach()
set(PROJECT_FILES ${PROJECT_FILES}
        ${PKG_SRC_FILES}
        ${PKG_INC_FILES}
)
# other files in the project
foreach(RDIR IN LISTS PROJECT_WORKING_RDIRS)
    file(GLOB_RECURSE FILES
            ${RDIR}/*.h ${RDIR}/*.hh ${RDIR}/*.hpp ${RDIR}/*.cuh
            ${RDIR}/*.c ${RDIR}/*.cc ${RDIR}/*.cpp ${RDIR}/*.cu
            )
    set(PROJECT_FILES ${PROJECT_FILES} ${FILES})
endforeach()
# files in the source directories
foreach(SRC_DIR IN LISTS SRC_DIRS)
    file(GLOB_RECURSE FILES
            ${SRC_DIR}/*.h ${SRC_DIR}/*.hh ${SRC_DIR}/*.hpp ${SRC_DIR}/*.cuh
            ${SRC_DIR}/*.c ${SRC_DIR}/*.cc ${SRC_DIR}/*.cpp ${SRC_DIR}/*.cu
    )
    set(PROJECT_FILES ${PROJECT_FILES} ${FILES})
endforeach()
if(NOT DEFINED CUSTOM_FILELIST OR "${CUSTOM_FILELIST}" STREQUAL "")
set(MAIN_SOURCE "main")
if("C" IN_LIST PROJECT_LANGUAGES)
	message("Using main.c")
    string(APPEND MAIN_SOURCE ".c")
elseif("CXX" IN_LIST PROJECT_LANGUAGES)
	message("Using main.cpp")
    string(APPEND MAIN_SOURCE ".cpp")
# todo kludgy
elseif("Fortran" IN_LIST PROJECT_LANGUAGES)
	message("Using main.f")
	string(APPEND MAIN_SOURCE ".f")
endif()
endif()
set(PROJECT_FILES ${MAIN_SOURCE} ${PROJECT_FILES})



########
add_executable(${PROJECT_NAME} ${PROJECT_FILES})
########



# include header directories and link libraries
if (PKG_SRC_FILES)
    target_include_directories(${STATIC_TARGET_NAME} PRIVATE "pkg/inc")
    target_include_directories(${SHARED_TARGET_NAME} PRIVATE "pkg/inc")
    # todo there may be a more efficient way (or maybe not).
    # todo INC_DIRS may be polluted, in other words. But maybe not.
    if (INC_DIRS)
        target_include_directories(${STATIC_TARGET_NAME} PRIVATE ${INC_DIRS})
        target_include_directories(${SHARED_TARGET_NAME} PRIVATE ${INC_DIRS})
    endif()
    if (LIBRARIES)
        target_link_libraries(${STATIC_TARGET_NAME} ${LIBRARIES})
        target_link_libraries(${SHARED_TARGET_NAME} ${LIBRARIES})
    endif()
endif()
target_include_directories(${PROJECT_NAME} PRIVATE "pkg/inc")
if (INC_DIRS)
    target_include_directories(${PROJECT_NAME} PRIVATE ${INC_DIRS})
endif()
foreach(RDIR IN LISTS PROJECT_WORKING_RDIRS)
    target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/${RDIR})
endforeach()
if (LIBRARIES)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBRARIES})
endif()



# MacOSX system linkage
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    if ("Fortran" IN_LIST PROJECT_LANGUAGES)
	    #### libfortran
	    message(STATUS "libfortran directory explicitly linked.")
	    target_link_directories(${PROJECT_NAME} PUBLIC "/opt/homebrew/opt/gcc/lib/gcc/current")
    endif()
    if ("CXX" IN_LIST PROJECT_LANGUAGES)
        #### libc++
#        target_link_libraries(${PROJECT_NAME} PRIVATE c++)
    endif()
endif()

