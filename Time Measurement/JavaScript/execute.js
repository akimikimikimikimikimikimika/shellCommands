const
cp=require("child_process"),
fs=require("fs"),
exit=require("process").exit,
now=require("perf_hooks").performance.now,
EOL=require("os").EOL,

{MMNone,MMSerial,MMSpawn,data,clean}=require("./lib.js");

exports.main=async (rd=new data())=>{
	d=rd;
	o=co2f(d.out);
	e=co2f(d.err);
	r=ro2f(d.result);

	switch (d.multiple) {
		case MMNone:   single();      break;
		case MMSerial: serial();      break;
		case MMSpawn:  await spawn(); break;
	}

	fs.writeSync(r,res);
	fs.closeSync(r);
	exit(ec??1);
}

var d,o,e,r;
var ec=0,res="";

function single() {
	let p=new SP(d.command);

	let st=now();
	p.run();
	let en=now();

	res=clean(`
		time: ${descTime(en-st)}
		process id: ${p.pid}
		${p.descEC()}
	`);
	ec=p.ec;
}

function serial() {
	let pl=SP.multiple(d.command);
	var lp=pl[pl.length-1];

	let st=now();
	for (p of pl) {
		p.run();
		if (p.ec!=0) {
			lp=p;
			break;
		}
	}
	let en=now();

	res=[
		"time: "+descTime(en-st),
		...pl.map(p=>`process${p.order} id: ${p.pid<0?"N/A":p.pid}`),
		p.descEC(),""
	].join(EOL);
	ec=lp.ec;
}

async function spawn() {
	let pl=SP.multiple(d.command);

	let st=now();
	await Promise.all(pl.map(p=>p.start()));
	let en=now();

	res=[
		`time: ${descTime(en-st)}`,
		...pl.flatMap(p=>{
			if (p.ec>ec) ec=p.ec;
			return [`process${p.order} id: ${p.pid}`,p.descEC()];
		}),""
	].flat().join("\n");
}

class SP {
	args=[];

	order=0;
	pid=-1;
	ec=0;
	signal=null;
	descEC() {
		return this.ec==null?"terminated due to "+(this.signal??"signal"):"exit code: "+this.ec;
	}

	constructor(args) {
		if (typeof(args)=="string") this.args=[args,{stdio:["inherit",o,e],shell:true}];
		else {
			let f=args.shift();
			this.args=[f,args,{stdio:["inherit",o,e]}];
		}
	}
	static multiple(commands) {
		var n=1,c;
		let l=[];
		for (c of commands) {
			let p=new SP(c);
			p.order=n;
			l.push(p);
			n++;
		}
		return l;
	}
	start() {
		let t=this;
		return new Promise(resolve=>{
			let p=cp.spawn(...t.args);
			t.pid=p.pid;
			p.on("exit",(ec,signal)=>{
				t.ec=ec;
				t.signal=signal;
				resolve();
			});
		});
	}
	run() {
		let s=cp.spawnSync(...this.args);
		this.pid=s.pid;
		this.ec=s.status;
		this.signal=s.signal;
	}
}



function co2f(d) {
	switch (d) {
		case "inherit": return "inherit";
		case "discard": return "ignore";
		default:        return fh(d);
	}
}

function ro2f(d) {
	switch (d) {
		case "stdout": return 1;
		case "stderr": return 2;
		default:       return fh(d);
	}
}

let opened={};
function fh(path) {
	if (opened[path]) return opened[path];
	try{
		let io=fs.openSync(path,"a");
		opened[path]=io;
		return io;
	}
	catch(e) { error("指定したパスには書き込みできません: "+path); }
}



function descTime(msec) {
	var t="";
	var r=msec/(3600*1e+3),v=Math.floor(r);
	if (v>=1) t+=`${v}h `;
	r=(r-v)*60,v=Math.floor(r);
	if (v>=1) t+=`${v}m `;
	r=(r-v)*60,v=Math.floor(r);
	if (v>=1) t+=`${v}s `;
	r=(r-v)*1000;
	let ms=r.toFixed(3);
	t+=`${"0".repeat(7-ms.length)}${ms}ms`;
	return t;
}