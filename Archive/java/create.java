import java.util.*;
import java.nio.file.*;

public class create {

	private static Map<String,Object> d = util.map(
		"archive",null,
		"inFile",util.sl(),
		"type","zip",
		"mode","default",
		"level","default",
		"format","default",
		"single","",
		"excludeHiddenFiles","true",
		"encrypted","",
		"encryptType","default",
		"prior",null
	);

	public static void help() {
		util.helpText(
			"",
			"arc create [archive path] [options] [input file paths]...",
			"arc compress [input file path]... [options]",
			"",
			"アーカイブを生成します",
			"生成するにあたり,コンピュータで利用可能な方法を選択して実行します",
			"オプションによってはいずれの方法でも生成できない場合があり,その時にはエラーを返します",
			"",
			"オプション",
			"",
			"[input file path]...",
			"-i [string]...,--in [string]...",
			" アーカイブに含めるファイルを指定します",
			"",
			"[archive path]",
			"-a [string],-o [string],--archive [string],--out [string]",
			" 生成するアーカイブファイルの保存場所を指定します",
			"",
			"-t [enum],--type [enum]",
			" アーカイブの種類を指定します",
			" zip  zipアーカイブ (--zip,デフォルト)",
			" tar  tarアーカイブ (--tar)",
			" 7z   7zアーカイブ (--7z)",
			" この他にも対応しているフォーマットがあります。詳しくは後述",
			"",
			"-p [enum],--prior [enum]",
			" 生成方法を指定します (シェルコマンド)",
			" アーカイブの種類によって利用可能な生成方法は異なります (後述)",
			" 指定したオプション次第では指定した方法では生成されないことがあります",
			"",
			"-#,-l [int],--level [int]",
			" 圧縮率を指定します",
			" 1~9 の整数で指定し,数値が大きいと圧縮率が高くなります",
			" デフォルトは6",
			" ※ tarオプションでは例外があります",
			"  -m lz4 の場合は 1~12 で指定し,デフォルトは1です",
			"  -m zstd の場合は 1~19 で指定し,デフォルトは3です",
			"  -m stored の場合はこのオプションは無効です",
			"  -m compress の場合はこのオプションは無効です",
			"",
			"-v [int],--verbose [int]",
			" コマンドの出力レベルを指定します",
			"  -v 0, -s, --silence",
			"   何も出力しません。コマンド実行時にエラーがあっても出力しません。",
			"  -v 1 (デフォルト)",
			"   コマンド実行時にエラーがある場合にはエラーを標準エラー出力に出力します。",
			"  -v 2, -v",
			"   コマンド実行時の作業内容を出力します。暗号化ファイルを生成する場合にはパスワードが表示されるので注意してください。",
			"",
			"zipアーカイブのオプション",
			"",
			" 生成方法 (優先順)",
			"  7z  7zコマンド",
			"  zip zipコマンド",
			"  tar tarコマンド",
			"",
			" -m [enum],--mode [enum]",
			"  圧縮モードを指定します",
			"  store,copy  非圧縮 (デフォルト)",
			"  gz,deflate  Deflate圧縮",
			"  bz,bzip2    BZIP2圧縮",
			"  xz,lzma     LZMA圧縮",
			"",
			" -e,--encrypt [enum]",
			"  アーカイブを暗号化します",
			"  パスワードは後で指定します",
			"  [enum] に次のうちいずれかの値を指定した暗号化の方法を指定できます",
			"   zipcrypto ZIP標準の暗号システム (デフォルト)",
			"   aes128    AES128暗号",
			"   aes192    AES192暗号",
			"   aes256    AES256暗号",
			"",
			"tarアーカイブのオプション",
			"",
			" 生成方法 (優先順)",
			"  tar    tarコマンド",
			"  gnutar gtarコマンド",
			"  7z     7zコマンド",
			"",
			" -m [enum],--mode [enum]",
			"  圧縮モードを指定します",
			"  store,copy  非圧縮 (.tar,デフォルト)",
			"  gz,deflated Deflate圧縮 (.tar.gz)",
			"  bz,bzip2    BZIP2圧縮 (.tar.bz2)",
			"  xz,lzma     LZMA圧縮 (.tar.xz)",
			"  lzip        LZIP圧縮 (.tar.lz)",
			"  lzop        LZOP圧縮 (.tar.lzop)",
			"  lz4         LZ4圧縮 (.tar.lz4)",
			"  brotli      Brotli圧縮 (.tar.br)",
			"  zstd        Zstandard圧縮 (.tar.zst)",
			"",
			" -f [enum],--format [enum]",
			"  tarのフォーマットを指定します",
			"  cpio  cpioフォーマット",
			"  shar  sharフォーマット",
			"  ustar ustarフォーマット",
			"  gnu   GNU tarフォーマット",
			"  pax   paxフォーマット (デフォルト)",
			"",
			" -s,--single",
			"  -i で単一のファイルを指定した場合には,tarでアーカイブにせず圧縮ファイルを生成します。",
			"  例えば, -m gz とした場合, file は file.tar.gz ではなく file.gz になります。",
			"  -m store の場合はファイルが単純にコピーされます。",
			"",
			" --include-hidden-files",
			"  macOSの隠しファイルもアーカイブします",
			"  これらにはFinderで使用されるデータも含み,展開時にそれらが復元されますが,他のプラットフォームでは可視ファイルとして展開されます",
			"",
			"7zアーカイブのオプション",
			"",
			" 生成方法 (優先順)",
			"  7z  7zコマンド",
			"  tar tarコマンド",
			"",
			" -m [enum],--mode [enum]",
			"  圧縮モードを指定します",
			"  stored,copy 非圧縮",
			"  gz,deflate  Deflate圧縮",
			"  bz,bzip2    BZIP2圧縮",
			"  xz,lzma     LZMA圧縮",
			"  lzma2       LZMA2圧縮 (デフォルト)",
			"",
			" -e,--encrypt",
			"  アーカイブを暗号化します",
			"  パスワードは後で指定します",
			"",
			" -e he,--encrypt he",
			"  暗号化するにあたって,ヘッダも暗号化します",
			"  これにより, arc paths などでファイルの中身を表示できなくなります",
			"",
			"-tオプションで指定可能な値",
			" zip   zipアーカイブ (--zip)",
			" tar   tarアーカイブ (--tar)",
			" 7z    7zアーカイブ (--7z)",
			"",
			" gzip  Gzip      (-t tar -m gzip -s と同等)",
			" bzip2 Bzip2     (-t tar -m bzip2 -s と同等)",
			" xz    xz        (-t tar -m xz -s と同等)",
			" lzip  Lzip      (-t tar -m lzip -s と同等)",
			" lzop  Lzop      (-t tar -m lzop -s と同等)",
			" lz4   Lz4       (-t tar -m lz4 -s と同等)",
			" br    Brotli    (-t tar -m brotli -s と同等)",
			" zstd  Zstandard (-t tar -m zstd -s と同等)",
			"",
			" --gzip,--bzip2,... などでも指定可能",
			""
		);
	}

	public static Object main(String a) {

		analyze(a);

		String t=util.strCast(d.get("type"));
		if (util.eq(t,"zip")) Zip.run();
		else if (util.eq(t,"tar")) Tar.run();
		else if (util.eq(t,"7z")) Sz.run();
		else util.error("アーカイブタイプが不正です: "+util.strCast(d.get("type")));

		return null;

	}

	private static void analyze(String a) {

		String[] i=util.sa();
		if (a.equals("create")) i=util.sa("archive","inFile");
		if (a.equals("compress")) i=util.sa("inFile");

		ArrayList<String[][]> pl=util.sl2(
			util.sa2(
				util.sa("-a","-o","--archive","--out"),
				util.sa("var","archive")
			),
			util.sa2(
				util.sa("-i","--in"),
				util.sa("var","inFile","true")
			),
			util.sa2(
				util.sa("-t","--type"),
				util.sa("var","type")
			),
			util.sa2(
				util.sa("-m","--mode"),
				util.sa("var","mode")
			),
			util.sa2(
				util.sa("-l","--level"),
				util.sa("var","level")
			),
			util.sa2(
				util.sa("-#"),
				util.sa("write","level")),
			util.sa2(
				util.sa("-f","--format"),
				util.sa("var","format")
			),
			util.sa2(
				util.sa("-p","--prior"),
				util.sa("var","prior")
			),
			util.sa2(
				util.sa("-s","--single"),
				util.sa("write","single","true")
			),
			util.sa2(
				util.sa("--include-hidden-files"),
				util.sa("write","excludeHiddenFiles","")
			),
			util.sa2(
				util.sa("-e","--encrypt"),
				util.sa("write","encrypted","true"),
				util.sa("var","encryptType")
			),
			util.sa2(
				util.sa("-v","--verbose"),
				util.sa("write","verbose","2"),
				util.sa("var","verbose")
			),
			util.sa2(
				util.sa("-s","--silence"),
				util.sa("write","verbose","0")
			),
			util.sa2(
				util.sa("--zip"),
				util.sa("write","type","zip")
			),
			util.sa2(
				util.sa("--tar"),
				util.sa("write","type","tar")
			),
			util.sa2(
				util.sa("--7z"),
				util.sa("write","type","7z")
			)
		);

		for (util.CompressType c:util.compressors) {
			ArrayList<String> ll=util.sl();
			for (String k:c.keys) ll.add("--"+k);
			pl.add(
				util.sa2(
					ll.toArray(new String[ll.size()]),
					util.sa("write","type",c.keys[0])
				)
			);
		}
		String[][][] p=pl.toArray(new String[pl.size()][][]);

		util.switches(d,p,i,0);

		for (util.CompressType c:util.compressors) {
			boolean match=false;
			for (String k:c.keys) {
				String t=util.cast(d.get("type"));
				if (k.equals(t)) match=true;
			}
			if (match) {
				d.put("type","tar");
				d.put("mode",c.keys[0]);
				d.put("single","true");
				break;
			}
		}

		String ad=util.cast(d.get("archive"));
		if (ad!=null) {
			while (!util.isdir(ad)) ad=util.getdir(ad);
			if (!util.writable(ad)) util.error("この場所には保存できません");
		}

	}

	private static void verboseInfo() {

		util.println(
			"ステータス:",
			" カレントディレクトリ:",
			"  "+util.cwd
		);

		ArrayList<String> i=util.cast(d.get("inFile"));
		if (i.size()==0) util.println(" 入力ファイル: なし");
		else util.println(" 入力ファイル: "+String.join(" ",i));

		util.println(" 出力ファイル: "+util.strCast(d.get("archive")));

	}

	private static class Zip {

		private static String run7z=null;
		private static String runZip=null;
		private static String runTar=null;

		public static void run() {

			run7z=util.which("7z");
			runZip=util.which("zip");
			runTar=util.bsdTar();

			String[] m=modeAnalyze();
			String[] l=util.levelCast(util.strCast(d.get("level")));
			String[] e=encryptionAnalyze();
			archiveAnalyze("zip");

			if (util.verbose>1) verboseInfo();

			String p=util.strCast(d.get("prior"));
			if (util.eq(p,"7z")&&run7z!=null) szCmd(run7z,m[0],l[1],e[0]);
			else if (util.eq(p,"zip")&&runZip!=null) zipCmd(runZip,m[1],l[0]);
			else if (util.eq(p,"tar")&&runTar!=null) tarCmd(runTar,m[2],e[2]);
			else if (run7z!=null) szCmd(run7z,m[0],l[1],e[0]);
			else if (runZip!=null) zipCmd(runZip,m[1],l[0]);
			else if (runTar!=null) tarCmd(runTar,m[2],e[2]);
			else util.error("条件に合致したzipを生成する手段が見つかりませんでした");

		}

		private static String[] modeAnalyze() {
			String ms=util.cast(d.get("mode"));

			String[] m;
			if (util.eq(ms,"store","copy","default")) m=util.sa("Copy","store","store");
			else if (util.eq(ms,"gz","deflate")) m=util.sa("Deflate","deflate","deflate");
			else if (util.eq(ms,"deflate64")) m=util.sa("Deflate64","deflate","deflate");
			else if (util.eq(ms,"bz","bzip2")) {
				m=util.sa("BZip2","bzip2","");
				runTar=null;
			}
			else if (util.eq(ms,"xz","lzma")) {
				m=util.sa("LZMA","","");
				runZip=runTar=null;
			}
			else if (util.eq(ms,"ppmd")) {
				m=util.sa("PPMd","","");
				runZip=runTar=null;
			}
			else m=util.sa("Copy","store","store");

			return m;
		}

		private static String[] encryptionAnalyze() {
			String[] e;
			if (util.str2bool(d.get("encrypted"))) {
				String es=util.strCast(d.get("encryptType"));
				if (util.eq(es,"zipcrypto","default")) e=util.sa("ZipCrypto","-e","zipcrypt");
				else if (util.eq(es,"aes128")) {
					e=util.sa("AES128","","aes128");
					runZip=null;
				}
				else if (util.eq(es,"aes192")) {
					e=util.sa("AES192","","aes256");
					runZip=null;
				}
				else if (util.eq(es,"aes256")) {
					e=util.sa("AES256","","aes256");
					runZip=null;
				}
				else e=util.sa("ZipCrypto","-e","zipcrypt");
			}
			else e=util.sa(null,null,null);
			return e;
		}

		private static void szCmd(String cmd,String m,String l,String e) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive");
			if (util.slCast(d.get("inFile")).size()>0) {
				ArrayList<String> arg=util.sl(cmd,"a","-tzip",ap,"-sas","-xr!.DS_Store","-mx="+l,"-mm="+m);
				if (util.str2bool(d.get("encrypted"))) {
					String p=util.password();
					arg.add("-mem="+e);
					arg.add("-p"+p);
				}
				arg.addAll(util.slCast(d.get("inFile")));
				if (!util.exec(arg.toArray(new String[arg.size()]),true,null)) {
					tmp.done();
					util.error("7zでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				util.exec(util.sa(cmd,"a","-tzip",ap,".blank"),true,tmp.tmpDir);
				util.exec(util.sa(cmd,"d","-tzip",ap,".blank"),true,tmp.tmpDir);
			}
			util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

		private static void zipCmd(String cmd,String m,String l) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive");
			if (util.slCast(d.get("inFile")).size()>0) {
				ArrayList<String> arg=util.sl(cmd,ap,"-qr");
				arg.addAll(util.slCast(d.get("inFile")));
				if (util.eq(m,"deflate","bzip2")) arg.add("-"+l);
				if (util.str2bool(d.get("encrypted"))) {
					String p=util.password();
					arg.add("-P");arg.add(p);
				}
				arg.addAll(Arrays.asList("-x",".DS_Store","-Z",m));
				if (!util.exec(arg.toArray(new String[arg.size()]),false,null)) {
					tmp.done();
					util.error("zipでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				util.exec(util.sa(cmd,"-q",ap,".blank"),true,tmp.tmpDir);
				util.exec(util.sa(cmd,"-dq",ap,".blank"),true,tmp.tmpDir);
			}
			util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

		private static void tarCmd(String cmd,String m,String e) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive.zip");

			ArrayList<String> arg=util.sl(cmd,"-a","-cf",ap,"--options","zip:compression="+m);
			if (util.str2bool(d.get("encrypted"))) arg.set(5,arg.get(5)+",zip:encryption="+e);
			arg.addAll(Arrays.asList("--exclude",".DS_Store"));

			if (util.slCast(d.get("inFile")).size()>0) {
				arg.addAll(util.slCast(d.get("inFile")));
				if (!util.exec(arg.toArray(new String[arg.size()]),false,null)) {
					tmp.done();
					util.error("tarでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				arg.addAll(Arrays.asList("--exclude",".blank",".blank"));
				util.exec(arg.toArray(new String[arg.size()]),true,tmp.tmpDir);
			}
			util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

	}

	private static class Tar {

		private static String runBTar=null;
		private static String runGTar=null;
		private static String run7z=null;

		public static Object run() {

			runBTar=util.bsdTar();
			runGTar=util.gnuTar();
			run7z=util.which("7z");

			util.CompressType m=modeAnalyze();
			String[] l=util.levelCast(util.strCast(d.get("level")));
			String f=formatAnalyze();

			if (util.slCast(d.get("inFile")).size()==1&&util.str2bool(d.get("single"))) {
				String sf=util.slCast(d.get("inFile")).get(0);
				if (util.isfile(sf)) {
					archiveAnalyze(m.ext);
					comp(sf,m,l);
					return null;
				}
			}

			archiveAnalyze(m.tarExt);

			if (util.verbose>1) verboseInfo();

			String p=util.strCast(d.get("prior"));
			if (util.eq(p,"bsdtar","tar")&&runBTar!=null) tarCmd(runBTar,m,l,f);
			else if (util.eq(p,"gnutar")&&runGTar!=null) tarCmd(runGTar,m,l,f);
			else if (util.eq(p,"7z")&&run7z!=null) szCmd(run7z,m,l);
			else if (runBTar!=null) tarCmd(runBTar,m,l,f);
			else if (runGTar!=null) tarCmd(runGTar,m,l,f);
			else if (run7z!=null) szCmd(run7z,m,l);
			else util.error("条件に合致したtarを生成する手段が見つかりませんでした");

			return null;

		}

		private static util.CompressType modeAnalyze() {
			String ms=util.strCast(d.get("mode"));
			util.CompressType m=util.ct(util.sa(),null,null,"tar","");

			if (!util.eq(ms,"store","copy","default")) {
				for (util.CompressType c:util.compressors) {
					boolean match=false;
					for (String k:c.keys) if (util.eq(k,ms)) match=true;
					if (match) {
						m=c;
						break;
					}
				}
			}

			if (m.compressCmd!=null) {
				String c=util.which(m.compressCmd[0]);
				if (c!=null) m.compressCmd[0]=c;
				else util.error("コマンド \""+m.compressCmd[0]+"\" が利用できないため実行できません");
			}

			return m;
		}

		private static String formatAnalyze() {
			String fs=util.strCast(d.get("format"));

			if (util.eq(fs,"default")) return "pax";
			if (util.eq(fs,"cpio")) return "cpio";
			if (util.eq(fs,"shar")) return "shar";
			if (util.eq(fs,"ustar")) return "ustar";
			if (util.eq(fs,"gnu")) return "gnu";
			if (util.eq(fs,"pax")) return "pax";
			return "pax";

		}

		private static void szCmd(String cmd,util.CompressType m,String[] l) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive");
			if (util.slCast(d.get("inFile")).size()>0) {
				ArrayList<String> arg=util.sl(cmd,"a","-ttar",ap,"-sas");
				arg.addAll(util.slCast(d.get("inFile")));
				if (!util.exec(arg.toArray(new String[arg.size()]),true,null)) {
					tmp.done();
					util.error("7zでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				util.exec(util.sa(cmd,"a","-ttar",ap,".blank"),true,tmp.tmpDir);
				util.exec(util.sa(cmd,"d","-ttar",ap,".blank"),true,tmp.tmpDir);
			}
			if (m.compressCmd!=null) {
				compress(m.compressCmd,l,ap,tmp);
				util.mv(ap+"."+m.ext,util.strCast(d.get("archive")));
			}
			else util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

		private static void tarCmd(String cmd,util.CompressType m,String[] l,String f) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive");

			ArrayList<String> arg=util.sl(cmd,"-cf",ap,"--format",f);
			if (util.str2bool(d.get("excludeHiddenFiles"))) {
				arg.addAll(Arrays.asList("--exclude",".DS_Store"));
				util.env.put("COPYFILE_DISABLE","1");
			}

			if (util.slCast(d.get("inFile")).size()>0) {
				arg.addAll(util.slCast(d.get("inFile")));
				if (!util.exec(arg.toArray(new String[arg.size()]),false,null)) {
					tmp.done();
					util.error("tarでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				arg.addAll(Arrays.asList("--exclude",".blank",".blank"));
				util.exec(arg.toArray(new String[arg.size()]),true,tmp.tmpDir);
			}
			if (m.compressCmd!=null) {
				compress(m.compressCmd,l,ap,tmp);
				util.mv(ap+"."+m.ext,util.strCast(d.get("archive")));
			}
			else util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

		private static void comp(String f,util.CompressType m,String[] l) {
			if (m.compressCmd!=null) {
				String fn=util.basename(f);
				util.Temp tmp=new util.Temp();
				String tf=util.concatPath(tmp.tmpDir,fn);
				util.hardlink(f,tf);
				compress(m.compressCmd,l,tf,tmp);
				util.mv(tf+"."+m.ext,util.strCast(d.get("archive")));
				tmp.done();
			}
			else util.cp(f,util.strCast(d.get("archive")));
		}

		private static void compress(String[] m,String[] l,String ap,util.Temp tmp) {
			String cmd=util.basename(m[0]);
			ArrayList<String> ml=util.sl(m);
			if (util.eq(cmd,"lz4")) ml.add("-"+l[2]);
			else if (util.eq(cmd,"zstd")) ml.add("-"+l[3]);
			else if (!util.eq(cmd,"compress")) ml.add("-"+l[0]);
			ml.add(ap);
			if (util.eq(cmd,"lz4")) ml.add(ap+".lz4");
			m=ml.toArray(new String[ml.size()]);
			if (!util.exec(m,true,null)) {
				tmp.done();
				util.error("コマンド \""+cmd+"\" でエラーが発生しました");
			}
		}

	}

	private static class Sz {

		private static String run7z=null;
		private static String runTar=null;

		public static void run() {

			run7z=util.which("7z");
			runTar=util.bsdTar();

			String m=modeAnalyze();
			String[] l=util.levelCast(util.strCast(d.get("level")));
			boolean he=false;
			if (util.str2bool(d.get("encrypted"))) {
				runTar=null;
				if (util.eq(util.strCast(d.get("encryptType")),"he")) he=true;
			}
			archiveAnalyze("7z");

			if (util.verbose>1) verboseInfo();

			String p=util.strCast(d.get("prior"));
			if (util.eq(p,"7z")&&run7z!=null) szCmd(run7z,m,l[1],he);
			else if (util.eq(p,"tar")&&runTar!=null) tarCmd(runTar);
			else if (run7z!=null) szCmd(run7z,m,l[1],he);
			else if (runTar!=null) tarCmd(runTar);
			else util.error("条件に合致した7zを生成する手段が見つかりませんでした");

		}

		private static String modeAnalyze() {
			String ms=util.strCast(d.get("mode"));

			String m;
			if (util.eq(ms,"store","copy")) m="Copy";
			else if (util.eq(ms,"gz","deflate")) m="Deflate";
			else if (util.eq(ms,"bz","bzip2")) m="BZip2";
			else if (util.eq(ms,"xz","lzma")) m="LZMA";
			else if (util.eq(ms,"lzma2","default")) m="LZMA2";
			else m="LZMA2";

			return m;
		}

		private static void szCmd(String cmd,String m,String l,boolean he) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive");
			if (util.slCast(d.get("inFile")).size()>0) {
				ArrayList<String> arg=util.sl(cmd,"a","-t7z",ap,"-sas","-xr!.DS_Store","-mx="+l,"-m0="+m);
				if (util.str2bool(d.get("encrypted"))) {
					String p=util.password();
					arg.add("-p"+p);
					if (he) arg.add("-mhe=on");
				}
				arg.addAll(util.slCast(d.get("inFile")));
				if (!util.exec(arg.toArray(new String[arg.size()]),true,null)) {
					tmp.done();
					util.error("7zでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				util.exec(util.sa(cmd,"a","-t7z",ap,".blank"),true,tmp.tmpDir);
				util.exec(util.sa(cmd,"d","-t7z",ap,".blank"),true,tmp.tmpDir);
			}
			util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

		private static void tarCmd(String cmd) {
			util.Temp tmp=new util.Temp();
			String ap=util.concatPath(tmp.tmpDir,".archive.7z");

			ArrayList<String> arg=util.sl(cmd,"-a","-cf",ap);
			arg.addAll(Arrays.asList("--exclude",".DS_Store"));

			if (util.slCast(d.get("inFile")).size()>0) {
				arg.addAll(util.slCast(d.get("inFile")));
				if (!util.exec(arg.toArray(new String[arg.size()]),false,null)) {
					tmp.done();
					util.error("tarでエラーが発生しました");
				}
			}
			else {
				tmp.blank();
				arg.addAll(Arrays.asList("--exclude",".blank",".blank"));
				util.exec(arg.toArray(new String[arg.size()]),true,tmp.tmpDir);
			}
			util.mv(ap,util.strCast(d.get("archive")));
			tmp.done();
		}

	}

	private static void archiveAnalyze(String ext) {
		if (!ext.isEmpty()) ext="."+ext;
		String f;
		List<String> inf=util.slCast(d.get("inFile"));
		if (inf.size()==1) f=inf.get(0)+ext;
		else f="Archive"+ext;
		if (util.strCast(d.get("archive"))==null) {
			if (!util.writable(util.cwd)) util.error("カレントディレクトリにアーカイブを書き出すことができません");
			d.put("archive",f);
		}
		if (util.isdir(util.strCast(d.get("archive")))) d.put("archive",util.concatPath(util.strCast(d.get("archive")),f));
	}

}