%include "in_out.asm"
section .data
    sum db 0
section .text
    global  _start

increase:
    inc BYTE[sum]
    jmp main
printSum:
    mov rax, [sum]
    call writeNum
Exit:
    mov rax, 1
    mov rbx, 0
    int 0x80
_start:
    call readNum
    mov rbx, 0
main:
    cmp rbx ,64
    je printSum

    bt rax, rbx
    inc rbx
    jc increase
    jmp main
