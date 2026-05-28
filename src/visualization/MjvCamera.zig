const std = @import("std");
const mujoco_zig = @import("../root.zig");
const log = @import("../log.zig");

const ffi = mujoco_zig.ffi;

const MjvCamera = @This();
const MjModel = mujoco_zig.MjModel;
const CameraType = mujoco_zig.enums.CameraType;
const MouseAction = mujoco_zig.enums.MouseAction;
const MjtNum = mujoco_zig.MjtNum;
const MjvScene = mujoco_zig.MjvScene;
const MjData = mujoco_zig.MjData;

raw: ffi.mjvCamera,

pub fn init() @This() {
    var camera: ffi.mjvCamera = undefined;

    ffi.mjv_defaultCamera(&camera);

    return .{
        .raw = camera,
    };
}

pub fn initFree(model: *const MjModel) @This() {
    var camera: ffi.mjvCamera = undefined;

    ffi.mjv_defaultFreeCamera(model.raw, &camera);

    return .{
        .raw = camera,
    };
}

pub fn toTrack(self: *@This(), track_body_id: u31) void {
    self.raw.type = @intFromEnum(CameraType.tracking);
    self.raw.trackbodyid = track_body_id;
    self.raw.fixedcamid = -1;
}

pub fn move(
    self: *@This(),
    model: *const MjModel,
    action: MouseAction,
    dx: MjtNum,
    dy: MjtNum,
    scene: *const MjvScene,
) void {
    ffi.mjv_moveCamera(
        model.raw,
        @intFromEnum(action),
        dx,
        dy,
        &scene.raw,
        self.raw,
    );
}

const Frame = struct {
    pos: [3]MjtNum,
    forward: [3]MjtNum,
    up: [3]MjtNum,
    right: [3]MjtNum,
};

pub fn frame(self: *const @This(), data: *const MjData) Frame {
    var frame_ret: Frame = .{};

    ffi.mjv_cameraFrame(
        &frame_ret.pos,
        &frame_ret.forward,
        &frame_ret.up,
        &frame_ret.right,
        data.raw,
        &self.raw,
    );

    return frame_ret;
}

test "init" {
    const camera: MjvCamera = .init();
    _ = camera;
}

test "initFree" {
    mujoco_zig.init();

    var model: MjModel = try @import("../test_utils.zig").loadBasicModel();
    defer model.deinit();

    const camera: MjvCamera = .initFree(&model);
    _ = camera;
}
