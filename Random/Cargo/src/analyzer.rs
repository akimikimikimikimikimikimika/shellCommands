use std::env::args;
use std::process::exit;
use crate::data_types::*;
use crate::random::*;
use crate::help::*;

enum R {
	None,
	Mode,
	Seed,
	Step,
	Length,
	RangeFirst,
	RangeSecond,
}

pub fn analyzer(c:&mut Customize) {

	let args:Vec<String> = args().collect();

	if args.len()==2 {
		if args[1]=="help"||args[1]=="-help"||args[1]=="--help" {
			help();
			exit(0);
		}
		else if args[1]=="version"||args[1]=="-version"||args[1]=="--version" {
			version();
			exit(0);
		}
	}

	let mut responder:R = R::None;
	let mut is_real = true;
	let mut range_first:String = "".to_string();
	let mut range_second:String = "".to_string();
	let mut vt_specified = false;
	let mut seed_specified = false;

	for n in 1..args.len() {
		let a = &args[n];
		if a=="-m"||a=="-mode" {responder=R::Mode;}
		else if a=="-s"||a=="-seed" {responder=R::Seed;}
		else if a=="-d"||a=="-step" {responder=R::Step;}
		else if a=="-l"||a=="-length" {responder=R::Length;}
		else if a=="-i"||a=="-int" {
			is_real=false;
			vt_specified=true;
			responder = R::RangeFirst;
		}
		else if a=="-r"||a=="-real" {
			is_real=true;
			vt_specified=true;
			responder = R::RangeFirst;
		}
		else if a=="-hidden"||a=="-invisible" {c.visible = false;}
		else {
			match responder {
				R::Mode => {
					let m = a.parse::<RT>();
					if m.is_err() {
						eprintln!("モードが不正です: {}",a);
						exit(1);
					}
					else {
						c.mode = m.unwrap();
						responder = R::None;
					}
				},
				R::Seed => {
					let s = a.parse::<Seed>();
					if s.is_err() {
						eprintln!("シードが不正です: {}",a);
						exit(1);
					}
					else {
						c.seed = s.unwrap();
						seed_specified = true;
						responder = R::None;
					}
				},
				R::Step => {
					c.step = a.parse().unwrap_or(0);
					responder = R::None;
				},
				R::Length => {
					c.length = a.parse().unwrap_or(1);
					responder = R::None;
				},
				R::RangeFirst => {
					range_first = a.to_string();
					responder = R::RangeSecond;
				},
				R::RangeSecond => {
					range_second = a.to_string();
					responder = R::None;
				},
				R::None => {},
			}
		}
	}
	match c.mode {
		RT::Step => {
			if !vt_specified {
				is_real = false;
			}
			if !seed_specified {
				c.seed = Seed::Custom(0);
			}
		},
		_ => {},
	}
	if range_first!="" {
		if is_real {
			let first = range_first.parse::<f64>().unwrap_or(0.0);
			let mut second:f64 = 0.0;
			if range_second!="" {second = range_second.parse::<f64>().unwrap_or(0.0);}
			if first<second {c.value_type = VT::Real{default:false,min:first,max:second};}
			else {c.value_type = VT::Real{default:false,min:second,max:first};}
		}
		else {
			let first = range_first.parse::<i64>().unwrap_or(0);
			let mut second:i64 = 0;
			if range_second!="" {second = range_second.parse::<i64>().unwrap_or(0);}
			if first<second {c.value_type = VT::Int{default:false,min:first,max:second};}
			else {c.value_type = VT::Int{default:false,min:second,max:first};}
		}
	}
	else {
		if is_real {c.value_type = VT::Real{default:true,min:0.0,max:1.0}}
		else {c.value_type = VT::Int{default:true,min:0,max:0}}
	}

}