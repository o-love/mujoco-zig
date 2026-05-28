const std = @import("std");
const glfw = @import("zglfw");
const mujoco_zig = @import("mujoco_zig");

const MjModel = mujoco_zig.MjModel;
const MjData = mujoco_zig.MjData;
const MjrContext = mujoco_zig.MjrContext;
const MjvScene = mujoco_zig.MjvScene;
const MjvOption = mujoco_zig.MjvOption;
const MjvPerturb = mujoco_zig.MjvPerturb;
const MjvCamera = mujoco_zig.MjvCamera;
const ffi = mujoco_zig.ffi;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    mujoco_zig.init();

    var arg_it = init.minimal.args.iterate();
    _ = arg_it.skip();
    const model_path = arg_it.next() orelse "src/assets/hello.xml";

    const out = std.Io.File.stdout();
    var buffer: [1024]u8 = undefined;
    const writerStruct = out.writer(io, &buffer);

    var writer = writerStruct.interface;
    try writer.print("Initializing GLFW...\n", .{});

    try glfw.init();

    try writer.print("glfw.init() returned successfully.\n", .{});
    defer glfw.terminate();

    try writer.print("Creating window...\n", .{});
    const window: *glfw.Window = try glfw.createWindow(800, 640, "MuJoCo Zig Viewer", null, null);
    defer glfw.destroyWindow(window);

    try writer.print("Making context current...\n", .{});
    glfw.makeContextCurrent(window);

    try writer.print("Setting swap interval...\n", .{});
    // VSync
    glfw.swapInterval(1);

    try writer.print("Window opened successfully.\n", .{});

    try writer.print("Building model\n", .{});
    var model: MjModel = try .fromXmlZ(model_path);
    defer model.deinit();

    var data: MjData = try model.data();
    defer data.deinit();

    try writer.print("Building context and scene\n", .{});

    const options: MjvOption = .init();

    var scene: MjvScene = try .init(&model, 1000);
    defer scene.deinit();

    var context: MjrContext = try .init(&model, 200);
    defer context.deinit();

    var perturb: MjvPerturb = .init(&data, &scene);
    var camera: MjvCamera = .init();

    while (!glfw.windowShouldClose(window)) {
        if (glfw.getKey(window, glfw.KeyEscape) == glfw.Press) {
            glfw.setWindowShouldClose(window, true);
        }

        const simstartTime = data.raw.time;
        while (data.raw.time - simstartTime < 1.0 / 60.0) {
            try data.step();
        }

        var viewport: ffi.mjrRect = .{};
        glfw.getFramebufferSize(window, &viewport.width, &viewport.height);

        ffi.mjv_updateScene(model.raw, data.raw, &options.raw, &perturb.raw, &camera.raw, @intFromEnum(mujoco_zig.enums.CategoryFlag.all), &scene.raw);
        ffi.mjr_render(viewport, &scene.raw, &context.raw);

        // Basic event processing and buffer swapping
        glfw.swapBuffers(window);
        glfw.pollEvents();
    }
}
