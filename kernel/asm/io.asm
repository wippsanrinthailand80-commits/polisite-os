; Polisite OS — assembly layer (NASM, x86_64).
; Role: CPU port I/O and halt. Flat C ABI (System V x86_64).
; Args: rdi, rsi, rdx, ... ; return in rax/ax/al.

global outb
global inb
global halt

; void outb(uint16_t port, uint8_t val)
outb:
    mov dx, di      ; port (low 16 bits of rdi)
    mov al, sil     ; value (low 8 bits of rsi)
    out dx, al
    ret

; uint8_t inb(uint16_t port)
inb:
    mov dx, di      ; port
    in  al, dx
    ret

; void halt(void)
halt:
    hlt
    ret
