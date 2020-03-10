import java.util.*;
import java.util.regex.*;
import java.util.function.Function;
import java.io.*;
import java.nio.file.*;

public class util {

	public static int verbose = 1;
	private static void setVerbose(String v) {
		if (v.matches("[0-2]")) verbose=Integer.parseInt(v);
	}
		/*
			0: silent
			1: normal
			2: verbose
		*/

	public static String cwd = System.getProperty("user.dir");
	public static Map<String,String> env=new HashMap<String,String>(System.getenv());
	public static boolean mkdir(String path) {
		try{
			Files.createDirectory(getPath(path));
			return true;
		}catch(Exception e){return false;}
	}
	public static boolean mv(String src,String dst) {
		try{
			Files.move(getPath(src),getPath(dst), StandardCopyOption.REPLACE_EXISTING);
			return true;
		}catch(Exception e){
			println(e);
			return false;
		}
	}
	public static boolean cp(String src,String dst) {
		try{
			Files.copy(getPath(src),getPath(dst), StandardCopyOption.REPLACE_EXISTING);
			return true;
		}catch(Exception e){return false;}
	}
	public static boolean hardlink(String src,String dst) {
		try{
			Files.createLink(getPath(dst),getPath(src));
			return true;
		}catch(Exception e){return false;}
	}
	public static String basename(String path) {
		return getPath(path).getFileName().toString();
	}

	public static Path getPath(String path) {
		Path p=Path.of(path);
		try{return p.toRealPath(LinkOption.NOFOLLOW_LINKS);}
		catch(IOException e) {return p;}
	}
	public static boolean isfile(String path) {return Files.isRegularFile(getPath(path));}
	public static boolean isdir(String path) {return Files.isDirectory(getPath(path));}
	public static boolean islink(String path) {return Files.isSymbolicLink(getPath(path));}
	public static boolean writable(String path) {return Files.isWritable(getPath(path));}
	public static String which(String cmd) {
		Function<String[],String> f=(c)->{
			String rd=getData(c);
			if (rd==null) return rd;
			return rd.split("\\r?\\n")[0];
		};
		String d;
		d=f.apply(new String[] {"which",cmd});
		if (d!=null) return d;
		d=f.apply(new String[] {"where",cmd});
		if (d!=null) return d;
		return null;
	}

	public static boolean rm(File f) {
		try{
			if (!f.exists()) return false;
			if (f.isDirectory()) {
				File[] l=f.listFiles();
				for (File sf:l) if (!rm(sf)) return false;
			}
			if (!f.delete()) return false;
		}catch(Exception e){return false;}
		return true;
	}

	public static boolean rm(String f) {
		return rm(new File(f));
	}

	public static String getdir(String path) {
		return getPath(path).resolve("../").normalize().toString();
	}

	public static String concatPath(String path0,String ...paths) {
		Path p=Path.of(path0);
		for (String e:paths) p=p.resolve(e);
		return p.normalize().toString();
	}

	public static String[] fileList(String path) {
		File d=new File(path);
		File[] l=d.listFiles();
		List<String> fl=new ArrayList<>();
		for (File f:l) fl.add(f.getName());
		return fl.toArray(new String[fl.size()]);
	}

	public static void println(Object ...val) {
		for (Object v:val) System.out.println(v);
	}

	public static class Temp {
		public String tmpDir;
		public Path tmpDirPath;
		public Temp() {
			try{
				String id="archive"+String.valueOf((int)Math.floor(Math.random()*100000));
				tmpDirPath=Files.createTempDirectory(id);
				tmpDir=tmpDirPath.toString();
				if (verbose>1) println("一時ディレクトリ生成しました:"," "+tmpDir);
			}catch(Exception e){
				error("作業用一時ディレクトリが生成できませんでした。");
			}
		}
		public boolean blank() {
			try{
				Path blank=Path.of(tmpDir,".blank");
				Files.createFile(blank);
				return true;
			}catch(Exception e){return false;}
		}
		public boolean done() {return rm(tmpDir);}
	}

	public static String password() {
		try{
			if (which("read").isEmpty()) throw new Exception();
			ProcessBuilder pb=new ProcessBuilder(Arrays.asList("/bin/sh","-c","read -s -p \"パスワード: \" text ; echo>&2 ; echo $text"));
			pb.redirectInput(ProcessBuilder.Redirect.INHERIT);
			pb.redirectError(ProcessBuilder.Redirect.INHERIT);
			String pw="";
			while (pw.isEmpty()) {
					Process p=pb.start();
					InputStream is=p.getInputStream();
					StringBuilder sb=new StringBuilder();
					while (true) {
						int c=is.read();
						if (c==-1) {
							is.close();
							break;
						}
						sb.append((char)c);
					}
					if (p.waitFor()==0) pw=sb.toString().replaceFirst("\\r?\\n$","");
					else throw new Exception();
			}
			return pw;
		}catch(Exception e){error("パスワードが指定できません");}
		return null;
	}

	public static void error(String text) {
		if (verbose>0) System.err.println(text);
		if (verbose>1) System.err.println("エラーにより終了します");
		System.exit(1);
	}

	public static boolean exec(String[] cmd,boolean quiet,String dir) {
		if (verbose>1) println("コマンドを実行します:"," "+String.join(" ",cmd),"");
		ProcessBuilder pb=new ProcessBuilder(Arrays.asList(cmd));
		pb.redirectError(verbose>1 ?
			ProcessBuilder.Redirect.INHERIT :
			ProcessBuilder.Redirect.DISCARD
		);
		pb.redirectOutput(verbose>1 ?
			ProcessBuilder.Redirect.INHERIT :
			ProcessBuilder.Redirect.DISCARD
		);
		pb.environment().putAll(env);
		if (dir!=null) pb.directory(new File(dir));
		try{
			Process p=pb.start();
			return p.waitFor()==0;
		}catch(Exception e){return false;}
	}

	public static String getData(String[] cmd) {
		ProcessBuilder pb=new ProcessBuilder(Arrays.asList(cmd));
		pb.redirectError(ProcessBuilder.Redirect.DISCARD);
		try{
			Process p=pb.start();
			InputStream is=p.getInputStream();
			StringBuilder sb=new StringBuilder();
			while (true) {
				int c=is.read();
				if (c==-1) {
					is.close();
					break;
				}
				sb.append((char)c);
			}
			if (p.waitFor()==0) return sb.toString().replaceFirst("\\r?\\n$","");
			else return null;
		}catch(Exception e){return null;}
	}

	public static String bsdTar() {
		String[] l={which("bsdtar"),which("tar")};
		for (String t:l) if (t!=null) {
			String v=getData(new String[] {t,"--version"});
			if (v!=null) if (v.matches(".*bsdtar.*")) return t;
		}
		return null;
	}

	public static String gnuTar() {
		String[] l={which("gnutar"),which("tar"),which("gtar")};
		for (String t:l) if (t!=null) {
			String v=getData(new String[] {t,"--version"});
			if (v!=null) if (v.matches(".*GNU tar.*")) return t;
		}
		return null;
	}

	public static void helpText(String ...text) {
		if (text[text.length-1].isEmpty()) text[text.length-1]=null;
		for (String t:text) if (t!=null) System.out.println(t);
	}

	public static String[] levelCast(String val) {
		String[] l;
		if (val.matches("[1-9]")) l=sa(val,String.valueOf((int)(Math.ceil(Float.parseFloat(val)/2)*2-1)),val,val);
		else if (val.matches("1[0-9]")) {
			l=sa("9","9",val,val);
			if (Integer.parseInt(val)>12) l[2]="12";
		}
		else if (val=="default") l=sa("6","5","1","3");
		else l=sa("6","5","1","3");
		return l;
	}

	public static String[] sa(String ...v) {return v;}
	public static String[][] sa2(String[] ...v) {return v;}
	public static String[][][] sa3(String[][] ...v) {return v;}
	public static ArrayList<String> sl(String ...v) {
		List<String> l=Arrays.asList(v);
		ArrayList<String> al=new ArrayList<>(l);
		return al;
	}
	public static ArrayList<String[][]> sl2(String[][] ...v) {
		List<String[][]> l=Arrays.asList(v);
		ArrayList<String[][]> al=new ArrayList<>(l);
		return al;
	}
	public static Map<String,Object> map(Object ...l) {
		String key=null;
		Map<String,Object> m=new HashMap<String,Object>();
		for (Object o:l) {
			if (key!=null) {
				m.put(key,o);
				key=null;
			}
			else if (o instanceof String) key=(String)o;
			else continue;
		}
		return m;
	}
	public static boolean eq(String target,String ...candidate) {
		for (String c:candidate) if (c.equals(target)) return true;
		return false;
	}
	public static boolean str2bool(Object target) {return !strCast(target).isEmpty();}
	public static String[] add(String[] exist,String ...nv) {
		ArrayList<String> al = sl(exist);
		for (String v:nv) al.add(v);
		return al.toArray(new String[al.size()]);
	}

	@SuppressWarnings("unchecked")
	public static <T> T cast(Object v) {
		return (T)v;
	}

	public static String strCast(Object v) {
		String s=cast(v);
		return s;
	}

	public static List<String> slCast(Object v) {
		List<String> l=cast(v);
		return l;
	}

	public static class CompressType {
		public String[] keys = {};
		public String[] compressCmd = {};
		public String[] decompressCmd = {};
		public String tarExt="";
		public String ext="";
	}
	public static CompressType ct(String[] keys,String[] compressCmd,String[] decompressCmd,String tarExt,String ext) {
		CompressType t=new CompressType();
		t.keys=keys;
		t.compressCmd=compressCmd;
		t.decompressCmd=decompressCmd;
		t.tarExt=tarExt;
		t.ext=ext;
		return t;
	}
	public static CompressType[] compressors={
		// compress
		ct(
			sa("z","Z","compress","lzw"),
			sa("compress","-f"),
			sa("uncompress","-f"),
			"tar.Z","Z"
		),
		// gzip
		ct(
			sa("gz","gzip","deflate"),
			sa("gzip","-f","-k"),
			sa("gzip","-d","-f"),
			"tgz","gz"
		),
		// bzip2
		ct(
			sa("bz","bz2","bzip","bzip2"),
			sa("bzip2","-z","-f","-k"),
			sa("bzip2","-d"),
			"tbz2","bz2"
		),
		// xz
		ct(
			sa("xz","lzma"),
			sa("xz","-z","-f","-k","-T0"),
			sa("xz","-d","-f"),
			"txz","xz"
		),
		// lzip
		ct(
			sa("lz","lzip"),
			sa("lzip","-f","-k"),
			sa("lzip","-d","-f"),
			"tlz","lz"
		),
		// lzop
		ct(
			sa("lzo","lzop"),
			sa("lzop","-f"),
			sa("lzop","-d","-f"),
			"tar.lzo","lzo"
		),
		// brotli
		ct(
			sa("br","brotli"),
			sa("brotli","-f"),
			sa("brotli","-d","-f"),
			"tar.br","br"
		),
		// Zstandard
		ct(
			sa("zst","zstd","zstandard"),
			sa("zstd","-f","-T0"),
			sa("zstd","-d","-f","-T0"),
			"tar.zst","zst"
		),
		// lz4
		ct(
			sa("lz4"),
			sa("lz4","-f"),
			sa("lz4","-d","-f"),
			"tar.lz4","lz4"
		),
	};

	private static String[] args;
	public static void registerArgs(String[] a) {args=a;}
	public static void switches(Map<String,Object> d,String[][][] params,String[] inputs,int max) {

		String var=null;
		boolean multiple=false;
		String sharp=null;
		int step=1;

		boolean noSwitches=false;

		for (String a:Arrays.copyOfRange(args,1,args.length)) {

			boolean match=false;

			if (a.equals("--")) noSwitches=match=true;

			if (!noSwitches) {

				for (String[][] cmd:params) {
					for (String p:cmd[0]) {
						if (p.equals("-#")) {
							Matcher s=Pattern.compile("\\-([0-9]+)").matcher(a);
							if (s.matches()) {
								match=true;
								sharp=s.group(1);
							}
						}
						else if (p.equals(a)) match=true;
						if (match) break;
					}
					if (match) {
						var=null;
						for (String[] act:Arrays.copyOfRange(cmd,1,cmd.length)) {
							if (eq(act[0],"var")) {
								var=act[1];
								multiple=act.length==3;
							}
							if (eq(act[0],"write")) {
								if (sharp!=null) {
									d.put(act[1],sharp);
									sharp=null;
								}
								else if (eq(act[1],"verbose")) setVerbose(act[2]);
								else d.put(act[1],act[2]);
							}
						}
						break;
					}
				}

				if (!match) if (a.matches("\\-+.+")) error("このスイッチは無効です: "+a);

				if (!match) if (var!=null) {
					if (multiple) {
						List<String> l=cast(d.get(var));
						l.add(a);
					}
					else if (eq(var,"verbose")) setVerbose(a);
					else {
						d.put(var,a);
						var=null;
					}
					match=true;
				}

			}

			if (!match) {
				if (max>0&&step>max) error("パラメータが多すぎます");
				int i=Math.min(step,inputs.length)-1;
				if (d.get(inputs[i]) instanceof ArrayList<?>) {
					ArrayList<String> l=cast(d.get(inputs[i]));
					l.add(a);
				}
				else d.put(inputs[i],a);
				step+=1;
			}

		}

	}

}