const std = @import("std");
const mujoco_zig = @import("../root.zig");
const log = @import("../log.zig");

const ffi = mujoco_zig.ffi;

const MjvScene = @This();
const MjModel = mujoco_zig.MjModel;

raw: ffi.mjvScene,

pub fn init(model: *const MjModel, maxgeom: i32) !@This() {
    var scene: ffi.mjvScene = undefined;

    log.debug("Initializing mjvScene", .{});

    ffi.mjv_defaultScene(&scene);
    ffi.mjv_makeScene(model.model, &scene, maxgeom);

    log.debug("Finished initializing MjvScene", .{});

    return .{
        .raw = scene
    };
}

pub fn deinit(self: *@This()) void {
    ffi.mjv_freeScene(&self.raw);
}

test "init and deinit" {
    const testing = std.testing;
    const model_path = @import("../test_utils.zig").BasicModelPath;
    mujoco_zig.init();

    var model: MjModel = try .from_xml(model_path, testing.allocator);
    defer model.deinit();

    var scene: MjvScene = try .init(&model, 1000);
    defer scene.deinit();
}