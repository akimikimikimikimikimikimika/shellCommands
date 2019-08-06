#include <string>
#include <regex>

using namespace std;

string parse(string);

string argparse(int argc,char* argv[]) {
	int n;
	string text;
	for (n=1;n<argc;n++) {
		text+=" "+parse(string(argv[n]));
	}
	return text;
}

string parse(string text) {
	text=regex_replace(text,regex("\\\\"),"\\\\");
	text=regex_replace(text,regex("'"),"'\"'\"'");
	text="'"+text+"'";
	return text;
}