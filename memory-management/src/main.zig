const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/21_memory/src/main.zig#
// taking this ^^^ and adding notes from this:
// https://youtu.be/I_ynVBs66Oc?si=3ZEqeo7mmOoUgpla

// in Zig there is no default memory allocator
// When you are going to allocate memory on the heap, you have to specify which allocator you want to use

pub fn main() !void {}

// Take an output variable, returning number of bytes written into it.
fn catOutVarLen(
    a: []const u8,
    b: []const u8,
    out: []u8,
) usize {
    // Make sure we have enough space.
    std.debug.assert(out.len >= a.len + b.len);
    // Copy the bytes.
    std.mem.copy(u8, out, a);
    std.mem.copy(u8, out[a.len..], b);
    // Return the number of bytes copied.
    return a.len + b.len;
}

test "catOutVarLen" {
    const hello: []const u8 = "Hello ";
    const world: []const u8 = "world";

    // Our output buffer.
    var buf: [128]u8 = undefined;

    // Write to buffer, get length.
    const len = catOutVarLen(hello, world, &buf);
    try std.testing.expectEqualStrings(hello ++ world, buf[0..len]);
    // If you're feeling clever, you can also do this.
    try std.testing.expectEqualStrings(hello ++ world, buf[0..catOutVarLen(hello, world, &buf)]);
}

// Take an output variable returning a slice from it.
fn catOutVarSlice(
    a: []const u8,
    b: []const u8,
    out: []u8,
) []u8 {
    // Make sure we have enough space.
    std.debug.assert(out.len >= a.len + b.len);
    // Copy the bytes.
    std.mem.copy(u8, out, a);
    std.mem.copy(u8, out[a.len..], b);
    // Return the slice of copied bytes.
    return out[0 .. a.len + b.len];
}

test "catOutVarSlice" {
    const hello: []const u8 = "Hello ";
    const world: []const u8 = "world";

    // Our output buffer.
    var buf: [128]u8 = undefined;

    // Write to buffer get slice.
    const slice = catOutVarSlice(hello, world, &buf);
    try std.testing.expectEqualStrings(hello ++ world, slice);
}

// Take an allocator, return bytes allocated with it. Caller must free returned bytes.
fn catAlloc(
    allocator: std.mem.Allocator,
    a: []const u8,
    b: []const u8,
) ![]u8 {
    // Try to allocate enough space. Returns a []T on success.
    const bytes = try allocator.alloc(u8, a.len + b.len);
    // Copy the bytes.
    std.mem.copy(u8, bytes, a);
    std.mem.copy(u8, bytes[a.len..], b);
    // Return the allocated slice.
    return bytes;
}

test "catAlloc" {
    const hello: []const u8 = "Hello ";
    const world: []const u8 = "world";
    const allocator = std.testing.allocator;

    // Write to buffer get slice.
    const slice = try catAlloc(allocator, hello, world);
    defer allocator.free(slice);
    try std.testing.expectEqualStrings(hello ++ world, slice);
}

// Always fails; just to demonstrate errdefer.
fn mayFail() !void {
    return error.Boom;
}

// Run tests in sections.zig
test {
    _ = @import("sections.zig");
}
