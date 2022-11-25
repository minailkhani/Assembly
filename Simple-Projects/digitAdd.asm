%include "in_out.asm"

section .data
    sum db 0
section .text
    global  _start

_start:

    call readNum
    mov r8 ,10
digitAdd:
    xor rdx, rdx
    div r8
    add [sum], rdx
    cmp rax, 0
    je end
    jne digitAdd


end:
    xor rax, rax
    mov rax, [sum]
    call writeNum
    call exit
exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80