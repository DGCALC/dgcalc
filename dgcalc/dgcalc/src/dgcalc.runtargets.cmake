# File spectrum.cmake Created by Lucius Schoenbaum April 28, 2025
# Run targets for SPECTRUM, SPGEOMESH projects.
# Can be used more generally.
# Revised Spring 2026, August 2026



find_package(PkgConfig REQUIRED)



set(WORKING_DIR ${CMAKE_CURRENT_SOURCE_DIR})
message("${WORKING_DIR} ${CMAKE_CURRENT_SOURCE_DIR}")


if (NOT DEFINED OUTPUT_STEM OR OUTPUT_STEM STREQUAL "")
    # don't remove - cleaning is scripted using unsafe `rm` patterns
    set(OUTPUT_STEM "output")
endif()



if(NUM_PROCESSES)
    add_compile_definitions(USE_MPI)
    link_dependency(mpi)
endif()
link_dependency(gsl)
link_dependency(eigen)
if(USE_SILO)
    add_compile_definitions(USE_SILO)
    link_dependency(siloh5)
endif()




# ~run targets~
#
# user can point the build to MPI by setting NUM_PROCESSES (to the number of processes). 
# user can direct output to stdout, or to the terminal, or to both with 
# set(OUTPUT_STDOUT_FILE TRUE) # or FALSE
# set(OUTPUT_STDOUT_TERMINAL TRUE) # or FALSE
# user can set program arguments with set(PROGRAM_ARGS "x" "y" "z"). 


add_custom_target(main
    DEPENDS ${PROJECT_NAME}
)


string(REPLACE ";" " " ARGS "${PROGRAM_ARGS}")
set(BINARY_FULLNAME "${CMAKE_BINARY_DIR}/${PROJECT_NAME}")
if (DEFINED OUTPUT_STEM)
if(NUM_PROCESSES)
    if(OUTPUT_STDOUT_FILE)
        if(OUTPUT_STDOUT_TERMINAL)
            # output to file and to terminal
            # The error is still routed to the usual file.
            message("[runbin] mpi file+terminal")
            add_custom_target(runbin
                    COMMAND bash -c "cd ${WORKING_DIR} &&  [ -d ${OUTPUT_STEM} ] || mkdir ${OUTPUT_STEM} && find ${OUTPUT_STEM} -type f -delete && cd ${OUTPUT_STEM} && mpirun -n ${NUM_PROCESSES} ${BINARY_FULLNAME} ${PROGRAM_ARGS} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log && cat ${PROJECT_NAME}.out"
                    COMMENT "[runbin] > mpirun -n ${NUM_PROCESSES} ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
            add_custom_target(runhere
                    COMMAND bash -c "cd ${WORKING_DIR} && mpirun -n ${NUM_PROCESSES} ${BINARY_FULLNAME} ${PROGRAM_ARGS} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log && cat ${PROJECT_NAME}.out"
                    COMMENT "[runhere] > mpirunhere -n ${NUM_PROCESSES} ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
        else()
            message("[runbin] mpi file only")
            # output to file only
            add_custom_target(runbin
                    COMMAND bash -c "cd ${WORKING_DIR} &&  [ -d ${OUTPUT_STEM} ] || mkdir ${OUTPUT_STEM} && find ${OUTPUT_STEM} -type f -delete && cd ${OUTPUT_STEM} && mpirun -n ${NUM_PROCESSES} ${BINARY_FULLNAME} ${PROGRAM_ARGS} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log"
                    COMMENT "[runbin] > mpirun -n ${NUM_PROCESSES} ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
            add_custom_target(runhere
                    COMMAND bash -c "cd ${WORKING_DIR} && mpirun -n ${NUM_PROCESSES} ${BINARY_FULLNAME} ${ARGS_} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log"
                    COMMENT "[runhere] > mpirunhere -n ${NUM_PROCESSES} ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
        endif()
    else()
        # output to terminal only
        message("[runbin] mpi terminal only")
        add_custom_target(runbin
                COMMAND bash -c "cd ${WORKING_DIR} &&  [ -d ${OUTPUT_STEM} ] || mkdir ${OUTPUT_STEM} && find ${OUTPUT_STEM} -type f -delete && cd ${OUTPUT_STEM} && mpirun -n ${NUM_PROCESSES} ${BINARY_FULLNAME} ${PROGRAM_ARGS}"
                COMMENT "[runbin] > mpirun -n ${NUM_PROCESSES} ${PROJECT_NAME} ${PROGRAM_ARGS}"
                VERBATIM
        )
        add_custom_target(runhere
                COMMAND bash -c "cd ${WORKING_DIR} && mpirun -n ${NUM_PROCESSES} ${BINARY_FULLNAME} ${PROGRAM_ARGS}"
                COMMENT "[runhere] > mpirunhere -n ${NUM_PROCESSES} ${PROJECT_NAME} ${PROGRAM_ARGS}"
                VERBATIM
        )
    endif()
else()
    if(OUTPUT_STDOUT_FILE)
        if(OUTPUT_STDOUT_TERMINAL)
            message("[runbin] file+terminal")
            add_custom_target(runbin
                    # todo other custom targets should be formatted like this one
                    COMMAND bash -c "cd ${WORKING_DIR} && rm -rf ${OUTPUT_STEM} && mkdir ${OUTPUT_STEM} && cd ${OUTPUT_STEM} && ${BINARY_FULLNAME} ${PROGRAM_ARGS} > ${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log && cat ${PROJECT_NAME}.out"
                    COMMENT "[runbin] > ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
            add_custom_target(runhere
                    COMMAND bash -c "cd ${WORKING_DIR} && ${BINARY_FULLNAME} ${ARGS_} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log && cat ${PROJECT_NAME}.out"
                    COMMENT "[runhere] > ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
        else()
            message("[runbin] file only")
            add_custom_target(runbin
                    COMMAND bash -c "cd ${WORKING_DIR} &&  [ -d ${OUTPUT_STEM} ] || mkdir ${OUTPUT_STEM} && find ${OUTPUT_STEM} -type f -delete && cd ${OUTPUT_STEM} && ${BINARY_FULLNAME} ${PROGRAM_ARGS} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log"
                    COMMENT "[runbin] > ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
            add_custom_target(runhere
                    COMMAND bash -c "cd ${WORKING_DIR} && ${BINARY_FULLNAME} ${PROGRAM_ARGS} 1>${PROJECT_NAME}.out 2>${PROJECT_NAME}.err.log"
                    COMMENT "[runhere] > ${PROJECT_NAME} ${PROGRAM_ARGS}"
                    VERBATIM
            )
        endif()
    else()
        message("[runbin] terminal only")
        add_custom_target(runbin
                COMMAND bash -c "cd ${WORKING_DIR} &&  [ -d ${OUTPUT_STEM} ] || mkdir ${OUTPUT_STEM} && find ${OUTPUT_STEM} -type f -delete && cd ${OUTPUT_STEM} && ${BINARY_FULLNAME} ${PROGRAM_ARGS}"
                COMMENT "[runbin] > ${PROJECT_NAME} ${PROGRAM_ARGS}"
                VERBATIM
        )
        add_custom_target(runhere
                COMMAND bash -c "cd ${WORKING_DIR} && ${BINARY_FULLNAME} ${PROGRAM_ARGS}"
                COMMENT "[runhere] > ${PROJECT_NAME} ${PROGRAM_ARGS}"
                VERBATIM
        )
    endif()
endif()
endif()

