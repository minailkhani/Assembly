%include "in_out.asm"

    msgYes db 'Yes'
    lenYes equ $ - msgYes

    msgNo db 'No'
    lenNo equ $ - msgNo
section .text
    global  _start

_start:
    call readNum
    xor rcx, rcx
    inc rcx
    mov rbx, rax
    cmp rax, 1
    je no

prime:   
    inc rcx
    cmp rcx, rax   
    je yes
    xor rdx, rdx
    div rcx     ;cal remaining, rdx:remaining, rax:quotient
    cmp rdx,0   ;check divisibility
    mov rax, rbx
    je no

    jmp prime

yes :
    mov ebx, 1
    mov ecx, msgYes
    mov edx, lenYes
    mov eax, 4
    int 0x80
    call exit
no :
    mov ebx, 1
    mov ecx, msgNo
    mov edx, lenNo
    mov eax, 4
    int 0x80
    call exit

exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80