const std = @import("std");
const euler1 = @import("euler1.zig");
const euler2 = @import("euler2.zig");
const euler3 = @import("euler3.zig");
const euler4 = @import("euler4.zig");
const euler5 = @import("euler5.zig");

pub fn main() !void {
    // Initialize the allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");
    const allocator = gpa.allocator();

    // Euler #1
    {
        std.debug.print("euler #1 = {d}\n", .{euler1.solver(1_000)});
    }

    // Euler #2
    {
        std.debug.print("euler #2 = {d}\n", .{euler2.solver(4_000_000)});
    }

    // Euler #3
    {
        const solution = try euler3.solver(allocator, 600_851_475_143);
        std.debug.print("euler #3 = {d}\n", .{solution});
    }

    // Euler #4
    {
        std.debug.print("euler #4 = {d}\n", .{euler4.solver(4)});
    }

    // Euler #5
    {
        const solution = try euler5.solver(allocator, 20);
        std.debug.print("euler #5 = {d}\n", .{solution});
    }
}
