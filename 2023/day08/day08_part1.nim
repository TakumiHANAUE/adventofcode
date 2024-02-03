import std/tables
import strscans

type
    Instruction = tuple
        left: string
        right: string

let fileName = "day08_input.txt"
let inputFile = open(fileName, fmRead)

# read navigation
let navi = inputFile.readLine()
# read blank line
discard inputFile.readLine()

# read nodes
var inst = newTable[string, Instruction]()
for line in inputFile.lines:
    var node: string = ""
    var lr: Instruction = (left: "", right: "")
    discard scanf(line, "$w = ($w, $w)", node, lr.left, lr.right)
    inst[node] = lr
close(inputFile)

# navigate "AAA" to "ZZZ"
var step: int = 0
var pos: string = "AAA"
var reachZZZ: bool = false
while not reachZZZ:
    for lr in navi:
        if lr == 'L':
            pos = inst[pos].left
        else:
            pos = inst[pos].right
        inc(step, 1)
        if pos == "ZZZ":
            reachZZZ = true
            break

echo step
