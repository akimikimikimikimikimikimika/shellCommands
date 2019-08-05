#include <stdio.h>

void help() {
	printf("\n");
	printf("使い方: measure [command] [arg1] [arg2]...\n");
	printf("  [command] を実行し,最後にその所要時間を表示します\n");
	printf("  引数 [arg1] [arg2]... はそのまま [command] に渡されます\n");
	printf("\n");
}