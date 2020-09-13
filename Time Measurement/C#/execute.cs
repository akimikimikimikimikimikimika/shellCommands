using System;
using System.Diagnostics; // Process
using System.IO; // TextWriter
using System.Text.RegularExpressions; // RegEx
using System.Threading.Tasks; // Parallel

using Opened = System.Collections.Generic.Dictionary<string,System.IO.StreamWriter>;
using Data = lib.Data;
using MM = lib.MM;

public static class execute {

	static Data d;
	static int ec=0;
	static TextWriter r;

	static string res="";

	static string eol = Environment.NewLine;

	public static void exec(ref Data d) {
		execute.d=d;
		ro2f();

		switch (d.multiple) {
			case MM.none:   single(); break;
			case MM.serial: serial(); break;
			case MM.spawn:  spawn();  break;
			case MM.thread: thread(); break;
		}

		r.Write(res);
		r.Close();
		Environment.Exit(ec==-1?1:ec);
	}

	private static void single() {
		var p=new SP(d.command);

		var st=DateTime.Now;
		p.run();
		var en=DateTime.Now;

		res=lib.clean($@"
			time: {descTime(en-st)}
			process id: {p.pid}
			exit code: {p.ec}
		");
		ec=p.ec;
	}

	private static void serial() {
		var pl=SP.multiple(d.command);
		var lp=pl[pl.Length-1];

		var st=DateTime.Now;
		foreach (var p in pl) {
			p.run();
			if (p.ec!=0) {
				lp=p;
				break;
			}
		}
		var en=DateTime.Now;

		res=$"time: {descTime(en-st)}"+eol;
		foreach (var p in pl) res+=$"process{p.order} id: {(p.pid<0?"N/A":p.pid.ToString())}"+eol;
		res+=$"exit code: {lp.ec}"+eol;
		ec=lp.ec;
	}

	private static void spawn() {
		var pl=SP.multiple(d.command);

		var st=DateTime.Now;
		foreach (var p in pl) p.start();
		foreach (var p in pl) p.wait();
		var en=DateTime.Now;

		res=$"time: {descTime(en-st)}"+eol;
		foreach (var p in pl) {
			res+=$"process{p.order} id: {p.pid}"+eol;
			res+=$"exit code: {p.ec}"+eol;
			if (p.ec>ec) ec=p.ec;
		}
	}

	private static void thread() {
		var pl=SP.multiple(d.command);

		var st=DateTime.Now;
		Parallel.ForEach(pl,p=>{ p.run(); });
		var en=DateTime.Now;

		res=$"time: {descTime(en-st)}"+eol;
		foreach (var p in pl) {
			res+=$"process{p.order} id: {p.pid}"+eol;
			res+=$"exit code: {p.ec}"+eol;
			if (p.ec>ec) ec=p.ec;
		}
	}

	private class SP {
		private Process p;
		public int order=0;
		public int pid=-1;
		public int ec=0;

		public SP(string[] args) {
			this.p=new Process();
			var si=p.StartInfo;
			si.UseShellExecute=false;
			si.CreateNoWindow=true;
			si.RedirectStandardOutput=d.stdout!="inherit";
			si.RedirectStandardError =d.stderr!="inherit";
			si.FileName=args[0];
			si.Arguments="";
			int n=-1;
			foreach (var ar in args) {
				n++;
				if (n==0) continue;
				var a=ar;
				a=dq.Replace(a,@"\""");
				a=bs.Replace(a,@"\\");
				if (n>1) si.Arguments+=" ";
				si.Arguments+=$@"""{a}""";
			}
		}
		public static SP[] multiple(string[] commands) {
			var sh=Environment.GetEnvironmentVariable("SHELL")??"/bin/sh";
			var l=new SP[commands.Length];
			int n=1;
			foreach (var c in commands) {
				var p=new SP(new string[] {sh,"-c",c});
				p.order=n;
				l[n-1]=p;
				n++;
			}
			return l;
		}
		public void start() {
			try{
				p.Start();
				pid=p.Id;
			}catch{ lib.error("実行に失敗しました"); }
		}
		public void wait() {
			if ((d.stdout!="inherit")&&(d.stdout!="discard")) fh(d.stdout).Write(p.StandardOutput.ReadToEnd());
			if ((d.stderr!="inherit")&&(d.stderr!="discard")) fh(d.stderr).Write(p.StandardError.ReadToEnd());
			p.WaitForExit();
			ec=p.ExitCode;
		}
		public void run() {
			start();
			wait();
		}

	}



	private static void ro2f() {
		switch (d.result) {
			case "stdout": r=Console.Out;   break;
			case "stderr": r=Console.Error; break;
			default:       r=fh(d.result);  break;
		}
	}

	private static Opened opened = new Opened();
	private static StreamWriter fh(string path) {
		if (opened.ContainsKey(path)) return opened[path];
		try{
			var io=new StreamWriter(path,true);
			opened[path]=io;
			return io;
		}
		catch{ return lib.error($"指定したパスには書き込みできません: {path}") as StreamWriter; }
	}



	private static Regex bs=new Regex(@"\\");
	private static Regex dq=new Regex("\"");



	private static string descTime(TimeSpan diff) {
		var t="";
		if (diff.Hours>=1) t+=$"{diff.Hours}h ";
		if (diff.Minutes>=1) t+=$"{diff.Minutes}m ";
		if (diff.Seconds>=1) t+=$"{diff.Seconds}s ";
		t+=$"{diff.TotalMilliseconds%1000:000.000}ms";
		return t;
	}

}