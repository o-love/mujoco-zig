const std = @import("std");
const glfw = @import("zglfw");
const mujoco_zig = @import("mujoco_zig");

const MjModel = mujoco_zig.MjModel;
const MjrContext = mujoco_zig.MjrContext;
const MjvScene = mujoco_zig.MjvScene;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    mujoco_zig.init();

    var arg_it = init.minimal.args.iterate();
    _ = arg_it.skip();
    const model_path = arg_it.next() orelse "assets/hello.xml";

    try std.Io.File.stdout().writeStreamingAll(io, "Initializing GLFW...\n");

    try glfw.init();

    std.debug.print("glfw.init() returned successfully.\n", .{});
    defer {
        std.debug.print("Calling glfw.terminate()...\n", .{});
        glfw.terminate();
    }

    std.debug.print("Setting error callback...\n", .{});

    std.debug.print("Setting window hints...\n", .{});

    std.debug.print("Creating window...\n", .{});
    const window: *glfw.Window = try glfw.createWindow(800, 640, "MuJoCo Zig Viewer", null, null);
    defer glfw.destroyWindow(window);

    std.debug.print("Making context current...\n", .{});
    glfw.makeContextCurrent(window);

    std.debug.print("Setting swap interval...\n", .{});
    // VSync
    glfw.swapInterval(1);

    std.debug.print("Window opened successfully.\n", .{});

    std.debug.print("Building model\n", .{});
    var model: MjModel = try .from_xml(model_path, init.gpa);
    defer model.deinit();

    std.debug.print("Building context and scene\n", .{});

    var scene: MjvScene = try .init(&model, 1000);
    defer scene.deinit();

    var context: MjrContext = try .init(&model, 200);
    defer context.deinit();

    while (!glfw.windowShouldClose(window)) {
        if (glfw.getKey(window, glfw.KeyEscape) == glfw.Press) {
            glfw.setWindowShouldClose(window, true);
        }

        // Basic event processing and buffer swapping
        glfw.pollEvents();
        glfw.swapBuffers(window);
    }
}
