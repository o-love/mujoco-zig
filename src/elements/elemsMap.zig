const std = @import("std");
const mujoco_zig = @import("../root.zig");

const ObjectType = mujoco_zig.enums.ObjectType;
const ffi = mujoco_zig.ffi;
const elems = mujoco_zig.elements;

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
