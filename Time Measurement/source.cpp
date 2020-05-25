#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <string>
#include <cstring>
#include <vector>
#include <chrono>
#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

using namespace std;
using namespace chrono;

typedef vector<string> VS;

VS command;
string out="inherit";
string err="inherit";
string result="stderr";
bool multiple=false;

// declaration
void argAnalyze(vector<string>);
class execute {
	public: execute();
	private:
		int ec=0;
		char** shell();
		int run(char**);
		void connect(string,int);
		ofstream fh();
		string descTime(nanoseconds dur);
		string descEC();
};
void help();
void version();
void error(string text);

// easy equality check
bool eq(string target,string s1) { return target==s1; };
template<typename... Sn>
bool eq(string target, string s1, Sn ...sn) { return eq(target,s1)||eq(target,sn...); };

// convert array with memory management
char** vs2ca(VS);
void clear(char**);






int main(int argc,char *argv[]) {
	if (argc==1) error("引数が不足しています");
	VS args(argv+1,argv+argc);
	argAnalyze(args);
	execute();
	return 0;
}

enum AnalyzeKey { AKNull,AKStdout,AKStderr,AKResult };
void argAnalyze(VS l) {
	if (eq(l[0],"-h","help","-help","--help")) help();
	else if (eq(l[0],"-v","version","-version","--version")) version();
	AnalyzeKey key=AKNull;
	int n=0;
	for (string a:l) {
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
		else {
			VS cmd(l.begin()+n,l.end());
			command=cmd;
			break;
		}
		n++;
	}
	if (command.size()==0) error("実行する内容が指定されていません");
}

typedef chrono::high_resolution_clock HRC;
typedef HRC::time_point TP;
execute::execute() {
	stringstream res;
	TP st;TP en;
	if (!eq(result,"stdout","stderr")) fh().close();

	if (multiple) {
		int l=command.size();
		vector<int> pl(l,-1);
		char** cmd=vs2ca(command);
		char** args=shell();
		int n;
		st=HRC::now();
		for (n=0;cmd[n]!=nullptr;n++) {
			args[2]=cmd[n];
			pl[n]=run(args);
			if (ec!=0) break;
		}
		en=HRC::now();
		args[2]=nullptr;
		clear(args);
		res << "time: " << descTime(en-st) << endl;
		n=1;
		for (int pid:pl) {
			res << "process" << n << " id: ";
			if (pid<0) res << "N/A";
			else res << pid;
			res << endl;
			n++;
		}
		res << descEC() << endl;
	}
	else {
		char** args=vs2ca(command);
		st=HRC::now();
		int pid=run(args);
		en=HRC::now();
		clear(args);
		res <<
		"time: " << descTime(en-st) << endl <<
		"process id: " << pid << endl <<
		descEC() << endl;
	}

	if (ec!=255) {
		if (result=="stdout") cout << res.str();
		else if (result=="stderr") cerr << res.str();
		else {
			auto r=fh();
			r << res.str();
			r.close();
		}
		exit(ec);
	}
	else exit(1);
}
char** execute::shell() {
	VS args={"sh","-c",""};
	char* sh=getenv("SHELL");
	if (sh!=nullptr) args[0]=sh;
	return vs2ca(args);
}
int execute::run(char** args) {
	int sv;
	int pid=fork();
	if (pid<0) error("プロセスの起動に失敗しました");
	if (pid==0) {
		connect(out,STDOUT_FILENO);
		connect(err,STDERR_FILENO);
		if (execvp(args[0],args)<0) {
			cerr << "プロセスの実行に失敗しました" << endl;
			exit(255);
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
	ss.fill('0');
	ss << fixed << setw(7) << setprecision(3) << (double)ns/1e+6 << "ms";
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

void output(VS);
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
		" measure v2.2",
		" C++ バージョン (measure-cpp)",
		""
	});
	exit(0);
}
void output(VS d) {
	for (string l:d) cout << l << endl;
}



// convert array with memory management
char** vs2ca(VS vs) {
	int s=vs.size();
	auto ca=new char*[s+1];
	int n=0;
	for (string s:vs) {
		auto c=new char[s.size()+1];
		auto cc=s.c_str();
		strcpy(c,cc);
		ca[n]=c;
		n++;
	}
	ca[s]=nullptr;
	return ca;
}
void clear(char** p) {
	int n=0;
	while (p[n]!=nullptr) {
		delete[] p[n];
		n++;
	}
	delete[] p;
}