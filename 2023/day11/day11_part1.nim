
import sequtils

const GALAXY = '#'

type
    Position = tuple
        x: int
        y: int

var galaxies: seq[Position] = @[]
var noGalaxyLines: seq[int] = @[]
var noGalaxyColumns: seq[int] = @[]

proc getGelaxyXCoordinates(line: string): seq[int] =
    for i, c in line:
        if c == GALAXY:
            result.add(i)

proc ExpansionOfXDirection(x1, x2: int): int =
    let xmin = min(x1, x2)
    let xmax = max(x1, x2)
    for x in noGalaxyColumns:
        if xmin < x and x < xmax:
            result += 1

proc ExpansionOfYDirection(y1, y2: int): int =
    let ymin = min(y1, y2)
    let ymax = max(y1, y2)
    for y in noGalaxyLines:
        if ymin < y and y < ymax:
            result += 1

proc calcLength(pos1, pos2: Position): int =
    result += abs(pos1.x - pos2.x)
    result += abs(pos1.y - pos2.y)
    result += ExpansionOfXDirection(pos1.x, pos2.x)
    result += ExpansionOfYDirection(pos1.y, pos2.y)

###########

let fileName = "day11_input.txt"
let inputFile = open(fileName, fmRead)

let lineLength = inputFile.readLine().len()
inputFile.setFilePos(0)

# find galaxyies
# find no-galaxy lines
var y: int = 0
for line in inputFile.lines:
    let xpos = getGelaxyXCoordinates(line)
    if xpos.len == 0:
        noGalaxyLines.add(y)
    else:
        for x in xpos:
            galaxies.add((x, y))
    inc(y, 1)
close(inputFile)

# find no-galaxy columns 
var allXpos: seq[int] = @[]
var allYpos: seq[int] = @[]
(allXpos, allYpos) = galaxies.unzip()
let uniqXpos = allXpos.deduplicate()
for i in 0 ..< lineLength:
    if i notin uniqXpos:
        noGalaxyColumns.add(i)

# calculate paths between each galaxyies
var sumOfLength: int = 0
for i in 0 .. galaxies.high:
    for j in (i+1) .. galaxies.high:
        sumOfLength += calcLength(galaxies[i], galaxies[j])

echo sumOfLength
