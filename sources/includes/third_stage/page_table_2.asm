%define MEMORY_REGION_NUMBER        0x21000
%define MEMORY_REGION               0x21018
%define PML4_ADDRESS 0x100000
%define PDP_ADDRESS  0x101000
%define PD_ADDRESS   0x102000
%define PTE_ADDRESS  0x103000


PML4_counter dq 0x1 ;counter for PML4
PDP_counter dq 0x1  ;counter for PDP
PD_counter dq 0x1  ;counter for PD
PTE_counter dq 0x1  ;counter for PTE

PML4_ptr dq PML4_ADDRESS
PDP_ptr dq PDP_ADDRESS
PD_ptr dq PD_ADDRESS
PTE_ptr dq PTE_ADDRESS
current_ptr dq PTE_ADDRESS
phys_addr dq 0x0

max dq 0x0
mem_address dq 0x0
current_mem_region dq MEMORY_REGION

page_2:
    pushaq

    call   get_max_phys             ;get maximum possible memory that can be mapped according to the memory regions
    xor rdx,rdx                     ;clear rdx
    mov rdx,MEMORY_REGION           ;rdx points to address stored in memory region

    jmp PTE
    
    PML4_loop:
        add qword[current_ptr], 0x1000  ;move to next region
        mov qword[PDP_counter], 0x1     ;reset counter again to start from 0
        xor rax, rax                    ;set rax to zero
        xor rbx, rbx                    ;set rbx to zero
        mov rax,qword [current_ptr]    ;put current pointer in rax 
        mov qword [PDP_ptr],rax
        or rax, 0x3
        add qword[PML4_ptr], 0x8          ;increment ptr to next location
        mov rbx, PML4_ptr
        mov [rbx],rax
        add qword[PML4_counter], 0x1      ;increment counter

    PDP_loop:
        add qword[current_ptr], 0x1000 ;move to next region
        mov qword[PD_counter], 0x1     ;reset counter again to start from 0
        xor rax, rax                   ;set rax to zero
        xor rbx, rbx                   ;set rbx to zero
        mov rax,qword [current_ptr]    ;put current pointer in rax 
        mov qword [PD_ptr],rax
        or rax, 0x3
        mov rax, qword [PDP_ptr]
        add qword[PDP_ptr],0x8
        mov rbx, PDP_ptr 
        mov [rbx], rax
        add qword[PDP_counter],0x1

    PD_loop:
        ;xor rcx, rcx                     ;reset rcx
        ;mov rcx, [PML4_ptr]              ;copy pml4 address to rdx
        ;mov cr3, rcx                     ;set cr3 to adress of PML4
        add qword[current_ptr], 0x1000  ;move to next region
        mov qword[PTE_counter], 0x1     ;reset counter again to start from 1
        xor rax, rax                    ;set rax to zero
        xor rbx, rbx                    ;set rbx to zero
        mov rax, qword[current_ptr]     ;rax have the address of empty region
        or rax, 0x3                       ;enable present bit and r/w (activate the 4x)
        add qword[PD_ptr], 0x8            ;increment ptr to next location
        mov qword[PTE_ptr], rax         ;update the PTE_ptr value
        mov rbx, PD_ptr                   ;rbx have the address of PD ptr location
        mov [rbx], rax                   
        add qword[PD_counter], 0x1        ;increment counter

    PTE:
        mov r9, qword[rdx]                                     ;r9 = base address 
        mov r10, qword[rdx+8]                                  ;r10 = length
        add r10,r9                                             ;r10 = end = size of current region
        mov ecx,dword[rdx+16]                                  ;ecx = region type
        cmp ecx,0x1                                             ;check if the region is of type 1
        je .PTE_loop                                            ;if region 1 continue
        add rdx,0x18                            ;if regions is not of type 1 , move to next memory region
        jmp PTE                                                ;check again
        .PTE_loop:
            ;checking if the physical address reached the max possible memory
            xor rax,rax
            mov rax,[phys_addr]                 ;move current phys address to rax
            cmp rax,qword[max]                  ;check if we have reached the end of the physical memory
            jge exit_mapping                     ;if true then updates cr3 and exit

            ;check if the physical address is less than the end of the current region
            xor rsi,rsi
            cmp qword[phys_addr], r10            ;check if the physical address is less than the end of the current region
            jge out_of_memory_region              ;if false increment the address by 24 bytes

            xor rax, rax                            ;set rax to zero
            xor rbx, rbx                            ;set rbx to zero
            mov rax, PTE_ptr                        ;put current pte_ptr in rax
            mov rbx, qword[phys_addr]               ;put the current physical address in rbx
            or rbx, 0x3                             ;enable present bit and r/w
            mov [rax], rbx                          ;put the physical address after enabling it to the current PTE pointer

            add qword[phys_addr],0x1000             ;move to next phys address
            add qword[PTE_ptr], 0x8                 ;point to next PTE

            add qword[PTE_counter], 0x1
            
            cmp qword[PTE_counter], 0x200
            jle .PTE_loop

            cmp qword[PD_counter], 0x200            ;check if pd is full
            jle PD_loop

            cmp qword[PD_counter], 0x200            ;prints the "Mapping..."
            call progress
      

            cmp qword[PDP_counter], 0x200             ;check if pdp is full
            jle PDP_loop
                           

            cmp qword[PML4_counter],4              ;check if pml4 is full
            jle PML4_loop

            jmp exit_mapping
            
out_of_memory_region:
    add rdx,0x18                                      ;move to next region
    jmp PTE                                        ;get next region info
    ret

get_max_phys:
    pushaq
    mov rax, qword[MEMORY_REGION_NUMBER]           ;MEMORY_REGION points at the number of regions (7)      
    sub rax, 0x1                                   ;subtract -1 since to get the base address of the last region.                       
    mov rbx, 0x18                                  ;set rbx to 24                           
    mul rbx                                        ;multiply rbx by 24 to get to the last region then the result is stored in rax
    add rax, MEMORY_REGION                         ;add 0x21018 to rax to go to the last memory region.      
    mov r9, qword[rax]                             ;move the address pointed by rax to r9 (rax = base address of last region)            
    add rax, 0x8                                   ;add 8 bytes to rax to get to the length of the region
    add r9, qword[rax]                             ;add r9 (contains last base address) to the address pointed by rax (length of the region) to get the end address (max physical memory size)   
    mov qword[max], r9                             ;store the max size in variable max                                                 
    popaq
    ret


exit_mapping:
    ;xor rdx, rdx                     ;reset rcx
    ;mov rdx, [PML4_ptr]                 ;copy pml4 address to rdx
    ;mov cr3, rdx                     ;set cr3 to adress of PML4

    ;mov rdi,[phys_addr]
    ;call video_print_hexa
    ;mov rdi,[PD_counter]
    ;call video_print_hexa

    popaq
    ret

progress:
    mov rsi,mapping
    call video_print
    ret