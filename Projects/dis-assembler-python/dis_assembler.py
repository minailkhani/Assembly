from opcode_dict import *

class Rex:
    def __init__(self, string):
        self.start = '0100'
        self.w = string[4]
        self.r = string[5]
        self.x = string[6]
        self.b = string[7]

class Opcode:
    def __init__(self,string):
        self.len = 0
        self.opcodeSDic = set
        self.name = ''
        if string[:6] in twoOpImDict.keys() :
            self.opcodeSDic = self.opcodeSDic.union(twoOpImDict[string[:6]])
            self.DS = string[6]
            self.len = 8
            self.w = string[7]

        if string[:6] in twoOpNoImDict.keys() :
            self.opcodeSDic = self.opcodeSDic.union(twoOpNoImDict[string[:6]])
            self.DS = string[6]
            self.len = 8
            self.w = string[7]

        if string[:6] in oneOpDict.keys() :
            self.opcodeSDic = self.opcodeSDic.union(oneOpDict[string[:6]])
            self.DS = string[6]
            self.len = 8
            self.w = string[7]

        if string[:15] in twoOpNoImDict.keys() :
            self.opcodeSDic = self.opcodeSDic.union(twoOpNoImDict[string[:15]])
            self.DS = string[15]
            self.len = 16
            self.w = string[15]

        elif string[:16] in twoOpNoImDict.keys() :
            self.opcodeSDic = self.opcodeSDic.union(twoOpNoImDict[string[:16]])
            self.DS = string[16]
            self.len = 16
            self.w = string[15]

        elif string[:4] in twoOpImDict.keys() :   #mov
            self.opcodeSDic = self.opcodeSDic.union(twoOpImDict[string[:4]])
            self.DS = string[4]
            self.len = 6
            self.w = string[5]
        
class ModRegOpRM():
    def __init__(self, string) :
        self.mod = string[:2]
        self.RegOp = string[2:5]
        self.RM = string[5:8]

class Sib():
    def __init__(self,string) :
        self.scale = string[:2]
        self.index = string[2:5]
        self.bse = string[5:8]
        
class machine_code :
    def __init__(self, machineCodeBin) :
        self.machineCodeBin = machineCodeBin
        self.prefix66 = None
        self.prefix67 = None
        self.rex = None
        self.sib = None
        self.dsp = None
        self.imData = None

        self.set_prefix()
        self.set_rex()
        self.set_opcode()
        self.set_ModReg_OpRM()
        self.set_sib()
        self.set_dsp_im()

    def set_prefix(self) :
        if self.machineCodeBin[:8] == '01100111' :
            self.prefix67 = True
            self.machineCodeBin = self.machineCodeBin[8:]
        if self.machineCodeBin[:8] == '01100110' :
            self.prefix66 = True
            self.machineCodeBin = self.machineCodeBin[8:]

    def set_rex(self):
            if self.machineCodeBin[:4] == '0100':
                self.rex = Rex(self.machineCodeBin)
                self.machineCodeBin = self.machineCodeBin[8:]

    def set_opcode(self):
        self.opcode = Opcode(self.machineCodeBin)
        self.machineCodeBin = self.machineCodeBin[self.opcode.len:]
    
    def set_ModReg_OpRM(self):
        self.ModRegOpRM = ModRegOpRM(self.machineCodeBin)
        self.machineCodeBin = self.machineCodeBin[8:]
        
    def set_sib(self):
        if self.ModRegOpRM.RM == '100' :
            self.sib = Sib(self.machineCodeBin)
            self.machineCodeBin = self.machineCodeBin[8:]

    def set_dsp_im(self):
        if self.ModRegOpRM.mod == '10' or (self.ModRegOpRM.mod == '00' and self.sib and self.sib.bse == '101'):
            
            self.dsp = bin_to_hex_fit(self.machineCodeBin[:32])
            self.machineCodeBin = self.machineCodeBin[32: ]

        if self.ModRegOpRM.mod == '01':
            self.dsp = bin_to_hex_fit(self.machineCodeBin[:8])
            self.machineCodeBin = self.machineCodeBin[8:]
        if self.machineCodeBin != '' :
            self.imData = self.machineCodeBin
class Reg:
    def __init__(self, isNew, name ):
        self.name = name
        self.isNew = isNew

class Mmry:
    def __init__(self,Size, addressSize ):
        self.index, self.scale, self.dsp , self.bse = None, None, None,None
        self.addressSize, self.Size = addressSize,Size
        bseName,indexName = '', '', 
        bseIsNew   = '0'
        indexIsNew = '0'
        if code.rex :
            bseIsNew = code.rex.b
        if code.rex :
            indexIsNew = code.rex.x

        if code.sib:
            if not(code.ModRegOpRM.mod == '00' and code.sib.bse == '101') :
                bseName = regCodeDict[code.sib.bse][bseIsNew][indexSizeDict[addressSize]]  
                self.bse  = Reg(isNew = bseIsNew, name=bseName   )
            if code.sib.index != '100' or ( code.rex and code.rex.x == '1') :
                indexName = regCodeDict[code.sib.index][indexIsNew][indexSizeDict[addressSize]] 
                self.index = Reg(isNew = indexIsNew, name=indexName)
                self.scale = scaleDict[code.sib.scale]
            if code.dsp :
            # if code.dsp and code.sib.bse == '101' :
                self.dsp = code.dsp
        else:
            bseName = regCodeDict[code.ModRegOpRM.RM][bseIsNew][indexSizeDict[self.addressSize]]
            self.bse  = Reg(isNew = bseIsNew, name=bseName   )
            if code.dsp:
                self.dsp = code.dsp

    def prnt(self):
        ans = memoSizeDict[self.Size] + ' PTR ['
        if self.bse :
            ans += self.bse.name
    
            if self.index :
                ans += '+' + self.index.name +'*'+str(self.scale)
            
            if self.dsp :
                ans += '+' + self.dsp
        elif self.index :
            ans += self.index.name + '*' + str(self.scale)
            if self.dsp :
                ans += '+' +self.dsp
        else:
            ans += self.dsp
        return ans + ']'

class Whole_instraction():
    def __init__(self, code:machine_code) :
        self.mem = None
        self.op1 = None
        self.op2 = None
        self.opSize = self.get_op_size()

        if code.prefix67 or code.ModRegOpRM.mod != '11':    #mem...
            if code.prefix67:
                self.mem = Mmry(Size=self.opSize,addressSize=32)
            else:
                self.mem = Mmry(Size=self.opSize,addressSize=64)



        if code.imData:                                     #imm...
            self.opcodename = (code.opcode.opcodeSDic).intersection(imToRegDict[code.ModRegOpRM.RegOp]).pop()
            
            if self.mem :                                   #mem_imm
                self.op1 = self.mem.prnt()
                self.op2 = im_to_hex(code.imData)
                return

            else:                                           #im_reg
                
                if code.rex:
                    isNew = code.rex.b
                else:
                    isNew = '0'
                self.rm_reg = Reg( isNew=isNew, name = regCodeDict[code.ModRegOpRM.RM][isNew][indexSizeDict[self.opSize]] )
                self.op1 = self.rm_reg.name
                self.op2 = im_to_hex(code.imData)
                return

        for d in oneOpDict.values():
            if d.intersection(code.opcode.opcodeSDic) and list(code.opcode.opcodeSDic)[0] != 'imul' :   
                if self.mem:                                 #one op mem
                    self.op1 = self.mem.prnt()
                    self.opcodename = code.opcode.opcodeSDic.intersection(imToRegDict[code.ModRegOpRM.RegOp]).pop()
                    return
                
                else:                                        #one op reg
                    if code.rex:
                        isNew1 = code.rex.b
                    else:
                        isNew1 = '0'  
                    self.op1 = regCodeDict[code.ModRegOpRM.RM][isNew1][indexSizeDict[self.opSize]]
                    self.opcodename = code.opcode.opcodeSDic.intersection(imToRegDict[code.ModRegOpRM.RegOp]).pop()
                    return
      
        if not self.mem :
            for d in twoOpNoImDict.values():
                if d.intersection(code.opcode.opcodeSDic) :   #reg reg
                    self.opcodename = code.opcode.opcodeSDic.pop()
                    
                    if code.rex:
                        isNew1 = code.rex.r
                        isNew2 = code.rex.b
                    else:
                        isNew1 = '0'          
                        isNew2 = '0'
                    self.op2 = regCodeDict[code.ModRegOpRM.RegOp][isNew1][indexSizeDict[self.opSize]]
                    self.op1 = regCodeDict[code.ModRegOpRM.RM]   [isNew2][indexSizeDict[self.opSize]]
                    return
        


        if self.mem and code.opcode.opcodeSDic in twoOpNoImDict.values():  #reg_mem

            if code.rex:
                isNew = code.rex.r 
            else:
                isNew = '0'
            self.opcodename = code.opcode.opcodeSDic.pop()
           
            self.op1 = self.mem.prnt()
            self.op2 = Reg(isNew=isNew,name = regCodeDict[code.ModRegOpRM.RegOp][isNew][indexSizeDict[self.opSize]]).name

            if code.opcode.DS == '1':
                self.op1, self.op2 = self.op2, self.op1

            return

        
        if code.opcode.opcodeSDic == {'shr', 'shl'} :
            self.opcodename = (code.opcode.opcodeSDic).intersection(imToRegDict[code.ModRegOpRM.RegOp]).pop()
            
            if self.mem :                                   
                self.op1 = self.mem.prnt()
                self.op2 = im_to_hex(code.imData)
                return

            else:                                           
                if code.rex:
                    isNew = code.rex.b
                else:
                    isNew = '0'
                self.rm_reg = Reg( isNew=isNew, name = regCodeDict[code.ModRegOpRM.RM][isNew][indexSizeDict[self.opSize]] )
                self.op1 = self.rm_reg.name
                self.op2 = '1'
                return

        


    def prnt(self):
        if self.op1 and self.op2:
            print(self.opcodename+ ' ' + self.op1+ ',' + self.op2 )
        else:
            print(self.opcodename + ' ' + self.op1)
        
    def get_op_size(self):
        if code.prefix66:
            return 16
        elif code.rex != None and code.rex.w != '0' :
            return 64
        elif code.opcode.w == '0':
            return 8
        return 32

    def fix_exceptions(self):
        if (self.mem and self.opcodename == 'xadd') or (self.opcodename == 'bsf' or self.opcodename == 'bsr') or (self.opcodename == 'imul' ) :
            self.op1, self.op2 = self.op2, self.op1
        if self.opcodename == 'test' and code.opcode.DS == '1':
            self.opcodename = 'xchg'
        

def im_to_hex(im):
    ans = ''
    while im:
        ans += im[-8:]
        im = im[:-8]
        
    return hex(int(ans,2))

def hex_to_bin_fix(strHex):
    strBin = bin(int(strHex,16))[2:]
    if len(strBin)%8:
        strBin = '0'*(8 - len(strBin)%8 ) + strBin
    return strBin

def bin_to_hex_fit(strBin) :
    ans = ''
    for i in range(0, len(strBin), 8):
        ans = strBin[i: i+8] + ans
    return hex(int(ans, 2))


machineCodeBin = ((hex_to_bin_fix(input())))
if machineCodeBin in zeroOpDict.keys():
    print(zeroOpDict[machineCodeBin])

else:
    code = machine_code(machineCodeBin)
    w = Whole_instraction(code)
    w.fix_exceptions()
    w.prnt()