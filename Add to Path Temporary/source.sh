#! /usr/bin/env bash

# usage: source ATPT [dirname]
# if you do not specify dirname, the current directory will be added.

help(){
	echo """

使い方:
 source ATPT [path]
 source ATPT

[path] に指定したディレクトリを一時的に \$PATH に追加します
[path] を指定しない場合は,カレントディレクトリを \$PATH に追加します
現在実行中のシェルのみでこの設定は有効です
一時的に \$PATH に追加することで,ディレクトリ中の実行ファイルをより簡単に呼び出せるようになったりします
ただし,システムのコマンドと同名の実行ファイルが存在する場合は注意してください。追加したことで,システムのコマンドが呼び出せなくなる場合があります。

"""
}

if [ -z "$1" ]; then
	nd="`pwd`"
else
	nd="$(cd $(dirname "$1"); pwd)"
fi
PATH="$nd:$PATH"