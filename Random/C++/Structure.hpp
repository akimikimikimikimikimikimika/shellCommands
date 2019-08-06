#include <functional>

#ifndef STRUCTURE
#define STRUCTURE

enum RandType {
	Device,
	Rand,
	DRE,
	Minstd0,
	Minstd,
	Knuth,
	Ranlux3,
	Ranlux4,
	MT,
	MT64
};

enum SeedType {
	Nothing,
	Time,
	DevSeed,
	Custom
};

enum ValueType {
	Int,
	Real
};

struct Customize {
	RandType mode = Device;
	ValueType valueType = Real;
	SeedType seedType = DevSeed;
	unsigned long long seed = 0;
	unsigned long long discard = 0;
	unsigned long long length = 1;
	bool concurrent = false;
	bool visible = true;
	bool defaultRange = true;
	long double min = 0.0;
	long double max = 1.0;
	std::function<double()> generator;
};

#endif