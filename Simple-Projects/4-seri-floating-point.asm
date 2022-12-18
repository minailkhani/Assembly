%include "in_out.asm"

extern scanf
extern printf
extern fflush

section .data 
    fmt1    db  "%lf", 0
    fmt2  db  "%lf", 0xA, 0
    one     dq  1.0

section .bss 
    n resq 1
    x resq 1
    k resq 1
    one_per_fac resq 1
    tmp    resq 1
    ans resq 1

section .text
    global  main
    global  _start



main:
    enter   0,  0
    call readNum
    mov [n], rax
    
    mov rdi,    fmt1
    mov rsi,    x
    call    scanf   

    mov r15, 1

    loop_main:
        cmp r15, [n]
        jg end_loop_main
        fld qword[one]
        xor r14,r14
        inc r14
        fac_loop:
            cmp r14, r15
            jg  end_fac_loop
            mov [tmp], r14
            fild qword[tmp]

            fdivp
            
            fld qword[x] 
            fmulp

            inc r14
            jmp fac_loop
        end_fac_loop:
        fld qword[ans]
        faddp
        fstp qword[ans]
        inc     r15
        jmp     loop_main

    end_loop_main:
        fld qword[ans]
        fld qword[one]
        faddp
        fstp qword[ans]

        movq    xmm0,   qword[ans]
        mov     rdi,    fmt2
        mov     rax,    1
        call    printf


Exit:
  mov     rax,    60
    mov     rdi,    0
    call fflush
    syscall
