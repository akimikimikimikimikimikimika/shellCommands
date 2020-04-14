#include "general.h"

int main(int argc,char *argv[]) {
	struct data d=initData();
	argAnalyze(&d,argc,argv);
	execute(&d);
	return 0;
}