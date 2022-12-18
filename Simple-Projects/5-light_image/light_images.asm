%include "in_out.asm"
%include "file_in_out.asm"
%include "./sys-equal.asm"
;----------------------------------------------------

section     .bss
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000
    sys_mkdir       equ 83

    sys_makenewdir  equ 0q777

section     .data
    error_open_dir      db      "error in opening dir               ", NL, 0

    suces_open_dir      db      "dir opened for R/W                 ", NL, 0    
    error_create_dir    db      "error in creating directory        ", NL, 0
    suces_create_dir    db      "dir created and opened for R/W     ", NL, 0
    
;----------------------------------------------------
section .text

;----------------------------------------------------
;----------------------------------------------------

section     .bss
    sourcePicName                   resb    100000000
    destinationPicName              resb    100000000
    sourceDir                       resb    100000000
    destDir                         resb    100000000
    curDir                          resb    100000000
    
    header_file                     resq    14
    image_type                      resq    4
    biWidth                         resq    4
    biHeight                        resq    4
    rest_of_os_image_header         resq    4
    rest_of_windows_image_header    resq    28
    pixels_buff                     resb    100000000
    ress                            resb    100000000
    n                               resb    1

section .data 
    pixels                              dq    0  
    FD_source                           dq    0
    FD_destination                      dq    0

    pixel_data_size                     dq    0  
    header_file_len                     dq    14
    image_type_len                      dq    4
    biWidth_biHeight_win_len            dq    4
    biWidth_biHeight_os_len             dq    2
    rest_of_os_image_header_len         dq    4
    rest_of_windows_image_header_len    dq    28
    source_dir_fd                       dq    0
    edited_photo                        db    '/edited_photo/', 0
    first                               db    'diiir', 0
    slash                               db    '/', 0



section .text
    global  _start

;   rdi: dirname
openDir:
    mov rax, sys_open
    mov rsi, O_DIRECTORY
    syscall
    cmp rax, -1
    ; jle openDir_error
    ; mov rsi, suces_open_dir
    ; call printString
    ret

; openDir_error:
;     mov rsi, error_open_dir
;     call printString
;     ret

; rdi: dir name
makeDir:
    mov rax, sys_mkdir
    mov rsi, sys_makenewdir
    xor rdx, rdx

    syscall
    cmp  rax, -1
    ; jle  makeDir_error
    ; mov  rsi, suces_create_dir
    ; call printString
    ; ret
; makeDir_error:
;     mov rsi,error_create_dir
;     call printString
;     ret

open_source_photo:
    enter 0,0
    %define param_photo qword[rbp+16]
    mov rdi, param_photo
    call openFile
    mov [FD_source], rax
    %undef param_photo
    leave
    ret 8
    
create_destination_photo:
    enter 0,0
    %define param_source_photo qword[rbp+16]
    ; esm o address distination ro az soutce besaz.  "destinationPicName"
    mov rdi, destinationPicName
    call createFile
    mov [FD_destination], rax
    %undef param_source_photo
    leave
    ret 8

read_part:
    enter 0,0
    %define param_buffer_len qword[rbp+16]
    %define param_buffer     qword[rbp+24]
    mov rdi, [FD_source]
    mov rsi, param_buffer
    mov rdx, param_buffer_len
    call readFile
    mov rdi, rsi    
    %undef param_buffer_len 
    %undef param_buffer     
    leave
    ret 16

write_part_qword:
    enter 0,0
    %define param_buffer     qword[rbp+24]
    %define param_buffer_len qword[rbp+16]
    mov rdi, [FD_destination]
    mov rsi, param_buffer
    mov rdx, param_buffer_len
    call writeFile
    %undef param_buffer_len 
    %undef param_buffer     
    leave
    ret 16


handle_pic:
    push qword sourcePicName
    call open_source_photo
    readFileHeader:
        push qword header_file
        push qword [header_file_len]
        call read_part
    
    readImageType:
        push qword image_type
        push qword [image_type_len]
        call read_part
    
    mov r15, 40 
    cmp qword[image_type],r15
    jne readOSImageHeader
    readWindowsImageHeader:
        readWidthWin:
            push qword biWidth
            push qword [biWidth_biHeight_win_len]
            call read_part
        readbHeightWin:
            push qword biHeight
            push qword [biWidth_biHeight_win_len]
            call read_part
        readRestOfImageHeaderWindows:
            push qword rest_of_windows_image_header
            push qword [rest_of_windows_image_header_len]
            call read_part
        jmp finishReadImageHeader

    readOSImageHeader:
        readWidthOs:
            push qword biWidth
            push qword [biWidth_biHeight_os_len]
            call read_part
        readbHeightOs:
            push qword biHeight
            push qword [biWidth_biHeight_os_len]
            call read_part
        readRestOfImageHeaderOs:
            push qword rest_of_os_image_header
            push qword [rest_of_os_image_header_len]
            call read_part
    finishReadImageHeader:
        calNumOfbyte:            ; rbx: number of bytes
            mov rax, [biWidth]
            mov r15,3
            
            mul r15
            mov rbx, rax
            xor rax, rax
            mov r15, 3
            mov rax, [biWidth]
            mul r15
            xor rdx, rdx
            mov r15, 4
            div r15
            
            add rbx, 4
            sub rbx, rdx
            imul rbx, [biHeight]


    readRestOfFile:

        push qword [pixels]
        push rbx
        call read_part

    ; finished reading the source file
    push qword sourcePicName
    call create_destination_photo

    write_distanation:
        writeFileHeader:
            push qword header_file
            push qword [header_file_len]
            call write_part_qword
        
        writeImageType:
            push qword image_type
            push qword [image_type_len]
            call write_part_qword
        
        mov r15, 40 
        cmp qword[image_type],r15
        jne writeOSImageHeader
        writeWindowsImageHeader:
            writeWidthWin:
                push qword biWidth
                push qword [biWidth_biHeight_win_len]
                call write_part_qword
            writebHeightWin:
                push qword biHeight
                push qword [biWidth_biHeight_win_len]
                call write_part_qword
            writeRestOfImageHeaderWindows:
                push qword rest_of_windows_image_header
                push qword [rest_of_windows_image_header_len]
                call write_part_qword
            jmp finishwriteImageHeader

        writeOSImageHeader:
            writeWidthOs:
                push qword biWidth
                push qword [biWidth_biHeight_os_len]
                call write_part_qword
            writebHeightOs:
                push qword biHeight
                push qword [biWidth_biHeight_os_len]
                call write_part_qword
            writeRestOfImageHeaderOs:
                push qword rest_of_os_image_header
                push qword [rest_of_os_image_header_len]
                call write_part_qword
        finishwriteImageHeader:

    vpbroadcastb  xmm0, [n]
    
    
    mov rcx, rbx
    shr rcx, 4 
    inc rcx    

    mov r10, [pixels]
    loop_on_128b:
        vmovdqa xmm1, [r10]
        vpaddusb xmm1, xmm0
        vmovdqa [r10],xmm1
        
        add r10,16
        loop loop_on_128b



    push qword [pixels]
    push rbx
    call write_part_qword
    ret

concate:
    enter 0,0
    %define param_first qword[rbp+32]
    %define param_second qword[rbp+24]
    %define param_dest qword[rbp+16]
    push r8
    push r9
    push rsi
    push rdi

    mov rdi, param_first
    call GetStrlen
    mov r8, rdx
    mov rdi, param_second
    call GetStrlen
    mov r9, rdx

    mov rcx, r8
    mov rsi, param_first
    mov rdi, param_dest
    cld
    rep movsb

    mov rcx, r9
    mov rsi, param_second
    rep movsb

    mov BYTE[rdi], 0

    pop  rdi
    pop  rsi
    pop  r9
    pop  r8
    %undef param_first  
    %undef param_second 
    %undef local_concatad 
    leave
    ret 24

main:
    mov rax, pixels_buff
    and rax, 63
    sub rax, 64
    neg rax
    add rax, pixels_buff
    mov [pixels], rax

    mov rax, sys_read
    mov rdi, stdin
    mov rsi, sourceDir
    mov rdx, 10000
    syscall
    mov r8, sourceDir
    add r8, rax
    dec r8
    mov qword[r8], 0

    call readNum
    mov r8, rax   ;n
    mov     [n],    al


    mov rdi, sourceDir
    call openDir
    mov [source_dir_fd], rax


    push sourceDir
    push edited_photo
    push destDir
    call concate

    push sourceDir
    push slash
    push sourceDir
    call concate

    mov rdi, destDir
    call makeDir


    mov rax, 217
    mov rdi, [source_dir_fd]
    mov rsi, curDir
    mov rdx, 100000000
    syscall
    add rax, curDir
    mov r14, rax

    xor rdx, rdx
    mov r11, curDir

    main_walkDir:
        add rdx, r11
        cmp rdx, r14
        jge Exit
        xor r11,  r11
        mov r11w, [rdx+16]
        mov r12, rdx
        add r12, 18
        xor r13, r13
        mov r13b, [r12]
        inc r12

        cmp r13, 8
        jne continue
        push  r11
        push  r12
        push  r13
        push  rdx

        push sourceDir
        push r12
        push sourcePicName
        call concate
        
        push destDir
        push r12
        push destinationPicName
        call concate
        call handle_pic

        pop rdx
        pop r13
        pop r12
        pop r11

        jmp main_walkDir
        continue:
            jmp main_walkDir

_start:
    call    main
Exit:
	mov     rax,    60
    mov     rdi,    0
    syscall

