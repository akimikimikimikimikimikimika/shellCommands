#! /usr/bin/env bash

command=()
out=inherit
err=inherit
result=stderr
multiple=0

argAnalyze() {
	local l=("$@")
	if [ `eq $1 "-h" "help" "-help" "--help"` ]; then
		help
	elif [ `eq $1 "-v" "version" "-version" "--version"` ]; then
		version
	fi
	local key=0
	while [ "${#l[@]}" -gt 0 ] ; do
		local a="${l[0]}"
		if [ $key -ne 0 ]; then
			case $key in
				1) out="$a";;
				2) err="$a";;
				3) result="$a";;
			esac
			key=0
			continue
		fi
		if [ `eq "$a" "-m" "-match"` ]; then
			multiple=1
		elif [ `eq "$a" "-o" "-out" "-stdout"` ]; then
			key=1
		elif [ `eq "$a" "-e" "-err" "-stderr"` ]; then
			key=2
		elif [ `eq "$a" "-r" "-result"` ]; then
			key=3
		else
			command=l
			break
		fi
		unset l[0]
		l=("${l[@]}")
	done
	if [ "${#command[@]}" -eq 0 ]; then
		error "実行する内容が指定されていません"
	fi
}

execute() {
	local pid
	local ec=0
	eval """
		run(){
			TIMEFORMAT=%3R
			time
		}
	"""
	if [ multiple -eq 0 ]; then
	else
	fi
	exit $ec
}

error() {
	echo "$1" >2
	exit 1
}

eq() {
	local target
	local init=0
	for s in "$@" ; do
		if [ $init -eq 0 ]; then
			target="$s"
			init=1
		elif [ "$s" = "$target" ]; then
			echo 1
			break
		fi
	done
	echo 0
}