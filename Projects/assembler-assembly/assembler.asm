%include    "in_out.asm"
%include    "file_in_out.asm"
%include "./sys-equal.asm"

section     .bss
    NewLine         equ     0xA
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000
    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777
    command     resb    100
    instruction resb    10
    helper_resb resb    100

    rex_whole       resb 10

    imm_hex_reverce resb 50
    imm_bin_fixed   resb 50

    memSize         resb 1
    bse             resb 4
    index           resb 4
    scale           resb 3
    addressSize     resb 1  

    sib_ss          resb 2
    sib_inx         resb 3
    sib_bas         resb 3

    mod             resb 2
    regoP_RM        resb 6

    reg1Code        resb 4
    reg1Size        resb 2
    reg1IsNew       resb 2
  
    reg2Code        resb 4
    reg2IsNew       resb 2
    reg2Size        resb 2
  

    tofile1Bin      resb 10000
    tofile2Bin      resb 10000
    tofile1Hex      resb 100000
    tofile2Hex      resb 100000
    tofile1Ptr_f    resq 1
    tofile1Ptr      resq 1
    tofile2Ptr      resq 1
    tofile1HexPtr   resq 1
    tofile2HexPtr   resq 1
    helper_resq_ptr resq 1
    instruction_ptr resq 1

    dsp             resb 100
    dsp_reverce     resb 100
    dsp_fixed       resb 100
    len_dsp         resb 10

    sourceFileName  resb  20

section .data
    
    zeroOpDandOpcodeDict    db  'cld:fc stc:f9 clc:f8 ret:c3 std:fd syscall:f05 $'
    oneOpDandOpcodeDict     db  "inc:1111111 dec:1111111 neg:1111011 not:1111011 idiv:1111011 ret:11000011 imsh:1100000 $"
    regToRegDandOpcodeDict  db  "mov:1000100 add:0000000 adc:0001000 and:0010000 or:0000100 xor:0011000 cmp:0011100 sub:0010100 sbb:0001100 xchg:1000011 test:1000010 xadd:000011111100000 bsf:0000111110111100 bsr:0000111110111101 imul:0000111110101111 $"
    regTomemDandOpcodeDict  db  "mov:1000100 add:0000000 adc:0001000 and:0010000 or:0000100 xor:0011000 cmp:0011101 sub:0010100 sbb:0001100 xchg:1000011 test:1000010 xadd:000011111100000 bsf:0000111110111100 bsr:0000111110111101 imul:0000111110101111 $"
    memToRegDandOpcodeDict  db  "mov:1000101 add:0000001 adc:0001001 and:0010001 or:0000101 xor:0011001 cmp:0011100 sub:0010101 sbb:0001101 xchg:1000011 test:1000010 xadd:000011111100000 bsf:0000111110111100 bsr:0000111110111101 imul:0000111110101111 $"
    immToRegDandOpcodeDict  db     "mov:1011 add:100000 adc:100000 and:100000 or:100000 xor:100000 cmp:100000 sub:100000 sbb:100000 test:111101 $"
    immToMemDandOpcodeDict  db  "mov:1100011 add:100000 adc:100000 and:100000 or:100000 xor:100000 cmp:100000 sub:100000 sbb:100000 test:111101 $"

    ; regDict  'reg name:reg code,bites,is new'
    regDict                 db  "al:000,1,0 ax:000,2,0 eax,000,4,0 rax:000,8,0 cl:001,1,0 cx:001,2,0 ecx:001,4,0 rcx:001,8,0 dl:010,1,0 dx:010,2,0 edx:010,4,0 rdx:010,8,0 bl:011,1,0 bx:011,2,0 ebx:011,4,0 rbx:011,8,0 ah:100,1,0 sp:100,2,0 esp:100,4,0 rsp:100,8,0 ch:101,1,0 bp:101,2,0 ebp:101,4,0 rbp:101,8,0 dh:110,1,0 si:110,2,0 esi:110,4,0 rsi:110,8,0 bh:111,1,0 di:111,2,0 edi:111,4,0 rdi:111,8,0 r8b:000,1,1 r8w,000,2,1 r8d:000,4,1 r8:000,8,1 r9b:001,1,1 r9w,001,2,1 r9d:001,4,1 r9:001,8,1 r10b:010,1,1 r10w:010,2,1 r10d:010,4,1 r10:010,8,1 r11b:011,1,1 r11w:011,2,1 r11d:011,4,1 r11:011,8,1 r12b:100,1,1 r12w:100,2,1 r12d:100,4,1 r12:100,8,1 r13b:101,1,1 r13w:101,2,1 r13d:101,4,1 r13:101,8,1 r14b:110,1,1 r14w:110,2,1 r14d:110,4,1 r14:110,8,1 r15b:111,1,1 r15w:111,2,1 r15d:111,4,1 r15:111,8,1 $" 
    shiftDict               db  "shr:1101000 shl:1101000 shim:1100000 $"
    imToRegDict         db      "add:000 adc:010 sub:101 sbb:011 and:100 or:001 xor:110 cmp:111 shr:101 shl:100 neg:011 not:010 push:110 pop:000 inc:000 dec:001 idiv:111 mov:000 test:000 $"
    scaleDict           db      "1:00 2:01 4:10 8:11 $"
    hexTobinDict        db      "0:0000 1:0001 2:0010 3:0011 4:0100 5:0101 6:0110 7:0111 8:1000 9:1001 a:1010 b:1011 c:1100 d:1101 e:1110 f:1111 $"
    binToHexDict        db      "0000:0 0001:1 0010:2 0011:3 0100:4 0101:5 0110:6 0111:7 1000:8 1001:9 1010:a 1011:b 1100:c 1101:d 1110:e 1111:f $"
    memorySizeDict      db      "BYTE:1 WORD:2 DWORD:4 QWORD:8 $"


    destinationFile1Name db  'assebmler-machine-code-1.txt',0    
    destinationFile2Name db  'assebmler-machine-code-2.txt',0    
    FD_source            dq   0
    FD_destination1      dq   0
    FD_destination2      dq   0
    len_file1_bin        dq   0
    len_file2_bin        dq   0
    len_file1_hex        dq   0
    len_file2_hex        dq   0
    helper_dq            dq   0  ; use as len_file

    imm_hex_len          db   0
    imm_hex_len_fix      db   0

    
    zero                 dq   '0 ', 0
    one                  dq   '1 ', 0
    eleven               dq   '11 '
    new_line             db   0xA
    dollar_sign          db   '$'

    prefix66             db '01100110 ', 0
    prefix67             db '01100111 ', 0
    prefix6766           db '0110011101100110 ', 0

    rex_start            db '0100 '
    rex_w                db '0 '
    rex_r                db '0 '
    rex_x                db '0 '
    rex_b                db '0 '

    mem_to_reg_flag      db 0

    bse_flag             db 0
    index_flag           db 0
    dsp_flag             db 0
    sib_flag             db 0
    
    reg_imm_flag         db 0
    mem_imm_flag         db 0
    shft_reg_flag        db 0
    shft_mem_flag        db 0

    zero0                db   '0', 0
    
section .text
    global  _start

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
    jmp     line_by_line_read

line_assembler:
    call reset
    
    push    r8
    push    rax
    mov     r8,     command
    call    parser
    pop     rax
    pop     r8
    ret

parser:
    push    rsi
    push    rdi
    push    rax
    loop_parser:
    cmp     byte[r8],   ' '  ;space
    je      not_zero_op

    cmp     byte[r8],  0xA  ;no space
    je      zero_op

    xor     rax,    rax
    mov     al,    [r8]
    inc     r8
    jmp     loop_parser
    end_parser:
        pop rax
        pop rdi
        pop rsi

        ret

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

insert_space_file2:
    push    rbx
    push    r8
    push    r9

    xor r8, r8
    xor rbx, rbx
    mov r8, tofile2HexPtr
    mov r8, [r8]
    mov bl,    ' '
    xor r9, r9
    mov r9b, bl
    mov [r8],  r9

    pop     r9
    pop     r8
    pop     rbx
    ret 
insert_NL_file2:
    push    rbx
    push    r8
    push    r9

    xor r8, r8
    xor rbx, rbx
    mov r8, tofile2HexPtr
    mov r8, [r8]
    mov bl,    0xA
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

insert_tofile1:
    push    tofile1Ptr
    push    len_file1_bin
    call    write_str
    mov     [tofile1Ptr], rax
    ret
insert_tofile2:    ;faqat ghesmati az machine code ro ezafe mikone
    push    tofile2Ptr
    push    len_file2_bin
    call    write_str
    mov     [tofile2Ptr], rax
    ret
insert_tofile2_zero_op:  ;yeja kol khat ro mirize
    ;insetr machine code
    push    r11
    push    rsi
    push    rdi
    push    tofile2HexPtr
    push    len_file2_hex
    call    write_str
    mov     [tofile2HexPtr],    rax
    
    ;insetr space
    call    insert_space_file2
    inc     qword[tofile2HexPtr]
    inc     qword[len_file2_hex]
    
    ;insetr assebmly code
    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr
    mov     rdi,    rax
    mov     rsi,    command
    push    tofile2HexPtr
    push    len_file2_hex
    call    write_str
    mov     [tofile2HexPtr],    rax

    ;insetr newLine
    call    insert_NL_file2
    inc     qword[tofile2HexPtr]
    inc     qword[len_file2_hex]

    pop     rdi
    pop     rsi
    pop     r11
    ret

get_index_of_first_spliter_after_ptr: ; ' ', ',','+', '*', ']' 0xA 
    enter   0,  0
    %define ptr     qword[rbp+16]
    xor rax,rax
    mov     rax,    ptr
    loop_get_index_of_first_NL_after_ptr:
        cmp byte [rax],0xA
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
        inc rax
        jmp loop_get_index_of_first_NL_after_ptr
    
    finish_loop_get_index_of_first_NL_after_ptr:
        dec rax
        %undef ptr
        leave
        ret 8

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


get_binary_code_from_dict:   ; rsi:address of fisrt char of binary code
                             ; rdi:address of last char of binary code
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
        pop     rdx
        pop     rbx
        leave

        ret 16
line_by_line_read:
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
    jmp line_by_line_read

set_instruction:
    push    r11

    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr

    mov     rdi,     rax
    mov     rsi,     command

    xor r11,r11
    mov r11,    instruction
    mov [instruction_ptr], r11

    push    instruction_ptr
    push    helper_dq
    call    write_str
    

    pop     r11
    ret


get_regSize:         ; rax: first char of reg size
    push    r11

    mov     r11,    rsi
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax

    pop     r11

    ret
get_regIsNew:       ; rax pointer to 0 or 1
    push    r11
    xor     rax,    rax
    mov     r11,    rsi
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    mov     r11,    rax
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax

    pop     r11

    ret

get_prefix:                 ; rsi:address of fisrt char of binary code
                            ; rdi:address of last char of binary code
                            ; there is a prefix:rax=1   ow:rax=0 
    ; r15 address(mem)==4 : 67
    ; r14 op(reg) or memSize(mem) ==2 : 66   
    
    enter   0,  0
    %define opSize      qword[rbp+24]    ;if there is no op pass zero
    %define addressSize qword[rbp+16]    ;if there is no mem pass zero
    push r14
    push r15
    
    mov r14,    opSize
    mov r15,    addressSize

    ; 66:
    cmp byte[r15],  '4'
    jne not_prefix_67

    cmp byte[r14],  '2'
    jne set_prefix_67
    je  set_prefix_67_66
    
    not_prefix_67:
    cmp byte[r14],  '2'
    je set_prefix_66
    jne not_prefix_67_66
    
    not_prefix_67_66:
        mov rax,0
        pop r15
        pop r14
        jmp finish_get_prefix

    set_prefix_67:
        mov rsi,    prefix67
        xor     r14,    r14
        mov     r14,    prefix67
        jmp set_prefix
    set_prefix_66:
        mov rsi,    prefix66
        xor     r14,    r14
        mov     r14,    prefix66
        jmp set_prefix

    set_prefix_67_66:
        mov rsi,    prefix6766
        xor     r14,    r14
        mov     r14,    prefix6766
        jmp set_prefix

    set_prefix:
        push    r14
        call    get_index_of_first_spliter_after_ptr
        mov     rdi,    rax
        xor rax,    rax
        mov rax,    1
        jmp finish_get_prefix

    finish_get_prefix:
        %undef  opSize
        %undef  addressSize 
        leave
        ret 16

get_code_w:
    enter   0,  0
    %define opSize      qword[rbp+16]
    push r14
    
    mov r14,    opSize
    cmp byte[r14],  '2'
    jge     mov_one
    mov_zero:
        mov     rsi,    zero
        mov     rdi,    zero
        jmp     end_of_get_code_w
    mov_one:
        mov     rsi,    one
        mov     rdi,    one
    end_of_get_code_w:
    %define opSize      qword[rbp+16]
    pop r14
    leave
    ret 8

need_rex_reg:
    ; if int(reg1.isNew) or reg1.numOfBit == 64 :
    ;     return True
    xor     rax,    rax

    cmp     byte[reg1Size], 0xA
    je      call_get_regSize_in_need_rex_reg
    mov     rax,    reg1Size
    jmp     continue_need_rex_reg
    call_get_regSize_in_need_rex_reg:
    call    get_regSize  ;input parametr: ptr to reg in regSize dict
    
    continue_need_rex_reg:
    cmp     byte[rax],    '8'
    je  end_of_need_rex_reg

    call    get_regIsNew
    cmp     byte[rax],    '1'
    je  end_of_need_rex_reg
    mov rax,    0
    ret

    end_of_need_rex_reg:
        mov     rax,    1
        ret
need_rex_reg_imm:
    ; if int(reg1.isNew) or reg1.numOfBit == 64 :
    ;     return True

    xor rax,    rax
    mov rax,    reg1Size
    cmp     byte[rax],    '8'
    je  end_of_need_rex_reg_imm

    call    get_regIsNew
    cmp     byte[rax],    '1'
    je  end_of_need_rex_reg_imm
    mov rax,    0
    ret

    end_of_need_rex_reg_imm:
        mov     rax,    1
        ret
need_rex_mem:
    push    r11
    mov rax,    1
    cmp byte[memSize],  8
    je finish_need_rex_mem
    ;     if mem.memSize == 'QWORD' :
    ;         return True

    cmp byte[bse_flag], 1
    jne next_check
        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        xor     r11,    r11
        mov     r11,    bse
        push    r11
        call    get_binary_code_from_dict
        
        mov     r11,    rsi
        call    get_regIsNew
        cmp     byte[rax],    '1'
        je      finish_need_rex_mem

    ;     if mem.bse :
    ;         if int(mem.bse.isNew)  :
    ;             return True
    next_check:
    cmp byte[index_flag], 1
    jne no_need_rex

        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        xor     r11,    r11
        mov     r11,    index
        push    r11
        call    get_binary_code_from_dict
        
        mov     r11,    rsi
        call    get_regIsNew
        cmp     byte[rax],    '1'
        je      finish_need_rex_mem

    ;     if mem.index:
    ;         if int(mem.index.isNew):
    ;             return True
    ; return False
    no_need_rex:
    mov rax,    0
    finish_need_rex_mem:
    pop r11
    ret
need_rex_reg_reg:
    mov rax,    1
    cmp byte[reg1IsNew],    '1'
    je  finish_need_rex_reg_reg

    cmp byte[reg1Size],    '8'
    je  finish_need_rex_reg_reg

    cmp byte[reg2IsNew],    '1'
    je  finish_need_rex_reg_reg

    cmp byte[reg2Size],    '8'
    je  finish_need_rex_reg_reg

    mov rax,    0
    finish_need_rex_reg_reg:
    ret
need_rex_reg_mem:
    mov rax,    1
    cmp byte[reg1IsNew],   '1'
    je  finish_need_rex_reg_mem

    cmp byte[reg1Size],    '8'
    je  finish_need_rex_reg_mem

    cmp byte[memSize],     '8'
    je  finish_need_rex_reg_mem

    cmp byte[bse_flag],     1
    jne  check_index
    
    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    bse
    push    r11
    call    get_binary_code_from_dict
    call    get_regIsNew
    cmp     byte[rax],  '1'
    je      finish_need_rex_reg_mem
    
    ;     if mem.bse :
    ;         if int(mem.bse.isNew)  :
    ;             return True
    
    check_index:
    cmp byte[index_flag],     1
    jne  finish_need_rex_reg_mem_no_rex
    
    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    index
    push    r11
    call    get_binary_code_from_dict
    call    get_regIsNew
    cmp     byte[rax],  '1'
    je      finish_need_rex_reg_mem
    
    ;     if mem.index:
    ;         if int(mem.index.isNew):
    ;             return True
    finish_need_rex_reg_mem_no_rex:
    mov rax,    0
    finish_need_rex_reg_mem:
    ret

set_whole_rex_reg:
    push    r10
    call    need_rex_reg
    cmp     rax,    0
    je      finish_get_rex_reg
    ; self.b = reg1.isNew
    ; self.w = get_rex_w(reg1 ,mem)
    xor     rax,    rax

    cmp     byte[reg1IsNew], 0xA
    je      call_get_regisNew_in_need_rex_reg
    mov     rax,    reg1IsNew
    jmp     continue_need_rex_reg2
    call_get_regisNew_in_need_rex_reg:
    call    get_regIsNew  ;input parametr: ptr to reg in regSize dict
    
    continue_need_rex_reg2:

    xor     r10,    r10
    mov     r10b,    byte[rax]
    mov     byte[rex_b],    r10b
    
    call    get_rex_w_reg
    call    set_rex_whole_ptr
    mov     rax,    1
    finish_get_rex_reg:
         pop    r10
        ret
set_whole_rex_reg_imm:
    push    r10
    call    need_rex_reg_imm
    cmp     rax,    0
    je      finish_get_rex_reg_imm
    ; self.b = reg1.isNew
    ; self.w = get_rex_w(reg1 ,mem)
    mov     r10b,    byte[reg1IsNew]
    mov     byte[rex_b],    r10b
    
    call    get_rex_w_reg_imm
    call    set_rex_whole_ptr
    mov     rax,    1
    finish_get_rex_reg_imm:
         pop    r10
        ret
set_whole_rex_mem:
    push    r11
    push    r10
    ; push    rax

    call    need_rex_mem
    push    rax
    cmp     rax,    0
    je      finish_get_rex_mem

    call    get_rex_w_mem
    ;     ; self.w = get_rex_w(reg1 ,mem)

    ; set_rex_b:
    cmp     byte[bse_flag], 1
    jne     set_rex_x

    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    bse
    push    r11
    call    get_binary_code_from_dict
    
    mov     r11,    rsi
    call    get_regIsNew
    mov     r10b,    byte[rax]
    mov     byte[rex_b],    r10b
  

    ;         if mem.bse :
    ;             self.b = mem.bse.isNew
    set_rex_x:
    cmp     byte[index_flag], 1
    jne     finish_get_rex_mem

    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    index
    push    r11
    call    get_binary_code_from_dict
    
    mov     r11,    rsi
    call    get_regIsNew
    mov     r10b,    byte[rax]
    mov     byte[rex_x],    r10b

        ;     if mem.index:
        ;            self.x = mem.index.isNew
    finish_get_rex_mem:
    call    set_rex_whole_ptr
    pop rax
    pop r10
    pop r11
    ret

set_whole_rex_reg_reg:
    push    r11
    push    r10
    call    need_rex_reg_reg
    cmp     rax,    0
    je      finish_get_rex_reg_reg
    cmp dword[instruction], 'imul'
    je  set_whole_rex_reg_reg_imul
    mov r11b,       byte[reg2IsNew]
    mov byte[rex_r],    r11b
    mov r11b,       byte[reg1IsNew]
    mov byte[rex_b],    r11b

    cmp byte[reg1Size], '8'
    jne finish_get_rex_reg_reg
    mov byte[rex_w],    '1'

    jmp finish_get_rex_reg_reg


    set_whole_rex_reg_reg_imul:
        mov r11b,       byte[reg1IsNew]
        mov byte[rex_r],    r11b
        mov r11b,       byte[reg2IsNew]
        mov byte[rex_b],    r11b

        cmp byte[reg2Size], '8'
        jne finish_get_rex_reg_reg
        mov byte[rex_w],    '1'



    finish_get_rex_reg_reg:
    call    set_rex_whole_ptr
    pop r10
    pop r11
    ret
set_whole_rex_reg_mem:
    push    r11
    push    r10
    call    need_rex_reg_mem
    cmp     rax,    0
    je      finish_get_rex_reg_mem

        ;      self.r = reg1.isNew
    mov     r10b,    byte[reg1IsNew]
    mov     byte[rex_r],    r10b
    
        ;      self.b = mem.bse.isNew
    cmp     byte[bse_flag], 1
    jne     set_rex_x_reg_mem

    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    bse
    push    r11
    call    get_binary_code_from_dict
    
    mov     r11,    rsi
    call    get_regIsNew
    mov     r10b,    byte[rax]
    mov     byte[rex_b],    r10b

        ;      self.x = mem.index.isNew
    set_rex_x_reg_mem:            
    cmp     byte[index_flag], 1
    jne     finish_get_rex_reg_mem

    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    index
    push    r11
    call    get_binary_code_from_dict
    
    mov     r11,    rsi
    call    get_regIsNew
    mov     r10b,    byte[rax]
    mov     byte[rex_x],    r10b


    finish_get_rex_reg_mem:
    call get_rex_w_reg_mem
    ;  self.w = get_rex_w(reg1 ,mem)
    call    set_rex_whole_ptr
    pop r10
    pop r11
    ret
set_rex_whole_ptr:
    push    r15
    ; self.start + self.w + self.r + self.x + self.b
    mov     rdi,    rex_whole
    
    mov     rsi,    rex_start
    mov     r15d,    DWORD[rsi]
    mov     DWORD[rdi],  r15d
    add     rdi,4

    mov     rsi,    rex_w
    mov     r15b,    byte[rsi]
    mov     byte[rdi],  r15b
    inc     rdi

    mov     rsi,    rex_r
    mov     r15b,    byte[rsi]
    mov     byte[rdi],  r15b
    inc     rdi

    mov     rsi,    rex_x
    mov     r15b,    byte[rsi]
    mov     byte[rdi],  r15b
    inc     rdi
    
    mov     rsi,    rex_b
    mov     r15b,    byte[rsi]
    mov     byte[rdi],  r15b

    mov     rsi,    rex_whole

    pop     r15
    ret


get_rex_w_reg_mem:
    ; if op :
    ;     if op.numOfBit < 64  :
    ;         return '0 '
    ; elif mem:
    ;     if memorySize[mem.memSize] <= 32  :
    ;         return '0 '
    ; return '1 '

    cmp byte[reg1Size],  '8'
    jne finish_get_rex_w_reg_mem
        
    cmp byte[memSize],  '4'
    jle finish_get_rex_w_reg_mem
    mov   byte[rex_w],    '1'

    mov byte[rex_w],    '1'
    finish_get_rex_w_reg_mem:
        ret

get_rex_w_reg:
    cmp     byte[reg1Size], 0xA
    je      call_get_regSize_in_get_rex_w_reg
    mov     rax,    reg1Size
    jmp     continue_get_rex_w_reg
    call_get_regSize_in_get_rex_w_reg:
    call    get_regSize  ;input parametr: ptr to reg in regSize dict

    continue_get_rex_w_reg:
    cmp byte[rax],  '8'
    jne finish_get_rex_w_reg
    mov byte[rex_w],    '1'
    ;   if op :
    ;     if op.numOfBit < 64  :
    ;         return '0 '
    finish_get_rex_w_reg:
        ret
get_rex_w_reg_imm:
    cmp byte[reg1Size],  '8'
    jne finish_get_rex_w_reg_imm
    mov byte[rex_w],    '1'
    ;   if op :
    ;     if op.numOfBit < 64  :
    ;         return '0 '
    finish_get_rex_w_reg_imm:
        ret
        
get_rex_w_mem:
    cmp byte[memSize],  '4'
    jle finish_get_rex_w_mem
    mov   byte[rex_w],    '1'
    ; if memorySize[mem.memSize] <= 32  :
    ;         return '0 '
    ; return '1 '
    finish_get_rex_w_mem:
    ret


set_mem_parts:
    push    r12
    push    r11
    push    rsi
    push    rdi

    set_memSize:
        push    command
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        mov     rsi,    rax ;ptr to mem(qword,.., byte)

        xor     r11,    r11
        mov     r11,    memorySizeDict
        push    r11
        mov     r11,    rsi
        mov     r12,    rsi
        push    r11
        call    get_binary_code_from_dict
        cmp     rax,    1
        je      setting_memSize
        
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        mov     rsi,    rax ;ptr to mem(qword,.., byte)

        xor     r11,    r11
        mov     r11,    memorySizeDict
        push    r11
        mov     r11,    rsi
        mov     r12,    rsi
        push    r11
        call    get_binary_code_from_dict
        
        setting_memSize:
        mov     r11b,    byte[rsi]
        mov     byte[memSize],  r11b
        
        mov     rsi,    r12

    skip_PTR:
        push    rsi
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        mov     rsi,    rax 

    ;set [bse+index*scale+dsp]
    inc     rsi                 ; skip [
    mov     rdi,    rsi
    cmp     byte[rdi],   '0'
    je      set_dsp_not_fit             ; just dsp

    push    rdi
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    cmp     byte[rax],  '*'
    je      set_index           ; start with index

    set_bse:
        mov     byte[bse_flag],   1
        push    rsi
        call    get_index_of_first_spliter_after_ptr
        mov     rdi,    rax

        mov     r12,    bse
        mov     [helper_resq_ptr],  r12
        push    helper_resq_ptr
        push    helper_dq
        call    write_str    


        inc     rdi
        cmp     byte[rdi],  ']'
        je      set_addressSize ; just base

        inc     rdi
        mov     rsi,    rdi
        cmp     byte[rdi],  '0'
        je      set_dsp_not_fit              ; just base and dsp

    set_index:
        mov     byte[index_flag],   1
        push    rsi
        call    get_index_of_first_spliter_after_ptr
        mov     rdi,    rax

        mov     r12,    index
        mov     [helper_resq_ptr],  r12
        push    helper_resq_ptr
        push    helper_dq
        call    write_str  

    set_scale:
        inc     rdi
        inc     rdi
        mov     r12b,    byte[rdi]
        ; mov     [scale],    r12b
        
        push    rsi
        push    rdi

        xor     r11,    r11
        mov     r11,    scaleDict
        push    r11
        xor     r11,    r11
        mov     r11,    rdi
        push    r11
        call    get_binary_code_from_dict
        
        xor     r12,    r12
        xor     r11,    r11
        mov     r11b,    byte[rsi]
        mov     r12,    scale
        mov     [r12],    r11b
        mov     r11b,    byte[rsi+1]
        mov     byte[r12+1],    r11b
        

        pop rdi
        pop rsi

        inc     rdi
        cmp     byte[rdi],  ']'
        je      set_addressSize ; just base
        mov     rsi,    rdi
        inc     rsi

    set_dsp_not_fit:
        inc rsi       ; skip 0
        inc rsi       ; skip 1
        ; xor r12,    r12
        ; mov r12,    dsp
        mov     byte[dsp_flag],   1
        push    rsi
        call    get_index_of_first_spliter_after_ptr
        mov rdi,    rax
        
        mov     r12,    dsp
        mov     [helper_resq_ptr],  r12
        push    helper_resq_ptr
        push    helper_dq
        call    write_str
        mov     byte[rax], ' '

    set_addressSize:
        mov     byte[addressSize],  '0'

        cmp     byte[bse_flag],   1
        jne     set_addressSize_check_index

        cmp     byte[index_flag],   1
        jne     set_bse_as_addressSize
    
        ;we have both bse and index
        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        xor     r11,    r11
        mov     r11,    bse
        push    r11
        call    get_binary_code_from_dict
        call    get_regSize
        mov     r12b,    byte[rax]

        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        xor     r11,    r11
        mov     r11,    index
        push    r11
        call    get_binary_code_from_dict
        call    get_regSize
        mov     r11b,    byte[rax]
        
        cmp     r11b,r12b
        jge     r11islarger
        mov     byte[addressSize],  r12b
        jmp     finish_set_mem_parts
        r11islarger:
            mov     byte[addressSize],  r11b

        jmp     finish_set_mem_parts
        set_addressSize_check_index:
        cmp     byte[index_flag],   1
        jne     finish_set_mem_parts
        
        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        xor     r11,    r11
        mov     r11,    index
        push    r11
        call    get_binary_code_from_dict
        call    get_regSize
        mov     r11b,    byte[rax]
        mov     byte[addressSize],  r11b

        jmp     finish_set_mem_parts

        set_bse_as_addressSize:
        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        xor     r11,    r11
        mov     r11,    bse
        push    r11
        call    get_binary_code_from_dict
        call    get_regSize
        mov     r11b,    byte[rax]
        mov     byte[addressSize],  r11b


        jmp     finish_set_mem_parts

    finish_set_mem_parts:
        pop     rdi
        pop     rsi
        pop     r11
        pop     r12

        ret


set_reg_reg_parts:
    enter   0,0          ;name-code-size-isNew
    %define reg1 qword[rbp+24]
    %define reg2 qword[rbp+16]
    push    r8
    push    rsi
    push    rdi

    mov     r8,    reg1
    xor     r12,    r12
    mov     r12,    regDict
    push    r12
    push    r8
    call    get_binary_code_from_dict

    mov     r8w, word[rsi]
    mov     word[reg1Code], r8w
    mov     r8b, byte[rsi+2]
    mov     byte[reg1Code+2], r8b

    mov     r8b, byte[rsi+4]
    mov     byte[reg1Size], r8b

    mov     r8b, byte[rsi+6]
    mov     byte[reg1IsNew], r8b


    mov     r8,    reg2
    xor     r12,    r12
    mov     r12,    regDict
    push    r12
    push    r8
    call    get_binary_code_from_dict

    mov     r8w, word[rsi]
    mov     word[reg2Code], r8w
    mov     r8b, byte[rsi+2]
    mov     byte[reg2Code+2], r8b

    mov     r8b, byte[rsi+4]
    mov     byte[reg2Size], r8b

    mov     r8b, byte[rsi+6]
    mov     byte[reg2IsNew], r8b



    pop    rdi
    pop    rsi
    pop    r8
    %undef reg1
    %undef reg2
    leave
    ret 16
set_reg_parts:   ; command: instruction reg,mem
                 ;          instruction mem,reg
                 ;          instruction reg,imm
     enter   0,0          ;name-code-size-isNew
    push    r11
    push    r8
    push    r9
    push    rsi


    xor     r8, r8
    xor     r8, command
    push    r8                                      
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    mov     rsi,    rax 


    mov     r9,    rsi
    xor     r12,    r12
    mov     r12,    regDict
    push    r12
    push    r9
    call    get_binary_code_from_dict
    cmp     rax,    1
    je      set_first_part_reg

    loop_skip_till_finish_mem_:
        inc     r9

        xor     r11,    r11
        mov     r11,    r9
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        mov     r9,    rax
        cmp     byte[r9],  ']'
        jne     loop_skip_till_finish_mem_

    push    r9
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    inc     rax
    mov     rsi,    rax 

    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    mov     r11,    rsi
    mov     r12,    rsi
    push    r11
    call    get_binary_code_from_dict
    

    set_first_part_reg:
    mov     r8w, word[rsi]
    mov     word[reg1Code], r8w
    mov     r8b, byte[rsi+2]
    mov     byte[reg1Code+2], r8b

    mov     r8b, byte[rsi+4]
    mov     byte[reg1Size], r8b

    mov     r8b, byte[rsi+6]
    mov     byte[reg1IsNew], r8b

    pop    rsi
    pop    r9
    pop    r8
    pop    r11
    leave
    ret
get_dsp_len: ; ret rax
    push    r8
    push    r11
    push    r14
    push    rcx

    mov     r14,    32
    mov     r8,     8
    xor     r11,    r11
    mov     rax,    0

    cmp     byte[bse_flag],   0
    cmove   rax,    r14
    je      check_memDsp

    push    rax

    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    bse
    push    r11
    call    get_binary_code_from_dict
    mov r8, 8
    pop     rax
    cmp     WORD[rsi],  '10'
    jne     check_memDsp
    cmp     byte[rsi+2],'1'
    jne     check_memDsp
    mov     rax,    8


    ; if mem.dsp != None and lenn != 32 :
    ;     l = (len(mem.dsp)-2)*4
    ;     if l <= 8:
    ;         lenn = 8
    ;     elif l <= 32:
    ;         lenn = 32
    ;     elif l <= 64:
    ;         lenn = 64
    ; return lenn



    check_memDsp:
    cmp byte[dsp_flag],   1
    jne finish_get_dsp_len    
    cmp rax,    32
    je finish_get_dsp_len

    ; cal num of bits of dsp
    xor     r11,    r11
    mov     r11,    dsp
    xor     rcx,    rcx
    dec     rcx
    loop_get_dsp_len:
        inc rcx
        cmp byte[r11+rcx],  ' '
        jne loop_get_dsp_len
    imul    rcx,    4
    cmp rcx,    32
    cmovle      rax,    r14
    cmp rcx,    8
    cmovle      rax,    r8


    finish_get_dsp_len:
    mov [len_dsp],   rax
    pop rcx
    pop r14
    pop r11
    pop r8
    ret


hex_to_bin:
    enter   0,  0
    %define source      qword[rbp+32]
    %define destination qword[rbp+24]
    %define len         qword[rbp+16]
    push    rsi
    push    rdi
    push    rcx
    push    rdx
    push    r13
    push    r8

    mov rsi,    source
    xor rdx,    rdx  ; source len
    dec rdx
    loop_hex_to_bin:
        inc     rdx
        cmp     byte[rsi+rdx],  ""
        je      continue_hex_to_bin_for_imm  
        cmp     byte[rsi+rdx],  0xA
        je      continue_hex_to_bin  
        cmp     byte[rsi+rdx],  ' '
        jne     loop_hex_to_bin
        je      continue_hex_to_bin
    
    continue_hex_to_bin_for_imm:
    dec     rdx
    continue_hex_to_bin:

    imul    rdx,4
    mov rcx,    len
    sub rcx,    rdx
    
    mov r13,    destination
    push    rcx
    dec r13
    cmp rcx,    0
    je finish_loop_set_zero
    loop_set_zero:
        mov     byte[r13+rcx],  '0'
        loop    loop_set_zero
    finish_loop_set_zero:
    inc r13
    pop     rcx
    add     r13,    rcx
    mov     [helper_resq_ptr],  r13
    loop_set_real_dsp:

    push    rsi
    push    rdi

    xor     r11,    r11
    mov     r11,    hexTobinDict
    push    r11
    xor     r11,    r11
    mov     r11,    rsi
    push    r11
    call    get_binary_code_from_dict


    push    helper_resq_ptr
    push    helper_dq
    call    write_str
    mov     [helper_resq_ptr], rax

    pop    rdi
    pop    rsi

        
        ; mov byte[rdi],    r8b
        inc rsi
        cmp byte[rsi+1],  ""
        je  finish_loop_set_real_dsp
        cmp byte[rsi],  ' '
        jne loop_set_real_dsp
    
    finish_loop_set_real_dsp:

    ; raqam ha baAx
    mov rcx,    qword[len_dsp]
    shr    rcx,    3 ; rcx /= 8
    mov r8, rcx
    mov rdx,    dsp_fixed
    
    loop_reverse_hex:
    dec r8
    xor r13,    r13
    xor r9, r9
    mov r9, destination
    mov r13,   qword[r9+r8*8]
    mov qword[rdx], r13
    add rdx,  8
    loop    loop_reverse_hex

    pop r8
    pop r13
    pop rdx
    pop rcx
    pop rdi
    pop rsi
    
    %undef source      
    %undef destination 
    %undef len         
    leave
    ret 24

bin_to_hex:
    push    rsi
    push    rdi

    loop_bin_to_hex:
        xor rsi,    rsi
        mov rsi,    tofile1Ptr_f
        mov rsi,    [rsi]
        
        mov     r11,    binToHexDict
        push    r11
        xor     r11,    r11
        mov     r11,    rsi
        push    r11
        call    get_binary_code_from_dict
    
        push    tofile1HexPtr
        push    len_file1_hex
        call    write_str
        mov     [tofile1HexPtr], rax
  
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr], rax
        
        add qword[tofile1Ptr_f], 4
        ; inc qword[tofile2HexPtr]
        mov r11,    qword[tofile1Ptr]
        cmp qword[tofile1Ptr_f],   r11
        jne loop_bin_to_hex

    pop rdi
    pop rsi
    ret


decimal_str_to_bin_fix:   ;write on imm_bin_fixed - rax:last char
    enter   0,  0
    %define decimal_str qword[rbp+16]
    push    rcx
    push    rdx
    push    rsi
    push    r8

    mov     r8, 7

    push    qword decimal_str
    call    decimal_str_to_decimal_digit   ;ret rax
    mov     rdx,    rax
    mov     rsi,    imm_bin_fixed
    
    xor rcx,    rcx
    bsr rcx,    rdx  ; index ba arzesh tarin 1
    
    loop_write_zero:
    cmp r8, rcx
    je  loop_write_bin_on_imm_bin_fixed
    mov byte[rsi],  '0'
    inc rsi
    dec r8
    jmp loop_write_zero

    loop_write_bin_on_imm_bin_fixed:
    bt  rdx,    rcx
    jc   mov_1  
    jnc  mov_0
    continue_loop_write_bin_on_imm_bin_fixed:
    dec     rcx
    inc     rsi
    cmp     rcx,    -1
    jne     loop_write_bin_on_imm_bin_fixed
    jmp     finish_loop_write_bin_on_imm_bin_fixed

    mov_1:
    mov byte[rsi],  '1'
    jmp continue_loop_write_bin_on_imm_bin_fixed
    mov_0:
    mov byte[rsi],  '0'
    jmp continue_loop_write_bin_on_imm_bin_fixed

    finish_loop_write_bin_on_imm_bin_fixed:
    mov     rax,    rsi

    pop     r8
    pop     rsi
    pop     rdx
    pop     rcx
    %undef decimal_str
    leave
    ret 8

decimal_str_to_decimal_digit:
    enter   0,  0
    %define decimal_str qword[rbp+16]
    push    r8

    xor     r8,     r8
    mov     r8,     decimal_str
    xor     rax,    rax
    loop_decimal_to_bin:
        cmp byte[r8],  '0'
        jne check_1
        add rax,    0
        jmp finish_digit
        check_1:
        cmp byte[r8],  '1'
        jne check_2
        add rax,    1
        jmp finish_digit
        check_2:
        cmp byte[r8],  '2'
        jne check_3
        add rax,    2
        jmp finish_digit
        check_3:        
        cmp byte[r8],  '3'
        jne check_4
        add rax,    3
        jmp finish_digit
        check_4:        
        cmp byte[r8],  '4'
        jne check_5
        add rax,    4
        jmp finish_digit
        check_5:        
        cmp byte[r8],  '5'
        jne check_6
        add rax,    5
        jmp finish_digit
        check_6:        
        cmp byte[r8],  '6'
        jne check_7
        add rax,    6
        jmp finish_digit
        check_7:        
        cmp byte[r8],  '7'
        jne check_8
        add rax,    7
        jmp finish_digit
        check_8:        
        cmp byte[r8],  '8'
        jne check_9
        add rax,    8
        jmp finish_digit
        check_9:        
        cmp byte[r8],  '9'
        jne finish_decimal_to_bin_loop
        add rax,    9
        
        finish_digit:
        imul rax,   10
        inc r8
        jmp loop_decimal_to_bin

    finish_decimal_to_bin_loop:
    xor rdx,    rdx
    mov r8,     10
    div r8
    pop r8
    %undef decimal_str
    leave
    ret 8


set_dsp_fit:
    push    r8
    call    get_dsp_len
    cmp     rax,0
    je      finish_set_dsp_fit
    xor     r8,r8
    mov     r8, dsp
    cmp     byte[dsp_flag], 0
    je      zero_dsp
    jne     not_zero_dsp

    zero_dsp:
    mov     byte[dsp_flag], 1
    push    zero
    push    dsp_reverce
    push    rax
    call    hex_to_bin
    jmp     finish_set_dsp_fit

    not_zero_dsp:
    push    r8
    push    dsp_reverce
    push    rax
    call    hex_to_bin
    jmp finish_set_dsp_fit

    finish_set_dsp_fit:
    pop r8
    ret


get_imm_len_fix:    ; if called by shtf: decimal
                    ; if called by reg-imm pr mem-imm: hex
    push    r9
    push    r14

    mov r14,    4
    ; if int(binary,2) <= int('11111111',2):
    ;     lenn = 8    
    mov byte[imm_hex_len_fix],  1
    cmp byte[imm_hex_len],  2
    jle finish_get_imm_len_fix
    
    ; elif mem:
    ;     lenn = memSize[mem.memSize]
    cmp byte[mem_imm_flag], 1
    jne is_reg_imm
    xor r9, r9
    mov r9b ,   byte[memSize]
    mov [imm_hex_len_fix],  r9

    ; elif reg:
    ;         lenn = reg.numOfBit
    is_reg_imm:    
    cmp byte[reg_imm_flag], 1
    jne else
    xor r9, r9
    mov r9b, byte[reg1Size]
    mov byte[imm_hex_len_fix],  r9b
    jmp finish_get_imm_len_fix
    
    ; else :
    ;     lenn = 32
    else:
    mov [imm_hex_len_fix],  r14

    finish_get_imm_len_fix:
    pop r14
    pop r9
    ret

set_imm_fit:      ; if called by reg-imm pr mem-imm: hex
    push    r11
    push    r12
    push    r14
    push    r8

    mov     r11,    8 ; 1
    mov     r12,    16; 2
    mov     r14,    32; 4
    mov     r8,     64; 8


    call    get_imm_len_fix         ; imm_hex_len_fix

    ; to bin:
    ; %define source      qword[rbp+32]
    ; %define destination qword[rbp+24]
    ; %define len         qword[rbp+16]
    push    qword imm_hex_reverce
    push    qword imm_bin_fixed
    
    cmp     byte[imm_hex_len_fix],  '1'
    jne     check_is_2
    mov     byte[imm_hex_len_fix],  1
    push    r11
    jmp     call_hex_to_bin
    check_is_2:
    cmp     byte[imm_hex_len_fix],  '2'
    jne     check_is_4
    mov     qword[imm_hex_len_fix],  2
    push    r12
    jmp     call_hex_to_bin
    check_is_4:
    cmp     byte[imm_hex_len_fix],  '4'
    jne     check_is_8
    mov     byte[imm_hex_len_fix],  4
    push    r14
    jmp     call_hex_to_bin
    check_is_8:
    cmp     byte[imm_hex_len_fix],  '8'
    jne     is_int
    mov     byte[imm_hex_len_fix],  8
    push    r8
    jmp     call_hex_to_bin
    is_int:
    xor     r8, r8
    mov     r8b, byte[imm_hex_len_fix]
    imul    r8, 8
    push    r8
    call_hex_to_bin:
    mov r8b,    byte[imm_hex_len_fix]
    shl r8b,  3
    mov        [len_dsp],r8b
    call    hex_to_bin

    pop    r8
    pop    r14
    pop    r12
    pop    r11

    ret

set_imm:
    push    r11
    push    rcx

    xor     rcx,    rcx
    xor     rax,    rax
    mov     rax,    command
    dec     rax
    loop_find_first_char_of_imm:
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        cmp     byte[rax],    ','
        jne     loop_find_first_char_of_imm

    inc     rax
    inc     rax  ;ignore 0x
    inc     rax
    
    loop_wtire_imm_on_imm_hex:
        mov     r11b,       byte[rax]
        mov     byte[imm_hex_reverce+rcx],  r11b
        inc     rcx
        inc     rax
        cmp     byte[rax],  ""
        jne     loop_wtire_imm_on_imm_hex


    dec     rcx
    mov     byte[imm_hex_len],  cl

    pop     rcx
    pop     r11
    ret

set_sib_mem:
    push    r8
    push    rsi
    push    rdi
    xor     r8, r8
    mov byte[sib_flag],   0
    cmp byte[dsp_flag],   0
    jne chech_second
    cmp byte[index_flag], 0
    je finish_set_sib

    chech_second:
    cmp byte[dsp_flag],   0
    je  has_sib
    cmp byte[index_flag], 0
    jne  has_sib
    cmp byte[bse_flag],   0
    jne  finish_set_sib

    has_sib:
    mov byte[sib_flag],   1

    ; set defult values
    mov byte[sib_ss],   '0'
    mov byte[sib_ss+1], '0'

    mov byte[sib_inx],   '1'
    mov byte[sib_inx+1], '0'
    mov byte[sib_inx+2], '0'
    
    mov byte[sib_bas],   '1'
    mov byte[sib_bas+1], '0'
    mov byte[sib_bas+2], '1'

    set_ss_inx:
    ; set ss:
    cmp byte[index_flag],   1
    jne  set_bas

    mov r8b,byte [scale]
    mov byte[sib_ss],   r8b
    mov r8b, byte[scale+1]
    mov byte[sib_ss+1], r8b
    
    ; set inx:
    xor     r8,    r8
    mov     r8,    regDict
    push    r8
    xor     r8,    r8
    mov     r8,    index
    push    r8    
    call    get_binary_code_from_dict

    mov r8b,byte [rsi]
    mov byte[sib_inx],   r8b
    mov r8b, byte[rsi+1]
    mov byte[sib_inx+1], r8b
    mov r8b, byte[rsi+2]
    mov byte[sib_inx+2], r8b
    
    set_bas:
    cmp byte[bse_flag],   1
    jne  finish_set_sib

    xor     r8,    r8
    mov     r8,    regDict
    push    r8
    xor     r8,    r8
    mov     r8,    bse
    push    r8    
    call    get_binary_code_from_dict

    mov r8b,byte [rsi]
    mov byte[sib_bas],   r8b
    mov r8b, byte[rsi+1]
    mov byte[sib_bas+1], r8b
    mov r8b, byte[rsi+2]
    mov byte[sib_bas+2], r8b
    

    finish_set_sib:
    pop rdi
    pop rsi
    pop r8
    ret
set_sib_reg_mem:
    push    r8
    push    rsi
    push    rdi
    xor     r8, r8
    mov byte[sib_flag],   0
    
    cmp byte[dsp_flag],   1
    je  second_check_has_sib_reg_mem
    
    cmp byte[index_flag], 1
    je  second_check_has_sib_reg_mem

    jmp finish_set_sib_reg_mem
    ; (mem.dsp == None and mem.index == None) or (dsp_bin_fix != None and mem.index == None and mem.bse != None)
    second_check_has_sib_reg_mem:
    cmp byte[dsp_flag],   0
    je  has_sib_reg_mem
    
    cmp byte[index_flag], 1
    je  has_sib_reg_mem

    cmp byte[bse_flag],   0
    je  has_sib_reg_mem
    jmp finish_set_sib_reg_mem
    

    has_sib_reg_mem:
    mov byte[sib_flag],   1

    ; set defult values
    mov word[sib_ss],   '00'

    mov word[sib_inx],   '10'
    mov byte[sib_inx+2], '0'
    
    mov word[sib_bas],   '10'
    mov byte[sib_bas+2], '1'

    ; set_ss_inx:
    ; set ss:
    cmp byte[index_flag],   1
    jne  set_bas_reg_mem

    mov r8b,byte [scale]
    mov byte[sib_ss],   r8b
    mov r8b, byte[scale+1]
    mov byte[sib_ss+1], r8b
    
    ; set inx:
    xor     r8,    r8
    mov     r8,    regDict
    push    r8
    xor     r8,    r8
    mov     r8,    index
    push    r8    
    call    get_binary_code_from_dict

    mov r8b,byte [rsi]
    mov byte[sib_inx],   r8b
    mov r8b, byte[rsi+1]
    mov byte[sib_inx+1], r8b
    mov r8b, byte[rsi+2]
    mov byte[sib_inx+2], r8b
    
    set_bas_reg_mem:
    cmp byte[bse_flag],   1
    jne  finish_set_sib_reg_mem

    xor     r8,    r8
    mov     r8,    regDict
    push    r8
    xor     r8,    r8
    mov     r8,    bse
    push    r8    
    call    get_binary_code_from_dict

    mov r8b,byte [rsi]
    mov byte[sib_bas],   r8b
    mov r8b, byte[rsi+1]
    mov byte[sib_bas+1], r8b
    mov r8b, byte[rsi+2]
    mov byte[sib_bas+2], r8b
    

    finish_set_sib_reg_mem:
    pop rdi
    pop rsi
    pop r8
    ret
set_mod_mem_reg:
    mov word[mod],    '00'
    cmp byte[dsp_flag], 0
    je  finish_set_mod_mem_reg
    
    cmp byte[bse_flag], 0
    jne second_check
    cmp byte[index_flag], 1
    je  finish_set_mod_mem_reg

    ; if ((mem.dsp == None ))     or     ((mem.bse == None) and (mem.index != None) ):
    ;     return '00 '


    second_check:
    mov word[mod],    '01'
    cmp byte[dsp_flag], 0
    je third_check
    cmp qword[len_dsp],  9
    jle finish_set_mod_mem_reg
    ; cmp get_dsp_len
    ; if (mem.dsp != None ) :
    ;     if len(mem.dsp) <= 2 :
    ;         return '01 '
    
    third_check:
    mov word[mod],    '10'
    ; return '10 '
    finish_set_mod_mem_reg:
    ret
set_regoP_RM_mem:
    push    r11

    xor     r11,    r11
    mov     r11,    imToRegDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11    
    call    get_binary_code_from_dict
    mov     r11w,    WORD[rsi]
    mov WORD[regoP_RM],    r11w
    mov     r11b,    byte[rsi+2]
    mov byte[regoP_RM+2],    r11b
    cmp byte[sib_flag], 1
    ; xor rax,rax
    ; mov al, byte[sib_flag]
    ; call    writeNum
    ; call newLine
    jne no_sib
    mov WORD[regoP_RM+3],    '10'

    mov     rax,    qword[len_dsp]

    mov BYTE[regoP_RM+5],    '0'
    jmp finish_set_regoP_RM_mem

    no_sib:
    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    bse
    push    r11    
    call    get_binary_code_from_dict
    mov     r11w,    WORD[rsi]
    mov WORD[regoP_RM+3],    r11w
    mov     r11b,    byte[rsi+2]
    mov byte[regoP_RM+5],    r11b
    

    ;   if  not sib :
    ;             return  imToRegDict[instruction] + mem.bse.code
    ;         return  imToRegDict[instruction] + '100 '
    finish_set_regoP_RM_mem:
    
    pop r11
    ret

zero_op:
    push    r11

    xor     r11,    r11
    mov     r11,    zeroOpDandOpcodeDict
    push    r11
    xor     r11,    r11
    mov     r11,    command
    push    r11
    ; push    zeroOpDandOpcodeDict
    ; push    command
    
    call    get_binary_code_from_dict

    call    insert_tofile1
    call    insert_tofile2_zero_op
    
    mov rax,    qword[tofile1Bin]
    mov qword[tofile1Hex], rax
    mov rax,    qword[len_file1_bin]
    mov qword[len_file1_hex],rax

    pop     r11

    jmp end_parser


not_zero_op:
    push    r11
    push    rax
    push    r8
    push    r9
    push    r10

    call    set_instruction
    
    ;copy first reg or memSize to helper_resb

    ;find first char of first op:
    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    mov     rsi,     rax

    ;find last char of first op:
    mov     r11,    rax
    inc     r11

    push    r11
    call    get_index_of_first_spliter_after_ptr
    mov     rdi,     rax
    

    ; copy first op in helper_resq_ptr:
    xor r11,r11
    mov r11,    helper_resb
    mov [helper_resq_ptr], r11
    
    push    helper_resq_ptr
    push    helper_dq
    call    write_str
    ;-----------------------------------------------------------
    xor     r11,    r11
    mov     r11,    oneOpDandOpcodeDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    
    cmp     rax,    0
    jne     oneOp
    je      twoOp

    ret_to_not_zero_op:
        pop     r10
        pop     r9
        pop     r8
        pop     rax
        pop     r11
        jmp     end_parser

oneOp:
    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    helper_resb
    push    r11
    call    get_binary_code_from_dict
    cmp     rax,    0
    je      oneOpMem  
    jne     oneOpReg

oneOpReg:
    push    r11

    mov     r11,    [tofile1Ptr]
    mov     [tofile1Ptr_f], r11
    ;set prefix:
    push    rsi
    cmp     byte[reg1Size], 0xA
    je      call_get_regSize
    mov     rax,    reg1Size
    jmp     continue_oneOpReg
    call_get_regSize:
    call    get_regSize  ;input parametr: ptr to reg in regSize dict
    continue_oneOpReg:
    push    rax
    push    zero
    call    get_prefix
    cmp     rax,    0
    je      continue_one_op_reg1
    call     insert_tofile1
    ; call     insert_tofile2
    
    continue_one_op_reg1:
    pop     rsi
    push    rsi
    ; set rex:
    call    set_whole_rex_reg
    cmp     rax,    0
    je      continue_one_op_reg2
    call     insert_tofile1
    ; call     insert_tofile2

    ;set D and Opcode:
    continue_one_op_reg2:
    xor     r11,    r11
    mov     r11,    oneOpDandOpcodeDict
    cmp     word[instruction],  'sh'
    jne     continue_one_op_reg22
    mov     r11,    shiftDict
    continue_one_op_reg22:
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call     insert_tofile1
    ; call     insert_tofile2
    ;set code.w
    pop     rsi
    
    cmp     byte[reg1Size], 0xA
    je      call_get_regSize1
    mov     rax,    reg1Size
    jmp     continue_oneOpReg1
    call_get_regSize1:
    call    get_regSize  ;input parametr: ptr to reg in regSize dict
    
    continue_oneOpReg1:
    push    rax
    call    get_code_w
    call     insert_tofile1
    ; call     insert_tofile2
    ; set mod
    ; "11 " +imToRegDict[instruction] + reg.code
    mov     rsi,    eleven
    mov     rdi,    rsi
    inc     rdi
    call     insert_tofile1
    ; call     insert_tofile2

    xor     r11,    r11
    mov     r11,    imToRegDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call    insert_tofile1
    ; call    insert_tofile2
    
    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    helper_resb
    push    r11
    call    get_binary_code_from_dict
    push    rsi
    call    get_index_of_first_spliter_after_ptr
    mov     rdi,    rax
    call    insert_tofile1
    ; call    insert_tofile2


    rest_of_tofile2:
        call    bin_to_hex
        
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        cmp     word[instruction],  'sh'
        jne     insert_command_to_file2
        inc     rax
        inc     rax
        insert_command_to_file2:
        mov     rdi,    rax
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11
        

    pop     r11

    cmp word[instruction],  'sh'
    je finish_shift_reg
    jmp ret_to_not_zero_op
oneOpMem:
    push    r11
    ; set memSize, bse, index, scale, dsp, addressSize
    mov     r11,    [tofile1Ptr]
    mov     [tofile1Ptr_f], r11     
    call    set_mem_parts
    
    ; prefix + rex + opcodeAndDandW + modRegoPRM + sib + dsp
    ;set prefix:
    push    memSize
    push    addressSize
    call    get_prefix
    cmp     rax,    0
    je      continue_one_op_mem1
    call     insert_tofile1
    ; call     insert_tofile2
    continue_one_op_mem1:
    ;-----------------------------------------

    call    set_sib_mem
    call    set_mod_mem_reg

    ;set dsp fit and bin
    call    set_dsp_fit

    call    set_regoP_RM_mem
    
    ;-----------------------------------------
    ;write rex
    call    set_whole_rex_mem
    cmp     rax,    0
    je      continue_one_op_mem2
    call    insert_tofile1
    ; call     insert_tofile2
    

    ;write opcede and D
    continue_one_op_mem2:
    xor     r11,    r11
    mov     r11,    oneOpDandOpcodeDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call    insert_tofile1
    ; call     insert_tofile2
    
    ; write code.w :
    push    memSize
    call    get_code_w
    call    insert_tofile1
    ; call     insert_tofile2

    ; write modRegoPRM:
    ; write mod:
    mov     rsi,    mod
    mov     rdi,    rsi
    inc     rdi
    call     insert_tofile1
    ; call     insert_tofile2
    ; write regoP_RM
    mov     rsi,    regoP_RM
    mov     rdi,    rsi
    add     rdi,    5
    call     insert_tofile1
    ; call     insert_tofile2


    ;write sib(ss + inx + bas):
    cmp byte[sib_flag], 1
    jne continue_one_op_mem3

    mov     rsi,    sib_ss
    mov     rdi,    rsi
    add     rdi,    1
    call     insert_tofile1
    ; call     insert_tofile2
  
    mov     rsi,    sib_inx
    mov     rdi,    rsi
    add     rdi,    2
    
    call     insert_tofile1
    ; call     insert_tofile2

    mov     rsi,    sib_bas
    mov     rdi,    rsi
    add     rdi,    2
    call     insert_tofile1
    ; call     insert_tofile2
    

    continue_one_op_mem3:
    cmp byte[dsp_flag], 1
    jne rest_of_tofile2_mem
    mov     rsi,    dsp_fixed
    mov     rdi,    rsi
    add     rdi,    qword[len_dsp]
    dec     rdi
    call     insert_tofile1
    ; call     insert_tofile2
    
    

    rest_of_tofile2_mem:
        call    bin_to_hex
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        loop_on_mem_command:
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr    
        cmp byte[rax+1], ']'
        jne loop_on_mem_command

        mov     rdi,    rax
        inc     rdi
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11

    pop     r11
    jmp     ret_to_not_zero_op

reg_reg:
    push    r11
    push    r12
    push    rsi
    push    rdi
    push    rcx
    push    rbx

    mov     r11,    [tofile1Ptr]
    mov     [tofile1Ptr_f], r11

    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    mov     r12,rax
    inc     rax

    push    rax
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    push    r12
    push    rax
    call set_reg_reg_parts

    ;set prefix
    push    reg1Size
    push    zero
    call    get_prefix
    cmp     rax,    0
    je      set_rex_reg_reg
    call     insert_tofile1
    ; call     insert_tofile2

    set_rex_reg_reg:
    call    set_whole_rex_reg_reg
    cmp     rax,    0
    je      get_opcode_and_D
    call     insert_tofile1
    ; call     insert_tofile2

    get_opcode_and_D:
    ; DandOpcodeDict[instruction][whatTOwhat]
    xor     r11,    r11
    mov     r11,    regToRegDandOpcodeDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call     insert_tofile1
    call     insert_tofile2

    ; get  get_code_w(reg ):
    cmp dword[instruction], 'imul'
    je  set_mod_reg_reg

    cmp word[instruction], 'bs'
    je  set_mod_reg_reg
    xor rax,    rax
    xor rbx,    rbx
    xor rcx,    rcx
    mov rbx,    one
    mov rcx,    zero
    cmp byte[reg1Size], '2'
    cmovge  rax,    rbx
    cmovl   rax,    rcx
    mov     rsi,    rax
    mov     rdi,    rsi
    call    insert_tofile1
    ; call    insert_tofile2

    set_mod_reg_reg:
    ; "11" + op2.code + op1.code
    mov     rsi,    eleven
    mov     rdi,    rsi
    inc     rdi
    call    insert_tofile1
    ; call    insert_tofile2
    cmp dword[instruction], 'imul'
    je set_reg_reg_imul_bsf_bsr
    cmp word[instruction], 'bs'  ; bsf or bsr
    je set_reg_reg_imul_bsf_bsr

    mov     rsi,    reg2Code
    mov     rdi,    rsi
    add     rdi,    2
    call    insert_tofile1
    ; call    insert_tofile2

    mov     rsi,    reg1Code
    mov     rdi,    rsi
    add     rdi,    2    
    call    insert_tofile1
    ; call    insert_tofile2
    jmp     rest_of_tofile_reg_reg

    set_reg_reg_imul_bsf_bsr:
    mov     rsi,    reg1Code
    mov     rdi,    rsi
    add     rdi,    2    
    call    insert_tofile1

    mov     rsi,    reg2Code
    mov     rdi,    rsi
    add     rdi,    2
    call    insert_tofile1


    rest_of_tofile_reg_reg:
        call    bin_to_hex
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        mov     rdi,    rax
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11


    pop rbx
    pop rcx
    pop rdi
    pop rsi
    pop r12
    pop r11

    jmp finish_twoOp
reg_mem:
    push    r11

    mov     r11,    [tofile1Ptr]
    mov     [tofile1Ptr_f], r11     

    call    set_mem_parts
    call    set_reg_parts
 
    push    reg1Size
    push    addressSize
    call    get_prefix
    cmp     rax,    0
    je      continue_reg_mem1
    call     insert_tofile1

    continue_reg_mem1:
    call    set_dsp_fit

    ;write rex
    call    set_whole_rex_reg_mem
    cmp     rax,    0
    je      get_opcode_and_D_mem_reg
    call    insert_tofile1
    
    get_opcode_and_D_mem_reg:
    ; DandOpcodeDict[instruction][whatTOwhat]
    xor     r11,    r11
    mov     r11,    memToRegDandOpcodeDict
    cmp     byte[mem_to_reg_flag],    1
    jne     get_opcode_and_D_mem_reg_continue
    mov     r11,    regTomemDandOpcodeDict
    get_opcode_and_D_mem_reg_continue:
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call     insert_tofile1

    ; prefix + rex + opcodeAndD     + modRegoPRM + sib + dsp_bin_fix ;imul
    
    ; prefix + rex + opcodeAndD     + modRegoPRM + sib + dsp_bin_fix ;bsf/bsr

    ; prefix + rex + opcodeAndDAndW + modRegoPRM + sib + dsp_bin_fix ;other

    ; get  get_code_w(reg ):
    cmp dword[instruction], 'imul'
    je  set_mod_reg_mem

    cmp word[instruction], 'bs'
    je  set_mod_reg_mem
    xor rax,    rax
    xor rbx,    rbx
    xor rcx,    rcx
    mov rbx,    one
    mov rcx,    zero
    cmp byte[reg1Size], '2'
    cmovge  rax,    rbx
    cmovl   rax,    rcx
    mov     rsi,    rax
    mov     rdi,    rsi
    call    insert_tofile1
    
    
    set_mod_reg_mem:
    ; --------------------------------------
    call set_sib_reg_mem
    call    set_mod_mem_reg
    ;--------------------------------------

    ; write mod:
    mov     rsi,    mod
    mov     rdi,    rsi
    inc     rdi
    call     insert_tofile1
    ; call     insert_tofile2
    

    mov     rsi,    reg1Code
    mov     rdi,    rsi
    add     rdi,    2
    call    insert_tofile1

    cmp     byte[sib_flag],  0
    je      set_bse_code
    mov     word[bse],  'rs'
    mov     byte[bse+2],'p'
    
    set_bse_code:
    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    bse
    push    r11
    call    get_binary_code_from_dict
    sub     rdi,    4
    call    insert_tofile1
    

    ; write sib(ss + inx + bas):
    cmp byte[sib_flag], 1
    jne continue_mem_reg1

    mov     rsi,    sib_ss
    mov     rdi,    rsi
    add     rdi,    1
    call     insert_tofile1
  
    mov     rsi,    sib_inx
    mov     rdi,    rsi
    add     rdi,    2
    
    call     insert_tofile1

    mov     rsi,    sib_bas
    mov     rdi,    rsi
    add     rdi,    2
    call     insert_tofile1
    

    continue_mem_reg1:
    cmp byte[dsp_flag], 1
    jne rest_of_tofile2_mem_reg
    mov     rsi,    dsp_fixed
    mov     rdi,    rsi
    add     rdi,    qword[len_dsp]
    dec     rdi
    call     insert_tofile1



    rest_of_tofile2_mem_reg:
        call    bin_to_hex
        
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        loop_on_mem_command_mem_reg:
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr    
        cmp byte[rax+1], ']'
        jne loop_on_mem_command_mem_reg
        cmp byte[rax+2], ','
        jne continue_mem_reg
        
        inc     rax
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr    
        dec     rax
        
        continue_mem_reg:
        mov     rdi,    rax
        inc     rdi
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11


    pop r11
    jmp finish_twoOp
reg_imm:
    push    r11

    mov byte[reg_imm_flag], 1

    mov     r11,    [tofile1Ptr]
    mov     [tofile1Ptr_f], r11

    call    set_reg_parts
    call    set_imm   ;set imm_hex_reverce and imm_hex_len
    call    set_imm_fit

    ;set prefix:
    push    reg1Size
    push    zero
    call    get_prefix
    cmp     rax,    0
    je      continue_reg_im
    call     insert_tofile1
    
    continue_reg_im:
    pop     rsi
    push    rsi

    cmp word[instruction],  'sh'  ;shl or shr
    je  shift_reg
   
    ; set rex:
    call    set_whole_rex_reg_imm
    cmp     rax,    0
    je      continue_reg_im2
    call     insert_tofile1
    ; call     insert_tofile2

    ;set D and Opcode:
    continue_reg_im2:
    xor     r11,    r11
    mov     r11,    immToRegDandOpcodeDict      
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call     insert_tofile1
    ;---------------------------------------------------
    cmp     word[instruction],  'mo'   ;mov
    jne      not_mov
    push    reg1Size
    call    get_code_w
    call     insert_tofile1
    jmp     continue_imm_reg
        ; if instruction == "mov" :
        ; ans += get_code_w(reg)
    ;---------------------------------------------------

    ;---------------------------------------------------
    not_mov:
    cmp     dword[instruction],  'test'   
    je      continue_imm_reg1
    mov     rsi,    zero0
    mov     rdi,    rsi
    call    insert_tofile1
    jmp     continue_imm_reg2
    continue_imm_reg1:
    mov     rsi,    one
    mov     rdi,    rsi
    call     insert_tofile1
    continue_imm_reg2:
    push    reg1Size
    call    get_code_w
    call     insert_tofile1
    
    mov     rsi,    eleven
    mov     rdi,    rsi
    inc     rdi
    call     insert_tofile1

    xor     r11,    r11
    mov     r11,    imToRegDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call     insert_tofile1

    ; else:
    ;     if instruction != 'test' :
        ;     ans += '0 '
        ; ans += get_code_w(reg) + ' 11 ' + imToRegDict[instruction]
    ;---------------------------------------------------
    continue_imm_reg:
    ; ans += reg.code + to_binary_fit(im, reg)
    mov     rsi,    reg1Code
    mov     rdi,    rsi
    add     rdi,    2
    call    insert_tofile1

    mov     rsi,    dsp_fixed
    xor     r11,r11
    mov     r11b, byte[imm_hex_len_fix]
    mov     rdi,    r11
    shl     rdi,    3
    dec     rdi
    add     rdi,    rsi
    call    insert_tofile1


    rest_of_tofile_reg_imm:
        call    bin_to_hex
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        mov     rdi,    rax
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11

    finish_reg_imm:
    pop r11
    jmp finish_twoOp


shift_mem:
    push    rsi
    push    rdi
    push    r9
    push    r11

    mov byte[shft_mem_flag], 1
    call    set_mem_parts

    push    zero
    push    addressSize
    call    get_prefix
    cmp     rax,    0
    je      continue_sh_mem
    call     insert_tofile1
    
    continue_sh_mem:
    call    set_whole_rex_mem
    cmp     rax,    0
    je      continue_sh_mem2
    call     insert_tofile1
    
    continue_sh_mem2:
    ; opcode and D :
    xor     r11,    r11
    mov     r11,    shiftDict
    push    r11
    xor     r11,    r11
    mov     dword[helper_resb],  'shim'
    mov     r11,    helper_resb
    push    r11
    call    get_binary_code_from_dict
    call    insert_tofile1
    ;code.w :
    push    memSize
    call    get_code_w
    call    insert_tofile1

    ; prefix + get_rex( mem=mem) + get_opcode_D_W('sh im',mem=mem) 
    ; + get_mod_mem_reg(mem, dsp) + get_sib(mem) + imfix


    call    set_mod_mem_reg

    ; write modRegoPRM:
    ; write mod:
    mov     rsi,    mod
    mov     rdi,    rsi
    inc     rdi
    call     insert_tofile1
    ;-----------------------------------------
    call    set_sib_mem
    ;-----------------------------------------

    ; write regoP_RM
    call    set_regoP_RM_mem
    mov     rsi,    regoP_RM
    mov     rdi,    rsi
    add     rdi,    5
    call    insert_tofile1

    cmp byte[sib_flag], 1
    jne continue_sh_imm3

    mov     rsi,    sib_ss
    mov     rdi,    rsi
    add     rdi,    1
    call     insert_tofile1
    ; call     insert_tofile2
  
    mov     rsi,    sib_inx
    mov     rdi,    rsi
    add     rdi,    2
    
    call     insert_tofile1
    ; call     insert_tofile2

    mov     rsi,    sib_bas
    mov     rdi,    rsi
    add     rdi,    2
    call     insert_tofile1
    ; call     insert_tofile2
    

    continue_sh_imm3:
    call    set_dsp_fit
    cmp byte[dsp_flag], 1
    jne continue_sh_imm
    mov     rsi,    dsp_fixed
    mov     rdi,    rsi
    add     rdi,    qword[len_dsp]
    dec     rdi
    call     insert_tofile1
    call     insert_tofile2
    
    continue_sh_imm:
    mov r9, command
    loop_ignore_finish_mem_:
        inc     r9

        xor     r11,    r11
        mov     r11,    r9
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        mov     r9,    rax
        cmp     byte[r9],  ']'
        jne     loop_ignore_finish_mem_
    inc     rax
    inc     rax
    push    rax
    call    decimal_str_to_bin_fix
    mov     rsi,    imm_bin_fixed
    mov     rdi,    rax
    dec     rdi
    call    insert_tofile1

    rest_of_tofile2_sh_mem:
        call    bin_to_hex
        
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        loop_on_mem_command_sh_mem:
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr    
        cmp byte[rax+1], ']'
        jne loop_on_mem_command_sh_mem
        cmp byte[rax+2], ','
        jne continue_mem_sh
        
        inc     rax
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr    
        dec     rax
        
        continue_mem_sh:
        mov     rdi,    rax
        inc     rdi
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11



    pop     r11
    pop     r9
    pop     rdi
    pop     rsi
    jmp finish_mem_imm

shift_reg:
    push    r11

    mov byte[shft_reg_flag], 1
    call    set_reg_parts

    ; if im == '1':
    ;     return one_op_reg(reg)
    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    push    rax
    mov     rsi,    rax
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    
    cmp     byte[rax],  '1'
    jne     not_shft_1
    cmp     byte[rax+1],  0xA
    je     oneOpReg
    ; return prefix + get_rex(reg1=reg) + get_opcode_D_W('sh im', reg=reg) + '11' +imToRegDict[instruction] + reg.code + imfix
    not_shft_1:
    push    reg1Size
    push    zero
    call    get_prefix
    cmp     rax,    0
    je      continue_shft
    call     insert_tofile1
    
    continue_shft:
    call    set_whole_rex_reg
    cmp     rax,    0
    je      continue_shft2
    call     insert_tofile1
    continue_shft2:
    xor     r11,    r11
    mov     r11,    shiftDict
    push    r11
    xor     r11,    r11
    mov     dword[helper_resb],  'shim'
    mov     r11,    helper_resb
    push    r11
    call    get_binary_code_from_dict
    call     insert_tofile1

    ; set code.w
    mov     rax,    reg1Size    
    push    rax
    call    get_code_w
    call     insert_tofile1
    ; set mod
    ; "11 " +imToRegDict[instruction] + reg.code
    mov     rsi,    eleven
    mov     rdi,    rsi
    inc     rdi
    call     insert_tofile1
    ; imToRegDict[instruction]
    xor     r11,    r11
    mov     r11,    imToRegDict
    push    r11
    xor     r11,    r11
    mov     r11,    instruction
    push    r11
    call    get_binary_code_from_dict
    call    insert_tofile1
    
    mov     rsi,    reg1Code
    mov     rdi,    rsi
    inc     rdi
    inc     rdi
    call    insert_tofile1

    ;get imm data (bin)
    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    push    rax
    mov     rsi,    rax
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    
    cmp     word[rax],  '0x'
    jne     call_decimal_str_to_bin_fix
    je      call_set_imm
    call_decimal_str_to_bin_fix:
    push    rax
    call    decimal_str_to_bin_fix
    mov     rsi,    imm_bin_fixed
    mov     rdi,    rax
    dec     rdi
    jmp     write_imm
    call_set_imm:
    call    set_imm   ;set imm_hex_reverce and imm_hex_len
    mov     rsi,    dsp_fixed
    mov     rdi,    rsi
    add     rdi,    7
    jmp     write_imm
    write_imm:
    call    insert_tofile1

    rest_of_tofile3:
        call    bin_to_hex
        
        push    r11
        push    rsi
        push    rdi

        ; insetr space
        call    insert_space_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]
        
        ;insetr assebmly code
        xor     r11,    r11
        mov     r11,    command
        push    r11
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        push    rax
        call    get_index_of_first_spliter_after_ptr
        cmp     word[instruction],  'sh'
        jne     insert_command_to_file3
        inc     rax
        inc     rax
        insert_command_to_file3:
        mov     rdi,    rax
        mov     rsi,    command
        push    tofile2HexPtr
        push    len_file2_hex
        call    write_str
        mov     [tofile2HexPtr],    rax

        ;insetr newLine
        call    insert_NL_file2
        inc     qword[tofile2HexPtr]
        inc     qword[len_file2_hex]

        pop     rdi
        pop     rsi
        pop     r11
        


    finish_shift_reg:
    pop r11
    jmp finish_reg_imm


mem_imm:
    mov byte[mem_imm_flag], 1

    mov     r11,    [tofile1Ptr]
    mov     [tofile1Ptr_f], r11

    cmp word[instruction],  'sh'  ;shl or shr
    je  shift_mem

    finish_mem_imm:
    jmp finish_twoOp
twoOp:
    push    r11
    push    r12

    xor     r11,    r11
    mov     r11,    command
    push    r11
    call    get_index_of_first_spliter_after_ptr
    inc     rax
    inc     rax
    mov     rsi,     rax

    xor     r11,    r11
    mov     r11,    regDict
    push    r11
    xor     r11,    r11
    mov     r11,    rsi
    mov     r12,    rsi
    push    r11
    call    get_binary_code_from_dict
    
    cmp     rax,    0
    jne     reg_sth
    je      mem_sth

    reg_sth:
        push    r12
        call    get_index_of_first_spliter_after_ptr
        inc     rax
        inc     rax
        mov     rsi,     rax

        mov     r12,    rsi

        xor     r11,    r11
        mov     r11,    regDict
        push    r11
        push    rsi
        call    get_binary_code_from_dict
        cmp     rax,    1
        je      reg_reg

        
        xor     r11,    r11
        mov     r11,    memorySizeDict
        push    r11
        push    r12
        call    get_binary_code_from_dict
        cmp     rax,    1
        je      reg_mem
        jne     reg_imm



    mem_sth:
        mov rsi,    command
        loop_skip_till_finish_mem:
            inc     rsi
            xor     r11,    r11
            mov     r11,    rsi
            push    r11
            call    get_index_of_first_spliter_after_ptr
            inc     rax
            mov     rsi,    rax
            cmp     byte[rsi],  ']'
            jne     loop_skip_till_finish_mem

        inc rsi
        inc rsi
        cmp word[rsi],  '0x'  ; be dalil khastegi ziad :)))
        je  mem_imm
        cmp byte[rsi],  '0'
        je  mem_imm
        cmp byte[rsi],  '1'
        je  mem_imm
        cmp byte[rsi],  '2'
        je  mem_imm
        cmp byte[rsi],  '3'
        je  mem_imm
        cmp byte[rsi],  '4'
        je  mem_imm
        cmp byte[rsi],  '5'
        je  mem_imm
        cmp byte[rsi],  '6'
        je  mem_imm
        cmp byte[rsi],  '7'
        je  mem_imm
        cmp byte[rsi],  '8'
        je  mem_imm
        cmp byte[rsi],  '9'
        je  mem_imm
        mov byte[mem_to_reg_flag],    1
        jmp reg_mem
    finish_twoOp:
    pop     r12
    pop     r11
    jmp     ret_to_not_zero_op

reset:
    mov byte[rex_w],    '0'
    mov byte[rex_r],    '0'
    mov byte[rex_x],    '0'
    mov byte[rex_b],    '0'


    mov byte[bse_flag],     0
    mov byte[index_flag],   0
    mov byte[dsp_flag],     0
    mov byte[sib_flag],     0

    mov byte[mem_imm_flag], 0
    mov byte[reg_imm_flag], 0

    mov byte[rex_whole],    0xA
    mov byte[mem_to_reg_flag],  0xA

    mov byte[memSize],      0xA
    mov byte[bse],          0xA
    mov byte[index],        0xA
    mov byte[scale],        0xA
    mov byte[addressSize],  0xA  

    mov byte[sib_ss],       0xA
    mov byte[sib_inx],      0xA
    mov byte[sib_bas],      0xA

    mov byte[mod],          0xA
    mov byte[regoP_RM],     0xA
  
    mov byte[dsp],          0xA
    mov byte[dsp_reverce],  0xA
    mov byte[dsp_fixed],    0xA
    mov byte[len_dsp],      0xA

    mov byte[reg1Code],     0xA
    mov byte[reg1Size],     0xA
    mov byte[reg1IsNew],    0xA
    mov byte[reg2Code],     0xA
    mov byte[reg2IsNew],    0xA
    mov byte[reg2Size],     0xA

    mov byte[imm_hex_len],  0
    mov byte[imm_hex_len_fix],  0
    mov byte[reg_imm_flag], 0
    mov byte[mem_imm_flag], 0

    mov byte[imm_hex_reverce],  0xA
    mov byte[imm_bin_fixed],    0xA
    
    
    ret
_start:

    call    get_source_file

    mov rax,    tofile1Bin
    mov [tofile1Ptr], rax
    
    xor rax,rax
    mov rax,    tofile2Bin
    mov [tofile2Ptr], rax

    mov rax,    tofile1Hex
    mov [tofile1HexPtr], rax
    
    xor rax,rax
    mov rax,    tofile2Hex
    mov [tofile2HexPtr], rax

    
    
    mov     rdi,    sourceFileName
    call    openFile
    mov     [FD_source],   rax

    mov     r8,    command
    xor     r9,    r9
    jmp     line_by_line_read


write_file:
    mov     rdi,    destinationFile1Name
    call    createFile
    mov     [FD_destination1],    rax
    mov     rdi,    [FD_destination1]
    mov     rsi,    tofile1Bin
    mov     rdx,    [len_file1_bin]
    call    writeFile

    mov     rdi,    destinationFile2Name
    call    createFile
    mov     [FD_destination2],    rax
    mov     rdi,    [FD_destination2]
    mov     rsi,    tofile2Hex
    mov     rdx,    [len_file2_hex]
    call    writeFile

    
    jmp     Exit
get_source_file:
    push rdi
    push rsi
    push rdx

    mov rax, sys_read
    mov rdi, stdin
    mov rsi, sourceFileName
    mov rdx, 1000
    syscall
    
    push    sourceFileName
    call    get_index_of_first_spliter_after_ptr
    mov byte[rax+1],    0
    pop rdx
    pop rsi
    pop rdi
    ret
Exit:
	mov     rax,    60
    mov     rdi,    0
    syscall