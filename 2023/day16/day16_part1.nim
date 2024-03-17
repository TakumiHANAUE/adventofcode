import sequtils

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
        INVALID

type
    Position = tuple
        x: int
        y: int

type
    BeamInfo = tuple
        pos: Position
        dir: Direction

var contraption: seq[string] = @[]
var energizeInfo: seq[BeamInfo] = @[]
var x_min: int = 0
var x_max: int = 0
var y_min: int = 0
var y_max: int = 0
const invalidBeamInfo: BeamInfo = ((-1, -1), INVALID)

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

proc updateBeam(beam: BeamInfo, nextBeam, splittedBeam: var BeamInfo): void =
    nextBeam = invalidBeamInfo
    splittedBeam = invalidBeamInfo
    let tile = contraption[beam.pos.y][beam.pos.x]
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

proc deleteUnnecessaryBeams(beams: seq[BeamInfo], unnecessaryBeamNumbers: seq[int]): seq[BeamInfo] =
    result = beams
    for n in unnecessaryBeamNumbers:
        result[n] = invalidBeamInfo
    result = filter(result, proc(b: BeamInfo): bool = b != invalidBeamInfo)

#############

let fileName = "day16_input.txt"

let file = open(fileName, fmRead)
for line in file.lines:
    contraption.add(line)
close(file)

x_max = contraption[0].high
y_max = contraption.high

var beams: seq[BeamInfo] = @[((0, 0), RIGHTWARD)]
while beams.len > 0:
    var additionalBeams: seq[BeamInfo] = @[]
    var unnecessaryBeamNumbers: seq[int] = @[]
    for beamNumber in 0 .. beams.high:
        # record energize tile
        if beams[beamNumber] notin energizeInfo:
            energizeInfo.add(beams[beamNumber])
        else:
            # already processed beam
            unnecessaryBeamNumbers.add(beamNumber)
        # update beam
        var nextBeam: BeamInfo = invalidBeamInfo
        var splittedBeam: BeamInfo = invalidBeamInfo
        updateBeam(beams[beamNumber], nextBeam, splittedBeam)
        if nextBeam != invalidBeamInfo:
            beams[beamNumber] = nextBeam
        else:
            unnecessaryBeamNumbers.add(beamNumber)
        if splittedBeam != invalidBeamInfo:
            additionalBeams.add(splittedBeam)
    # delete the beam that is same beam info
    if unnecessaryBeamNumbers.len > 0:
        beams = deleteUnnecessaryBeams(beams, unnecessaryBeamNumbers)
    # add new beam
    if additionalBeams.len > 0:
        beams = beams & additionalBeams

var energizedPos: seq[Position] = @[]
var directions: seq[Direction] = @[]
(energizedPos, directions) = energizeInfo.unzip()

echo energizedPos.deduplicate().len

