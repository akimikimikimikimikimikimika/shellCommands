#! /usr/bin/env node

const process=require("process"),cp=require("child_process"),os=require("os"),fs=require("fs");
const { performance }=require("perf_hooks");

let command=[];
var out="inherit";
var err="inherit";
var result="stderr";
var multiple=false;

function main() {
	argAnalyze();
	execute();
}

function argAnalyze() {
	let l=process.argv;
	l.splice(0,2);
	if (l.length==0) error("引数が不足しています");
	else {
		switch (l[0]) {
			case "-h": case "help": case "-help": case "--help": help();
			case "-v": case "version": case "-version": case "--version": version();
		}
	}
	var key=null;
	for (var n=0;n<l.length;n++) {
		let a=l[n];
		if (key) {
			switch (key) {
				case 0: out=a; break;
				case 1: err=a; break;
				case 2: result=a; break;
			}
			key=null;
			continue;
		}
		breakable=false;
		switch (a) {
			case "-o": case "-out": case "-stdout": key=0; break;
			case "-e": case "-err": case "-stderr": key=1; break;
			case "-r": case "-result": key=2; break;
			case "-m": case "-multiple": multiple=true; break;
			default:
				command=l.slice(n);
				breakable=true;
		}
	}
	if (command.length==0) error("実行する内容が指定されていません");
}

let execute=(()=>{

	function execute() {
		let o=co2f(out);
		let e=co2f(err);
		let r=ro2f(result);

		var ec=0;
		if (multiple) {
			let pl=[];

			let st=performance.now();
			for (c of command) {
				let s=cp.spawnSync(c,{stdio:["inherit",o,e],shell:true});
				pl.push(s.pid);
				ec=s.status;
				if (ec!=0) break;
			}
			let en=performance.now();

			fs.writeSync(r,"time: "+descTime(en-st)+os.EOL);
			pl.forEach((pid,n)=>fs.writeSync(r,`process${n+1} id:${pid}`+os.EOL));
			fs.writeSync(r,descEC(ec)+os.EOL);
		}
		else {
			let st=performance.now();
			let f=command.shift();
			let s=cp.spawnSync(f,command,{stdio:["inherit",o,e]});
			let en=performance.now();

			let pid=s.pid;
			ec=s.status;
			fs.writeSync(r,clean(`
				time: ${descTime(en-st)}
				process id: ${pid}
				${descEC(ec)}
			`));
		}
		fs.closeSync(r);
	}

	function co2f(d) {
		switch (d) {
			case "inherit": return "inherit";
			case "discard": return "ignore";
			default: return fh(d);
		}
	}

	function ro2f(d) {
		switch (d) {
			case "stdout": return 1;
			case "stderr": return 2;
			default: return fh(d);
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
		t+=`${r.toFixed(3)}ms`;
		return t;
	}

	function descEC(ec) {
		return ec==null?"terminated due to signal":"exit code: "+ec;
	}

	return execute;
})();

function error(text) {
	process.stderr.write(text+os.EOL);
	process.exit(1);
}

function help() {
	process.stdout.write(clean(`

		 使い方:
		  measure [options] [command] [arg1] [arg2]…
		  measure -multiple [options] "[command1]" "[command2]"…

		  [command] を実行し,最後にその所要時間を表示します

		  オプション

		   -o,-out,-stdout
		   -e,-err,-stderr
		    標準出力,標準エラー出力の出力先を指定します
		    指定しなければ inherit になります
		    • inherit
		     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
		    • discard
		     出力しません
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -r,-result
		    実行結果の出力先を指定します
		    指定しなければ stderr になります
		    • stdout,stderr
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -m,-multiple
		    複数のコマンドを実行します
		    通常はシェル経由で実行されます
		    例えば measure echo 1 と指定していたのを

		     measure -multiple "echo 1" "echo 2"

		    などと1つ1つのコマンドを1つの文字列として渡して実行します

	`));
	process.exit(0);
}

function version() {
	process.stdout.write(clean(`

		 measure v2.1
		 JavaScript バージョン (measure-js)

	`));
	process.exit(0);
}

function clean(text) {
	return text.replace(/\t+/mg,"").replace(/^\n/,"");
}

main();