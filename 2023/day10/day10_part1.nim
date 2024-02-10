import strutils

type
    Position = tuple
        x: int
        y: int

type
    Direction = enum
        NORTH = 0,
        EAST,
        SOUTH,
        WEST

var pipeMap: seq[string] = @[]

proc existNORTHPos(pos: Position): bool =
    result = true
    if pos.y - 1 < 0:
        result = false

proc existEASTPos(pos: Position): bool =
    result = true
    let xMax = pipeMap[0].high
    if pos.x + 1 > xMax:
        result = false

proc existSOUTHPos(pos: Position): bool =
    result = true
    let yMax = pipeMap.high
    if pos.y + 1 > yMax:
        result = false

proc existWESTPos(pos: Position): bool =
    result = true
    if pos.x - 1 < 0:
        result = false

proc isOpen(pos: Position, dir: Direction): bool =
    result = false
    let tile = pipeMap[pos.y][pos.x]
    if tile == '|':
        if dir in [NORTH, SOUTH]:
            result = true
    elif tile == '-':
        if dir in [EAST, WEST]:
            result = true
    elif tile == 'L':
        if dir in [NORTH, EAST]:
            result = true
    elif tile == 'J':
        if dir in [NORTH, WEST]:
            result = true
    elif tile == '7':
        if dir in [SOUTH, WEST]:
            result = true
    elif tile == 'F':
        if dir in [EAST, SOUTH]:
            result = true
    elif tile == 'S':
        result = true

proc oppositeOf(dir: Direction): Direction =
    if dir == NORTH:
        result = SOUTH
    elif dir == EAST:
        result = WEST
    elif dir == SOUTH:
        result = NORTH
    else: # dir == WEST
        result = EAST

proc isConnected(fromPos, toPos: Position, dir: Direction): bool =
    result = false
    if isOpen(fromPos, dir) and isOpen(toPos, oppositeOf(dir)):
        result = true

proc getNeighborPos(pos: Position): seq[Position] =
    result = @[]
    if existNORTHPos(pos):
        result.add( (pos.x, pos.y-1) )
    if existEASTPos(pos):
        result.add( (pos.x+1, pos.y) )
    if existSOUTHPos(pos):
        result.add( (pos.x, pos.y+1) )
    if existWESTPos(pos):
        result.add( (pos.x-1, pos.y) )

proc getDirection(fromPos, toPos: Position): Direction =
    if fromPos.x == toPos.x:
        if fromPos.y > toPos.y:
            result = NORTH
        else:
            result = SOUTH
    else: # fromPos.y == toPos.y
        if fromPos.x < toPos.x:
            result = EAST
        else:
            result = WEST

proc getNextPosition(nowPos: Position, lastPos: Position): Position =
    result = nowPos
    let neighbors = getNeighborPos(nowPos)
    for neighbor in neighbors:
        # skip the same as last position
        if neighbor == lastPos:
            continue
        # if next tile is connected, get it as next position
        let dir = getDirection(nowPos, neighbor)
        if isConnected(nowPos, neighbor, dir):
            result = neighbor
            break

#############

let fileName = "day10_input.txt"
let inputFile = open(fileName, fmRead)

var startPos: Position = (x: -1, y: -1)
var lineNum: int = 0
for line in inputFile.lines:
    pipeMap.add(line)
    # find start position
    if startPos == (-1, -1):
        if line.contains('S'):
            startPos.x = line.find('S')
            startPos.y = lineNum
    inc(lineNum, 1)
close(inputFile)

var nowPos: Position = startPos
var lastPos: Position = startPos
var step: int = 0
while true:
    let nextPos = getNextPosition(nowPos, lastPos)
    inc(step, 1)
    lastPos = nowPos
    nowPos = nextPos
    # echo "STEP ", step, " ", lastPos, " ", pipeMap[lastPos.y][lastPos.x], " -> ", nowPos, " ", pipeMap[nowPos.y][nowPos.x]
    if nowPos == startPos:
        break

echo step div 2
