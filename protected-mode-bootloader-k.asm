section .boot
bits 16                         ; 16 bit mode
global boot
boot:
    mov ax, 0x2401              ; Enable A20 Gate
    int 15h                     ; raise System services interrupt

    mov [disk], dl
    mov ah, 0x2
    mov al, 6
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov dl, [disk]
    mov bx, off_mbr
    int 0x13
    
    cli                         ; clear interrupts
    lgdt [gdt.pointer]          ; load global descriptor table

    mov eax, cr0                ; Enable protected mode by setting
    or eax, 0x1                 ; bit 0 in cr0
    mov cr0, eax                ;

    mov ax, DATA_SEG
    mov ds, ax                  ; Set stack and data segments
    mov ss, ax
    mov es, ax
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

disk:
    db 0
times 510 - ($-$$) db 0         ; fill rest of bytes with 0
dw 0xaa55                       ; and last two bytes with magic number


off_mbr:
bits 32
boot32:
    mov esi, msg
    mov ebx, 0xb8000

print_loop:
    lodsb                       ; Load bytes at si to al and increment si
    or al, al                   ; Did we reach end of the msg ?
    jz busy_loop                ; Yes: jump to busy looping
    or eax, 0x0E00              ; No:  write current byte to video buffer 
    mov word [ebx], ax          ;
    add ebx, 2                  ;
    jmp print_loop              ;      loop 

busy_loop:
    mov esp, stack_top
    extern kmain
    call kmain
    cli                         ; clear interrrupt flag
    jmp $                       ; loop forever
    
msg:
    db "Calling kmain",0         ; bytes in string "Hello World!" followed by 00

section .bss
align 4 
resb 8192                   ; reserve 8kb for stack
stack_top:   
