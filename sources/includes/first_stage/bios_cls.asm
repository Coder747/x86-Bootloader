;************************************** bios_cls.asm **************************************      
bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen

pusha       ;push all cpu regitster to stack -- works only on 16 bit mode 
mov ah,0x0  ;set video mode function
mov al,0x3  ;divide screen into 80x25
int 0x10    ;INT 0x10
popa        ;pop cpu registers again    
ret
