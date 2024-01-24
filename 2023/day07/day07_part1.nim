import strutils
import sequtils
import std/tables
import algorithm

type
    HandBid = tuple
        hand: string
        bid: int

type
    HandType = enum
        HIGH_CARD = 0,
        ONE_PAIR,
        TWO_PAIR,
        THREE_OF_A_KIND
        FULL_HOUSE,
        FOUR_OF_A_KIND,
        FIVE_OF_A_KIND

let handStrength = {
    '2': 0,
    '3': 1,
    '4': 2,
    '5': 3,
    '6': 4,
    '7': 5,
    '8': 6,
    '9': 7,
    'T': 8,
    'J': 9,
    'Q': 10,
    'K': 11,
    'A': 12,
}.toTable

proc getHandType(h: string): HandType =
    let uniqueCards = h.deduplicate()
    let n = uniqueCards.len
    if n == 1:
        result = FIVE_OF_A_KIND
    elif n == 2:
        result = FULL_HOUSE
        for i in 0 .. uniqueCards.high:
            if h.count(uniqueCards[i]) == 4:
                result = FOUR_OF_A_KIND
    elif n == 3:
        result = TWO_PAIR
        for i in 0 .. uniqueCards.high:
            if h.count(uniqueCards[i]) == 3:
                result = THREE_OF_A_KIND
    elif n == 4:
        result = ONE_PAIR
    else:
        result = HIGH_CARD

proc cmpEachCards(h1, h2: string): int =
    result = 0
    for i in 0 .. h1.high:
        if handStrength[h1[i]] > handStrength[h2[i]]:
            result = 1
            break
        elif handStrength[h1[i]] < handStrength[h2[i]]:
            result = -1
            break
        else:
            discard

proc cmpHands(h1, h2: string): int =
    result = 0
    if getHandType(h1) > getHandType(h2):
        result = 1
    elif getHandType(h1) < getHandType(h2):
        result = -1
    else:
        if cmpEachCards(h1, h2) == 1:
            result = 1
        elif cmpEachCards(h1, h2) == -1:
            result = -1
        else:
            result = 0

proc cmpHands(hb1, hb2: HandBid): int =
    result = cmpHands(hb1.hand, hb2.hand)

###########

let fileName = "day07_input.txt"
let inputFile = open(fileName, fmRead)

var handBidSeq: seq[HandBid] = @[]
for line in inputFile.lines:
    let h = line.splitWhitespace()[0]
    let b = line.splitWhitespace()[1].parseInt()
    handBidSeq.add((h, b))
close(inputFile)

sort(handBidSeq, cmpHands)

var totalWinnings: int = 0
for i, handBid in handBidSeq:
    let rank = i + 1
    totalWinnings += handBid.bid * rank

echo totalWinnings
