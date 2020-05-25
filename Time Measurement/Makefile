# cmd := clang++/g++/clang/gcc
# ext := cpp/c
# std := c++2a/c17
# binFile := ../bin/measure

option := -std=${std} -O3

src = $(shell find . -path "./${searchPath}")
obj = ${src:%.${ext}=%.o}

${obj}: %.o: %.${ext} # compiling
	@${cmd} -c ${option} -o $@ $<
bin: ${obj} # linking
	@${cmd} -o ${binFile} ${option} ${obj}
clean:
	@rm -f ${obj}
build: bin clean



build-clang++:
	@make build -e cmd="clang++" ext=cpp std=c++2a binFile=../bin/measure-cpp searchPath=source.cpp
build-g++:
	@make build -e cmd="g++ -pthread -lstdc++fs" ext=cpp std=c++2a binFile=../bin/measure-cpp searchPath=source.cpp
build-clang:
	@make build -e cmd=clang ext=c std=c17 binFile=../bin/measure-c searchPath="C/*.c"
build-gcc:
	@make build -e cmd="gcc -lm -lrt" ext=c std=c17 binFile=../bin/measure-c searchPath="C/*.c"
build-swift:
	@swiftc *.swift -o ../bin/measure-swift
build-go:
	@go build -o ../bin/measure-go *.go
build-rust:
	@rustc *.rs -C opt-level=3 -o ../bin/measure-rs
build-java:
	@javac Measure.java -Xlint:unchecked
	@jar cfe measure-java.jar Measure *.class
	@rm -f *.class
build-cs:
	@mcs source.cs -out:measure-cs.exe