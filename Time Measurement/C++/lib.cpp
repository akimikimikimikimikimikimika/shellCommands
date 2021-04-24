#include <cstring>
#include <sstream>
#include "lib.hpp"

void error(S text) {
	cerr << text << endl;
	exit(1);
}

void output(VS d) {
	for (string l:d) cout << l << endl;
}

bool eq(S target,S s1) {
	return target==s1;
}



typedef stringstream SS;
S join(VS v,const char* delim) {
	SS ss;
	copy(v.begin(),v.end(),ostream_iterator<S>(ss,delim));
	return ss.str();
}



// convert array with memory management
char** vs2ca(VS vs) {
	int s=vs.size();
	auto ca=new char*[s+1];
	int n=0;
	for (string s:vs) {
		auto c=new char[s.size()+1];
		auto cc=s.c_str();
		strcpy(c,cc);
		ca[n]=c;
		n++;
	}
	ca[s]=nullptr;
	return ca;
}



void clear(char** p) {
	int n=0;
	while (p[n]!=nullptr) {
		delete[] p[n];
		n++;
	}
	delete[] p;
}