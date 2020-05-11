#include "data.h"

void argAnalyze(struct data*,int,char*[]);
void execute(struct data*,char**);
void help();
void version();

int eq(char *target,...);
void error(const char*);