#include "general.h"
#include <string.h>

enum AnalyzeKey { AKNull,AKStdout,AKStderr,AKResult };

void argAnalyze(struct data *d,int argc,char *argv[]) {
	int body=0;
	enum AnalyzeKey key=AKNull;
	if (argc==1) error("引数が不足しています");
	else if (eq(argv[1],"-h","help","-help","--help",NULL)) help();
	else if (eq(argv[1],"-v","version","-version","--version",NULL)) version();
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
		if (eq(a,"-m","-multiple",NULL)) d->multiple=true;
		else if (eq(a,"-o","-out","-stdout",NULL)) key=AKStdout;
		else if (eq(a,"-e","-err","-stderr",NULL)) key=AKStderr;
		else if (eq(a,"-r","-result",NULL)) key=AKResult;
		else { body=n; break; }
	}
	if (body==0) error("実行する内容が指定されていません");
	for (int n=body;n<argc;n++) argv[n-body]=argv[n];
	argv[argc-body]=NULL;
	d->count=argc-body;
}