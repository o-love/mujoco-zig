const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;
const MjVFS = @This();
const MjModel = mujoco_zig.MjModel;

raw: ffi.mjVFS,

pub fn init() @This() {
    var vfs: ffi.mjVFS = undefined;

    ffi.mj_defaultVFS(&vfs);

    return .{
        .raw = vfs,
    };
}

pub fn deinit(self: *@This()) void {
    ffi.mj_deleteVFS(&self.raw);
}

pub const AddFileError = error{
    AlreadyExists,
    InternalError,
    OutOfMemory,
    UnkownError,
};

pub fn addFile(
    self: *@This(),
    gpa: std.mem.Allocator,
    filedir: []const u8,
    filename: []const u8,
) AddFileError!void {
    // TODO: Consider using max path. Risk: mujoco doesn't have limit.

    const filename_sent: [:0]u8 = try gpa.dupeSentinel(u8, filename, 0);
    defer gpa.free(filename_sent);

    const filedir_sent: [:0]u8 = try gpa.dupeSentinel(u8, filedir, 0);
    defer gpa.free(filedir_sent);

    return self.addFileZ(filedir_sent, filename_sent);
}

pub fn addFileZ(
    self: *@This(),
    filedir: [:0]const u8,
    filename: [:0]const u8,
) AddFileError!void {
    const result = ffi.mj_addFileVFS(&self.raw, filedir, filename);

    switch (result) {
        0 => return,
        2 => return AddFileError.AlreadyExists,
        -1 => return AddFileError.InternalError,
        else => return AddFileError.UnkownError,
    }
}

pub fn containsFile(
    self: *@This(),
    gpa: std.mem.Allocator,
    filedir: []const u8,
    filename: []const u8,
) error{OutOfMemory}!bool {
    const filename_sent: [:0]u8 = try gpa.dupeSentinel(u8, filename, 0);
    defer gpa.free(filename_sent);

    const filedir_sent: [:0]u8 = try gpa.dupeSentinel(u8, filedir, 0);
    defer gpa.free(filedir_sent);

    return self.containsFileZ(filedir_sent, filename_sent);
}

pub fn containsFileZ(
    self: *@This(),
    filedir: [:0]const u8,
    filename: [:0]const u8,
) bool {
    const result = ffi.mj_containsFileVFS(&self.raw, filedir, filename);

    return result != 0;
}

const testing = std.testing;

test "init and deinit" {
    mujoco_zig.init();

    var vfs: MjVFS = .init();
    defer vfs.deinit();
}

test "Add and load model" {
    const test_utils = @import("test_utils.zig");
    var buffer: [std.fs.max_path_bytes]u8 = undefined;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const filepath = "hello.xml";
    const dirpathsize = try tmp.dir.realPath(testing.io, &buffer);
    const dirpath: []const u8 = buffer[0..dirpathsize];

    try tmp.dir.writeFile(testing.io, .{
        .sub_path = filepath,
        .data = test_utils.BasicModelStr,
    });

    var vfs: MjVFS = .init();
    defer vfs.deinit();

    try vfs.addFile(testing.allocator, dirpath, filepath);

    try testing.expectEqual(true, vfs.containsFile(testing.allocator, dirpath, filepath));

    const model: MjModel = try .fromXmlVfs(testing.allocator, filepath, &vfs);
    defer model.deinit();
}

test "Add non existing file" {
    // When a file does not exist, mujoco creates an empty buffer
    mujoco_zig.init();

    var vfs: MjVFS = .init();
    defer vfs.deinit();

    try vfs.addFile(testing.allocator, "DoesNotExist", "DoesNotExist");

    try testing.expectEqual(true, vfs.containsFile(testing.allocator, "DoesNotExist", "DoesNotExist"));
}
