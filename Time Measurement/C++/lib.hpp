#ifndef LIB
#define LIB

#include <iostream>
#include <string>
#include <vector>

using namespace std;
typedef string S;
typedef vector<S> VS;

enum CommandMode { CMMain,CMHelp,CMVersion };
typedef CommandMode CM;

enum MultipleMode { MMNone,MMSerial,MMSpawn,MMThread };
typedef MultipleMode MM;

class Data {
	public:
		CM mode=CMMain;
		VS command;
		S out="inherit";
		S err="inherit";
		S result="stderr";
		MM multiple=MMNone;
};

void output(VS);
void error(S text);

// convert array with memory management
char** vs2ca(VS);
void clear(char**);

// concatenate vector<string>
S join(VS,const char*);

// easy equality check
bool eq(S target,S s1);
template<typename... Sn>
bool eq(S target, S s1, Sn ...sn) {
	return eq(target,s1) ? true : eq(target,sn...);
}

#endif