import std/tables
import strscans
import strutils
import sequtils
import math

proc matchNode(input: string, node: var string, start: int): int = 
    var ofs: int = 0
    while start+ofs < input.len and isAlphaNumeric(input[start+ofs]):
        inc(ofs, 1)
    node = input[ start..(start+ofs-1) ]
    result = ofs
    
type
    Instruction = tuple
        left: string
        right: string

let fileName = "day08_input.txt"
let inputFile = open(fileName, fmRead)

# read LR navigation
let navi = inputFile.readLine()
# read blank line
discard inputFile.readLine()
# read nodes
var inst = newTable[string, Instruction]()
var pos: seq[string] = @[]
for line in inputFile.lines:
    var node: string = ""
    var lr: Instruction = (left: "", right: "")
    discard scanf(line, "${matchNode} = (${matchNode}, ${matchNode})", node, lr.left, lr.right)
    inst[node] = lr
    if node[^1] == 'A':
        pos.add(node)
close(inputFile)

# navigate "**A" to "**Z"
var steps: seq[int] = repeat(0, pos.len)
for i in 0 .. pos.high:
    var reachZ: bool = false
    while not reachZ:
        for lr in navi:
            if lr == 'L':
                pos[i] = inst[pos[i]].left
            else:
                pos[i] = inst[pos[i]].right
            inc(steps[i], 1)
            # check if the node ends with 'Z'
            if pos[i][^1] == 'Z':
                reachZ = true
                break

echo steps.lcm()
