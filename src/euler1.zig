const std = @import("std");
const sequence = @import("./sequence.zig");

// Find the sum of all multiples of 3 or 5 below 1000.
pub fn solver(bound: u64) u64 {
    // We can solve this by summing the arithmetic series:
    //
    // a(n) = 0 + 3 * n
    //
    // and
    //
    // b(n) = 0 + 5 * n
    //
    // We can them remove duplicates by subtracing the series:
    //
    // c(n) = 0 + 3 * 5 * n = 0 + 15 * n
    const a = sequence.Arithmetic{ .k = 0, .d = 3 };
    const b = sequence.Arithmetic{ .k = 0, .d = 5 };
    const c = sequence.Arithmetic{ .k = 0, .d = 15 };
    return a.sum(1, a.sup(bound)) + b.sum(1, b.sup(bound)) - c.sum(1, c.sup(bound));
}

test "euler1" {
    // Ensure that the function returns the correct result on the example.
    try std.testing.expectEqual(23, solver(10));

    // Ensure that the function returns the correct result on the real problem.
    try std.testing.expectEqual(233_168, solver(1_000));
}
