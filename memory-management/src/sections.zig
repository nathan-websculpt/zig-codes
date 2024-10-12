const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/21_memory/src/sections.zig#

// Memory Sections or Where are the bytes?

// Stored in global constant section of memory.
const pi: f64 = 3.1415;
const greeting = "Hello";

// Stored in the global data section.
var count: usize = 0;

fn locals() u8 {
    // All of these local variables are gone
    // once the function exits. They live on the
    // function's stack frame.
    var a: u8 = 1;
    var b: u8 = 2;
    var result: u8 = a + b;
    // Here a copy of result is returned,
    // since it's a primitive numeric type.
    return result;
}

fn badIdea1() *u8 {
    // `x` lives on the stack.
    var x: u8 = 42;
    // Invalid pointer once the function returns
    // and its stack frame is destroyed.
    return &x;
}

fn badIdea2() []u8 {
    var array: [5]u8 = .{ 'H', 'e', 'l', 'l', 'o' };
    // Remember, a slice is also a pointer!
    var s = array[2..];
    // This is an error since `array` will be destroyed
    // when the function returns. `s` will be left dangling.
    return s;
}

// Caller must free returned bytes.
fn goodIdea(allocator: std.mem.Allocator) std.mem.Allocator.Error![]u8 {
    var array: [5]u8 = .{ 'H', 'e', 'l', 'l', 'o' };
    // `s` is a []u8 with length 5 and a pointer to bytes on the heap.
    const s = try allocator.alloc(u8, 5);
    std.mem.copy(u8, s, &array);
    // This is OK since `s` points to bytes allocated on the
    // heap and thus outlives the function's stack frame.
    return s;
}

const Foo = struct {
    s: []u8,

    // When a type needs to initialized resources, such as allocating
    // memory, it's convention to do it in a `init` method.
    fn init(allocator: std.mem.Allocator, s: []const u8) !*Foo {
        // `create` allocates space on the heap for a single value.
        // It returns a pointer.
        const foo_ptr = try allocator.create(Foo);
        errdefer allocator.destroy(foo_ptr);
        // `alloc` allocates space on the heap for many values.
        // It returns a slice.
        foo_ptr.s = try allocator.alloc(u8, s.len);
        std.mem.copy(u8, foo_ptr.s, s);
        // Or: foo_ptr.s = try allocator.dupe(s);

        return foo_ptr;
    }

    // When a type needs to clean-up resources, it's convention
    // to do it in a `deinit` method.
    fn deinit(self: *Foo, allocator: std.mem.Allocator) void {
        // `free` works on slices allocated with `alloc`.
        allocator.free(self.s);
        // `destroy` works on pointers allocated with `create`.
        allocator.destroy(self);
    }
};

test Foo {
    const allocator = std.testing.allocator;
    var foo_ptr = try Foo.init(allocator, greeting);
    defer foo_ptr.deinit(allocator);

    try std.testing.expectEqualStrings(greeting, foo_ptr.s);
}
