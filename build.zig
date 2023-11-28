const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const exe = b.addExecutable(.{
            .name = "ls",
            .root_source_file = .{ .path = "src/ls.zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
    }
}
