#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "execute.h"

SP sp(D *d,char** args) {
	SP p;
	p.out=&d->out;
	p.err=&d->err;
	p.args=args;
	p.pid=-1;
	p.ec=0;
	p.error=0;
	return p;
}

void connect(CO* co,int sfd) {
	int fd;
	switch (co->type) {
		case COInherit: return;
		case CODiscard:
			fd=open("/dev/null",O_WRONLY);
			if (fd<0) error("出力を破棄することができません");
			break;
		case COFile:
			fd=open(co->file,O_WRONLY|O_APPEND|O_CREAT);
			if (fd<0) {
				char m[60+strlen(co->file)];
				sprintf(m,"指定したパスには書き込みできません: %s",co->file);
				error(m);
			}
			break;
	}
	dup2(fd,sfd);
	close(fd);
}
void startSP(SP *p) {
	p->pid=fork();
	if (p->pid<0) {
		fputs("プロセスの起動に失敗しました\n",stderr);
		p->pid=255;
	}
	if (p->pid==0) {
		connect(p->out,STDOUT_FILENO);
		connect(p->err,STDERR_FILENO);
		if (execvp(p->args[0],p->args)<0) {
			fputs("プロセスの実行に失敗しました\n",stderr);
			exit(255);
		}
	}
}

void waitSP(SP* p) {
	int sv;
	waitpid(p->pid,&sv,0);
	if (WIFEXITED(sv)) p->ec=WEXITSTATUS(sv);
	else p->ec=-1;
	if (p->ec==255) {
		p->error=1;
		p->ec=1;
	}
}

void runSP(SP* p) {
	startSP(p);
	waitSP(p);
}

void descEC(X *x,SP *p) {
	char t[25];
	if (p->ec<0) strcpy(t,"terminated due to signal");
	else sprintf(t,"exit code: %d",p->ec);
	write(x->r,t,strlen(t));
	write(x->r,"\n",1);
}