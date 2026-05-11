const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;
const MjData = mujoco_zig.MjData;
const Allocator = std.mem.Allocator;

const log = @import("log.zig");

const MjModel = @This();

model: *ffi.mjModel,

pub fn from_raw(model: *ffi.mjModel) @This() {
    return .{
        .model = model,
    };
}

pub fn from_xml(path: []const u8, gpa: Allocator) !@This() {
    const c_path = try gpa.dupeSentinel(u8, path, 0);
    defer gpa.free(c_path);

    const buf_size = 1000;
    var err_buffer: [buf_size:0]u8 = undefined;

    const raw_model = ffi.mj_loadXML(c_path, null, &err_buffer, 1000);

    if (raw_model == null) {
        log.err("Error loading mujoco model from xml: {s}", .{ err_buffer });
        return error.LoadingModel;
    }

    return from_raw(raw_model);
}

pub fn deinit(self: *const @This()) void {
    ffi.mj_deleteModel(self.model);
}


pub fn data(self: *const @This()) !MjData {
    const raw_data = ffi.mj_makeData(self.model);

    if (raw_data == null) {
        log.err("Error loading mujoco data", .{});
        return error.LoadingData;
    }

    return MjData.from_raw(raw_data, self);
}