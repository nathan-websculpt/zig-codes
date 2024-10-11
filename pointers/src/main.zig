const std = @import("std");

// https://codeberg.org/dude_the_builder/zig_in_depth/src/branch/main/09_pointers/src/main.zig#
// taking this ^^^ and adding notes from this:
// https://youtu.be/4j7MkMc0sN0?si=R6nFI-zkR9iJIiw7

pub fn main() !void {
    // Single item pointer to a constant.
    const a: u8 = 0;
    const a_ptr = &a; // type of: pointer to a const u8 // Defining a pointer to const a's location in memory using the & which is the "address of" operator

    // Trying to dereference (Obtain that value that it is pointing to) the pointer and increment the value
    // a_ptr.* += 1; // but you cannot assign to constant

    // NOTE: * is used to dereference a pointer
    std.debug.print("a_ptr: {}, type of a_ptr: {}\n", .{ a_ptr.*, @TypeOf(a_ptr) });

    /////////________________________________________>

    // Single item pointer to a variable.
    var b: u8 = 0;
    const b_ptr = &b; // type of: pointer to a u8
    b_ptr.* += 1; // This is OK, because the pointer is not pointing to a const
    std.debug.print("b_ptr: {}, type of b_ptr: {}\n", .{ b_ptr.*, @TypeOf(b_ptr) });

    // Both are const and can't be modified themselves.
    // a_ptr = &b; // error will be: "Cannot assign to a constant"
    // b_ptr = &a;

    // Use a var if you need to swap the pointer itself.
    var c_ptr = a_ptr; // inferring from type-of: a_ptr (which itself is a pointer to a const u8)
    c_ptr = b_ptr; // OK - in Zig, non-const to const can be coerced (not the other way around)
    std.debug.print("c_ptr: {}, type of c_ptr: {}\n", .{ c_ptr.*, @TypeOf(c_ptr) });

    std.debug.print("\n", .{});

    //////////__________________________________________________>

    // Multi-item pointer.
    var array = [_]u8{ 1, 2, 3, 4, 5, 6 };
    var multi_item_ptr: [*]u8 = &array; // [*] is a multi-item pointer
    std.debug.print("multi_item_ptr[0]: {}, type of multi_item_ptr: {}\n", .{ multi_item_ptr[0], @TypeOf(multi_item_ptr) });
    multi_item_ptr[1] += 1; // will take '2' and add '1'
    multi_item_ptr += 1; // Pointer arithmetic... adds 1 whole byte (because this is a u8 type) to the address

    // Now index 0 will actually be index 1 (after the Pointer Arithmetic)
    std.debug.print("multi_item_ptr[0]: {}, type of multi_item_ptr: {}\n", .{ multi_item_ptr[0], @TypeOf(multi_item_ptr) });
    multi_item_ptr -= 1; // Pointer arithmetic. //going back down to index 0
    std.debug.print("multi_item_ptr[0]: {}, type of multi_item_ptr: {}\n", .{ multi_item_ptr[0], @TypeOf(multi_item_ptr) });

    std.debug.print("\n", .{});

    // Pointer to array.
    const array_ptr = &array; // address to array that is different from the multi-item pointer // Convenient syntax, I guess this is like a single item pointer with functionality
    std.debug.print("array_ptr[0]: {}, type of array_ptr: {}\n", .{ array_ptr[0], @TypeOf(array_ptr) });
    array_ptr[1] += 1;
    std.debug.print("array_ptr[1]: {}, type of array_ptr: {}\n", .{ array_ptr[1], @TypeOf(array_ptr) });
    std.debug.print("array[1]: {}\n", .{array[1]});
    std.debug.print("array_ptr.len: {}\n", .{array_ptr.len});

    //NOTE: String literals are this type of pointer, a pointer to an array of characters

    std.debug.print("\n", .{});

    ////////______________________________________________________________________________________>

    // Sentinel terminated pointer.
    array[3] = 0;
    const sentinel_ptr: [*:0]const u8 = array[0..3 :0]; // a type of slicing syntax (indexing brackets that contain a range [0..3]) // <___ slicing example ::::::    ':0' Tells the compiler that this will be a sentinel terminated pointed (Where are the Sentinel is going to be 0)
    //^^^^ Up to but not including three where the Sentinel is 0

    std.debug.print("sentinel_ptr[1]: {}, type of sentinel_ptr: {}\n", .{ sentinel_ptr[1], @TypeOf(sentinel_ptr) });

    std.debug.print("\n", .{});

    // If you ever need the address as an integer.
    const address = @intFromPtr(sentinel_ptr);
    std.debug.print("address: {}, type of address: {}\n", .{ address, @TypeOf(address) });
    // and the other way around too.
    const g_ptr: [*:0]const u8 = @ptrFromInt(address);
    std.debug.print("g_ptr[1]: {}, type of g_ptr: {}\n", .{ g_ptr[1], @TypeOf(g_ptr) });

    std.debug.print("\n", .{});

    // Pointers cannot be null in Zig
    // If you need a pointer that can be null like in C, use an optional pointer.
    // optional pointer
    var optional_ptr: ?*const usize = null;
    std.debug.print("optional_ptr: {?}, type of optional_ptr: {}\n", .{ optional_ptr, @TypeOf(optional_ptr) });
    optional_ptr = &address; //actually the address of the usize in memory
    std.debug.print("optional_ptr.?.*: {}, type of optional_ptr: {}\n", .{ optional_ptr.?.*, @TypeOf(optional_ptr) });
    // The size of an optional pointer is the same as a normal pointer.
    std.debug.print("optional_ptr size: {}, *usize size: {}\n", .{ @sizeOf(@TypeOf(optional_ptr)), @sizeOf(*usize) });

    // There's also [*c] but that's only for transitioning from C code.
}
