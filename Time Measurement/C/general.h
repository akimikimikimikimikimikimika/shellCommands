#include "data.h"

void argAnalyze(struct data*,int,char*[]);
void execute(struct data*);
void help();
void version();

char* copyStr(char*);
bool eq(char *target,...);
void error(const char*);