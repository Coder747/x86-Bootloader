;************************************** load_boot_drive_params.asm **************************************
      load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]

pusha                       ;push registers to stack
xor di,di                   ;di and es should be restored to overcome buggy BIOSes
mov es,di                   ;es = 0
mov ah,0x8                  ;INT 0x13 function to fetch disk parameters
mov dl,[boot_drive]         ;dl carries the id of the disk stored in boot_drive to fetsh its parameters
int 0x13                    ;issue bios INT 0x13
inc dh                      ;DH incremented to store numbers of heads as its base-zero
mov word[hpc],0x0          ;clear out [hpc] / head/cylinder
mov [hpc+1],dh              ;store dh into lower byte of [hpc] as hpc is double word
and cx,0000000000111111b    ;first bits store the number of cylinders, last six bits which are sectors/track 
mov word[spt],cx           ;CX carrying sectors/track, is stored into [spt]
popa
ret

