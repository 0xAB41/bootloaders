bits 16                         ; 16 bit mode
org 0x7c00                      ; offset set to 0x7c00

greeting:
    db "Hello World!",0         ; bytes in string "Hello World!" followed by 00

init:
    mov ah, 0x0e                ; Write Charater in TTY
    mov si, greeting            ; Point source register to greeting
print_loop:
    lodsb                       ; Load bytes at si to al and increment si
    or al, al                   ; Did we reach end of the greeting ?
    jz busy_loop                ; Yes: jump to busy looping
    int 0x10                    ; No:  raise Video display function interrupt 
    jmp print_loop              ;      loop 

busy_loop:
    cli                         ; clear interrrupt flag
    jmp $                       ; loop forever
    
times 510 - ($-$$) db 0         ; fill rest of bytes with 0
dw 0xaa55                       ; and last two bytes with magic number
