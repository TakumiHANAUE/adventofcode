import strutils
import sequtils

proc getDiiferences(s: seq[int]): seq[int] =
    result = @[]
    for i in 1 .. s.high:
        result.add( s[i] - s[i-1] )

proc allZero(s: seq[int]): bool =
    result = all(s, proc(x: int): bool = x == 0)

proc extrapolateBack(s: var seq[seq[int]]): void =
    for i in countdown(s.high, 0):
        if i == s.high:
            s[s.high].insert(0, 0)
        else:
            let firstVal = s[i][0]
            let diff = s[i+1][0]
            s[i].insert((firstVal - diff), 0)

#########

let fileName = "day09_input.txt"
let inputFile = open(fileName, fmRead)

var sumOfNewFirstvalue: int = 0
for line in inputFile.lines:
    var values: seq[seq[int]] = @[]
    # read one history
    values.add( line.splitWhitespace().map(proc(x: string): int = parseInt(x)) )
    # generate differences
    while not allZero( values[values.high] ):
        values.add( getDiiferences(values[values.high]) )
    # extrapolate history
    extrapolateBack(values)
    # sum
    sumOfNewFirstvalue += values[0][0]
close(inputFile)

echo sumOfNewFirstvalue
