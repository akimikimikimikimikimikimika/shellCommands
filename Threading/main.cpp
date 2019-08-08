#include "structure.hpp"

void analyze(int,char*[],O&);
void craft(O&);
void execution(O&);

void help();

int main(int argc, char *argv[]) {

    if (argc==1) {
		help();
		return 0;
	}
	else {
		auto a1 = S(argv[1]);
		if (a1=="help"||a1=="-help"||a1=="--help") {
			help();
			return 0;
		}
	}

    O o;
	analyze(argc,argv,o);
    craft(o);
	execution(o);

    return 0;

}