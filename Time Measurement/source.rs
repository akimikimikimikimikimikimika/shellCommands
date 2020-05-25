use std::env;
use std::process::exit;

// convert str -> String
macro_rules! S {
	($text:expr) => {
		String::from($text)
	};
}

// exit with error
macro_rules! E {
	($text:expr) => {
		eprintln!($text);
		exit(1);
	};
}

// append String to another string
macro_rules! add {
	($val:ident,$formatter:expr,$value:expr) => {
		if write!($val,$formatter,$value).is_err() {
			E!("内部処理に失敗しました");
		}
	};
}

fn main() {
	let mut d=data();
	arg_analyze(&mut d);
	execute(&mut d);
}

fn arg_analyze(d:&mut Data) {
	let mut l:Vec<String> = env::args().collect();
	l=l[1..].to_vec();
	if l.len()==0 { E!("引数が不足しています"); }
	else {
		match &l[0][..] {
			"-h"|"help"|"-help"|"--help" => help(),
			"-v"|"version"|"-version"|"--version" => version(),
			_ => {}
		}
	}
	let mut key:Option<AnalyzeKey> = None;
	let mut n:usize=0;
	for a in &l {
		if let Some(k)=key {
			match k {
				AnalyzeKey::Stdout => d.out=s2co(a),
				AnalyzeKey::Stderr => d.err=s2co(a),
				AnalyzeKey::Result => d.result=s2ro(a)
			}
			key=None;
			continue;
		}
		match &a[..] {
			"-o"|"-out"|"-stdout" => key=Some(AnalyzeKey::Stdout),
			"-e"|"-err"|"-stderr" => key=Some(AnalyzeKey::Stderr),
			"-r"|"-result" => key=Some(AnalyzeKey::Result),
			"-m"|"-multiple" => d.multiple=true,
			_ => {
				d.command=l[n..].to_vec();
				break;
			}
		}
		n+=1;
	}
	if d.command.len()==0 { E!("実行する内容が指定されていません"); }
}

mod exec {
	use std::process::{Stdio,Command,exit};
	use std::io::{Write,stdout,stderr};
	use std::time::SystemTime;
	use std::fmt::Debug;
	use std::fmt::Write as FmtWrite;
	use crate::utils::*;

	type PID = u32;
	type EC = Option<i32>;

	pub fn execute(d:&mut Data) {

		let r = ro2f(&d.result);
		let mut ec:EC = Some(0);
		let mut t:String = String::new();

		if d.multiple {

			let mut cl:Vec<Command> = d.command.iter().map(|c| shell(c,&d)).collect();
			let mut pl:Vec<PID> = d.command.iter().map(|_c| 0).collect();

			let from_time = SystemTime::now();
			let mut n = 0;
			for cmd in &mut cl {
				let (pid,ec_tmp) = run(cmd);
				pl[n]=pid;
				ec=ec_tmp;
				n+=1;
				if let Some(0) = ec { continue; } else { break; }
			}
			let to_time = SystemTime::now();

			add!(t,"time: {}\n",desc_time(from_time,to_time));
			for n in 0..pl.len() {
				add!(t,"process{} ",n+1);
				let pid:String;
				if pl[n]==0 { pid=S!("N/A"); }
				else { pid=pl[n].to_string(); }
				add!(t,"id: {}\n",pid);
			}
			add!(t,"{}\n",desc_ec(ec));

		}
		else {

			let mut cmd = make_cmd(&d.command[0],&d.command[1..],&d);

			let from_time = SystemTime::now();
			let (pid,ec_tmp) = run(&mut cmd);
			let to_time = SystemTime::now();
			ec=ec_tmp;

			add!(t,"time: {}\n",desc_time(from_time,to_time));
			add!(t,"process id: {}\n",pid);
			add!(t,"{}\n",desc_ec(ec));

		}

		if match &d.result {
			ResultOutput::Stdout => stdout().write(&t.as_bytes()),
			ResultOutput::Stderr => stderr().write(&t.as_bytes()),
			ResultOutput::File(_) => r.unwrap().write(&t.as_bytes())
		}.is_err() { exit(1); }
		exit(ec.unwrap_or(255));

	}

	fn shell(cmd:&String,d:&Data) -> Command {
		let sh=match option_env!("SHELL") {
			Some(s) => S!(s),
			None => S!("sh")
		};
		return make_cmd(&sh,&[S!("-c"),S!(cmd)],&d);
	}

	fn make_cmd(file:&String,args:&[String],d:&Data) -> Command {
		let mut cmd = Command::new(&file);
		cmd.args(args.iter())
			.stdin(Stdio::inherit())
			.stdout(co2sio(&d.out))
			.stderr(co2sio(&d.err));
		return cmd;
	}

	fn run(cmd:&mut Command) -> (PID,EC) {
		let mut c = unwrap_or_error(cmd.spawn(),&S!("実行に失敗しました"));
		let s = unwrap_or_error(c.wait(),&S!("実行に失敗しました"));
		return (c.id(),s.code());
	}

	fn desc_time(st:SystemTime,en:SystemTime) -> String {
		let mut r=unwrap_or_error(en.duration_since(st),&S!("内部処理でエラーが発生しました")).as_secs_f64();
		let mut v:f64;
		let mut t=String::new();

		r=r/3600.0;
		v=r.floor();
		if v>=1.0 { add!(t,"{:.0}h ",v); }
		r=(r-v)*60.0;
		v=r.floor();
		if v>=1.0 { add!(t,"{:.0}m ",v); }
		r=(r-v)*60.0;
		v=r.floor();
		if v>=1.0 { add!(t,"{:.0}s ",v); }
		r=(r-v)*1000.0;
		add!(t,"{:07.3}ms",r);

		return t;
	}

	fn desc_ec(ec:EC) -> String {
		return ec.map_or(
			S!("terminated due to signal"),
			|v| format!("exit code: {}",v)
		);
	}

	fn unwrap_or_error<T,E>(r:Result<T,E>,message:&String) -> T where E : Debug {
		if r.is_err() { eprintln!("{}",message); exit(1); }
		else { return r.unwrap(); }
	}

}
use exec::execute;

mod docs {
	use std::process::exit;
	pub fn help() {
		output(S!(r#"

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

		"#));
		exit(0);
	}
	pub fn version() {
		output(S!(r#"

			 measure v2.2
			 Rust バージョン (measure-rs)

		"#));
		exit(0);
	}
	fn output(text:String) {
		let l=text.len();
		let mut t=text.replace("\t","");
		t=t.chars().skip(1).take(l-2).collect();
		print!("{}",t);
	}
}
use docs::{help,version};

mod utils {
	use std::process::{Stdio,exit};
	use std::fs::{File,OpenOptions};
	pub struct Data {
		pub command: Vec<String>,
		pub out: ChildOutput,
		pub err: ChildOutput,
		pub result: ResultOutput,
		pub multiple: bool
	}
	pub fn data() -> Data {
		return Data {
			command: vec![],
			out: ChildOutput::Inherit,
			err: ChildOutput::Inherit,
			result: ResultOutput::Stderr,
			multiple: false
		};
	}
	pub enum ChildOutput {
		Inherit,
		Discard,
		File(String)
	}
	pub fn s2co(v:&String) -> ChildOutput {
		if v=="inherit" { return ChildOutput::Inherit; }
		else if v=="discard" { return ChildOutput::Discard; }
		else { return ChildOutput::File(S!(v)); }
	}
	pub fn co2sio(v:&ChildOutput) -> Stdio {
		return match &v {
			ChildOutput::Inherit => Stdio::inherit(),
			ChildOutput::Discard => Stdio::null(),
			ChildOutput::File(path) => Stdio::from(fh(&path))
		};
	}
	pub enum ResultOutput {
		Stdout,
		Stderr,
		File(String)
	}
	pub fn s2ro(v:&String) -> ResultOutput {
		if v=="stdout" { return ResultOutput::Stdout; }
		else if v=="stderr" { return ResultOutput::Stderr; }
		else { return ResultOutput::File(S!(v)); }
	}
	pub fn ro2f(v:&ResultOutput) -> Option<File> {
		return match &v {
			ResultOutput::File(path) => Some(fh(&path)),
			_ => None
		};
	}
	pub enum AnalyzeKey {
		Stdout,
		Stderr,
		Result
	}
	fn fh(path:&String) -> File {
		let f=OpenOptions::new().append(true).create(true).open(path);
		if f.is_ok() { return f.unwrap(); }
		else {
			eprintln!("指定したパスには書き込みできません: {}",path);
			exit(1);
		}
	}
}
use utils::*;