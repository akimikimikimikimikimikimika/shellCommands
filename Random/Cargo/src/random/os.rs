use rand::RngCore;
use rand_os::OsRng;

pub fn init() -> OsRng {
	rand_os::OsRng
}

pub fn generator() -> Box<FnMut() -> u64> {
	let mut rng = init();
	Box::new(move|| -> u64 {rng.next_u64()})
}