import math

def genSigContent(dataWidth,sigmoidSize,weightIntSize,inputIntSize):
    f = open("sigContent.mif","w")
    fractBits = sigmoidSize-(weightIntSize+inputIntSize) 
    if fractBits < 0: 
        fractBits = 0
    x = -2**(weightIntSize+inputIntSize-1)
    for i in range(0,2**sigmoidSize):
        y = sigmoid(x)
        z = DtoB(y,dataWidth,dataWidth-inputIntSize)       
        f.write(z+'\n')
        x=x+(2**-fractBits)
    f.close()

def DtoB(num,dataWidth,fracBits):
    if num >= 0:
        num = num * (2**fracBits)
        num = int(num)
        e = bin(num)[2:]
    else:
        num = -num
        num = num * (2**fracBits)
        num = int(num)
        if num == 0:
            d = 0
        else:
            d = 2**dataWidth - num
        e = bin(d)[2:]
    return e
    
    
def sigmoid(x):
    try:
        return 1 / (1+math.exp(-x))
    except:
        return 0
        
        
if __name__ == "__main__":
    genSigContent(dataWidth=16,sigmoidSize=5,weightIntSize=4,inputIntSize=1)