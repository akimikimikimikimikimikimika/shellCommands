#! /usr/bin/env bash

main(){
    cd "$(cd $(dirname $0); pwd)"
    checkIfExists swift "build mui"
    checkIfExists swift "build trash"
    choice clang gcc appearance
    choice clang++ g++ thread
    choice clang gcc measure-c
    choice clang++ g++ measure-cpp
    choice clang gcc random-c
    choice clang++ g++ random-cpp
    checkIfExists swift "build random-swift"
    checkIfExists go "build random-go"
    checkIfExists gfortran "build random-f"
}

checkIfExists(){
    if type "$1" > /dev/null 2>&1; then
        $2
    else
        $3
    fi
}

build(){
    make $1 -s && echo $1
}
choice(){
    checkIfExists $1 "build $3 -e c=$1" "checkIfExists $2 \"build $3 -e c=$2\""
}

dialog(){
    echo
    echo "buildは利用可能な全てのコマンドをコンパイルします"
    echo "よろしいですか?"
    echo
    echo "returnキーを押すとコンパイルが始まります"
    echo "Ctrl-Cでコンパイルを中断します"
    read rtn
    echo
    echo "コンパイル中..."
    echo
    echo "コンパイルに成功したコマンドを以下に表示します"
    echo "このコンピュータではこれらのコマンドが利用可能です"
    echo "これらのコマンドを利用するには,binディレクトリをPATHに追加してください"
    echo
    main
    echo
}

abort(){
    echo "このコンピュータにはmakeコマンドがインストールされていないため利用できません"
    echo "終了します"
    exit
}

checkIfExists make dialog abort