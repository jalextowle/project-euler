const std = @import("std");
const math = @import("std").math;
const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;
const HashMap = @import("std").AutoHashMap;

// TODO: Replace the HashMap with a BitSet for efficiency.
//
// Find all of the primes below the bound using the Sieve of Eratosthenes.
pub fn primes(allocator: Allocator, bound: u64) !ArrayList(u64) {
    // Instantiate a hashmap for the composites added to the sieve and the list
    // of primes.
    var composites = HashMap(u64, void).init(allocator);
    defer composites.deinit();
    var primes_ = ArrayList(u64).init(allocator);

    // If the bound is less than or equal to  2, return the empty arraylist.
    if (bound <= 2) {
        return primes_;
    }

    // Fill up the list of primes using the Sieve of Eratosthenes.
    var cur: u64 = 2;
    while (cur < bound) {
        // Append the new prime to the arraylist.
        try primes_.append(cur);

        // The current value is prime since it wasn't in the composites list.
        // Fill up the composites map with the multiples of the prime.
        if (bound / cur >= 2) {
            for (2..bound / cur + 1) |k| {
                try composites.put(cur * k, undefined);
            }
        }

        // Increase the current value until we find a value that isn't in the
        // composites map. If we exceed the bound, we break out of the loop.
        cur += 1;
        while (composites.get(cur) != null and cur < bound) {
            cur += 1;
        }
    }

    return primes_;
}

test "primes" {
    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Get all of the primes less than or equal to 2. This should be empty.
    const primes_ = try primes(allocator, 2);
    defer primes_.deinit();
    try std.testing.expect(primes_.items.len == 0);

    // Get all of the primes less than 150. For each of these primes, iterate
    // through the list of primes that were returned and verify that none of
    // the primes divide the included primes except for themselves.
    const primes__ = try primes(allocator, 150);
    defer primes__.deinit();
    for (primes__.items) |p| {
        for (primes__.items) |q| {
            if (p != q) {
                try std.testing.expect(p % q != 0);
            }
        }
    }
}

// Get the prime factorization of a number, n.
pub fn factorization(allocator: Allocator, n: u64) !ArrayList(u64) {
    // Get all of the primes less than the square root of the number.
    const primes_ = try primes(allocator, math.sqrt(n));
    defer primes_.deinit();

    // Iterate through the list of primes. For each of the primes that divide
    // n, add it to the list of factors.
    var factors = ArrayList(u64).init(allocator);
    for (primes_.items) |p| {
        if (n % p == 0) {
            try factors.append(p);
        }
    }

    return factors;
}

test "factorization" {
    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Get the prime factorization of 13,195.
    const factors = try factorization(allocator, 13_195);
    defer factors.deinit();
    try std.testing.expectEqualSlices(u64, &[_]u64{ 5, 7, 13, 29 }, factors.items);
}
