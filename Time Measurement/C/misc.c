#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

void error(const char*);

int eq(char *target,...) {
	va_list args;
	va_start(args,target);
	int matched=0;
	while (1) {
		const char* str=va_arg(args,const char*);
		if (str==NULL) break;
		if (!strcmp(target,str)) {
			matched=1;
			break;
		}
	}
	va_end(args);
	return matched;
}

void error(const char* text) {
	char t[strlen(text)+2];
	strcpy(t,text);
	strcat(t,"\r\n");
	fputs(t,stderr);
	exit(EXIT_FAILURE);
}