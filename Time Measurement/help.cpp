#include <iostream>

using namespace std;

void help() {
	cout << endl;
	cout << "使い方: measure [command] [arg1] [arg2]..." << endl;
	cout << "  [command] を実行し,最後にその所要時間を表示します" << endl;
	cout << "  引数 [arg1] [arg2]... はそのまま [command] に渡されます" << endl;
	cout << endl;
}