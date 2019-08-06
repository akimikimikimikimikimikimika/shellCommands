mod random;
mod analyzer;
mod generator;
mod data_types;
mod help;

use crate::analyzer::analyzer;
use crate::generator::generate;
use crate::data_types::Customize;
use crate::random::*;

pub fn main() {

	let mut customize = Customize{
		mode: RT::OS,
		value_type: VT::Real{default:true,min:0.0,max:1.0},
		seed: Seed::OS,
		step: 1,
		length: 1,
		visible: true
	};
	analyzer(&mut customize);
	generate(& customize);

}