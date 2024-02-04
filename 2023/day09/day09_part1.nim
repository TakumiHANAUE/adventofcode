import strutils
import sequtils

proc getDiiferences(s: seq[int]): seq[int] =
    result = @[]
    for i in 1 .. s.high:
        result.add( s[i] - s[i-1] )

proc allZero(s: seq[int]): bool =
    result = all(s, proc(x: int): bool = x == 0)

proc extrapolateHistory(s: var seq[seq[int]]): void =
    for i in countdown(s.high, 0):
        if i == s.high:
            s[s.high].add(0)
        else:
            let lastVal = s[i][s[i].high]
            let diff = s[i+1][s[i+1].high]
            s[i].add(lastVal + diff)


let fileName = "day09_input.txt"
let inputFile = open(fileName, fmRead)

var sumOfnextvalue: int = 0
for line in inputFile.lines:
    var values: seq[seq[int]] = @[]
    # read one history
    values.add( line.splitWhitespace().map(proc(x: string): int = parseInt(x)) )
    # generate differences
    while not allZero( values[values.high] ):
        values.add( getDiiferences(values[values.high]) )
    # extrapolate history
    extrapolateHistory(values)
    # sum
    sumOfnextvalue += values[0][values[0].high]
close(inputFile)

echo sumOfnextvalue
