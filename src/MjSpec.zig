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

pub fn fromXmlStr(gpa: Allocator, str: []const u8) !@This() {
    const c_string: [:0]const u8 = try gpa.dupeSentinel(u8, str, 0);
    defer gpa.free(c_string);

    return fromXmlStrZ(c_string);
}

pub fn fromXmlStrZ(str: [:0]const u8) !@This() {
    const buf_size = 1000;
    var err_buffer: [buf_size:0]u8 = undefined;

    const result = ffi.mj_parseXMLString(str, null, &err_buffer, buf_size);

    if (result == null) {
        log.err("Error parsing XML string: {s}", .{err_buffer});
        return error.LoadingModel;
    }

    return .{
        .raw = result,
    };
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

pub fn findZ(self: *@This(), comptime obj_type: ObjectType, name: [:0]const u8) ?*obj(obj_type) {
    const element = ffi.mjs_findElement(self.raw, @intFromEnum(obj_type), name);

    return asObj(obj_type, element);
}

pub fn find(self: *@This(), gpa: Allocator, comptime obj_type: ObjectType, name: []const u8) error{OutOfMemory}!?*obj(obj_type) {
    const c_name = try gpa.dupeSentinel(u8, name, 0);
    defer gpa.free(c_name);

    return self.findZ(obj_type, name);
}

pub fn world(self: *@This()) ?*ffi.mjsBody {
    return self.findZ(.body, "world");
}

pub fn option(self: *const @This()) *ffi.mjOption {
    return &self.raw.option;
}

pub fn stats(self: *const @This()) *ffi.mjStatistic {
    return &self.raw.stat;
}

pub fn compiler(self: *const @This()) *ffi.mjsCompiler {
    return &self.raw.compiler;
}

pub fn visual(self: *const @This()) *ffi.mjVisual {
    return &self.raw.visual;
}

fn obj(comptime obj_type: ObjectType) type {
    return switch (obj_type) {
        .body => ffi.mjsBody,
        .xbody => ffi.mjsBody,
        .joint => ffi.mjsJoint,
        .geom => ffi.mjsGeom,
        .site => ffi.mjsSite,
        .camera => ffi.mjsCamera,
        .light => ffi.mjsLight,
        .flex => ffi.mjsFlex,
        .mesh => ffi.mjsMesh,
        .skin => ffi.mjsSkin,
        .hfield => ffi.mjsHField,
        .texture => ffi.mjsTexture,
        .material => ffi.mjsMaterial,
        .pair => ffi.mjsPair,
        .exclude => ffi.mjsExclude,
        .equality => ffi.mjsEquality,
        .tendon => ffi.mjsTendon,
        .actuator => ffi.mjsActuator,
        .sensor => ffi.mjsSensor,
        .numeric => ffi.mjsNumeric,
        .text => ffi.mjsText,
        .tuple => ffi.mjsTuple,
        .key => ffi.mjsKey,
        .plugin => ffi.mjsPlugin,
        .dof, .unknown, .frame, .default, .model => {
            @compileError(std.fmt.comptimePrint("Unsupported object type: {s}", .{@tagName(obj_type)}));
        },
    };
}

fn asObj(comptime obj_type: ObjectType, elem: ?*ffi.mjsElement) ?*obj(obj_type) {
    if (elem == null) {
        return null;
    }

    std.debug.assert(elem.?.elemtype == @intFromEnum(obj_type));

    const castedElem: ?*obj(obj_type) = switch (obj_type) {
        .body => ffi.mjs_asBody,
        .xbody => ffi.mjs_asBody,
        .joint => ffi.mjs_asJoint,
        .geom => ffi.mjs_asGeom,
        .site => ffi.mjs_asSite,
        .camera => ffi.mjs_asCamera,
        .light => ffi.mjs_asLight,
        .flex => ffi.mjs_asFlex,
        .mesh => ffi.mjs_asMesh,
        .skin => ffi.mjs_asSkin,
        .hfield => ffi.mjs_asHField,
        .texture => ffi.mjs_asTexture,
        .material => ffi.mjs_asMaterial,
        .pair => ffi.mjs_asPair,
        .exclude => ffi.mjs_asExclude,
        .equality => ffi.mjs_asEquality,
        .tendon => ffi.mjs_asTendon,
        .actuator => ffi.mjs_asActuator,
        .sensor => ffi.mjs_asSensor,
        .numeric => ffi.mjs_asNumeric,
        .text => ffi.mjs_asText,
        .tuple => ffi.mjs_asTuple,
        .key => ffi.mjs_asKey,
        .plugin => ffi.mjs_asPlugin,
        .dof, .unknown, .frame, .default, .model => {
            @compileError(std.fmt.comptimePrint("Unsupported object type: {s}", .{@tagName(obj_type)}));
        },
    }(elem);

    std.debug.assert(castedElem != null);

    return castedElem.?;
}

const testing = std.testing;
const test_utils = @import("test_utils.zig");

test "init and deinit" {
    var spec: MjSpec = try .init();
    defer spec.deinit();
}

test world {
    var spec: MjSpec = try test_utils.loadBasicSpec();
    defer spec.deinit();

    const result = spec.world();

    try testing.expect(result != null);
}

test fromXmlStr {
    const model_str =
        \\ <mujoco>
        \\  <default>
        \\    <joint springdamper="0.003 0.7"/>
        \\  </default>
        \\ </mujoco>
    ;

    var spec: MjSpec = try .fromXmlStr(testing.allocator, model_str);
    defer spec.deinit();
}

test compiler {
    var spec: MjSpec = try test_utils.loadBasicSpec();
    defer spec.deinit();

    const result = spec.compiler();
    _ = result;
}

test option {
    var spec: MjSpec = try test_utils.loadBasicSpec();
    defer spec.deinit();

    const optionA = spec.option();
    optionA.timestep = 0.0123;

    try testing.expectApproxEqRel(0.0123, spec.raw.option.timestep, 0.0001);
}
