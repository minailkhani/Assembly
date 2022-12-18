imToRegDict = { "add" : "000 ", "adc" : "010 ", "sub" : "101 ", "sbb" : "011 ",
                "and" : "100 ", "or"  : "001 ", "xor" : "110 ", "cmp" : "111 ",  
                "shr" : '101' , "shl" : '100' , "neg" : "011 ", "not" : "010" , 
                "push": "110" , "pop" : "000" , "inc" : "000 ", "dec" : "001" ,
                "idiv": "111" , "mov" : "000" , "test": "000"
    }

scaleDict = {"1" : "00", "2" : "01", "4" : "10", "8" : "11" }

memorySize = {"BYTE": 8, "WORD": 16, "DWORD": 32, "QWORD": 64}

DandOpcodeDict = {
    "mov" : { 
        "r to r" : "1000 10 0 ",
        "m to r" : "1000 10 1 ",
        "r to m" : "1000 10 0 ",
        "i to r"    : "1011 " ,
        "i to m" : "1100 01 1 " 
    },                
    "add" : { 
        "r to r" : "0000 00 0 ",
        "m to r" : "0000 00 1 ",
        "r to m" : "0000 00 0 ",
        "i to r" : "1000 00 " ,
        "i to m" : "1000 00 "
    },
    "adc" : { 
        "r to r" : "0001 00 0 ",
        "m to r" : "0001 00 1 ",
        "r to m" : "0001 00 0 ",
        "i to r" : "1000 00 " ,
        "i to m" : "1000 00 "
    },
    "and" : {
        "r to r" : "0010 00 0 ",
        "m to r" : "0010 00 1 ",
        "r to m" : "0010 00 0 ",
        "i to r" : "1000 00 " ,
        "i to m" : "1000 00 "
    },
    "or": {
        'r to r': '0000 10 0 ',
        'r to m': '0000 10 0 ',
        'm to r': '0000 10 1 ',
        'r to i': '1000 00 ',
        'm to i': '1000 00 '
    },
    "xor": {
        'r to r': '0011 00 0 ',
        'r to m': '0011 00 0 ',
        'm to r': '0011 00 1 ',
        'r to i': '1000 00 ',
        'm to i': '1000 00 '
    },
    "cmp": {
        'r to r': '0011 10 0 ',
        'r to m': '0011 10 1 ',
        'm to r': '0011 10 0 ',
        'r to i': '1000 00 ',
        'm to i': '1000 00 '
    },
    "sub": {
        'r to r': '0010 10 0 ',
        'r to m': '0010 10 0 ',
        'm to r': '0010 10 1 ',
        'r to i': '1000 00 ',
        'm to i': '1000 00 '
    },
    "sbb": {
        'r to r': '0001 10 0 ',
        'r to m': '0001 10 0 ',
        'm to r': '0001 10 1 ',
        'r to i': '1000 00 ',
        'm to i': '1000 00 '
    
    },
    'xchg' : {
        'r to r': '1000 01 1 ',
        'r to m': '1000 01 1 ',
        'm to r': '1000 01 1 ',
    },

    "test": {
        'r to r': '1000 01 0 ',
        'r to m': '1000 01 0 ',
        'm to r': '1000 01 0 ',
        'r to i': '1111 01 ',
        'm to i': '1111 01 '
    },
    'xadd':{
        'r to r': '0000 1111 1100 000 ',
        'r to m': '0000 1111 1100 000 ',
        'm to r': '0000 1111 1100 000 ',
    },
    'bsf' : {
        'r to r': '0000 1111 1011 1100 ',
        'r to m': '0000 1111 1011 1100 ',
        'm to r': '0000 1111 1011 1100 ',
    
    },
    'bsr': {
        'r to r': '0000 1111 1011 1101 ',
        'r to m': '0000 1111 1011 1101 ',
        'm to r': '0000 1111 1011 1101 ',
    },
    'stc':'1111 1001' ,
    'clc':'1111 1000' ,
    'std':'1111 1101' ,
    'cld':'1111 1100' ,
    'ret':'1100 0011' ,
    
    'inc': '1111 111 ',
    'dec': '1111 111 ',
    'neg': '1111 011 ',
    'not': '1111 011 ',
    'idiv':'1111 011 ',

    "shr": '1101 00 0 ',
    "shl": '1101 00 0 ',

    'sh im': '1100 00 0',

    'syscall' : '0000 1111 0000 0101 ',

    # call	ret	
}

regDict = {   # regName: [code, num of bit, new/old]
    "al":["000 ", 8, '0 '], "ax":["000 ", 16, '0 '],"eax":["000 ", 32, '0 '],"rax":["000 ", 64, '0 '],
    "cl":["001 ", 8, '0 '], "cx":["001 ", 16, '0 '],"ecx":["001 ", 32, '0 '],"rcx":["001 ", 64, '0 '],
    "dl":["010 ", 8, '0 '], "dx":["010 ", 16, '0 '],"edx":["010 ", 32, '0 '],"rdx":["010 ", 64, '0 '],
    "bl":["011 ", 8, '0 '], "bx":["011 ", 16, '0 '],"ebx":["011 ", 32, '0 '],"rbx":["011 ", 64, '0 '],
    "ah":["100 ", 8, '0 '], "sp":["100 ", 16, '0 '],"esp":["100 ", 32, '0 '],"rsp":["100 ", 64, '0 '],
    "ch":["101 ", 8, '0 '], "bp":["101 ", 16, '0 '],"ebp":["101 ", 32, '0 '],"rbp":["101 ", 64, '0 '],
    "dh":["110 ", 8, '0 '], "si":["110 ", 16, '0 '],"esi":["110 ", 32, '0 '],"rsi":["110 ", 64, '0 '],
    "bh":["111 ", 8, '0 '], "di":["111 ", 16, '0 '],"edi":["111 ", 32, '0 '],"rdi":["111 ", 64, '0 '],

    "r8b" :["000 ", 8, '1 '], "r8w" :["000 ", 16, '1 '], "r8d" :["000 ", 32, '1 '], "r8" :["000 ", 64, '1 '],
    "r9b" :["001 ", 8, '1 '], "r9w" :["001 ", 16, '1 '], "r9d" :["001 ", 32, '1 '], "r9" :["001 ", 64, '1 '],
    "r10b":["010 ", 8, '1 '], "r10w":["010 ", 16, '1 '], "r10d":["010 ", 32, '1 '], "r10":["010 ", 64, '1 '],
    "r11b":["011 ", 8, '1 '], "r11w":["011 ", 16, '1 '], "r11d":["011 ", 32, '1 '], "r11":["011 ", 64, '1 '],
    "r12b":["100 ", 8, '1 '], "r12w":["100 ", 16, '1 '], "r12d":["100 ", 32, '1 '], "r12":["100 ", 64, '1 '],
    "r13b":["101 ", 8, '1 '], "r13w":["101 ", 16, '1 '], "r13d":["101 ", 32, '1 '], "r13":["101 ", 64, '1 '],
    "r14b":["110 ", 8, '1 '], "r14w":["110 ", 16, '1 '], "r14d":["110 ", 32, '1 '], "r14":["110 ", 64, '1 '],
    "r15b":["111 ", 8, '1 '], "r15w":["111 ", 16, '1 '], "r15d":["111 ", 32, '1 '], "r15":["111 ", 64, '1 '],
}