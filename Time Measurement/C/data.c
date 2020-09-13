#include <string.h>
#include <stdlib.h>
#include "general.h"

D initData() {
	D d;
	d.mode = CMMain;
	d.out.type = COInherit;
	d.out.file=NULL;
	d.err.type = COInherit;
	d.err.file=NULL;
	d.result.type = ROStderr;
	d.result.file=NULL;
	d.multiple = MMNone;
	d.count = 0;
	d.commands = NULL;
	return d;
}

CO s2co(const char* v) {
	CO co;
	co.file = NULL;
	if (!strcmp(v,"inherit")) co.type=COInherit;
	else if (!strcmp(v,"discard")) {
		co.type=CODiscard;
		co.file=NULL;
	}
	else {
		co.type=COFile;
		co.file=v;
	}
	return co;
}

RO s2ro(const char* v) {
	RO ro;
	ro.file = NULL;
	if (!strcmp(v,"stdout")) ro.type=ROStdout;
	else if (!strcmp(v,"stderr")) ro.type=ROStderr;
	else {
		ro.type=ROFile;
		ro.file=v;
	}
	return ro;
}