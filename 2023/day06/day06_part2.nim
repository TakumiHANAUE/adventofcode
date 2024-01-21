import strutils

let fileName = "day06_input.txt"
let file = open(fileName, fmRead)

let timeMax = file.readLine().replace(" ").split(':')[1].parseInt()
let distanceRecord = file.readLine().replace(" ").split(':')[1].parseInt()

close(file)

var prodOfRecords: int = 1
for holdingButtonTime in 0 .. timeMax:
    let speed = holdingButtonTime
    let travelTime = timeMax - holdingButtonTime
    let distance = speed * travelTime
    if distance > distanceRecord:
        let wins = (timeMax + 1) - (holdingButtonTime * 2)
        prodOfRecords *= wins
        break

echo prodOfRecords
