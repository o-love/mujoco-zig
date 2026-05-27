const std = @import("std");
const mujoco_zig = @import("../root.zig");
const log = @import("../log.zig");

const ffi = mujoco_zig.ffi;

const MjvCamera = @This();

raw: ffi.mjvCamera,

pub fn init() @This() {
    var camera: ffi.mjvCamera = undefined;

    ffi.mjv_defaultCamera(&camera);

    log.debug("Done initializing mjvCamera", .{});

    return .{
        .raw = camera,
    };
}

test "init" {
    const camera: MjvCamera = .init();
    _ = camera;
}
