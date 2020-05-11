#include "general.h"
#include <stdio.h>

int main(int argc,char *argv[]) {
	struct data d=initData();
	argAnalyze(&d,argc,argv);
	execute(&d,argv);
	return 0;
}