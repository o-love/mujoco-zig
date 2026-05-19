const std = @import("std");
const rl = @import("raylib");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const ptr = try gpa.create(i32);
    defer gpa.destroy(ptr);

    try std.Io.File.stdout().writeStreamingAll(io, "Hello, world!\n");

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    for (args, 0..) |arg, i| {
        std.log.info("arg[{d}] = {s}", .{ i, arg });
    }

    std.log.info("{d} env vars", .{init.environ_map.count()});

    rl.initWindow(1200, 720, "mujoco-zig viewer example");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
