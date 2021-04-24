#include <fstream>
#include <sstream>
#include <iomanip>
#include <chrono>
#include <cstdlib>
#include <thread>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "lib.hpp"

using namespace chrono;
typedef chrono::high_resolution_clock HRC;
typedef HRC::time_point TP;
typedef stringstream SS;

class execute {

	public:

	static void main(Data *rd) {
		d=rd;
		if (!eq(d->result,"stdout","stderr")) fh().close();
		int ec;

		switch (d->multiple) {
			case MMNone:   ec=single();        break;
			case MMSerial: ec=serial();        break;
			case MMSpawn:  ec=spawn();         break;
			case MMThread: ec=threadProcess(); break;
		}

		if (ec!=255) {
			if (d->result=="stdout") cout << res.str();
			else if (d->result=="stderr") cerr << res.str();
			else {
				auto r=fh();
				r << res.str();
				r.close();
			}
			exit(ec);
		}
		else exit(1);
	}

	private:

	static Data* d;
	static SS res;

	static int single() {
		sp p(d->command,join(d->command," "));

		TP st=HRC::now();
		p.run();
		TP en=HRC::now();

		res <<
		"time: " << descTime(en-st) << endl <<
		"process id: " << p.pid << endl <<
		p.descEC() << endl;

		return p.ec;
	}

	static int serial() {
		auto pl=sp::multiple(d->command);
		sp lp=pl.back();

		TP st=HRC::now();
		for (sp &p:pl) {
			p.run();
			if (p.ec!=0) {
				lp=p;
				break;
			}
		}
		TP en=HRC::now();

		res << "time: " << descTime(en-st) << endl;
		for (sp &p:pl) {
			res << "process" << p.order << " id: ";
			if (p.pid<0) res << "N/A";
			else res << p.pid;
			res << endl;
		}
		res << lp.descEC() << endl;

		return lp.ec;
	}

	static int spawn() {
		auto pl=sp::multiple(d->command);

		TP st=HRC::now();
		for (sp &p:pl) p.start();
		for (sp &p:pl) p.wait();
		TP en=HRC::now();

		return sp::collect(pl,st,en);
	}

	static int threadProcess() {
		auto pl=sp::multiple(d->command);
		vector<thread> tl;
		tl.reserve(pl.size());
		auto tf=[](sp &p){
			p.run();
		};

		TP st=HRC::now();
		for (sp &p:pl) tl.emplace_back(thread(tf,ref(p)));
		for (thread &t:tl) t.join();
		TP en=HRC::now();

		return sp::collect(pl,st,en);
	}

	class sp {

		private:
		char** args;
		S description;

		public:
		int order=0;
		int pid=-1;
		int ec=0;

		public:
		sp(VS args,S desc) {
			this->args=vs2ca(args);
			this->description=desc;
		}
		static vector<sp> multiple(VS commands) {
			char* shc=getenv("SHELL");
			S sh=shc!=nullptr ? shc : "sh";
			vector<sp> l;
			l.reserve(commands.size());
			int n=1;
			for (S c:commands) {
				VS a={sh,"-c",c};
				sp p(a,c);
				p.order=n;
				n++;
				l.push_back(p);
			}
			return l;
		}
		static int collect(vector<sp> pl,TP st,TP en) {
			int ec=0;
			res << "time: " << descTime(en-st) << endl;
			for (sp &p:pl) {
				res <<
				"process" << p.order << " id: " << p.pid << endl <<
				p.descEC() << endl;
				if (p.ec>ec) ec=p.ec;
			}
			return ec;
		}

		void start() {
			int pid=fork();
			if (pid<0) error("プロセスの起動に失敗しました");
			if (pid==0) {
				connect(d->out,STDOUT_FILENO);
				connect(d->err,STDERR_FILENO);
				if (execvp(args[0],args)<0) {
					cerr << "実行に失敗しました: " << this->description << endl;
					exit(255);
				}
			}
			this->pid=pid;
		}
		void wait() {
			int sv;
			waitpid(this->pid,&sv,0);
			if (WIFEXITED(sv)) this->ec=WEXITSTATUS(sv);
			else this->ec=-1;
			clear(this->args);
		}
		void run() {
			this->start();
			this->wait();
		}
		string descEC() {
			if (ec<0) return "terminated due to signal";
			else return "exit code: "+to_string(ec);
		}

		private:
		void connect(string co,int sfd) {
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

	};

	static ofstream fh() {
		ofstream o;
		o.open(d->result,ios_base::out|ios_base::ate);
		if (!o) error("指定したパスには書き込みできません: "+d->result);
		return o;
	}

	static string descTime(nanoseconds dur) {
		SS ss;
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

};

Data *execute::d = nullptr;
stringstream execute::res;

void exec(Data *d) {
	execute::main(d);
}