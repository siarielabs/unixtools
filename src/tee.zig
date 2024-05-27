const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

const Opts = struct {
    program: []const u8,
    files: std.ArrayList([]const u8),
    append: bool = false,
    help: bool = false,

    pub fn parse(allocator: mem.Allocator, default_name: []const u8) !Opts {
        var args = std.process.args();
        defer args.deinit();

        var opts = Opts{
            .program = args.next() orelse default_name,
            .files = std.ArrayList([]const u8).init(allocator),
        };

        while (args.next()) |opt| {
            if (!mem.startsWith(u8, opt, "-")) {
                try opts.files.append(opt);
            }
            if (mem.eql(u8, opt, "-a")) opts.append = true;
            if (mem.eql(u8, opt, "-h")) opts.help = true;
        }

        return opts;
    }

    pub fn deinit(self: *Opts) void {
        self.files.deinit();
    }

    pub fn printHelpAndExit(self: Opts) noreturn {
        const usage = comptime 
        \\Usage: {s} [OPTIONS]... [FILE]...
        \\Copy standard input to each file, and also standard output
        \\
        \\OPTIONS:
        \\ -a    append to given FILEs, do not overwrite
        \\ -h    display this help and exit
        \\
        ;
        stdout.writer().print(usage, .{self.program}) catch unreachable;
        std.process.exit(0);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) std.log.debug("memleak", .{});

    var opts = try Opts.parse(allocator, "ztee");
    defer opts.deinit();
    if (opts.help) {
        opts.printHelpAndExit();
    }

    var writer_list = std.ArrayList(fs.File).init(allocator);
    defer {
        for (writer_list.items) |file| file.close();
        writer_list.deinit();
    }

    try writer_list.append(stdout);

    for (opts.files.items) |filepath| {
        var file = try fs.cwd().createFile(filepath, .{ .truncate = !opts.append });
        if (opts.append) {
            const stat = try file.stat();
            try file.seekTo(stat.size);
        }
        try writer_list.append(file);
    }

    var buf_reader = std.io.bufferedReader(stdin.reader());
    var reader = buf_reader.reader();

    const buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer);

    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |buf| {
        for (writer_list.items) |f| {
            try f.writer().print("{s}\n", .{buf});
        }
    }
}
