const Allocator = @import("std").mem.Allocator;
const factorization = @import("./prime.zig").factorization;

// What is the largest prime factor of the number 600,851,475,143?
pub fn solver(allocator: Allocator, n: u64) !u64 {
    // Get the prime factorization of n.
    var factors = try factorization(allocator, n);
    defer factors.deinit();

    // Return the last element of the factorization.
    return factors.pop();
}

test "euler3" {
    const std = @import("std");

    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Ensure that the function returns the correct result on the example.
    try std.testing.expectEqual(29, solver(allocator, 13_195));

    // Ensure that the function returns the correct result on the real problem.
    try std.testing.expectEqual(6857, solver(allocator, 60_0851_475_143));
}
