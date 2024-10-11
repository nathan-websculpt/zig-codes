const std = @import("std");

pub fn main() anyerror!void {
    std.log.info("Ello, Gubna!", .{});
    std.debug.print("Ello, Gubna!\n", .{});
}
