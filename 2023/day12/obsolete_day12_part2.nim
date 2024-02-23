# This program couldn't solve part2 because it takes too long time.

import strutils
import sequtils
import math
import std/tables


const RECORD_CHARS = ['#', '.']
const NUM_OF_COPIES = 5

var tmpRecord: string = ""
var resNum = {'.': 0, '#': 0, '?': 0}.toTable
var expectedSizeList: seq[int] = @[]

var quesPos: seq[int] = @[]
var quesPosIdx: int = 0

proc getSizeList(record: string): seq[int] =

    proc subProc(x: string): int =
        result = x.len()

    result = record.replace('.', ' ').splitWhitespace().map(proc(x: string): int = subProc(x))
    # echo record, " : getSizeList : ", result

proc getRecord(line: string): string =
    result = line.splitWhitespace()[0]
    # echo "getRecord : ", result

proc unfoldRecord(record: string): string =
    var tmp: seq[string] = @[]
    for i in 0 ..< NUM_OF_COPIES:
        tmp.add(record)
    result = join( tmp, "?")
    echo "unfoldRecord : ", result

proc getInputSizeList(line: string): seq[int] =
    result = line.splitWhitespace()[1].split(',').map(proc(x: string): int = parseInt(x))
    # echo "getInputSizeList : ", result

proc getAllUnknownCharPos(realRecord: string): seq[int] =
    result = @[]
    for i,c in realRecord:
        if c == '?':
            result.add(i)
    # echo "getAllUnknownCharPos : ", result

proc initResidualNumOfChars(realRecord: string): void =
    var totalNum = {'.': 0, '#': 0}.toTable
    totalNum['#'] = expectedSizeList.sum()
    totalNum['.'] = realRecord.len - expectedSizeList.sum()
    #
    resNum['.'] = totalNum['.'] - realRecord.count('.')
    resNum['#'] = totalNum['#'] - realRecord.count('#')
    resNum['?'] = realRecord.count('?')

proc isPartialValidRecord(): bool =
    result = true
    let partialRecord = tmpRecord[0..<quesPos[quesPosIdx]]
    let sizeList = getSizeList(partialRecord)
    #
    if sizeList.len > expectedSizeList.len:
        result = false
    else:
        for i in 0 .. sizeList.high:
            if i == sizeList.high:
                if sizeList[i] > expectedSizeList[i]:
                    result = false
            else:
                if sizeList[i] != expectedSizeList[i]:
                    result = false

proc isFullValidRecord(): bool =
    result = false
    let sizeList = getSizeList(tmpRecord)
    if sizeList == expectedSizeList:
        result = true

proc isValidRecord(): bool =
    if resNum['?'] == 0:
        result = isFullValidRecord()
    else:
        result = isPartialValidRecord()
    # echo "isValidRecord : ", result

proc getPossibleArrangementNum(realRecord: string): int =
    var num = 0
    # init tmpRecord
    tmpRecord = realRecord

    proc getPossiblePattern(): void =
        let isValid = isValidRecord()
        # echo tmpRecord, " : ", isValid
        if isValid and resNum['?'] == 0:
            # check if it is valid record
            inc(num, 1)
        elif isValid and resNum['?'] > 0:
            # generate possible unknows chars pattern
            let nextIdx = quesPos[quesPosIdx]
            dec(resNum['?'], 1)
            inc(quesPosIdx, 1)
            for c in RECORD_CHARS:
                if resNum[c] > 0:
                    tmpRecord[nextIdx] = c
                    dec(resNum[c], 1)
                    getPossiblePattern()
                    inc(resNum[c], 1)
            tmpRecord[nextIdx] = '?'
            dec(quesPosIdx, 1)
            inc(resNum['?'], 1)

    getPossiblePattern()
    result = num
    # echo "getPossibleArrangementNum : ", result

##########

# let fileName = "day12_input.txt"
let fileName = "../tmp.txt"
let file = open(fileName, fmRead)

var lineNum: int = 1

var sumOfPossibleArrangement: int = 0
for line in file.lines:
    let foldedRecord = getRecord(line)
    let realRecord = unfoldRecord(foldedRecord)
    let foldedExpectedSizeList = getInputSizeList(line)
    expectedSizeList = foldedExpectedSizeList.cycle(NUM_OF_COPIES)
    echo "expectedSizeList : ", expectedSizeList
    quesPos = getAllUnknownCharPos(realRecord)
    quesPosIdx = 0
    initResidualNumOfChars(realRecord)
    #
    let possibleArrangementNum = getPossibleArrangementNum(realRecord)
    #
    inc(sumOfPossibleArrangement, possibleArrangementNum)
    #
    echo lineNum, " : ", possibleArrangementNum, " : ", foldedRecord
    inc(lineNum, 1)
close(file)

echo sumOfPossibleArrangement
