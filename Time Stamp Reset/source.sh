#! /usr/bin/env bash

if [ -z "$1" ]; then
    echo "No file name specified">&2
    exit 1
elif [ -L "$1" ]; then
    touch -t 197001010000 "$1"
    exit $?
elif [ -f "$1" ]; then
    touch -t 197001010000 "$1"
    exit $?
elif [ -d "$1" ]; then
    find "$1" -exec touch -t 197001010000 "{}" \;
    exit $?
else
    echo "No such file or directory: ""$1">&2
    exit 1
fi