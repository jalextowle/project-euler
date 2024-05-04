const std = @import("std");
const euler1 = @import("euler1.zig");

pub fn main() void {
    // Prints the answer to the first euler problem.
    std.debug.print("euler #1 = {d}\n", .{euler1.solver(1_000)});
}
