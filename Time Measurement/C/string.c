#include <string.h>

void parse(char*,const char*);
void clear(char*);

char* argparse(int argc,char* argv[]) {
	int n;
	long long int l=1;
	for (n=1;n<argc;n++) l+=strlen(argv[n])*5+3;
	char text[l];
	for (n=0;n<l;n++) text[n]='\0';
	for (n=1;n<argc;n++) {
		parse(text,argv[n]);
	}
	char *ret=text;
	return ret;
}

void parse(char *merging,const char *text) {
	int l=strlen(text);
	char newtext[l*5+3];
	int diff=1;
	int n=0;
	int nd;
	int m;
	long long int offset;
	newtext[0]='\'';
	for (n=0;n<=l;n++) {
		nd=n+diff;
		if (n==l) for (m=0;m<2;m++) newtext[nd+m]=m?'\0':'\'';
		else if (text[n]=='\'') {
			for (m=0;m<5;m++) newtext[nd+m]=(m%2)?'"':'\'';
			diff+=4;
		}
		else if (text[n]=='\\') {
			for (m=0;m<2;m++) newtext[nd+m]='\\';
			diff+=1;
		}
		else newtext[n+diff]=text[n];
	}
	offset=strlen(merging);
	if (offset) {
		merging[offset]=' ';
		offset++;
	}
	l=strlen(newtext);
	for (n=0;n<l;n++) merging[offset+n]=newtext[n];
	clear(newtext);
}

void copy(const char *from,char *to) {
	int l=strlen(from);
	int n;
	for (n=0;from[n]!='\0';n++) to[n]=from[n];
	to[n]='\0';
}

void clear(char *str) {
	int l=strlen(str);
	int n;
	for (n=0;n<l;n++) str[n]='\0';
}