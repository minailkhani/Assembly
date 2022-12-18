%include "in_out.asm"
section .text
    global  _start

%macro printbit 1
    push rax
    mov rax, %1
    call writeNum
    pop rax
%endmacro
print1:
    printbit 1
    jmp main
print0:
    printbit 0
    jmp main

_start:
    call readNum
    mov rbx, 0
    jmp main
main:
    cmp rbx ,64
    je Exit

    bt rax, rbx
    inc rbx
    jnc print0
    jc print1
Exit:
    mov rax, 1
    mov rbx, 0
    int 0x80
