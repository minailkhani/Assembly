## assembler and disassembler 
assembler and disassembler are implemented in python and assembly language (4 projects)

instructions:

![image](https://user-images.githubusercontent.com/83788223/208305782-5f69c56e-050a-466d-b481-bfd03fffaeb7.png)

(8, 16, 32, 64 bit)


check [instruction-formats-and-encodings.pdf](https://github.com/minailkhani/Assembly/blob/main/Projects/instruction-formats-and-encodings.pdf) and https://defuse.ca/online-x86-assembler.htm

#### assembler test case:
input1:  \
imul cx,WORD PTR [r11*2+0x0]  \
output1: \
66420faf0c5d00000000 

input2: \
xadd rcx,rbp \
output2: \
480fc1e9 

#### disassembler test case:
input1: \
6703940b67543432 \
output1: \
add edx,DWORD PTR [ebx+ecx*1+0x32345467] 

input2: \
f9 \
output2: \
stc 
