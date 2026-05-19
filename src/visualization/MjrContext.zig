const std = @import("std");
const mujoco_zig = @import("../root.zig");

const ffi = mujoco_zig.ffi;

const MjrContext = @This();
const MjModel = mujoco_zig.MjModel;

raw: ffi.mjrContext,

pub fn init(model: *const MjModel, fontscale: i64) !@This() {
    var context: ffi.mjrContext = undefined;

    ffi.mjr_defaultContext(&context);
    ffi.mjr_makeContext(model.model, &context, @intCast(fontscale));

    return .{
        .raw = context,
    };
}

pub fn deinit(self: *@This()) void {
    ffi.mjr_freeContext(&self.raw);
}

test "init and deinit" {
    const testing = std.testing;
    const rl = @import("raylib");
    const model_path = @import("../test_utils.zig").BasicModelPath;

    rl.initWindow(1200, 720, "mujoco-zig viewer example");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.beginDrawing();
    defer rl.endDrawing();

    std.debug.print("Building model\n", .{});
    var model: MjModel = try .from_xml(model_path, testing.allocator);
    defer model.deinit();

    std.debug.print("Building context\n", .{});
    var context: MjrContext = try .init(&model, 200);
    defer context.deinit();

    std.debug.print("Done builing\n", .{});
}
