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
			""
		);
	}

	public static Object main() {

		util.switches(util.cast(d),util.sa3(
			util.sa2(util.sa("-a","-i","--archive","--in"),util.sa("var","archive"))
		),util.sa("archive"),1);

		if (!util.isfile(d.get("archive"))) util.error("パラメータが不正です: "+d.get("archive"));
		if (cmd()) return null;
		util.error("このファイルの内容を表示できません");
		return null;

	};

	private static boolean cmd() {
		String t;
		t=util.bsdTar();
		if (t!=null) {
			String l=util.getData(util.sa(t,"-tf",d.get("archive")));
			if (l!="") {
				System.out.println(l);
				return true;
			}
		}
		t=util.gnuTar();
		if (t!=null) {
			String l=util.getData(util.sa(t,"-tf",d.get("archive")));
			if (l!="") {
				System.out.println(l);
				return true;
			}
		}
		return false;
	}

}