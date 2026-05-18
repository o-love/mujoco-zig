const std = @import("std");
pub const ffi = @import("c");

pub const MjModel = @import("MjModel.zig");
pub const MjData = @import("MjData.zig");

test "ffi: load hello mujoco model" {
    var buffer: [1024]u8 = undefined;
    const model = ffi.mj_loadXML("assets/hello.xml", null, &buffer, 1000);
    defer ffi.mj_deleteModel(model);

    const data = ffi.mj_makeData(model);
    defer ffi.mj_deleteData(data);

    while (data.*.time < 10) {
        ffi.mj_step(model, data);
    }
}

test "load hello mujoco model" {
    const testing = std.testing;

    const model: MjModel = try .from_xml("assets/hello.xml", testing.allocator);
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
}
