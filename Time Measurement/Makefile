build-c-macos:
	@cd C && make build-macos-universal
build-c:
	@cd C && make debug
debug-c:
	@cd C && make build

build-cpp-macos:
	@cd C++ && make build-macos-universal
build-cpp:
	@cd C++ && make debug
debug-cpp:
	@cd C++ && make build

build-swift-macos:
	@cd Swift && make build-macos-universal
build-swift:
	@cd Swift && make build

build-go-macos:
	@cd Go && make build-macos-universal
build-go:
	@cd Go && make build

build-rust-macos:
	@cd Rust && make build-macos-universal

debug-rust:
	@cd Rust && make debug

build-java:
	@cd Java && make build

build-cs:
	@cd C# && make build
debug-cs:
	@cd C# && make debug

build-net:
	@cd NET && make build

clean-debug:
	@rm -f binaries/measure-debug
	@rm -rf *.dSYM
	@cd Java && make clean
	@cd C# && make clean