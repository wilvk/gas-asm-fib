# framework - convert string to number
.section .text
.globl _start

# entrypoint of application
_start:
    nop
    movl %esp, %ebp     # take a copy of esp to use
    addl $8, %ebp       # address of first arg in stack
    movl (%ebp), %edi   # move arg address into esi for scasb
    push %edi           # store the string address as edi gets clobbered
    call get_string_length
    pop %edi             # get edi string addr then push it as we are going to clobber it
    push %edi
    call long_from_string
    cmpl $0, %eax
    je exit
    call fibonacci
    call exit

# using address of string edi
# use eax register to store our result
# jump to done if not a number
# if numeric
# subtract 48 from the byte to convert it to a number
# multiply the result by 10 and add the number to eax
# multiply the result register eax by 10
# loop until the ecx counter has reached a non-numeric (null byte) and return
long_from_string:
    xor %eax, %eax # set eax as our result register
    xor %ecx, %ecx # set ecx(cl) as our temporary byte register
.top:
    movb (%edi), %cl
    inc %edi
    # check if we have a valid number in edi
    cmpb $48, %cl  # check if value in ecx is less than ascii '0'. exit if less
    jl .done
    cmpb $57, %cl  # check if value in ecx is greater than ascii '9'. exit if greater
    jg .done
    sub $48, %cl
    imul $10, %eax
    add %ecx, %eax
    jmp .top
.done:
    ret

fibonacci:
    ret

# get length of string pointed to by edi and place result in ebx
get_string_length:
    movl $50, %ecx      # set ecx counter to a high value
    movl $0, %eax       # zero al search char
    movl %ecx, %ebx     # copy our max counter value to edx
    cld                 # set direction down
    repne scasb         # iterate until we find the al char
    movl %ecx, %edx     # move count into edx
    subl %ecx, %ebx     # subtract from our original ecx value
    dec %ebx            # remove null byte at the end of the string from the count
    ret

# print the string in ecx to the length of ebx
print_string:
    mov %ebx, %edx      # move our count value to edx for the int 80 call
    movl $4, %eax       # set eax to 4 for int 80 to write to file
    movl $0, %ebx       # set ebx for file to write to as stdoout (file descriptor 0)
    int $0x80           # make it so
    ret

# exit the application
exit:
    movl $1, %eax       # set eax for int 80 for system exit
    movl $0, %ebx       # set ebx for return code 0
    int $0x80           # make it so again

