pub enum CommandMode {
	Main(Data),
	Help,
	Version
}
pub type CM = CommandMode;

pub enum MultipleMode {
	None,
	Serial,
	Spawn,
	Thread
}
pub type MM = MultipleMode;

pub enum ChildOutput {
	Inherit,
	Discard,
	File(String)
}
pub type CO = ChildOutput;

pub enum ResultOutput {
	Stdout,
	Stderr,
	File(String)
}
pub type RO = ResultOutput;

pub struct Data {
	pub command: Vec<String>,
	pub out: CO,
	pub err: CO,
	pub result: RO,
	pub multiple: MM
}

pub fn data() -> Data {
	return Data {
		command: vec![],
		out: CO::Inherit,
		err: CO::Inherit,
		result: RO::Stderr,
		multiple: MM::None
	};
}

// convert str -> String
#[macro_export]
macro_rules! S {
	($text:expr) => {
		String::from($text)
	};
}

use std::process::exit;
pub fn error_exit() {
	exit(1);
}

// exit with error
#[macro_export]
macro_rules! E {
	($text:expr) => {
		eprintln!($text);
		error_exit();
	};
}

// append String to another string
#[macro_export]
macro_rules! add {
	($val:expr,$formatter:expr,$value:expr) => {
		if write!($val,$formatter,$value).is_err() {
			E!("内部処理に失敗しました");
		}
	};
}