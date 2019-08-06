use rand::RngCore;
use rand::rngs::mock::StepRng;
use chrono::{DateTime,Local};
use crate::random::*;

pub fn init(s:& Seed, step: u64) -> StepRng {
	match s {
		Seed::Time => {
			let dt: DateTime<Local> = Local::now();
			StepRng::new(dt.timestamp() as u64,step)
		},
		Seed::OS => {
			let mut g = gen(&RT::OS,&Seed::Custom(0),0);
			StepRng::new(g(),step)
		},
		Seed::Jitter => {
			let mut g = gen(&RT::Jitter,&Seed::Custom(0),0);
			StepRng::new(g(),step)
		},
		Seed::Thread => {
			let mut g = gen(&RT::Thread,&Seed::Custom(0),0);
			StepRng::new(g(),step)
		},
		Seed::Custom(seed) => StepRng::new(*seed,step),
	}
}

pub fn generator(s:& Seed, step: u64) -> Box<FnMut() -> u64> {
	let mut rng = init(s,step);
	Box::new(move|| -> u64 {rng.next_u64()})
}