const std = @import("std");
const mujoco_zig = @import("mujoco_zig");

const MjModel = mujoco_zig.MjModel;
const MjData = mujoco_zig.MjData;

const benchmark_duration_ns = 10 * std.time.ns_per_s;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const out = std.Io.File.stdout();
    var buffer: [1024]u8 = undefined;
    var writerStruct = out.writer(io, &buffer);

    var writer = &writerStruct.interface;
    defer writer.flush() catch {};

    mujoco_zig.init();

    var arg_it = init.minimal.args.iterate();
    _ = arg_it.skip();
    const model_path = arg_it.next().?;

    var model: MjModel = try .fromXmlZ(model_path);
    defer model.deinit();

    var data: MjData = try model.data();
    defer data.deinit();

    const start = std.Io.Clock.awake.now(io);
    var iterations: u64 = 0;

    while (start.untilNow(io, .awake).toNanoseconds() < benchmark_duration_ns) : (iterations += 1) {
        try data.step();
    }

    const elapsed_ns = start.untilNow(io, .awake).toNanoseconds();
    const elapsed_s = @as(f64, @floatFromInt(elapsed_ns)) / @as(f64, @floatFromInt(std.time.ns_per_s));

    try writer.print(
        "iterations: {d}, throughput: {d:.2} steps/sec\n",
        .{
            iterations,
            @as(f64, @floatFromInt(iterations)) / elapsed_s,
        },
    );
}