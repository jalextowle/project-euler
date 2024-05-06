const math = @import("std").math;
const is_palindrome = @import("./palindrome.zig").is_palindrome;

// A palindromic number reads the same both ways. The largest palindrome made
// from the product of two-digit numbers is 9009 = 91 * 99.
//
// Find the largest palindrome made from a product of two 3-digit numbers.
pub fn solver(digits: u64) u64 {
    // If the number of digits is 0, panic since the input doesn't make sense.
    if (digits == 0) {
        @panic("zero digits");
    }

    // Find the maximum and minimum integers with the specified number of digits.
    var m: u64 = 0;
    for (0..digits) |_| {
        // Fill in the maximum integer with all 9s.
        m = m * 10 + 9;
    }
    const n: u64 = math.pow(u64, 10, digits - 1);

    // Find the maximum palindrome
    var max_palindrome: u64 = 0;
    var i: u64 = m;
    while (i >= n) : (i -= 1) {
        var j: u64 = m;
        while (j >= n) : (j -= 1) {
            const product = i * j;
            if (is_palindrome(product) and product > max_palindrome) {
                max_palindrome = product;
            }
        }
    }

    return max_palindrome;
}

test "euler4" {
    const std = @import("std");

    // Ensure that the function returns the correct result on the example.
    try std.testing.expectEqual(9009, solver(2));

    // Ensure that the function returns the correct result on the real problem.
    try std.testing.expectEqual(906609, solver(3));
}
