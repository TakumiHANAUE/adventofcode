import strutils
import strscans
import math

type
    ColorIndex = enum
        RED = 0
        GREEN,
        BLUE,
        COLOR_MAX

proc convertColorEnum(color: string): ColorIndex =
    case color
    of "red":
        result = RED
    of "green":
        result = GREEN
    of "blue":
        result = BLUE
    else:
        discard

####################

let inputFile = open("./day02_input.txt", fmRead)

var sumOfPowers: int = 0
for line in inputFile.lines:
    let game = line.split(':')[0]
    let cubes = line.split(':')[1].split({';', ','})
    # parse Game ID
    var id: int = 0 
    discard scanf(game, "Game $i", id)
    # get fewest number of cubes for possible game
    var cubeNum: array[COLOR_MAX, int]
    for c in cubes:
        # parse number and color of cubes
        var num: int = 0
        var color: string = ""
        discard scanf(c, "$s$i$s$w", num, color)
        # update max num of each color cube
        let colorIndex = convertColorEnum(color)
        cubeNum[colorIndex] = max(cubeNum[colorIndex], num)
    # add product of cube nums
    sumOfPowers += prod(cubeNum)
    
close(inputFile)

echo sumOfPowers
