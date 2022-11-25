%include "in_out.asm"
section .data
    msgNaN db "NaN"
    lenNaN equ 3
section .bss
    global_array resq 1000000
section .text
    global  _start

print_space:
    push rax
    mov rax, ' '
    call putc
    pop rax
    ret

readArray: ;len
    enter 0,0
    %define len qword[rbp+16]
    cld
    push rdi
    push rcx
    mov rcx, len
    mov rdi, global_array
    whilenum:
        call readNum
        stosq
        ; xchg rax, [global_array+rdi*8]
        ; inc rdi
        loop whilenum
    pop rcx
    pop rdi
    leave
    %undef len
    ret 8

printlistqword:; array, len
    enter 0,0
    %define len qword[rbp+16]
    %define arr qword[rbp+24]

    cmp len, 1
    je print_last
    push rsi
    push rcx

    mov rsi, arr
    mov rcx, len
    dec rcx
    loop_in_print_arr_qword:
        lodsq
        call writeNum
        call print_space
        loop loop_in_print_arr_qword
    lodsq
    print_last:
    call writeNum

    pop rcx
    pop rsi

    %undef len
    %undef arr
    leave
    ret 16

main:
    enter 24,0
    %define local_len qword[rbp-8]
    %define local_q qword[rbp-16]
    %define local_x qword[rbp-24]
    push rcx
    call readNum
    mov local_len, rax

    push local_len
    call readArray

    call readNum
    mov local_q, rax

    mov rcx, local_q
    cmp local_q, 1
    je last
    dec rcx
    while_q:
        call readNum
        mov local_x, rax

        push local_x
        push global_array
        xor rax,rax
        push rax ;0
        push local_len
        dec qword[rsp]
        call binary_search ;x, arr,low,high ;ret rax
        ; call writeNum
        call print_ans
        call newLine
        loop while_q
    last:
    call readNum
    mov local_x, rax

    push local_x
    push global_array
    xor rax,rax
    push rax ;0
    push local_len
    dec qword[rsp]
    call binary_search ;x, arr,low,high ;ret rax
    ; call writeNum
    call print_ans

    pop rcx
    %undef local_len
    %undef local_q
    %undef local_x
    leave
    ret 0
_start: 
    call main
    call Exit

; def binary_search(x, arr,low,high):

;    ; if low < high:
;           mid = (low + high) // 2
;           if arr[mid] < x:
                ;  return binarySearch(x, arr,mid+1, high )
;               low = mid + 1
;           elif arr[mid] > x:
                ;  return binarySearch(x, arr,low, mid )
;               high = mid
;           elif mid > 0 and arr[mid-1] == x:
                ;  return binarySearch(x, arr,low, mid )  ;
;               high = mid
;           else:
;               return mid
;  return -1
print_ans:
    cmp rax, -1
    je print_nan
    call writeNum
    ret
    print_nan:
        push rcx
        mov rsi, msgNaN
        mov rdx, lenNaN
        mov rax, 1
        mov rdi, 1
        syscall
        pop rcx
        ret
binary_search: ;x, arr,low,high
    enter 8,0
    %define parametr_high qword[rbp+16]
    %define parametr_low qword[rbp+24]
    %define parametr_arr qword[rbp+32]
    %define parametr_x qword[rbp+40]
    %define local_mid qword[rbp-8]
    push rbx
    push rdx
    mov rax, parametr_low
    cmp rax, parametr_high
    jge not_low_less_than_high

    mov rbx, parametr_low
    add rbx, parametr_high
    shr rbx, 1
    mov local_mid, rbx 

    mov rbx, local_mid
    shl rbx, 3
    add rbx, parametr_arr ;arr[mid]
    
    if: ; if low < high:
    mov rdx, [rbx]
    cmp rdx, parametr_x
    jge elif1 
        ; return binarySearch(x, arr,mid+1, high )
        push parametr_x
        push parametr_arr
        push local_mid
        inc qword[rsp]
        push parametr_high
        call binary_search
        jmp finish

    elif1: ; arr[mid] > x
    jle elif2
        ;  return binarySearch(x, arr,low, mid )
        push parametr_x
        push parametr_arr
        push parametr_low
        push local_mid
        call binary_search
        jmp finish
        
    elif2:  ;mid > 0 and arr[mid-1] == x
    cmp local_mid, 0
    jle else

    mov rbx, local_mid
    dec rbx
    shl rbx, 3
    add rbx, parametr_arr ;arr[mid-1]
    mov rdx, [rbx]
    cmp rdx, parametr_x
    jne else
        ;  return binarySearch(x, arr,low, mid )  ;
        push parametr_x
        push parametr_arr
        push parametr_low
        push local_mid
        call binary_search
        jmp finish

    else:
        mov rax, local_mid
        jmp finish

    not_low_less_than_high:
        mov rbx, parametr_low
        shl rbx, 3
        add rbx, parametr_arr
        mov rdx, [rbx]
        cmp rdx, parametr_x
        cmove rax, parametr_low
        mov r15, -1
        cmovne rax , r15
    finish:
    pop rdx
    pop rbx
    %define parametr_high
    %define parametr_low
    %define parametr_arr
    %define parametr_x
    %undef local_mid
    ;ret rax
    leave
    ret 32

Exit:
    mov rax, 1
    mov rbx, 0 
    int 0x80