const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;
const MjModel = mujoco_zig.MjModel;

const MjData = @This();

data: *ffi.mjData,
model: *const MjModel,

pub fn new(model: MjModel) !@This() {
    const data = try model.data();

    return data;
}

pub fn from_raw(data: *ffi.mjData, model: *const MjModel) @This() {
    return .{
        .data = data,
        .model = model,
    };
}

pub fn deinit(self: *@This()) void {
    ffi.mj_deleteData(self.data);

    self.model = undefined;
    self.data = undefined;
}

pub fn step(self: *@This()) !void {
    ffi.mj_step(self.model.model, self.data);
}