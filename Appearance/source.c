#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void help();
void helpText();
void lightOrDark(int);
void accentColor(char*);
void argError();



int cmp(char *s1,char *s2) {
	return strcmp(s1,s2)==0;
}

int main(int argc,char* argv[]) {
	if (argc==1) argError();
	else if (cmp(argv[1],"help")|cmp(argv[1],"-help")|cmp(argv[1],"--help")) help();
	else if (cmp(argv[1],"help-text")) helpText();
	else if (cmp(argv[1],"light")) lightOrDark(0);
	else if (cmp(argv[1],"dark")) lightOrDark(1);
	else if (cmp(argv[1],"blue")) accentColor("Blue");
	else if (cmp(argv[1],"purple")) accentColor("Purple");
	else if (cmp(argv[1],"pink")) accentColor("Pink");
	else if (cmp(argv[1],"red")) accentColor("Red");
	else if (cmp(argv[1],"orange")) accentColor("Orange");
	else if (cmp(argv[1],"yellow")) accentColor("Yellow");
	else if (cmp(argv[1],"green")) accentColor("Green");
	else if (cmp(argv[1],"graphite")) accentColor("Graphite");
	else argError();
	return 0;
}



void lightOrDark(int mode) {
	char cmd[120];
	sprintf(cmd,"osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to %s'",mode?"true":"false");
	system(cmd);
}

void accentColor(char *accent) {
	char cmd[450];
	sprintf(cmd,"echo '''\n\
		tell application \"System Preferences\"\n\
			reveal anchor \"Main\" of pane id \"com.apple.preference.general\"\n\
			activate\n\
		end tell\n\
		\n\
		tell application \"System Events\"\n\
			repeat until exists of checkbox \"Dark\" of window \"General\" of application process \"System Preferences\"\n\
				delay 0.1\n\
			end repeat\n\
			click checkbox \"%s\" of window \"General\" of application process \"System Preferences\"\n\
		end tell\n\
		''' | osascript > /dev/null\n\
	",accent);
	system(cmd);
}



void n() {
	printf("\n");
}

void argError() {
	printf("引数が不正です。");n();
	printf("詳しくはヘルプを参照してください");n();n();
	printf("  appearance help");n();n();
}

void help() {
	system("appearance help-text | less");
}

void helpText() {
	n();
	printf("使い方");n();n();
	printf("appearance [mode]");n();n();
	printf(" [mode] には次の値が指定できます");n();
	n();
	printf(" ライト/ダークモードの変更");n();
	printf("  • light");n();
	printf("  • dark");n();
	n();
	printf(" アクセントカラーの変更");n();
	printf("  • blue");n();
	printf("  • purple");n();
	printf("  • pink");n();
	printf("  • red");n();
	printf("  • orange");n();
	printf("  • yellow");n();
	printf("  • green");n();
	printf("  • graphite");n();
	n();
	printf(" ヘルプ");n();
	printf("  • help");n();
	printf("    このメニューを表示します");n();
	printf("  • help-text");n();
	printf("    ヘルプを通常テキストで表示します");n();
	n();n();
}