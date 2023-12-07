import strutils
import math

type
    DigitString = tuple[word: string, valueStr: string]

let digitWords: seq[DigitString] = @[
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

let inputFile = open("./day1_input.txt", fmRead)
# let inputFile = open("./tmp.txt", fmRead)

var calibvalues: seq[int] = @[]
for line in inputfile.lines:
    # find "two-digit number" candidate
    var digitsSeq: seq[tuple[index: int, valueStr: string]] = @[]
    for d in digitWords:
        if line.contains(d.word):
            # "first digit" candidate
            digitsSeq.add( (line.find(d.word), d.valueStr) )
            # "last digit" candidate
            digitsSeq.add( (line.rfind(d.word), d.valueStr) )
    
    # find first/last digit
    var firstDigit = (index: line.high(), valueStr: "")
    var lastDigit = (index: 0, valueStr: "")
    for dig in digitsSeq:
        # find first digit
        if dig.index <= firstDigit.index:
            firstDigit.index = dig.index
            firstDigit.valueStr = dig.valueStr
        # find last digit
        if dig.index >= lastDigit.index:
            lastDigit.index = dig.index
            lastDigit.valueStr = dig.valueStr
    
    # get calibration value
    calibvalues.add(parseInt(firstDigit.valueStr & lastDigit.valueStr))

close(inputFile)

echo calibvalues.sum()
