release:
	@dotnet build --configuration Release

debug:
	@dotnet build --configuration Debug

build:
	@dotnet publish --configuration Release -o binary
	@rm -rf bin obj
	@rm -rf ../binaries/measure-net
	@mv binary ../binaries/measure-net