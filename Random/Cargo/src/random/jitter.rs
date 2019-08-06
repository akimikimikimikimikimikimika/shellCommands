use rand::RngCore;
use rand_jitter::JitterRng;
use std::time::{SystemTime, UNIX_EPOCH};

fn get_nstime() -> u64 {
	let dur = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
	dur.as_secs() << 30 | dur.subsec_nanos() as u64
}

pub fn init() -> JitterRng {
	JitterRng::new_with_timer(get_nstime)
}

pub fn generator() -> Box<FnMut() -> u64> {
	let mut rng = init();
	Box::new(move|| -> u64 {rng.next_u64()})
}