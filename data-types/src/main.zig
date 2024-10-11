const std = @import("std");

pub fn main() anyerror!void {
    // Integers, Signed and unsigned
    // i1, u1 // 1 bit
    // i8, u8
    // i16, u16
    // i32, u32
    // i64, u64,
    // i128, u128
    // isize, usize // Depends upon the architecture of your system (pointer-sized integer on the target platform)
    var example: u32 = 10;
    example = 30;

    std.debug.print("Size of a u1 type is: {} bytes\n", .{@sizeOf(u1)}); // Should be one byte

    std.debug.print("{}, Size of example number: {} bytes\n", .{ example, @sizeOf(@TypeOf(example)) }); // Should be four bytes

    // Floating-point
    // f32, f64, f80 ....

    // Boolean
    const is_bool: bool = true;

    // NOTE: You will get compiler errors if you have variables that are not used, here's the way to get around that
    _ = is_bool; // Tell the compiler that this is not used

    // Struct: https://ziglang.org/documentation/master/#struct
    // Zig gives no guarantees about the order of fields and the size of
    // the struct but the fields are guaranteed to be ABI-aligned.
    // const Point = struct {
    //     x: f32,
    //     y: f32,
    // };

    // Enum: https://ziglang.org/documentation/master/#enum
    // A set of named constants
    // Declare an enum.
    const Type = enum {
        ok,
        not_ok,
    };
    // Declare a specific enum field.
    const c = Type.ok;

    std.debug.print("Selected enum is: {}\n\n", .{c});

    // Unions: https://ziglang.org/documentation/master/#union
    // Allows you to define a type that can hold one of several different types at a time.
    // This is particularly useful for representing data structures that can have different types of values.
    // A bare union defines a set of possible types that a value can be as a list of fields.
    // Only one field can be active at a time.
    // const Payload = union {
    //     int: i64,
    //     float: f64,
    //     boolean: bool,
    // };

    // Type

    // Function call
    const numOne: i32 = 10;
    const numTwo: i32 = 20;
    std.debug.print("Result of add(): {}\n", .{add(numOne, numTwo)});
}

//simple function
fn add(a: i32, b: i32) i32 {
    return a + b;
}
