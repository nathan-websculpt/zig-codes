const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/24_allocators/src/list.zig#
// https://youtu.be/rxo0j08ctdQ?si=rnn_TX4APN9i3qko

/// A generic linked list that uses the provided allocator.
pub fn List(comptime T: type) type {
    return struct {
        const Node = struct {
            allocator: std.mem.Allocator,
            data: T,
            next: ?*Node,

            fn init(allocator: std.mem.Allocator, data: T) !*Node {
                const ptr = try allocator.create(Node);
                ptr.allocator = allocator;
                ptr.data = data;
                ptr.next = null;

                return ptr;
            }

            fn deinit(self: *Node) void {
                if (self.next) |ptr| ptr.deinit();
                self.allocator.destroy(self);
            }
        };

        const Self = @This();

        allocator: std.mem.Allocator,
        head: *Node,

        pub fn init(allocator: std.mem.Allocator, data: T) !Self {
            return .{
                .allocator = allocator,
                .head = try Node.init(allocator, data),
            };
        }

        pub fn deinit(self: *Self) void {
            self.head.deinit();
        }

        pub fn append(self: *Self, data: T) !void {
            var tail: *Node = self.head;
            while (tail.next) |ptr| tail = ptr;
            tail.next = try Node.init(self.allocator, data);
        }

        pub fn lookup(self: Self, data: T) bool {
            var current: ?*Node = self.head;

            return while (current) |node_ptr| {
                if (node_ptr.data == data) break true;
                current = node_ptr.next;
            } else false;
        }
    };
}
