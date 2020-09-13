#[macro_use]
mod lib;
mod analyze;
mod execute;
mod docs;

use crate::analyze::arg_analyze;
use crate::execute::execute;
use crate::docs::{help,version};
use crate::lib::CM;

fn main() {
	match arg_analyze() {
		CM::Main(mut d) => execute(&mut d),
		CM::Help        => help(),
		CM::Version     => version()
	}
}