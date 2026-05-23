const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const renderer = b.option(bool, "renderer", "Enable the renderer (MjrContext) and link GLFW") orelse false;

    const mujoco_dep = b.dependency("mujoco", .{});

    const c_deps = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
    });
    c_deps.addIncludePath(mujoco_dep.path("include"));

    const mujoco_lib = buildMujoco(b, target, optimize, mujoco_dep);

    const build_options = b.addOptions();
    build_options.addOption(bool, "renderer", renderer);

    const module_options: std.Build.Module.CreateOptions = .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "c",
                .module = c_deps.createModule(),
            },
            .{
                .name = "build_options",
                .module = build_options.createModule(),
            },
        },
    };
    const mod = b.addModule("mujoco_zig", module_options);
    mod.linkLibrary(mujoco_lib);

    const zglfw_mod = if (renderer) b.createModule(.{
        .root_source_file = b.dependency("zglfw", .{}).path("src/glfw.zig"),
        .target = target,
        .optimize = optimize,
    }) else null;

    if (renderer) {
        addGlfw(mod, zglfw_mod.?);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    buildViewer(b, mod, target, optimize, zglfw_mod);
}

fn buildViewer(
    b: *std.Build,
    mod: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    zglfw_mod: ?*std.Build.Module,
) void {
    const viewer_step = b.step("viewer", "Build the OpenGL viewer example");
    const examples_step = b.step("examples", "Build all examples");
    examples_step.dependOn(viewer_step);

    const viewer_exe = b.addExecutable(.{
        .name = "opengl-viewer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/opengl-viewer/viewer.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    viewer_exe.root_module.addImport("mujoco_zig", mod);
    if (zglfw_mod) |z| {
        addGlfw(viewer_exe.root_module, z);
    }

    const install_viewer = b.addInstallArtifact(viewer_exe, .{});
    viewer_step.dependOn(&install_viewer.step);

    const run_viewer = b.addRunArtifact(viewer_exe);
    if (b.args) |args| {
        run_viewer.addArgs(args);
    }
    const run_viewer_step = b.step("run-viewer", "Run the OpenGL viewer example");
    run_viewer_step.dependOn(&run_viewer.step);
}

fn addGlfw(
    mod: *std.Build.Module,
    zglfw_mod: *std.Build.Module,
) void {
    mod.addImport("zglfw", zglfw_mod);
    mod.linkSystemLibrary("glfw", .{});

    if (mod.resolved_target.?.result.os.tag == .macos) {
        mod.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
        mod.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
    }
}

pub fn buildMujoco(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    mujoco_dep: *std.Build.Dependency,
) *std.Build.Step.Compile {
    // TODO: Things to turn into options
    const is_wasm = false;

    const mujoco_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,

        .link_libc = true,
        .link_libcpp = true,
    });

    const mujoco_modD: ModD = .{
        .mod = mujoco_mod,
        .dep = mujoco_dep,
    };

    const mujoco_lib = b.addLibrary(.{
        .name = "mujoco",
        .root_module = mujoco_mod,
    });

    mujoco_mod.addIncludePath(mujoco_dep.path("include"));
    mujoco_mod.addIncludePath(mujoco_dep.path("plugin"));
    mujoco_mod.addIncludePath(mujoco_dep.path("src"));

    for (MujocoHeaders) |header| {
        mujoco_lib.installHeader(mujoco_dep.path(header), header["include/".len..]);
    }

    addMujocoDependencies(mujoco_mod, b);

    mujoco_modD.addToModule(&.{
        MujocoEngineSources,
        MujocoXmlSources,
        MujocoUserCppSources,
        MujocoUserCSources,
        MujocoThreadSources,
        MujocoClassicRenderCSources,
        MujocoClassicRenderCppSources,
    });

    if (!is_wasm) {
        mujoco_modD.addToModule(&.{});
    }

    return mujoco_lib;
}

fn addMujocoDependencies(mod: *std.Build.Module, b: *std.Build) void {
    addCcd(mod, b);
    addTinyXml2(mod, b);
    addLodePng(mod, b);
    addTinyObjLoader(mod, b);
    addQhull(mod, b);
    addMarchingCubeCpp(mod, b);

    mod.addCMacro("_GNU_SOURCE", "1");
    mod.addCMacro("CCD_STATIC_DEFINE", "1");
    mod.addCMacro("MUJOCO_DLL_EXPORTS", "1");
    mod.addCMacro("MC_IMPLEM_ENABLE", "1");
}

fn addMarchingCubeCpp(mod: *std.Build.Module, b: *std.Build) void {
    const marchingcubecpp_dep = b.dependency("marchingcubecpp", .{});
    mod.addIncludePath(marchingcubecpp_dep.path("."));
}

fn addCcd(mod: *std.Build.Module, b: *std.Build) void {
    const ccd_dep = b.dependency("ccd", .{});

    const ccd_config_header = b.addConfigHeader(.{
        .style = .{ .cmake = ccd_dep.path("src/ccd/config.h.cmake.in") },
        .include_path = "ccd/config.h",
    }, .{
        .CCD_VERSION = "2.1",
        .CCD_SINGLE = null,
        .CCD_DOUBLE = true,
    });

    mod.addConfigHeader(ccd_config_header);
    mod.addIncludePath(ccd_dep.path("src"));
    mod.addCSourceFiles(.{
        .root = ccd_dep.path("src"),
        .files = &.{
            "ccd.c",
            "mpr.c",
            "polytope.c",
            "support.c",
            "vec3.c",
        },
        .flags = &.{
            "-DCCD_STATIC_DEFINE",
            "-D_GNU_SOURCE",
            "-DENABLE_DOUBLE_PRECISION",
        },
    });
}

fn addTinyXml2(mod: *std.Build.Module, b: *std.Build) void {
    const tinyxml2_dep = b.dependency("tinyxml2", .{});

    mod.addCSourceFiles(.{
        .root = tinyxml2_dep.path("."),
        .files = &.{"tinyxml2.cpp"},
        .flags = &.{"-std=c++17"},
    });
    mod.addIncludePath(tinyxml2_dep.path("."));
}

fn addLodePng(mod: *std.Build.Module, b: *std.Build) void {
    const lodepng_dep = b.dependency("lodepng", .{});

    mod.addCSourceFiles(.{
        .root = lodepng_dep.path("."),
        .files = &.{"lodepng.cpp"},
        .flags = &.{"-std=c++17"},
    });
    mod.addIncludePath(lodepng_dep.path("."));
}

fn addTinyObjLoader(mod: *std.Build.Module, b: *std.Build) void {
    const tinyobjloader_dep = b.dependency("tinyobjloader", .{});

    mod.addCSourceFiles(.{
        .root = tinyobjloader_dep.path("."),
        .files = &.{"tiny_obj_loader.cc"},
        .flags = &.{"-std=c++17"},
    });
    mod.addIncludePath(tinyobjloader_dep.path("."));
}

fn addQhull(mod: *std.Build.Module, b: *std.Build) void {
    const qhull_dep = b.dependency("qhull", .{});

    mod.addCSourceFiles(.{
        .root = qhull_dep.path("src/libqhull_r"),
        .files = &.{
            "libqhull_r.c",
            "geom_r.c",
            "geom2_r.c",
            "global_r.c",
            "io_r.c",
            "mem_r.c",
            "merge_r.c",
            "poly_r.c",
            "poly2_r.c",
            "qset_r.c",
            "random_r.c",
            "rboxlib_r.c",
            "stat_r.c",
            "user_r.c",
            "usermem_r.c",
            "userprintf_r.c",
        },
    });

    mod.addIncludePath(qhull_dep.path("src"));
    mod.addIncludePath(qhull_dep.path("src/libqhull_r"));
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

const ModD = struct {
    mod: *std.Build.Module,
    dep: *std.Build.Dependency,

    pub fn addToModule(self: *const ModD, modules: []const MujocoModule) void {
        for (modules) |mod| {
            mod.addToModule(self);
        }
    }
};

const MujocoModule = struct {
    root: []const u8,
    sources: []const []const u8,
    flags: []const []const u8 = &.{},

    pub fn addToModule(self: *const MujocoModule, modD: *const ModD) void {
        modD.mod.addCSourceFiles(.{
            .root = modD.dep.path(self.root),
            .files = self.sources,
            .flags = self.flags,
        });
    }
};

const MujocoEngineSources: MujocoModule = .{
    .root = "src/engine",
    .sources = &.{
        "engine_callback.c",
        "engine_collision_box.c",
        "engine_collision_convex.c",
        "engine_collision_driver.c",
        "engine_collision_gjk.c",
        "engine_collision_primitive.c",
        "engine_collision_sdf.c",
        "engine_core_constraint.c",
        "engine_core_util.c",
        "engine_core_smooth.c",
        "engine_crossplatform.cc",
        "engine_derivative.c",
        "engine_derivative_fd.c",
        "engine_forward.c",
        "engine_inverse.c",
        "engine_init.c",
        "engine_island.c",
        "engine_io.c",
        "engine_memory.c",
        "engine_name.c",
        "engine_passive.c",
        "engine_plugin.cc",
        "engine_print.c",
        "engine_ray.c",
        "engine_sensor.c",
        "engine_setconst.c",
        "engine_sleep.c",
        "engine_solver.c",
        "engine_support.c",
        "engine_util_blas.c",
        "engine_util_errmem.c",
        "engine_util_misc.c",
        "engine_util_solve.c",
        "engine_util_sparse.c",
        "engine_util_spatial.c",
        "engine_vis_init.c",
        "engine_vis_interact.c",
        "engine_vis_visualize.c",
    },
};

const MujocoXmlSources: MujocoModule = .{
    .root = "src/xml",
    .sources = &.{
        "xml.cc",
        "xml_api.cc",
        "xml_base.cc",
        "xml_global.cc",
        "xml_native_reader.cc",
        "xml_numeric_format.cc",
        "xml_native_writer.cc",
        "xml_urdf.cc",
        "xml_util.cc",
    },
    .flags = &.{
        "-std=c++20",
    },
};

const MujocoUserCppSources: MujocoModule = .{
    .root = "src/user",
    .sources = &.{
        "user_api.cc",
        "user_cache.cc",
        "user_composite.cc",
        "user_flexcomp.cc",
        "user_mesh.cc",
        "user_model.cc",
        "user_objects.cc",
        "user_resource.cc",
        "user_threadpool.cc",
        "user_util.cc",
        "user_vfs.cc",
    },
    .flags = &.{
        "-std=c++20",
    },
};

const MujocoUserCSources: MujocoModule = .{
    .root = "src/user",
    .sources = &.{
        "user_init.c",
    },
};

const MujocoThreadSources: MujocoModule = .{
    .root = "src/thread",
    .sources = &.{
        "thread_pool.cc",
        "thread_task.cc",
    },
    .flags = &.{
        "-std=c++20",
    },
};

const MujocoClassicRenderCppSources: MujocoModule = .{
    .root = "src/render/classic",
    .sources = &.{
        "glad/loader.cc",
    },
    .flags = &.{
        "-std=c++20",
    },
};
const MujocoClassicRenderCSources: MujocoModule = .{
    .root = "src/render/classic",
    .sources = &.{
        "glad/glad.c",
        "render_context.c",
        "render_gl2.c",
        "render_gl3.c",
        "render_util.c",
    },
};
