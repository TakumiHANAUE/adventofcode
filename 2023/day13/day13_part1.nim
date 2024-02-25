

proc getLineNumber(linePos: int): int =
    result = linePos + 1

proc transposePattern(pattern: seq[string]): seq[string] =
    result = @[]
    for i in 0 .. pattern[0].high:
        var s: string = ""
        for j in 0 .. pattern.high:
            s = s & $pattern[j][i]
        result.add(s)


proc isReflectionLine(pattern: seq[string], linePos: int): bool =
    result = true
    let MIN_LINE_POS: int = 0
    let MAX_LINE_POS: int = pattern.high
    var i: int = linePos
    var j: int = linePos + 1
    while MIN_LINE_POS <= i and j <= MAX_LINE_POS:
        if pattern[i] != pattern[j]:
            result = false
            break
        dec(i, 1)
        inc(j, 1)

proc findHorizontalReflectionLine(pattern: seq[string], linePos: var int): bool =
    # return above of horizontal line of reflection
    result = false
    for i in 0 .. (pattern.high - 1):
        if pattern[i] == pattern[i+1]:
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
    echo "analyzePattern : ", result

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
