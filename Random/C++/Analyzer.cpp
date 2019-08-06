#include <string>
#include "Structure.hpp"

using namespace std;

void help();
void version();
RandType detectRT(string);

enum Responder {
	None,
	Mode,
	Seed,
	Discard,
	Length,
	RangeFirst,
	RangeSecond
};

bool argAnalyze(int argc, char *argv[], Customize &c) {

	if (argc>1) {
		string firstArg = string(argv[1]);
		if (firstArg=="help"||firstArg=="-help"||firstArg=="--help") {
			help();
			return false;
		}
		if (firstArg=="version"||firstArg=="-version"||firstArg=="--version") {
			version();
			return false;
		}
	}

	Responder r=None;
	string sFirst="";
	string sSecond="";

	for (int n=1;n<argc;n++) {
		string param=string(argv[n]);
		if (param=="-m"||param=="-mode") r=Mode;
		else if (param=="-s"||param=="-seed") r=Seed;
		else if (param=="-d"||param=="-discard") r=Discard;
		else if (param=="-i"||param=="-int") {
			c.valueType=Int;
			r=RangeFirst;
		}
		else if (param=="-r"||param=="-real") {
			c.valueType=Real;
			r=RangeFirst;
		}
		else if (param=="-l"||param=="-length") r=Length;
		else if (param=="-parallel") c.concurrent=true;
		else if (param=="-hidden"||param=="-invisible") c.visible=false;
		else if (r==Mode) {
			c.mode=detectRT(param);
			r=None;
		}
		else if (r==Seed) {
            if (param=="none") c.seedType=Nothing;
            else if (param=="time") c.seedType=Time;
            else if (param=="device") c.seedType=DevSeed;
            else {
                c.seedType=Custom;
                c.seed=stoull(param);
            }
			r=None;
		}
		else if (r==Discard) {
			c.discard=stoull(param);
			r=None;
		}
		else if (r==Length) {
			c.length=stoull(param);
			r=None;
		}
		else if (r==RangeFirst) {
			sFirst=param;
			c.defaultRange=false;
			r=RangeSecond;
		}
		else if (r==RangeSecond) {
			sSecond=param;
			r=None;
		}
	}

	if (sFirst!="") {
		if (c.valueType==Int) {
			long long int iFirst = stoll(sFirst);
			long long int iSecond = 0;
			if (sSecond!="") iSecond = stoll(sSecond);
			if (iFirst>iSecond) {
				c.max=(long double)iFirst;
				c.min=(long double)iSecond;
			}
			else {
				c.max=(long double)iSecond;
				c.min=(long double)iFirst;
			}
		}
		if (c.valueType==Real) {
			long double rFirst = stold(sFirst);
			long double rSecond = 0;
			if (sSecond!="") rSecond = stold(sSecond);
			if (rFirst>rSecond) {
				c.max=rFirst;
				c.min=rSecond;
			}
			else {
				c.max=rSecond;
				c.min=rFirst;
			}
		}
	}

	return true;

}

RandType detectRT(string s) {
	if (s=="device") return Device;
	else if (s=="rand") return Rand;
	else if (s=="default") return DRE;
	else if (s=="minstd0") return Minstd0;
	else if (s=="minstd") return Minstd;
	else if (s=="knuth") return Knuth;
	else if (s=="ranlux3") return Ranlux3;
	else if (s=="ranlux4") return Ranlux4;
	else if (s=="mt") return MT;
	else if (s=="mt64") return MT64;
	else return Device;
}