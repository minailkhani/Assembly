%include "in_out.asm"
; %include    "./my-file-in-out.asm"
; %include    "./dict-dis-ass.asm"
section     .bss
    NewLine     equ     0xA
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000
    sys_mkdir       equ 83

    sys_makenewdir  equ 0q777

section .bss    
    command         resb 25   
    tofilePtr       resq 1
    tofile          resb 10000
    
    rex_w           resb 1
    rex_r           resb 1
    rex_x           resb 1
    rex_b           resb 1

    instruction     resb 10
    opCode          resb 9   ;6 is enough.
    opcode_D_S      resb 2
    opcode_W        resb 2

    mod             resb 3
    RegOp           resb 4
    RM              resb 5

    sib_scale       resb 5
    sib_index       resb 5
    sib_base        resb 5
    
    dsp             resb 20
    data            resb 20
    op1             resb 10
    op2             resb 10
    opSize          resb 2
    regOp_reg       resb 20
    rm_reg          resb 20
    sourceFileNametest  resb  20


section .data
    sourceFileName      dq  'machinecode.txt', 0
    destinationFileName dq  'dis-assemblycode.txt',0    
    FD_source           dq  0
    FD_destination      dq  0
    source_dir_fd       dq  0
    len_file            dq  0

    dollar_sign         db '$'
    prefix66_flag       db 0
    prefix67_flag       db 0
    need_rex_flag       db 0
    need_sib_flag       db 0
    has_0f_flag         db 0

    reg1IsNew           db '0'
    reg2IsNew           db '0'

    scaleDict       db  "00:1 01:2 10:4 11:8 $"
    memorySizeDict  db  "1:BYTE 2:WORD 4:DWORD 8:QWORD $"
    indexSizeDect   db  "1:0 2:1 4:2 8:3 $"
    twoOpNoImDict   db  "000010:or 000100:adc 000110:sbb 100010:mov 000011111100000:xadd 0000111110111100:bsf 0000111110111101:bsr 0000111110101111:imul 000000:add 001010:sub 001000:and 001100:xor 001110:cmp $"
    zeroOpDict      db  "f9:stc f8:clc fd:std fc:cld 0f05:syscall c3:ret $"
    
    regCodeNotNew   db  "000:al,ax,eax,rax, 001:cl,cx,ecx,rcx 010:dl,dx,edx,rdx 011:bl,bx,ebx,rbx 100:ah,sp,esp,rsp 101:ch,bp,ebp,rbp 110:dh,si,esi,rsi 111:bh,di,edi,rdi $" 
    regCodeNew      db  "000:r8b,r8w,r8d,r8 001:r9b,r9w,r9d,r9 010:r10b,r10w,r10d,r10 011:r11b,r11w,r11d,r11 100:r12b,r12w,r12d,r12 101:r13b,r13w,r13d,r13 110:r14b,r14w,r14d,r14 111:r15b,r15w,r15d,r15 $"
    imToReg         db  "000:add,pop,inc,mov,test 001:or,dec 010:adc,not 011:neg,sbb 100:and,shl 101:sub,shr,imul 110:xor,push 111:cmp,idiv $"
    twoOpIm         db  "100000:add,adc,and,or,xor,cmp,sub,sbb 111101:test 110001:mov 1011:mov 110100:sh 110000:sh $"
    
    oneOpDict       db  "100011:pop 111101:neg,not,idiv,imul 111111:inc,dec,push $"
    
    exceptionsDict  db  "110000:xadd 101111:bsf,bsr 101011:imul 100001:test,xchg $"
    
    regOpDict       db  "000:add,pop,inc,mov,test 010:adc,not 101:sub,shr,imul 011:sbb,neg 100:and,shl 001:or,dec 110:xor,push 111:cmp,idiv $"
    
    hexTobinDict    db  "0:0000 1:0001 2:0010 3:0011 4:0100 5:0101 6:0110 7:0111 8:1000 9:1001 a:1010 b:1011 c:1100 d:1101 e:1110 f:1111 $"
    binToHexDict    db  "0000:0 0001:1 0010:2 0011:3 0100:4 0101:5 0110:6 0111:7 1000:8 1001:9 1010:a 1011:b 1100:c 1101:d 1110:e 1111:f $"


section .text
    global  _start
set_op_size:
    push    r8
    push    r10
    push    r11
    push    r12
    push    r14
    
    xor r8, r8
    xor r10, r10
    xor r11, r11
    xor r12, r12
    xor r14, r14
    
    mov r11,    '1'
    mov r12,    '2'
    mov r14,    '4'
    mov r8,     '8'

    cmp byte[prefix66_flag],    1
    cmove   r10, r12
    cmp byte[prefix66_flag],    1
    je  finish_set_op_size

    cmp byte[need_rex_flag],    1
    jne check_code_w
    cmp byte[rex_w],    '1'
    cmove   r10, r8
    cmp byte[rex_w],    '1'
    je  finish_set_op_size

    check_code_w:
    cmp byte[opcode_W],    '0'
    cmove   r10,  r11
    cmp byte[opcode_W],    '0'
    je  finish_set_op_size
    
    mov   r10,  r14

    finish_set_op_size:
        mov byte[opSize],   r10b
        pop r14
        pop r12
        pop r11
        pop r10
        pop r8

        ret
        
convert_one_hex_digit_to_bin: ;starting point is in rsi
    push    r11

    xor     r11,    r11
    mov     r11,    hexTobinDict
    push    r11
    push    rsi
    call    get_val_from_dict
    
    pop     r11
    ret
set_mod_rm:
    push    r11
    push    rsi
    push    rax

    push    rsi

    call convert_one_hex_digit_to_bin

    mov     r11w,   WORD[rsi]
    mov     WORD[mod],  r11w
    mov     r11w,   WORD[rsi+2]
    mov     WORD[RegOp],  r11w

    pop     rsi
    push    rsi

    inc     rsi
    call    convert_one_hex_digit_to_bin

    mov     r11b,   byte[rsi]
    mov     byte[RegOp+2],  r11b
    mov     r11d,   DWORD[rsi+1]
    mov     DWORD[RM],  r11d
    mov     r11b,   byte[rsi+3]
    mov     byte[RM+2],  r11b
    
    pop     rsi

    pop     rax
    pop     rsi
    pop     r11

    ret

set_rex_parts:  
    push    r11
    push    rsi
    push    rax

    inc     rsi
    call convert_one_hex_digit_to_bin

    mov r11b, byte[rsi]   
    mov byte[rex_w],    r11b
    mov r11b, byte[rsi+1]
    mov byte[rex_r],    r11b
    mov r11b, byte[rsi+2]
    mov byte[rex_x],    r11b
    mov r11b, byte[rsi+3]
    mov byte[rex_b],    r11b

    pop     rax
    pop     rsi
    pop     r11
    ret
set_opcode:
    push    r11
    push    rsi
    push    rax

    push    rsi

    call    convert_one_hex_digit_to_bin

    mov     r11d,   DWORD[rsi]
    mov     DWORD[opCode],  r11d

    pop     rsi
    push    rsi

    inc     rsi
    call    convert_one_hex_digit_to_bin

    mov     r11w,   WORD[rsi]
    mov     WORD[opCode+4],  r11w
    mov     r11b,   byte[rsi+2]
    mov     byte[opcode_D_S],  r11b
    mov     r11b,   byte[rsi+3]
    mov     byte[opcode_W],  r11b

    pop     rsi

    pop     rax
    pop     rsi
    pop     r11

    ret

set_sib:
    push    rsi
    push    rdi
    mov byte[need_sib_flag],    1

    push    rsi

    call convert_one_hex_digit_to_bin

    mov     r11w,   WORD[rsi]
    mov     WORD[sib_scale],  r11w
    mov     r11w,   WORD[rsi+2]
    mov     WORD[sib_index],  r11w

    pop     rsi
    push    rsi

    inc     rsi
    call    convert_one_hex_digit_to_bin

    mov     r11b,   byte[rsi]
    mov     byte[sib_index],  r11b
    mov     r11d,   DWORD[rsi+1]
    mov     DWORD[sib_base],  r11d
    mov     r11b,   byte[rsi+3]
    mov     byte[sib_base+2],  r11b
    
    pop     rsi



    pop rdi
    pop rsi
    ret
set_dsp:
    ret 8
set_mem:
    ret
parser:
    push    r8

    mov rsi,    command
    check_prefix_67:
        cmp word[rsi],  '67'
        je  set_prefix67
    check_prefix_66:
        cmp word[rsi],  '66'
        je set_prefix66
        jmp check_rex
    set_prefix67:
        mov byte[prefix67_flag],    1
        inc rsi
        inc rsi
        jmp check_prefix_66
    set_prefix66:
        mov byte[prefix66_flag],    1
        inc rsi
        inc rsi
    
    check_rex:
        cmp byte[rsi], '4'
        je  set_rex
        jne check_start_with_0f
    set_rex:
        mov byte[need_rex_flag],    1
        call    set_rex_parts
        inc rsi
        inc rsi

    check_start_with_0f:
        cmp word[rsi],  '0f'
        je  set_0f
        jne check_opCode
    set_0f:
        mov byte[has_0f_flag],  1
        inc rsi
        inc rsi

    check_opCode:
        call set_opcode
        inc rsi
        inc rsi
    
    mod_rm:
        call set_mod_rm
        inc rsi
        inc rsi
    
    check_sib:
        cmp word[RM],   '10'
        jne check_dsp_short
        cmp word[RM+2],   '0'
        jne check_dsp_short
        call    set_sib
        inc rsi
        inc rsi
    check_dsp_short:
        mov r8, 8
        cmp word[RM],   '10'
        jne continue_check_dsp_short
        add rsi,    8
        jmp  call_set_dsp
        
        continue_check_dsp_short:
        cmp word[mod],   '00'
        jne check_dsp_long
        cmp byte[need_sib_flag],    1
        jne check_dsp_long
        cmp word[sib_base],   '10'
        jne check_dsp_long
        cmp byte[sib_base],   '1'
        jne check_dsp_long
        add rsi,    8
        jmp call_set_dsp

    
    check_dsp_long:
        mov r8, 2
        cmp word[RM],   '01'
        jne rest_imm
        inc rsi
        inc rsi
        jmp  call_set_dsp
    call_set_dsp:
        push    r8
        call    set_dsp
    rest_imm:
        push    r8
        call    set_dsp
        
        pop r8
        ret
check_is_zero_op:
    push    r11
    xor     r11,    r11
    mov     r11,    zeroOpDict
    push    r11
    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_val_from_dict  
    pop r11
    ret

str_to_int_one_digit:
    enter   0,  0
    %define str qword[rbp+16]
    mov rax,    str
    cmp byte[rax],  '0'
    je  mov_0
    cmp byte[rax],  '1'
    je  mov_1
    cmp byte[rax],  '2'
    je  mov_2
    cmp byte[rax],  '3'
    je  mov_3
    cmp byte[rax],  '4'
    je  mov_4
    cmp byte[rax],  '5'
    je  mov_5
    cmp byte[rax],  '6'
    je  mov_6
    cmp byte[rax],  '7'
    je  mov_7
    cmp byte[rax],  '8'
    je  mov_8
    cmp byte[rax],  '9'
    je  mov_9
    mov_0:
        mov rax,    0
        jmp finish_str_to_int_one_digit
    mov_1:
        mov rax,    1
        jmp finish_str_to_int_one_digit
    mov_2:
        mov rax,    2
        jmp finish_str_to_int_one_digit
    mov_3:
        mov rax,    3
        jmp finish_str_to_int_one_digit
    mov_4:
        mov rax,    4
        jmp finish_str_to_int_one_digit
    mov_5:
        mov rax,    5
        jmp finish_str_to_int_one_digit
    mov_6:
        mov rax,    6
        jmp finish_str_to_int_one_digit
    mov_7:
        mov rax,    7
        jmp finish_str_to_int_one_digit
    mov_8:
        mov rax,    8
        jmp finish_str_to_int_one_digit
    mov_9:
        mov rax,    9
        jmp finish_str_to_int_one_digit
    finish_str_to_int_one_digit:
        %undef str
        leave
        ret 8

get_i_th_val:    ;ret ptr rax
    enter   0,  0
    %define i qword[rbp+24]
    %define ptr qword[rbp+16]
    push    rcx

    push    i
    call    str_to_int_one_digit
    mov     rcx,    rax

    mov rax,    ptr
    cmp rcx,    0
    je  finish_get_i_th_val
    loop_get_reg:
        push    rax
        call get_index_of_first_spliter_after_ptr
        inc rax
        inc rax
        loop    loop_get_reg
    
    finish_get_i_th_val:
    pop rcx
    %undef i 
    %undef ptr 
    leave
    ret 16
write_zero_op:
    call    insert_tofile
    call    insert_new_line
    inc     qword[tofilePtr]
    inc     qword[len_file]
    ret
write_one_op_reg:
    mov     rsi,    instruction
    push    rsi
    call get_index_of_first_spliter_after_ptr
    mov rdi,    rax
    call    insert_tofile
    
    call    insert_space_file
    inc     qword[tofilePtr]
    inc     qword[len_file]
    
    mov     rsi,    op1
    push    rsi
    call get_index_of_first_spliter_after_ptr
    mov rdi,    rax
    call    insert_tofile
    
    
    call    insert_new_line
    inc     qword[tofilePtr]
    inc     qword[len_file]
   
    ret

write_0f:
    ret
write_two_op_reg_reg:
    mov     rsi,    instruction
    push    rsi
    call get_index_of_first_spliter_after_ptr
    mov rdi,    rax
    call    insert_tofile
    
    call    insert_space_file
    inc     qword[tofilePtr]
    inc     qword[len_file]
    
    mov     rsi,    op1
    push    rsi
    call get_index_of_first_spliter_after_ptr
    mov rdi,    rax
    call    insert_tofile
    
    call    insert_comma_file
    inc     qword[tofilePtr]
    inc     qword[len_file]
    
    mov     rsi,    op2
    push    rsi
    call get_index_of_first_spliter_after_ptr
    mov rdi,    rax
    call    insert_tofile
    
    call    insert_new_line
    inc     qword[tofilePtr]
    inc     qword[len_file]
   
    ret
set_one_op_reg:
    push    r15
    push    r11
    push    rsi
    push    rdi
    push    rbx
    push    rdx
    
    xor     r11,    r11
    mov     r11,    oneOpDict
    push    r11
    xor     r11,    r11
    mov     r11,    opCode
    push    r11
    call    get_instruction
    mov     rdx,    rsi
    
    push    rdx

    xor     r11,    r11
    mov     r11,    regOpDict
    push    r11
    xor     r11,    r11
    mov     r11,    RegOp
    push    r11
    call    get_instruction
    mov     rbx,    rsi

    pop     rdx

    push    rdx
    push    rbx
    call    union

    push    rax
    call set_instruction
    
    check_reg_is_new:
        cmp byte[need_rex_flag],    1
        jne get_reg
        mov r11b,   byte[rex_b]
        mov byte[reg1IsNew],    r11b

    get_reg:
        xor     r11,    r11
        cmp     byte[reg1IsNew],    '0'
        je      push_regCodeNotNew
        jne     push_regCodeNew
        push_regCodeNotNew:
            push    regCodeNotNew
            jmp continue_get_reg
        push_regCodeNew:
            push    regCodeNew
            jmp continue_get_reg
        continue_get_reg:
        xor     r11,    r11
        mov     r11,    RM
        push    r11
        call    get_val_from_dict
        mov     r15,    rsi

        xor     r11,    r11
        xor     r11,    indexSizeDect
        push    r11
        xor     r11,    r11
        mov     r11,    opSize
        push    r11
        call    get_val_from_dict

        push    rsi
        push    r15
        call    get_i_th_val
        mov rax,    [rax]
        mov     DWORD[op1],    eax

        call    write_one_op_reg
    
    pop rdx
    pop rbx
    pop rdi
    pop rsi
    pop r11    
    pop r15
    ret
set_two_op_no_imm:
    push    r15
    push    r11
    push    rsi
    push    rdi
    push    rbx
    push    rdx
    
    xor     r11,    r11
    mov     r11,    twoOpNoImDict
    push    r11
    xor     r11,    r11
    mov     r11,    opCode
    push    r11
    call    get_instruction

    push    rsi
    call    set_instruction

    get_is_new_reg:
    cmp byte[need_rex_flag],    1
    jne get_reg2
    mov r11b,   byte[rex_r]
    mov byte[reg2IsNew],    r11b
    get_reg2:
        xor     r11,    r11
        cmp     byte[reg2IsNew],    '0'
        je      push_regCodeNotNew1
        jne     push_regCodeNew1
        push_regCodeNotNew1:
            push    regCodeNotNew
            jmp continue_get_reg1
        push_regCodeNew1:
            push    regCodeNew
            jmp continue_get_reg1
        continue_get_reg1:
        xor     r11,    r11
        mov     r11,    RegOp
        push    r11
        call    get_val_from_dict
        mov     r15,    rsi

        xor     r11,    r11
        xor     r11,    indexSizeDect
        push    r11
        xor     r11,    r11
        mov     r11,    opSize
        push    r11
        call    get_val_from_dict

        push    rsi
        push    r15
        call    get_i_th_val
        mov rax,    [rax]
        mov     DWORD[op2],    eax

    check_reg1_is_new:
        cmp byte[need_rex_flag],    1
        jne get_reg1
        mov r11b,   byte[rex_b]
        mov byte[reg1IsNew],    r11b

    get_reg1:
        xor     r11,    r11
        cmp     byte[reg1IsNew],    '0'
        je      push_regCodeNotNew2
        jne     push_regCodeNew2
        push_regCodeNotNew2:
            push    regCodeNotNew
            jmp continue_get_reg2
        push_regCodeNew2:
            push    regCodeNew
            jmp continue_get_reg2
        continue_get_reg2:
        xor     r11,    r11
        mov     r11,    RM
        push    r11
        call    get_val_from_dict
        mov     r15,    rsi

        xor     r11,    r11
        xor     r11,    indexSizeDect
        push    r11
        xor     r11,    r11
        mov     r11,    opSize
        push    r11
        call    get_val_from_dict

        push    rsi
        push    r15
        call    get_i_th_val
        mov rax,    [rax]
        mov     DWORD[op1],    eax

        call    write_two_op_reg_reg

    pop rdx
    pop rbx
    pop rdi
    pop rsi
    pop r11    
    pop r15
    ret
get_instruction:
    enter   0,  0
    %define dict qword[rbp+24]
    %define code qword[rbp+16]
    push    r11

    xor     r11,    r11
    mov     r11,    dict
    push    r11
    xor     r11,    r11
    mov     r11,    code
    push    r11
    call    get_val_from_dict
    
    pop    r11
   %undef dict
   %undef code
    leave
    ret 16
set_instruction:
    enter   0,  0
    %define name qword[rbp+16]
    mov rax,    name
    push    r11
    push    rax
    mov     r11w,   word[rax]
    mov     word[instruction],   r11w
    cmp     byte[rax+2],    ' '
    je      finish_set_instruction
    cmp     byte[rax+2],    ','
    je      finish_set_instruction
    mov     r11b,   byte[rax+2]
    mov     byte[instruction+2],   r11b
    cmp     byte[rax+3],    ' '
    je      finish_set_instruction
    cmp     byte[rax+3],    ','
    je      finish_set_instruction
    mov     r11b,   byte[rax+3]
    mov     byte[instruction+3],   r11b

    finish_set_instruction:
    pop     rax
    pop    r11
   %undef name
    leave
    ret 8
insert_new_line:
    push    rbx
    push    r8
    push    r9

    xor r8, r8
    xor rbx, rbx
    mov r8, tofilePtr
    mov r8, [r8]
    mov bl,    0xA
    xor r9, r9
    mov r9b, bl
    mov [r8],  r9

    pop     r9
    pop     r8
    pop     rbx
    ret 

insert_tofile:
    push    tofilePtr
    push    len_file
    call    write_str
    mov     [tofilePtr], rax
    ret
insert_space_file:
    push    rbx
    push    r8
    push    r9

    xor r8, r8
    xor rbx, rbx
    mov r8, tofilePtr
    mov r8, [r8]
    mov bl,    ' '
    xor r9, r9
    mov r9b, bl
    mov [r8],  r9

    pop     r9
    pop     r8
    pop     rbx
    ret
insert_comma_file:
    push    rbx
    push    r8
    push    r9

    xor r8, r8
    xor rbx, rbx
    mov r8, tofilePtr
    mov r8, [r8]
    mov bl,    ','
    xor r9, r9
    mov r9b, bl
    mov [r8],  r9

    pop     r9
    pop     r8
    pop     rbx
    ret
write_str:   ; ret new ptr  ;mov to file_ptr from rsi to rdi
    enter   0,  0
    %define file_ptr qword[rbp+24]
    %define len_file qword[rbp+16]
    push    r10
    push    r9
    push    r8
    push    rsi
    
    dec     rsi
    mov     r10,    len_file
    xor r8, r8
    mov r8, file_ptr
    mov r8, [r8]
    loop_write:
        inc rsi
        xor r9, r9
        mov r9b, byte[rsi]
        mov byte[r8],  r9b
        inc r8
        inc qword[r10]
        cmp rsi,    rdi
        jne loop_write
    
    mov rax,  r8
    pop     rsi
    pop     r8
    pop     r9
    pop     r10
    %undef  file_ptr
    %undef  len_file
    leave   
    ret     16
found:
    ;set pointers:
    inc     rsi
    loop_find_last_char:
        inc rdi
        cmp byte[rdi],    ' '
        jne loop_find_last_char
    dec rdi
    mov rax,    1
    jmp     finish_check
not_found:
    loop_find_next_key:
        inc rdi
        cmp byte[rdi], ' '
        jne loop_find_next_key
    inc rdi
    mov rsi,    rdi
    jmp loop_on_dict
not_found_at_all:
    mov rax,    0
    jmp     finish_check

check:
    push    r8
    xor     rcx,rcx
    check_loop:
        cmp rsi,rdi
        je  found
        xor r10,    r10
        mov r10b,   [rbx+rcx]
        mov r8b,     [rsi]
        cmp r8b,  [dollar_sign]
        je  not_found_at_all
        cmp r10b,    [rsi]
        jne not_found
        inc rcx
        inc rsi
        jmp    check_loop
    finish_check:
        pop     r8
        jmp     finish_loop

get_val_from_dict:      ; rsi:address of fisrt char of binary code
                        ; rdi:address of last char of binary code
                        ; rax=0 : not found
                        ; rax=1 : found
    enter   0,  0
    %define dict    qword[rbp+24]
    %define key     qword[rbp+16]
    push    rbx
    push    rdx

    xor     rsi,rsi
    xor     rdi,rdi
    xor     rbx,rbx
    mov rsi,    dict    ;first char
    mov rdi,    dict    ;last char
    mov rbx,    key
    
    loop_on_dict:
        cmp BYTE[rdi],  ':'
        je  check

        cmp BYTE[rdi],  ','
        je  check

        inc rdi
        jmp    loop_on_dict
    finish_loop:
        %undef dict
        %undef key

        pop     rbx
        pop     rdx
        leave

        ret 16


get_index_of_first_spliter_after_ptr: ; ' ', ',','+', '*', ']', ':' 0xA 
    enter   0,  0
    %define ptr     qword[rbp+16]
    xor rax,rax
    mov     rax,    ptr
    loop_get_index_of_first_NL_after_ptr:
        cmp byte [rax],0xA
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],':'
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],'+'
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],'*'
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],']'
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],' '
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],','
        je  finish_loop_get_index_of_first_NL_after_ptr
        cmp byte [rax],''
        je  finish_loop_get_index_of_first_NL_after_ptr
        
        inc rax
        jmp loop_get_index_of_first_NL_after_ptr
    
    finish_loop_get_index_of_first_NL_after_ptr:
        dec rax
        %undef ptr
        leave
        ret 8
union:
    enter   0,  0
    %define first_ptr qword[rbp+24]
    %define second_ptr qword[rbp+16]
    push    rsi
    push    rdi
    push    r8

    mov rsi,    first_ptr
    dec rsi
    loop_on_first_ptr:
        push    rsi
        call    get_index_of_first_spliter_after_ptr
        cmp     byte[rax+1],    ' '
        je      finish_loop_on_first_ptr
        inc     rax
        inc     rax
        mov     rsi,    rax
        reset_second_ptr:
        mov rdi,    second_ptr
        dec rdi    
        loop_on_second_ptr:
            push    rdi
            call    get_index_of_first_spliter_after_ptr
            cmp     byte[rax+1],    ' '
            je      loop_on_first_ptr
            inc     rax
            inc     rax
            mov     rdi,    rax
            mov     r8w, word[rdi]
            cmp     word[rsi],    r8w
            je      finish_loop_on_first_ptr
            jne     loop_on_second_ptr

    finish_loop_on_first_ptr:
        mov     rax,    rdi
        pop     r8
        pop     rdi
        pop     rsi

        %undef first_ptr 
        %undef second_ptr
        leave
        ret 16

print_command:
    push    rsi
    push    rax

    xor     rax,    rax
    mov     rsi,    command
    loop_print_command:
        mov     rax, [rsi]
        call    putc
        cmp     al,  0xA
        je      finish_loop_print_command
        inc     rsi
        jmp     loop_print_command

    finish_loop_print_command:
        pop    rax
        pop    rsi
        ret

handel_last_line:
    mov     byte[r8],   0xA
    ; call    line_assembler
    jmp     write_file
handel_line:
    call    print_command
    call    line_assembler
    mov     r8, command
    jmp     read_machine_code

read_machine_code:
    mov rdi,[FD_source]
    mov rsi,r8
    mov rdx,1
    call readFile

    cmp rax,rdx
    jl handel_last_line
    mov rdi,[FD_source]
    inc r9
    mov rsi,r9
    mov rdx,0
    call seekFile

    cmp byte [r8],0xA
    je handel_line
    inc r8
    jmp read_machine_code

_start:

    call    get_source_file
    mov rax,    tofile
    mov [tofilePtr], rax

    

    mov     rdi,    sourceFileNametest
    call    openFile
    mov     [FD_source],   rax

    mov     r8,    command
    xor     r9,    r9
    jmp     read_machine_code
get_source_file:
    push rdi
    push rsi
    push rdx

    mov rax, sys_read
    mov rdi, stdin
    mov rsi, sourceFileNametest
    mov rdx, 1000
    syscall
    
    push    sourceFileNametest
    call    get_index_of_first_spliter_after_ptr
    mov byte[rax+1],    0
    pop rdx
    pop rsi
    pop rdi
    ret
write_file:
    mov     rdi,    destinationFileName
    call    createFile
    mov     [FD_destination],    rax
    mov     rdi,    [FD_destination]
    mov     rsi,    tofile
    mov     rdx,    [len_file]
    call    writeFile
    call    Exit
line_assembler:
    call reset

    call    check_is_zero_op
    cmp     rax,    1
    je      write_zero_op

    call    parser
    call    set_op_size

    ;check if mem:
    cmp byte[prefix67_flag],    1
    je  call_set_mem
    cmp word[mod],  '11'
    jne call_set_mem
    je  check_0f

    call_set_mem:
        call    set_mem
    
    check_0f:
        cmp byte[has_0f_flag],  1
        je  write_0f

    ; baqiye halat ro handel nakardam
    
    check_two_op_no_imm:
        xor     r11,    r11
        mov     r11,    twoOpNoImDict
        push    r11
        xor     r11,    r11
        mov     r11,    opCode
        push    r11
        call    get_val_from_dict
        cmp     rax,    1
        je      set_two_op_no_imm

    ; check two no imm

    check_one_op:
        xor     r11,    r11
        mov     r11,    oneOpDict
        push    r11
        xor     r11,    r11
        mov     r11,    opCode
        push    r11
        call    get_val_from_dict
        cmp     rax,    1
        je      set_one_op_reg
    
    ret

reset:
    mov byte[rex_w], '0'
    mov byte[rex_r], '0'
    mov byte[rex_x], '0'
    mov byte[rex_b], '0'
    mov qword[instruction], '    '
    mov byte[opCode], 0
    mov byte[opcode_D_S], 0
    mov byte[opcode_W], 0
    mov byte[mod], 0
    mov byte[RegOp], 0
    mov byte[RM], 0
    mov byte[sib_scale], 0
    mov byte[sib_index], 0
    mov byte[sib_base], 0
    mov byte[dsp], 0
    mov byte[data], 0
    mov byte[op1], 0
    mov byte[op2], 0
    mov byte[opSize], 0
    mov byte[regOp_reg], 0
    mov byte[rm_reg], 0
    mov byte[prefix66_flag], 0
    mov byte[prefix67_flag], 0
    mov byte[need_rex_flag], 0
    mov byte[need_sib_flag], 0
    mov byte[has_0f_flag], 0
    mov byte[reg1IsNew], '0'
    mov byte[reg2IsNew], '0'

    ret
Exit:
	mov     rax,    60
    mov     rdi,    0
    syscall

