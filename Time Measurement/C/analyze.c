#include "general.h"
#include <string.h>

enum AnalyzeKey { AKNull,AKStdout,AKStderr,AKResult,AKMultiple };

void argAnalyze(D *d,int argc,char *argv[]) {
	int body=0;
	int proceed;
	enum AnalyzeKey key=AKNull;

	if (argc==1) error("引数が不足しています");

	else if (eq(argv[1],"-h","help","-help","--help",NULL)) {d->mode=CMHelp;return;}
	else if (eq(argv[1],"-v","version","-version","--version",NULL)) {d->mode=CMVersion;return;}

	for (int n=1;n<argc;n++) {
		char* a=argv[n];
		if (a[0]=='\0') continue;

		proceed=1;
		if (eq(a,"-m","-multiple",NULL)) {
			d->multiple=MMSerial;
			key=AKMultiple;
		}
		else if (eq(a,"-o","-out","-stdout",NULL)) { key=AKStdout; }
		else if (eq(a,"-e","-err","-stderr",NULL)) { key=AKStderr; }
		else if (eq(a,"-r","-result",NULL)) { key=AKResult; }
		else proceed=0;
		if (proceed) continue;

		if (a[0]=='-') error("不正なオプションが指定されています");
		else if (key!=AKNull) {
			proceed=1;
			switch (key) {
				case AKStdout: d->out=s2co(a); break;
				case AKStderr: d->err=s2co(a); break;
				case AKResult: d->result=s2ro(a); break;
				case AKMultiple:
					if (eq(a,"none",NULL)) d->multiple=MMNone;
					else if (eq(a,"serial","",NULL)) d->multiple=MMSerial;
					else if (eq(a,"spawn","fork","parallel",NULL)) d->multiple=MMSpawn;
					else if (eq(a,"thread",NULL)) d->multiple=MMThread;
					else proceed=0;
					break;
				case AKNull: break;
			}
			key=AKNull;
		}
		if (!proceed) {
			body=n;
			break;
		}
	}

	if (body==0) error("実行する内容が指定されていません");
	d->commands=argv+body;
	d->count=argc-body;
}