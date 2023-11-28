const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const stderr = std.io.getStdErr();
const stdout = std.io.getStdOut();

pub fn main() !void {
    var args = std.process.args();
    defer args.deinit();

    _ = args.next() orelse "ls";
    const path = args.next() orelse ".";

    const stat = try fs.cwd().statFile(path);
    switch (stat.kind) {
        .directory => try ls(path),
        else => try stdout.writer().print("{s}\n", .{path}),
    }
}

fn ls(path: []const u8) !void {
    var dir = try fs.cwd().openIterableDir(path, .{});
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |item| {
        try stdout.writer().print("{s}\n", .{item.name});
    }
}
