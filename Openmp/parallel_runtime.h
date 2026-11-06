#ifndef PARALLEL_RUNTIME_H
#define PARALLEL_RUNTIME_H

typedef void (*parallel_function)(void *);

enum parallel_error {
    PARALLEL_BAD_CORE = 1,
    PARALLEL_BAD_TEAM,
    PARALLEL_NESTED_REGION,
    PARALLEL_BAD_STATE,
    PARALLEL_BAD_FUNCTION
};

/* Core 0 calls once, before workers are released. */
void parallel_runtime_init(void);

/* Core 1 enters after shared initialization completes. */
void parallel_worker_loop(void) __attribute__((noreturn));

/* Diagnostic value to inspect after an unexpected halt. */
extern volatile unsigned int parallel_runtime_error;

/* ABI entry points called by GCC-generated code. */
void GOMP_parallel_start(parallel_function function,
                         void *argument,
                         unsigned int num_threads);

void GOMP_barrier(void);

//atomic/reduction
void GOMP_atomic_start(void);
void GOMP_atomic_end(void);

//critical
void GOMP_critical_start(void);
void GOMP_critical_end(void);

void GOMP_parallel_end(void);




#endif
