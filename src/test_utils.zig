const std = @import("std");
const mujoco_zig = @import("root.zig");
const MjModel = mujoco_zig.MjModel;

pub const BasicModelPath = "src/assets/hello.xml";
pub const BasicModelStr = @embedFile("assets/hello.xml");

pub fn loadBasicModel() !MjModel {
    mujoco_zig.init();

    const model: MjModel = try .fromXmlZ(BasicModelPath);

    return model;
}
