#include "Structure.h"

int argAnalyze(int, char *[], Customize*);
void generate(Customize*);

int main(int argc,char* argv[]) {

	Customize c = init();
	int result;

	result=argAnalyze(argc,argv,&c);
	if (result) generate(&c);

	return 0;

}