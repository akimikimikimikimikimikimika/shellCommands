cpp := /usr/bin/clang++
target := x86_64-unknown-linux-gnu
binary := measure-cpp-linux-amd64

build-macos-universal:
	@/usr/bin/clang++ -O3 -std=c++2a -o .~amd64 *.cpp -target x86_64-apple-macos11
	@/usr/bin/clang++ -O3 -std=c++2a -o .~arm64 *.cpp -target arm64e-apple-macos11
	@lipo -create -output ../binaries/measure-cpp-macos .~amd64 .~arm64 && rm .~amd64 .~arm64

build:
	@$(cpp) -O3 -std=c++2a -lstdc++fs -lpthread -o ../binaries/$(binary) -target $(target) *.cpp

debug:
	@$(cpp) -g -O0 -std=c++2a -lstdc++fs -lpthread -o ../binaries/measure-debug *.cpp