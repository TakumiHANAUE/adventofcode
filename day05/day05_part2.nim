import strutils
import sequtils

type
    InfoKind = enum
        SEED_TO_SOIL = 0,
        SOIL_TO_FERTILIZER,
        FERTILIZER_TO_WATER,
        WATER_TO_LIGHT,
        LIGHT_TO_TEMPERATURE,
        TEMPERATURE_TO_HUMIDITY,
        HUMIDITY_TO_LOCATION,
        INFO_MAX,
        SEEDS,
        OTHER

type
    MapInfo = tuple
        destStart: int
        srcStart: int
        rangeLen: int

type
    SeedInfo = tuple
        startNum: int
        endNum: int

proc getLineKind(line: string): InfoKind =
    if line.contains("seeds:"):
        result = SEEDS
    elif line.contains("seed-to-soil map:"):
        result = SEED_TO_SOIL
    elif line.contains("soil-to-fertilizer map:"):
        result = SOIL_TO_FERTILIZER
    elif line.contains("fertilizer-to-water map:"):
        result = FERTILIZER_TO_WATER
    elif line.contains("water-to-light map:"):
        result = WATER_TO_LIGHT
    elif line.contains("light-to-temperature map:"):
        result = LIGHT_TO_TEMPERATURE
    elif line.contains("temperature-to-humidity map:"):
        result = TEMPERATURE_TO_HUMIDITY
    elif line.contains("humidity-to-location map:"):
        result = HUMIDITY_TO_LOCATION
    else:
        result = OTHER

proc getSeedInfos(line: string): seq[SeedInfo] =
    result = @[]
    let nums = line.splitWhitespace()[1 .. ^1].map( proc(x: string): int = parseInt(x) )
    for i in countup(0, nums.high, 2):
        let startNum = nums[i]
        let endNum = (startNum - 1) + nums[i+1]
        result.add((startNum, endNum))

proc getSrcNumber(destNum: int, mapInfos: seq[MapInfo]): int =
    result = destNum
    for i in 0 .. mapInfos.high:
        let destStart = mapInfos[i].destStart
        let srcStart = mapInfos[i].srcStart
        let rangeLen = mapInfos[i].rangeLen
        if destStart <= destNum and destNum <= (destStart + (rangeLen - 1)):
            result = (destNum - destStart) + srcStart
            break

proc isValidSeed(num: int, seedInfos: seq[SeedInfo]): bool =
    result = false
    for seedInfo in seedInfos:
        if seedInfo.startNum <= num and num <= seedInfo.endNum:
            result = true
            break

##############

let fileName = "./day05_input.txt"
var almanacInfo = newSeqWith(ord(INFO_MAX), newSeq[MapInfo](0))
var seedInfos: seq[SeedInfo] = @[]

let inputFile = open(fileName, fmRead)

# Read and Store almanacInfos
for line in inputFile.lines:
    let kind = getLineKind(line)
    if kind == SEEDS:
        seedInfos = getSeedInfos(line)
    elif SEED_TO_SOIL <= kind and kind <= HUMIDITY_TO_LOCATION:
        for subLine in inputFile.lines:
            if subLine.len == 0:
                break
            let mapInfo = subLine.splitWhitespace().map( proc(x: string): int = parseInt(x) )
            almanacInfo[ord(kind)].add((mapInfo[0], mapInfo[1], mapInfo[2]))
    else:
        discard
close(inputFile)

# find lowest location number
var locationNum: int = 0
while true:
    var num = locationNum
    for kind in countdown(ord(HUMIDITY_TO_LOCATION), ord(SEED_TO_SOIL)):
        num = getSrcNumber(num, almanacInfo[kind])
    if isValidSeed(num, seedInfos):
        break
    inc(locationNum, 1)

echo locationNum
