import strutils
import math

type
    LinePos = enum
        BEFORE_LINE = 0,
        THIS_LINE,
        AFTER_LINE

type
    PositionRange = tuple
        startPos: int
        endPos: int


proc shiftBuf(buf: var array[3, string], newLine: string): void =
    buf[0] = buf[1]
    buf[1] = buf[2]
    buf[2] = newLine

# proc echoBuf(buf: array[3, string]): void =
#     echo ""
#     for i in 0 .. buf.high:
#         echo buf[i]

proc getNumberPosition(line: string): seq[PositionRange] =
    result = @[]
    var startIndex: int = 0
    var endIndex: int = 0
    var digitStarted: bool = false
    for i, c in line:
        if not digitStarted and isDigit(c):
            digitStarted = true
            startIndex = i
        if digitStarted and not isDigit(c):
            digitStarted = false
            endIndex = i - 1
            result.add( (startIndex, endIndex) )

proc isPartNumber(buf: array[3, string], leftEdgeIndex, rightEdgeIndex: int): bool =
    result = false
    # buf[0], buf[2]
    for i in leftEdgeIndex .. rightEdgeIndex:
        if buf[ord(BEFORE_LINE)][i] != '.':
            result = true
        if buf[ord(AFTER_LINE)][i] != '.':
            result = true
    # buf[THIS_LINE]
    if buf[ord(THIS_LINE)][leftEdgeIndex] != '.':
        result = true
    if buf[ord(THIS_LINE)][rightEdgeIndex] != '.':
        result = true

proc extractPartNumber(buf: array[3, string]): seq[int] =
    result = @[]
    let numberPositions = getNumberPosition(buf[ord(THIS_LINE)])
    for p in numberPositions:
        if isPartNumber(buf, (p.startPos - 1), (p.endPos + 1) ):
            let num = parseInt(buf[ord(THIS_LINE)][p.startPos..p.endPos])
            result.add(num)

proc isAdjacentToGear(startVal, endVal: int, validRange: seq[int], ): bool =
    result = false
    for v in startVal .. endVal:
        if v in validRange:
            result = true
            break
        

proc getGearSymbolPositions(line: string): seq[int] =
    result = @[]
    for i, c in line:
        if c == '*':
            result.add(i)

proc getGearRatio(buf: array[3, string]): seq[int] =
    result  = @[]
    if '*' notin buf[ord(THIS_LINE)]:
        return @[]
    # find '*' symbols and define the range which is adjacent to the gear
    for gearPos  in getGearSymbolPositions(buf[ord(THIS_LINE)]):
        #  define the range which is adjacent to the gear
        let validRange = @[(gearPos-1), gearPos, (gearPos+1)]
        # find numbers adjacent to the gear
        var numsAdjacentToGear: seq[int] = @[]
        for line in buf:
            let numberPositions = getNumberPosition(line)
            for p in numberPositions:
                if isAdjacentToGear(p.startPos, p.endPos, validRange):
                    numsAdjacentToGear.add( parseInt(line[p.startPos..p.endPos]) )
        if numsAdjacentToGear.len == 2:
            result.add(numsAdjacentToGear.prod())


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
var totalGearRatio: int = 0
for line in inputFile.lines:
    shiftBuf(buf, '.' & line & '.')
    # partNumber
    totalPartNumber += extractPartNumber(buf).sum()
    # gearRatio
    totalGearRatio += getGearRatio(buf).sum()

# for last line
shiftBuf(buf, repeat('.', length))
## get part number
totalPartNumber += extractPartNumber(buf).sum()
## gearRatio
totalGearRatio += getGearRatio(buf).sum()

echo totalPartNumber
echo totalGearRatio
