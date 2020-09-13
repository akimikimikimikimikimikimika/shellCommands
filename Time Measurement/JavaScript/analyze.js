const
process=require("process"),
e=exports,

{CMHelp,CMVersion,data,error,MMSerial,MMNone,MMSpawn}=require("./lib.js");

const
Out=1,
Err=2,
Result=3,
Multiple=4;

e.argAnalyze=(d=new data())=>{
	let l=process.argv.slice(2);

	if (l.length==0) error("引数が不足しています");
	else switch (l[0]) {
		case "-h": case "help": case "-help": case "--help":
			d.mode=CMHelp; return;
		case "-v": case "version": case "-version": case "--version":
			d.mode=CMVersion; return;
	}

	var key=null,n=-1;
	for (a of l) {
		n++;
		if (a=="") continue;

		var proceed=true;
		switch (a) {
			case "-m": case "-multiple":
				d.multiple=MMSerial;
				key=Multiple; break;
			case "-o": case "-out": case "-stdout":
				key=Out; break;
			case "-e": case "-err": case "-stderr":
				key=Err; break;
			case "-r": case "-result":
				key=Result; break;
			default: proceed=false;
		}
		if (proceed) continue;

		if (a.startsWith("-")) error("不正なオプションが指定されています");
		else if (key) {
			proceed=true;
			switch (key) {
				case Out:    d.out=a;    break;
				case Err:    d.err=a;    break;
				case Result: d.result=a; break;
				case Multiple:
					switch (a) {
						case "none":
							d.multiple=MMNone; break;
						case "serial": case "":
							d.multiple=MMSerial; break;
						case "spawn": case "async": case "parallel":
							d.multiple=MMSpawn; break;
						default: proceed=false;
					}
			}
			key=null;
		}
		if (proceed) continue;

		d.command=l.slice(n);
		break;
	}

	if (d.command.length==0) error("実行する内容が指定されていません");
};