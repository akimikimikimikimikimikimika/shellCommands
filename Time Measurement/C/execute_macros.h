
#define ERR(func)                                                        \
	if (func!=0) {                                                       \
		err=1;                                                           \
		fprintf(stderr,"%dつ目の実行内容を並列実行するのに失敗しました。\n",n+1); \
	}                                                                    \


// | measure | arg0 | arg1 | … | argN-1 | argN |
// -> | arg0 | arg1 | … | argN | NULL |
#define SHIFT()                                             \
	char** shifted=(d->commands)-1;                         \
	for (int n=0;n<d->count;n++) shifted[n]=d->commands[n]; \
	shifted[d->count]=NULL;                                 \

#define DESC_COPY()                                      \
	size_t ds=d->count;                                  \
	for (int n=0;n<d->count;n++) ds+=strlen(shifted[n]); \
	char desc[ds]; desc[0]='\0';                         \
	char* space=" ";                                     \
	for (int n=0;n<d->count;n++) {                       \
		if (n) strcat(desc,space);                       \
		strcat(desc,shifted[n]);                         \
	}                                                    \

#define single_setup()       \
	TIMETYPE st,en;          \
	char t[20];              \
	D *d=x->d;               \
	SHIFT();                 \
	DESC_COPY();             \
	SP p=sp(d,shifted,desc); \

#define single_report()                      \
	if (!p.error) {                          \
		descTime(x->r,st,en);                \
		sprintf(t,"process id: %d\n",p.pid); \
		write(x->r,t,strlen(t));             \
		descEC(x,&p);                        \
		x->ec=p.ec;                          \
	}                                        \



#define serial_setup()                                            \
	TIMETYPE st,en;                                               \
	char t[20];                                                   \
	D *d=x->d;                                                    \
	                                                              \
	char *args[]={getenv("SHELL"),"-c",NULL,NULL};                \
	if (args[0]==NULL) args[0]="sh";                              \
	SP pl[d->count];                                              \
	for (int n=0;n<d->count;n++) pl[n]=sp(d,args,d->commands[n]); \
	int ln=d->count-1;                                            \

#define serial_report()                                            \
	if (!pl[ln].error) {                                           \
		descTime(x->r,st,en);                                      \
		for (int n=0;n<d->count;n++) {                             \
			if (pl[n].pid<0) sprintf(t,"process%d id: N/A\n",n+1); \
			else sprintf(t,"process%d id: %d\n",n+1,pl[n].pid);    \
			write(x->r,t,strlen(t));                               \
		}                                                          \
		descEC(x,&pl[ln]);                                         \
		x->ec=pl[ln].ec;                                           \
	}                                                              \



#define parallel_setup()                       \
	TIMETYPE st,en;                            \
	D *d=x->d;                                 \
	int err=0;                                 \
	char t[20];                                \
	                                           \
	char *sh=getenv("SHELL");                  \
	if (sh==NULL) sh="sh";                     \
	char *c="-c";                              \
	                                           \
	SP pl[d->count];                           \
	char* args[d->count*4];                    \
	for (int n=0;n<d->count;n++) {             \
		args[n*4+0]=sh;                        \
		args[n*4+1]=c;                         \
		args[n*4+2]=d->commands[n];            \
		args[n*4+3]=NULL;                      \
		pl[n]=sp(d,&args[n*4],d->commands[n]); \
	}                                          \

#define parallel_report()                                                         \
	for (int n=0;n<d->count;n++) if (pl[n].error) {                               \
		err=1;                                                                    \
		break;                                                                    \
	}                                                                             \
	                                                                              \
	if (!err) {                                                                   \
		descTime(x->r,st,en);                                                     \
		for (int n=0;n<d->count;n++) {                                            \
			if ((pl[n].pid<0)||pl[n].error) sprintf(t,"process%d id: N/A\n",n+1); \
			else sprintf(t,"process%d id: %d\n",n+1,pl[n].pid);                   \
			write(x->r,t,strlen(t));                                              \
			descEC(x,&pl[n]);                                                     \
			if (pl[n].ec>x->ec) x->ec=pl[n].ec;                                   \
		}                                                                         \
	}                                                                             \
