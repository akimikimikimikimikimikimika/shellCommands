#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>

void output(const char*[]);
void error(const char*);

void help() {
	const char *text[]={
		"",
		" 使い方:",
		"  measure [options] [command] [arg1] [arg2]…",
		"  measure -multiple [options] \"[command1]\" \"[command2]\"…",
		"",
		"  [command] を実行し,最後にその所要時間を表示します",
		"",
		"  オプション",
		"",
		"   -o,-out,-stdout",
		"   -e,-err,-stderr",
		"    標準出力,標準エラー出力の出力先を指定します",
		"    指定しなければ inherit になります",
		"    • inherit",
		"     stdoutはstdoutに,stderrはstderrにそれぞれ出力します",
		"    • discard",
		"     出力しません",
		"    • [file path]",
		"     指定したファイルに書き出します (追記)",
		"",
		"   -r,-result",
		"    実行結果の出力先を指定します",
		"    指定しなければ stderr になります",
		"    • stdout,stderr",
		"    • [file path]",
		"     指定したファイルに書き出します (追記)",
		"",
		"   -m,-multiple",
		"    複数のコマンドを実行します",
		"    通常はシェル経由で実行されます",
		"    例えば measure echo 1 と指定していたのを",
		"",
		"     measure -multiple \"echo 1\" \"echo 2\"",
		"",
		"    などと1つ1つのコマンドを1つの文字列として渡して実行します",
		"",
		NULL
	};
	output(text);
	exit(0);
}

void version() {
	const char *text[]={
		"",
		" measure v2.0",
		" C バージョン (measure-c)",
		"",
		NULL
	};
	output(text);
	exit(0);
}

void output(const char* lines[]) {
	int n=0;
	while (lines[n]!=NULL) {
		printf("%s\n",lines[n]);
		n++;
	}
}

char* copyStr(char *str) {
	char *p=(char*)malloc(sizeof(char)*(strlen(str)+1));
	if (p==NULL) error("メモリ不足です");
	strcpy(p,str);
	return p;
}

bool eq(char *target,...) {
	va_list args;
	va_start(args,target);
	bool matched=false;
	while (true) {
		const char* str=va_arg(args,const char*);
		if (str==NULL) break;
		if (!strcmp(target,str)) {
			matched=true;
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