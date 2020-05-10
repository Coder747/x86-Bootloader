check_a20_gate:
    pusha                                   ; Save all general purpose registers on the stack
    mov ax,0x2402                           ;store function INT 0x15 into ax
    int 0x15                                ;issue interrupt, set flag if cannot modify A20 or if it is not supported
    jc .error                               ;if flag is set jump error
    cmp al,0x0                              ;if al == 0 means A20 is disabled
    je .enable_a20                          ;jump to enable A20 gate
    jmp .success                            ;exit if gate is enabled
    .enable_a20:
        mov si,a20_not_enabled_msg
        call bios_print
        mov ax,0x2401                   ;store function INT 0x15 into ax
        int 0x15                        ;issue interrupt,set flag if cannot set A20 gate on
        jc .error                       ;if flag is set jump error
        jmp check_a20_gate              ;jump again to ensure the gate is enabled
   .error:
        mov si,a20_function_not_supported_msg
        call bios_print
        jmp hang
   .success:
        mov si,a20_enabled_msg
        call bios_print 
     	popa                                    ; Restore all general purpose registers from the stack
     ret
