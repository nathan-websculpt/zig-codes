const std = @import("std");

// https://youtu.be/aUSYxDg6RYM?si=VaPbqQ1K0rsu641_
// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/23_arena/src/main.zig#

// const List = @import("list.zig").List;
const List = @import("list_arena.zig").List;

pub fn main() !void {
    // We use the GeneralPurposeAllocator for normal allocations.
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();

    // We use the page_allocator as backing allocator for the
    // ArenaAllocator. page_allocator is not recommended for
    // normal allocations since it allocates a full page of
    // memory per allocation.
    const allocator = std.heap.page_allocator;

    const iterations: usize = 100;
    const item_count: usize = 1_000;

    // Start the timer.
    var timer = try std.time.Timer.start();

    // Loop
    for (0..iterations) |_| {
        // Create the list.
        var list = try List(usize).init(allocator, 13);
        errdefer list.deinit();
        // Add items, allocating each time.
        for (0..item_count) |i| try list.append(i);
        // Free allocated memory. Once per item for
        // non-arena List; only once for arena List.
        list.deinit();
    }

    // Get elapsed time in milliseconds.
    var took: f64 = @floatFromInt(timer.read());
    took /= std.time.ns_per_ms;
    // Report
    std.debug.print("took: {d:.2}ms\n", .{took});
}
