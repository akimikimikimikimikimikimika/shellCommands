import java.util.*;

public class expand {

	private static Map<String,Object> d = util.map(
		"archive","",
		"out","",
		"outType","same",
		"encrypted","",
		"suppressExpansion",""
	);

	public static void help() {
		util.helpText(
			"",
			"arc expand [archive path] [options]",
			"arc extract [archive path] [options]",
			"arc decompress [archive path] [options]",
			"",
			"アーカイブを展開します",
			"圧縮ファイルを解凍します",
			"",
			"オプション",
			"",
			"-a [string],-i [string],--archive [string],--in [string]",
			" アーカイブ•圧縮ファイルを指定します",
			"",
			"-d [string],-o [string],--dir [string],--out [string]",
			" 展開する場所を指定します",
			" アーカイブの場合は指定したディレクトリ内に,圧縮ファイルの場合は指定したパスに保存します",
			" 指定したディレクトリが存在しなければ自動的にディレクトリを生成します",
			"--cwd",
			" カレントディレクトリに展開します",
			"--same",
			" アーカイブファイルのあるディレクトリに展開します (デフォルト)",
			"",
			"-s,--suppress-expansion",
			" .tar.gz など,圧縮したtarアーカイブファイルを受け取った場合に,圧縮を解凍してもtarを展開しないようにします",
			"",
			"-e,--encrypt",
			" 暗号化ファイルを展開する場合は,このオプションを使用してください",
			" パスワードは後で指定します",
			"",
			"-v [int],--verbose [int]",
			" コマンドの出力レベルを指定します",
			"  -v 0, -s, --silence",
			"   何も出力しません。コマンド実行時にエラーがあっても出力しません。",
			"  -v 1 (デフォルト)",
			"   コマンド実行時にエラーがある場合にはエラーを標準エラー出力に出力します。",
			"  -v 2, -v",
			"   コマンド実行時の作業内容を出力します。暗号化ファイルを生成する場合にはパスワードが表示されるので注意してください。",
			""
		);
	}

	public static void main() {
		analyze();
		core();
	}

	private static void analyze() {

		util.switches(d,util.sa3(
			util.sa2(
				util.sa("-a","-i","--archive","--in"),
				util.sa("var","archive")
			),
			util.sa2(
				util.sa("-d","-o","--dir","--out"),
				util.sa("var","out")
			),
			util.sa2(
				util.sa("--cwd"),
				util.sa("write","outType","cwd"),
				util.sa("write","out","")
			),
			util.sa2(
				util.sa("--same"),
				util.sa("write","outType","same"),
				util.sa("write","out","")
			),
			util.sa2(
				util.sa("-e","--encrypted"),
				util.sa("write","encrypted","true")
			),
			util.sa2(
				util.sa("-s","--suppress-expansion"),
				util.sa("write","suppressExpansion","true")
			),
			util.sa2(
				util.sa("-v","--verbose"),
				util.sa("write","verbose","2"),
				util.sa("var","verbose")
			)
		),util.sa("archive"),1);

		String a=util.strCast(d.get("archive"));
		if (!util.isfile(a)) util.error("指定したパスは不正です: "+a);

		if (util.eq(util.strCast(d.get("outType")),"cwd")&&util.strCast(d.get("out")).isEmpty()) d.put("out",util.cwd);
		if (util.eq(util.strCast(d.get("outType")),"same")&&util.strCast(d.get("out")).isEmpty()) d.put("out",util.getdir(util.strCast(d.get("archive"))));

		if (util.verbose>1) verboseInfo();

	}

	private static void verboseInfo() {

		util.println(
			"ステータス:",
			" カレントディレクトリ:",
			"  "+util.cwd,
			" 入力ファイル: "+util.strCast(d.get("archive")),
			" 出力先: "+util.strCast(d.get("out"))
		);

	}

	private static void core() {
		util.Temp t=new util.Temp();
		String o=util.strCast(d.get("out"));
		if (util.isfile(o)) {
			if (decompress(t)) move(t,true);
			else {
				t.done();
				util.error("このファイルはこの場所には展開できません");
			}
		}
		else if (util.isdir(o)) {
			if (util.str2bool(d.get("suppressExpansion"))) {
				if (decompress(t)) move(t,true);
			}
			else {
				if (extract(t)) move(t,false);
				else if (decompress(t)) move(t,true);
				else {
					t.done();
					util.error("このファイルは展開できません");
				}
			}
		}
		else if (util.islink(o)) {
			t.done();
			util.error("リンクが不正です: "+o);
		}
		else {
			String pd=util.getdir(o);
			if (!util.isdir(pd)) {
				try{
					util.mkdir(pd);
				}
				catch(Exception e) {
					t.done();
					util.error("この場所に展開できません");
				}
			}
			if (util.str2bool(d.get("suppressExpansion"))) {
				if (decompress(t)) move(t,true);
			}
			else {
				if (extract(t)) move(t,false);
				else if (decompress(t)) move(t,true);
				else {
					t.done();
					util.error("このファイルは展開できません");
				}
			}
		}
		t.done();
	}

	private static boolean extract(util.Temp t) {
		boolean done=false;
		String cmd;
		String a=util.strCast(d.get("archive"));
		String[] arg;
		boolean e=util.str2bool(d.get("encrypted"));
		String p="";
		if (e) p=util.password();

		cmd=util.which("unzip");
		if (!done&&cmd!=null) {
			arg=util.sa(cmd,"-qq","-d",t.tmpDir);
			if (e) arg=util.add(arg,"-P",p);
			arg=util.add(arg,a);
			done=util.exec(arg,true,null);
		}

		cmd=util.bsdTar();
		if (!done&&cmd!=null) {
			arg=util.sa(cmd,"-xf",a,"-C",t.tmpDir);
			done=util.exec(arg,true,null);
		}

		cmd=util.gnuTar();
		if (!done&&cmd!=null) {
			arg=util.sa(cmd,"-xf",a,"-C",t.tmpDir);
			done=util.exec(arg,true,null);
		}

		cmd=util.which("7z");
		if (!done&&cmd!=null) {
			arg=util.sa(cmd,"x","-t7z","-o"+t.tmpDir);
			if (e) arg=util.add(arg,"-p"+p);
			arg=util.add(arg,a);
			done=util.exec(arg,true,null);
		}

		return done;
	}

	private static boolean decompress(util.Temp t) {
		String a=util.strCast(d.get("archive"));
		String arc=util.concatPath(t.tmpDir,util.basename(a));
		util.hardlink(a,arc);
		boolean done=false;
		for (util.CompressType c:util.compressors) {
			String cmd=util.which(c.decompressCmd[0]);
			if (cmd==null) continue;
			ArrayList<String> ca=util.sl(c.decompressCmd);
			ca.set(0,cmd);
			ca.add(arc);
			if (util.eq(c.ext,"lz4")) {
				String ee=arc.replaceFirst("\\.lz4$","");
				if (util.eq(arc,ee)) ca.add(ee+".out");
				else ca.add(ee);
			}
			if (util.exec(ca.toArray(new String[ca.size()]),true,null)) {
				done=true;
				break;
			}
		}
		if (util.isfile(arc)) util.rm(arc);
		return done;
	}

	private static void move(util.Temp t,boolean one) {
		String[] fl=util.fileList(t.tmpDir);
		String o=util.strCast(d.get("out"));
		if (fl.length==1&&one) {
			if (util.isfile(o)) util.rm(o);
			if (util.isdir(o)) {
				String p=util.concatPath(o,fl[0]);
				if (util.isfile(p)) util.rm(p);
			}
			util.mv(util.concatPath(t.tmpDir,fl[0]),o);
		}
		else {
			try{
				if (util.isfile(o)) util.error("この場所には展開できません");
				else if (!util.isdir(o)) util.mkdir(o);
				for (String f:fl) util.mv(
					util.concatPath(t.tmpDir,f),
					util.concatPath(o,f)
				);
			}
			catch(Exception e){
				util.error("このファイルはこの場所には展開できません");
			}
		}
	}

}