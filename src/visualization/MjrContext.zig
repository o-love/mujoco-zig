const std = @import("std");
const mujoco_zig = @import("../root.zig");
const log = mujoco_zig.log;

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
    const model_path = @import("../test_utils.zig").BasicModelPath;
    mujoco_zig.init();

    const glfw = @import("zglfw");

    try glfw.init();
    std.debug.print("glfw.init() returned successfully.\n", .{});

    defer {
        std.debug.print("Calling glfw.terminate()...\n", .{});
        glfw.terminate();
    }

    const window: *glfw.Window = try glfw.createWindow(800, 640, "Hello World", null, null);
    defer glfw.destroyWindow(window);

    glfw.makeContextCurrent(window);
    glfw.swapInterval(1);
    glfw.swapBuffers(window);

    std.debug.print("Building model\n", .{});
    var model: MjModel = try .from_xml(model_path, testing.allocator);
    defer model.deinit();

    std.debug.print("Building context\n", .{});
    var context: MjrContext = try .init(&model, 200);
    defer context.deinit();

    glfw.pollEvents();
    glfw.swapBuffers(window);

    std.debug.print("Done builing\n", .{});
}
