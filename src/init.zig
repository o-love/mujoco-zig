const std = @import("std");
const mujoco_zig = @import("root.zig");
const log = @import("log.zig");
const build_options = @import("build_options");

const ffi = mujoco_zig.ffi;

fn user_error_callback(msg: [*c]const u8) callconv(.c) void {
    if (msg) |m| {
        log.err("MUJOCO ERROR: {s}\n", .{m});
    }
    std.process.exit(1);
}

fn user_warning_callback(msg: [*c]const u8) callconv(.c) void {
    if (msg) |m| {
        log.warn("MUJOCO WARNING: {s}\n", .{m});
    }
}

pub fn init() void {
    ffi.mju_user_error = user_error_callback;
    ffi.mju_user_warning = user_warning_callback;

    if (build_options.renderer) {
        const glfw = @import("zglfw");

        _ = glfw.setErrorCallback(struct {
            fn callback(error_code: c_int, description: [*:0]const u8) callconv(.c) void {
                log.err("GLFW Error ({d}): {s}", .{ error_code, description });
            }
        }.callback);
    }

    log.debug("Ran mujoco_zig initialization", .{});
}
