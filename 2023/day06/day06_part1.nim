import strutils
import sequtils

let fileName = "day06_input.txt"
let file = open(fileName, fmRead)

let times = file.readLine().splitWhitespace()[1 .. ^1].map( proc(x: string): int = parseInt(x) )
let distanceRecords = file.readLine().splitWhitespace()[1 .. ^1].map( proc(x: string): int = parseInt(x) )

close(file)

var prodOfRecords: int = 1
for raceNum in 0 .. times.high:
    let timeMax = times[raceNum]
    let distanceRecord = distanceRecords[raceNum]
    for holdingButtonTime in 0 .. timeMax:
        let speed = holdingButtonTime
        let travelTime = timeMax - holdingButtonTime
        let distance = speed * travelTime
        if distance > distanceRecord:
            let wins = (timeMax + 1) - (holdingButtonTime * 2)
            prodOfRecords *= wins
            break

echo prodOfRecords
