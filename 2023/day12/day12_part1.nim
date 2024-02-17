import strutils
import sequtils
import math
import std/tables


const RECORD_CHARS = ['.', '#']

proc getAllUnknownCharPatterns(maxLen: int, charMaxNums: Table[char, int]): seq[string] = 
    var combinations: seq[string] = @[]

    proc getPossiblePattern(prefix: string, maxLen: int): void =
        if prefix.len == maxLen:
            combinations.add(prefix)
        else:
            if prefix.len() < maxLen:
                for c in RECORD_CHARS:
                    if prefix.count(c) < charMaxNums[c]:
                        let nowStr = prefix & c
                        getPossiblePattern(nowStr, maxLen)

    getPossiblePattern("", maxLen)
    result = combinations

proc completeUnknownChars(damagedRecord: string, unknownCharPattern: string): string =
    result = damagedRecord
    var idx = 0
    for i, c in damagedRecord:
        if c == '?':
            result[i] = unknownCharPattern[idx]
            inc(idx, 1)

proc getSizeList(record: string): seq[int] =
    result = record.replace('.', ' ').splitWhitespace().map(proc(x: string): int = x.len())

##########

let fileName = "day12_input.txt"
let file = open(fileName, fmRead)

var sumOfPossibleArrangement: int = 0
for line in file.lines:
    let orgRecord = line.splitWhitespace()[0]
    let expectedSizeList = line.splitWhitespace()[1].split(',').map(proc(x: string): int = parseInt(x))
    var maxNum = {'.': 0, '#': 0}.toTable
    maxNum['#'] = expectedSizeList.sum() - orgRecord.count('#')
    maxNum['.'] = orgRecord.len - expectedSizeList.sum() - orgRecord.count('.')
    # get possible char set at each '?'
    let allUnknownCharPatterns = getAllUnknownCharPatterns( orgRecord.count('?'), maxNum )
    #
    var possibleArrangementNum: int = 0
    for unknownCharPattern in allUnknownCharPatterns:
        # complete ? chars to make possible record
        var possibleRecord = completeUnknownChars(orgRecord, unknownCharPattern)
        # check if it's valid record
        let sizeList = getSizeList(possibleRecord)
        if sizeList == expectedSizeList:
            inc(possibleArrangementNum, 1)
    #
    inc(sumOfPossibleArrangement, possibleArrangementNum)
close(file)

echo sumOfPossibleArrangement
