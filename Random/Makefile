build-clang++:
	@make build -f c.mk -e cmd=clang++ ext=cpp dir=C++ std=c++2a binFile=../bin/random-cpp
build-g++:
	@make build -f c.mk -e cmd=g++ ext=cpp dir=C++ std=c++2a binFile=../bin/random-cpp
build-icpc:
	@make build -f c.mk -e cmd=icpc ext=cpp dir=C++ std=c++2a binFile=../bin/random-cpp
build-clang:
	@make build -f c.mk -e cmd=clang ext=c dir=C std=c17 binFile=../bin/random-c
build-gcc:
	@make build -f c.mk -e cmd=gcc ext=c dir=C std=c17 binFile=../bin/random-c
build-icc:
	@make build -f c.mk -e cmd=icc ext=c dir=C std=c11 binFile=../bin/random-c
build-swift:
	swiftc -o ../bin/random-swift Swift/*.swift
build-go:
	go build -o ../bin/random-go Random.go
build-fortran:
	gfortran Random.f95 -o ../bin/random-f -O3 -fopenmp
build-ifort:
	ifort Random.f95 -o ../bin/random-f -O3 -qopenmp