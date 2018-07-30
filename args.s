# framework
.section .text
.globl _start
  _start:
    nop
    movl %esp, %ebp
    addl $8, %ebp # address of first arg in stack

