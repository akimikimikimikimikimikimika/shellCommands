#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <memory>
#include <string>
#include <deque>
#include <chrono>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

using namespace std;
using namespace chrono;

deque<string> command;
string out="inherit";
string err="inherit";
string result="stderr";
bool multiple=false;

// declaration
void argAnalyze(deque<string>);
class execute {
	public: execute();
	private:
		int ec=0;
		int run(deque<string>);
		void connect(string,int);
		ofstream fh();
		string descTime(nanoseconds dur);
		string descEC();
};
void help();
void version();
void error(string text);

// utilities
deque<string> ca2vs(char*[],int);
char** vs2ca(deque<string>);
bool eq(string target,string s1) { return target==s1; };
template<typename... Sn>
bool eq(string target, string s1, Sn ...sn) { return eq(target,s1)||eq(target,sn...); };






int main(int argc,char *argv[]) {
	argAnalyze(ca2vs(argv,argc));
	execute();
	return 0;
}

enum AnalyzeKey { AKNull,AKStdout,AKStderr,AKResult };
void argAnalyze(deque<string> l) {
	l.pop_front();
	if (l.size()==0) error("引数が不足しています");
	else if (eq(l[0],"-h","help","-help","--help")) help();
	else if (eq(l[0],"-v","version","-version","--version")) version();
	bool noFlags=false;
	AnalyzeKey key=AKNull;
	for (string a:l) {
		if (noFlags) { command.push_back(a); continue; }
		if (key!=AKNull) {
			switch (key) {
				case AKStdout: out=a; break;
				case AKStderr: err=a; break;
				case AKResult: result=a; break;
				case AKNull: break;
			}
			key=AKNull;
			continue;
		}
		if (eq(a,"-m","-match")) multiple=true;
		else if (eq(a,"-o","-out","-stdout")) key=AKStdout;
		else if (eq(a,"-e","-err","-stderr")) key=AKStderr;
		else if (eq(a,"-r","-result")) key=AKResult;
		else { noFlags=true; command.push_back(a); }
	}
	if (command.size()==0) error("実行する内容が指定されていません");
}

typedef chrono::high_resolution_clock HRC;
execute::execute() {
	if (!eq(result,"stdout","stderr")) fh().close();
	stringstream res;
	if (multiple) {
		deque<int> pl;
		deque<string> args={"sh","-c",""};
		HRC::time_point st=HRC::now();
		for (string c:command) {
			args[2]=c;
			pl.push_back(run(args));
			if (ec!=0) break;
		}
		HRC::time_point en=HRC::now();
		res << "time: " << descTime(en-st) << endl;
		for (int n=0;n<pl.size();n++) res << "process" << n+1 << " id: " << pl[n] << endl;
		res << descEC() << endl;
	}
	else {
		HRC::time_point st=HRC::now();
		int pid=run(command);
		HRC::time_point en=HRC::now();
		res <<
		"time: " << descTime(en-st) << endl <<
		"process id: " << pid << endl <<
		descEC() << endl;
	}
	if (result=="stdout") cout << res.str();
	else if (result=="stderr") cerr << res.str();
	else {
		auto r=fh();
		r << res.str();
		r.close();
	}
	exit((ec+256)%256);
}
int execute::run(deque<string> args) {
	int sv;
	int pid=fork();
	if (pid<0) error("プロセスの起動に失敗しました");
	if (pid==0) {
		connect(out,STDOUT_FILENO);
		connect(err,STDERR_FILENO);
		if (execvp(args[0].c_str(),vs2ca(args))<0) {
			cerr << "プロセスの実行に失敗しました" << endl;
			exit(127);
		}
	}
	waitpid(pid,&sv,0);
	if (WIFEXITED(sv)) ec=WEXITSTATUS(sv);
	else ec=-1;
	return pid;
}
void execute::connect(string co,int sfd) {
	int fd;
	if (co=="inherit") return;
	if (co=="discard") {
		fd=open("/dev/null",O_WRONLY);
		if (fd<0) error("出力を破棄することができません");
		return;
	}
	else {
		fd=open(co.c_str(),O_WRONLY|O_APPEND|O_CREAT);
		if (fd<0) error("指定したパスには書き込みできません: "+co);
	}
	dup2(fd,sfd);
	close(fd);
}
ofstream execute::fh() {
	ofstream o;
	o.open(result,ios_base::out|ios_base::ate);
	if (!o) error("指定したパスには書き込みできません: "+result);
	return o;
}
string execute::descTime(nanoseconds dur) {
	stringstream ss;
	auto h=duration_cast<hours>(dur).count();
	auto m=duration_cast<minutes>(dur).count();
	auto s=duration_cast<seconds>(dur).count();
	auto ns=duration_cast<nanoseconds>(dur).count();
	ns-=s*1e+9,s-=m*60,m-=h*60;
	if (h>=1) ss << h << "h ";
	if (m>=1) ss << m << "m ";
	if (s>=1) ss << s << "s ";
	ss << fixed << setprecision(3) << (double)ns/1e+6 << "ms";
	return ss.str();
}
string execute::descEC() {
	if (ec<0) return "terminated due to signal";
	else return "exit code: "+to_string(ec);
}

void error(string text) {
	cerr << text << endl;
	exit(1);
}

void output(deque<string>);
void help() {
	output({
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
		""
	});
	exit(0);
}
void version() {
	output({
		"",
		" measure v2.0",
		" C++ バージョン (measure-cpp)",
		""
	});
	exit(0);
}
void output(deque<string> d) {
	for (int n=0;n<d.size();n++) {
		if (n) cout << endl;
		cout << d[n];
	}
}



// utilities implementation
deque<string> ca2vs(char *charArray[],int arrayLength) {
	deque<string> v(arrayLength);
	for (int n=0;n<arrayLength;n++) v[n]=string(charArray[n]);
	return v;
}
char** vs2ca(deque<string> v) {
	auto cpa=allocator<char*>();
	auto ca=allocator<char>();
	char** a=cpa.allocate(v.size()+1);
	int n=0;
	for (string s:v) {
		char *t=ca.allocate(s.size()+1);
		for (int m=0;m<s.size();m++) t[m]=s[m];
		t[s.size()]='\0';
		a[n]=t;
		n++;
	}
	a[v.size()]=nullptr;
	return a;
}