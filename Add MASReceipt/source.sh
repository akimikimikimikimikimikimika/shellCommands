#! /usr/bin/env bash

addForcedly() {
    mkdir -p "$1"/Contents/_MASReceipt
    touch "$1"/Contents/_MASReceipt/receipt
    chmod 744 "$1"/Contents/_MASReceipt/receipt
    exit $?
}

if [ -d "$1" ]; then
    mkdir -p "$1"/Contents/_MASReceipt
    rtn=$?
    if [ $rtn -eq 0 ]; then
        touch "$1"/Contents/_MASReceipt/receipt
        chmod 744 "$1"/Contents/_MASReceipt/receipt
        rtn=$?
        exit $rtn
    else
        echo "This app seems to be uneditable"
        echo "By entering root password, you can add _MASReceipt forcedly"
        sudo addForcedly "$1"
    fi
fi