build-clang++:
	@clang++ -O3 -std=c++2a -o ../bin/measure-cpp C++/*.cpp
debug-clang++:
	@clang++ -g -O0 -std=c++2a -o /tmp/debugging-bin C++/*.cpp
	@lldb /tmp/debugging-bin
	@rm /tmp/debugging-bin
build-g++:
	@g++ -O3 -std=c++2a -pthread -lstdc++fs -o ../bin/measure-cpp C++/*.cpp
debug-g++:
	@g++ -g -O0 -std=c++2a -pthread -lstdc++fs -o /tmp/debugging-bin C++/*.cpp
	@gdb /tmp/debugging-bin
	@rm /tmp/debugging-bin
build-clang:
	@clang -O3 -std=c17 -pthread -o ../bin/measure-c C/*.c
debug-clang:
	@clang -g -O0 -std=c17 -pthread -o /tmp/debugging-bin C/*.c
	@lldb /tmp/debugging-bin
	@rm /tmp/debugging-bin
build-gcc:
	@gcc -O3 -std=c17 -lm -lrt -lpthread -o ../bin/measure-c C/*.c
debug-gcc:
	@clang -g -O0 -std=c17 -lm -lrt -lpthread -o /tmp/debugging-bin C/*.c
	@gdb /tmp/debugging-bin
	@rm /tmp/debugging-bin
build-swift:
	@swiftc Swift/*.swift -o ../bin/measure-swift
build-go:
	@go build -ldflags="-s -w" -o ../bin/measure-go Go/*.go
build-rust:
	@cd Rust && cargo build --release
	@mv Rust/target/release/measure ../bin/measure-rs
	@rm -rf Rust/target
build-java:
	@cd Java && javac *.java -Xlint:unchecked
	@cd Java && jar cfe ../measure-java.jar measure *.class
	@cd Java && rm -f *.class
build-cs:
	@mcs C#/*.cs -out:measure-cs.exe