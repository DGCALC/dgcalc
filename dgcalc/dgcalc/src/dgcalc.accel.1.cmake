# dgcalc.accel.1.cmake Created by Lucius Schoenbaum February 3, 2023



# accel config


find_path(NUMA_INCLUDE_DIR NAMES numa.h)
find_library(NUMA_LIBRARY NAMES numa)

if (ACCEL STREQUAL "Cuda")
    message("Accel: Cuda")
    set(PROJECT_LANGUAGES ${PROJECT_LANGUAGES} CUDA)
    # cuda 12.0 or higher 
    # todo adjust for older architectures
    set(PROJECT_CUDA_ARCHITECTURES "120-real")
    add_definitions(-DACCEL_CUDA)
    add_definitions(-DUSE_CUDA)
    set(INC_DIRS ${INC_DIRS} "${ACCEL_INSTALL_DIR}/cuda/include")
    set(LIBRARIES ${LIBRARIES} "${ACCEL_INSTALL_DIR}/cuda/lib64/libcudart.so")
    foreach(DEP IN LISTS ACCEL_DEPENDENCIES)
        if (DEP STREQUAL "cuBLAS")
            set(LIBRARIES ${LIBRARIES} "${ACCEL_INSTALL_DIR}/cuda/lib64/libcublas.so")
        elseif(DEP STREQUAL "cuSPARSE")
            set(LIBRARIES ${LIBRARIES} "${ACCEL_INSTALL_DIR}/cuda/lib64/libcusparse.so")
            elseif(DEP STREQUAL "cuRAND")
            set(LIBRARIES ${LIBRARIES} "${ACCEL_INSTALL_DIR}/cuda/lib64/libcurand.so")
        endif()
    endforeach()
	#### Another CUDA build glob I've seen
	#     find_package(CUDAToolkit REQUIRED)
	#     target_link_libraries(${PROJECT_NAME} PRIVATE CUDA::cudart)
	#     set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_SEPARABLE_COMPILATION ON CUDA_ARCHITECTURES "native")
    message("Accel libraries is ${ACCEL_LIBRARIES}")
elseif(ACCEL STREQUAL "Metal")
    message("Accel: Metal")
    add_definitions(-DACCEL_METAL)
    add_definitions(-DNS_PRIVATE_IMPLEMENTATION)
    add_definitions(-DCA_PRIVATE_IMPLEMENTATION)
    add_definitions(-DMTL_PRIVATE_IMPLEMENTATION)
    set(INC_DIRS ${INC_DIRS} "${ACCEL_INSTALL_DIR}/metal/include")
    set(LIBRARIES "stdc++")
    set(LIBRARIES ${LIBRARIES} "-framework Metal")
    set(LIBRARIES ${LIBRARIES} "-framework Foundation")
    set(LIBRARIES ${LIBRARIES} "-framework QuartzCore")
    set(LIBRARIES ${LIBRARIES} "objc")
    # todo as part of CMake/Metal support, automated build of .metallib files from .metal source files (task for later) 
else()
    message("Accel: none")
endif()





