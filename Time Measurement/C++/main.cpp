#include "lib.hpp"

void argAnalyze(Data*,VS);
void exec(Data*);
void help();
void version();

int main(int argc,char *argv[]) {
	if (argc==1) error("引数が不足しています");
	VS args(argv+1,argv+argc);
	Data d;

	argAnalyze(&d,args);

	switch (d.mode) {
		case CMMain:    exec(&d);    break;
		case CMHelp:    help();    break;
		case CMVersion: version(); break;
	}

	return 0;
}