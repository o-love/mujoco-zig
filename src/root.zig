const std = @import("std");
const Io = std.Io;
const c = @import("c");

pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("Run `zig build test` to run the tests.\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

test "load hello mujoco model" {
    var buffer: [1024]u8 = undefined;
    _ = c.mj_loadXML("hello.xml", null, &buffer, 1000);
}
