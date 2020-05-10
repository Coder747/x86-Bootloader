        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack
            pushfd              ; push eflags 
            pushfd              ; push eflags
            pushfd              ; push eflags
            pop eax             ; copy flags to eax
            xor eax,0x200000    ; flip bit 21
            push eax            ; copy value of eax again to eflags
            popfd               
            pushfd
            pop eax             ; updated value of eax
            pop ecx             ; original value of flag  
            xor eax,ecx         ; xoring will always produce 1
            and eax,0x0200000   ; anding supposed to zero out all bits except bit 21
            cmp eax,0x0         ; if eax equals zero this means eflags did not flip bit 21
            jne .cpuid_supported; jump to print cpuid is supported
            mov si,cpuid_not_supported  ; print message cpuid is not supported
            call bios_print             ;
            jmp hang                    ;
            .cpuid_supported:            ;if cpuid is supproted
                mov si,cpuid_supported  ;print message that cpu is supported
                call bios_print         ;
                popfd                   ;restore flag register
            popa                ; Restore all general purpose registers from the stack
            ret

        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack
            mov eax,0x80000000                      ;
            cpuid
            cmp eax,0x80000001                      ; if eax >= 0x80000001 then long mode is supported
            jl .long_mode_not_supported             ; if long mode is not supported jump to print that
            mov eax,0x80000001                      ; if supported move address to eax
            cpuid
            and edx,0x20000000                      ;mask out all bits
            cmp edx,0                               ;edx == 0 indicates long mode not supported
            je .long_mode_not_supported            ;jump to print long mode is not supported
            mov si,long_mode_supported_msg          ;if supported print that long mode is supported
            call bios_print                         ;print message
            jmp .exit_check_long_mode_with_cpuid
            .long_mode_not_supported:
                mov si,long_mode_not_supported_msg
                call bios_print                     ;print message
                jmp hang
            .exit_check_long_mode_with_cpuid:
                popa                                ; Restore all general purpose registers from the    stack
                ret
