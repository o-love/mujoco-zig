const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;
const log = @import("log.zig");
const MjSpec = @This();
const MjVFS = mujoco_zig.MjVFS;
const MjModel = mujoco_zig.MjModel;
const Allocator = std.mem.Allocator;
const ObjectType = mujoco_zig.enums.ObjectType;

raw: *ffi.mjSpec,

pub fn init() !@This() {
    const spec = ffi.mj_makeSpec();

    if (spec == null) {
        log.err("Failed to initialize base spec", .{});
        return error.SpecInit;
    }

    return .{
        .raw = spec,
    };
}

pub fn deinit(self: *const @This()) void {
    ffi.mj_deleteSpec(self.raw);
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

    const raw_spec = ffi.mj_parseXML(c_path, raw_vfs, &err_buffer, 1000);

    if (raw_spec == null) {
        log.err("Error loading mujoco spec from xml: {s}", .{err_buffer});
        return error.LoadingSpec;
    }

    return .{
        .raw = raw_spec,
    };
}

pub fn compile(self: *@This()) !MjModel {
    const raw_model = ffi.mj_compile(self.raw, null);

    if (raw_model == null) {
        // TODO: Load error message from mjs_getError

        log.err("Error compiling Spec", .{});
        return error.LoadingModel;
    }

    return .fromRaw(raw_model);
}

pub fn saveXml(self: *const @This(), gpa: Allocator, filename: []const u8) !void {
    const c_path = try gpa.dupeSentinel(u8, filename, 0);
    defer gpa.free(c_path);

    self.saveXmlZ(c_path);
}

pub fn saveXmlZ(self: *const @This(), fileaname: [:0]const u8) !void {
    const buf_size = 1000;
    var err_buffer: [buf_size:0]u8 = undefined;

    const result = ffi.mj_saveXML(self.raw, fileaname, &err_buffer, buf_size);

    if (result != 0) {
        log.err("Error saving spec to xml file {s}: {s}", .{ fileaname, err_buffer });
        return error.SavingSpec;
    }
}

fn findElementZ(self: *@This(), obj_type: ObjectType, name: [:0]const u8) ?*ffi.mjsElement {
    const result = ffi.mjs_findElement(self.raw, @intFromEnum(obj_type), name);

    return result;
}

test "init and deinit" {
    var spec: MjSpec = try .init();
    defer spec.deinit();
}
