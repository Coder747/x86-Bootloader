;************************************** detect_boot_disk.asm **************************************      
      detect_boot_disk: ; A subroutine to detect the the storage device number of the device we have booted from
                        ; After the execution the memory variable [boot_drive] should contain the device number
                        ; Upon booting the bios stores the boot device number into DL

pusha               ;push registers to stack
mov si,fault_msg    ;si stores err message to print in case could not detect boot device
xor ax,ax           ;ax=0 to reset disk drive -- AH =0
int 13h             ;INT 0x13, resets disk in DL register
jc .exit_with_error ;case of reset failure, sets the carry flag-> j local label exit_with_error

mov si,booted_from_msg      ;si stores message to indicate boot succeded 
call bios_print             ;print message
mov [boot_drive],dl         ;get the id of the valid disk to boot_drive from dl
cmp dl,0                    ;if dl==0 , then it is booted from a floopy disk -> set the flag
je .floppy                  ;if flag is set, jump to local label floppy
call load_boot_drive_params ;if it is not a floppy check the type of drive again
mov si,drive_boot_msg      ;si stores message "DISK"
jmp .finish                 ;skip .floppy code is the booted drive is not a floppy

.floppy:
    mov si,floppy_boot_msg  ;si stores message to indicate it is a floppy
    jmp .finish             ;jump to finish to skip error
.exit_with_error:           ;in case boot failed
    jmp hang                ;hang
.finish:                
    call bios_print         ;print message stored in si either disk or floppy
    popa                    ;pop again resiters from the stack
ret  
                          
