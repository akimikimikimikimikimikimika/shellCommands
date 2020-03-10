let
fs=require("fs"),
os=require("os"),
pt=require("path"),
process=require("process"),
child_process=require("child_process"),
e=exports;

e.id=process.pid;
e.cwd=process.cwd();
e.env=process.env;
e.chdir=process.chdir;
e.mv=fs.renameSync;
e.cp=fs.copyFileSync;
e.rm=path=>{
	let s=fs.statSync(path);
	if (!s.isDirectory()) fs.unlinkSync(path);
	else {
		e.fileList(path).forEach(i=>e.rm(pt.join(path,i)));
		fs.rmdirSync(path);
	}
};
e.fileList=fs.readdirSync;
e.which=cmd=>{
	var r;
	r=e.getData(["which",cmd]);
	if (r!=null && r!="") return r;
	r=e.getData(["where",cmd]);
	if (r!=null && r!="") return r;
	return null;
};
e.isfile=path=>{
	if (!fs.existsSync(path)) return false;
	return fs.statSync(path).isFile();
};
e.isdir=path=>{
	if (!fs.existsSync(path)) return false;
	return fs.statSync(path).isDirectory();
};
e.islink=path=>{
	if (!fs.existsSync(path)) return false;
	return fs.statSync(path).isSymbolicLink();
};
e.mkdir=path=>fs.mkdirSync(path,{recursive:true});
e.basename=pt.basename;
e.hardlink=fs.linkSync;
e.getdir=path=>fs.realpathSync(pt.dirname(path));
e.concatPath=pt.join;
e.writable=path=>fs.statSync(path).mode&fs.constants.S_IWUSR!=0;

class Temp {
	tmpDir=null;
	constructor() {
		let td=os.tmpdir();
		e.chdir(td);
		this.tmpDir=e.concatPath(td,fs.mkdtempSync("archive"+process.pid));
		e.chdir(e.cwd);
	}
	blank() {
		fs.writeFileSync(concatPath(this.tmpDir,".blank"));
	}
	done(){
		e.rm(this.tmpDir);
	}
}
e.Temp=Temp;

e.password=()=>{
	try{
		if (!e.which("read")) throw Error();
		var p="";
		while (p=="") p=child_process.execSync('read -s -p "パスワード: " text ; echo>&2 ; echo $text',{env:e.env,stdio:["inherit","pipe","inherit"],shell:true}).toString().trimRight();
		return p;
	}catch(ex){e.error("パスワードが指定できません");}
};

e.error=(text)=>{
	console.error(text);
	process.exit(1);
};

e.exec=(cmd,quiet=false)=>{
	let c=cmd.shift();
	let p=child_process.spawnSync(c,cmd,{env:e.env,stdio:["inherit","ignore","ignore"]});
	return p.status;
};

e.getData=(cmd)=>{
	let c=cmd.shift();
	let p=child_process.spawnSync(c,cmd,{env:e.env,stdio:["inherit","pipe","ignore"]});
	if (p.status==0) return p.stdout.toString().trimRight();
	else return null;
};

e.bsdTar=()=>{
	let l=[e.which("bsdtar"),e.which("tar")];
	for (t of l) if (t!=null) {
		let v=e.getData([t,"--version"]);
		if (/bsdtar/.test(v)) return t;
	}
	return null;
};

e.gnuTar=()=>{
	let l=[e.which("gnutar"),e.which("tar"),e.which("gtar")];
	for (t of l) if (t!=null) {
		let v=e.getData([t,"--version"]);
		if (/GNU tar/.test(v)) return t;
	}
	return null;
};

e.helpText=(text)=>{
	text=text.replace(/\n\t+/g,"\n").replace(/^\r?\n/g,"").replace(/\r?\n\r?\n$/g,"");
	console.log(text);
}

e.levelCast=(val)=>{
	var l;
	if (/^[1-9]$/.test(val)) l=[val,(Math.ceil(val/2)*2-1).toString(),val,val];
	else if (/^1[0-9]$/.test(val)) {
		l=["9","9",val,val];
		if (val>12) l[2]="12";
	}
	else if (val=="default") l=["6","5","1","3"];
	else l=["6","5","1","3"];
	return l;
};

class CompressType {
	constructor(data) {
		this.keys=data[0];
		this.compressCmd=data[2];
		this.decompressCmd=data[4];
		this.tarExt=data[1];
		this.ext=data[3];
	}
	static each(l) {
		return l.map(a=>new CompressType(a));
	}
}
e.CompressType=CompressType;

e.compressors=CompressType.each([
	[["z","Z","compress","lzw"],"tar.Z",["compress","-f"],"Z",["uncompress","-f"]],
	[["gz","gzip","deflate"],"tgz",["gzip","-f","-k"],"gz",["gzip","-d","-f"]],
	[["bz","bz2","bzip","bzip2"],"tbz2",["bzip2","-z","-f","-k"],"bz2",["bzip2","-d"]],
	[["xz","lzma"],"txz",["xz","-z","-f","-k","-T0"],"xz",["xz","-d","-f"]],
	[["lz","lzip"],"tlz",["lzip","-f","-k"],"lz",["lzip","-d","-f"]],
	[["lzo","lzop"],"tar.lzo",["lzop","-f"],"lzo",["lzop","-d","-f"]],
	[["br","brotli"],"tar.br",["brotli","-f"],"br",["brotli","-d","-f"]],
	[["zst","zstd","zstandard"],"tar.zst",["zstd","-f","-T0"],"zst",["zstd","-d","-f","-T0"]],
	[["lz4"],"tar.lz4",["lz4","-f"],"lz4",["lz4","-d","-f"]]
]);

e.switches=(d,params,inputs,max=0)=>{

	let args=process.argv;

	var
	va=null,
	multiple=false,
	sharp=null,
	step=1,

	noSwitches=false;

	for (a of args.slice(3)) {

		var match=false;

		if (a=="--") noSwitches=match=true;

		if (!noSwitches) {

			for (cmd of params) {
				for (p of cmd[0]) {
					if (p=="-#") {
						let s=a.match(/^\-([0-9]+)$/);
						if (s!=null) {
							match=true;
							sharp=s[1];
						}
					}
					else if (p==a) match=true;
					if (match) break;
				}
				if (match) {
					va=null;
					for (act of cmd.slice(1)) {
						if (act[0]=="var") {
							va=act[1];
							multiple=act.length==3;
						}
						if (act[0]=="write") {
							if (sharp!=null) {
								d[act[1]]=sharp;
								sharp=null;
							}
							else d[act[1]]=act[2];
						}
					}
					break;
				}
			}

			if (!match) if (/^\-+/.test(a)) error("このスイッチは無効です: "+a);

			if (!match) if (va!=null) {
				if (multiple) d[va].push(a);
				else {
					d[va]=a;
					va=null;
				}
				match=true;
			}

		}

		if (!match) {
			if (max>0 && step>max) error("パラメータが多すぎます");
			let i=Math.min(step,inputs.length)-1;
			if (d[inputs[i]] instanceof Array) d[inputs[i]].push(a);
			else d[inputs[i]]=a;
			step+=1;
		}

	}

};