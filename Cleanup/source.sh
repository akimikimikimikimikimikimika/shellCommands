#! /usr/bin/env bash

remove() {
    local s
    s="$1"
    if [ -d "$1" ]; then
        find "$1" -name ".DS_Store" -exec rm "{}" \;
        find "$1" -name "._*" -exec rm "{}" \;
    else
        echo "ディレクトリではありません:"
        echo "$s">&2
    fi
}

help() {
    echo """

使い方: cleanup [path1] [path2]...
 [path1] [path2]... で指定したディレクトリ内の隠しファイルをまとめて削除します
 [path1] [path2]... を指定しない場合は,カレントディレクトリ内の隠しファイルを削除します

"""
}

if [ $1 = "help" -o $1 = "-help" -o $1 = "--help" ]; then
    help
elif [ $# -eq 0 ]; then
    remove "`pwd`"
else
    for s in "$@"; do
        remove "$s"
    done
fi