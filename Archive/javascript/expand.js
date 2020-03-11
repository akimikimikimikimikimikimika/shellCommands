let u=require("./util.js");

let d={
	"archive":"",
	"out":"",
	"outType":"same",
	"encrypted":false,
	"suppressExpansion":false
};

class Expand {

	static help() {
		helpText(`

			arc expand [archive path] [options]
			arc extract [archive path] [options]
			arc decompress [archive path] [options]

			アーカイブを展開します
			圧縮ファイルを解凍します

			オプション

			-a [string],-i [string],--archive [string],--in [string]
			 アーカイブ•圧縮ファイルを指定します

			-d [string],-o [string],--dir [string],--out [string]
			 展開する場所を指定します
			 アーカイブの場合は指定したディレクトリ内に,圧縮ファイルの場合は指定したパスに保存します
			 指定したディレクトリが存在しなければ自動的にディレクトリを生成します
			--cwd
			 カレントディレクトリに展開します
			--same
			 アーカイブファイルのあるディレクトリに展開します (デフォルト)

			-s,--suppress-expansion
			 .tar.gz など,圧縮したtarアーカイブファイルを受け取った場合に,圧縮を解凍してもtarを展開しないようにします

			-e,--encrypt
			 暗号化ファイルを展開する場合は,このオプションを使用してください
			 パスワードは後で指定します

		`)
	}

	static main() {
		analyze();
		core();
	}

}
exports.Expand=Expand;

function analyze() {

	u.switches(d,[
		[["-a","-i","--archive","--in"],["var","archive"]],
		[["-d","-o","--dir","--out"],["var","out"]],
		[["--cwd"],["write","outType","cwd"],["write","out",""]],
		[["--same"],["write","outType","same"],["write","out",""]],
		[["-e","--encrypted"],["write","encrypted",true]],
		[["-s","--suppress-expansion"],["write","suppressExpansion",true]],
	],["archive"],1);

	if (!u.isfile(d["archive"])) error("指定したパスは不正です: "+d["archive"]);

	if (d["outType"]=="cwd" && d["out"]=="") d["out"]=u.cwd;
	if (d["outType"]=="same" && d["out"]=="") d["out"]=u.getdir(d["archive"]);

}

function core() {
	let t=new u.Temp();
	if (u.isfile(d["out"])) {
		if (decompress(t)) move(t,true);
		else {
			t.done();
			u.error("このファイルはこの場所には展開できません");
		}
	}
	else if (u.isdir(d["out"])) {
		if (d["suppressExpansion"]) {
			if (decompress(t)) move(t,true);
		}
		else {
			if (extract(t)) move(t);
			else if (decompress(t)) move(t,true);
			else{
				t.done();
				u.error("このファイルは展開できません");
			}
		}
	}
	else if (u.islink(d["out"])) {
		t.done();
		u.error("リンクが不正です: "+d["out"]);
	}
	else {
		let pd=u.getdir(d["out"]);
		if (!u.isdir(pd)) {
			try{
				u.mkdir(u.getdir(d["out"]));
			}
			catch(e) {
				t.done();
				u.error("この場所に展開できません");
			}
		}
		if (d["suppressExpansion"]) {
			if (decompress(t)) move(t,true);
		}
		else {
			if (extract(t)) move(t);
			else if (decompress(t)) move(t,true);
			else {
				t.done();
				u.error("このファイルは展開できません");
			}
		}
	}
	t.done();
}

function extract(t) {
	var done=false;
	if (d["encrypted"]) let p=u.password();

	var cmd;

	cmd=u.which("unzip");
	if (!done && cmd!=null) {
		let arg=[cmd,"-qq",d["archive"],"-d",t.tmpDir];
		if (d["encrypt"]) arg.splice(1,0,"-P",p);
		if (u.exec(arg,true)==0) done=true;
	}

	cmd=u.bsdTar();
	if (!done && cmd!=null) {
		let arg=[cmd,"-xf",d["archive"],"-C",t.tmpDir];
		if (u.exec(arg,true)==0) done=true;
	}

	cmd=u.gnuTar();
	if (!done && cmd!=null) {
		let arg=[cmd,"-xf",d["archive"],"-C",t.tmpDir];
		if (u.exec(arg,true)==0) done=true;
	}

	cmd=u.which("7z");
	if (!done && cmd!=null) {
		let arg=[cmd,"x","-t7z",d["archive"],"-o"+t.tmpDir];
		if (d["encrypted"]) arg.push("-p"+p);
		if (u.exec(arg,true)==0) done=true;
	}

	return done;
}

function decompress(t) {
	let arc=u.concatPath(t.tmpDir,u.basename(d["archive"]));
	u.hardlink(d["archive"],arc);
	var done=false;
	for (c of u.compressors) {
		let cmd=u.which(c.decompressCmd[0]);
		if (cmd==null) continue;
		c.decompressCmd[0]=cmd;
		c.decompressCmd.push(arc);
		if (c.ext=="lz4") {
			let a=arc.replace(/\.lz4$/,"");
			if (a==arc) c.decompressCmd.push(a+".out");
			else c.decompressCmd.push(a);
		}
		if (u.exec(c.decompressCmd,true)==0) {
			done=true;
			break;
		}
	}
	if (u.isfile(arc)) u.rm(arc);
	return done;
}

function move(t,one=false) {
	let fl=u.fileList(t.tmpDir);
	if (fl.length==1 && one) {
		if (u.isfile(d["out"])) u.rm(d["out"]);
		if (u.isdir(d["out"])) {
			let p=u.concatPath(d["out"],fl[0]);
			if (u.isfile(p)) u.rm(p);
		}
		u.mv(fl[0],d["out"]);
	}
	else {
		try {
			if (u.isfile(d["out"])) u.error("この場所には展開できません");
			else if (!u.isdir(d["out"])) u.mkdir(d["out"]);
			for (f of fl) u.mv(u.concatPath(t.tmpDir,f),u.concatPath(d["out"],f));
		}
		catch(e){u.error("このファイルはこの場所には展開できません");}
	}
}