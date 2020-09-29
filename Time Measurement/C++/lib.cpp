#include <cstring>
#include "lib.hpp"

void error(string text) {
	cerr << text << endl;
	exit(1);
}

void output(VS d) {
	for (string l:d) cout << l << endl;
}

bool eq(string target,string s1) {
	return target==s1;
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