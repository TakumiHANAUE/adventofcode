import sequtils
import math

const ROUNDED_ROCK = 'O'
const CUBE_SHAPED_ROCK = '#'

let fileName = "day14_input.txt"
let file = open(fileName, fmRead)

let length = file.readLine.len
file.setFilePos(0)

var indexList = newSeq[int](length)
var roundRockYindexList: seq[int] = @[]
var ypos: int = 0
for line in file.lines:
    for xpos, c in line:
        if c == ROUNDED_ROCK:
            roundRockYindexList.add(indexList[xpos])
            inc(indexList[xpos], 1)
        elif c == CUBE_SHAPED_ROCK:
            indexList[xpos] = ypos + 1
    inc(ypos, 1)
close(file)
let lineNum = ypos

echo roundRockYindexList.map(proc(x: int): int = abs(x - lineNum)).sum()
