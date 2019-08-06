#include <iostream>
#include <string>
#include <cstdlib>
#include <cmath>
#include <chrono>

using namespace std;
using namespace std::chrono;
using hrc = chrono::high_resolution_clock;
using tp = hrc::time_point;

string argparse(int,char*[]);
int measure(string);
void printTime(tp,tp);

void help();

int core(int argc,char* argv[]) {

	if (argc==1) {
		help();
		return 0;
	}
	else {
		auto a1 = string(argv[1]);
		if (a1=="help"||a1=="-help"||a1=="--help") {
			help();
			return 0;
		}
	}

	string arg=argparse(argc,argv);
	return measure(arg);
}

int measure(string cmd) {
	int extcode;
	tp start,end;

	start = hrc::now();
	extcode=system(cmd.c_str());
	end = hrc::now();

	if (extcode<0) {
		cerr << "実行に失敗しました" << endl;
		return 1;
	}
	else {
		printTime(start,end);
		cout << "exit code: " << extcode%255 << endl;
		return extcode%255;
	}
}


void printTime(tp start,tp end) {
	auto dur=end-start;

	auto ms=fmod((long double)(duration_cast<nanoseconds>(dur).count())/1000000,1000);
	auto s=duration_cast<seconds>(dur).count()%60;
	auto m=duration_cast<minutes>(dur).count()%60;
	auto h=duration_cast<hours>(dur).count();

	cout << "time: ";
	if (h>=1) cout << h << "h ";
	if (m>=1) cout << m << "m ";
	if (s>=1) cout << s << "s ";
	cout << ms << "ms" << endl;

}
