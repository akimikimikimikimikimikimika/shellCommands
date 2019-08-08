#include <string>
#include <vector>

#ifndef STRUCTURE
#define STRUCTURE

using namespace std;
using S = string;
using I = int;
using B = bool;
using VS = vector<S>;
using VI = vector<I>;
using VVS = vector<VS>;
using VVSP = vector<VS*>;

enum ExecMode {
	Parallel,
	Group,
	Serial
};

struct Options {
	VS format;
	VVSP list;

	B test = false;
	ExecMode mode = Serial;
	VVS process;
};

using O = Options;

#endif