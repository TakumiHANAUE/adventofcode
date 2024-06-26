import std/heapqueue
import std/tables

import maputils

type
    PositionInfo = tuple
        position: Position
        heatLoss: int
        direction: Direction
        directionNum: int

type
    MovingInfo = tuple
        position: Position
        direction: Direction
        directionNum: int

var mapData: seq[string] = @[]
let startPos: Position = (0, 0)
const STRAIGHT_NUM_MAX: int = 10
const STRAIGHT_NUM_MIN: int = 4

proc `<` (p1, p2: PositionInfo): bool = p1.heatLoss < p2.heatLoss

proc getNextDirectionNum(currentInfo: PositionInfo, nextDir: Direction): int =
    if currentInfo.direction != nextDir:
        result = 1
    else:
        result = currentInfo.directionNum + 1

proc getHeatLoss(p: Position): int =
    result = ord(mapData[p.y][p.x]) - ord('0')

#########

let fileName = "day17_input.txt"

let file = open(fileName, fmRead)
for line in file.lines:
    mapData.add(line)
close(file)
setXMax(mapData[0].high)
setYMax(mapData.high)

let goalPos: Position = (getXMax(), getYMax())

var frontier = initHeapQueue[PositionInfo]()
frontier.push((startPos, 0, INVALID, 0))

var costSoFar = initTable[MovingInfo, int]()
costSoFar[(startPos, RIGHT, 0)] = 0

var leastHeatLoss: int = high(int)

# path finding
while frontier.len != 0:
    let currentInfo = frontier.pop()
    # reached goalPos
    if currentInfo.position == goalPos:
        # need moving at least 4 block when reached goalPos
        if currentInfo.directionNum >= STRAIGHT_NUM_MIN:
            leastHeatLoss = min(leastHeatLoss, currentInfo.heatLoss)
            continue
        
    # get neighbor Position
    for next in (currentInfo.position).getNeighbors():
        let nextDir = getDirection(currentInfo.position, next)
        let nextDirectionNum = getNextDirectionNum(currentInfo, nextDir)
        let newHeatLoss = currentInfo.heatLoss + getHeatLoss(next)

        # cannot move to reverse direction
        if isOppositeDirection(currentInfo.direction, nextDir):
            continue
        # cannot move straight ten block
        if currentInfo.direction == nextDir:
            if currentInfo.directionNum >= STRAIGHT_NUM_MAX:
                continue
        # need moving at least 4 block before turning
        if isTurning(currentInfo.direction, nextDir):
            if currentInfo.directionNum < STRAIGHT_NUM_MIN:
                continue
        # less heat loss already exists 
        if newHeatLoss >= leastHeatLoss:
            continue

        # add next position
        let key = (next, nextDir, nextDirectionNum)
        if (key notin costSoFar) or (newHeatLoss < costSoFar[key]):
            costSoFar[key] = newHeatLoss
            frontier.push((next, newHeatLoss, nextDir, nextDirectionNum))

echo leastHeatLoss
