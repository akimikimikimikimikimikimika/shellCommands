#include "general.h"

#ifndef EXEC
#define EXEC

struct exec {
	D* d;
	int r;
	int ec;
};
typedef struct exec X;

struct subprocess {
	CO *out;
	CO *err;
	char* description;
	char** args;
	int pid;
	int ec;
	int error;
};
typedef struct subprocess SP;

SP sp(D*,char** args,char* desc);
void startSP(SP*);
void waitSP(SP*);
void runSP(SP*);
void descEC(X*,SP*);

#endif