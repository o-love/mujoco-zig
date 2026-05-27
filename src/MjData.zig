const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;
const MjModel = mujoco_zig.MjModel;

const MjData = @This();

raw: *ffi.mjData,
model: *const MjModel,

pub fn new(model: MjModel) !@This() {
    const data = try model.data();

    return data;
}

pub fn from_raw(data: *ffi.mjData, model: *const MjModel) @This() {
    return .{
        .raw = data,
        .model = model,
    };
}

pub fn deinit(self: *@This()) void {
    ffi.mj_deleteData(self.raw);

    self.model = undefined;
    self.raw = undefined;
}

pub fn step(self: *@This()) !void {
    ffi.mj_step(self.model.raw, self.raw);
}

test "ffi: load hello mujoco model" {
    const model_path = @import("test_utils.zig").BasicModelPath;

    var buffer: [1024]u8 = undefined;
    const model = ffi.mj_loadXML(model_path, null, &buffer, 1000);
    defer ffi.mj_deleteModel(model);

    const data = ffi.mj_makeData(model);
    defer ffi.mj_deleteData(data);

    while (data.*.time < 10) {
        ffi.mj_step(model, data);
    }
}

test "load hello mujoco model" {
    const testing = std.testing;
    const model_path = @import("test_utils.zig").BasicModelPath;

    var model: MjModel = try .fromXml(testing.allocator, model_path);
    defer model.deinit();

    var data: MjData = try model.data();
    defer data.deinit();

    while (data.raw.time < 10) {
        try data.step();
    }
}
