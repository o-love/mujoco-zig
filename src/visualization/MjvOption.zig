const std = @import("std");
const mujoco_zig = @import("../root.zig");

const ffi = mujoco_zig.ffi;

const MjvOption = @This();

raw: ffi.mjvOption,

pub fn init() @This() {
    var option: ffi.mjvOption = undefined;

    ffi.mjv_defaultOption(&option);

    return .{
        .raw = option,
    };
}

test "init" {
    const option: MjvOption = .init();
    _ = option;
}
