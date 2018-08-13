# stack args example
.section .text
.globl _start
  _start:
    nop
    movl %esp, %ebp     # take a copy of the stack pointer esp into ebp
    addl $8, %ebp       # address of first arg in stack
    movl (%ebp), %ecx   # move the address of the first arg into ecx
    movl $4, %edx       # set the length of our string to 4
    movl $4, %eax       # indicate to int 0x80 that we are doing a write
    movl $0, %ebx       # indicate to int 0x80 that we are writing to file descriptor 0
    int $0x80           # call int 0x80 for write
    movl $1, %eax       # exit gracefully
    movl $0, %ebx       # with return code 0
    int $0x80           # call int 0x80 for exit
