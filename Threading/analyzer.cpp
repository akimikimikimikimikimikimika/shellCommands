#include "structure.hpp"

void exitWithError(string);

enum Receiver {
	None,
	Mode,
	List,
	SequenceFirst,
	SequenceSecond
};

void analyze(int argc,char *argv[],O &o) {
	int sFirst,sSecond;

	Receiver r=None;
	for (int n=1;n<argc;n++) {
		S param=S(argv[n]);
		if (param=="-m") {
			r=Mode;
		}
		if (param=="-l") {
			o.list.push_back(new VS());
			r=List;
		}
		else if (param=="-s") {
			o.list.push_back(new VS());
			r=SequenceFirst;
		}
		else if (param=="-parallel") {
			o.mode = Parallel;
			r=None;
		}
		else if (param=="-group") {
			o.mode = Group;
			r=None;
		}
		else if (param=="-serial") {
			o.mode = Serial;
			r=None;
		}
		else if (param=="-test") {
			o.test = true;
			r=None;
		}
		else if (r==Mode) {
			if (param=="parallel") o.mode = Parallel;
			else if (param=="group") o.mode = Group;
			else if (param=="serial") o.mode = Serial;
			else exitWithError("-mオプションの値が不正です: "+param);
			r=None;
		}
		else if (r==List) o.list.back()->push_back(param);
		else if (r==SequenceFirst) {
			try{
				sFirst=stoi(param);
			}
			catch(const invalid_argument&) {
				exitWithError("-sオプションの値が不正です: "+param);
			}
			r=SequenceSecond;
		}
		else if (r==SequenceSecond) {
			try{
				sSecond=stoi(param);
			}
			catch(const invalid_argument&) {
				exitWithError("-sオプションの値が不正です: "+param);
			}
			if (sFirst==sSecond) o.list.back()->push_back(std::to_string(sFirst));
			if (sFirst<sSecond) for (int n=sFirst;n<=sSecond;n++) o.list.back()->push_back(std::to_string(n));
			if (sFirst>sSecond) for (int n=sFirst;n>=sSecond;n--) o.list.back()->push_back(std::to_string(n));
			r=None;
		}
		else o.format.push_back(param);
	}
}