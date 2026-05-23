const std = @import("std");
pub const ffi = @import("c");
const build_options = @import("build_options");

pub const MjModel = @import("MjModel.zig");
pub const MjData = @import("MjData.zig");

pub const MjrContext = if (build_options.renderer) @import("visualization/MjrContext.zig") else @compileError("MjrContext requires the 'renderer' build option");

pub const init = @import("init.zig").init;

test "ffi: load hello mujoco model" {
    const model_path = @import("test_utils.zig").BasicModelPath;

    var buffer: [1024]u8 = undefined;
    const model = ffi.mj_loadXML(model_path, null, &buffer, 1000);
    defer ffi.mj_deleteModel(model);

    const data = ffi.mj_makeData(model);
    defer ffi.mj_deleteData(data);

    while (data.*.time < 10) {
        ffi.mj_step(model, data);
    }
}

test "load hello mujoco model" {
    const testing = std.testing;
    const model_path = @import("test_utils.zig").BasicModelPath;

    var model: MjModel = try .from_xml(model_path, testing.allocator);
    defer model.deinit();

    var data: MjData = try model.data();
    defer data.deinit();

    while (data.data.time < 10) {
        try data.step();
    }
}

test {
    _ = @import("MjData.zig");
    _ = @import("MjModel.zig");
    _ = @import("log.zig");
    _ = @import("visualization/MjvCamera.zig");
    _ = @import("visualization/MjvOption.zig");
    _ = @import("visualization/MjvScene.zig");

    if (build_options.renderer) {
        _ = @import("visualization/MjrContext.zig");
    }
}
