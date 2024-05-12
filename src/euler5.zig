const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;
const lcm = @import("./prime.zig").lcm;

// 2520 is the smallest number that can be divided by each of the numbers from
// 1 to 10 without any remainder. What is the smallest positive number that is
// evenly divisible by all of the numbers from 1 to 20?
pub fn solver(allocator: Allocator, max: u64) !u64 {
    // This problem simply amounts to finding the least common multiples in the
    // list 1..max+1.
    var ns = ArrayList(u64).init(allocator);
    defer ns.deinit();
    for (1..max + 1) |n| {
        try ns.append(n);
    }
    return lcm(allocator, ns);
}

test "solver" {
    const std = @import("std");

    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Ensure that the function returns the correct result on the example.
    try std.testing.expectEqual(2520, solver(allocator, 10));

    // Ensure that the function returns the correct result on the real problem.
    try std.testing.expectEqual(232792560, solver(20));
}
