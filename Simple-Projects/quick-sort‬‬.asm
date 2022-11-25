%include "in_out.asm"
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
    enter 8,0
    %define len qword[rbp-8]
    call readNum
    mov len, rax 

    push len
    call readArray
    
    cmp len, 1
    je is_sorted

    push global_array
    push qword 0 ;low 
    push len
    dec qword[rsp]
    call quickSort
    is_sorted:
    push global_array
    push len
    call printlistqword
    call Exit
    %undef len
    leave ;8
    ret
_start: 
    call main
    call Exit

; quickSort(low, high)
; {
;     if (low < high)
;     {
;         pi = partition(arr, low, high);

;         quickSort(low, pi - 1);  
;         quickSort(pi + 1, high); 
;     }
; }

quickSort: ;arr, low, high 
    enter 8, 0
    %define arr qword[rbp+32]
    %define low1 qword[rbp+24]
    %define high1 qword[rbp+16]
    %define local_pi qword[rbp-8]

    mov rax, low1
    cmp rax, high1
 
    jge continue_quickSort
    if_rsi_less_than_rdi:
        push arr
        push low1
        push high1
        call partition;(arr, low, high)    ;rax is pi
        mov local_pi ,rax


        push arr
        push low1
        push local_pi
        dec qword[rsp]
        call quickSort ;(arr,low1, pi-1)

        push arr
        push local_pi
        inc qword[rsp]
        push high1
        call quickSort;(arr,pi+1, high1)


    jmp continue_quickSort
    continue_quickSort:
    %undef arr 
    %undef low1
    %undef high1
    %undef local_pi
    
    leave 
    ret 24



; partition (low, high)
;     i = (low - 1)
;     for (j = low, j < high, j++)
;         if (arr[j] < arr[high])
;             i++
;             swap arr[i] and arr[j]
;     i++
;     swap arr[i] and arr[high]
;     return (i)
partition:
    enter 16, 0
    %define arr qword[rbp+32]
    %define low3 qword[rbp+24]
    %define high3 qword[rbp+16]
    %define local_i qword[rbp-8]
    %define local_j qword[rbp-16]
    push rbx
    push rcx
    push rdx

    mov rax, low3
    mov local_i, rax
    dec local_i
    mov local_j, rax
    dec local_j
    for_in_partition:
        inc local_j
        mov rax , high3
        cmp local_j, rax
        jge end_for_in_partition

        mov rax, local_j
        shl rax, 3
        add rax, arr  ;arr[j]

        mov  rbx, high3
        shl rbx, 3
        add rbx, arr  ;arr[high]

        mov rcx, [rax] ;[arr[j]]
        cmp rcx, [rbx]
        jge for_in_partition

        inc local_i
        ;             swap arr[i] and arr[j]
        mov rdx, local_i 
        shl rdx, 3
        add rdx, arr ;arr[i]

        xchg rcx, [rdx]
        mov [rax], rcx

        jmp for_in_partition

    end_for_in_partition:
    inc local_i

    mov rdx, local_i
    shl rdx, 3
    add rdx, arr ;arr[i]


    mov  rbx, high3
    shl rbx, 3
    add rbx, arr  ;arr[high]

    
    mov rcx, [rdx] ;[arr[i]]
    xchg rcx, [rbx]
    mov [rdx], rcx

    pop rdx
    pop rcx
    pop rbx
    
    mov rax, local_i ;ret rax
    %undef arr
    %undef low3
    %undef high3
    %undef local_i
    %undef local_j
    leave ;16
    ret 24

Exit:
    mov rax, 1
    mov rbx, 0 
    int 0x80