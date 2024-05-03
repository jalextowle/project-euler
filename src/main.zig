const std = @import("std");
const sequence = @import("sequence.zig");

pub fn main() void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("Hello, world!\n", .{});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

// Find the sum of all multiples of 3 or 5 below 1000.
fn euler1() u64 {
    // FIXME: I need a function that gives me all of the multiples of 3 and 5
    // that are less than 1000. This is a small enough problem to just brute
    // force this.
    //
    // I can be more clever though. Disecting the problem, there are three
    // arithmetic progressions to think through:
    //
    // a =     3,     6,     9, ...
    //   = 1 * 3, 2 * 3, 3 * 3, ...
    //
    // b =     5,    10,    15, ...
    //     1 * 5, 2 * 5, 3 * 5, ...
    //
    // c =       15,        30,        45, ...
    //     1 * 3 * 5, 2 * 3 * 5, 3 * 3 * 5, ...
    //
    // Just to think about arithmetic series for a moment,
    //
    // s_a(1, 3) = a_1 + a_2 + a_3
    //           = k * d + (k + 1) * d + (k + 2) * d
    //           = d * (k + (k + 1) + (k + 2))
    //
    // How do I efficiently compute the sum k + (k + 1) + (k + 2) + ...?
    //
    // Let's call this k(1, n) = (k + 1) + ... + (k + n)
    //
    // Then, k(1, n) = n * k + (1 + 2 + 3 + ... + n)
    //
    // s_a(1, n) = a
}
