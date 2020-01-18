# cmd := clang++/g++
ext := cpp
std := c++2a
binFile := ../bin/thread

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
	@make build -e cmd=clang++
build-g++:
	@make build -e cmd=g++