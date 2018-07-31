# framework
.section .text
.globl _start
  _start:
    nop
    movl %esp, %ebp     # take a copy of esp to use
    addl $8, %ebp       # address of first arg in stack
    movl (%ebp), %ecx   # copy address of first arg to ecx
    # need to find length of string and pass it to edx
    movl $4, %edx       # set length of string to 4
    movl $4, %eax       # set write to file for int 80
    movl $0, %ebx       # set file descriptor to 0 (stdout) for int 80
    int $0x80           # call int 80
    movl $1, %eax       # set exit for into 80
    movl $0, %ebx       # set return code to 0 for into 80
    int $0x80           # call into 80

