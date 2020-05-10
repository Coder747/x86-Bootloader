%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT

%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000



switch_to_long_mode:
        
          mov eax, 10100000b                    ;Set the 5th and 7th bit to 1 to enable Physical Address Extension and Page Global Enabled
          mov cr4,eax                           ;move it to cr4

          mov edi, PAGE_TABLE_EFFECTIVE_ADDRESS ;make cr3 point to the page table 
          mov edx,edi
          mov cr3, edx

          mov ecx, 0xC0000080    
          rdmsr                 ;execute the read special instruction (Loads the contents of a 64-bit model-specific register (MSR) specified in the ECX register into registers EDX:EAX)

          or eax, 0x00000100    ;Set the LME bit to 1 to enable long mode
          wrmsr                 ;execute the write special instruction (This instruction writes the contents of the EDX:EAX register pair into a 64-bit model-specific register specified in the ECX register)

          mov ebx,cr0
          or ebx,0x80000001         ;set bit 0 to 1 to enable paging and set bit 31 to 1 to enable protected mode
          mov cr0,ebx               ;move it to cr0

          lgdt [GDT64.Pointer]
          jmp CODE_SEG:LongModeEntry

    ret