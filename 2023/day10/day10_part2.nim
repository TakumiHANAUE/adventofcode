import strutils
import sequtils

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

const GROUND = '.'
var pipeMap: seq[string] = @[]
var insideRoopTilePos: seq[Position] = @[]

proc getTile(pos: Position): char =
    result = pipeMap[pos.y][pos.x]

proc setTile(pos: Position, tile: char): void =
    pipeMap[pos.y][pos.x] = tile

proc existNorthPos(pos: Position): bool =
    result = true
    if pos.y - 1 < 0:
        result = false

proc existEastPos(pos: Position): bool =
    result = true
    let xMax = pipeMap[0].high
    if pos.x + 1 > xMax:
        result = false

proc existSouthPos(pos: Position): bool =
    result = true
    let yMax = pipeMap.high
    if pos.y + 1 > yMax:
        result = false

proc existWestPos(pos: Position): bool =
    result = true
    if pos.x - 1 < 0:
        result = false

proc isOpen(pos: Position, dir: Direction): bool =
    result = false
    let tile = getTile(pos)
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
    if existNorthPos(pos):
        result.add( (pos.x, pos.y-1) )
    if existEastPos(pos):
        result.add( (pos.x+1, pos.y) )
    if existSouthPos(pos):
        result.add( (pos.x, pos.y+1) )
    if existWestPos(pos):
        result.add( (pos.x-1, pos.y) )

proc getDiagonalPos(pos: Position): seq[Position] =
    result = @[]
    if existNorthPos(pos) and existEastPos(pos):
        result.add( (pos.x+1, pos.y-1) )
    if existSouthPos(pos) and existEastPos(pos):
        result.add( (pos.x+1, pos.y+1) )
    if existSouthPos(pos) and existWestPos(pos):
        result.add( (pos.x-1, pos.y+1) )
    if existNorthPos(pos) and existWestPos(pos):
        result.add( (pos.x-1, pos.y-1) )

proc getAroundPos(pos: Position): seq[Position] = 
    result.add(getNeighborPos(pos))
    result.add(getDiagonalPos(pos))

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

proc isCorner(pos: Position): bool =
    let tile = getTile(pos)
    case tile
    of 'L', 'J', '7', 'F':
        result = true
    else:
        result = false

proc isTurningRight(nowPos, nextPos: Position): bool =
    result = false
    let nowTile = getTile(nowPos)
    if nowTile == 'L':
        if getDirection(nowPos, nextPos) == NORTH:
            result = true
    elif nowTile == 'J':
        if getDirection(nowPos, nextPos) == WEST:
            result = true
    elif nowTile == '7':
        if getDirection(nowPos, nextPos) == SOUTH:
            result = true
    else: # nowTile == 'F'
        if getDirection(nowPos, nextPos) == EAST:
            result = true

proc getPositionsInsideOfCorner(pos: Position, insidePos: var Position): bool =
    result = false
    let tile = getTile(pos)
    if tile == 'L':
        if existNorthPos(pos) and existEastPos(pos):
            insidePos = (pos.x + 1, pos.y - 1)
            result = true
    elif tile == 'J':
        if existNorthPos(pos) and existWestPos(pos):
            insidePos = (pos.x - 1, pos.y - 1)
            result = true
    elif tile == '7':
        if existSouthPos(pos) and existWestPos(pos):
            insidePos = (pos.x - 1, pos.y + 1)
            result = true
    else: # tile == 'F'
        if existSouthPos(pos) and existEastPos(pos):
            insidePos = (pos.x + 1, pos.y + 1)
            result = true

proc setInsideCornerAsInsideRoop(pos: Position): void =
    var insidePos: Position = (-1, -1)
    if getPositionsInsideOfCorner(pos, insidePos):
        if getTile(insidePos) == GROUND:
            setTile(insidePos, 'I')
            insideRoopTilePos.add(insidePos)

proc setInsideTileAsInsideRoop(corners: seq[Position]): void =
    for cPos in corners:
        setInsideCornerAsInsideRoop(cPos)

proc getPositionsOutsideOfCorner(pos: Position, outsidePos: var seq[Position]): bool =
    result = false
    let tile = getTile(pos)
    if tile == 'L':
        if existSouthPos(pos) and existWestPos(pos):
            outsidePos.add( (pos.x - 1, pos.y   ) )
            outsidePos.add( (pos.x - 1, pos.y + 1) )
            outsidePos.add( (pos.x,     pos.y + 1) )
            result = true
    elif tile == 'J':
        if existSouthPos(pos) and existEastPos(pos):
            outsidePos.add( (pos.x + 1, pos.y   ) )
            outsidePos.add( (pos.x + 1, pos.y + 1) )
            outsidePos.add( (pos.x,     pos.y + 1) )
            result = true
    elif tile == '7':
        if existNorthPos(pos) and existEastPos(pos):
            outsidePos.add( (pos.x + 1, pos.y   ) )
            outsidePos.add( (pos.x + 1, pos.y - 1) )
            outsidePos.add( (pos.x,     pos.y - 1) )
            result = true
    else: # tile == 'F'
        if existNorthPos(pos) and existWestPos(pos):
            outsidePos.add( (pos.x - 1, pos.y   ) )
            outsidePos.add( (pos.x - 1, pos.y - 1) )
            outsidePos.add( (pos.x,     pos.y - 1) )
            result = true

proc setOutsideCornerAsInsideRoop(pos: Position): void =
    var outsidePos: seq[Position] = @[]
    if getPositionsOutsideOfCorner(pos, outsidePos):
        for oPos in outsidePos:
            if getTile(oPos) == GROUND:
                setTile(oPos, 'I')
                insideRoopTilePos.add(oPos)

proc setOutsideTileAsInsideRoop(corners: seq[Position]): void =
    for cPos in corners:
        setOutsideCornerAsInsideRoop(cPos)

proc makeMapOnlyMainRoop(mainRoop: seq[Position]): void =
    let dummyLine = repeat(GROUND, pipeMap[0].len)
    var tmpMap = newSeqWith(pipeMap.len, dummyLine)
    for pos in mainRoop:
        tmpMap[pos.y][pos.x] = getTile(pos)
    pipeMap = tmpMap

#############

let fileName = "day10_input.txt"
# let fileName = "../tmp.txt"
let inputFile = open(fileName, fmRead)

# Make map
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

# find main roop
var nowPos: Position = startPos
var prevPos: Position = startPos
var mainRoop: seq[Position] = @[startPos]
var turnCount: int = 0 # turning right: +1, turning left : -
var cornersOfTurningRight: seq[Position] = @[]
var cornersOfTurningLeft: seq[Position] = @[]
while true:
    let nextPos = getNextPosition(nowPos, prevPos)
    mainRoop.add(nextPos)
    # memorize corner position
    if isCorner(nowPos):
        if isTurningRight(nowPos, nextPos):
            inc(turnCount, 1)
            cornersOfTurningRight.add(nowPos)
        else:
            dec(turnCount, 1)
            cornersOfTurningLeft.add(nowPos)
    # update position
    prevPos = nowPos
    nowPos = nextPos
    # come back to start position
    if nowPos == startPos:
        break

# get roop direction
var isRightRoop: bool = false
if turnCount > 0:
    isRightRoop = true

# overwrite non-main roop to "ground" '.'
makeMapOnlyMainRoop(mainRoop)

# change tiles (inside roop and next to corner) to 'I'
if isRightRoop:
    setInsideTileAsInsideRoop(cornersOfTurningRight)
    setOutsideTileAsInsideRoop(cornersOfTurningLeft)
else:
    setInsideTileAsInsideRoop(cornersOfTurningLeft)
    setOutsideTileAsInsideRoop(cornersOfTurningRight)

# count 'I' tile and tiles next to 'I'
var tilesEnclosedByTheRoop: int = insideRoopTilePos.len
while insideRoopTilePos.len > 0:
    var newInsideRoopTile: seq[Position] = @[]
    for pos in insideRoopTilePos:
        let aroundPos = getAroundPos(pos)
        for p in aroundPos:
            if getTile(p) == GROUND:
                setTile(p, 'I')
                newInsideRoopTile.add(p)
                inc(tilesEnclosedByTheRoop, 1)
    insideRoopTilePos = newInsideRoopTile

echo tilesEnclosedByTheRoop
