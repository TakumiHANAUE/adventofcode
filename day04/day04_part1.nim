import strutils
import sequtils
import std/sets
import math

let inputFile = open("./day04_input.txt", fmRead)

var points: int = 0
for line in inputFile.lines:
    let fields = line.split({':', '|'})
    let winNumbers = fields[1].strip().splitWhitespace().map( proc(x: string): int = parseInt(x) )
    let myNumbers = fields[2].strip().splitWhitespace().map( proc(x: string): int = parseInt(x) )
    let myWinNumber = toHashSet(winNumbers) * toHashSet(myNumbers)
    if myWinNumber.len() > 0:
        points += 2 ^ (myWinNumber.len() - 1)
close(inputFile)

echo points
