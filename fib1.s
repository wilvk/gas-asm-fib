# framework
.section .text
.globl _start
  _start:
    nop
    # the rest of our program goes here
    movl $1, %eax
    movl $0, %ebx
    int $0x80
