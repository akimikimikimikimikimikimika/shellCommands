build-macos-universal:
	@GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o .~amd64 *.go
	@GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o .~arm64 *.go
	@lipo -create -output ../binaries/measure-go-macos .~amd64 .~arm64 && rm .~amd64 .~arm64

build:
	@GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o ../binaries/measure-go-linux-amd64 *.go
	@GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o ../binaries/measure-go-linux-arm64 *.go
	@GOOS=linux GOARCH=arm go build -ldflags="-s -w" -o ../binaries/measure-go-linux-arm *.go
	@GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o ../binaries/measure-go-windows-amd64 *.go
	@GOOS=windows GOARCH=arm go build -ldflags="-s -w" -o ../binaries/measure-go-windows-arm *.go