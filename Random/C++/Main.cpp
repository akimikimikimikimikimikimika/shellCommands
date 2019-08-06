#include "Structure.hpp"

bool argAnalyze(int,char* [],Customize &);
void generatorSetup(Customize &);
void execute(Customize &);

int main(int argc,char* argv[]){

	struct Customize c;
	bool procession = argAnalyze(argc,argv,c);

	if (procession) {
		generatorSetup(c);
		execute(c);
	}

	return 0;

}