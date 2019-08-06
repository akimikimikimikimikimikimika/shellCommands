#include <iostream>
#include <iomanip>
#include <thread>
#include <vector>
#include "Structure.hpp"

using namespace std;

void execute(Customize &c) {
	int precision = c.valueType==Int ? 0 : 19;
	if (c.concurrent) {
		vector<thread> threads;
		if (c.visible) for (int n=0;n<c.length;n++) threads.push_back(thread([&]{
			cout << fixed << setprecision(precision) << c.generator() << endl;
		}));
		else for (int n=0;n<c.length;n++) threads.push_back(thread([&]{
			c.generator();
		}));
		for (thread &eachthread : threads) eachthread.join();
	}
	else if (c.visible) for (int n=0;n<c.length;n++) cout << fixed << setprecision(precision) << c.generator() << endl;
	else for (int n=0;n<c.length;n++) c.generator();
}