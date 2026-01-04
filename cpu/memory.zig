pub const RAM_SIZE = 256;

pub fn initRAM() [RAM_SIZE]u8 {
    return [_]u8{0} ** RAM_SIZE;
}
