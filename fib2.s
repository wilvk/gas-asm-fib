# framework
.section .text
.globl _start
  _start:
    nop
    movl %esp, %ebp
    addl $8, %ebp # address of first arg in stack
    movl (%ebp), %ecx

    movl $4, %edx
    movl $4, %eax
    movl $0, %ebx
    int $0x80
    movl $1, %eax
    movl $0, %ebx
    int $0x80
