use std::str::FromStr;

pub enum RT {
	OS,
	Thread,
	Jitter,
	Standard,
	ChaCha20,
	ChaCha12,
	ChaCha8,
	Hc128,
	Isaac,
	Isaac64,
	Lcg128,
	Lcg64,
	Mcg128,
	XorShift,
	Xoroshiro64StarStar,
	Xoroshiro64Star,
	Xoroshiro128StarStar,
	Xoroshiro128Plus,
	Xoshiro128StarStar,
	Xoshiro128Plus,
	Xoshiro256StarStar,
	Xoshiro256Plus,
	Xoshiro512StarStar,
	Xoshiro512Plus,
	SplitMix64,
	Step,
}

impl FromStr for RT {
	type Err = ();
	fn from_str(s: &str) -> Result<RT,Self::Err> {
		match s {
			"OS"|"os"|"Os" => Ok(RT::OS),
			"Jitter"|"jitter" => Ok(RT::Jitter),
			"Thread"|"thread" => Ok(RT::Thread),
			"Standard"|"standard"|"Std"|"std" => Ok(RT::Standard),
			"ChaCha20"|"chacha20" => Ok(RT::ChaCha20),
			"ChaCha12"|"chacha12" => Ok(RT::ChaCha12),
			"ChaCha8"|"chacha8" => Ok(RT::ChaCha8),
			"Hc128"|"hc128" => Ok(RT::Hc128),
			"Isaac"|"isaac"|"ISAAC" => Ok(RT::Isaac),
			"Isaac64"|"isaac64"|"ISAAC-64" => Ok(RT::Isaac64),
			"Lcg128"|"lcg128"|"Pcg32"|"pcg32" => Ok(RT::Lcg128),
			"Lcg64"|"lcg64"|"Pcg64"|"pcg64" => Ok(RT::Lcg64),
			"Mcg128"|"mcg128"|"Pcg64Mcg"|"pcg64mcg" => Ok(RT::Mcg128),
			"XorShift"|"xorshift" => Ok(RT::XorShift),
			"Xoroshiro64StarStar"|"Xoroshiro64**" => Ok(RT::Xoroshiro64StarStar),
			"Xoroshiro64Star"|"Xoroshiro64*" => Ok(RT::Xoroshiro64Star),
			"Xoroshiro128StarStar"|"Xoroshiro128**" => Ok(RT::Xoroshiro128StarStar),
			"Xoroshiro128Plus"|"Xoroshiro128+" => Ok(RT::Xoroshiro128Plus),
			"Xoshiro128StarStar"|"Xoshiro128**" => Ok(RT::Xoshiro128StarStar),
			"Xoshiro128Plus"|"Xoshiro128+" => Ok(RT::Xoshiro128Plus),
			"Xoshiro256StarStar"|"Xoshiro256**" => Ok(RT::Xoshiro256StarStar),
			"Xoshiro256Plus"|"Xoshiro256+" => Ok(RT::Xoshiro256Plus),
			"Xoshiro512StarStar"|"Xoshiro512**" => Ok(RT::Xoshiro512StarStar),
			"Xoshiro512Plus"|"Xoshiro512+" => Ok(RT::Xoshiro512Plus),
			"SplitMix64"|"splitmix64" => Ok(RT::SplitMix64),
			"Step"|"step" => Ok(RT::Step),
			_ => Err(()),
		}
	}
}

pub enum VT {
	Int{default:bool,min:i64,max:i64},
	Real{default:bool,min:f64,max:f64}
}

pub enum Seed {
	Time,
	OS,
	Jitter,
	Thread,
	Custom(u64),
}

impl FromStr for Seed {
	type Err = ();
	fn from_str(s: &str) -> Result<Seed,Self::Err> {
		match s {
			"Time"|"time" => Ok(Seed::Time),
			"OS"|"os"|"Os" => Ok(Seed::OS),
			"Thread"|"thread" => Ok(Seed::Thread),
			"Jitter"|"jitter" => Ok(Seed::Jitter),
			_ => {
				let cs = s.parse::<u64>();
				if cs.is_err() {Err(())}
				else {Ok(Seed::Custom(cs.unwrap()))}
			},
		}
	}
}