import strutils
import sequtils
import std/sets
import math

let inputFile = open("./day04_input.txt", fmRead)

var scratchCards: seq[int] = @[0]
for line in inputFile.lines:
    let fields = line.split({':', '|'})
    let cardNumber = (fields[0].splitWhitespace())[1].parseInt()
    let winNumbers = fields[1].strip().splitWhitespace().map( proc(x: string): int = parseInt(x) )
    let myNumbers = fields[2].strip().splitWhitespace().map( proc(x: string): int = parseInt(x) )
    let myWinNumbers = toHashSet(winNumbers) * toHashSet(myNumbers)
    # Add number of original and copy of scratchcards
    for i in cardNumber .. (cardNumber + myWinNumbers.len):
        if scratchCards.high < i:
            scratchCards.setLen(i+1)
        if i == cardNumber: # for original scratchcard
            scratchCards[i] += 1
        else: # for copy of scratchcards
            scratchCards[i] = scratchCards[i] + scratchCards[cardNumber]
close(inputFile)

echo scratchCards.sum
