pub const ffi = @import("c");


pub const MjModel = ffi.mjModel;
pub const MjData = ffi.mjData;

pub const loadXML = ffi.mj_loadXML;
pub const makeData = ffi.mj_makeData;

test "load hello mujoco model" {
    var buffer: [1024]u8 = undefined;
    _ = ffi.mj_loadXML("hello.xml", null, &buffer, 1000);
}
