const std = @import("std");
const mujoco_zig = @import("../../root.zig");
const log = @import("../../log.zig");

const ffi = mujoco_zig.ffi;

const MjrContext = @This();
const MjModel = mujoco_zig.MjModel;

raw: ffi.mjrContext,

pub fn init(model: *const MjModel, fontscale: i64) !@This() {
    var context: ffi.mjrContext = undefined;

    log.debug("Initializing MjrContext", .{});

    ffi.mjr_defaultContext(&context);
    ffi.mjr_makeContext(model.raw, &context, @intCast(fontscale));

    log.debug("Finished initializing MjrContext", .{});

    return .{
        .raw = context,
    };
}

pub fn deinit(self: *@This()) void {
    ffi.mjr_freeContext(&self.raw);
}

test "init and deinit" {
    const testing = std.testing;
    const model_path = @import("../../test_utils.zig").BasicModelPath;
    mujoco_zig.init();

    const glfw = @import("zglfw");

    try glfw.init();

    defer {
        glfw.terminate();
    }

    const window: *glfw.Window = try glfw.createWindow(800, 640, "Hello World", null, null);
    defer glfw.destroyWindow(window);

    glfw.makeContextCurrent(window);
    glfw.swapInterval(1);
    glfw.swapBuffers(window);

    var model: MjModel = try .from_xml(model_path, testing.allocator);
    defer model.deinit();

    var context: MjrContext = try .init(&model, 200);
    defer context.deinit();

    glfw.pollEvents();
    glfw.swapBuffers(window);
}
