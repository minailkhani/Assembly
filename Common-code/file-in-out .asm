%include "../general/sys-equal.asm"
;----------------------------------------------------
section     .data1
    error_open_dir   db     "error in opening dir         ", NL, 0
    error_create     db     "error in creating file       ", NewLine, 0
    error_close      db     "error in closing file        ", NewLine, 0
    error_write      db     "error in writing file        ", NewLine, 0
    error_open       db     "error in opening file        ", NewLine, 0
    error_append     db     "error in appending file      ", NewLine, 0
    error_delete     db     "error in deleting file       ", NewLine, 0
    error_read       db     "error in reading file        ", NewLine, 0
    error_print      db     "error in printing file       ", NewLine, 0
    error_seek       db     "error in seeking file        ", NewLine, 0
    error_create_dir db    "error in creating directory  ", NL, 0

    suces_open_dir   db      "dir opened for R/W                 ", NL, 0    
    suces_create_dir db      "dir created and opened for R/W     ", NL, 0
    suces_create     db      "file created and opened for R/W ", NewLine, 0
    suces_close      db      "file closed                     ", NewLine, 0
    suces_write      db      "written to file                 ", NewLine, 0
    suces_open       db      "file opend for R/W              ", NewLine, 0
    suces_append     db      "file opened for appending       ", NewLine, 0
    suces_delete     db      "file deleted                    ", NewLine, 0
    suces_read       db      "reading file                    ", NewLine, 0
    suces_seek       db      "seeking file                    ", NewLine, 0

;----------------------------------------------------
; rdi : file name; rsi : file permission
createFile:
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rdi, suces_create           
    call    printString
    ret
createerror:
    mov     rdi, error_create
    call    printString
    ret

createFile:
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rdi, suces_create           
    call    printString
    ret
createerror:
    mov     rdi, error_create
    call    printString
    ret
;----------------------------------------------------
; rdi : file name; rsi : file access mode 
; rdx: file permission, do not need
openFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR     
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov     rdi, suces_open
    call    printString
    ret
openerror:
    mov     rdi, error_open
    call    printString
    ret
;----------------------------------------------------
; rdi point to file name
appendFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR | O_APPEND
    syscall
    cmp     rax, -1     ; file descriptor in rax
    jle     appenderror
    mov     rdi, suces_append
    call    printString
    ret
appenderror:
    mov     rdi, error_append
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         ; number of written byte
    jle     writeerror
    mov     rdi, suces_write
    call    printString
    ret
writeerror:
    mov     rdi, error_write
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
readFile:
    mov     rax, sys_read
    syscall
    cmp     rax, -1           ; number of read byte
    jle     readerror
    mov     byte [rsi+rax], 0 ; add a  zero
    mov     rdi, suces_read
    call    printString
    ret
readerror:
    mov     rdi, error_read
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor
closeFile:
    mov     rax, sys_close
    syscall
    cmp     rax, -1      ; 0 successful
    jle     closeerror
    mov     rdi, suces_close
    call    printString
    ret
closeerror:
    mov     rdi, error_close
    call    printString
    ret

;----------------------------------------------------
; rdi : file name
deleteFile:
    mov     rax, sys_unlink
    syscall
    cmp     rax, -1      ; 0 successful
    jle     deleterror
    mov     rdi, suces_delete
    call    printString
    ret
deleterror:
    mov     rdi, error_delete
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi: offset ; rdx : whence
seekFile:
    mov     rax, sys_lseek
    syscall
    cmp     rax, -1
    jle     seekerror
    mov     rdi, suces_seek
    call    printString
    ret
seekerror:
    mov     rdi, error_seek
    call    printString
    ret

;----------------------------------------------------
