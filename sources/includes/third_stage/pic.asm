%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    configure_pic:
        pushaq
                  ; This function need to be written by you.


        mov al,11111111b                    ; Disabling PIC by basically masking all the IRQs
        out MASTER_PIC_DATA_PORT,al
        out SLAVE_PIC_DATA_PORT,al
        mov al,00010001b                    ; Set ICW1 with bit0: expect ICW4, bit4: initialization bit
        out MASTER_PIC_COMMAND_PORT,al
        out SLAVE_PIC_COMMAND_PORT,al
                                            ; Since we sent ICW1 to the Command port we need to write ICW2-4 to the Data Port
        ; ICW2 for mapping interrupts, which interrupt number should the controller starts at
        mov al,0x20                         ; start with interrupt 32 on master
        out MASTER_PIC_DATA_PORT,al
        mov al,0x28                         ; start interrupt 40 on slave
        out SLAVE_PIC_DATA_PORT,al
        ; ICW3 for cascading communication. Define the pins that the master and the salve will communicate over
        mov al,00000100b                    ; IRQ2 on the master
        out MASTER_PIC_DATA_PORT,al
        mov al,00000010b                    ; Tells the slave the IRQ that the master is on,IRQ2
        out SLAVE_PIC_DATA_PORT,al
        ; ICW4 to set 80x86 mode
        mov al,00000001b                    ; bit0 sets 80x86 mode
        out MASTER_PIC_DATA_PORT,al
        out SLAVE_PIC_DATA_PORT,al
        mov al,0x0                          ; Unmask all IRQs
        out MASTER_PIC_DATA_PORT,al
        out SLAVE_PIC_DATA_PORT,al

        popaq
        ret


    set_irq_mask:
        pushaq                              ;Save general purpose registers on the stack
        ; This function need to be written by you.


        



        .out:    
        popaq
        ret


    clear_irq_mask:
        pushaq
        ; This function need to be written by you.
        .out:    
        popaq
        ret
