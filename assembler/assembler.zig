const std = @import("std");
const isa = @import("isa");
const asmerr = @import("error.zig");

pub fn assemble(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    var labels = std.StringHashMap(u8).init(allocator);
    defer labels.deinit();

    var output = std.ArrayListUnmanaged(u8){};
    defer output.deinit(allocator);

    //  PASS 1: collect labels
    var pc: u8 = 0;
    var line_no: usize = 0;
    var it = std.mem.tokenizeAny(u8, source, "\n");

    while (it.next()) |line| {
        line_no += 1;

        const trimmed = std.mem.trim(u8, line, " \t");
        if (trimmed.len == 0) continue;

        if (trimmed[trimmed.len - 1] == ':') {
            const name = trimmed[0 .. trimmed.len - 1];
            try labels.put(name, pc);
        } else {
            pc += instructionSize(trimmed);
        }
    }

    //  PASS 2: emit bytecode
    it = std.mem.tokenizeAny(u8, source, "\n");
    line_no = 0;

    while (it.next()) |line| {
        line_no += 1;

        const trimmed = std.mem.trim(u8, line, " \t");
        if (trimmed.len == 0) continue;
        if (trimmed[trimmed.len - 1] == ':') continue;

        try emitInstruction(&output, trimmed, &labels, allocator, line_no);
    }

    return output.toOwnedSlice(allocator);
}

fn instructionSize(line: []const u8) u8 {
    if (std.mem.startsWith(u8, line, "HALT")) return 1;
    if (std.mem.startsWith(u8, line, "JMP")) return 2;
    if (std.mem.startsWith(u8, line, "JZ")) return 3;
    if (std.mem.startsWith(u8, line, "PUSH")) return 2; // Opcode + Reg
    if (std.mem.startsWith(u8, line, "POP")) return 2; // Opcode + Reg
    if (std.mem.startsWith(u8, line, "CALL")) return 2;
    if (std.mem.startsWith(u8, line, "RET")) return 1;
    return 3;
}

fn emitInstruction(
    out: *std.ArrayListUnmanaged(u8),
    line: []const u8,
    labels: *std.StringHashMap(u8),
    allocator: std.mem.Allocator,
    line_no: usize,
) !void {
    var parts = std.mem.tokenizeAny(u8, line, " ,");
    const instr = parts.next() orelse return; // Skip empty lines if any

    if (std.mem.eql(u8, instr, "HALT")) {
        try out.append(allocator, isa.HALT);
        return;
    }

    if (std.mem.eql(u8, instr, "JMP")) { // Removed the JZ check here
        const label = parts.next().?;
        const addr = labels.get(label) orelse {
            asmerr.report(line_no, "undefined label");
            return asmerr.AsmError.UndefinedLabel;
        };
        try out.append(allocator, isa.JMP);
        try out.append(allocator, addr);
        return;
    }

    // Handle PUSH/POP (1 operand)
    if (std.mem.eql(u8, instr, "PUSH") or std.mem.eql(u8, instr, "POP")) {
        // Explicitly type this as u8!
        const opcode: u8 = if (std.mem.eql(u8, instr, "PUSH")) isa.PUSH else isa.POP;

        try out.append(allocator, opcode);
        const reg_str = parts.next() orelse return asmerr.AsmError.InvalidInstruction;
        try out.append(allocator, parseRegister(reg_str));
        return;
    }

    if (std.mem.eql(u8, instr, "CALL")) {
        const label = parts.next() orelse return asmerr.AsmError.InvalidInstruction;

        try out.append(allocator, isa.CALL);

        const addr = labels.get(label) orelse
            return asmerr.AsmError.UndefinedLabel;

        try out.append(allocator, addr);

        return;
    }
    if (std.mem.eql(u8, instr, "RET")) {
        try out.append(allocator, isa.RET);
        return;
    }
    // Handle 2-operand instructions (MOV, ADD, SUB, LD, ST)
    // We only call .next() here because we KNOW these instructions need two parts
    const r1_str = parts.next() orelse return asmerr.AsmError.InvalidInstruction;
    const r2_str = parts.next() orelse return asmerr.AsmError.InvalidInstruction;

    const r1 = parseRegister(r1_str);

    if (std.mem.eql(u8, instr, "MOV")) {
        try out.append(allocator, isa.MOV);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2_str, 10));
    } else if (std.mem.eql(u8, instr, "ADD")) {
        try out.append(allocator, isa.ADD);
        try out.append(allocator, r1);
        try out.append(allocator, parseRegister(r2_str));
    } else if (std.mem.eql(u8, instr, "SUB")) {
        try out.append(allocator, isa.SUB);
        try out.append(allocator, r1);
        try out.append(allocator, parseRegister(r2_str));
    } else if (std.mem.eql(u8, instr, "LD")) {
        try out.append(allocator, isa.LD);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2_str, 10));
    } else if (std.mem.eql(u8, instr, "ST")) {
        try out.append(allocator, isa.ST);
        try out.append(allocator, r1);
        try out.append(allocator, try std.fmt.parseInt(u8, r2_str, 10));
    } else if (std.mem.eql(u8, instr, "JZ")) {
        try out.append(allocator, isa.JZ);
        try out.append(allocator, r1);

        const label = r2_str;
        const addr = labels.get(label) orelse
            return asmerr.AsmError.UndefinedLabel;

        try out.append(allocator, addr);
    } else {
        asmerr.report(line_no, "invalid instruction");
        return asmerr.AsmError.InvalidInstruction;
    }
}

fn parseRegister(tok: []const u8) u8 {
    if (tok.len != 2 or tok[0] != 'R') {
        return 0; // will be caught later if needed
    }
    return tok[1] - '0';
}
