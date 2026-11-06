#include "omp.h"
#include "parallel_platform.h"
#include "parallel_runtime.h"

#ifndef PARALLEL_DEFAULT_THREADS
#define PARALLEL_DEFAULT_THREADS 1
#endif
#if PARALLEL_DEFAULT_THREADS < 1 || PARALLEL_DEFAULT_THREADS > 2
#error "PARALLEL_DEFAULT_THREADS must be 1 or 2"
#endif

enum mailbox_state {
    IDLE = 0,
    READY = 1,
    DONE = 2
};

struct work_mailbox {
    parallel_function function;
    void *argument;
    unsigned int state;
};

static struct work_mailbox mailbox;

/* Core 0 writes; workers read during published jobs. */
static unsigned int active_team_size;

/* Accessed only by core 0. */
static unsigned int region_active;

/* Each core accesses only its own sense element. */
static unsigned int barrier_sense[2];

/* Core 1 publishes arrival; core 0 publishes release. */
static unsigned int barrier_arrived;
static unsigned int barrier_released;

volatile unsigned int parallel_runtime_error;

static unsigned char atomic_lock;

static unsigned char critical_lock;

static void runtime_fail(unsigned int error)
    __attribute__((noreturn));

static void runtime_fail(unsigned int error)
{
    parallel_runtime_error = error;

    platform_runtime_fail(error);

    /* Defensive fallback if a platform hook unexpectedly returns. */
    for (;;) {}
}

void parallel_runtime_init(void)
{
    if (platform_core_id() != 0)
        runtime_fail(PARALLEL_BAD_CORE);

    mailbox.function = 0;
    mailbox.argument = 0;
    active_team_size = 1;
    region_active = 0;
    parallel_runtime_error = 0;

    state_store_release(&mailbox.state, IDLE);

    barrier_sense[0] = 0;
    barrier_sense[1] = 0;
    barrier_arrived = 0;
    barrier_released = 0;

    atomic_lock = 0;

    critical_lock = 0;
}

void GOMP_parallel_start(parallel_function function,
                         void *argument,
                         unsigned int num_threads)
{
    unsigned int team_size;

    /* Reject calls from workers before touching coordinator state. */
    if (platform_core_id() != 0)
        runtime_fail(PARALLEL_BAD_CORE);

    if (region_active)
        runtime_fail(PARALLEL_NESTED_REGION);

    if (!function)
        runtime_fail(PARALLEL_BAD_FUNCTION);

    team_size = num_threads ? num_threads : PARALLEL_DEFAULT_THREADS;

    if (team_size > 2)
        runtime_fail(PARALLEL_BAD_TEAM);

    if (state_load_acquire(&mailbox.state) != IDLE)
        runtime_fail(PARALLEL_BAD_STATE);

    active_team_size = team_size;
    region_active = 1;

    if (team_size == 1)
        return;

    mailbox.function = function;
    mailbox.argument = argument;

    state_store_release(&mailbox.state, READY);
}

void GOMP_parallel_end(void)
{
    if (platform_core_id() != 0)
        runtime_fail(PARALLEL_BAD_CORE);

    if (!region_active)
        runtime_fail(PARALLEL_BAD_STATE);

    if (active_team_size == 2) {
        while (state_load_acquire(&mailbox.state) != DONE) {
        }

        state_store_release(&mailbox.state, IDLE);
    }

    active_team_size = 1;
    region_active = 0;
}

void parallel_worker_loop(void)
{
    parallel_function function;
    void *argument;

    if (platform_core_id() != 1)
        runtime_fail(PARALLEL_BAD_CORE);

    for (;;) {
        while (state_load_acquire(&mailbox.state) != READY) {
        }

        function = mailbox.function;
        argument = mailbox.argument;

        function(argument);

        state_store_release(&mailbox.state, DONE);
    }
}

int omp_get_thread_num(void)
{
    unsigned int id = platform_core_id();

    if (id > 1)
        runtime_fail(PARALLEL_BAD_CORE);

    return (int)id;
}

int omp_get_num_threads(void)
{
    return (int)active_team_size;
}

void GOMP_barrier(void)
{
    unsigned int id = platform_core_id();
    unsigned int sense;

    if (id > 1)
        runtime_fail(PARALLEL_BAD_CORE);

    if (active_team_size == 1)
        return;

    sense = barrier_sense[id] ^ 1u;
    barrier_sense[id] = sense;

    if (id == 0) {
        /* Core 0 has arrived; wait for core 1. */
        while (state_load_acquire(&barrier_arrived) != sense) {
        }

        /* Both have arrived: release core 1. */
        state_store_release(&barrier_released, sense);
    } else {
        state_store_release(&barrier_arrived, sense);

        while (state_load_acquire(&barrier_released) != sense) {
        }
    }
}

/* Atomic/reduction */
void GOMP_atomic_start(void)
{
    platform_lock_acquire(&atomic_lock);
}

void GOMP_atomic_end(void)
{
    platform_lock_release(&atomic_lock);
}

/* Critical */
void GOMP_critical_start(void)
{
    platform_lock_acquire(&critical_lock);
}

void GOMP_critical_end(void)
{
    platform_lock_release(&critical_lock);
}
