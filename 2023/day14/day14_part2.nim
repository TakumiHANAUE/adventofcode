import strutils
import std/tables

const ROUNDED_ROCK = 'O'
const CUBE_SHAPED_ROCK = '#'
const EMPTY_SPACE = '.'

const CYCLE_NUM = 1000000000

var positions: seq[string] = @[]
var lineNum: int = 0

proc getCol(xIndex: int): string =
    for i in 0 .. positions.high:
        result = result & positions[i][xIndex]

proc setCol(str: string, xIndex: int): void =
    for i in 0 .. positions.high:
        positions[i][xIndex] = str[i]

proc getRow(yIndex: int): string =
    result = positions[yIndex]

proc setRow(str: string, yIndex: int): void =
    positions[yIndex] = str

proc moveRoundRockLeft(str: string): string =
    var nextIndex: int = 0
    result = str
    for i in countup(0, str.high):
        if str[i] == ROUNDED_ROCK:
            result[i] = EMPTY_SPACE
            result[nextIndex] = str[i]
            inc(nextIndex, 1)
        elif str[i] == CUBE_SHAPED_ROCK:
            nextIndex = i + 1

proc moveRoundRockRight(str: string): string =
    var nextIndex: int = str.high
    result = str
    for i in countdown(str.high, 0):
        if str[i] == ROUNDED_ROCK:
            result[i] = EMPTY_SPACE
            result[nextIndex] = str[i]
            dec(nextIndex, 1)
        elif str[i] == CUBE_SHAPED_ROCK:
            nextIndex = i - 1

proc tiltNorth(): void =
    for x in countup(0, positions[0].high):
        let orgCol = getCol(x)
        let col = orgCol.moveRoundRockLeft()
        setCol(col, x)

proc tiltWest(): void =
    for y in countup(0, positions.high):
        let orgRow = getRow(y)
        let row = orgRow.moveRoundRockLeft()
        setRow(row, y)

proc tiltSouth(): void =
    for x in countup(0, positions[0].high):
        let orgCol = getCol(x)
        let col = orgCol.moveRoundRockRight()
        setCol(col, x)

proc tiltEast(): void =
    for y in countup(0, positions.high):
        let orgRow = getRow(y)
        let row = orgRow.moveRoundRockRight()
        setRow(row, y)

# read puzzle input
let fileName = "day14_input.txt"
let file = open(fileName, fmRead)
for line in file.lines:
    positions.add(line)
close(file)
lineNum = positions.len()

# find the keys that make loop
var cache = Table[string, seq[string]]()
var reachedLoop: bool = false
var keyList: seq[string] = @[]
var cycleIndex: int = 0
for i in 1 .. CYCLE_NUM:
    cycleIndex = i
    let key = $positions
    # same position comes again
    if cache.hasKey(key):
        # update positions
        positions = cache[key]
        if not reachedLoop:
            # memorize the first key of loops
            reachedLoop = true
            keyList.add(key)
        elif reachedLoop:
            # memorize the other keys of loops
            if key notin keyList:
                keyList.add(key)
            else:
                # finish memorize keys
                break
    # it's unknown positions. need to do 1 cycle
    else:
        tiltNorth()
        tiltWest()
        tiltSouth()
        tiltEast()
        cache[key] = positions

# set the last positions
if CYCLE_NUM > cycleIndex:
    let resCycle = CYCLE_NUM - cycleIndex
    let lastKey = keyList[ resCycle mod keyList.len() ]
    positions = cache[lastKey]

# calc the total load on the north support beams
var totalLoad: int = 0
for i in 0 .. positions.high:
    totalLoad = totalLoad + positions[i].count('O') * abs(i - lineNum)
echo totalLoad
