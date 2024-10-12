const std = @import("std");
const debug = std.debug;
const io = std.io;
const process = std.process;

const clap = @import("clap");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/45_cli_args/src/main.zig#
// https://youtu.be/76_VHwQ6MyM?si=B6AbgkbTHxTJYaKK

pub fn main() !void {
    debug.print("\nNo alloc:\n", .{});
    // In non-Windows systems, you can get an iterator
    //  over the command line args with std.process.args.
    //  No allocator needed.
    var args_no_alloc_iter = process.args();

    // The first item is the binary being executed.
    debug.print("binary: {s}\n", .{args_no_alloc_iter.next().?});

    // Then the rest are the actual args passed to the program.
    var i: usize = 1;
    while (args_no_alloc_iter.next()) |arg| : (i += 1) debug.print("arg #{}: {s}\n", .{ i, arg });

    // On Windows, you need an allocator. :-/
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    debug.print("\nAlloc:\n", .{});
    var args_alloc_iter = try process.argsWithAllocator(allocator);
    // Since we're allocating, we need to free resources
    // when finished.
    defer args_alloc_iter.deinit();

    // Then, same as above.
    debug.print("binary: {s}\n", .{args_alloc_iter.next().?});
    i = 1;
    while (args_alloc_iter.next()) |arg| : (i += 1) debug.print("arg #{}: {s}\n", .{ i, arg });

    debug.print("\nzig-clap\n", .{});
    // zig-clap is a powrful command line args parser from the
    // Zig ecosystem. https://github.com/Hejsil/zig-clap

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-n, --number <usize>   An option parameter, which takes a value.
        \\-s, --string <str>...  An option parameter which can be specified multiple times.
        \\<str>...
        \\
    );

    // Parse and display help message on error.
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = null,
        .allocator = allocator,
    }) catch {
        return clap.help(io.getStdErr().writer(), clap.Help, &params, .{});
    };
    defer res.deinit();

    // Now you can use the args. They have the corresponding Zig types.
    // A boolean flag
    if (res.args.help != 0)
        return clap.help(io.getStdErr().writer(), clap.Help, &params, .{});
    // A single numeric arg (usize)
    if (res.args.number) |n|
        debug.print("--number = {}\n", .{n});
    // Multiple string args ([]const []const u8)
    for (res.args.string) |s|
        debug.print("--string = {s}\n", .{s});
    // Any other positional args ([]const []const u8)
    for (res.positionals) |pos|
        debug.print("{s}\n", .{pos});
}
