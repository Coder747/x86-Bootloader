GDT64:
    .Null: equ $ - GDT64         ; The null descriptor.
    dw 0   
    dw 0
    db 0
    db 0
    db 0        
    db 0

    .Code: equ $ - GDT64         ; The Kernel code descriptor.
    dw 0
    dw 0
    db 0
    db 10011000b
    db 00100000b
    db 0

    .Data: equ $ - GDT64         ; The Kernel data descriptor.
    dw 0
    dw 0
    db 0
    db 10010011b
    db 00100000b                 ;set long mode bit to 1
    db 0

ALIGN 4
    dw 0
    
    .Pointer:
    dw $ - GDT64 - 1
    dq GDT64