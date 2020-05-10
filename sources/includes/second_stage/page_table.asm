%define PAGE_TABLE_BASE_ADDRESS 0x0000
%define PAGE_TABLE_BASE_OFFSET 0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000
%define PAGE_PRESENT_WRITE 0x3  ; 011b
%define MEM_PAGE_4K         0x1000

;PML4 = P4
;PDP  = P3
;PD   = P2
;PT   = P1

;This function maps the first 2MB of Memory into the page table.
build_page_table:
    pusha                                   ;save registers on the stack
        mov ax,PAGE_TABLE_BASE_ADDRESS      ;store into ax the begining of the page table (0x0000). 
        mov es,ax                           ;store into es 0x1000
        xor eax,eax                         ;set eax to zero 
        mov edi,PAGE_TABLE_BASE_OFFSET      ;set edi to 0x1000 hence es:di contain 0x0000:0x1000

        mov ecx,0x1000                      ;set ecx to 0x1000 which is 4KB (counter)
        xor eax,eax                         ;set eax to 0
        cld                                 ;clears direction flag (DF) in order to increment the data pointer
        rep stosd                           ;store contents of eax into where edi points to (es:edi) then increment directional flag by 4 bytes every loop
                                            ;each loop ecx is decremented by 1 so it will repeat 4096 times(0x1000)
                                            ;hence 4 * 4096 = 16KB = 4 memory pages
                                            ;"rep repeats the stosd instruction the number of times specified in the counter register ecx. The repetition terminates when the value in rCX reaches 0" 

        mov edi, PAGE_TABLE_BASE_OFFSET     ;set edi to 0x1000 es:di = 0x0000:0x1000    
        lea eax, [es:di + MEM_PAGE_4K]      ;load the address of the next page table (P3) into eax
        or eax, PAGE_PRESENT_WRITE          ;set the last 2 bits to 1 (the Present and R/W are 1)
        mov [es:di], eax                    ;store eax (0x2003) into the first entry of P4

        add di,MEM_PAGE_4K                  ;P3 is now at [0x0000:0x2000] = [es:di]

        lea eax, [es:di + MEM_PAGE_4K]      ;load the address of the next page table (P2) into eax
        or eax, PAGE_PRESENT_WRITE          ;set the last 2 bits to 1 (the Present and R/W are 1)
        mov [es:di], eax                    ;store eax (0x3003) into the first entry of P4

        add di,MEM_PAGE_4K                  ;P2 is now at [0x0000:0x3000] = [es:di]

        lea eax, [es:di + MEM_PAGE_4K]      ;load the address of the next page table (P1) into eax
        or eax, PAGE_PRESENT_WRITE          ;set the last 2 of eax to 1 (the Present and R/W are 1)       
        mov [es:di], eax                    ;store eax (0x4003) into the first entry of P4

        add di,MEM_PAGE_4K                  ;P1 is now at [0x0000:0x4000] = [es:di]
        mov eax, PAGE_PRESENT_WRITE         ;set the last 2 bits to 1 (the Present and R/W are 1)

        .pte_loop                           ;this loop maps the the 512 entries (in P1) to the first 2MB of physical memory.
                mov [es:di], eax            ;set es:di to 0x0000:0x0003
                add eax, MEM_PAGE_4K        
                add di, 0x8
                cmp eax, 0x200000           ;if eax is less than 0x200000 (Memory region segment) then continue the loop (map the rest) else the first 2MB are mapped
                jl .pte_loop                
        
        mov si,first2mb          
        call bios_print

    popa                                ; Restore all general purpose registers from the stack
    ret