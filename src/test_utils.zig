const std = @import("std");
const mujoco_zig = @import("root.zig");
const MjModel = mujoco_zig.MjModel;
const MjSpec = mujoco_zig.MjSpec;
const testing = std.testing;

pub const BasicModelPath = "src/assets/hello.xml";
pub const BasicModelStr = @embedFile("assets/hello.xml");

pub fn loadBasicModel() !MjModel {
    mujoco_zig.init();

    const model: MjModel = try .fromXmlZ(BasicModelPath);

    return model;
}

pub fn loadBasicSpec() !MjSpec {
    mujoco_zig.init();

    const spec: MjSpec = try .fromXmlZ(BasicModelPath);

    return spec;
}

test loadBasicModel {
    const model: MjModel = try loadBasicModel();
    defer model.deinit();
}

test loadBasicSpec {
    const spec: MjSpec = try loadBasicSpec();
    defer spec.deinit();
}

test BasicModelStr {
    try testing.expect(BasicModelStr.len > 0);
}
