#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <fcntl.h>
#include "general.h"
#include "time_switch.h"

void checkFile(const char* path) {
	FILE *f=fopen(path,"a");
	if (f==NULL) {
		char m[60+strlen(path)];
		strcpy(m,"指定したパスには書き込みできません: ");
		strcat(m,path);
		error(m);
	}
	fclose(f);
}

int fh(RO *r) {
	switch (r->type) {
		case ROStdout: return STDOUT_FILENO;
		case ROStderr: return STDERR_FILENO;
		case ROFile:
			checkFile(r->file);
			return open(r->file,O_WRONLY|O_APPEND);
	}
}

#define DESC(fd,fmt,var) {\
	char tmp[20];\
	sprintf(tmp,fmt,var);\
	write(fd,tmp,strlen(tmp));\
}
void descTime(int fd,TIMETYPE st,TIMETYPE en) {
	double sec=SEC(en)-SEC(st);
	double nsec=NSEC(en)-NSEC(st);
	if (nsec<0) { nsec+=1e+9; sec-=1; }
	double r,v;

	write(fd,"time: ",6);
	r=sec/3600; v=floor(r);
	if (v>=1) DESC(fd,"%.0lfh ",v);
	r=(r-v)*60; v=floor(r);
	if (v>=1) DESC(fd,"%.0lfm ",v);
	r=(r-v)*60; v=floor(r);
	if (v>=1) DESC(fd,"%.0lfs ",v);
	DESC(fd,"%07.3lfms\n",nsec/1e+6);
}
#undef DESC