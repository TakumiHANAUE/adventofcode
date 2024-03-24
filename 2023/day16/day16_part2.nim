
const EMPTY_SPACE = '.'
const MIRROR_S = '/'
const MIRROR_B = '\\'
const SPLITTER_V = '|'
const SPLITTER_H = '-'

type
    Direction = enum
        RIGHTWARD = 0,
        LEFTWARD,
        UPWARD,
        DOWNWARD,
        DIRECTION_MAX

type
    Position = tuple
        x: int
        y: int

type
    BeamInfo = tuple
        pos: Position
        dir: Direction

type
    TileInfo = tuple
        tile: char
        energized: array[DIRECTION_MAX, bool]

var contraption: seq[seq[TileInfo]] = @[]
var x_min: int = 0
var x_max: int = 0
var y_min: int = 0
var y_max: int = 0
const invalidBeamInfo: BeamInfo = ((-1, -1), DIRECTION_MAX)

proc moveBeam(beam: BeamInfo, nextBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    case beam.dir:
    of RIGHTWARD:
        if beam.pos.x < x_max:
            nextBeam = ((beam.pos.x + 1, beam.pos.y), beam.dir)
    of LEFTWARD:
        if x_min < beam.pos.x:
            nextBeam = ((beam.pos.x - 1, beam.pos.y), beam.dir)
    of UPWARD:
        if y_min < beam.pos.y:
            nextBeam = ((beam.pos.x, beam.pos.y - 1), beam.dir)
    of DOWNWARD:
        if beam.pos.y < y_max:
            nextBeam = ((beam.pos.x, beam.pos.y + 1), beam.dir)
    else:
        discard

proc processEmptySpace(beam: BeamInfo, nextBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    moveBeam(beam, nextBeam)

proc processMirrorSlash(beam: BeamInfo, nextBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    var dir: Direction
    case beam.dir:
    of RIGHTWARD:
        dir = UPWARD
    of LEFTWARD:
        dir = DOWNWARD
    of UPWARD:
        dir = RIGHTWARD
    of DOWNWARD:
        dir = LEFTWARD
    else:
        discard
    moveBeam(((beam.pos.x, beam.pos.y), dir), nextBeam)

proc processMirrorBackSlash(beam: BeamInfo, nextBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    var dir: Direction
    case beam.dir:
    of RIGHTWARD:
        dir = DOWNWARD
    of LEFTWARD:
        dir = UPWARD
    of UPWARD:
        dir = LEFTWARD
    of DOWNWARD:
        dir = RIGHTWARD
    else:
        discard
    moveBeam(((beam.pos.x, beam.pos.y), dir), nextBeam)

proc processVertialSplitter(beam: BeamInfo, nextBeam, splittedBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    splittedBeam = invalidBeamInfo
    case beam.dir:
    of RIGHTWARD, LEFTWARD:
        moveBeam(((beam.pos.x, beam.pos.y), UPWARD), nextBeam)
        moveBeam(((beam.pos.x, beam.pos.y), DOWNWARD), splittedBeam)
    of UPWARD, DOWNWARD:
        moveBeam(beam, nextBeam)
    else:
        discard

proc processHorizontalSplitter(beam: BeamInfo, nextBeam, splittedBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    splittedBeam = invalidBeamInfo
    case beam.dir:
    of RIGHTWARD, LEFTWARD:
        moveBeam(beam, nextBeam)
    of UPWARD, DOWNWARD:
        moveBeam(((beam.pos.x, beam.pos.y), RIGHTWARD), nextBeam)
        moveBeam(((beam.pos.x, beam.pos.y), LEFTWARD), splittedBeam)
    else:
        discard

proc isValidBeam(beam: BeamInfo): bool =
    result = true
    if beam.dir == DIRECTION_MAX:
        result = false

proc isProcessedBeam(beam: BeamInfo): bool =
    result = false
    if beam.dir in [RIGHTWARD, LEFTWARD, UPWARD, DOWNWARD]:
        if contraption[beam.pos.y][beam.pos.x].energized[beam.dir]:
            result = true   

proc getNextBeams(beam: BeamInfo): seq[BeamInfo] =
    result = @[]
    var nextBeam = invalidBeamInfo
    var splittedBeam = invalidBeamInfo
    let tile = contraption[beam.pos.y][beam.pos.x].tile
    case tile
    of EMPTY_SPACE:
        processEmptySpace(beam, nextBeam)
    of MIRROR_S:
        processMirrorSlash(beam, nextBeam)
    of MIRROR_B:
        processMirrorBackSlash(beam, nextBeam)
    of SPLITTER_V:
        processVertialSplitter(beam, nextBeam, splittedBeam)
    of SPLITTER_H:
        processHorizontalSplitter(beam, nextBeam, splittedBeam)
    else:
        discard

    if isValidBeam(nextBeam) and not isProcessedBeam(nextBeam):
        result.add(nextBeam)
    if isValidBeam(splittedBeam) and not isProcessedBeam(splittedBeam):
        result.add(splittedBeam)

proc energizeTiles(beamStart: BeamInfo): void =
    var beamList: seq[BeamInfo] = @[beamStart]
    while beamList.len > 0:
        var nextBeams: seq[BeamInfo] = @[]
        for beam in beamList:
            contraption[beam.pos.y][beam.pos.x].energized[beam.dir] = true
            nextBeams.add( getNextBeams(beam) )
        beamList = nextBeams

proc getenergizedTileNum(): int =
    var num: int = 0
    for y in 0 .. contraption.high:
        for x in 0 .. contraption[0].high:
            if true in contraption[y][x].energized:
                inc(num, 1)
    result = num

proc makeBeamStartList(): seq[BeamInfo] =
    # from any tile in the top row
    for x in x_min .. x_max:
        result.add(((x, y_min), DOWNWARD))
    # from any tile in the bottom row
    for x in x_min .. x_max:
        result.add(((x, y_max), UPWARD))
    # from any tile in the rightmost column
    for y in y_min .. y_max:
        result.add(((x_max, y), LEFTWARD))
    # from any tile in the rightmost column
    for y in y_min .. y_max:
        result.add(((x_min, y), RIGHTWARD)) 

############

let fileName = "day16_input.txt"
let file = open(fileName, fmRead)

let energizedInit: array[DIRECTION_MAX, bool] = [false, false, false, false]

for line in file.lines:
    var tileRow: seq[TileInfo] = @[]
    for c in line:
        tileRow.add( (c, energizedInit) )
    contraption.add( tileRow )
close(file)

x_max = contraption[0].high
y_max = contraption.high

let initContraption = contraption
var beamStartList: seq[BeamInfo] = makeBeamStartList()
var energizedTileNum: int = 0
for beamStart in beamStartList:
    contraption = initContraption
    energizeTiles(beamStart)
    let n = getenergizedTileNum()
    energizedTileNum = max(n, energizedTileNum)

echo energizedTileNum
