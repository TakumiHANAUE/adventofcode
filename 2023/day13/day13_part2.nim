

proc getLineNumber(linePos: int): int =
    result = linePos + 1

proc transposePattern(pattern: seq[string]): seq[string] =
    result = @[]
    for i in 0 .. pattern[0].high:
        var s: string = ""
        for j in 0 .. pattern.high:
            s = s & $pattern[j][i]
        result.add(s)

proc getNumOfDifferentChar(pattern1, pattern2: string): int =
    result = 0
    for i in 0 .. pattern1.high:
        if pattern1[i] != pattern2[i]:
            inc(result, 1)

proc isReflectionLine(pattern: seq[string], linePos: int): bool =
    result = true
    let MIN_LINE_POS: int = 0
    let MAX_LINE_POS: int = pattern.high
    var i: int = linePos
    var j: int = linePos + 1
    var smudgeNum: int = 0
    while MIN_LINE_POS <= i and j <= MAX_LINE_POS:
        let n = getNumOfDifferentChar(pattern[i], pattern[j])
        if n == 0:
            discard
        elif n == 1:
            inc(smudgeNum, 1)
        else:
            return false
        dec(i, 1)
        inc(j, 1)
    if smudgeNum != 1:
        result = false

proc findHorizontalReflectionLine(pattern: seq[string], linePos: var int): bool =
    # return above of horizontal line of reflection
    result = false
    for i in 0 .. (pattern.high - 1):
        if getNumOfDifferentChar(pattern[i], pattern[i+1]) < 2:
            if isReflectionLine(pattern, i):
                result = true
                linePos = i
                break

proc findVerticalReflectionLine(pattern: seq[string], linePos: var int): bool =
    # return left of vertical line of reflection
    let transposedPattern = transposePattern(pattern)
    result = findHorizontalReflectionLine(transposedPattern, linePos)

proc analyzePattern(pattern: seq[string]): int =
    var linePos: int = 0
    if findHorizontalReflectionLine(pattern, linePos):
        result += getLineNumber(linePos) * 100
    if findVerticalReflectionLine(pattern, linePos):
        result += getLineNumber(linePos)

#######

let fileName = "day13_input.txt"
let file = open(fileName, fmRead)

var pattern: seq[string] = @[]
var sumOfNotes: int = 0
for line in file.lines:
    if line == "" or endOfFile(file):
        sumOfNotes += analyzePattern(pattern)
        # init pattern
        pattern = @[]
    else:
        pattern.add(line)
close(file)
echo sumOfNotes
