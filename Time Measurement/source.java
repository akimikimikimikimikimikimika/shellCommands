import java.util.*;
import java.io.*;
import java.nio.file.*;

public class Measure {

	private static String[] command=new String[0];
	private static String out="inherit";
	private static String err="inherit";
	private static String result="stderr";
	private static boolean multiple=false;

	public static void main(String[] args) {
		argAnalyze(args);
		new execute();
	}

	private static void argAnalyze(String[] l) {
		if (l.length==0) error("引数が不足しています");
		else switch (l[0]) {
			case "-h": case "help": case "-help": case "--help": help();
			case "-v": case "version": case "-version": case "--version": version();
		}
		AnalyzeKey key=null;
		int n=0;
		for (String a:l) {
			if (key!=null) {
				switch (key) {
					case stdout: out=a; break;
					case stderr: err=a; break;
					case result: result=a; break;
				}
				key=null;
				continue;
			}
			Boolean body=false;
			switch (a) {
				case "-o": case "-out": case "-stdout": key=AnalyzeKey.stdout; break;
				case "-e": case "-err": case "-stderr": key=AnalyzeKey.stderr; break;
				case "-r": case "-result": key=AnalyzeKey.result; break;
				case "-m": case "-multiple": multiple=true; break;
				default: body=true;
			}
			if (body) {
				command=Arrays.copyOfRange(l,n,l.length);
				break;
			}
			n++;
		}
		if (command.length==0) error("実行する内容が指定されていません");
	}
	private enum AnalyzeKey { stdout, stderr, result };

	private static class execute {

		private ProcessBuilder.Redirect i=ProcessBuilder.Redirect.INHERIT;
		private ProcessBuilder.Redirect o;
		private ProcessBuilder.Redirect e;

		execute() {
			showResult();
			o=redirect(out);
			e=redirect(err);
			String[] res;
			int ec=0;

			if (multiple) {
				int l=command.length;
				long[] pl=new long[l];
				Arrays.fill(pl,-1);
				ProcessBuilder[] pbl=new ProcessBuilder[l];
				int n=0;
				for (String c:command) {pbl[n]=makePB("sh","-c",c);n++;}

				long st=0;
				long en=0;
				try{
					n=0;
					st=System.nanoTime();
					for (ProcessBuilder pb:pbl) {
						Process p=pb.start();
						pl[n]=p.pid();
						ec=p.waitFor();
						if (ec!=0) break;
						n++;
					}
					en=System.nanoTime();
				}
				catch(IOException e) { error("実行に失敗しました"); }
				catch(InterruptedException e) { ec=-1; }

				res=new String[l+2];
				res[0]=String.format("time: %s",descTime(en-st));
				res[l+1]=descEC(ec);
				n=0;
				for (long pid:pl) {res[n+1]=String.format("process%d id: %s",n+1,pid<0?"N/A":pid);n++;}
			}
			else {
				ProcessBuilder pb=makePB(command);
				long pid=0;

				long st;
				long en;
				st=System.nanoTime();
				try{
					Process p=pb.start();
					pid=p.pid();
					ec=p.waitFor();
				}
				catch(IOException e) { error("実行に失敗しました"); }
				catch(InterruptedException e) { ec=-1; }
				en=System.nanoTime();

				res=new String[] {
					String.format("time: %s",descTime(en-st)),
					String.format("process id: %d",pid),
					descEC(ec)
				};
			}

			showResult(res);
			System.exit((ec+256)%256);
		}

		private ProcessBuilder.Redirect redirect(String co) {
			switch (co) {
				case "inherit": return ProcessBuilder.Redirect.INHERIT;
				case "discard": return ProcessBuilder.Redirect.DISCARD;
				default: return ProcessBuilder.Redirect.appendTo(new File(co));
			}
		}

		private ProcessBuilder makePB(String ...args) {
			ProcessBuilder pb=new ProcessBuilder(Arrays.asList(args));
			pb.redirectOutput(i);
			pb.redirectOutput(o);
			pb.redirectError(e);
			return pb;
		}

		private String descTime(long nSec) {
			String t="";
			double r=(double)nSec,v;
			r/=3600*1e+9;
			v=Math.floor(r);
			if (v>=1) t+=String.format("%.0fh ",v);
			r=(r-v)*60;
			v=Math.floor(r);
			if (v>=1) t+=String.format("%.0fm ",v);
			r=(r-v)*60;
			v=Math.floor(r);
			if (v>=1) t+=String.format("%.0fs ",v);
			r=(r-v)*1000;
			t+=String.format("%07.3fms",r);
			return t;
		}

		private String descEC(int ec) {
			if (ec<0) return "terminated due to signal";
			else return String.format("exit code: %d",ec);
		}

		private void showResult(String ...l) {
			String text=lines(l);
			switch (result) {
				case "stdout": if (!text.isEmpty()) System.out.println(text); break;
				case "stderr": if (!text.isEmpty()) System.err.println(text); break;
				default:
					try{
						Files.writeString(
							Paths.get(result),
							text,
							StandardOpenOption.WRITE,
							StandardOpenOption.CREATE,
							StandardOpenOption.APPEND
						);
					}
					catch(IOException e){ error("指定したパスには書き込みできません: "+result); }
					break;
			}
		}

	}

	private static void help() {
		System.out.println(lines(
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
		));
		System.exit(0);
	}

	private static void version() {
		System.out.println(lines(
			"",
			" measure v2.2",
			" Java バージョン (measure-java)",
			""
		));
		System.exit(0);
	}

	private static String lines(String ...l) { return String.join(System.lineSeparator(),l); }

	private static void error(String text) {
		System.err.println(text);
		System.exit(1);
	}

}