# dgcalc.accel.2.cmake Created by Lucius Schoenbaum February 3, 2023




# accel config
if(ACCEL STREQUAL "Cuda")
    set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
    set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_ARCHITECTURES ${PROJECT_CUDA_ARCHITECTURES})
elseif(ACCEL STREQUAL "Metal")
    # Metal
endif()



# OpenMP

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(MACOSX TRUE)

endif()
if ($CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(LINUX TRUE)
endif()



if(FALSE)
FIND_PACKAGE( OpenMP REQUIRED)
if(OPENMP_FOUND)
    message("OpenMP found.")
endif()
if (OPENMP_FOUND AND CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    #### Mac/Clang - this works on my local machine.
    # lib omp path
    set(LIBOMP_PATH $ENV{LIBOMP_PATH})
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    target_include_directories(${PROJECT_NAME} PRIVATE "${LIBOMP_PATH}/include")
    target_link_libraries(${PROJECT_NAME} PRIVATE "${LIBOMP_PATH}/lib/libomp.a")
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()
if (OPENMP_FOUND AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
    #### Linux/GCC
    # https://gcc.gnu.org/onlinedocs/libgomp/Enabling-OpenMP.html#Enabling-OpenMP
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()
endif()



if(NUMA_INCLUDE_DIR AND NUMA_LIBRARY)
    target_compile_definitions(${PROJECT_NAME} PRIVATE HAS_NUMA=1)
    target_include_directories(${PROJECT_NAME} PRIVATE ${NUMA_INCLUDE_DIR})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${NUMA_LIBRARY})
    message(STATUS "NUMA support enabled.")
else()
    message(STATUS "NUMA support not enabled.")
endif()



