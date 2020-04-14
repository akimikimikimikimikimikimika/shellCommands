#include "general.h"
#include <string.h>
#include <stdlib.h>

enum AnalyzeKey { AKNull,AKStdout,AKStderr,AKResult };
char** copyArray(char*[],int,int);

void argAnalyze(struct data *d,int argc,char *argv[]) {
	int cmdBegin=0;
	enum AnalyzeKey key=AKNull;
	if (argc==1) error("引数が不足しています");
	else if (
		!strcmp(argv[1],"-h")||
		!strcmp(argv[1],"help")||
		!strcmp(argv[1],"-help")||
		!strcmp(argv[1],"--help")
	) help();
	else if (
		!strcmp(argv[1],"-v")||
		!strcmp(argv[1],"version")||
		!strcmp(argv[1],"-version")||
		!strcmp(argv[1],"--version")
	) version();
	for (int n=1;n<argc;n++) {
		char* a=argv[n];
		if (key!=AKNull) {
			switch (key) {
				case AKStdout: d->out=s2co(a); break;
				case AKStderr: d->err=s2co(a); break;
				case AKResult: d->result=s2ro(a); break;
				case AKNull: break;
			}
			key=AKNull;
			continue;
		}
		if (
			!strcmp(a,"-m")||
			!strcmp(a,"-multiple")
		) d->multiple=true;
		else if (
			!strcmp(a,"-o")||
			!strcmp(a,"-out")||
			!strcmp(a,"-stdout")
		) key=AKStdout;
		else if (
			!strcmp(a,"-e")||
			!strcmp(a,"-err")||
			!strcmp(a,"-stderr")
		) key=AKStderr;
		else if (
			!strcmp(a,"-r")||
			!strcmp(a,"-result")
		) key=AKResult;
		else {
			cmdBegin=n;
			break;
		}
	}
	if (cmdBegin==0) error("実行する内容が指定されていません");
	d->count=argc-cmdBegin;
	d->command=copyArray(argv,cmdBegin,d->count);
}

char** copyArray(char* b[],int from,int size) {
	char **a=(char**)malloc((size+1)*sizeof(char*));
	if (a==NULL) error("メモリ不足です");
	for (int n=0;n<size;n++) a[n]=copyStr(b[n+from]);
	a[size]=(char*)malloc(sizeof(char));
	a[size]=NULL;
	return a;
}