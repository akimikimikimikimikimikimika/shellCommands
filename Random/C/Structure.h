#ifndef STRUCTURE
#define STRUCTURE

enum SeedType {
	Nothing,
	Time,
	Custom
};

enum ValueType {
	Int,
	Real
};

typedef struct customize {
	enum ValueType valueType;
	enum SeedType seedType;
	unsigned long long seed;
	unsigned long long length;
	int visible;
	int defaultRange;
	long double min;
	long double max;
} Customize;

static Customize init() {
	Customize c;
	c.valueType = Real;
	c.seedType = Time;
	c.seed = 0;
	c.length = 1;
	c.visible = 1;
	c.defaultRange = 1;
	c.min = 0.0;
	c.max = 1.0;
	return c;
}

#endif