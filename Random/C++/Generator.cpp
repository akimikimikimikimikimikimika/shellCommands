#include <random>
#include <ctime>
#include <memory>
#include "Structure.hpp"

#include <iostream>

using namespace std;

void seed(Customize &);
template <typename AnyType>
unique_ptr<AnyType> makeptr(AnyType);
long double LDConvert(long double,long double,long double,long double,long double);
long long int LLIConvert(long double,long double,long double,long double,long double);

void device(Customize &c) {
	auto fMax = (long double)random_device::max();
	auto fMin = (long double)random_device::min();
	auto tMin = c.min;
	auto tMax = c.max;
	if (c.valueType==Real) {
		c.generator=[fMin,fMax,tMin,tMax]() -> long double {
			random_device rng;
			return LDConvert((long double)rng(),fMin,fMax,tMin,tMax);
		};
	}
	else if (c.defaultRange) {
		c.generator=[]() -> long long int {
			random_device rng;
			return (long long int)rng();
		};
	}
	else {
		c.generator=[fMin,fMax,tMin,tMax]() -> long long int {
			random_device rng;
			return LLIConvert((long double)rng(),fMin,fMax,tMin,tMax);
		};
	}
}

void CRandom(Customize &c) {
	auto fMax = (long double)RAND_MAX;
	auto tMin = c.min;
	auto tMax = c.max;
	seed(c);
	if (c.seedType!=Nothing) srand(c.seed);
	if (c.valueType==Real) {
		c.generator=[fMax,tMin,tMax]() -> long double {
			return LDConvert((long double)rand(),0,fMax,tMin,tMax);
		};
	}
	else if (c.defaultRange) {
		c.generator=[]() -> long long int {
			return (long long int)rand();
		};
	}
	else {
		c.generator=[fMax,tMin,tMax]() -> long long int {
			return LLIConvert((long double)rand(),0,fMax,tMin,tMax);
		};
	}
}

#define RANDOMENGINE(MODE,RNGNAME) void MODE (Customize &c) { auto rng = makeptr(RNGNAME()); seed(c); if (c.seedType!=Nothing) (*rng).seed(c.seed); if (c.discard>0) (*rng).discard(c.discard); if (c.valueType==Real) { auto dist = makeptr(new uniform_real_distribution<long double>(c.min,c.max)); c.generator=[&dist=*move(*dist),&rng=*move(rng)]() -> long double {return dist(rng);}; } else if (c.defaultRange) { c.generator=[&rng=*move(rng)]() -> long long int {return (long long int)rng();}; } else { auto dist = makeptr(new uniform_int_distribution<long long int>((long long int)c.min,(long long int)c.max)); c.generator=[&dist=*move(*dist),&rng=*move(rng)]() -> long long int {return dist(rng);}; } }

RANDOMENGINE(defaultRandomEngine,default_random_engine)
RANDOMENGINE(minstd0,minstd_rand0)
RANDOMENGINE(minstd,minstd_rand)
RANDOMENGINE(knuth,knuth_b)
RANDOMENGINE(ranlux3,ranlux24)
RANDOMENGINE(ranlux4,ranlux48)
RANDOMENGINE(mt,mt19937)
RANDOMENGINE(mt64,mt19937_64)
#undef RANDOMENGINE

void generatorSetup(Customize &c) {
	switch (c.mode) {
		case Device: device(c); break;
		case Rand: CRandom(c); break;
		case DRE: defaultRandomEngine(c); break;
		case Minstd0: minstd0(c); break;
		case Minstd: minstd(c); break;
		case Knuth: knuth(c); break;
		case Ranlux3: ranlux3(c); break;
		case Ranlux4: ranlux4(c); break;
		case MT: mt(c); break;
		case MT64: mt64(c); break;
		default: break;
	}
}


// Utils

void seed(Customize &c) {
    switch (c.seedType) {
		case Nothing: case Custom:
			break;
        case Time:
            c.seed=(unsigned long long)time(nullptr);
            break;
        case DevSeed:
            random_device rng;
            c.seed=(unsigned long long)rng();
            break;
    }
}

template <typename AnyType>
unique_ptr<AnyType> makeptr(AnyType ro) {
	return make_unique<AnyType>(ro);
}

long double LDConvert(long double v,long double fMin,long double fMax,long double tMin,long double tMax) {
	return (v-fMin)/(fMax-fMin+1)*(tMax-tMin)+tMin; // [fMin,fMax] -> [tMin,tMax)
}

long long int LLIConvert(long double v,long double fMin,long double fMax,long double tMin,long double tMax) {
	return (long long int)round((v-fMin)/(fMax-fMin)*(tMax-tMin)+tMin); // [fMin,fMax] -> [tMin,tMax]
}