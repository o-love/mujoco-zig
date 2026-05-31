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

var has_init: std.atomic.Value(bool) = .init(false);
pub fn init() void {
    if (has_init.load(.acquire)) {
        return;
    }
    has_init.store(true, .monotonic);
    // While using a mutex would make it thread safe. I want to avoid a dependency on Io.
    // Initializing the error callbacks multiple time should have no side effects.

    ffi.mju_user_error = user_error_callback;
    ffi.mju_user_warning = user_warning_callback;

    if (build_options.opengl) {
        const glfw = @import("zglfw");

        _ = glfw.setErrorCallback(struct {
            fn callback(error_code: c_int, description: [*:0]const u8) callconv(.c) void {
                log.err("GLFW Error ({d}): {s}", .{ error_code, description });
            }
        }.callback);
    }

    log.debug("Ran mujoco_zig initialization", .{});
}
