// Utilities for different kinds of sequences including arithmetic sequences.
const std = @import("std");

// FIXME: Another cool function would be a function that takes two arithmetic
// sequences and adds or subtracts them. I have a feeling that this works out
// very nicely and imbues arithmetic sequences with a nice algebraic structure
// (at the very least, they are a group, but they should really be an infinite
// dimensional vector space).
//
// In general, an arithmetic sequence takes the form:
//
// k + d, k + 2 * d, k + 3 * d, ..., k + n * d
//
// We call k the "offset" of the sequence and d the "step size" of the sequence.
// The value n is the "index" of the sequence.
pub const Arithmetic = struct {
    k: u64,
    d: u64,

    // Initializes an arithmetic sequence.
    pub fn init(k: u64, d: u64) Arithmetic {
        return Arithmetic{
            .k = k,
            .d = d,
        };
    }

    // Finds the element of the sequence at a given index, n. This is just:
    //
    // element = k + n * d
    pub fn at(self: Arithmetic, n: u64) u64 {
        return self.k + n * self.d;
    }

    // Find the index of the greatest lower bound, the supremum, of the sequence
    // given a bound, b. In our case, the supremum must be strictly less than
    // the bound. If all of the elements of the sequence are greater than n, the
    // index of the supremum is 0.
    //
    // We can compute this by solving the following inequality:
    //
    // k + n * d < b
    //
    // This gives our bound:
    //
    // n < (b - k) / d
    pub fn sup(self: Arithmetic, b: u64) u64 {
        if (b <= self.k) {
            return 0;
        }

        // We have that n < (b - k) / d. Since we use integer division, the
        // supremum that we seek, s, will be equal to (b - k) / d if the
        // division rounds down, and it will be equal to (b - k) / d - 1 if
        // the division doesn't round down.
        if ((b - self.k) % self.d == 0) {
            return (b - self.k) / self.d - 1;
        }
        return (b - self.k) / self.d;
    }

    // FIXME: Add caveats for the requirements on the starting and ending indexes.
    //
    // FIXME: Just glancing at this, it looks like it can be further simplified.
    //
    // t(e - s) = ((e - s + 1) * (e - s))
    //
    // so we get
    //
    // sum = (e - s + 1) * (k + s * d) + ((e - s + 1) * (e - s)) * d / 2
    //     = (e - s + 1) * ((k + s * d) + ((e - s) * d) / 2
    //
    // FIXME: I can probably simplify this more, but I like the below formulation
    // more for now.
    //
    // Sums over an arithmetic sequence given a starting and ending index.
    // Given an arithmetic sequence (k + n * d), a starting index, s, and an
    // ending index, e, we can calculate the sum of the arithmetic sequence in
    // constant time.
    //
    // We use the following identity to simplify the sum:
    //
    // e = s + (e - s)
    //
    // The sum takes the form:
    //
    // sum = (k + s * d) + (k + (s + 1) * d) + ... + (k + e * d)
    //     = (e - s + 1) * k + s * d + (s + 1) * d + ... + e * d
    //     = (e - s + 1) * k + (s + 0) * d + (s + 1) * d + ... + (s + (e - s)) * d
    //     = (e - s + 1) * k + (e - s + 1) * s * d + (1 + ... (e - s)) * d
    //     = (e - s + 1) * (k + s * d) + (1 + ... + (e - s)) * d
    //
    // From this simplification, we see that it all boils down to triangular i
    // numbers. Since we can compute triangular numbers in constant time, we can
    // compute arithmetic series in constant time.
    pub fn sum(self: Arithmetic, s: u64, e: u64) u64 {
        // FIXME: Is this what we want to do?
        if (e < s) {
            return 0;
        }
        return (e - s + 1) * (self.k + s * self.d) + triangular(e - s) * self.d;
    }
};

test "Arithmetic.sup" {
    const sequence = Arithmetic{
        .k = 4,
        .d = 37,
    };
    const bound = [_]u64{ 1, 55, 10343, 1_000_000 };
    for (bound) |b| {
        const s = sequence.sup(b);
        if (sequence.at(0) > b) {
            try std.testing.expectEqual(s, 0);
        } else {
            // Ensure the element of the sequence at s is less than b.
            try std.testing.expect(sequence.at(s) < b);

            // Ensure the element of the sequence at s + 1 is greater than b.
            try std.testing.expect(sequence.at(s + 1) > b);
        }
    }
}

test "Arithmetic.sum" {
    const sequence = Arithmetic{
        .k = 4,
        .d = 37,
    };
    const start = [_]u64{ 1, 3, 30, 66 };
    const end = [_]u64{ 100, 777, 1000, 70000 };
    for (start, end) |s, e| {
        var expected: u64 = 0;
        for (s..(e + 1)) |n| {
            expected += sequence.k + n * sequence.d;
        }
        const actual = sequence.sum(s, e);
        try std.testing.expectEqual(expected, actual);
    }
}

// Triangular numbers are the sums of the simplest arithmetic sequence -- a
// sequence that starts at 1 and has a step size of 1. The nth triangular number
// takes the form:
//
// t(n) = 1 + 2 + ... + n
//
// If n is even, we can cleverly group the terms of this series to calculate
// the t(n) in constant time:
//
// t(n) = 1 + 2 + ... + n
//      = (1 + n) + (2 + (n - 1)) + ... + (n/2 + (n/2 + 1))
//
// Each term in t(n) is equal to n + 1 and there are a total of n/2 terms since
// we paired up the elements of the series. This gives us the simple formula:
//
// t(n) = ((n + 1) * n) / 2
//
// If n is odd, then n - 1 is even, and we have that:
//
// t(n) = 1 + 2 + ... + (n - 1) + n
//      = t(n - 1) + n
//      = ((n - 1) + 1) * (n - 1) / 2 + n
//      = n * (n - 1) / 2 + n
//      = (n^2 - n + 2 * n) / 2
//      = (n^2 + n) / 2
//      = ((n + 1) * n) / 2
//
// Thus, we can use (n + 1) * n/2 to calculate all triangular numbers in
// constant time.
pub fn triangular(n: u64) u64 {
    return ((n + 1) * n) / 2;
}

test "triangular" {
    const cases = [_]u64{ 1, 5, 100, 1000, 70000 };
    for (cases) |n| {
        var expected: u64 = 0;
        for (1..(n + 1)) |k| {
            expected += k;
        }
        const actual = triangular(n);
        try std.testing.expectEqual(expected, actual);
    }
}
