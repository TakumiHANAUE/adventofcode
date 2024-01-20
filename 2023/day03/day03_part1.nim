import strutils

type
    LinePos = enum
        BEFORE_LINE = 0,
        THIS_LINE,
        AFTER_LINE

proc shiftBuf(buf: var array[3, string], newLine: string): void =
    buf[0] = buf[1]
    buf[1] = buf[2]
    buf[2] = newLine

# proc echoBuf(buf: array[3, string]): void =
#     echo ""
#     for i in 0 .. buf.high:
#         echo buf[i]

proc isPartNumber(buf: array[3, string], leftEdgeIndex, rightEdgeIndex: int): bool =
    result = false
    # buf[0], buf[2]
    for i in leftEdgeIndex .. rightEdgeIndex:
        if buf[0][i] != '.':
            result = true
        if buf[2][i] != '.':
            result = true
    # buf[1]
    if buf[1][leftEdgeIndex] != '.':
        result = true
    if buf[1][rightEdgeIndex] != '.':
        result = true

proc extractPartNumber(buf: array[3, string]): seq[int] =
    result = @[]
    var startIndex: int = 0
    var endIndex: int = 0
    var digitStarted: bool = false
    for i, c in buf[1]:
        if not digitStarted and isDigit(c):
            digitStarted = true
            startIndex = i
        if digitStarted and not isDigit(c):
            digitStarted = false
            endIndex = i - 1
            # get part number candidate
            let num = parseInt(buf[1][ startIndex..endIndex ])
            # if it is part number, add num to result
            if isPartNumber(buf, (startIndex-1), (endIndex+1)):
                result.add(num)
            # reset startIndex
            startIndex = 0
            endIndex = 0

###############

let inputFile = open("./day03_input.txt", fmRead)

# get length of 1 line
# insert '.' into first and last 
let length = inputFile.readLine.len + 2
inputFile.setFilePos(0)

# initialize buffer
var buf: array[3, string] = ["", "", ""]
for lp in LinePos:
    buf[ord(lp)] = repeat('.', length)

# get part number
var totalPartNumber: int = 0
for line in inputFile.lines:
    shiftBuf(buf, '.' & line & '.')
    let partNumbers = extractPartNumber(buf)
    for n in partNumbers:
        totalPartNumber += n

# get part number for last line
shiftBuf(buf, repeat('.', length))
let partNumbers = extractPartNumber(buf)
for n in partNumbers:
    totalPartNumber += n

echo totalPartNumber
