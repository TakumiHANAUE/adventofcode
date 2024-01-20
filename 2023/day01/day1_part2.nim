import strutils
import math

type
    DigitString = tuple[word: string, valueStr: string]

const DIGIT_WORD_ARRAY: array[18, DigitString] = [
    ("one"  , "1"),
    ("two"  , "2"),
    ("three", "3"),
    ("four" , "4"),
    ("five" , "5"),
    ("six"  , "6"),
    ("seven", "7"),
    ("eight", "8"),
    ("nine" , "9"),
    ("1"    , "1"),
    ("2"    , "2"),
    ("3"    , "3"),
    ("4"    , "4"),
    ("5"    , "5"),
    ("6"    , "6"),
    ("7"    , "7"),
    ("8"    , "8"),
    ("9"    , "9")
]

type
    DigitPosition = tuple[index: int, valueStr: string]

proc getTwoDigitCandidate(line: string): seq[DigitPosition] = 
    # find "two-digit number" candidate
    var digitsCandidates: seq[tuple[index: int, valueStr: string]] = @[]
    for d in DIGIT_WORD_ARRAY:
        if line.contains(d.word):
            # "first digit" candidate
            digitsCandidates.add( (line.find(d.word), d.valueStr) )
            # "last digit" candidate
            digitsCandidates.add( (line.rfind(d.word), d.valueStr) )
    return digitsCandidates

proc getFirstDigit(line: string): string = 
    let digits = line.getTwoDigitCandidate()
    # find first digit
    var firstDigit = (index: line.high(), valueStr: "")
    for d in digits:
        if d.index <= firstDigit.index:
            firstDigit.index = d.index
            firstDigit.valueStr = d.valueStr
    return firstDigit.valueStr

proc getLastDigit(line: string): string = 
    let digits = line.getTwoDigitCandidate()
    # find lst digit
    var lastDigit = (index: 0, valueStr: "")
    for d in digits:
        if d.index >= lastDigit.index:
            lastDigit.index = d.index
            lastDigit.valueStr = d.valueStr
    return lastDigit.valueStr

############

let inputFile = open("./day1_input.txt", fmRead)

var calibvalues: seq[int] = @[]
for line in inputFile.lines:
    # get first/last digit
    let firstDigit = line.getFirstDigit()
    let lastDigit = line.getLastDigit()
    # get calibration value
    calibvalues.add(parseInt(firstDigit & lastDigit))

close(inputFile)

echo calibvalues.sum()
