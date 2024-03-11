import strutils

proc hashAlgorithm(str: string): int =
    var value: int = 0
    for c in str:
        value = ((ord(c) + value) * 17) mod 256
    result = value

##########

let fileName = "day15_input.txt"
let file = open(fileName, fmRead)

var sumOfResult: int = 0
let strList = file.readLine().split(',')
close(file)

for str in strList:
    sumOfResult += hashAlgorithm(str)
echo sumOfResult
