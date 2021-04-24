c := /usr/bin/clang
target := x86_64-unknown-linux-gnu
binary := measure-c-linux-amd64

build-macos-universal:
	@/usr/bin/clang -O3 -std=c17 -pthread -o .~amd64 *.c -target x86_64-apple-macos11
	@/usr/bin/clang -O3 -std=c17 -pthread -o .~arm64 *.c -target arm64e-apple-macos11
	@lipo -create -output ../binaries/measure-c-macos .~amd64 .~arm64 && rm .~amd64 .~arm64

build:
	@$(c) -O3 -std=c17 -lm -lrt -lpthread -o ../binaries/$(binary) -target $(target) *.c

debug:
	@$(c) -g -O0 -std=c17 -lm -lrt -lpthread -o ../binaries/measure-debug *.c