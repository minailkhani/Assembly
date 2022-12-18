%include "in_out.asm"
section .bss
    string resb 1000

section .data
    sum dq 0

section .text
    global  _start

readStr:    
    push rdi
    push rsi
    push rdx

    mov rax, sys_read
    mov rdi, stdin
    mov rsi, string
    mov rdx, 1000
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    ret
increase:
    inc qword[sum]
    jmp calSum

calSum:
    cmp rbx ,8
    je main

    bt rax, rbx
    inc rbx
    jc increase
    jmp calSum

_start:
    call readNum
    lea rsi, [rax+string]

    call readNum
    lea  rdi, [rax+string]
    inc rdi
    call readStr

main:
    cmp rsi, rdi
    je printSum
    lodsb
    mov rbx, 0
    call calSum


printSum:
    xor rax, rax
    mov rax, [sum]
    call writeNum  
    Exit:
    mov rax, 1
    mov rbx, 0 
    int 0x80
