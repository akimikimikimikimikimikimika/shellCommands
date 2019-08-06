use crate::random::VT;
use crate::random::gen;
use crate::data_types;

static UPPER:u64 = u64::max_value()/16+1;
static UPPERF:f64 = UPPER as f64;

pub fn generate(c:& data_types::Customize) {
	let mut gen = gen(&c.mode,&c.seed,c.step);
	match c.value_type {
		VT::Int {default,min,max} => {
			if default {
				if c.visible {for _ in 0..c.length {println!("{}",gen());}}
				else {for _ in 0..c.length {let _ = gen();}}
			}
			else {
				let maxf = max as f64;
				let minf = min as f64;
				let diff = maxf-minf;
				if c.visible {for _ in 0..c.length {
					let v = (((gen()%UPPER) as f64)*diff/UPPERF+minf).round() as i64;
					println!("{}",v);
				}}
				else {for _ in 0..c.length {
					let _ = (((gen()%UPPER) as f64)*diff/UPPERF+minf).round() as i64;
				}}
			}
		},
		VT::Real {default,min,max} => {
			if default {
				if c.visible {for _ in 0..c.length {
					let v = ((gen()%UPPER) as f64)/(UPPERF+1.0);
					println!("{}",v);
				}}
				else {for _ in 0..c.length {
					let _ = ((gen()%UPPER) as f64)/(UPPERF+1.0);
				}}
			}
			else {
				let diff = max-min;
				if c.visible {for _ in 0..c.length {
					let v = ((gen()%UPPER) as f64)*diff/(UPPERF+1.0)+min;
					println!("{}",v);
				}}
				else {for _ in 0..c.length {
					let _ = ((gen()%UPPER) as f64)*diff/(UPPERF+1.0)+min;
				}}
			}
		},
	}
}