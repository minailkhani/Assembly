%include "in_out.asm"
section .data
    sumO db 0
    sumE db 0
    
    msgSpace db ' '
    lenSpace equ $ - msgSpace
section .text
    global  _start

_start:

    call readNum
    mov r10 ,10
    mov r12, 2
digitAdd:
    xor rdx, rdx
    div r10           ;cal remaining, rdx:remaining, rax:quotient, r10 Divisor
    call calSum
    cmp rax, 0
    je end
    jne digitAdd

calSum:
    push rdx
    push rax

    mov rax, rdx
    xor rdx, rdx
    div r12

    cmp rdx, 0
    je addToE
    jne addToO
    
    addToE:
        pop rax
        pop rdx

        add [sumE], rdx

        ret
    addToO:
        pop rax
        pop rdx

        add [sumO], rdx

        ret
end:
    xor rax, rax
    mov al, [sumO]
    call writeNum


    mov ebx, 1
    mov ecx, msgSpace
    mov edx, lenSpace
    mov eax, 4
    int 0x80

    xor rax, rax
    mov al, [sumE]
    call writeNum

exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80