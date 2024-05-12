const std = @import("std");
const math = @import("std").math;
const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;
const ArrayHashMap = @import("std").AutoArrayHashMap;
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
    if (bound < 2) {
        return primes_;
    }

    // If the bound is 2, return 2.
    if (bound == 2) {
        try primes_.append(2);
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
    try std.testing.expectEqualSlices(u64, &[_]u64{2}, primes_.items);

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

// Get the prime factors of a number, n.
pub fn factors(allocator: Allocator, n: u64) !ArrayList(u64) {
    // Get all of the primes less or equal to than the square root of the number.
    const ps = try primes(allocator, math.sqrt(n) + 1);
    defer ps.deinit();

    // Iterate through the list of primes. For each of the primes that divide
    // n, add it to the list of factors.
    var fs = ArrayList(u64).init(allocator);
    for (ps.items) |p| {
        if (n % p == 0) {
            try fs.append(p);
        }
    }

    // If the list of factors is currently empty, the number is either 0, 1, or
    // a prime itself.
    if (n > 1 and fs.items.len == 0) {
        try fs.append(n);
    }

    return fs;
}

test "factors" {
    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Get the prime factorization of 13,195.
    const fs = try factors(allocator, 13_195);
    defer fs.deinit();
    try std.testing.expectEqualSlices(u64, &[_]u64{ 5, 7, 13, 29 }, fs.items);
}

pub const PrimeFactor = struct {
    prime: u64,
    degree: u64,
};

// Get the prime factorization of a number, n.
pub fn factorization(allocator: Allocator, n: u64) !ArrayList(PrimeFactor) {
    // Instantiate an arraylist for the prime factorization of n.
    var fz = ArrayList(PrimeFactor).init(allocator);

    // Get the prime factors of n.
    var fs = try factors(allocator, n);
    defer fs.deinit();

    // If the list of prime factors is empty, we return early.
    if (fs.items.len == 0) {
        return fz;
    }

    // Otherwise, iterate through the list of prime factors. For each factor,
    // calculate the degree of the prime factor in n's prime factorization.
    for (fs.items) |p| {
        // Calculate the degree of the prime factor.
        var n_ = n / p;
        var d: u64 = 1;
        while (n_ % p == 0) {
            n_ /= p;
            d += 1;
        }

        // Add the prime factor to the factorization.
        try fz.append(PrimeFactor{
            .prime = p,
            .degree = d,
        });
    }

    return fz;
}

test "factorization" {
    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Get the prime factorization of 2.
    {
        const fs = try factorization(allocator, 2);
        defer fs.deinit();
        try std.testing.expectEqualSlices(PrimeFactor, &[_]PrimeFactor{PrimeFactor{
            .prime = 2,
            .degree = 1,
        }}, fs.items);
    }

    // Get the prime factorization of 8.
    {
        const fs = try factorization(allocator, 8);
        defer fs.deinit();
        try std.testing.expectEqualSlices(PrimeFactor, &[_]PrimeFactor{PrimeFactor{
            .prime = 2,
            .degree = 3,
        }}, fs.items);
    }

    // Get the prime factorization of 9.
    {
        const fs = try factorization(allocator, 9);
        defer fs.deinit();
        try std.testing.expectEqualSlices(PrimeFactor, &[_]PrimeFactor{PrimeFactor{
            .prime = 3,
            .degree = 2,
        }}, fs.items);
    }

    // Get the prime factorization of 16.
    {
        const fs = try factorization(allocator, 16);
        defer fs.deinit();
        try std.testing.expectEqualSlices(PrimeFactor, &[_]PrimeFactor{PrimeFactor{
            .prime = 2,
            .degree = 4,
        }}, fs.items);
    }

    // Get the prime factorization of 720.
    {
        const fs = try factorization(allocator, 720);
        defer fs.deinit();
        try std.testing.expectEqualSlices(PrimeFactor, &[_]PrimeFactor{
            PrimeFactor{
                .prime = 2,
                .degree = 4,
            },
            PrimeFactor{
                .prime = 3,
                .degree = 2,
            },
            PrimeFactor{
                .prime = 5,
                .degree = 1,
            },
        }, fs.items);
    }
}

// Gets the least common multiple of a set of numbers.
//
// The basic idea of this calculation is that we can take the prime
// factorization of each of the numbers, pick the highest degree of each of the
// primes in the prime factorization, and then multiply these prime factors
// together.
pub fn lcm(allocator: Allocator, ns: ArrayList(u64)) !u64 {
    // If there aren't any numbers in the arraylist, return 1.
    if (ns.items.len == 0) {
        return 1;
    }

    // If there is only one item in the arraylist, return the number in the
    // arraylist.
    if (ns.items.len == 1) {
        return ns.getLast();
    }

    // Instantiate an array hash map to store the largest degree encountered
    // for each prime factor.
    var fzs = ArrayHashMap(u64, u64).init(allocator);
    defer fzs.deinit();

    // Loop over the numbers. For each number, get the prime factorization. Then
    // we scan through the prime factorization and update the hash map with the
    // factor and degree if the degree is larger than the existing entry.
    for (ns.items) |n| {
        // Get the prime factorization of n.
        const fs = try factorization(allocator, n);
        defer fs.deinit();

        // Iterate over the prime factors. If the factor isn't in the hash map,
        // add it. If the factor's degree is larger than the degree in the hash
        // map, replace the existing entry.
        for (fs.items) |f| {
            const maybe_d = fzs.get(f.prime);
            if (maybe_d) |d| {
                if (f.degree > d) {
                    try fzs.put(f.prime, f.degree);
                }
            } else {
                try fzs.put(f.prime, f.degree);
            }
        }
    }

    // Iterate over the factors in the hashmap and accumulate them into the lcm.
    var m: u64 = 1;
    var iterator = fzs.iterator();
    while (iterator.next()) |f| {
        m *= try math.powi(u64, f.key_ptr.*, f.value_ptr.*);
    }

    return m;
}

test "lcm" {
    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Ensure that the lcm of 1 and 7 is 7.
    {
        var fs = ArrayList(u64).init(allocator);
        defer fs.deinit();
        try fs.append(1);
        try fs.append(7);
        try std.testing.expectEqual(lcm(allocator, fs), 7);
    }

    // Ensure that the lcm of 1..11 is 2520.
    {
        var fs = ArrayList(u64).init(allocator);
        defer fs.deinit();
        for (1..11) |i| {
            try fs.append(i);
        }
        try std.testing.expectEqual(lcm(allocator, fs), 2520);
    }
}
