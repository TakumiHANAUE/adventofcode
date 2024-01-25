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

let cardStrength = {
    'J': 0,
    '2': 1,
    '3': 2,
    '4': 3,
    '5': 4,
    '6': 5,
    '7': 6,
    '8': 7,
    '9': 8,
    'T': 9,
    'Q': 10,
    'K': 11,
    'A': 12,
}.toTable

proc getPossibleHands(h: string): seq[string] =
    result = @[]
    let uniqueCards = h.deduplicate()
    for c in uniqueCards:
        result.add(h.replace('J', c))

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

proc getHandTypeWithJokerRule(h: string): HandType =
    result = HIGH_CARD
    let possibleTypes = getPossibleHands(h).map( proc(x: string): HandType = getHandType(x) )
    for t in possibleTypes:
        if t > result:
            result = t

proc cmpEachCards(h1, h2: string): int =
    result = 0
    for i in 0 .. h1.high:
        if cardStrength[h1[i]] > cardStrength[h2[i]]:
            result = 1
            break
        elif cardStrength[h1[i]] < cardStrength[h2[i]]:
            result = -1
            break
        else:
            discard

proc cmpHands(h1, h2: string): int =
    result = 0
    let h1Type = getHandTypeWithJokerRule(h1)
    let h2Type = getHandTypeWithJokerRule(h2)
    if h1Type > h2Type:
        result = 1
    elif h1Type < h2Type:
        result = -1
    else:
        let cmpRet = cmpEachCards(h1, h2)
        if cmpRet == 1:
            result = 1
        elif cmpRet == -1:
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
