const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/24_allocators/src/main.zig#
// https://youtu.be/rxo0j08ctdQ?si=rnn_TX4APN9i3qko

// GeneralPurposeAllocator (gpa) - for scenarios where you do not need any special allocation strategy or any special behavior
// gpa benefits: when in debug mode, it will provide detection of memory leaks and double-frees

// const List = @import("list.zig").List;
const List = @import("list_arena.zig").List;

pub fn main() !void {
    // Our good old GPA.
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // .{<For configuring>}{} ... trailing {} Is the instantiation
    // defer std.debug.print("GPA result: {}\n", .{gpa.deinit()}); // <___ gpa deinit returns a status, this will print that status

    // Logs all allocations and frees.

    // For the arena... Logs every time that it allocates and every time that it frees
    var logging_alloc = std.heap.loggingAllocator(std.heap.page_allocator); //<____ pass in the child allocator that you want to log

    const allocator = logging_alloc.allocator();

    // Let's allocate!
    var list = try List(u8).init(allocator, 42); // 1
    defer list.deinit(); // free at scope exit
    try list.append(13); // 2
    try list.append(99); // 3

    // When integrating with C, use
    // std.heap.c_allocator;

    // When targetting WASM, use
    // std.heap.wasm_allocator;
}

test "Allocation failure" {
    const allocator = std.testing.failing_allocator;
    var list = List(u8).init(allocator, 42);
    try std.testing.expectError(error.OutOfMemory, list);
}

// Use a memory pool when all the objects being allocated have the same type.
// This is more efficient since previously allocated slots can be re-used
// instead of allocating new ones.
test "memory pool: basic" {
    const MemoryPool = std.heap.MemoryPool;

    var pool = MemoryPool(u32).init(std.testing.allocator);
    defer pool.deinit();

    const p1 = try pool.create();
    const p2 = try pool.create();
    const p3 = try pool.create();

    // Assert uniqueness
    try std.testing.expect(p1 != p2);
    try std.testing.expect(p1 != p3);
    try std.testing.expect(p2 != p3);

    pool.destroy(p2);
    const p4 = try pool.create();

    // Assert memory reuse
    try std.testing.expect(p2 == p4);
}
