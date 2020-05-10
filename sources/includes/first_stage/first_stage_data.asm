;************************************** first_stage_data.asm **************************************
boot_drive db 0x0   ;id of the drive to load from
lba_sector dw 0x1   ;number of sectors in disk (0x0 is loaded by hardware)

spt dw 0x12         ;number of sectors/track    (default value of floppy)
hpc dw 0x2          ;number of head/cylinder    (default value of floppy)

Cylinder dw 0x0     ;
Head     db 0x0     ;variables used for conversion from LBA to CHS
Sector  dw 0x0      ;

; A number of string messages that we will use in our first stage boot loader
disk_error_msg db 'Disk Error', 13, 10, 0
fault_msg db 'Unknown Boot Device', 13, 10, 0
booted_from_msg db 'Booted from ', 0
floppy_boot_msg db 'Floppy', 13, 10, 0
drive_boot_msg db 'Disk', 13, 10, 0
greeting_msg db '1st Stage Loader', 13, 10, 0
second_stage_loaded_msg db 13,10,'2nd Stage loaded, press any key to resume!', 0
dot db '.',0
newline db 13,10,0
disk_read_segment dw 0
disk_read_offset dw 0
; "13,10" == "\r\n" , 0 == null character





