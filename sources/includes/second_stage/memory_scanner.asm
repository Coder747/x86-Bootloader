%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150                
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack
            mov ax,MEM_REGIONS_SEGMENT                  ; set ES to 0x2000
            mov es,ax
            xor ebx,ebx                                 ;set ebx to 0
            mov [es:PTR_MEM_REGIONS_COUNT],word 0x0     ; counter to memory regions
            mov di, PTR_MEM_REGIONS_TABLE               ; memory address to store region information
            .memory_scanner_loop:                       ; Loop over available memory regions
                mov edx,MEM_MAGIC_NUMBER                ; Set EDX to magic number 0x0534D4150 = 'SMAP'
                mov word [es:di+20], 0x1                ; This is needed by function 0xe820 int 0x15 to load the memory region information to that address in memory
                mov eax, 0xE820                         ; store 0x15 interrupt function in eax
                mov ecx,0x18                            ; size of memory to store region information = 24 bytes
                int 0x15                                ; issue the interrupt, if failure occurs set the flag
                jc .memory_scan_failed                  ; if flag is set indicating error jump to memory scan failed
                cmp eax,MEM_MAGIC_NUMBER                ; If eax is equal to the magic number then the call is successful
                jnz .memory_scan_failed                 ; Else something wrong happened so we need to exit with error message
                add di,0x18                             ; Advance di 24 bytes to point to read next region in memory information
                inc word [es:PTR_MEM_REGIONS_COUNT]     ; Increment the memory regions counter to read all 5 regions informations   
                cmp ebx,0x0                             ; ebx == 0 , indicates that all memory regions had been read successfully
                jne .memory_scanner_loop                ; otherwise loop again to fetch next region
                jmp .finish_memory_scan                 ; reaching this point indicates reading data is done without errors
            .memory_scan_failed:
                mov si,memory_scan_failed_msg           ;print failure message
                call bios_print
                jmp hang
            .finish_memory_scan:
                popa                                        ; Restore all general purpose registers from the stack
                ret
    

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax       
            xor edi,edi
            mov di,word [es:PTR_MEM_REGIONS_COUNT]
            call bios_print_hexa
            mov si,newline
            call bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]
            mov si,0x1018 
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix


                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret
