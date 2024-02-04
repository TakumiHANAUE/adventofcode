#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Invalid argument"
    exit -1
fi

YEAR=$1
DAY=$2
NEWDIRNAME="${YEAR}/day${DAY}"
FILENAME_BASE="day${DAY}"

if [ -d ${NEWDIRNAME} ]; then
    echo "${NEWDIRNAME} already exists"
    exit -2
fi

mkdir -p ${NEWDIRNAME}
cd ${NEWDIRNAME}
touch ${FILENAME_BASE}_part1.nim ${FILENAME_BASE}_part2.nim ${FILENAME_BASE}_input.txt 
