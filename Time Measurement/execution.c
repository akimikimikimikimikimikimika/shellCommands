#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <math.h>

void help();

char* argparse(int,char*[]);
void copy(const char*,char*);
void clear(char*);

int measure(char *);
void printTime(struct timeval,struct timeval);

int core(int argc,char* argv[]) {

	if (argc==1) {
		help();
		return 0;
	}
	else if (!(strcmp(argv[1],"help")&&strcmp(argv[1],"-help")&&strcmp(argv[1],"--help"))) {
		help();
		return 0;
	}

	char *arg=argparse(argc,argv);
	char text[strlen(arg)];
	copy(arg,text);
	clear(arg);
	return measure(text);
}

int measure(char *cmd) {
	int extcode;
	struct timeval start,end;
	gettimeofday(&start,NULL);
	extcode=system(cmd);
	gettimeofday(&end,NULL);
	clear(cmd);
	if (extcode<0) {
		printf("実行に失敗しました\n");
		return 1;
	}
	else {
		printTime(start,end);
		printf("exit code: %d\n",extcode%255);
		return extcode%255;
	}
}

void printTime(struct timeval start,struct timeval end) {
	long double sec=(long double)(end.tv_sec-start.tv_sec);
	long double usec=(long double)(end.tv_usec-start.tv_usec);

	long double s=sec+usec/1000000;
	long double m=s/60;
	long double h=m/60;
	long double ms=s*1000;

	printf("time: ");
	if (h>=1) printf("%.0fh ",floor(h));
	if (m>=1) printf("%.0fm ",floor(fmod(m,60)));
	if (s>=1) printf("%.0fs ",floor(fmod(s,60)));
	printf("%.3fms\n",fmod(ms,1000));
}