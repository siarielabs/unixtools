const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const ls = b.addExecutable(.{
            .name = "zig-ls",
            .root_source_file = .{ .path = "src/ls.zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ls);
    }

    {
        const tee = b.addExecutable(.{
            .name = "zig-tee",
            .root_source_file = .{ .path = "src/tee.zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(tee);
    }
}
