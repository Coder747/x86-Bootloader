%define IDT_BASE_ADDRESS            0x40000 ;  0x4000:0x0000 which is free
%define IDT_HANDLERS_BASE_ADDRESS   0x41000 ;  0x4000:0x1000 which is free
%define IDT_P_KERNEL_INTERRUPT_GATE 0x8E    ;  10001110 -> P DPL Z Int_Gate

%macro aISR 2           ;macro for ISR entry
      mov rsi,%1
      mov rdi,%2
      call setup_idt_entry
%endmacro

%macro aIRQ 2           ;macro for IRQ entry
      mov rsi,%1
      mov rdi,%2
      call setup_idt_entry
%endmacro

icounter db 1

struc IDT_ENTRY
.base_low         resw  1
.selector         resw  1
.reserved_ist     resb  1
.flags            resb  1
.base_mid         resw  1
.base_high        resd  1
.reserved         resd  1
endstruc

ALIGN 4                 ; Make sure that the IDT starts at a 4-byte aligned address    
IDT_DESCRIPTOR:         ; The label indicating the address of the IDT descriptor to be used with lidt
      .Size dw    0x1000                   ;  Table size is 0x1000 bytes (word, 16-bit) -> 256 x 16 bytes
      .Base dq    IDT_BASE_ADDRESS         ;  Table base address is 0x40000 (Quad word, 64-bit)



load_idt_descriptor:
    pushaq
    ; This function need to be written by you.

    lidt [IDT_DESCRIPTOR]
    popaq
    ret


init_idt:         ; Intialize the IDT which is 256 entries each entry corresponds to an interrupt number
                  ; Each entry is 16 bytes long
                  ; Table total size if 4KB = 256 * 16 = 4096 bytes
      pushaq
      ; This function need to be written by you.

      popaq
      ret


register_idt_handler: ; Store a handler into the handler array
                        ; RDI contains the interrupt number
                        ; RSI contains the handler address
      pushaq            ; Save all general purpose registers
     ; This function need to be written by you.

      shl rdi,3                                 ; Multiply interrupt number by 8 -> the index in handler array
      mov [rdi+IDT_HANDLERS_BASE_ADDRESS],rsi   ; Store handler address in the corresponding array location

      popaq             ; Restore general purpose registers
      ret

setup_idt:
      pushaq
            ;This function need to be written by you.
            ;RSI = address of handler
            ;RDI = interrupt number
            ;macros that loads the corresponding address into rsi and the coressponding interrupt number into rdi
      aISR isr0,0             
      aISR isr1,1
      aISR isr2,2
      aISR isr3,3
      aISR isr4,4
      aISR isr5,5
      aISR isr6,6
      aISR isr7,7
      aISR isr8,8
      aISR isr9,9
      aISR isr10,10
      aISR isr11,11
      aISR isr12,12
      aISR isr13,13
      aISR isr14,14
      aISR isr15,15
      aISR isr16,16
      aISR isr17,17
      aISR isr18,18
      aISR isr19,19
      aISR isr20,20
      aISR isr21,21
      aISR isr22,22
      aISR isr23,23
      aISR isr24,24
      aISR isr25,25
      aISR isr26,26
      aISR isr27,27
      aISR isr28,28
      aISR isr29,29
      aISR isr30,30
      aISR isr31,31

      ;setup irq
      aIRQ irq0,32
      aIRQ irq1,33
      aIRQ irq2,34
      aIRQ irq3,35
      aIRQ irq4,36
      aIRQ irq5,37
      aIRQ irq6,38
      aIRQ irq7,39
      aIRQ irq8,40
      aIRQ irq9,41
      aIRQ irq10,42
      aIRQ irq11,43
      aIRQ irq12,44
      aIRQ irq13,45
      aIRQ irq14,46
      aIRQ irq15,47

      call load_idt_descriptor      ;load the IDT to update it

      popaq
      ret


setup_idt_entry:  ; Setup and interrupt entry in the IDT
                  ; RDI: Interrupt Number
                  ; RSI: Address of the handler
                  
      ; This function need to be written by you.
      pushaq
      shl rdi,4                                                   ; multiply interrupt number by 16 (entry location into IDT)
      add rdi,IDT_BASE_ADDRESS                                    ; Add the IDT base address
      mov rax,rsi                                                 ; Calculate lower 16-bit of base address and store it
      and ax,0xFFFF
      mov [rdi+IDT_ENTRY.base_low],ax
      mov rax,rsi                                                 ; Calculate middle 16-bit of base address and store it
      shr rax, 16
      and ax,0xFFFF
      mov [rdi+IDT_ENTRY.base_mid],ax
      mov rax,rsi                                                 ; Calculate high 16-bit of base address and store it
      shr rax, 32
      and eax,0xFFFFFFFF
      mov [rdi+IDT_ENTRY.base_high],eax
      mov [rdi+IDT_ENTRY.selector], byte 0x8                      ; The Selector is the GDT code segment index
      mov [rdi+IDT_ENTRY.reserved_ist], byte 0x0
      mov [rdi+IDT_ENTRY.reserved], dword 0x0
      mov [rdi+IDT_ENTRY.flags], byte IDT_P_KERNEL_INTERRUPT_GATE ; 0x8E, 1 00 0 1110 -> P DPL Z Int_Gate 
            
      popaq
      ret

idt_default_handler:
      pushaq
      ;This is the default
      popaq
      ret

isr_common_stub:
      pushaq                  ; Save all general purpose registers
       ; This function need to be written by you.

      cli                                       ; Disable interrupt
      mov rdi,rsp                               ; Set RDI to the stack pointer
      mov rax,[rdi+120]                         ; Fetch the Interrupt number that was pushed by the macro
      shl rax,3                                 ; Multiple interrupt number by 8 -> offset in handlers array
      mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax]   ; Get the address of the registered routine
      cmp rax,0                                 ; Compare address with NULL
      je .call_default                          ; If yes, the no registered routine for the interrupt and we execute the default
      call rax                                  ; Else call the registered routine
      jmp .out                                  ; Skip the default
      .call_default:
      call idt_default_handler ; Call the default routine

      .out:
      popaq                   ; Restore all the general purpose registers
      add rsp,16              ; Make up for the interrupt number and the error code pushed by the macros
      sti                     ; Enable interrupts -> not neccessary, why:
      iretq                   ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP

irq_common_stub:
      pushaq                  ; Save all general purpose registers
      ; This function need to be written by you.

      cli                                             ; Disable interrupt
      mov rdi,rsp                                     ; Set RDI to the stack pointer
      mov rax,[rdi+120]                               ; Fetch the Interrupt number that was pushed by the macro
      shl rax,3                                       ; Multiple interrupt number by 8 -> offset in handlers array
      mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax]         ; Get the address of the registered routine
      cmp rax,0                                       ; Compare address with NULL
      je .call_default                                ; If yes, the no registered routine for the interrupt and we execute the default
      call rax                                        ; Else call the registered routine
      mov al,0x20                                     ; VERY IMPORTANT: Send EOI to PIC
      out MASTER_PIC_COMMAND_PORT,al
      out SLAVE_PIC_COMMAND_PORT,al
      jmp .out                                        ; Skip the default
      .call_default:
      call idt_default_handler                        ; Call the default routine
      .out:
      popaq                   ; Restore all the general purpose registers
      add rsp,16              ; Make up for the interruot number and the error code pushed by the macros
      sti                     ; Enable interrupts -> not neccessary, why:
      iretq                   ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP



setup_idt_irqs:
      pushaq
      ; This function need to be written by you.
      popaq
      ret


setup_idt_exceptions:
      pushaq
      ; This function need to be written by you.
      popaq
      ret

; This macro will be used with exceptions that does not push error codes on the stack
; NOtice that we push first a zero on the stack to make it consistent with other excptions
; that pushes an error code on the stack
%macro ISR_NOERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword 0            ;error code
      push qword %1           ;interrupt number
      jmp isr_common_stub
%endmacro

; This macro will be used with exceptions that push error codes on the stack
; Notice that we here push only the interrupt number which is passed as a parameter to the macro
%macro ISR_ERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword %1           ;interrupt number
      jmp isr_common_stub
%endmacro


; This macro will be used with the IRQs generated by the PIC
%macro IRQ 2
  global irq%1
  irq%1:
      cli
      push qword 0            ;error code
      push qword %2           ;interrupt number
      jmp irq_common_stub
%endmacro





ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31


IRQ   0,    32
IRQ   1,    33
IRQ   2,    34
IRQ   3,    35
IRQ   4,    36
IRQ   5,    37
IRQ   6,    38
IRQ   7,    39
IRQ   8,    40
IRQ   9,    41
IRQ  10,    42
IRQ  11,    43
IRQ  12,    44
IRQ  13,    45
IRQ  14,    46
IRQ  15,    47


isr255:
        iretq
