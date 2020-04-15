import java.util.*;
import java.util.function.BiFunction;
import java.io.*;
import java.nio.file.*;

public class Measure {

	private static List<String> command=new ArrayList<String>();
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
		else {
			switch (l[0]) {
				case "-h": case "help": case "-help": case "--help": help();
				case "-v": case "version": case "-version": case "--version": version();
			}
		}
		boolean noFlags=false;
		AnalyzeKey key=null;
		for (String a:l) {
			if (noFlags) { command.add(a); continue; }
			if (key!=null) {
				switch (key) {
					case stdout: out=a; break;
					case stderr: err=a; break;
					case result: result=a; break;
				}
				key=null;
				continue;
			}
			switch (a) {
				case "-o": case "-out": case "-stdout": key=AnalyzeKey.stdout; break;
				case "-e": case "-err": case "-stderr": key=AnalyzeKey.stderr; break;
				case "-r": case "-result": key=AnalyzeKey.result; break;
				case "-m": case "-multiple": multiple=true; break;
				default:
					noFlags=true;
					command.add(a);
			}
		}
		if (command.size()==0) error("実行する内容が指定されていません");
	}
	private enum AnalyzeKey { stdout, stderr, result };

	private static class execute {

		private ProcessBuilder.Redirect i=ProcessBuilder.Redirect.INHERIT;
		private ProcessBuilder.Redirect o;
		private ProcessBuilder.Redirect e;

		execute() {
			writeFile("");
			o=redirect(out);
			e=redirect(err);
			int ec=0;

			if (multiple) {
				List<Long> pl=new ArrayList<Long>();
				List<ProcessBuilder> pbl=map(
					command,(c,n)->makePB(Arrays.asList("sh","-c",c))
				);

				long st=System.nanoTime();
				try{
					for (ProcessBuilder pb:pbl) {
						Process p=pb.start();
						pl.add(p.pid());
						ec=p.waitFor();
						if (ec!=0) break;
					}
				}
				catch(IOException e) { error("実行に失敗しました"); }
				catch(InterruptedException e) { ec=-1; }
				long en=System.nanoTime();

				List<String> dl=map(
					pl,(pid,n)->String.format("process%d id: %d",n+1,pid)
				);
				dl.add(0,String.format("time: %s",descTime(st,en)));
				dl.add(String.format("%s",descEC(ec)));
				showResult(dl);
			}
			else {
				ProcessBuilder pb=makePB(command);
				long pid=0;

				long st=System.nanoTime();
				try{
					Process p=pb.start();
					pid=p.pid();
					ec=p.waitFor();
				}
				catch(IOException e) { error("実行に失敗しました"); }
				catch(InterruptedException e) { ec=-1; }
				long en=System.nanoTime();

				showResult(Arrays.asList(
					String.format("time: %s",descTime(st,en)),
					String.format("process id: %d",pid),
					String.format("%s",descEC(ec))
				));
			}
			System.exit((ec+256)%256);
		}

		private ProcessBuilder.Redirect redirect(String co) {
			switch (co) {
				case "inherit": return ProcessBuilder.Redirect.INHERIT;
				case "discard": return ProcessBuilder.Redirect.DISCARD;
				default: return ProcessBuilder.Redirect.appendTo(new File(co));
			}
		}

		private ProcessBuilder makePB(List<String> args) {
			ProcessBuilder pb=new ProcessBuilder(args);
			pb.redirectOutput(i);
			pb.redirectOutput(o);
			pb.redirectError(e);
			return pb;
		}

		private String descTime(long st,long en) {
			String t="";
			double r=(double)(en-st),v;
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
			t+=String.format("%.3fms",r);
			return t;
		}

		private String descEC(int ec) {
			if (ec<0) return "terminated due to signal";
			else return String.format("exit code: %d",ec);
		}

		private <B,A> List<A> map(List<B> b,BiFunction<B,Integer,A> f) {
			List<A> a=new ArrayList<A>();
			for (int n=0;n<b.size();n++) a.add(f.apply(b.get(n),n));
			return a;
		}

		private void showResult(List<String> lines) {
			switch (result) {
				case "stdout": for (String t:lines) System.out.println(t); break;
				case "stderr": for (String t:lines) System.err.println(t); break;
				default:
					String res="";
					for (String t:lines) res+=t+System.lineSeparator();
					writeFile(res);
					break;
			}
		}

		private void writeFile(String text) {
			try{
				if (result!="stdout" && result!="stderr")
					Files.writeString(
						Paths.get(result),
						text,
						StandardOpenOption.WRITE,
						StandardOpenOption.CREATE,
						StandardOpenOption.APPEND
					);
			}
			catch(IOException e){ error("指定したパスには書き込みできません: "+result); }
		}

	}

	private static void help() {
		String[] text={
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
		};
		System.out.print(String.join(System.lineSeparator(),text));
		System.exit(0);
	}

	private static void version() {
		String[] text={
			"",
			" measure v2.0",
			" Java バージョン (measure-java)",
			""
		};
		System.out.print(String.join(System.lineSeparator(),text));
		System.exit(0);

	}

	private static void error(String text) {
		System.out.println(text);
		System.exit(1);
	}

}