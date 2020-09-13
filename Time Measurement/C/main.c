#include "general.h"
#include <stdio.h>

void argAnalyze(D*,int,char*[]);
void execute(D*);
void help();
void version();

int main(int argc,char *argv[]) {
	D d=initData();
	argAnalyze(&d,argc,argv);
	switch (d.mode) {
		case CMMain:    execute(&d); break;
		case CMHelp:    help();      break;
		case CMVersion: version();   break;
	}
	return 0;
}