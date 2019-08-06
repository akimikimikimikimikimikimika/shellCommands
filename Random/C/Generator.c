#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "Structure.h"

long double distribute(long double,long double,enum ValueType);
void r();

void generate(Customize *c) {

	unsigned long long n;

	if (c->seedType==Time) c->seed=(unsigned long long)time(NULL);
	if (c->seedType!=Nothing) srand(c->seed);

	if (c->valueType==Int&&c->defaultRange) {
		if (c->visible) for (n=0;n<c->length;n++) {printf("%d",rand());r();}
		else for (n=0;n<c->length;n++) rand();
	}
	else if (!c->visible) for (n=0;n<c->length;n++) distribute(c->min,c->max,c->valueType);
	else if (c->valueType==Int) for (n=0;n<c->length;n++) {
		printf("%lld",(long long int)distribute(c->min,c->max,Int));r();
	}
	else for (n=0;n<c->length;n++) {
		printf("%.9Lf",distribute(c->min,c->max,Real));r();
	}

}

static long double rmax = (long double)RAND_MAX;
long double distribute(long double min,long double max,enum ValueType t) {
	long double r = (long double)rand();
	if (t==Int) return r/rmax*(max-min)+min;
	else return r/(rmax+1)*(max-min)+min;
}

void r() {
	printf("\n");
}