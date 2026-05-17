const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const ptr = try gpa.create(i32);
    defer gpa.destroy(ptr);

    try std.Io.File.stdout().writeStreamingAll(io, "Hello, world!\n");

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    for (args, 0..) |arg, i| {
        std.log.info("arg[{d}] = {s}", .{ i, arg });
    }

    std.log.info("{d} env vars", .{init.environ_map.count()});
}
