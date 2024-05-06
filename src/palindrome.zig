// Determines whether or not a given number, n, is a palindrome.
//
// This algorithm checks to see if a number is a palindrome without processing
// every digit of the palindrome or checking to see the number of digits of n.
pub fn is_palindrome(n: u64) bool {
    // If n is a single digit number, it is a palindrome.
    if (n < 10) {
        return true;
    }
    // Otherwise, if the first digit is zero, n is not a palindrome. This edge
    // case would cause the algorithm to have false positives since k wouldn't
    // be initialized.
    if (n % 10 == 0) {
        return false;
    }

    // Loop over each digit of n and accumulate the digits into k. Stop when
    // k > n since this signifies that k contains more than half of the digits
    // of n.
    var n_: u64 = n;
    var k: u64 = 0;
    var d: u64 = 0;
    while (k < n_) : (d += 1) {
        // Read n into k backwards, digit by digit.
        k = k * 10 + n_ % 10;
        n_ /= 10;
    }

    // If k is equal to n, then n is a palindrome with an even number of
    // digits.
    if (k == n_) {
        return true;
    }

    // If k > n and n > 0, it's still possible that n is a palindrome. If k/10
    // equals n, then n is a palindrome with an odd number of digits.
    if (n_ > 0 and k / 10 == n_) {
        return true;
    }

    // n is not a palindrome.
    return false;
}

test "is_palindrome" {
    const std = @import("std");

    // Ensure that all of the single digit numbers are palindromes.
    for (0..10) |n| {
        try std.testing.expect(is_palindrome(n));
    }

    // Ensure that 10 is not a palindrome.
    try std.testing.expect(!is_palindrome(10));

    // Ensure that 11 is a palindrome.
    try std.testing.expect(is_palindrome(11));

    // Ensure that 100 is not a palindrome.
    try std.testing.expect(!is_palindrome(100));

    // Ensure that 101 is a palindrome.
    try std.testing.expect(is_palindrome(101));

    // Ensure that 1331 is a palindrome.
    try std.testing.expect(is_palindrome(1331));

    // Ensure that 9009 is a palindrome.
    try std.testing.expect(is_palindrome(9009));

    // Ensure that 941490 is not a palindrome.
    try std.testing.expect(!is_palindrome(941490));

    // Ensure that 941409 is not a palindrome.
    try std.testing.expect(!is_palindrome(941409));

    // Ensure that 94140009 is not a palindrome.
    try std.testing.expect(!is_palindrome(94140009));

    // Ensure that 1358531 is a palindrome.
    try std.testing.expect(is_palindrome(1358531));

    // Ensure that 13588531 is a palindrome.
    try std.testing.expect(is_palindrome(13588531));

    // Ensure that 1348531 is not a palindrome.
    try std.testing.expect(!is_palindrome(1348531));
}
