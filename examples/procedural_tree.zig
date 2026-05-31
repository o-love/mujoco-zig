//! Procedural tree using recursive model editing.
//!
//! Builds a branching tree programmatically via MjSpec's body/joint/geom API.
//! Ball joints with spring-stiffness make branches sway under an animated wind gust.
//!
//! Adapted from the MuJoCo mjspec tutorial:
//! https://colab.research.google.com/github/google-deepmind/mujoco/blob/main/python/mjspec.ipynb
//!
//! Credit to David Hožič <davidhozic@gmail.com> at https://github.com/davidhozic/mujoco-rs
//! Licensed under Dual MIT and Apache 2

const std = @import("std");
const mujoco_zig = @import("mujoco_zig");

const MjSpec = mujoco_zig.MjSpec;
const MjModel = mujoco_zig.MjModel;
const MjData = mujoco_zig.MjData;
const Allocator = std.mem.Allocator;
const DisableFlag = mujoco_zig.enums.DisableFlag;

const brown = [4]f32{ 0.4, 0.24, 0.0, 1.0 };
const green = [4]f32{ 0.0, 0.7, 0.2, 1.0 };

const max_depth = 4;
const scale = 0.6;
const num_branches = 5;

const directions: [num_branches][3]f32 = .{
    .{ 0.7071, 0.0000, 0.7071 },
    .{ 0.2190, 0.6756, 0.7071 },
    .{ -0.5729, 0.4163, 0.7071 },
    .{ -0.5729, -0.4163, 0.7071 },
    .{ 0.2190, -0.6756, 0.7071 },
};

const model_xml =
    \\ <mujoco>
    \\  <default>
    \\    <joint springdamper="0.003 0.7"/>
    \\  </default>
    \\ </mujoco>
;

pub fn main(init: std.process.Init) !void {
    var model: MjModel = try build_tree(init.gpa);
    model.deinit();
}

fn build_tree(gpa: Allocator) !MjModel {
    var spec: MjSpec = try .fromXmlStr(gpa, model_xml);
    defer spec.deinit();

    var options = spec.option();
    options.timestep = 0.002;
    options.density = 1.294;
    options.wind[0] = 0.0;
    options.disableflags |= @intFromEnum(DisableFlag.constraint);

    var stat = spec.stats();
    stat.center = .{0.0, 0.0, 0.5};
    stat.extent = 1.0;

    var world = spec.world().?;

    mujoco_zig.ffi.mjs_add

    return try spec.compile();
}
