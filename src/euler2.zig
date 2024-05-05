const std = @import("std");

// Find the sum of the even-valued terms of the fibonacci sequence that do not
// exceed 4 million.
pub fn solver(bound: u64) u64 {
    // Sum over all of the even-values of the fibonnaci sequence that don't
    // exceed the bound.
    var sum: u64 = 0;
    var last: u64 = 1;
    var cur: u64 = 1;
    while (true) {
        // Compute the next step of the fibonacci sequence.
        const last_ = cur;
        cur = cur + last;
        last = last_;

        // If the current value exceeds the bound, exit the loop.
        if (cur > bound) {
            break;
        }
        // Otherwise, if the current value is even, add it to the sum.
        else if (cur % 2 == 0) {
            sum += cur;
        }
    }

    return sum;
}

test "euler2" {
    try std.testing.expectEqual(44, solver(100));
    try std.testing.expectEqual(4_613_732, solver(4_000_000));
}
