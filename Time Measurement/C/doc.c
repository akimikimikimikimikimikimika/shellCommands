#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

void output(const char*,...);

void help() {
	output(
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
	);
	exit(0);
}

void version() {
	output(
		"",
		" measure v2.2",
		" C バージョン (measure-c)",
		"",
		NULL
	);
	exit(0);
}

void output(const char* lines,...) {
	va_list args;
	printf("%s\n",lines);
	va_start(args,lines);
	while (1) {
		const char* l=va_arg(args,const char*);
		if (l==NULL) break;
		printf("%s\n",l);
	}
	va_end(args);
}