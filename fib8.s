# framework - refactor into separate functions
.section .text
.globl _start

# entrypoint of application
_start:
    nop
    movl %esp, %ebp     # take a copy of esp to use
    addl $8, %ebp       # address of first arg in stack
    movl (%ebp), %edi   # move arg address into esi for scasb
    push %edi           # store the string address as edi gets clobbered
    call get_string_length  # get the length of the argument string passed in
    pop %edi             # get edi string address
    call long_from_string # get a numeric value from our argument
    call check_valid_input # if the result is zero, exit
    call fibonacci         # run our fibonacci sequence
    call print_long        # print the last value in the sequence
    call exit              # exit gracefully

# print the long value in register ebx
# process:
#  check our value is not zero, and handle the special case and print '0' if so
#  set a counter for the number of digits to 0
#  start a loop and check if value is zero - jump to done if so
#  divide the number by 10 and take the remainder as the first digit
#  add 48 to the number to make it an ascii value
#  store the byte in the address esp + ecx
#  increment the counter
#  jump to start of loop
# output: no output registers

print_long:
    mov %esp, %ebp  # copy the stack pointer to ebp for use
    addl $11, %esp   # add 11 extra spaces to the array size as a long is 32 bits and can be a number up to 10 digits long
    shl $2, %esp  # multiply by 4 as we are using 32 bit longs
    xor %ecx, %ecx   # zero our ecx counter
    mov $10, %ax  # for division, our divisor is stored in ax:dx
.loop_pl:
    xor %dx, %dx  # clear dx for the dividend
    div %ebx
    cmp $0, %ax
    je .done_pl
    addb $48, %dl
    movb %dl, (%esp, %ecx, 1)
    inc %ecx
    jmp .loop_pl
.done_pl:
    mov %ecx, %edx      # move our count value to edx for the int 80 call
    mov %esp, %ecx      # move our string start address into ecx
    movl $4, %eax       # set eax to 4 for int 80 to write to file
    movl $0, %ebx       # set ebx for file to write to as stdoout (file descriptor 0)
    int $0x80           # make it so
    movl %ebp, %esp # move our copy of the stack pointer back to esp
    popl %ebp       # retrieve the original copy of ebp from the stack
    ret

# if the result from long_from_string is 0, we exit as either the input was invalid or fib(0) is not valid
check_valid_input:
    cmpl $0, %eax
    je exit
    ret

# using address of string edi
# use eax register to store our result
# jump to done if not a number
# if numeric
# subtract 48 from the byte to convert it to a number
# multiply the result by 10 and add the number to eax
# multiply the result register eax by 10
# loop until the ecx counter has reached a non-numeric (null byte) and return
# e.g '123' will be processed:
#  '123' -> '1' r '23' => ( 0  * 10 ) + 1 = 1
#   '23' -> '2' r '3'  => ( 1  * 10 ) + 2 = 12
#    '3' -> '3' r ''   => ( 12 * 10 ) + 3 = 123
long_from_string:
    xor %eax, %eax # set eax as our result register
    xor %ecx, %ecx # set ecx(cl) as our temporary byte register
.lfs_top:
    movb (%edi), %cl  # get the byte pointed to by the address in edi
    inc %edi  # bump our position in the string array
    # check if we have a valid number in edi
    cmpb $48, %cl  # check if value in ecx is less than ascii '0'. exit if less
    jl .lfs_done
    cmpb $57, %cl  # check if value in ecx is greater than ascii '9'. exit if greater
    jg .lfs_done
    sub $48, %cl  # subtract the ascii component of the string to reveal the number
    imul $10, %eax  # multiply our result by 10 (doesn't affect our first iteration as 0x10 = 0)
    add %ecx, %eax  # add our digit to the result
    jmp .lfs_top
.lfs_done:
    ret

# input: eax holds our fibonacci n
# processing: iterate the fibonacci sequence n times
# output: return our fibonacci result in ebx
fibonacci:
    pushl %ebp      # preserve ebp as we are going to use it to store our stack pointer for the return call
    mov %esp, %ebp  # copy the stack pointer to ebp for use
    mov %eax, %ebx  # make a copy of our fib(n) value for allocating an array on the stack
    addl $2, %ebx   # add 2 extra spaces to the array size in case n=1 or n=1
    shl $2, %ebx    # multiply by 4 as we are using longs (32 bits)
    subl %ebx, %esp  # add the size of our array to the stack to allocate the required space
    xor %ecx, %ecx  # set our counter to zero
    movl %ecx, (%esp, %ecx, 4)  # initialise our array with 0 for esp[0]
    incl %ecx  # increase our counter
    movl %ecx, (%esp, %ecx, 4)  # initialise our array with 1 for esp[1]
    incl %ecx  # our counter/iterator should be at 2 now
.fib_loop:
    # we begin our for loop here
    cmp %eax, %ecx  # compare our counter (ecx) to n (eax) if it's greater or equal, we're done
    jge .fib_done
    movl -4(%esp, %ecx, 4), %ebx  # get the value in the stack at esp-1 from our current stack pointer location
    movl -8(%esp, %ecx, 4), %edx  # get the value in the stack esp-2 from our current stack pointer location
    addl %edx, %ebx  # add the values esp-1 and esp-2 together
    movl %ebx, (%esp, %ecx, 4)  # place the result in the current stack location
    incl %ecx   # bump our counter
    jmp .fib_loop  # loop again

.fib_done:
    movl %ebp, %esp # move our copy of the stack pointer back to esp
    popl %ebp       # retrieve the original copy of ebp from the stack
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

