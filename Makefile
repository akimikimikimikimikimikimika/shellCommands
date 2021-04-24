c := clang-macos
cpp := clang++-macos

main:
	echo "usage: make [cmd]"

mui:
	@cd Manage\ Ubiquitous\ Items && make build

trash:
	@cd Move\ to\ Trash && make build

appearance:
	@cd Appearance && make build -e cmd=${c}

thread:
	@cd Threading && make build-${cpp}

measure-cpp:
	@cd Time\ Measurement && make build-${cpp}
measure-c:
	@cd Time\ Measurement/C && make build
measure-swift:
	@cd Time\ Measurement && make build-swift-macos
measure-go:
	@cd Time\ Measurement && make build-go
measure-rs:
	@cd Time\ Measurement && make build-rust
measure-java:
	@cd Time\ Measurement && make build-java
measure-cs:
	@cd Time\ Measurement && make build-cs

random-cpp:
	@cd Random && make build-${cpp}
random-c:
	@cd Random && make build-${c}
random-swift:
	@cd Random && make build-swift
random-go:
	@cd Random && make build-go
random-f:
	@cd Random && make build-fortran