import json

dataWidth = 8
dataIntWidth = 1
weightIntWidth = 4
inputFile = "weightsandbiases.txt"
dataFracWidth = dataWidth - dataIntWidth
weightFracWidth = dataWidth - weightIntWidth
biasIntWidth = dataIntWidth + weightIntWidth
biasFracWidth = dataWidth - biasIntWidth
outputPath = "./w_b/"
headerPath = "./"

def DtoB(num, intWidth, fracWidth):
    fixedPoint = int(num * (2 ** fracWidth))
    maxVal = (2 ** (intWidth + fracWidth)) - 1
    minVal = -(2 ** (intWidth + fracWidth))
    if fixedPoint > maxVal:
        fixedPoint = maxVal
    elif fixedPoint < minVal:
        fixedPoint = minVal
    if fixedPoint < 0:
        fixedPoint += 2 ** (intWidth + fracWidth)
    binary = format(fixedPoint, f'0{intWidth + fracWidth}b')
    return binary


def genWaitAndBias(dataWidth, weightIntWidth, weightFracWidth, biasIntWidth, biasFracWidth, inputFile):
    myDataFile = open(inputFile, "r")
    myData = myDataFile.read()
    myDict = json.loads(myData)
    myWeights = myDict['weights']
    myBiases = myDict['biases']

    weightHeaderFile = open(headerPath + "weightValues.h", "w")
    weightHeaderFile.write("int weightValues[] = {\n")
    for layer, weights_layer in enumerate(myWeights):
        for neuron, weights_neuron in enumerate(weights_layer):
            fi = f'w_{layer + 1}_{neuron}.txt'
            with open(outputPath + fi, 'w') as f:
                for weight in weights_neuron:
                    if 'e' in str(weight):
                        p = '0' * dataWidth
                    else:
                        if weight > 2 ** (weightIntWidth - 1):
                            weight = 2 ** (weightIntWidth - 1) - 2 ** (-weightFracWidth)
                        elif weight < -2 ** (weightIntWidth - 1):
                            weight = -2 ** (weightIntWidth - 1)
                        p = DtoB(weight, weightIntWidth, weightFracWidth)
                    f.write(p + '\n')
                    weightHeaderFile.write(str(int(p, 2)) + ',')
    weightHeaderFile.write('0\n};\n')
    weightHeaderFile.close()

    biasHeaderFile = open(headerPath + "biasValues.h", "w")
    biasHeaderFile.write("int biasValues[] = {\n")
    for layer, biases_layer in enumerate(myBiases):
        for neuron, bias in enumerate(biases_layer):
            fi = f'b_{layer + 1}_{neuron}.txt'
            p = bias[0]
            if 'e' in str(p):
                res = '0' * dataWidth
            else:
                if p > 2 ** (biasIntWidth - 1):
                    p = 2 ** (biasIntWidth - 1) - 2 ** (-biasFracWidth)
                elif p < -2 ** (biasIntWidth - 1):
                    p = -2 ** (biasIntWidth - 1)
                res = DtoB(p, biasIntWidth, biasFracWidth)
            with open(outputPath + fi, 'w') as f:
                f.write(res)
                biasHeaderFile.write(str(int(res, 2)) + ',')
    biasHeaderFile.write('0\n};\n')
    biasHeaderFile.close()

if __name__ == "__main__":
    genWaitAndBias(dataWidth, weightIntWidth, weightFracWidth, biasIntWidth, biasFracWidth, inputFile)
