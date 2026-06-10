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
const ffi_cpp_viewer = mujoco_zig.ffi_cpp_viewer;

pub fn main(init: std.process.Init) !void {
    mujoco_zig.init();

    const model_path = "src/assets/hello.xml";

    std.log.info("Building model", .{});
    var model: MjModel = try .fromXmlZ(model_path);
    defer model.deinit();

    var data: MjData = try model.data();
    defer data.deinit();

    std.log.info("Building context and scene", .{});

    var options: MjvOption = .init();
    var scene: MjvScene = try .init(&model, 1000);
    defer scene.deinit();

    var perturb: MjvPerturb = .init(&data, &scene);
    var camera: MjvCamera = .init();

    std.log.info("Creating C Simulate instance...", .{});
    const sim = ffi_cpp_viewer.mujoco_cSimulate_create(&camera.raw, &options.raw, &perturb.raw, &scene.raw) orelse return error.SimulateCreateFailed;
    defer ffi_cpp_viewer.mujoco_cSimulate_destroy(sim);

    // Create simulation thread
    const thread = try std.Thread.spawn(.{}, simulationLoop, .{ init.io, &data, sim, model_path });

    std.log.info("Starting rendering loop...", .{});

    // This blocks until the window is closed
    _ = ffi_cpp_viewer.mujoco_cSimulate_RenderLoop(sim);

    ffi_cpp_viewer.mujoco_cSimulate_ExitRequest(sim);
    thread.join();
}

fn simulationLoop(io: std.Io, data: *MjData, sim: *ffi.mujoco_Simulate, model_path: [:0]const u8) void {
    _ = std.Io.sleep(io, std.Io.Duration.fromNanoseconds(100 * std.time.ns_per_ms), .awake) catch {};

    ffi_cpp_viewer.mujoco_cSimulate_Load(sim, data.model.raw, data.raw, model_path);

    while (ffi_cpp_viewer.mujoco_cSimulate_ShouldExit(sim) == 0) {
        const simstartTime = data.raw.time;
        while (data.raw.time - simstartTime < 1.0 / 60.0) {
            data.step() catch break;
        }
        ffi_cpp_viewer.mujoco_cSimulate_Sync(sim, 0);
        _ = std.Io.sleep(io, std.Io.Duration.fromNanoseconds(1 * std.time.ns_per_ms), .awake) catch {};
    }
}
