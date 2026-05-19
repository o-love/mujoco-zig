const std = @import("std");
const mujoco_zig = @import("../root.zig");

const ffi = mujoco_zig.ffi;

raw: ffi.mjvCamera,

pub fn init() @This() {
    var camera: ffi.mjvCamera = undefined;

    ffi.mjv_defaultCamera(&camera);

    return .{};
}
