swiftc := /usr/bin/swiftc
target := x86_64-unknown-linux-gnu
binary := measure-swift-linux-amd64

build-macos-universal:
	@swiftc *.swift -o .~amd64 -target x86_64-apple-macos11
	@swiftc *.swift -o .~arm64 -target arm64e-apple-macos11
	@lipo -create -output ../binaries/measure-swift-macos .~amd64 .~arm64 && rm .~amd64 .~arm64

build:
	@$(swiftc) *.swift -o ../binaries/$(binary) -target $(target)