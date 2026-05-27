const std = @import("std");
const mujoco_zig = @import("../root.zig");
const log = @import("../log.zig");

const ffi = mujoco_zig.ffi;

const MjvPerturb = @This();
const MjData = mujoco_zig.MjData;
const MjvScene = mujoco_zig.MjvScene;
const MjModel = mujoco_zig.MjModel;

raw: ffi.mjvPerturb,

pub fn init(
    data: *MjData,
    scene: *const MjvScene,
) @This() {
    var self: @This() = .default();

    ffi.mjv_initPerturb(data.model.raw, data.raw, &scene.raw, &self.raw);

    return self;
}

pub fn default() @This() {
    var perturb: ffi.mjvPerturb = undefined;

    ffi.mjv_defaultPerturb(&perturb);

    return .{
        .raw = perturb,
    };
}

test "default MjvPerturb" {
    const perturb: MjvPerturb = .default();
    _ = perturb;
}

test "init MjvPerturb" {
    const testing = std.testing;
    const model_path = @import("../test_utils.zig").BasicModelPath;
    mujoco_zig.init();

    var model: MjModel = try .fromXml(testing.allocator, model_path);
    defer model.deinit();

    var data: MjData = try model.data();
    defer data.deinit();

    var scene: MjvScene = try .init(&model, 1000);
    defer scene.deinit();

    const perturb: MjvPerturb = .init(&data, &scene);
    _ = perturb;
}
