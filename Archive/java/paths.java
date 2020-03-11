import java.util.*;

public class paths {

	private static Map<String,String> d = util.cast(util.map(
		"archive",null
	));

	public static void help() {
		util.helpText(
			"",
			"arc paths [archive path] [options]",
			"arc list [archive path] [options]",
			"",
			"アーカイブに含まれるファイルの一覧を表示します",
			"",
			"オプション",
			"",
			"[archive path]",
			"-a [string],-i [string],--archive [string],--in [string]",
			" アーカイブファイルを指定します",
			"",
			"-v [int],--verbose [int]",
			" コマンドの出力レベルを指定します",
			"  -v 0, -s, --silence",
			"   コマンド実行時にエラーがあっても出力しません。",
			"  -v 1 (デフォルト)",
			"   コマンド実行時にエラーがある場合にはエラーを標準エラー出力に出力します。",
			"  -v 2, -v",
			"   コマンド実行時の作業内容を出力します。",
			""
		);
	}

	public static Object main() {

		util.switches(util.cast(d),util.sa3(
			util.sa2(
				util.sa("-a","-i","--archive","--in"),
				util.sa("var","archive")
			),
			util.sa2(
				util.sa("-v","--verbose"),
				util.sa("write","verbose","2"),
				util.sa("var","verbose")
			),
			util.sa2(
				util.sa("-s","--silence"),
				util.sa("write","verbose","0")
			)
		),util.sa("archive"),1);

		if (!util.isfile(d.get("archive"))) util.error("パラメータが不正です: "+d.get("archive"));
		if (util.verbose>1) verboseInfo();
		if (cmd()) return null;
		util.error("このファイルの内容を表示できません");
		return null;

	};

	private static void verboseInfo() {

		util.println(
			"ステータス:",
			" カレントディレクトリ:",
			"  "+util.cwd,
			" 入力ファイル: "+util.strCast(d.get("archive"))
		);

	}

	private static boolean cmd() {
		String t;
		t=util.bsdTar();
		if (t!=null) if (util.exec(util.sa(t,"-tf",d.get("archive")),false,null)) return true;
		t=util.gnuTar();
		if (t!=null) if (util.exec(util.sa(t,"-tf",d.get("archive")),false,null)) return true;
		return false;
	}

}