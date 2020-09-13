#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include "execute.h"
#include "execute_macros.h"
#include "time_switch.h"

int fh(RO*);
void descTime(int,TIMETYPE,TIMETYPE);

void single(X*);
void serial(X*);
void spawn(X*);
void thread(X*);



void execute(D *d) {
	X x;
	x.d=d;
	x.ec=0;
	x.r=fh(&d->result);

	switch (d->multiple) {
		case MMNone:   single(&x); break;
		case MMSerial: serial(&x); break;
		case MMThread: thread(&x); break;
		case MMSpawn:  spawn(&x);  break;
	}

	exit(x.ec<0?1:x.ec);
}

void single(X *x) {
	TIMETYPE st,en;
	char t[20];
	D *d=x->d;
	SHIFT();
	SP p=sp(d,d->commands);

	GETTIME(st);
	runSP(&p);
	GETTIME(en);

	if (!p.error) {
		descTime(x->r,st,en);
		sprintf(t,"process id: %d\n",p.pid);
		write(x->r,t,strlen(t));
		descEC(x,&p);
		x->ec=p.ec;
	}
}

void serial(X *x) {
	TIMETYPE st,en;
	char t[20];
	D *d=x->d;

	char *args[]={getenv("SHELL"),"-c",NULL,NULL};
	if (args[0]==NULL) args[0]="sh";
	SP pl[d->count];
	for (int n=0;n<d->count;n++) pl[n]=sp(d,args);
	int ln=d->count-1;

	GETTIME(st);
	for (int n=0;n<d->count;n++) {
		args[2]=d->commands[n];
		runSP(&pl[n]);
		if (pl[n].ec!=0) {
			ln=n;
			break;
		}
	}
	GETTIME(en);

	if (!pl[ln].error) {
		descTime(x->r,st,en);
		for (int n=0;n<d->count;n++) {
			if (pl[n].pid<0) sprintf(t,"process%d id: N/A\n",n+1);
			else sprintf(t,"process%d id: %d\n",n+1,pl[n].pid);
			write(x->r,t,strlen(t));
		}
		descEC(x,&pl[ln]);
		x->ec=pl[ln].ec;
	}
}

void spawn(X *x) {
	PARALLEL_SETUP();

	GETTIME(st);
	for (int n=0;n<d->count;n++) startSP(&pl[n]);
	for (int n=0;n<d->count;n++) waitSP(&pl[n]);
	GETTIME(en);

	PARALLEL_REPORT();

}

void threadFunc(void*);
void thread(X *x) {
	PARALLEL_SETUP();
	void *f=(void*)threadFunc;
	pthread_t tl[d->count];

	GETTIME(st);
	for (int n=0;n<d->count;n++) ERR(pthread_create(&tl[n],NULL,f,(void*)&pl[n]));
	for (int n=0;n<d->count;n++) ERR(pthread_join(tl[n],NULL));
	GETTIME(en);

	for (int n=0;n<d->count;n++) {
		free(pl[n].args);
		if (pl[n].error) err=1;
	}

	PARALLEL_REPORT();
}

void threadFunc(void *pt) {
	SP *p=(SP*)pt;
	runSP(p);
}