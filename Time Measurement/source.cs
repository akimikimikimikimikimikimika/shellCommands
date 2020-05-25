using System;
using System.IO;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Buffers;

public class Measure {

	private static string[] command=new string[0];
	private static string stdout="inherit";
	private static string stderr="inherit";
	private static string result="stderr";
	private static bool multiple=false;

	public static void Main (string[] args) {
		argAnalyze(args);
		new execute();
	}

	private static void argAnalyze(string[] l) {
		if (l.Length==0) error("引数が不足しています");
		else switch (l[0]) {
			case "-h": case "help": case "-help": case "--help": help(); break;
			case "-v": case "version": case "-version": case "--version": version(); break;
		}
		AnalyzeKey? key=null;
		int n=0;
		foreach (var a in l) {
			if (key!=null) {
				switch (key) {
					case AnalyzeKey.stdout: stdout=a; break;
					case AnalyzeKey.stderr: stderr=a; break;
					case AnalyzeKey.result: result=a; break;
				}
				key=null;
				continue;
			}
			var body=false;
			switch (a) {
				case "-o": case "-out": case "-stdout": key=AnalyzeKey.stdout; break;
				case "-e": case "-err": case "-stderr": key=AnalyzeKey.stderr; break;
				case "-r": case "-result": key=AnalyzeKey.result; break;
				case "-m": case "-multiple": multiple=true; break;
				default: body=true; break;
			}
			if (body) {
				command=new string[l.Length-n];
				Array.Copy(l,n,command,0,l.Length-n);
				break;
			}
			n++;
		}
		if (command.Length==0) error("実行する内容が指定されていません");
	}
	private enum AnalyzeKey { stdout,stderr,result };

	private class execute {

		public execute() {
			var r=ro2f();
			int ec=0;

			if (multiple) {
				var pcl=new Process[command.Length];
				var pl=new int[command.Length];
				Array.Fill(pl,-1);
				var a=new string[] {Environment.GetEnvironmentVariable("SHELL")??"sh","-c",""};
				int n=0;
				foreach (var c in command) {
					a[2]=c;
					pcl[n]=makeProcess(a);
					n++;
				}
				try{
					n=0;
					var st=DateTime.Now;
					foreach (var p in pcl) {
						p.Start();
						redirect(p);
						p.WaitForExit();
						pl[n]=p.Id;
						ec=p.ExitCode;
						if (ec!=0) break;
						n++;
					}
					var en=DateTime.Now;
					r.WriteLine($"time: {descTime(en-st)}");
					n=1;
					foreach (var pid in pl) {
						r.WriteLine($"process{n} id: {(pid<0?"N/A":pid.ToString())}");
						n++;
					}
					r.WriteLine($"exit code: {ec}");
				}catch{ error("実行に失敗しました"); }
			}
			else {
				var p=makeProcess(command);
				int pid;
				try{
					p.Start();
					var st=p.StartTime;
					redirect(p);
					p.WaitForExit();
					var en=p.ExitTime;
					pid=p.Id;
					ec=p.ExitCode;
					r.Write(clean($@"
						time: {descTime(en-st)}
						process id: {pid}
						exit code: {ec}
					"));
				}catch{ error("実行に失敗しました"); }
			}
			Environment.Exit((ec+256)%256);
		}

		private void redirect(Process p) {
			if ((stdout!="inherit")&&(stdout!="discard")) fh(stdout).Write(p.StandardOutput.ReadToEnd());
			if ((stderr!="inherit")&&(stderr!="discard")) fh(stderr).Write(p.StandardError.ReadToEnd());
		}

		private TextWriter ro2f() {
			switch (result) {
				case "stdout": return Console.Out;
				case "stderr": return Console.Error;
				default: return fh(result);
			}
		}

		private Dictionary<string,StreamWriter> opened = new Dictionary<string,StreamWriter>();
		private StreamWriter fh(string path) {
			if (opened.ContainsKey(path)) return opened[path];
			try{
				var io=new StreamWriter(path,true);
				opened[path]=io;
				return io;
			}
			catch{ return error($"指定したパスには書き込みできません: {path}") as StreamWriter; }
		}

		private Process makeProcess(string[] args) {
			var p=new Process();
			var si=p.StartInfo;
			si.UseShellExecute=false;
			si.CreateNoWindow=true;
			si.RedirectStandardOutput=stdout=="inherit";
			si.RedirectStandardError =stderr=="inherit";
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
			return p;
		}
		private Regex bs=new Regex(@"\\");
		private Regex dq=new Regex("\"");

		private string descTime(TimeSpan diff) {
			var t="";
			if (diff.Hours>=1) t+=$"{diff.Hours}h ";
			if (diff.Minutes>=1) t+=$"{diff.Minutes}m ";
			if (diff.Seconds>=1) t+=$"{diff.Seconds}s ";
			t+=$"{diff.TotalMilliseconds%1000:000.000}ms";
			return t;
		}

	}

	private static object error(string text) {
		Console.Error.WriteLine(text);
		Environment.Exit(1);
		return null;
	}

	private static void help() {
		Console.Write(clean(@"

			 使い方:
			  measure [options] [command] [arg1] [arg2]…
			  measure -multiple [options] ""[command1]"" ""[command2]""…

			  [command] を実行し,最後にその所要時間を表示します

			  オプション

			   -o,-out,-stdout
			   -e,-err,-stderr
			    標準出力,標準エラー出力の出力先を指定します
			    指定しなければ inherit になります
			    • inherit
			     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
			    • discard
			     出力しません
			    • [file path]
			     指定したファイルに書き出します (追記)

			   -r,-result
			    実行結果の出力先を指定します
			    指定しなければ stderr になります
			    • stdout,stderr
			    • [file path]
			     指定したファイルに書き出します (追記)

			   -m,-multiple
			    複数のコマンドを実行します
			    通常はシェル経由で実行されます
			    例えば measure echo 1 と指定していたのを

			     measure -multiple ""echo 1"" ""echo 2""

			    などと1つ1つのコマンドを1つの文字列として渡して実行します

		"));
		Environment.Exit(0);
	}

	private static void version() {
		Console.Write(clean(@"

			 measure v2.2
			 C# バージョン (measure-cs)

		"));
		Environment.Exit(0);
	}

	private static string clean(string text) {
		var t=text;
		t=new Regex(@"^\n").Replace(t,"");
		t=new Regex(@"\n$").Replace(t,"");
		t=new Regex(@"(?m)^\t+").Replace(t,"");
		return t;
	}

}