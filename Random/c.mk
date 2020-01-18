# cmd := clang++/g++/clang/gcc
# ext := cpp/c
# std := c++2a/c17
# binFile := ../bin/random
# dir := C/C++

option := -std=${std} -O3

src = $(shell find ${dir} -name "*.${ext}")
obj = ${src:%.${ext}=%.o}

${obj}: %.o: %.${ext} # compiling
	@${cmd} -c ${option} -o $@ $<
bin: ${obj} # linking
	@${cmd} -o ${binFile} ${option} ${obj}
clean:
	@rm -f ${obj}
build: bin clean