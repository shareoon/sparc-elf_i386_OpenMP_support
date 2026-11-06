#ifndef SPARC_OMP_H
#define SPARC_OMP_H

#include "parallel_runtime.h"
#include "board_exit.h"

/* The SDK build supplies the active board adapter. */
#ifdef PARALLEL_PLATFORM_HEADER
#include "parallel_platform.h"
#endif

/* OpenMP API functions implemented by this runtime. */
int omp_get_thread_num(void);
int omp_get_num_threads(void);

#endif
