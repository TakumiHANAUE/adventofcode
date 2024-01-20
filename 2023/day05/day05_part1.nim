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

proc getDestNumber(srcNum: int, mapInfos: seq[MapInfo]): int =
    result = srcNum
    for i in 0 .. mapInfos.high:
        let destStart = mapInfos[i].destStart
        let srcStart = mapInfos[i].srcStart
        let rangeLen = mapInfos[i].rangeLen
        if srcStart <= srcNum and srcNum <= (srcStart + (rangeLen - 1)):
            result = (srcNum - srcStart) + destStart
            break

##############

var almanacInfo = newSeqWith(ord(INFO_MAX), newSeq[MapInfo](0))
var seeds: seq[int] = @[]

let inputFile = open("./day05_input.txt", fmRead)

# Read and Store almanacInfos
for line in inputFile.lines:
    let kind = getLineKind(line)
    if kind == SEEDS:
        seeds = line.splitWhitespace()[1 .. ^1].map( proc(x: string): int = parseInt(x) )
    elif SEED_TO_SOIL <= kind and kind <= HUMIDITY_TO_LOCATION:
        for subLine in inputFile.lines:
            if subLine.len == 0:
                break
            let mapInfo = subLine.splitWhitespace().map( proc(x: string): int = parseInt(x) )
            almanacInfo[ord(kind)].add((mapInfo[0], mapInfo[1], mapInfo[2]))
    else:
        discard
close(inputFile)

# Convert Seed to Location
var locations: seq[int] = @[]
for seed in seeds:
    var num = seed
    for kind in SEED_TO_SOIL .. HUMIDITY_TO_LOCATION:
        num = getDestNumber(num, almanacInfo[ord(kind)])
    locations.add(num)

echo locations.min
