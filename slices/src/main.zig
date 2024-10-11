const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/10_slices/src/main.zig#
// taking this ^^^ and adding notes from this:
// https://youtu.be/tFeB-LD7rks?si=9o_zylC23yR4bbts

pub fn main() !void {
    // If you slice with comptime known bounds, the result
    // is not a slice but rather a pointer to an array.
    var array = [_]u8{ 0, 1, 2, 3, 4, 5 };
    const array_ptr = array[0..array.len];
    std.debug.print("array_ptr type: {}\n", .{@TypeOf(array_ptr)});

    std.debug.print("\n", .{});

    // So we need this runtime zero to force getting
    // a slice versus a pointer to an array.
    var zero: usize = 0;

    // You get a slice by using slicing syntax.
    // []u8 is a slice of u8
    const a_slice: []u8 = &array; // or array[zero..] or array[zero..array.len]
    a_slice[0] += 1; // even though a_slice is const, the data that it is referring to isn't const

    std.debug.print("a_slice[0]: {}, a_slice.len: {}\n", .{ a_slice[0], a_slice.len });
    // ^^^ slices have .len BUT, length isn't a part of the type -- length is a runtime-known value

    std.debug.print("\n", .{});

    // In Zig, a slice is a multi-item pointer and a length (usize).
    std.debug.print("type of a_slice.ptr: {}\n", .{@TypeOf(a_slice.ptr)});
    std.debug.print("type of a_slice.len: {}\n", .{@TypeOf(a_slice.len)});

    std.debug.print("\n", .{});

    // Which means we can directly manipulate it if needed.
    var b_slice = array[zero..];
    b_slice.ptr += 2; // pointer arithmetic on multi-item pointer
    // Now it's up to us to update the length or suffer nasty consequences later on.
    b_slice.len -= 2;
    std.debug.print("b_slice: {any}\n", .{b_slice});

    std.debug.print("\n", .{});

    // No problem in slicing a slice. Note we force a const slice
    // by explicitly specifying the result type.
    const c_slice: []const u8 = a_slice[0..3];
    std.debug.print("c_slice: {any}\n", .{c_slice});

    // Slices have bounds checking.
    // b_slice[10] = 9;

    std.debug.print("\n", .{});

    // You can slice a pointer to an array.
    const d_slice = array_ptr[zero..2];
    std.debug.print("d_slice: {any}\n", .{d_slice});

    std.debug.print("\n", .{});

    // A sentinel terminated slice is very similar to a sentinel
    // terminated pointer.
    array[4] = 0;
    const e_slice: [:0]u8 = array[0..4 :0];
    std.debug.print("e_slice[e_slice.len]: {}\n", .{e_slice[e_slice.len]});

    std.debug.print("\n", .{});

    // A useful idiom is slicing by length.
    var start: usize = 2;
    var length: usize = 4;
    const f_slice = array[start..][0..length];
    std.debug.print("f_slice: {any}\n", .{f_slice});
}
