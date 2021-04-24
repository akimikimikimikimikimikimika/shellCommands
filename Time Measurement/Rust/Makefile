build-macos-universal: target/x86_64-apple-darwin/release/measure target/aarch64-apple-darwin/release/measure
	@lipo -create -output ../binaries/measure-rs-macos target/x86_64-apple-darwin/release/measure target/aarch64-apple-darwin/release/measure
	@sleep 1
	@rm -fr target

build: target/x86_64-unknown-linux-gnu/release/measure target/aarch64-unknown-linux-gnu/release/measure target/x86_64-pc-windows-msvc/release/measure target/aarch64-pc-windows-msvc/release/measure
	@sleep 1
	@rm -fr target

debug: target/debug/measure
	@mv target/debug/measure ../binaries/measure-debug
	@sleep 1
	@rm -fr target



target/x86_64-apple-darwin/release/measure:
	@cargo build --release --target=x86_64-apple-darwin

target/aarch64-apple-darwin/release/measure:
	@cargo build --release --target=aarch64-apple-darwin

target/x86_64-unknown-linux-gnu/release/measure:
	@cargo build --release --target=x86_64-unknown-linux-gnu

target/aarch64-unknown-linux-gnu/release/measure:
	@cargo build --release --target=aarch64-unknown-linux-gnu

target/x86_64-pc-windows-msvc/release/measure:
	@cargo build --release --target=x86_64-unknown-linux-gnu

target/aarch64-pc-windows-msvc/release/measure:
	@cargo build --release --target=aarch64-unknown-linux-gnu

target/debug/measure:
	@cargo build