#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>
#include <regex>
#include "structure.hpp"

using T = thread;
using VT = vector<T>;
using NS = chrono::nanoseconds;

void action(S cmd,B test) {
	smatch found;
	if (test) printf("%s\n",cmd.c_str());
	else if (regex_search(cmd,found,regex("^sleep ([0-9\\.]+)$",regex_constants::icase))) {
		try{
			long double s = stold(found[1].str());
			this_thread::sleep_for(NS((long long int)(s*1e+9)));
		}
		catch (const invalid_argument& e) {
			printf("sleepの引数が不正です: %s\n",found[1].str().c_str());
		}
	}
	else {
		int extcode;
		extcode=system(cmd.c_str());
		if (extcode<0) cerr << "execution failed" << endl << "  @ \"" << cmd << "\"" << endl;
		else if (extcode>0) cerr << "exit code: " << extcode%256 << endl << "  @ \"" << cmd << "\"" << endl;
	}
}

void execution(O& o) {
	if (o.mode==Parallel) {
		VT threads;
		for (I n=0;n<o.process.size();n++) {
			auto sp=o.process[n];
			for (I m=0;m<sp.size();m++) threads.push_back(T(action,sp[m],o.test));
		}
		for (T &t : threads) t.join();
	}
	if (o.mode==Group) {
		VT threads;
		auto threadAction=[t=o.test](VS sp) {
			for (I m=0;m<sp.size();m++) action(sp[m],t);
		};
		for (I n=0;n<o.process.size();n++) threads.push_back(T(threadAction,move(o.process[n])));
		for (T &t : threads) t.join();
	}
	if (o.mode==Serial) {
		for (I n=0;n<o.process.size();n++) {
			auto sp=o.process[n];
			for (I m=0;m<sp.size();m++) action(sp[m],o.test);
		}
	}
}
