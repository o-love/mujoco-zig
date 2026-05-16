const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mujoco_dep = b.dependency("mujoco", .{});

    const c_deps = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
    });
    c_deps.addIncludePath(mujoco_dep.path("include"));

    const mujoco_lib = buildMujoco(b, target, optimize, mujoco_dep);

    const mod = b.addModule("mujoco_zig", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "c",
                .module = c_deps.createModule(),
            },
        },
    });
    mod.linkLibrary(mujoco_lib);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

pub fn buildMujoco(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    mujoco_dep: *std.Build.Dependency,
) *std.Build.Step.Compile {
    const mujoco_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,

        .link_libc = true,
        .link_libcpp = true,
    });

    const mujoco_lib = b.addLibrary(.{
        .name = "mujoco",
        .root_module = mujoco_mod,
    });

    for (MujocoHeaders) |header| {
        mujoco_lib.installHeader(mujoco_dep.path(header), header["include/".len..]);
    }

    MujocoEngineSources.addToModule(mujoco_mod, mujoco_dep);

    return mujoco_lib;
}

const MujocoHeaders = [_][]const u8{
    "include/mujoco/mjdata.h",
    "include/mujoco/mjexport.h",
    "include/mujoco/mjmacro.h",
    "include/mujoco/mjmodel.h",
    "include/mujoco/mjplugin.h",
    "include/mujoco/mjrender.h",
    "include/mujoco/mjsan.h",
    "include/mujoco/mjspec.h",
    "include/mujoco/mjthread.h",
    "include/mujoco/mjtnum.h",
    "include/mujoco/mjui.h",
    "include/mujoco/mjvisualize.h",
    "include/mujoco/mjxmacro.h",
    "include/mujoco/mujoco.h",
};

const MujocoModule = struct {
    root: []const u8,
    sources: []const []const u8,

    pub fn addToModule(self: *const MujocoModule, mod: *std.Build.Module, dep: *std.Build.Dependency) void {
        mod.addCSourceFiles(.{
            .root = dep.path(self.root),
            .files = self.sources,
        });
    }
};

const MujocoEngineSources: MujocoModule = .{
    .root = "src/engine",
    .sources = &[_][]const u8{
        "engine_array_safety.h",
        "engine_callback.c",
        "engine_callback.h",
        "engine_collision_box.c",
        "engine_collision_convex.c",
        "engine_collision_convex.h",
        "engine_collision_driver.c",
        "engine_collision_driver.h",
        "engine_collision_gjk.c",
        "engine_collision_gjk.h",
        "engine_collision_primitive.c",
        "engine_collision_primitive.h",
        "engine_collision_sdf.c",
        "engine_collision_sdf.h",
        "engine_core_constraint.c",
        "engine_core_constraint.h",
        "engine_core_util.c",
        "engine_core_util.h",
        "engine_core_smooth.c",
        "engine_core_smooth.h",
        "engine_crossplatform.cc",
        "engine_crossplatform.h",
        "engine_derivative.c",
        "engine_derivative.h",
        "engine_derivative_fd.c",
        "engine_derivative_fd.h",
        "engine_forward.c",
        "engine_forward.h",
        "engine_global_table.h",
        "engine_inverse.c",
        "engine_inverse.h",
        "engine_init.c",
        "engine_init.h",
        "engine_inline.h",
        "engine_island.c",
        "engine_island.h",
        "engine_io.c",
        "engine_io.h",
        "engine_macro.h",
        "engine_memory.c",
        "engine_memory.h",
        "engine_name.c",
        "engine_name.h",
        "engine_passive.c",
        "engine_passive.h",
        "engine_plugin.cc",
        "engine_plugin.h",
        "engine_print.c",
        "engine_print.h",
        "engine_ray.c",
        "engine_ray.h",
        "engine_sensor.c",
        "engine_sensor.h",
        "engine_setconst.c",
        "engine_setconst.h",
        "engine_sleep.c",
        "engine_sleep.h",
        "engine_solver.c",
        "engine_solver.h",
        "engine_sort.h",
        "engine_support.c",
        "engine_support.h",
        "engine_util_blas.c",
        "engine_util_blas.h",
        "engine_util_errmem.c",
        "engine_util_errmem.h",
        "engine_util_misc.c",
        "engine_util_misc.h",
        "engine_util_solve.c",
        "engine_util_solve.h",
        "engine_util_sparse.c",
        "engine_util_sparse.h",
        "engine_util_sparse_avx.h",
        "engine_util_spatial.c",
        "engine_util_spatial.h",
        "engine_vis_init.c",
        "engine_vis_init.h",
        "engine_vis_interact.c",
        "engine_vis_interact.h",
        "engine_vis_visualize.c",
        "engine_vis_visualize.h",
    },
};
