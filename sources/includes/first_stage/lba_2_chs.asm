 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]

pusha                       ;save registers on stack
xor dx,dx                   ;dx = 0
mov ax,[lba_sector]         ;ax stores [lba_Sector] that will be converted to its equivalent CHS
div word [spt]              ;lba_sector/spt -> DX carry the remainder while AX carry the quotient
inc dx                      ;sectors starts from 1 so dx should be incremented
mov [Sector],dx             ;move sector number from dx to memory
xor dx,dx                   ;zero out dx
div word [hpc]              ;ax/hpc
mov [Cylinder],ax           ;move cylinder number from ax to memory
mov [Head],dl               ;move head number from dl to memory
popa                        ;pop registers from stack
ret

