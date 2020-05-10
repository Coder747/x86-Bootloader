
%define PML4_ADDRESS 0x100000


physical_addr dq PML4_ADDRESS       ;start checking memory after 1 MB
current_pointer dq 0x0
test_number dq 0x100

;max = max memory size

memory_test:
    pushaq
 

    mem_test_loop:

        mov qword[physical_addr],test_number
        cmp qword[physical_addr],test_number

        jle size_check
        jmp exit2



size_check:
    ;mov r8,qword[max]           ;r8 = max size of physical memory mapped
    mov rax,0x6
    cmp rax,qword[max]
    jl mem_test_loop
    
    mov rsi,hexa_digits
    call video_print


exit2:
    popaq
    ret
