#include "lib.hpp"

enum AnalyzeKey { AKNull,AKStdout,AKStderr,AKResult,AKMultiple };

void argAnalyze(Data *d,VS l) {
	if (eq(l[0],"-h","help","-help","--help")) {
		d->mode=CMHelp; return;
	}
	else if (eq(l[0],"-v","version","-version","--version")) {
		d->mode=CMVersion; return;
	}

	AnalyzeKey key=AKNull;
	int n=-1;
	for (string a:l) {
		n++;
		if (a.empty()) continue;

		bool proceed=true;
		if (eq(a,"-m","-match")) {
			d->multiple=MMSerial;
			key=AKMultiple;
		}
		else if (eq(a,"-o","-out","-stdout")) key=AKStdout;
		else if (eq(a,"-e","-err","-stderr")) key=AKStderr;
		else if (eq(a,"-r","-result")) key=AKResult;
		else proceed=false;
		if (proceed) continue;

		if (a.starts_with("-")) error("不正なオプションが指定されています");
		else if (key!=AKNull) {
			proceed=true;
			switch (key) {
				case AKStdout: d->out=a; break;
				case AKStderr: d->err=a; break;
				case AKResult: d->result=a; break;
				case AKMultiple:
					if (eq(a,"none")) d->multiple=MMNone;
					else if (eq(a,"serial","")) d->multiple=MMSerial;
					else if (eq(a,"spawn","parallel")) d->multiple=MMSpawn;
					else if (eq(a,"thread")) d->multiple=MMThread;
					else proceed=false;
				case AKNull: break;
			}
			key=AKNull;
		}
		if (proceed) continue;

		VS cmd(l.begin()+n,l.end());
		d->command=cmd;
		break;
	}

	if (d->command.size()==0) error("実行する内容が指定されていません");
}