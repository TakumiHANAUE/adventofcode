import strutils
import math

let inputFile = open("./day1_input.txt", fmRead)

var calibvalues: seq[int] = @[]
for line in inputfile.lines:
    var twoDigitNum: string = "0"
    for i in countup(0, line.high()):
        if isDigit(line[i]):
            twoDigitNum.add(line[i])
            break
    for i in countdown(line.high(), 0):
        if isDigit(line[i]):
            twoDigitNum.add(line[i])
            break
    calibvalues.add(parseInt(twoDigitNum))

close(inputFile)

echo calibvalues.sum()
