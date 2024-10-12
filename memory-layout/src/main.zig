const std = @import("std");

//https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/29_packed/src/main.zig#
// https://youtu.be/zdLYY9QhnZY?si=c9vFyIF9gbhpz1Nd

// An extern struct has a guaranteed memory layout compatible
// with the C ABI. Padding ensures alignment of fields and field
// order is preserved is in the source code.
const Extern = extern struct {
    a: u16, // natural align 2
    b: u64, // natural align 8
    c: u16, // natural align 2
};

// A normal struct in Zig has no guarantees regarding its memory
// layout. The compiler will determine the optimal layout, which may
// include padding to ensure proper alignment of fields.
const Normal = struct {
    a: u16,
    b: u64,
    c: u16,
};

// A packed struct preserves field order but packs fields
// together with no padding in between so fields only use
// their actual bit width in size. Padding may be used at the
// end to ensure alignment at the struct boundary in memory.
const Packed = packed struct {
    a: u16,
    b: u64,
    c: u16,
};

pub fn main() !void {
    printInfo(Extern);
    printInfo(Normal);
    printInfo(Packed);

    // Packed structs can be bit casted.
    const w = Whole{
        .num = 0x1234,
    };

    const p: Parts = @bitCast(w);

    std.debug.print("w.num: 0x{x}\n", .{w.num});
    std.debug.print("p.half: 0x{x}\n", .{p.half});
    std.debug.print("p.q3: 0x{x}\n", .{p.q3});
    std.debug.print("p.q4: 0x{x}\n", .{p.q4});
}

fn printInfo(comptime T: type) void {
    std.debug.print("size of {s}: {}\n", .{ @typeName(T), @sizeOf(T) });

    inline for (std.meta.fields(T)) |field| {
        std.debug.print("  field {s} byte offset: {}\n", .{ field.name, @offsetOf(T, field.name) });
    }

    std.debug.print("\n", .{});
}

const Whole = packed struct {
    num: u16,
};

const Parts = packed struct {
    half: u8,
    q3: u4,
    q4: u4,
};
