#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "general.h"

#define R 0
#define W 1

#ifdef CLOCK_MONOTONIC_RAW
	#define CLOCKTYPE CLOCK_MONOTONIC_RAW
#else
	#define CLOCKTYPE CLOCK_MONOTONIC
#endif

struct status {
	int pid;
	int ec;
};
struct status run(char*[],struct ChildOutput*,struct ChildOutput*);
void checkFile(const char*);
int fh(struct ResultOutput*);
char* descTime(struct timespec*,struct timespec*);
char* descEC(int);

void execute(struct data *d) {
	struct timespec st,en;
	struct status s;

	if (d->result.type==ROFile) checkFile(d->result.file);

	char rl[50];
	int ec;
	if (d->multiple) {
		int pl[d->count];
		char *args[4];
		args[0]="sh";
		args[1]="-c";
		args[3]=NULL;

		clock_gettime(CLOCKTYPE,&st);
		for (int n=0;n<d->count;n++) {
			args[2]=d->command[n];
			s=run(args,&d->out,&d->err);
			ec=s.ec;
			pl[n]=s.pid;
			if (ec!=0) break;
		}
		clock_gettime(CLOCKTYPE,&en);

		int r=fh(&d->result);
		sprintf(rl,"time: %s\n",descTime(&st,&en));
		write(r,rl,strlen(rl));
		for (int n=0;n<d->count;n++) {
			char rl[50];
			sprintf(rl,"process%d id: %d\n",n+1,pl[n]);
			write(r,rl,strlen(rl));
		}
		sprintf(rl,"%s\n",descEC(ec));
		write(r,rl,strlen(rl));
		close(r);
	}
	else {
		clock_gettime(CLOCKTYPE,&st);
		s=run(d->command,&d->out,&d->err);
		clock_gettime(CLOCKTYPE,&en);

		ec=s.ec;
		int r=fh(&d->result);
		sprintf(rl,"time: %s\n",descTime(&st,&en));
		write(r,rl,strlen(rl));
		sprintf(rl,"process id: %d\n",s.pid);
		write(r,rl,strlen(rl));
		sprintf(rl,"%s\n",descEC(ec));
		write(r,rl,strlen(rl));
		close(r);
	}

	exit((ec+256)%256);
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
			exit(127);
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

char* descTime(struct timespec *st,struct timespec *en) {
	double sec=(double)(en->tv_sec-st->tv_sec);
	double nsec=(double)(en->tv_nsec-st->tv_nsec);
	if (nsec<0) { nsec+=1e+9; sec-=1; }
	double r,v;
	char t[50]; t[0]='\0';
	char tmp[20];
	r=sec/3600; v=floor(r);
	if (v>=1) { sprintf(tmp,"%.0lfh ",v); strcat(t,tmp); }
	r=(r-v)*60; v=floor(r);
	if (v>=1) { sprintf(tmp,"%.0lfm ",v); strcat(t,tmp); }
	r=(r-v)*60; v=floor(r);
	if (v>=1) { sprintf(tmp,"%.0lfs ",v); strcat(t,tmp); }
	sprintf(tmp,"%.3lfms",nsec/1e+6); strcat(t,tmp);
	return copyStr(t);
}
char* descEC(int ec) {
	if (ec<0) return copyStr("terminated due to signal");
	else {
		char t[15];
		sprintf(t,"exit code: %d",ec);
		return copyStr(t);
	}
}