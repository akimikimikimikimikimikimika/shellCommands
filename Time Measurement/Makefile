# cmd := clang++/g++/clang/gcc
# ext := cpp/c
# std := c++2a/c17
# binFile := ../bin/measure

option := -std=${std} -O3

src = $(shell find . -name "*.${ext}")
obj = ${src:%.${ext}=%.o}

${obj}: %.o: %.${ext} # compiling
	@${cmd} -c ${option} -o $@ $<
bin: ${obj} # linking
	@${cmd} -o ${binFile} ${option} ${obj}
clean:
	@rm -f ${obj}
build: bin clean



build-clang++:
	@make build -e cmd="clang++ -pthread" ext=cpp std=c++2a binFile=../bin/measure-cpp
build-g++:
	@make build -e cmd="g++ -pthread" ext=cpp std=c++2a binFile=../bin/measure-cpp
build-clang:
	@make build -e cmd=clang ext=c std=c17 binFile=../bin/measure-c
build-gcc:
	@make build -e cmd=gcc ext=c std=c17 binFile=../bin/measure-c