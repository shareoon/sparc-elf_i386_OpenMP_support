#ifndef PARALLEL_PLATFORM_H
#define PARALLEL_PLATFORM_H

// Select an adapter explicitly; no hardware assumptions are implicit. 
#ifndef PARALLEL_PLATFORM_HEADER
#error "Define PARALLEL_PLATFORM_HEADER to a platform adapter header path"
#else
#include PARALLEL_PLATFORM_HEADER
#endif
#endif
