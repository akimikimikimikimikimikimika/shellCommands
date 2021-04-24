#include <stdio.h>
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
		case MMSpawn:   spawn(&x); break;
	}

	exit(x.ec<0?1:x.ec);
}

void single(X *x) {
	single_setup();

	GETTIME(st);
	runSP(&p);
	GETTIME(en);

	single_report();
}

void serial(X *x) {
	serial_setup();

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

	serial_report();
}

void spawn(X *x) {
	parallel_setup();

	GETTIME(st);
	for (int n=0;n<d->count;n++) startSP(&pl[n]);
	for (int n=0;n<d->count;n++) waitSP(&pl[n]);
	GETTIME(en);

	parallel_report();
}

void threadFunc(void*);
void thread(X *x) {
	parallel_setup();
	void *f=(void*)threadFunc;
	pthread_t tl[d->count];

	GETTIME(st);
	for (int n=0;n<d->count;n++) ERR(pthread_create(&tl[n],NULL,f,(void*)&pl[n]));
	for (int n=0;n<d->count;n++) ERR(pthread_join(tl[n],NULL));
	GETTIME(en);

	parallel_report();
}

void threadFunc(void *pt) {
	SP *p=(SP*)pt;
	runSP(p);
}