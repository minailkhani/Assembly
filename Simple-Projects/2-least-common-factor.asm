%include "in_out.asm"
section .data
section .bss
	num1 resb 16
	num2 resb 16

section .text
	global _start
_start:

read:
	call readNum
	mov [num1], rax
	xor rax, rax
	call readNum
	mov [num2], rax
	mov rbx, rax
	mov rax, [num1]

lfc:
	cmp rax, rbx
	je finish
	ja incrbx
	jb incrax
incrax:
	add rax, [num1]
	call lfc
incrbx:
	add rbx, [num2]
	call lfc

finish:
	mov rdx, rax
	call writeNum
	call exit

exit:
	mov eax, 1
	mov ebx, 0
	int 80h
