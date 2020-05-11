#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "general.h"
#include "time-switch.h"

#define R 0
#define W 1

struct status {
	int pid;
	int ec;
};
struct status run(char*[],struct ChildOutput*,struct ChildOutput*);
void checkFile(const char*);
int fh(struct ResultOutput*);
void descTime(int,TIMETYPE,TIMETYPE);
void descEC(int,int);

void execute(struct data *d,char** command) {
	TIMETYPE st,en;
	struct status s;

	if (d->result.type==ROFile) checkFile(d->result.file);

	char t[50];
	int ec;
	if (d->multiple) {
		int pl[d->count];
		char *args[4];
		char* sh=getenv("SHELL");
		args[0]=sh==NULL ? "sh" : sh;
		args[1]="-c";
		args[3]=NULL;

		GETTIME(st);
		for (int n=0;n<d->count;n++) {
			args[2]=command[n];
			s=run(args,&d->out,&d->err);
			ec=s.ec;
			pl[n]=s.pid;
			if (ec!=0) break;
		}
		GETTIME(en);

		if (ec!=255) {
			int r=fh(&d->result);
			descTime(r,st,en);
			for (int n=0;n<d->count;n++) {
				char t[20];
				sprintf(t,"process%d id: %d\n",n+1,pl[n]);
				write(r,t,strlen(t));
			}
			descEC(r,ec);
			close(r);
		}
	}
	else {
		GETTIME(st);
		s=run(command,&d->out,&d->err);
		GETTIME(en);

		ec=s.ec;
		if (ec!=255) {
			int r=fh(&d->result);
			descTime(r,st,en);
			char t[20];
			sprintf(t,"process id: %d\n",s.pid);
			write(r,t,strlen(t));
			descEC(r,ec);
			close(r);
		}
	}

	exit(ec==255?1:ec);
}

void connect(struct ChildOutput* co,int sfd) {
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
struct status run(char *args[],struct ChildOutput *out,struct ChildOutput *err) {
	struct status s;
	int sv;
	s.pid=fork();
	if (s.pid<0) error("プロセスの起動に失敗しました");
	if (s.pid==0) {
		connect(out,STDOUT_FILENO);
		connect(err,STDERR_FILENO);
		if (execvp(args[0],args)<0) {
			fputs("プロセスの実行に失敗しました\n",stderr);
			exit(255);
		}
	}
	waitpid(s.pid,&sv,0);
	if (WIFEXITED(sv)) s.ec=WEXITSTATUS(sv);
	else s.ec=-1;
	return s;
}

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

int fh(struct ResultOutput *r) {
		switch (r->type) {
		case ROStdout: return STDOUT_FILENO;
		case ROStderr: return STDERR_FILENO;
		case ROFile: return open(r->file,O_WRONLY|O_APPEND);
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
	DESC(fd,"%.3lfms\n",nsec/1e+6);
}
void descEC(int fd,int ec) {
	char t[24];
	if (ec<0) strcpy(t,"terminated due to signal");
	else sprintf(t,"exit code: %d",ec);
	write(fd,t,strlen(t));
	write(fd,"\n",1);
}