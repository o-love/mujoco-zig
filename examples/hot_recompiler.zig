const std = @import("std");
const mujoco_zig = @import("mujoco_zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    mujoco_zig.init();

    _ = io;
}
