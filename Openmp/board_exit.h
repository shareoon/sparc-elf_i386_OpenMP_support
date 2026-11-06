#ifndef BOARD_EXIT_H
#define BOARD_EXIT_H
/* The termination instruction receives status in %o0. */
void board_terminate(unsigned int status) __attribute__((noreturn));
#endif
