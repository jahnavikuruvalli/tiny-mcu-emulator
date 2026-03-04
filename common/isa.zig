pub const NOP: u8 = 0x00;

pub const MOV: u8 = 0x10;
pub const ADD: u8 = 0x20;
pub const SUB: u8 = 0x21;

pub const JMP: u8 = 0x40;
pub const JZ: u8 = 0x41;

pub const PUSH = 0x08;
pub const POP = 0x09;

pub const CALL: u8 = 0x30;
pub const RET: u8 = 0x31;

pub const HALT: u8 = 0x01;

pub const LD: u8 = 0x30;
pub const ST: u8 = 0x31;
