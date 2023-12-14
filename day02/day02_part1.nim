import strutils
import strscans


proc isPossibleCubeNum(color: string, num: int): bool =
    const RED_CUBE_NUM: int = 12
    const GREEN_CUBE_NUM: int = 13
    const BLUE_CUBE_NUM: int = 14
    var possible_red: bool = true
    var possible_green: bool = true
    var possible_blue: bool = true

    case color:
    of "red":
        if num > RED_CUBE_NUM:
            possible_red = false
    of "green":
        if num > GREEN_CUBE_NUM:
            possible_green = false
    of "blue":
        if num > BLUE_CUBE_NUM:
            possible_blue = false
    else:
        discard

    if possible_red and possible_green and possible_blue:
        result = true

####################

let inputFile = open("./day02_input.txt", fmRead)
# let inputFile = open("./tmp.txt", fmRead)

var sumOfIds: int = 0
for line in inputFile.lines:
    let game = line.split(':')[0]
    let cubes = line.split(':')[1].split({';', ','})
    # parse Game ID
    var id: int = 0 
    discard scanf(game, "Game $i", id)
    # parse number and color of cubes
    var num: int = 0
    var color: string = ""
    var isPossibleGame: bool = true
    for c in cubes:
        discard scanf(c, "$s$i$s$w", num, color)
        if not isPossibleCubeNum(color, num):
            isPossibleGame = false
            break
    if isPossibleGame:
        sumOfIds += id

close(inputFile)

echo sumOfIds
