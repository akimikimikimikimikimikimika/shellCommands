#include <string.h>
#include <stdlib.h>
#include "general.h"

struct data initData() {
	struct data d;
	d.out.type = COInherit;
	d.out.file=NULL;
	d.err.type = COInherit;
	d.err.file=NULL;
	d.result.type = ROStderr;
	d.result.file=NULL;
	d.multiple = false;
	d.count = 0;
	return d;
}

struct ChildOutput s2co(const char* v) {
	struct ChildOutput co;
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

struct ResultOutput s2ro(const char* v) {
	struct ResultOutput ro;
	ro.file = NULL;
	if (!strcmp(v,"stdout")) ro.type=ROStdout;
	else if (!strcmp(v,"stderr")) ro.type=ROStderr;
	else {
		ro.type=ROFile;
		ro.file=v;
	}
	return ro;
}