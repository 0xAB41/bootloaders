bits 16                         ; 16 bit mode
org 0x7c00                      ; offset set to 0x7c00

boot16:
    mov ax, 0x2401              ; Enable A20 Gate
    int 15h                     ; raise System services interrupt
    cli                         ; clear interrupts

    lgdt [gdt.pointer]          ; load global descriptor table

    mov eax, cr0                ; Enable protected mode by setting
    or eax, 0x1                 ; bit 0 in cr0
    mov cr0, eax                ;

    jmp CODE_SEG:boot32         ; long jump to 32. also clears pipe

gdt:
.start:
    dq 0x0                      ; null seg which is always 0

.code:                          ; code seg. set to target entire 4G
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

.data:                          ; data seg. set to target entire 4G
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
.end:
.pointer:                       ; gdt table. size followed by start offset
    dw .end - gdt
    dd gdt

CODE_SEG equ gdt.code - gdt.start
DATA_SEG equ gdt.data - gdt.start
    
bits 32
boot32:
    mov ax, DATA_SEG
    mov ds, ax                  ; Set stack and data segments
    mov ss, ax
    mov es, ax

    mov esi, greeting
    mov ebx, 0xb8000

print_loop:
    lodsb                       ; Load bytes at si to al and increment si
    or al, al                   ; Did we reach end of the greeting ?
    jz busy_loop                ; Yes: jump to busy looping
    or eax, 0x0E00              ; No:  write current byte to video buffer 
    mov word [ebx], ax          ;
    add ebx, 2                  ;
    jmp print_loop              ;      loop 

busy_loop:
    cli                         ; clear interrrupt flag
    jmp $                       ; loop forever
    
greeting:
    db "Hello World!",0         ; bytes in string "Hello World!" followed by 00

times 510 - ($-$$) db 0         ; fill rest of bytes with 0
dw 0xaa55                       ; and last two bytes with magic number
