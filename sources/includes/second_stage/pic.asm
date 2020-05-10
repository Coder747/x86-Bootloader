%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    disable_pic:
        pusha
        mov al,0xFF
        out MASTER_PIC_DATA_PORT,al     ;Disable the Master PIC (to avoid reciviing interupts while switching from Real mode to Long mode)
        out SLAVE_PIC_DATA_PORT,al      ;Disable the Slave PIC
        nop
        nop                             ;we do 2 nops because it takes 2 cycles to disable the pic.

        ;print that the pic has been disabled.
        mov si, pic_disabled_msg        
        call bios_print
        popa                            ;Restore the registers from the stack
        ret