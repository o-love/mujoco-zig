const std = @import("std");
const log = std.log.scoped(.mujoco_zig);

pub const info = log.info;
pub const debug = log.debug;
pub const err = log.err;
pub const warn = log.warn;

pub fn user_error_callback(msg: [*c]const u8) callconv(.c) void {
    if (msg) |m| {
        std.debug.print("MUJOCO ERROR: {s}\n", .{m});
    }
    std.process.exit(1);
}

pub fn user_warning_callback(msg: [*c]const u8) callconv(.c) void {
    if (msg) |m| {
        std.debug.print("MUJOCO WARNING: {s}\n", .{m});
    }
}

pub fn init() void {
    const ffi = @import("root.zig").ffi;
    ffi.mju_user_error = user_error_callback;
    ffi.mju_user_warning = user_warning_callback;
}

var run_once: std.atomic.Value(bool) = .{
    .raw = false,
};

pub fn init_once() void {}
