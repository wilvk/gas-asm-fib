# framework
.section .text
.globl _start
  _start:
    nop
    movl $1, %eax
    movl $0, %ebx
    int $0x80
