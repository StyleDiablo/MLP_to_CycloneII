import sys
import numpy as np
from sklearn import datasets

outputPath = "./test_data/"
headerFilePath = "./test_data/"

dataWidth = 16  
IntSize = 1    

def DtoB(num, dataWidth, fracBits):
    if num >= 0:
        num = num * (2 ** fracBits)
        d = int(num)
    else:
        num = -num
        num = num * (2 ** fracBits)
        num = int(num)
        if num == 0:
            d = 0
        else:
            d = 2 ** dataWidth - num
    return d

def genTestData(dataWidth, IntSize):
    digits = datasets.load_digits()

    dataHeaderFile = open(headerFilePath + "dataValues.h", "w")
    dataHeaderFile.write("int dataValues[]={")

    num_samples = len(digits.images)
    for idx, image in enumerate(digits.images):
        fileName = f"test_data_{idx:04d}.txt"  # Adjusted line
        f = open(outputPath + fileName, "w")

        for row in image:
            for pixel in row:
                dInDec = DtoB(pixel, dataWidth, dataWidth - IntSize)
                myData = bin(dInDec)[2:]
                f.write(myData + "\n")

        label_binary = bin(digits.target[idx])[2:]
        f.write(label_binary)
        f.close()

        dataHeaderFile.write(f"{idx}, ")
    
    dataHeaderFile.write("0};\n")
    dataHeaderFile.write(f"int result[]={','.join(map(str, digits.target))};\n")
    dataHeaderFile.close()


if __name__ == "__main__":
    genTestData(dataWidth, IntSize)
