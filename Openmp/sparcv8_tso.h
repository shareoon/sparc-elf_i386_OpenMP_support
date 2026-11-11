#ifndef SPARCV8_TSO_H
#define SPARCV8_TSO_H

#include "board_config.h"
#include "board_exit.h"
static inline unsigned int platform_core_id(void)
{
    unsigned int value;

    __asm__ __volatile__(
        "rd %%asr" BOARD_ASR ", %0"
        : "=r"(value)
    );

    return (value >> BOARD_ID_SHIFT) & BOARD_ID_MASK;
}

// Requires TSO, coherent shared RAM and aligned 32-bit accesses. 
static inline unsigned int
state_load_acquire(const unsigned int *address)
{
    unsigned int value;

    __asm__ __volatile__(
        "ld [%1], %0"
        : "=r"(value)
        : "r"(address)
        : "memory"
    );

    return value;
}

static inline void
state_store_release(unsigned int *address, unsigned int value)
{
    __asm__ __volatile__(
        "st %0, [%1]"
        :
        : "r"(value), "r"(address)
        : "memory"
    );
}

/* Locks */
static inline unsigned int
platform_lock_try(unsigned char *lock)
{
    unsigned int previous;

    __asm__ __volatile__(
        "ldstub [%1], %0"
        : "=r"(previous)
        : "r"(lock)
        : "memory"
    );

    return previous == 0;
}

static inline void
platform_lock_acquire(unsigned char *lock)
{
    while (!platform_lock_try(lock)) {
        // Retry until this core acquires the lock. 
    }
}

static inline void
platform_lock_release(unsigned char *lock)
{
    __asm__ __volatile__(
        "stb %%g0, [%0]"
        :
        : "r"(lock)
        : "memory"
    );
}

static inline void platform_runtime_fail(unsigned int error)
{
    // Runtime_fail has already recorded the diagnostic. 
    (void)error;
    board_terminate(0);
}

#endif
