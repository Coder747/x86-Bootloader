;*******************************************************************************************************************
%define CONFIG_ADDRESS  0xCF8
%define CONFIG_DATA     0xCFC

ata_device_msg db 'Found ATA Controller',13,10,0
pci_header times 512 db 0


struc PCI_CONF_SPACE 
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc

get_pci_device:
    ;Compose the Config Address Register (32-bis):
    ;  Bit 7-2 : so we clear the last two bytes by & 0xfc
    ;  Bit 31 : Enable bit, and to set it we | 0x80000000
    ;  ((bus << 16) | (device << 11) | (function << 8) | (offset & 0xfc) | ( 0x80000000))    

    ; This function need to be written by you.

    
    xor rbx,rbx                     ;clear out rbx 
    mov bl,[bus]                    ;mov the bus into register bl (bl is a small rbx)
    shl ebx,16                      ;shift ebx 16 bits left to move it to the required position by the PCI controller for the Bus number.
    or eax,ebx                      ;or eax with ebx to have a copy of ebx in eax

    xor rbx,rbx                     ;...
    mov bl,[device]                 ;...
    shl ebx,11                      ;shift ebx 11 bits left to move it to the required position by the PCI controller for the Device number.
    or eax,ebx                      

    xor rbx,rbx                     ;...
    mov bl,[function]               ;...
    shl ebx,8                       ;shift ebx 8 bits left to move it to the required position by the PCI controller for the Function number.
    or eax,ebx

    or eax,0x80000000               ;set the enable bit to 1
    xor rsi,rsi                     ;set rsi to 0 (rsi will be used as the offset in the function below)
ret
    

;Loop that reads the registers of each device
pci_config_space_read_loop:
    push rax            ;save the value of the ready register (contains info about current device)
    
    or rax,rsi          ;move rsi into rax (rsi is initially 0)
    and al,0xfc         ;0xfc = 11111100‬ so it sets the last 2 bits to 0 (al is a small rax) (required by PCI controller)
    
    mov dx,CONFIG_ADDRESS   ;set dx = 0xCF8
    out dx,eax              ;write a double word to the port (Output doubleword in eax to the output port specified in dx)
    
    mov dx,CONFIG_DATA      ;set dx = 0xCFC
    xor rax,rax             ;set rax to 0
    in eax,dx               ;read a double word from the port (Input a doubleword from the port at the address specified by the dx register and put it into the eax register)
   
    mov [pci_header+rsi],eax        ;store the double word intro memory and incremeent the memory by rsi to store the next device
    add rsi,0x4                     ;increment offset by 4 bytes
    pop rax                         ;restore rax (contains info about current device)
    cmp rsi,0xff                    ;when rsi reaches 255 (256 itterations) exit the function (the configuration space was read)
    jl pci_config_space_read_loop

ret
