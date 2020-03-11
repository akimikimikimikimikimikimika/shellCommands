let u=require("./util.js");

let d={
	"archive":null,
	"inFile":[],
	"type":"zip",
	"mode":"default",
	"level":"default",
	"format":"default",
	"single":false,
	"excludeHiddenFiles":true,
	"encrypted":false,
	"encryptType":"default",
	"prior":null
};

class Create {

	static help(){
		u.helpText(`

			arc create [archive path] [options] [input file paths]...
			arc compress [input file path]... [options]

			アーカイブを生成します
			生成するにあたり,コンピュータで利用可能な方法を選択して実行します
			オプションによってはいずれの方法でも生成できない場合があり,その時にはエラーを返します

			オプション

			[input file path]...
			-i [string]...,--in [string]...
			 アーカイブに含めるファイルを指定します

			[archive path]
			-a [string],-o [string],--archive [string],--out [string]
			 生成するアーカイブファイルの保存場所を指定します

			-t [enum],--type [enum]
			 アーカイブの種類を指定します
			 zip  zipアーカイブ (--zip,デフォルト)
			 tar  tarアーカイブ (--tar)
			 7z   7zアーカイブ (--7z)
			 この他にも対応しているフォーマットがあります。詳しくは後述

			-p [enum],--prior [enum]
			 生成方法を指定します (シェルコマンド)
			 アーカイブの種類によって利用可能な生成方法は異なります (後述)
			 指定したオプション次第では指定した方法では生成されないことがあります

			-#,-l [int],--level [int]
			 圧縮率を指定します
			 1~9 の整数で指定し,数値が大きいと圧縮率が高くなります
			 デフォルトは6
			 ※ tarオプションでは例外があります
			  -m lz4 の場合は 1~12 で指定し,デフォルトは1です
			  -m zstd の場合は 1~19 で指定し,デフォルトは3です
			  -m stored の場合はこのオプションは無効です
			  -m compress の場合はこのオプションは無効です

			zipアーカイブのオプション

			 生成方法 (優先順)
			  7z  7zコマンド
			  zip zipコマンド
			  tar tarコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  store,copy  非圧縮 (デフォルト)
			  gz,deflate  Deflate圧縮
			  bz,bzip2    BZIP2圧縮
			  xz,lzma     LZMA圧縮

			 -e,--encrypt [enum]
			  アーカイブを暗号化します
			  パスワードは後で指定します
			  [enum] に次のうちいずれかの値を指定した暗号化の方法を指定できます
			   zipcrypto ZIP標準の暗号システム (デフォルト)
			   aes128    AES128暗号
			   aes192    AES192暗号
			   aes256    AES256暗号

			tarアーカイブのオプション

			 生成方法 (優先順)
			  tar    tarコマンド
			  gnutar gtarコマンド
			  7z     7zコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  store,copy  非圧縮 (.tar,デフォルト)
			  gz,deflated Deflate圧縮 (.tar.gz)
			  bz,bzip2    BZIP2圧縮 (.tar.bz2)
			  xz,lzma     LZMA圧縮 (.tar.xz)
			  lzip        LZIP圧縮 (.tar.lz)
			  lzop        LZOP圧縮 (.tar.lzop)
			  lz4         LZ4圧縮 (.tar.lz4)
			  brotli      Brotli圧縮 (.tar.br)
			  zstd        Zstandard圧縮 (.tar.zst)

			 -f [enum],--format [enum]
			  tarのフォーマットを指定します
			  cpio  cpioフォーマット
			  shar  sharフォーマット
			  ustar ustarフォーマット
			  gnu   GNU tarフォーマット
			  pax   paxフォーマット (デフォルト)

			 -s,--single
			  -i で単一のファイルを指定した場合には,tarでアーカイブにせず圧縮ファイルを生成します。
			  例えば, -m gz とした場合, file は file.tar.gz ではなく file.gz になります。
			  -m store の場合はファイルが単純にコピーされます。

			 --include-hidden-files
			  macOSの隠しファイルもアーカイブします
			  これらにはFinderで使用されるデータも含み,展開時にそれらが復元されますが,他のプラットフォームでは可視ファイルとして展開されます

			7zアーカイブのオプション

			 生成方法 (優先順)
			  7z  7zコマンド
			  tar tarコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  stored,copy 非圧縮
			  gz,deflate  Deflate圧縮
			  bz,bzip2    BZIP2圧縮
			  xz,lzma     LZMA圧縮
			  lzma2       LZMA2圧縮 (デフォルト)

			 -e,--encrypt
			  アーカイブを暗号化します
			  パスワードは後で指定します

			 -e he,--encrypt he
			  暗号化するにあたって,ヘッダも暗号化します
			  これにより, arc paths などでファイルの中身を表示できなくなります

			-tオプションで指定可能な値
			 zip   zipアーカイブ (--zip)
			 tar   tarアーカイブ (--tar)
			 7z    7zアーカイブ (--7z)

			 gzip  Gzip      (-t tar -m gzip -s と同等)
			 bzip2 Bzip2     (-t tar -m bzip2 -s と同等)
			 xz    xz        (-t tar -m xz -s と同等)
			 lzip  Lzip      (-t tar -m lzip -s と同等)
			 lzop  Lzop      (-t tar -m lzop -s と同等)
			 lz4   Lz4       (-t tar -m lz4 -s と同等)
			 br    Brotli    (-t tar -m brotli -s と同等)
			 zstd  Zstandard (-t tar -m zstd -s と同等)

			 --gzip,--bzip2,... などでも指定可能

		`);
	}

	static main(a){

		analyze(a);

		switch (d["type"]) {
			case "zip": Zip.run(); break;
			case "tar": Tar.run(); break;
			case "7z": Sz.run(); break;
			default: error("アーカイブタイプが不正です: "+d["type"]);
		}

	}

}
exports.Create=Create;

function analyze(a) {

	var i;
	switch (a) {
		case "create": i=["archive","inFile"]; break;
		case "compress": i=["inFile"]; break;
	}

	let p=[
		[["-a","-o","--archive","--out"],["var","archive"]],
		[["-i","--in"],["var","inFile",true]],
		[["-t","--type"],["var","type"]],
		[["-m","--mode"],["var","mode"]],
		[["-l","--level"],["var","level"]],
		[["-#"],["write","level"]],
		[["-f","--format"],["var","format"]],
		[["-p","--prior"],["var","prior"]],
		[["-s","--single"],["write","single",true]],
		[["--include-hidden-files"],["write","excludeHiddenFiles",false]],
		[
			["-e","--encrypt"],
			["write","encrypted",true],
			["var","encryptType"]
		],
		[["--zip"],["write","type","zip"]],
		[["--tar"],["write","type","tar"]],
		[["--7z"],["write","type","7z"]]
	];

	for (c of u.compressors) {
		let l=c.keys.map(k=>"--"+k);
		p.push([l,["write","type",c.keys[0]]]);
	}

	u.switches(d,p,i);

	for (c of u.compressors) {
		var match=false;
		for (k of c.keys) if (k==d["type"]) match=true;
		if (match){
			d["type"]="tar";
			d["mode"]=c.keys[0];
			d["single"]=true;
			break;
		}
	}

	let ad=d["archive"];
	if (ad!=null) {
		while (!u.isdir(ad)) ad=u.getdir(ad);
		if (!u.writable(ad)) u.error("この場所には保存できません");
	}

}

class Zip {

	static run7z=null;
	static runZip=null;
	static runTar=null;

	static run() {

		this.run7z=u.which("7z");
		this.runZip=u.which("zip");
		this.runTar=u.bsdTar();

		let m=this.modeAnalyze();
		let l=u.levelCast(d["level"]);
		let e=this.encryptionAnalyze();
		archiveAnalyze("zip");

		let p=d["prior"];
		if (p=="7z" && this.run7z!=null) this.szCmd(this.run7z,m[0],l[1],e[0]);
		else if (p=="zip" && this.runZip!=null) this.zipCmd(this.runZip,m[1],l[0]);
		else if (p=="tar" && this.runTar!=null) this.tarCmd(this.runTar,m[2],e[2]);
		else if (this.run7z!=null) this.szCmd(this.run7z,m[0],l[1],e[0]);
		else if (this.runZip!=null) this.zipCmd(this.runZip,m[1],l[0]);
		else if (this.runTar!=null) this.tarCmd(this.runTar,m[2],e[2]);
		else error("条件に合致したzipを生成する手段が見つかりませんでした");

	}

	static modeAnalyze() {
		let ms=d["mode"];

		var m;
		switch (ms) {
			case "store":case "copy":case "default":
				m=["Copy","store","store"]; break;
			case "gz":case "deflate":
				m=["Deflate","deflate","deflate"]; break;
			case "deflate64":
				m=["Deflate64","deflate","deflate"]; break;
			case "bz":case "bzip2":
				m=["BZip2","bzip2",""];
				this.runTar=null; break;
			case "xz":case "lzma":
				m=["LZMA","",""];
				this.runZip=this.runTar=null; break;
			case "ppmd":
				m=["PPMd","",""];
				this.runZip=this.runTar=null; break;
			default:
				m=["Copy","store","store"];
		}

		return m;
	}

	static encryptionAnalyze() {
		if (d["encrypted"]) {
			var e;
			switch (d["encryptType"]) {
				case "zipcrypto":case "default":
					e=["ZipCrypto","-e","zipcrypt"]; break;
				case "aes128":
					e=["AES128","","aes128"];
					this.runZip=null; break;
				case "aes192":
					e=["AES192","","aes256"];
					this.runZip=null; break;
				case "aes256":
					e=["AES256","","aes256"];
					this.runZip=null; break;
				default:
					e=["ZipCrypto","-e","zipcrypt"];
			}
		}
		else e=[null,null,null];

		return e;
	}

	static szCmd(cmd,m,l,e) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive");
		if (d["inFile"].length>0) {
			var arg=[cmd,"a","-tzip",ap,"-bso0","-bsp0","-sas","-xr!.DS_Store","-mx="+l,"-mm="+m];
			if (d["encrypted"]) {
				p=u.password();
				arg.push("-mem="+e,"-p"+p);
			}
			arg=arg.concat(d["inFile"]);
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("7zでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir)
			tmp.blank();
			u.exec([cmd,"a","-tzip",ap,".blank"],true);
			u.exec([cmd,"d","-tzip",ap,".blank"],true);
			u.chdir(cwd);
		}
		u.mv(ap,d["archive"]);
		tmp.done();
	}

	static zipCmd(cmd,m,l) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive");
		if (d["inFile"].length>0) {
			let arg=[cmd,ap,"-qr"].concat(d["inFile"]);
			if (m=="deflate" || m=="bzip2") arg.push("-"+l);
			if (d["encrypted"]) arg.push("-p",u.password());
			arg.push("-x",".DS_Store");
			arg.push("-Z",m);
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("zipでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir);
			tmp.blank();
			u.exec([cmd,"-q",ap,".blank"],true);
			u.exec([cmd,"-dq",ap,".blank"],true);
			u.chdir(u.cwd);
		}
		u.mv(ap,d["archive"]);
		tmp.done();
	}

	static tarCmd(cmd,m,e) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive.zip");

		var arg=[cmd,"-a","-cf",ap,"--options","zip:compression="+m];
		if (d["encrypted"]) arg[5]+=",zip:encryption="+e;
		arg.push("--exclude",".DS_Store");

		if (d["inFile"].length>0) {
			arg=arg.concat(d["inFile"]);
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("tarでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir);
			tmp.blank();
			arg.push("--exclude",".blank",".blank");
			u.exec(arg,true);
			u.chdir(cwd);
		}
		u.mv(ap,d["archive"]);
		tmp.done();
	}

}

class Tar {

	static runBTar=null;
	static runGTar=null;
	static run7z=null;

	static run() {

		this.runBTar=u.bsdTar();
		this.runGTar=u.gnuTar();
		this.run7z=u.which("7z");

		let m=this.modeAnalyze();
		let l=u.levelCast(d["level"]);
		let f=this.formatAnalyze();

		if (d["inFile"].length==1 && d["single"]) {
			let sf=d["inFile"][0];
			if (u.isfile(sf)) {
				archiveAnalyze(m.ext);
				this.comp(sf,m,l);
				return null;
			}
		}

		archiveAnalyze(m.tarExt);

		let p=d["prior"];
		if ((p=="bsdtar" || p=="tar") && this.runBTar!=null) this.tarCmd(this.runBTar,m,l,f);
		else if (p=="gnutar" && this.runGTar!=null) this.tarCmd(this.runGTar,m,l,f);
		else if (p=="7z" && this.run7z!=null) this.szCmd(this.run7z,m,l);
		else if (this.runBTar!=null) this.tarCmd(this.runBTar,m,l,f);
		else if (this.runGTar!=null) this.tarCmd(this.runGTar,m,l,f);
		else if (this.run7z!=null) this.szCmd(this.run7z,m,l);
		else error("条件に合致したtarを生成する手段が見つかりませんでした");

	}

	static modeAnalyze() {
		let ms=d["mode"];
		var m=new u.CompressType([[],"tar",null,"",null]);

		if (ms!="store" && ms!="copy" && ms!="default") {
			for (c of u.compressors) {
				var match=false;
				for (k of c.keys) if (k==ms) match=true;
				if (match) {
					m=c;
					break;
				}
			}
		}

		if (m.compressCmd!=null) {
			let c=u.which(m.compressCmd[0]);
			if (c!=null) m.compressCmd[0]=c;
			else error(`コマンド "${m.compressCmd[0]}" が利用できないため実行できません`);
		}

		return m;
	}

	static formatAnalyze() {
		let fs=d["format"];

		var f;
		switch (fs) {
			case "default":
				f="pax"; break;
			case "cpio":
				f="cpio";
				this.runGTar=null; break;
			case "shar":
				f="shar";
				this.runGTar=null; break;
			case "ustar":
				f="ustar"; break;
			case "gnu":
				f="gnu";
				this.runBTar=null; break;
			case "pax":
				f="pax"; break;
			default:
				f="pax";
		}

		return f;
	}

	static szCmd(cmd,m,l) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive");
		if (d["inFile"].length>0) {
			var arg=[cmd,"a","-ttar",ap,"-bso0","-bsp0","-sas"];
			if (d["excludeHiddenFiles"]) arg.push("-xr!.DS_Store");
			arg=arg.concat(d["inFile"]);
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("7zでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir);
			tmp.blank();
			u.exec([cmd,"a","-ttar",ap,".blank"],true);
			u.exec([cmd,"d","-ttar",ap,".blank"],true);
			u.chdir(u.cwd);
		}
		if (m.compressCmd!=null) {
			this.compress(m.compressCmd,l,ap,tmp);
			u.mv(ap+"."+m.ext,d["archive"]);
		}
		else u.mv(ap,d["archive"]);
		tmp.done();
	}

	static tarCmd(cmd,m,l,f) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive");

		var arg=[cmd,"-cf",ap,"--format",f];
		if (d["excludeHiddenFiles"]) {
			arg.push("--exclude",".DS_Store");
			u.env["COPYFILE_DISABLE"]="1";
		}

		if (d["inFile"].length>0){
			arg=arg.concat(d["inFile"])
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("tarでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir);
			tmp.blank();
			arg.push("--exclude",".blank",".blank");
			u.exec(arg,true);
			u.chdir(u.cwd);
		}
		if (m.compressCmd!=null) {
			this.compress(m.compressCmd,l,ap,tmp);
			u.mv(ap+"."+m.ext,d["archive"]);
		}
		else mv(ap,d["archive"]);
		tmp.done();
	}

	static comp(f,m,l) {
		if (m.compressCmd!=null) {
			let fn=u.basename(f);
			let tmp=new u.Temp();
			let tf=u.concatPath(tmp.tmpDir,fn);
			u.hardlink(f,tf);
			this.compress(m.compressCmd,l,tf,tmp);
			u.mv(tf+"."+m.ext,d["archive"]);
			tmp.done();
		}
		else u.cp(f,d["archive"]);
	}

	static compress(m,l,ap,tmp) {
		let cmd=u.basename(m[0]);
		if (cmd=="lz4") m.push("-"+l[2]);
		else if (cmd=="zstd") m.push("-"+l[3]);
		else if (cmd!="compress") m.push("-"+l[0]);
		m.push(ap);
		if (cmd=="lz4") m.push(ap+".lz4");
		if (u.exec(m,true)!=0) {
			tmp.done();
			u.error(`コマンド "${cmd}" でエラーが発生しました`);
		}
	}

}

class Sz {

	static run7z=null;
	static runTar=null;

	static run() {

		this.run7z=u.which("7z");
		this.runTar=u.bsdTar();

		let m=this.modeAnalyze();
		let l=u.levelCast(d["level"]);
		let he=false;
		if (d["encrypted"]) {
			this.runTar=false;
			if (d["encryptType"]=="he") he=true;
		}
		archiveAnalyze("7z");

		let p=d["prior"];
		if (p=="7z" && this.run7z!=null) this.szCmd(this.run7z,m,l[1],he);
		else if (p=="tar" && this.runTar!=null) this.tarCmd(this.runTar);
		else if (this.run7z!=null) this.szCmd(this.run7z,m,l[1],he);
		else if (this.runTar!=null) this.tarCmd(this.runTar);
		else error("条件に合致した7zを生成する手段が見つかりませんでした");

	}

	static modeAnalyze() {

		var m;
		switch (d["mode"]) {
			case "store":case "copy": m="Copy"; break;
			case "gz":case "deflate": m="Deflate"; break;
			case "bz":case "bzip2": m="BZip2"; break;
			case "xz":case "lzma": m="LZMA"; break;
			case "lzma2":case "default": m="LZMA2"; break;
			default: m="LZMA2";
		}

		return m;

	}

	static szCmd(cmd,m,l,he) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive");
		if (d["inFile"].length>0) {
			var arg=[cmd,"a","-t7z",ap,"-bso0","-bsp0","-sas","-xr!.DS_Store","-mx="+l,"-m0="+m];
			if (d["encrypted"]) {
				let p=u.password();
				arg.push("-p"+p);
				if (he) arg.push("-mhe=on");
			}
			arg=arg.concat(d["inFile"]);
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("7zでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir);
			tmp.blank();
			u.exec([cmd,"a","-t7z",ap,".blank"],true);
			u.exec([cmd,"d","-t7z",ap,".blank"],true);
			u.chdir(u.cwd);
		}
		u.mv(ap,d["archive"]);
		tmp.done();
	}

	static tarCmd(cmd) {
		let tmp=new u.Temp();
		let ap=u.concatPath(tmp.tmpDir,".archive.7z");

		var arg=[cmd,"-a","-cf",ap];
		arg.push("--exclude",".DS_Store");

		if (d["inFile"].length>0) {
			arg=arg.concat(d["inFile"]);
			if (u.exec(arg,true)!=0) {
				tmp.done();
				u.error("tarでエラーが発生しました");
			}
		}
		else {
			u.chdir(tmp.tmpDir);
			tmp.blank();
			arg.push("--exclude",".blank",".blank");
			u.exec(arg,true);
			u.chdir(u.cwd);
		}
		u.mv(ap,d["archive"]);
		tmp.done();
	}

}

function archiveAnalyze(ext) {
	if (ext!="") ext="."+ext;
	var f;
	if (d["inFile"].length==1) f=d["inFile"][0]+ext;
	else f="Archive"+ext;
	if (d["archive"]==null) {
		if (!u.writable(u.cwd)) error("カレントディレクトリにアーカイブを書き出すことができません");
		d["archive"]=f;
	}
	if (u.isdir(d["archive"])) d["archive"]=u.concatPath(d["archive"],f);
}