using System; // Array

using CM = lib.CM;
using MM = lib.MM;

public class analyze {

	private enum Key { stdout,stderr,result,multiple };

	public static void argAnalyze(ref lib.Data d,string[] l) {
		if (l.Length==0) lib.error("引数が不足しています");
		else switch (l[0]) {
			case "-h": case "help": case "-help": case "--help": d.mode=CM.help; break;
			case "-v": case "version": case "-version": case "--version": d.mode=CM.version; break;
		}

		Key? key=null;
		int n=-1;
		foreach (var a in l) {
			n++;
			if (a.Length==0) continue;

			bool proceed=true;
			switch (a) {
				case "-m": case "-multiple":
					d.multiple=MM.serial;
					key=Key.multiple; break;
				case "-o": case "-out": case "-stdout":
					key=Key.stdout; break;
				case "-e": case "-err": case "-stderr":
					key=Key.stderr; break;
				case "-r": case "-result":
					key=Key.result; break;
				default: proceed=false; break;
			}
			if (proceed) continue;

			if (a.StartsWith("-")) lib.error("不正なオプションが指定されています");
			else if (key!=null) {
				proceed=true;
				switch (key) {
					case Key.stdout: d.stdout=a; break;
					case Key.stderr: d.stderr=a; break;
					case Key.result: d.result=a; break;
					case Key.multiple:
						switch (a) {
							case "none":
								d.multiple=MM.none; break;
							case "serial": case "":
								d.multiple=MM.serial; break;
							case "spawn": case "parallel":
								d.multiple=MM.spawn; break;
							case "thread":
								d.multiple=MM.thread; break;
							default: proceed=false; break;
						}
						break;
				}
				key=null;
			}
			if (proceed) continue;

			d.command=new string[l.Length-n];
			Array.Copy(l,n,d.command,0,l.Length-n);
			break;
		}

		if (d.command.Length==0) lib.error("実行する内容が指定されていません");
	}

}