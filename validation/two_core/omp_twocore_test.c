#include <omp.h>
#include <ajit_mt_irc.h>

/* Shared BSS: multicore startup must clear it before either core
 * enters main().
 */
static unsigned int runtime_ready;
static unsigned int observed_id[2];
static unsigned int observed_size[2];
static unsigned int counter;

static unsigned int run_test(void)
{
    observed_id[0] = 99;
    observed_id[1] = 99;
    observed_size[0] = 0;
    observed_size[1] = 0;
    counter = 0;

    #pragma omp parallel num_threads(2)
    {
        int tid = omp_get_thread_num();
        int i;

        if (tid >= 0 && tid < 2) {
            observed_id[tid] = (unsigned int)tid;
            observed_size[tid] =
                (unsigned int)omp_get_num_threads();
        }

        for (i = 0; i < 100; ++i) {
            #pragma omp atomic
            counter++;
        }
    }

    /* Joining the region makes completed worker results visible. */
    return observed_id[0] == 0 &&
           observed_id[1] == 1 &&
           observed_size[0] == 2 &&
           observed_size[1] == 2 &&
           counter == 200;
}

int main(void)
{
    unsigned int id = platform_core_id();
    unsigned int passed;

    if (id == 0) {
        parallel_runtime_init();

        /* All runtime initialization precedes this publication. */
        state_store_release(&runtime_ready, 1);

        passed = run_test();

        parallel_runtime_shutdown();

        /* Test convention: 1 = PASS, 0 = FAIL. */
        board_terminate(passed);
    }

    if (id == 1) {
        while (!state_load_acquire(&runtime_ready)) {
        }

        parallel_worker_loop();

        /* Worker has acknowledged shutdown. */
        board_terminate(1);
    }

    /* Unexpected extra active core. */
    board_terminate(0);
}
