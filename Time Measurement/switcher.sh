#! /usr/bin/env bash

replace() {
	rm -fr "$measure"
	if [ -f "$measure-$1" ]; then
		ln -s "measure-$1" "$measure"
		echo "successfully switched to measure-$1"
	else
		echo "failed to choose: measure-$1">&1
		exit 1
	fi
}

measure="`dirname "$0"`/measure"
case "$1" in
	c|C) replace c;;
	cpp|c++|C++) replace cpp;;
	rs|rust|Rust) replace rs;;
	go|Go) replace go;;
	swift|Swift) replace swift;;
	php|PHP) replace php;;
	py|python|Python) replace py;;
	rb|ruby|Ruby) replace rb;;
	cs|c#|C#) replace cs;;
	js|javascript|JavaScript|node) replace js;;
	java|Java) replace java;;
	jl|julia|Julia) replace jl;;
	*)
		if [ -L "$measure" ]; then
			echo "Current measure: `readlink "$measure"`"
		else
			echo "Measure is not available currently"
		fi
		echo "usage: measure [type]"
		echo " switch to the specified type for the measure command"
		;;
esac