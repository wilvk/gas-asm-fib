# framework
.section .text
.globl _start
_start:
    nop
    movl %esp, %ebp     # take a copy of esp to use
    addl $8, %ebp       # address of first arg in stack
    movl (%ebp), %edi   # move arg address into esi for scasb
    push %edi
    movl $50, %ecx      # zero ecx counter
    movl $0, %eax        # zero al search char
    movl %ecx, %ebx
    cld                 # set direction down
    repne scasb         # iterate until we find the al char
    movl %ecx, %edx      # move count into edx
    subl %ecx, %ebx
    dec %ebx
    pop %ecx
    mov %ebx, %edx

    movl $4, %eax
    movl $0, %ebx
    int $0x80
    movl $1, %eax
    movl $0, %ebx
    int $0x80

