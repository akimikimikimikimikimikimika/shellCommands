use std::env;
use crate::lib::*;
use std::convert::TryFrom;

enum AnalyzeKey {
	Out,
	Err,
	Result,
	Multiple
}
type AK = AnalyzeKey;
type OAK = Option<AK>;

pub fn arg_analyze() -> CM {
	let mut l:Vec<String> = env::args().collect();
	l=l[1..].to_vec();

	if l.len()==0 { E!("引数が不足しています"); }
	else {
		match &l[0][..] {
			"-h"|"help"|"-help"|"--help" => return CM::Help,
			"-v"|"version"|"-version"|"--version" => return CM::Version,
			_ => {}
		}
	}

	let mut d = data();
	let mut key:OAK = None;
	let mut n:isize=-1;
	for a in &l {
		n+=1;
		if a.is_empty() { continue; }

		let mut proceed=true;
		match &a[..] {
			"-m"|"-multiple" => {
				d.multiple=MM::Serial;
				key=Some(AK::Multiple);
			},
			"-o"|"-out"|"-stdout" => key=Some(AK::Out),
			"-e"|"-err"|"-stderr" => key=Some(AK::Err),
			"-r"|"-result" => key=Some(AK::Result),
			_ => proceed=false
		}
		if proceed { continue; }

		if a.starts_with("-") { E!("不正なオプションが指定されています"); }
		else if let Some(k)=key {
			proceed=true;
			match k {
				AK::Out => d.out=s2co(a),
				AK::Err => d.err=s2co(a),
				AK::Result => d.result=s2ro(a),
				AK::Multiple => {
					match &a[..] {
						"none" => d.multiple=MM::None,
						"serial"|"" => d.multiple=MM::Serial,
						"spawn"|"parallel" => d.multiple=MM::Spawn,
						"thread" => d.multiple=MM::Thread,
						_ => proceed=false
					};
				}
			}
			key=None;
		}
		if proceed { continue; }

		d.command=l[TryFrom::try_from(n).unwrap()..].to_vec();
		break;
	}

	if d.command.is_empty() { E!("実行する内容が指定されていません"); }

	return CM::Main(d);
}

fn s2co(v:&String) -> CO {
	return match &v[..] {
		"inherit" => CO::Inherit,
		"discard" => CO::Discard,
		_ =>         CO::File(S!(v))
	};
}

fn s2ro(v:&String) -> RO {
	return match &v[..] {
		"stdout" => RO::Stdout,
		"stderr" => RO::Stderr,
		_ =>        RO::File(S!(v))
	};
}