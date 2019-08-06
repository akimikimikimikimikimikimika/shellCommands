mod types;

mod os;
mod thread;
mod jitter;
mod seedable_rng;
mod step;
use crate::random::seedable_rng::*;

pub fn gen(rt:& RT,s:& Seed,step: u64) -> Box<FnMut() -> u64> {
    match rt {
        RT::OS => os::generator(),
        RT::Thread => thread::generator(),
        RT::Jitter => jitter::generator(),
		RT::Standard => Standard::generator(s),
		RT::ChaCha20 => ChaCha20::generator(s),
		RT::ChaCha12 => ChaCha12::generator(s),
		RT::ChaCha8 => ChaCha8::generator(s),
		RT::Hc128 => Hc128::generator(s),
		RT::Isaac => Isaac::generator(s),
		RT::Isaac64 => Isaac64::generator(s),
		RT::Lcg128 => Lcg128::generator(s),
		RT::Lcg64 => Lcg64::generator(s),
		RT::Mcg128 => Mcg128::generator(s),
		RT::XorShift => XorShift::generator(s),
		RT::Xoroshiro64StarStar => Xoroshiro64StarStar::generator(s),
		RT::Xoroshiro64Star => Xoroshiro64Star::generator(s),
		RT::Xoroshiro128StarStar => Xoroshiro128StarStar::generator(s),
		RT::Xoroshiro128Plus => Xoroshiro128Plus::generator(s),
		RT::Xoshiro128StarStar => Xoshiro128StarStar::generator(s),
		RT::Xoshiro128Plus => Xoshiro128Plus::generator(s),
		RT::Xoshiro256StarStar => Xoshiro256StarStar::generator(s),
		RT::Xoshiro256Plus => Xoshiro256Plus::generator(s),
		RT::Xoshiro512StarStar => Xoshiro512StarStar::generator(s),
		RT::Xoshiro512Plus => Xoshiro512Plus::generator(s),
		RT::SplitMix64 => SplitMix64::generator(s),
		RT::Step => step::generator(s,step),
    }
}

pub use os::init as OSInit;
pub use jitter::init as JitterInit;
pub use thread::init as ThreadInit;

pub use types::RT as RT;
pub use types::VT as VT;
pub use types::Seed as Seed;