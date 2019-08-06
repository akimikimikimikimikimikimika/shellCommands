#include <stdlib.h>
#include <string.h>
#include "Structure.h"

void help();
void version();
int cmp(char *,char *);
int emp(char *);

enum Responder {
	None,
	Seed,
	Length,
	RangeFirst,
	RangeSecond
};

int argAnalyze(int argc, char *argv[], Customize *c) {

	enum Responder r=None;
	int n;
	char *firstArg = argv[1];
	char sFirst[30]="";
	char sSecond[30]="";
	char param[30];
	long long int iFirst = 0;
	long long int iSecond = 0;
	long double rFirst = 0;
	long double rSecond = 0;


	if (argc>1) {
		if (cmp(firstArg,"help")||cmp(firstArg,"-help")||cmp(firstArg,"--help")) {
			help();
			return 0;
		}
		if (cmp(firstArg,"version")||cmp(firstArg,"-version")||cmp(firstArg,"--version")) {
			version();
			return 0;
		}
	}


	for (n=1;n<argc;n++) {
		strcpy(param,argv[n]);
		if (cmp(param,"-s")||cmp(param,"-seed")) r=Seed;
		else if (cmp(param,"-i")||cmp(param,"-int")) {
			c->valueType=Int;
			r=RangeFirst;
		}
		else if (cmp(param,"-r")||cmp(param,"-real")) {
			c->valueType=Real;
			r=RangeFirst;
		}
		else if (cmp(param,"-l")||cmp(param,"-length")) r=Length;
		else if (cmp(param,"-hidden")||cmp(param,"-invisible")) c->visible=0;
		else if (r==Seed) {
            if (cmp(param,"none")) c->seedType=Nothing;
            else if (cmp(param,"time")) c->seedType=Time;
            else {
                c->seedType=Custom;
                c->seed=strtouq(param,NULL,10);
            }
			r=None;
		}
		else if (r==Length) {
			c->length=strtouq(param,NULL,10);
			r=None;
		}
		else if (r==RangeFirst) {
			strcpy(sFirst,param);
			c->defaultRange=0;
			r=RangeSecond;
		}
		else if (r==RangeSecond) {
			strcpy(sSecond,param);
			r=None;
		}
	}

	if (!emp(sFirst)) {
		if (c->valueType==Int) {
			iFirst = strtoq(sFirst,NULL,10);
			if (!emp(sSecond)) iSecond = strtoq(sSecond,NULL,10);
			if (iFirst>iSecond) {
				c->max=(long double)iFirst;
				c->min=(long double)iSecond;
			}
			else {
				c->max=(long double)iSecond;
				c->min=(long double)iFirst;
			}
		}
		if (c->valueType==Real) {
			rFirst = strtold(sFirst,NULL);
			if (!emp(sSecond)) rSecond = strtold(sSecond,NULL);
			if (rFirst>rSecond) {
				c->max=rFirst;
				c->min=rSecond;
			}
			else {
				c->max=rSecond;
				c->min=rFirst;
			}
		}
	}

	return 1;

}

int cmp(char *s1,char *s2) {
	return strcmp(s1,s2)==0;
}

int emp(char *s) {
	return strlen(s)==0;
}