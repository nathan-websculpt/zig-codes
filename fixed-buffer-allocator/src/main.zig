const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/22_fba/src/main.zig#
// https://youtu.be/5jht76c1cVI?si=DywmUJrUWfPQCao6

// This is for situations when you know how much memory you need ahead of time
// Strictly using memory on the stack (bytes/buffer)
// Faster than using memory allocated on the heap (Because when you allocate on the heap you have to make a request to the operating system)

// Returns the concatenation of `a` and `b` as newly allocated bytes.
// Caller must free returned bytes with `allocator`.
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

test "fba bytes" {
    // Each string has six bytes
    const hello = "Hello ";
    const world = "world!";

    // If we know the required memory size in advance, we can create
    // a fixed-size array for it as a buffer.
    var buf: [12]u8 = undefined;
    // And then use that buffer as the backing-store for a FixedBufferAllocator.
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator(); //All the allocators follow this approach

    const result = try catAlloc(allocator, hello, world);
    defer allocator.free(result);

    try std.testing.expectEqualStrings(hello ++ world, result);

    // no need to deinit the fba, because this is memory on the stack
}

// Returns a slice with elements of the type of `item` and length `n`.
// Caller must free returned slice with `allocator`.
fn sliceOfAlloc(
    allocator: std.mem.Allocator,
    item: anytype,
    n: usize, // how much memory we'll be allocating
) ![]@TypeOf(item) {
    const slice = try allocator.alloc(@TypeOf(item), n);
    for (slice) |*e| e.* = item;
    return slice;
}

test "fba structs" {
    const Foo = struct {
        a: u8 = 42,
        b: []const u8 = "Hello world!",
    };

    // Our inputs.
    const foo = Foo{};
    const n = 2;

    // The buffer must always be an array of bytes, so we must
    // calculate the size of the items in bytes using `@sizeOf`.
    var buf: [n * @sizeOf(Foo)]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    const result = try sliceOfAlloc(allocator, foo, n);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(Foo, &[_]Foo{ foo, foo }, result);
}

pub fn main() !void {
    std.debug.print("Run zig build test --summary all\n", .{});
}
