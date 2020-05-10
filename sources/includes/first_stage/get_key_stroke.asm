;************************************** get_key_stroke.asm **************************************      
get_key_stroke: ; A routine to print a confirmation message and wait for key press to jump to second boot stage

pusha         ;push all cpu registers to stack
mov ah,0x0    ;ah stores function to wait for a keyboard input
int 0x16      ;issues INT 0x16
popa          ;pop cpu register again
ret
