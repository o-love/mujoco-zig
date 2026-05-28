const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;
const MjData = mujoco_zig.MjData;
const MjVFS = mujoco_zig.MjVFS;
const Allocator = std.mem.Allocator;
const enums = mujoco_zig.enums;

const log = @import("log.zig");

const MjModel = @This();

raw: *ffi.mjModel,

pub fn fromRaw(model: *ffi.mjModel) @This() {
    return .{
        .raw = model,
    };
}

pub fn fromXml(gpa: Allocator, path: []const u8) !@This() {
    const c_path = try gpa.dupeSentinel(u8, path, 0);
    defer gpa.free(c_path);

    return load(c_path, null);
}

pub fn fromXmlZ(path: [:0]const u8) !@This() {
    return load(path, null);
}

pub fn fromXmlVfs(gpa: Allocator, path: []const u8, vfs: *const MjVFS) !@This() {
    const c_path = try gpa.dupeSentinel(u8, path, 0);
    defer gpa.free(c_path);

    return load(c_path, vfs);
}

pub fn fromXmlVfsZ(path: [:0]const u8, vfs: *const MjVFS) !@This() {
    return load(path, vfs);
}

fn load(c_path: [:0]const u8, vfs: ?*const MjVFS) !@This() {
    const buf_size = 1000;
    var err_buffer: [buf_size:0]u8 = undefined;

    const raw_vfs: ?*const ffi.mjVFS = if (vfs) |v| &v.raw else null;

    const raw_model = ffi.mj_loadXML(c_path, raw_vfs, &err_buffer, 1000);

    if (raw_model == null) {
        log.err("Error loading mujoco model from xml: {s}", .{err_buffer});
        return error.LoadingModel;
    }

    return .{
        .raw = raw_model,
    };
}

pub fn deinit(self: *const @This()) void {
    ffi.mj_deleteModel(self.raw);
}

pub fn data(self: *const @This()) !MjData {
    const raw_data = ffi.mj_makeData(self.raw);

    if (raw_data == null) {
        log.err("Error loading mujoco data", .{});
        return error.LoadingData;
    }

    return MjData.fromRaw(raw_data, self);
}

pub fn size(self: *const @This()) mujoco_zig.MjtSize {
    return ffi.mj_sizeModel(self.raw);
}

pub fn stateSize(self: *const @This(), sig: enums.StateFlag) i64 {
    return ffi.mj_stateSize(self.raw, @intFromEnum(sig));
}
