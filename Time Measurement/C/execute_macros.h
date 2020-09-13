#define SHELL(var,cmd) \
	var={getenv("SHELL"),"-c",cmd,NULL}; \
	if (var[0]==NULL) var[0]="sh";

#define SHIFT() \
	char** shifted=(d->commands)-1; \
	for (int n=0;n<d->count;n++) shifted[n]=d->commands[n]; \
	shifted[d->count]=NULL; \
	d->commands=shifted;

// | measure | arg0 | arg1 | … | argN-1 | argN |
// -> | arg0 | arg1 | … | argN | NULL |

#define ERR(func) \
	if (func!=0) {\
		err=1;\
		fprintf(stderr,"%dつ目の実行内容を並列実行するのに失敗しました。\n",n+1);\
	}

#define PARALLEL_SETUP() \
	TIMETYPE st,en; \
	D *d=x->d; \
	int err=0; \
	char t[20]; \
	\
	char *sh=getenv("SHELL"); \
	if (sh==NULL) sh="sh"; \
	char *c="-c"; \
	\
	SP pl[d->count]; \
	for (int n=0;n<d->count;n++) { \
		char **a=(char**)malloc(4*sizeof *a); \
		pl[n]=sp(d,a); \
		a[0]=sh; \
		a[1]=c; \
		a[2]=d->commands[n]; \
		a[3]=NULL; \
	}

#define PARALLEL_REPORT() \
	if (!err) { \
		descTime(x->r,st,en); \
		for (int n=0;n<d->count;n++) { \
			if ((pl[n].pid<0)||pl[n].error) sprintf(t,"process%d id: N/A\n",n+1); \
			else sprintf(t,"process%d id: %d\n",n+1,pl[n].pid); \
			write(x->r,t,strlen(t)); \
			descEC(x,&pl[n]); \
			if (pl[n].ec>x->ec) x->ec=pl[n].ec; \
		} \
	}