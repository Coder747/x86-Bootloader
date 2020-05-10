 ;************************************** read_disk_sectors.asm **************************************
      read_disk_sectors: ; This function will read a number of 512-sectors stored in DI 
                         ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
pusha                           ;save registers on stack
add di,[lba_sector]             ;DI stores last sector to be read        
mov ax,[disk_read_segment]      ;ax stores the segment
mov es,ax                       ;ex = ax as ex can't be set directly
add bx,[disk_read_offset]       ;bx stores the offset
mov dl,[boot_drive]             ;dl carries address of drive to boot from

.read_sector_loop:
    call lba_2_chs              ;convert LBA to CHS
    mov ah,0x2                  ;interrupt for reading sectors
    mov al,0x1                  ;read only one sector
    mov cx,[Cylinder]           ;store cylinder int CX
    shl cx,0x8                  ;shift the value of CX 8 bits to the left to store cylinder
    or cx,[Sector]              ;store sector into first 6 bits
    mov dh,[Head]               ;store head to dh
    int 0x13                    ;issue interrupt -> read one sector from this location from disk
    jc .read_disk_error         ;if flag is set then there is an error
    mov si,dot                  ;save a '.' in si
    call bios_print             ;print dot
    inc word[lba_sector]        ;increment to read next sectorr
    add bx,0x200                ;move to next memory location to load next data from next sector (0x200 == 512)
    cmp word[lba_sector],di     ;if last sector == current sector, set the flag
    jl .read_sector_loop        ;if flag is not set loop read_sector_loop
jmp .finish                     ;jump to finish indicates disk was read correctly               
.read_disk_error:   
    mov si,disk_error_msg       ;in case of failure during reading sector print an error message
    call bios_print             ;
    jmp hang                    ;
.finish:    
    popa                        ;pop register to stack again
    ret     
