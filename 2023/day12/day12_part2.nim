# This program is created based on the article below.
# https://observablehq.com/@jwolondon/advent-of-code-2023-day-12

import strutils
import sequtils
import std/tables

type
    State = tuple
        position: int
        group: int
        size: int

const NUM_OF_COPIES = 5

var realRecord: string = ""
var realSizeList: seq[int] = @[]
var cache = Table[string, int]()

proc initVars(): void =
    realRecord = ""
    realSizeList = @[]
    cache = Table[string, int]()

proc getRecord(line: string): string =
    result = line.splitWhitespace()[0]

proc unfoldRecord(record: string): string =
    var tmp: seq[string] = @[]
    for i in 0 ..< NUM_OF_COPIES:
        tmp.add(record)
    result = join( tmp, "?")

proc getInputSizeList(line: string): seq[int] =
    result = line.splitWhitespace()[1].split(',').map(proc(x: string): int = parseInt(x))

proc unfoldSizeList(sizeList: seq[int]): seq[int] =
    result = sizeList.cycle(NUM_OF_COPIES)

proc getArrangements(state: State): int =
    let key = $state

    # if the key alreeady exists, return.
    if cache.hasKey(key):
        return cache[key]

    ####################################
    ##### at the end of the record #####
    ####################################
    # check if the arrangement is valid
    if state.position == realRecord.len:
        # check arrrangement
        if state.group == realSizeList.high: # processing the last group
            if state.size == realSizeList[state.group]:
                # the size matches last group size. 
                return 1
            else:
                return 0
        elif state.group == realSizeList.len: # finished processing the last group
            return 1
        else:
            # not reached last group
            return 0

    #################################
    ##### processing the record #####
    #################################
    result = 0
    let c = realRecord[state.position]

    # at # or ? character
    # check the number of damaged springs we're considering
    if c in ['#', '?']:
        if state.group < realSizeList.len:
            if state.size < realSizeList[state.group]:
                let nextState: State = (state.position+1, state.group, state.size+1)
                result += getArrangements(nextState)

    # at . or ? character
    # check if group size matches the expected group size
    if c in ['.', '?']:
        if state.size == 0: # not processing damaged spring
            let nextState: State = (state.position+1, state.group, 0)
            result += getArrangements(nextState)
        elif state.size == realSizeList[state.group]: # just finish processing damaged spring
            let nextState: State = (state.position+1, state.group+1, 0)
            result += getArrangements(nextState)

    # memoization
    cache[key] = result

############

let fileName = "day12_input.txt"
let file = open(fileName, fmRead)

var sumOfArrangements: int = 0
for line in file.lines:
    initVars()
    realRecord = line.getRecord().unfoldRecord()
    realSizeList = line.getInputSizeList().unfoldSizeList()
    sumOfArrangements += getArrangements((0, 0, 0))
close(file)
echo sumOfArrangements
