use rand::RngCore;
use rand::rngs::ThreadRng;

pub fn init() -> ThreadRng {
	rand::thread_rng()
}

pub fn generator() -> Box<FnMut() -> u64> {
	let mut rng = init();
	Box::new(move|| -> u64 {rng.next_u64()})
}