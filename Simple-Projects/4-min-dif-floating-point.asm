%include "in_out.asm"

extern scanf
extern printf
extern fflush

section .data 
    minDif dq 99999999999999999.99999999999999999
    fmt1    db  "%lf", 0
    fmt2    db  "%lf %lf",  0xA,    0
    space   dq '', 0
    lenSpace equ $-space

section .bss 
    first   resq    1
    second  resq    1
    len     resq    1
    arr     resq    1000000
    x       resq    1
    junck   resq    1

section .text
    global  main
    global  _start


read_num_arr:
    push rbp
    mov rdi,    fmt1
    mov rsi,    x
    push rbx
    push rcx
    xor rax,    rax
    call    scanf   
    pop rcx
    pop rbx
    pop rbp
    mov rax, [x]

    ret 

check_min_dif:
    enter 0,0
    %define parametr_last_index qword[rbp+16]
    %define parametr_last_member qword[rbp+24]
    push rcx
    push r8
    push rsi
    push rdi

    xor r8, r8

    cmp r8,parametr_last_index
    je end_check_min_dif

    mov rdi, parametr_last_index
    xor rsi,rsi
    mov rcx, parametr_last_index

    loop_check:
        fld qword[arr+rsi*8]
        fld qword[arr+rdi*8]
        
        fsubp
        fabs
        fld qword[minDif]
        fcomi st0, st1
        jnae continue_check_min_dif
        update_ans:
            fstp    qword[minDif]
            fstp    qword[minDif]

            mov r8, qword[arr+rsi*8]
            mov qword[first], r8
            mov r8, qword[arr+rdi*8]
            mov qword[second], r8
        
        continue_check_min_dif:
            fstp qword[junck]
            fstp qword[junck]
            inc rsi
            loop loop_check



    end_check_min_dif:
        pop rdi
        pop rsi
        pop r8
        pop rcx
        %undef last_index
        leave
        ret 16

print_ans:
    push rbp


        movq    xmm0,   qword[first]
        movq    xmm1,   qword[second]
        mov     rdi,    fmt2
        mov     rax,    2
        call    printf


    pop rbp

    ret

main:
    push rax
    push rcx
    push rsi

    call readNum
    mov [len], rax

    mov rcx, [len]
    xor rbx, rbx

    min_dif_Fp_loop:
        call read_num_arr
        mov qword[arr+rbx*8], rax
        push rax
        push rbx
        call check_min_dif



        inc rbx
        loop min_dif_Fp_loop    

    call print_ans

    pop rbx
    pop rcx
    pop rsi

Exit:
	mov     rax,    60
    mov     rdi,    0
    call fflush
    syscall
