import re
from opcode_dict import *

global input_split_space
global binary_ans
binary_ans = ""

class Reg:
    def __init__(self, name):
        self.code = regDict[name][0]
        self.numOfBit = regDict[name][1]
        self.isNew = regDict[name][2]

class Mmry:
    def __init__(self, bse, index, scale, dsp, memSize, addressSize ):  #memSize : QWORD,WORD,...   addressSize: Size of reg
        self.index, self.scale, self.dsp, self.addressSize, self.bse = None, None, None, None, None
        
        if index != '':
            self.index = Reg(index)            
        
        if scale != '':
            self.scale = scaleDict[scale]
        
        if dsp != '':
            self.dsp = dsp
        
        if bse != '':
            self.bse = Reg(bse)

        self.memSize = memSize
        self.addressSize = addressSize

class Rex :
    def __init__(self, reg1:Reg = False, reg2:Reg = False, mem:Mmry = False, sib = False ) :
        self.start = '0100 '
        self.w, self.r, self.x, self.b = '0 ', '0 ', '0 ', '0 '
        if reg1 and reg2 :
            self.r = reg2.isNew
            self.b = reg1.isNew

        elif not sib and mem and reg1 :
            self.r = reg1.isNew
            self.b = mem.bse.isNew

        elif reg1 and mem :
            self.r = reg1.isNew
            if mem.bse :
                self.b = mem.bse.isNew
            if mem.index :
                if mem.index != '' :
                    self.x = mem.index.isNew
        elif mem:
            if mem.bse :
                self.b = mem.bse.isNew
            if mem.index:
                if mem.index != '' :
                    self.x = mem.index.isNew
        elif reg1:
            self.b = reg1.isNew

        self.w = get_rex_w(reg1 ,mem)
        if sib and mem :
            if mem.index:
                if mem.index != '' :
                    self.x = mem.index.isNew

    def get_whole_rex(self):
        return self.start + self.w + self.r + self.x + self.b

def binary_to_hex(binNum) :
    binNum = binNum.replace(" ", '')
    intNum = int(binNum, 2)
    hexNum = hex(intNum)
    return hexNum[3:]   #remove 0xF

def get_prefix(opSize = 0, addressSize = 0 ) :
    ans = ''
    if addressSize > 16  and addressSize <= 32 :
        ans += '0110 0111 ' #67
    if opSize == 16 :
        ans += '0110 0110 ' #66
    return ans

def get_code_w(op: Reg) :
    if op.numOfBit >= 16 :
        return '1 '
    return '0 '

def get_rex_w(op: Reg = None, mem:Mmry = None ) :
    if op :
        if op.numOfBit < 64  :
            return '0 '
    elif mem :
        if memorySize[mem.memSize] <= 32  :
            return '0 '
    return '1 '

def is_sign(data, bse):
    if int(data, bse) >= 0 :
        return '1 '
    else:
        return '0 '

def to_binary_fit(num, reg:Reg = None, mem:Mmry = None ):
    lenn = 0
    ans = ''
    if num[:2] == '0x':
        num = num[2:]
        integerr = int (num, 16)
    else:
        integerr = num
    
    binary = bin(int(integerr))[2:]

    if int(binary,2) <= int('11111111',2):
        lenn = 8
    
    elif mem:
        lenn = memSize[mem.memSize]    
    elif reg:
            lenn = reg.numOfBit
    else :
        lenn = 32

    for _ in range(lenn-len(binary)):
        binary = '0'+binary
    for i in range(0, lenn-1, 8):
        ans += binary[-8:] + ' '
        binary = binary[:-8]
    
    return ans

def memory_spliter(string) : #string : ...,[...],... -> [base+index*scale+disp]
    i = string.find('[')
    j = string.find(']')
    mem_list = re.split("\+",string[i+1:j])
    bse, index, scale, dsp, addressSize = '', '', '', '' , None
    a1,a2 = 0, 0
    if mem_list[0] in regDict.keys():              # base...
        bse = mem_list[0]
        
        if len(mem_list) >= 2:                     # not anly base
            if mem_list[1][:2] != '0x':            # base, index*scale... 
                a = re.split('\*', mem_list[1])
                index = a[0]
                scale = a[1]
                if len(mem_list) == 3:             # base, index*scalse,disp
                    dsp = mem_list[-1]
            else:                                  # base, disp
                dsp = mem_list[-1]
    
    elif mem_list[0][:2] != '0x':
        a = re.split('\*', mem_list[0])
        index = a[0]
        scale = a[1]
        if len(mem_list) == 2:
            dsp = mem_list[-1]
    else:
        dsp = mem_list[0]
    if bse != '':
        a1 = regDict[bse][1]
    if index != '':
        a2 = regDict[index][1]
    return bse, index, scale, dsp, max(a1,a2)

def zero_op(instruction) :
    return DandOpcodeDict[instruction]

def get_sib(mem:Mmry):
    if mem.scale != None:
        ss = mem.scale + ' '
    else:
        ss = '00 '
    if mem.index != None :
        inx = mem.index.code
    else: 
        inx = '100 '
    if mem.bse != None:
        bas = mem.bse.code
    else:
        bas = '101 '

    return ss + inx + bas

def hex_to_binary_fit(hexNum, lenn ):
    ans = ''
    integer = int (hexNum, 16)
    binary = bin(integer)[2:]

    for _ in range(lenn-len(binary)):
        binary = '0'+binary
    
    for i in range(0, lenn-1, 8):
        ans += binary[-8:] + ' '
        binary = binary[:-8]
        
    return ans

def get_disp_len(mem:Mmry):
    lenn = 0
    if mem.bse == None :
        lenn = 32
    elif mem.bse.code == "101 ": 
        lenn = 8
    else: 
        lenn = 0
    if mem.dsp != None and lenn != 32 :
        l = (len(mem.dsp)-2)*4
        if l <= 8:
            lenn = 8
        elif l <= 32:
            lenn = 32
        elif l <= 64:
            lenn = 64
    return lenn

def get_disp(mem:Mmry):
    lenn = get_disp_len(mem)

    if lenn == 0:
        return ''
    if mem.dsp != None:
        return hex_to_binary_fit(mem.dsp, lenn)
    else:
        return hex_to_binary_fit('0', lenn)

def get_opcode_D_W(instruction, whatTOwhat = None, reg:Reg = None, mem:Mmry = None ) :
    if whatTOwhat :
        if reg :
            return DandOpcodeDict[instruction][whatTOwhat] + get_code_w (reg )
        return DandOpcodeDict[instruction][whatTOwhat] + '0 '
    else:
        if reg :
            return DandOpcodeDict[instruction] + get_code_w(reg )
        if mem :
            if memorySize[mem.memSize] >=16 :
                return DandOpcodeDict[instruction] + '1 '

    return DandOpcodeDict[instruction] + '0 '
    
def get_mod_regoP_RM(mod , mem:Mmry, sib, reg:Reg = None,instruction = None) :
    if reg:
        if  not sib :
            return mod + reg.code + mem.bse.code
        return mod + reg.code + '100 '
    else:
        if  not sib :
            return mod + imToRegDict[instruction] + mem.bse.code
        return mod + imToRegDict[instruction] + '100 '

def need_rex(reg1:Reg = False, reg2:Reg = False, mem:Mmry = False, ) :
    
    if reg1 :
        if int(reg1.isNew) or reg1.numOfBit == 64 :
            return True
    if reg2 :
        if int(reg2.isNew) or reg1.numOfBit == 64 :
            return True
    if mem :
        if mem.memSize == 'QWORD' :
            return True
        if mem.bse :
            if int(mem.bse.isNew)  :
                return True
        if mem.index:
            if int(mem.index.isNew):
                return True
    return False

def get_rex(reg1:Reg = False, reg2:Reg = False, mem:Mmry = False, sib = False) :

    if need_rex(reg1=reg1, reg2=reg2, mem=mem) :
        rex = Rex(reg1, reg2, mem, sib)
        rex= rex.get_whole_rex()
    else:
        rex = ''
    return rex

def get_mod_mem_reg(mem:Mmry, dsp = None) :   #just get mod
    if ((mem.dsp == '' or mem.dsp == None ) and (dsp == '' or dsp == None))     or     ((mem.bse == '' or mem.bse == None) 
        and (mem.index != '' or mem.index != None) 
        and (mem.dsp != '' or mem.dsp != None) 
        and (mem.dsp != '' or mem.dsp != None)):
        return '00 '
    if not(mem.dsp == '' or mem.dsp == None ) :
        if len(mem.dsp)-2 <= 2 :
            return '01 '

    if not(dsp == '' or dsp == None ) :
        if len(dsp) <= 9 :
            return '01 '
    return '10 '
    
def reg_mem(instruction, reg:Reg, mem:Mmry, r_m): 

    prefix = get_prefix(reg.numOfBit, mem.addressSize)
    dsp_bin_fix = get_disp(mem)
    if (mem.dsp == None and mem.index == None) or (dsp_bin_fix != None and mem.index == None and mem.bse != None) :
        sib = ''
    else:
        sib = get_sib(mem)
    if sib == '' :
        modRegoPRM = get_mod_regoP_RM(get_mod_mem_reg(mem,dsp_bin_fix), mem, False, reg)
        rex = get_rex(reg1=reg, mem=mem)
    else:
        modRegoPRM = get_mod_regoP_RM(get_mod_mem_reg(mem, dsp_bin_fix), mem, True, reg)
        rex = get_rex(reg1=reg, mem=mem, sib=sib)


    if instruction == 'imul':
        return prefix + rex + '0000 1111 1010 1111' + modRegoPRM + sib + dsp_bin_fix
    opcodeAndDAndW = get_opcode_D_W(instruction, r_m, reg)
    if instruction == 'bsf' or instruction == 'bsr':
        return prefix + rex +opcodeAndDAndW[:-2] + modRegoPRM + sib + dsp_bin_fix
    
    return     prefix + rex + opcodeAndDAndW     + modRegoPRM + sib + dsp_bin_fix

def reg_to_reg(instruction, reg1: Reg, reg2:Reg):  
    prefix = get_prefix(op1.numOfBit)
    mod_reg_reg = "11 " + op2.code + op1.code
    
    rex = get_rex(reg1=reg1, reg2=reg2 )

    if instruction == 'imul':
        rex = get_rex(reg1=reg2, reg2=reg1 )
        return prefix + rex + '0000 1111 1010 1111   11 ' +  op1.code + op2.code
    elif instruction == 'bsf' or instruction == 'bsr':
        opcodeAndDAndW = get_opcode_D_W(instruction, 'r to r', reg1)
        return prefix + rex + opcodeAndDAndW[:-2] + "11 " + op1.code + op2.code
    opcodeAndDAndW = get_opcode_D_W(instruction, 'r to r', reg1)
    return     prefix + rex + opcodeAndDAndW + mod_reg_reg

def im_to_reg(instruction, reg: Reg, im):   
    prefix = get_prefix(reg.numOfBit)
    
    if instruction == 'shr' or instruction == 'shl':
        return shft(instruction,im=im,reg = reg,prefix=prefix)


    opcodeAndD = DandOpcodeDict[instruction]["i to r"]
    rex = get_rex(reg1=reg)
    ans = prefix + rex + opcodeAndD
    if instruction == "mov" :
        ans += get_code_w(reg)

    else:
        if instruction != 'test' :
            ans += '0 '
        ans += get_code_w(reg) + ' 11 '
        ans += imToRegDict[instruction]

    ans += reg.code
    
    ans += to_binary_fit(im, reg)  
    return ans

def one_op_mem(mem:Mmry) :                       

    prefix = get_prefix(memorySize[mem.memSize], mem.addressSize)

    
    opcodeAndDandW =  get_opcode_D_W(instruction , mem=mem)
    dsp = get_disp(mem)
    if (mem.dsp == None and mem.index == None) or (dsp != None and mem.index == None and mem.bse != None) :
            sib = ''
    else:
            sib = get_sib(mem)
    if sib == '' :
        modRegoPRM = get_mod_regoP_RM(get_mod_mem_reg(mem, dsp), mem, False, instruction= instruction)
        rex = get_rex(mem=mem)
    else:
        modRegoPRM = get_mod_regoP_RM(get_mod_mem_reg(mem, dsp), mem, True, instruction=instruction)
        rex = get_rex(mem=mem, sib=sib)

    return prefix + rex + opcodeAndDandW + modRegoPRM + sib + dsp

def one_op_reg(reg:Reg) :  

    prefix = get_prefix(reg.numOfBit)

    opcodeAndDAndW = get_opcode_D_W(instruction, reg=reg)
    mod_reg_reg = "11 " +imToRegDict[instruction] + reg.code
    
    rex = get_rex(reg1=reg )
    return prefix + rex + opcodeAndDAndW + mod_reg_reg

def shft(instruction, im = None, mem:Mmry = None, reg:Reg = None, prefix= '' ) : # not one op
    imfix = to_binary_fit(im)
    if mem :
        opcodeAndDAndW = get_opcode_D_W('sh im', mem=mem)
        dsp = get_disp(mem)
        sib = get_sib(mem)
        rex = get_rex(reg1=reg, mem=mem, sib=sib)
        
        modMemReg = get_mod_mem_reg(mem, dsp)
        return prefix + rex + opcodeAndDAndW + modMemReg   + imfix + sib

    elif reg:
        if im == '1' :
            return one_op_reg(reg)
        opcodeAndDAndW = get_opcode_D_W('sh im', reg=reg)
        sib = ''
        rex = get_rex(reg1=reg)
        return prefix + rex + opcodeAndDAndW + '11' +imToRegDict[instruction] + reg.code + imfix +sib

def im_to_mem(im, mem:Mmry):
    prefix = get_prefix(0, mem.addressSize)
    if instruction == 'shr' or instruction == 'shl' :
        return shft(instruction,im=im ,mem=mem, prefix=prefix)
    opcodeAndDAndW = get_opcode_D_W(instruction, 'i to m')
    dsp_bin_fix = get_disp(mem)
    return # 

input_split_space = re.split(' ',input())
instruction = input_split_space[0]

binary_ans += '1111 ' #If I don't add 1111, I'll lose 0 in codes which start with 0
if len(input_split_space) == 1:
    binary_ans += zero_op(instruction)

elif input_split_space[1] in memorySize.keys() :
    memSize = input_split_space[1]
    bse, index, scale, dsp, addressSize = memory_spliter(input_split_space[-1])
    mem = Mmry(bse, index, scale, dsp, memSize, addressSize)
    
    if len(input_split_space) == 3 or len(re.split('\,', input_split_space[-1])) == 1 :
        binary_ans += one_op_mem(mem)
    elif re.split(',',input_split_space[-1])[-1] in regDict.keys():
        binary_ans += reg_mem(instruction,Reg(re.split(',',input_split_space[-1])[-1]), mem, 'r to m' )
    else:
        binary_ans += im_to_mem(re.split(',',input_split_space[-1])[-1], mem)

elif len(input_split_space) != 2 :
    memSize = re.split('\,', input_split_space[1])[-1]
    bse, index, scale, dsp, addressSize = memory_spliter(input_split_space[-1])
    mem = Mmry(bse, index, scale, dsp, memSize, addressSize )
    binary_ans += reg_mem(instruction, Reg(re.split(',',input_split_space[1])[0]),mem , 'm to r')

elif re.split(',',input_split_space[-1])[-1] in regDict.keys() :
    splited_op = re.split(',', input_split_space[-1] )
    if len(splited_op) == 1:
        binary_ans += one_op_reg(Reg(splited_op[0]))
    else:
        op1 = Reg(splited_op[0])
        op2 = Reg(splited_op[1])

        binary_ans += reg_to_reg(instruction, op1, op2 )
    
else:
    splited_op = re.split(',', input_split_space[-1] )
    op1 = Reg(splited_op[0])
    op2 = splited_op[1]

    binary_ans += im_to_reg(instruction, op1, op2)

print('bin:', binary_ans, '(separated by functionality)')
print('hex:', binary_to_hex(binary_ans))