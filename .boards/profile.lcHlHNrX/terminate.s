.text
.align 4
.global board_terminate
board_terminate:
  ta 0
  nop
  nop
1: ba 1b
  nop
