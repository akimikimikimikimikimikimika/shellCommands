use std::process::{Stdio,Command,Child,exit};
use std::fs::{File,OpenOptions};
use std::io::{Write,stdout,stderr};
use std::thread;
use std::sync::{Mutex,Arc};
use std::fmt::Write as FmtWrite;
use std::time::SystemTime;

use crate::lib::*;

type EC = Option<i32>;

struct Exec<'x> {
	d:&'x Data,
	ec:EC,
	res:String
}

pub fn execute(d:&Data) {
	let mut x = Exec {
		d:d,
		ec:Some(0),
		res:String::new()
	};
	let r=ro2f(&d.result);

	match d.multiple {
		MM::None   => single(&mut x),
		MM::Serial => serial(&mut x),
		MM::Spawn => spawn(&mut x),
		MM::Thread => thread_process(&mut x)
	}

	if match &d.result {
		ResultOutput::Stdout  =>   stdout().write(&x.res.as_bytes()),
		ResultOutput::Stderr  =>   stderr().write(&x.res.as_bytes()),
		ResultOutput::File(_) => r.unwrap().write(&x.res.as_bytes())
	}.is_err() { exit(1); }

	exit(x.ec.unwrap_or(1));

}

fn single(x:&mut Exec) {
	let mut p = sp(x,&x.d.command[0],&x.d.command[1..],&x.d.command.join(" "));

	let st = SystemTime::now();
	p.run();
	let en = SystemTime::now();

	x.res=vec![
		format!("time: {}",desc_time(st,en)),
		format!("process id: {}",p.pid.unwrap()),
		p.desc_ec(),String::new()
	].join("\n");

	x.ec=p.ec;
}

fn serial(x:&mut Exec) {
	let mut pl=multiple(x,&x.d.command);
	let mut ln=pl.len()-1;

	let st = SystemTime::now();
	for p in &mut pl {
		p.run();
		if p.ec!=Some(0) {
			ln=p.order;
			break;
		}
	}
	let en = SystemTime::now();

	let lp = &pl[ln];

	let mut rl=make_vs(pl.len()+3);
	rl.push(format!("time: {}",desc_time(st,en)));
	for p in &pl {
		rl.push(format!(
			"process{} id: {}",
			p.order,
			p.pid.map_or(S!("N/A"),|pid| pid.to_string())
		));
	}
	rl.push(lp.desc_ec());
	rl.push(String::new());
	x.res=rl.join("\n");

	x.ec=lp.ec;
}

fn spawn(x:&mut Exec) {
	let mut pl=multiple(x,&x.d.command);

	let st = SystemTime::now();
	for p in &mut pl { p.start(); }
	for p in &mut pl { p.wait(); }
	let en = SystemTime::now();

	let mut ec:i32=0;

	let mut rl=make_vs(pl.len()*2+2);
	rl.push(format!("time: {}",desc_time(st,en)));
	for p in &pl {
		let pec=p.ec.unwrap_or(1);
		if pec>ec { ec=pec; }
		rl.push(format!(
			"process{} id: {}",
			p.order,
			p.pid.unwrap()
		));
		rl.push(p.desc_ec());
	}
	rl.push(String::new());
	x.res=rl.join("\n");

	x.ec=Some(ec);
}

fn thread_process(x:&mut Exec) {
	let al:Vec<Arc<Mutex<SP>>>=multiple(x,&x.d.command).into_iter().map(|p| Arc::new(Mutex::new(p))).collect();
	let mut tl:Vec<thread::JoinHandle<_>>=Vec::new();
	tl.reserve(al.len());

	let st = SystemTime::now();
	for a in &al {
		let m=a.clone();
		tl.push(thread::spawn(move || {
			let mut p=m.lock().unwrap();
			p.run();
		}));
	}
	tl.into_iter().for_each(|t| {
		if t.join().is_err() { E!("スレッド実行に失敗しました"); }
	});
	let en = SystemTime::now();

	let mut ec:i32=0;

	let mut rl=make_vs(al.len()*2+2);
	rl.push(format!("time: {}",desc_time(st,en)));
	for a in &al {
		let m=a.clone();
		let p=m.lock().unwrap();
		let pec=p.ec.unwrap_or(1);
		if pec>ec { ec=pec; }
		rl.push(format!(
			"process{} id: {}",
			p.order,
			p.pid.unwrap()
		));
		rl.push(p.desc_ec());
	}
	rl.push(String::new());
	x.res=rl.join("\n");

	x.ec=Some(ec);
}

struct SP {
	command:Command,
	child:Option<Child>,
	description:String,
	pub order:usize,
	pub pid:Option<u32>,
	pub ec:EC
}
fn sp(x:&Exec,file:&String,args:&[String],desc:&String) -> SP {
	let mut cmd = Command::new(&file);
	cmd.args(args.iter())
		.stdin(Stdio::inherit())
		.stdout(co2sio(&x.d.out))
		.stderr(co2sio(&x.d.err));
	return SP {
		command:cmd,
		child:None,
		description:desc.to_string(),
		order:0,
		pid:None,
		ec:Some(0)
	};
}
fn multiple(x:&Exec,commands:&[String]) -> Vec<SP> {
	let sh=match option_env!("SHELL") {
		Some(s) => S!(s),
		None => S!("sh")
	};
	let mut n:usize=1;
	let mut l:Vec<SP>=Vec::new();
	l.reserve(commands.len());
	for c in commands.iter() {
		let mut p=sp(x,&sh,&[S!("-c"),S!(c)],c);
		p.order=n;
		n+=1;
		l.push(p);
	}
	return l;
}
trait SPAction {
	fn start(&mut self);
	fn wait(&mut self);
	fn run(&mut self) {
		self.start();
		self.wait();
	}
	fn desc_ec(&self) -> String;
}
impl SPAction for SP {
	fn start(&mut self) {
		let c=unwrap_or_error(self.command.spawn(),&format!("実行に失敗しました: {}",self.description));
		self.pid=Some(c.id());
		self.child=Some(c);
	}
	fn wait(&mut self) {
		let s=unwrap_or_error(self.child.as_mut().unwrap().wait(),&format!("実行に失敗しました: {}",self.description));
		self.ec=s.code();
	}
	fn desc_ec(&self) -> String {
		return self.ec.map_or(
			S!("terminated due to signal"),
			|v| format!("exit code: {}",v)
		);
	}
}



fn co2sio(v:&CO) -> Stdio {
	return match &v {
		CO::Inherit => Stdio::inherit(),
		CO::Discard => Stdio::null(),
		CO::File(path) => Stdio::from(fh(&path))
	};
}
fn ro2f(v:&RO) -> Option<File> {
	return match &v {
		RO::File(path) => Some(fh(&path)),
		_ => None
	};
}
fn fh(path:&String) -> File {
	let f=OpenOptions::new().append(true).create(true).open(path);
	if f.is_ok() { return f.unwrap(); }
	else {
		eprintln!("指定したパスには書き込みできません: {}",path);
		exit(1);
	}
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