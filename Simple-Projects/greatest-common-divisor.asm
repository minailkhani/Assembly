	%include 'in_out.asm'

	section .bss
		num1 resb 8

	section .text
		global _start
	_start:

	read:
		call readNum
		mov [num1], rax
		xor rax, rax
		call readNum

		mov rbx, rax
		mov rax, [num1]


	lfc:
		cmp rax, rbx
		je finish
		ja decrax
		jb decrbx

	decrbx:
		sub rbx, rax
		call lfc
	decrax:
		sub rax, rbx
		call lfc
	finish:
		mov rdx, rax
		call writeNum
		call exit

	exit:
		mov eax, 1
		mov ebx, 0
		int 80h
