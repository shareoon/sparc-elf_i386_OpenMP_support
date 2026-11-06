#ifndef PARALLEL_PLATFORM_H
#define PARALLEL_PLATFORM_H

/* Select an adapter explicitly; no hardware assumptions are implicit. */
#ifndef PARALLEL_PLATFORM_HEADER
#error "Define PARALLEL_PLATFORM_HEADER to a platform adapter header path"
#else
#include PARALLEL_PLATFORM_HEADER
#endif

/* Adapter contract (all operations must constrain compiler reordering):
 * unsigned int platform_core_id(void): stable logical index, 0 or 1.
 * unsigned int state_load_acquire(const unsigned int *): atomic acquire load.
 * void state_store_release(unsigned int *, unsigned int): atomic release store.
 * void platform_lock_acquire(unsigned char *): acquire a zero-initialized lock.
 * void platform_lock_release(unsigned char *): release a held lock.
 * void platform_runtime_fail(unsigned int): report/stop; must not return.
 *
 * These signatures may be static inline definitions. Shared flags must support
 * aligned unsigned-int atomic accesses. Lock representation is one byte.
 * Acquire/release must order ordinary shared data as well as flags/locks.
 */
#endif
