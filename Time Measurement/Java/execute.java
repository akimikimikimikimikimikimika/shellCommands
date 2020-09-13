import java.util.*;
import java.io.*;
import java.nio.file.*;

public class execute {

	private static lib.Data d;
	private static ProcessBuilder.Redirect i=ProcessBuilder.Redirect.INHERIT;
	private static ProcessBuilder.Redirect o;
	private static ProcessBuilder.Redirect e;
	private static String result;
	private static int ec=0;

	public static void main(lib.Data rd) {
		d=rd;
		result=d.result;
		showResult();
		o=redirect(d.out);
		e=redirect(d.err);

		switch (d.multiple) {
			case none:   single(); break;
			case serial: serial(); break;
			case spawn:  spawn();  break;
			case thread: thread(); break;
		}

		System.exit(ec==-1?1:ec);
	}

	private static void single() {
		SP p=new SP(d.command);

		long st=System.nanoTime();
		p.run();
		long en=System.nanoTime();

		String[] res=new String[] {
			String.format("time: %s",descTime(en-st)),
			String.format("process id: %d",p.pid),
			descEC(p.ec)
		};
		showResult(res);

		ec=p.ec;
	}

	private static void serial() {
		SP[] pl=SP.multiple(d.command);
		SP lp=pl[pl.length-1];

		long st=System.nanoTime();
		for (SP p:pl) {
			p.run();
			if (p.ec!=0) {
				lp=p;
				break;
			}
		}
		long en=System.nanoTime();

		String[] res=new String[pl.length+2];
		res[0]=String.format("time: %s",descTime(en-st));
		for (SP p:pl) res[p.order]=String.format("process%d id: %s",p.order,p.pid<0?"N/A":p.pid);
		res[pl.length+1]=lp.descEC();
		showResult(res);

		ec=lp.ec;
	}

	private static void spawn() {
		SP[] pl=SP.multiple(d.command);

		long st=System.nanoTime();
		for (SP p:pl) p.startProcess();
		for (SP p:pl) p.waitProcess();
		long en=System.nanoTime();

		SP.collect(pl,st,en);
	}

	private static void thread() {
		SP[] pl=SP.multiple(d.command);

		long st=System.nanoTime();
		for (SP p:pl) p.start();
		try{ for (SP p:pl) p.join(); }
		catch(InterruptedException e) { lib.error("実行に失敗しました");}
		long en=System.nanoTime();

		SP.collect(pl,st,en);
	}

	private static class SP extends Thread {
		private ProcessBuilder pb;
		private Process p;
		public int order=0;
		public long pid=-1;
		public int ec=0;

		SP(String ...args) {
			pb=new ProcessBuilder(Arrays.asList(args));
			pb.redirectOutput(i);
			pb.redirectOutput(o);
			pb.redirectError(e);
		}
		public static SP[] multiple(String ...commands) {
			String sh="sh";
			try{
				sh=System.getenv("SHELL");
				if (sh==null) sh="sh";
			} catch(Exception e) { sh="sh"; }
			SP[] pdl=new SP[commands.length];
			int n=1;
			for (String c:commands) {
				SP pd=new SP(sh,"-c",c);
				pd.order=n;
				pdl[n-1]=pd;
				n++;
			}
			return pdl;
		}
		public static void collect(SP[] pl,long st,long en) {
			String[] res=new String[2*pl.length+1];
			res[0]=String.format("time: %s",descTime(en-st));
			for (SP p:pl) {
				int n=p.order;
				res[2*n-1]=String.format("process%d id: %s",n,p.pid);
				res[2*n]=p.descEC();
				if (p.ec>execute.ec) execute.ec=p.ec;
			}
			showResult(res);
		}

		public void startProcess() {
			try{
				p=pb.start();
				pid=p.pid();
			} catch(IOException e) { lib.error("実行に失敗しました"); }
		}
		public void waitProcess() {
			try{ ec=p.waitFor(); }
			catch(InterruptedException e) { ec=-1; }
		}
		public String descEC() {
			if (ec<0) return "terminated due to signal";
			else return String.format("exit code: %d",ec);
		}

		public void run() {
			startProcess();
			waitProcess();
		}


	}



	private static ProcessBuilder.Redirect redirect(String co) {
		switch (co) {
			case "inherit":
				return ProcessBuilder.Redirect.INHERIT;
			case "discard":
				return ProcessBuilder.Redirect.DISCARD;
			default:
				return ProcessBuilder.Redirect.appendTo(new File(co));
		}
	}



	private static void showResult(String ...l) {
		String text=lib.lines(l);
		switch (result) {
			case "stdout":
				if (!text.isEmpty()) System.out.println(text); break;
			case "stderr":
				if (!text.isEmpty()) System.err.println(text); break;
			default:
				try{
					Files.writeString(
						Path.of(result),
						text,
						StandardOpenOption.WRITE,
						StandardOpenOption.CREATE,
						StandardOpenOption.APPEND
					);
				}
				catch(IOException e){ lib.error("指定したパスには書き込みできません: "+result); }
				break;
		}
	}



	private static String descTime(long nSec) {
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

	private static String descEC(int ec) {
		if (ec<0) return "terminated due to signal";
		else return String.format("exit code: %d",ec);
	}

}