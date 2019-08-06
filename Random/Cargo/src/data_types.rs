use crate::random::*;

pub struct Customize {
    pub mode: RT,
    pub seed: Seed,
    pub step: u64,
    pub value_type: VT,
    pub length: u64,
    pub visible: bool
}