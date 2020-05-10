;*********************************** bios_print.asm *******************************
 bios_print: ; A subroutine to print a string on the screen using the bios int 0x10.
 ; Expects si to have the address of the string to be printed.
 ; Will loop on the string characters, printing one by one.
 ; Will Stop when encountering character 0.

pusha ; Save all general purpose registers on the stack
.print_loop:            ; loop to print charachter by a charachter
    xor ax,ax           ; Initialize ax to zero
    lodsb               ; al = current char pointed to by si and increment si to carry next charachter
    or al, al           ; if al == 0, it means it reached end of string (null charachter) then set the flag
    jz .done            ; if flag is set jump to done to exit loop
                  
    mov ah, 0x0E        ; otherwise store INT 0x10 print character function in ah
    int 0x10            ; print charchter stored in al
    jmp .print_loop     ; loop again to print next charachter
    .done:              ; Loop exit label
        popa            ; Restore all general purpose registers from the stack
        ret 
