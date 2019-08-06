#![allow(non_snake_case)]

macro_rules! sr {
	($name:ident,$rng:path) => {
		pub mod $name {
			use std::process::exit;
			use rand::RngCore;
			use rand::SeedableRng;
			use $rng as Rng;
			use chrono::{DateTime,Local};
			use crate::random::*;

			pub fn init(s:& Seed) -> Rng {
				match s {
					Seed::Time => {
						let dt: DateTime<Local> = Local::now();
						Rng::seed_from_u64(dt.timestamp() as u64)
					},
					Seed::OS => {
						let sr = Rng::from_rng(OSInit());
						if sr.is_err() {
							eprintln!("シードの生成が失敗しました");
							exit(1);
						}
						sr.ok().unwrap()
					},
					Seed::Jitter => {
						let sr = Rng::from_rng(JitterInit());
						if sr.is_err() {
							eprintln!("シードの生成が失敗しました");
							exit(1);
						}
						sr.ok().unwrap()
					},
					Seed::Thread => {
						let sr = Rng::from_rng(ThreadInit());
						if sr.is_err() {
							eprintln!("シードの生成が失敗しました");
							exit(1);
						}
						sr.ok().unwrap()
					},
					Seed::Custom(seed) => Rng::seed_from_u64(*seed),
				}
			}

			pub fn generator(s:& Seed) -> Box<FnMut() -> u64> {
				let mut rng = init(s);
				Box::new(move|| -> u64 {rng.next_u64()})
			}
		}
	};
}

sr!(Standard,rand::rngs::StdRng);
sr!(ChaCha20,rand_chacha::ChaCha20Rng);
sr!(ChaCha12,rand_chacha::ChaCha12Rng);
sr!(ChaCha8,rand_chacha::ChaCha8Rng);
sr!(Hc128,rand_hc::Hc128Rng);
sr!(Isaac,rand_isaac::IsaacRng);
sr!(Isaac64,rand_isaac::Isaac64Rng);
sr!(Lcg128,rand_pcg::Lcg128Xsl64);
sr!(Lcg64,rand_pcg::Lcg64Xsh32);
sr!(Mcg128,rand_pcg::Mcg128Xsl64);
sr!(XorShift,rand_xorshift::XorShiftRng);
sr!(Xoroshiro64StarStar,rand_xoshiro::Xoroshiro64StarStar);
sr!(Xoroshiro64Star,rand_xoshiro::Xoroshiro64Star);
sr!(Xoroshiro128StarStar,rand_xoshiro::Xoroshiro128StarStar);
sr!(Xoroshiro128Plus,rand_xoshiro::Xoroshiro128Plus);
sr!(Xoshiro128StarStar,rand_xoshiro::Xoshiro128StarStar);
sr!(Xoshiro128Plus,rand_xoshiro::Xoshiro128Plus);
sr!(Xoshiro256StarStar,rand_xoshiro::Xoshiro256StarStar);
sr!(Xoshiro256Plus,rand_xoshiro::Xoshiro256Plus);
sr!(Xoshiro512StarStar,rand_xoshiro::Xoshiro512StarStar);
sr!(Xoshiro512Plus,rand_xoshiro::Xoshiro512Plus);
sr!(SplitMix64,rand_xoshiro::SplitMix64);