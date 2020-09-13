import java.util.Arrays;

public class analyze {

	private enum Key { out, err, result, multiple };

	public static void argAnalyze(lib.Data d,String[] l) {
		if (l.length==0) lib.error("引数が不足しています");
		else switch (l[0]) {
			case "-h": case "help": case "-help": case "--help":
				d.mode=lib.CM.help; return;
			case "-v": case "version": case "-version": case "--version":
				d.mode=lib.CM.version; return;
		}

		Key key=null;
		int n=-1;
		for (String a:l) {
			n++;
			if (a.equals("")) continue;

			boolean proceed=true;
			switch (a) {
				case "-m","-multiple":
					d.multiple=lib.MM.serial;
					key=Key.multiple; break;
				case "-o","-out","-stdout":
					key=Key.out; break;
				case "-e","-err","-stderr":
					key=Key.err; break;
				case "-r","-result":
					key=Key.result; break;
				default: proceed=false;
			}
			if (proceed) continue;

			if (a.startsWith("-")) lib.error("不正なオプションが指定されています");
			else if (key!=null) {
				proceed=true;
				switch (key) {
					case out:    d.out=a; break;
					case err:    d.err=a; break;
					case result: d.result=a; break;
					case multiple:
						switch (a) {
							case "none":
								d.multiple=lib.MM.none; break;
							case "serial","":
								d.multiple=lib.MM.serial; break;
							case "spawn","parallel":
								d.multiple=lib.MM.spawn; break;
							case "thread":
								d.multiple=lib.MM.thread; break;
							default: proceed=false;
						}
				}
				key=null;
			}
			if (proceed) continue;

			d.command=Arrays.copyOfRange(l,n,l.length);
			break;
		}

		if (d.command.length==0) lib.error("実行する内容が指定されていません");
	}

}