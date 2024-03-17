import strutils
import sequtils

const DASH = '-'
const EQUAL = '='
const BOXNUM = 256

type
    Lens = tuple
        label: string
        focalLength: int

var boxes = newSeqWith(BOXNUM, newSeq[Lens]())

proc hashAlgorithm(str: string): int =
    var value: int = 0
    for c in str:
        value = ((ord(c) + value) * 17) mod 256
    result = value

proc getOepratePos(str: string): int =
    result = str.find({EQUAL, DASH})

proc getOperator(str: string): char =
    result = str[getOepratePos(str)]

proc getLens(str: string): Lens =
    let operationPos = getOepratePos(str)
    let label = str[0..(operationPos - 1)]
    var focalLength: int = 0
    if str[operationPos] == EQUAL:
        focalLength = str[(operationPos + 1)..str.high].parseInt()
    return ($label, focalLength)

proc getBoxIndex(str: string): int =
    let operationPos = getOepratePos(str)
    let label: string = str[0..(operationPos - 1)]
    result = hashAlgorithm(label)

proc getIndexOfLensInBox(label: string, boxIdx: int): int =
    result = -1
    for i, lens in boxes[boxIdx]:
        if lens.label == label:
            result = i
            break

proc operateEqual(lens: Lens, boxIdx: int): void =
    let lensPos = getIndexOfLensInBox(lens.label, boxIdx)
    if lensPos != -1:
        # there is already a lens in the box
        boxes[boxIdx][lensPos] = lens
    else:
        # there is not already a lens in the box
        boxes[boxIdx].add(lens)

proc operateDash(lens: Lens, boxIdx: int): void =
    let lensPos = getIndexOfLensInBox(lens.label, boxIdx)
    if lensPos != -1:
        # there is already a lens in the box
        boxes[boxIdx].delete(lensPos)

##########

let fileName = "day15_input.txt"
let file = open(fileName, fmRead)

let strList = file.readLine().split(',')
close(file)


for str in strList:
    let operator: char = getOperator(str)
    let lens: Lens = getLens(str)
    let boxIdx = getBoxIndex(str)
    if operator == EQUAL:
        operateEqual(lens, boxIdx)
    else:
        operateDash(lens, boxIdx)

var focusingPower: int = 0
for i, box in boxes:
    for j, lens in box:
        focusingPower += (i + 1) * (j + 1) * lens.focalLength
echo focusingPower
