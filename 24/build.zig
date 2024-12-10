const std = @import("std");
const print = std.debug.print;

const Build = std.Build;
const Step = Build.Step;
const Child = std.process.Child;

const tree =
    \\       .|,
    \\       -*-
    \\      '/'\`
    \\      /`'o\
    \\     /#,o'`\
    \\    o/`"#,`\o
    \\    /`o``"#,\
    \\   o/#,`'o'`\o
    \\   /o`"#,`',o\
    \\  o`-._`"#_.-'o
    \\      _|"|_
    \\      \=%=/   
    \\       ‾‾‾
    \\
;
var days = [_]Day{
    .{ .main_file = "01.zig" },
    .{ .main_file = "02.zig" },
    .{ .main_file = "03.zig" },
};

pub fn build(b: *std.Build) void {
    b.top_level_steps = .{};

    const work_path = "day";
    var prev_step = &PrintStep.create(b, tree).step;

    const days_step = b.step("days", "Check all days");
    b.default_step = days_step;

    const day_num = b.option(u8, "n", "Select day (1-25)");
    if (day_num) |n| {
        if (n < 1 or n > 25) {
            print("provide a number between 1-25\n", .{});
            std.process.exit(2);
        }
        const d = days[n - 1];
        const verify_step = DayStep.create(b, d, work_path);
        verify_step.step.dependOn(prev_step);

        prev_step = &verify_step.step;

        days_step.dependOn(prev_step);
        return;
    }

    for (days) |d| {
        const verify_step = DayStep.create(b, d, work_path);
        verify_step.step.dependOn(prev_step);

        prev_step = &verify_step.step;
    }
    days_step.dependOn(prev_step);
}

pub const Day = struct {
    main_file: []const u8,
    check_stdout: bool = false,

    /// Returns the name of the main file with .zig stripped.
    pub fn name(self: Day) []const u8 {
        return std.fs.path.stem(self.main_file);
    }
};

/// Prints a message to stderr.
const PrintStep = struct {
    step: Step,
    message: []const u8,

    pub fn create(owner: *Build, message: []const u8) *PrintStep {
        const self = owner.allocator.create(PrintStep) catch @panic("OOM");
        self.* = .{
            .step = Step.init(.{
                .id = .custom,
                .name = "print",
                .owner = owner,
                .makeFn = make,
            }),
            .message = message,
        };

        return self;
    }

    fn make(step: *Step, _: std.Progress.Node) !void {
        const self: *PrintStep = @alignCast(@fieldParentPtr("step", step));
        print("{s}", .{self.message});
    }
};

pub fn trimLines(allocator: std.mem.Allocator, buf: []const u8) ![]const u8 {
    var list = try std.ArrayList(u8).initCapacity(allocator, buf.len);

    var iter = std.mem.splitSequence(u8, buf, " \n");
    while (iter.next()) |line| {
        // TODO: trimming CR characters is probably not necessary.
        const data = std.mem.trimRight(u8, line, " \r");
        try list.appendSlice(data);
        try list.append('\n');
    }

    const result = try list.toOwnedSlice(); // TODO: probably not necessary

    // Remove the trailing LF character, that is always present in the exercise
    // output.
    return std.mem.trimRight(u8, result, "\n");
}

/// Ziglings
/// Build mode.
const DayStep = struct {
    step: Step,
    day: Day,
    work_path: []const u8,

    pub fn create(
        b: *Build,
        day: Day,
        work_path: []const u8,
    ) *DayStep {
        const self = b.allocator.create(DayStep) catch @panic("OOM");
        self.* = .{
            .step = Step.init(.{
                .id = .custom,
                .name = day.main_file,
                .owner = b,
                .makeFn = make,
            }),
            .day = day,
            .work_path = work_path,
        };
        return self;
    }

    fn make(step: *Step, progress_node: std.Progress.Node) !void {
        // NOTE: Using exit code 2 will prevent the Zig compiler to print the message:
        // "error: the following build command failed with exit code 1:..."
        const self: *DayStep = @alignCast(@fieldParentPtr("step", step));

        const exe_path = self.compile(progress_node) catch |err| {
            self.printErrors();

            print("\nself.compile: {any}\n", .{err});
            std.process.exit(2);
        };

        self.run(exe_path, progress_node) catch |err| {
            self.printErrors();
            print("\nself.run: {any}\n", .{err});
            std.process.exit(2);
        };
        self.printErrors();
    }

    fn run(self: *DayStep, exe_path: []const u8, _: std.Progress.Node) !void {
        print("―――――――― {s} ――――――――\n", .{self.day.main_file});
        const b = self.step.owner;

        // Allow up to 1 MB of stdout capture.
        const max_output_bytes = 1 * 1024 * 1024;

        const result = Child.run(.{
            .allocator = b.allocator,
            .argv = &.{exe_path},
            .cwd = b.build_root.path.?,
            .cwd_dir = b.build_root.handle,
            .max_output_bytes = max_output_bytes,
        }) catch |err| {
            return self.step.fail("unable to spawn {s}: {s}", .{
                exe_path, @errorName(err),
            });
        };

        return self.check_output(result);
    }

    fn check_output(self: *DayStep, result: Child.RunResult) !void {
        const b = self.step.owner;

        // Make sure it exited cleanly.
        switch (result.term) {
            .Exited => |code| {
                if (code != 0) {
                    return self.step.fail("{s} exited with error code {d} (expected {})", .{
                        self.day.main_file, code, 0,
                    });
                }
            },
            else => {
                return self.step.fail("{s} terminated unexpectedly", .{
                    self.day.main_file,
                });
            },
        }

        const output = trimLines(b.allocator, result.stderr) catch @panic("OOM");

        print("{s}\n", .{output});
    }

    fn compile(self: *DayStep, prog_node: std.Progress.Node) ![]const u8 {
        const b = self.step.owner;
        const day_path = self.day.main_file;
        const path = std.fs.path.join(b.allocator, &.{ self.work_path, day_path }) catch @panic("OOM");

        var zig_args = std.ArrayList([]const u8).init(b.allocator);
        defer zig_args.deinit();

        zig_args.append(b.graph.zig_exe) catch @panic("OOM");

        const cmd = "build-exe";
        zig_args.append(cmd) catch @panic("OOM");

        zig_args.append(b.pathFromRoot(path)) catch @panic("OOM");

        zig_args.append("--cache-dir") catch @panic("OOM");
        zig_args.append(b.pathFromRoot(b.cache_root.path.?)) catch @panic("OOM");

        zig_args.append("--listen=-") catch @panic("OOM");

        // NOTE: After many changes in zig build system, we need to create the cache path manually.
        // See https://github.com/ziglang/zig/pull/21115
        // Maybe there is a better way (in the future).
        const exe_dir = try self.step.evalZigProcess(zig_args.items, prog_node);
        // NOTE: useful in zig v0.14.0
        // const exe_name = self.day.name();
        // const sep = std.fs.path.sep_str;
        // const root_path = exe_dir.?.root_dir.path.?;
        // const sub_path = exe_dir.?.subPathOrDot();
        // const exe_path = b.fmt("{s}{s}{s}{s}{s}", .{ root_path, sep, sub_path, sep, exe_name });

        return exe_dir.?;
    }

    fn printErrors(self: *DayStep) void {
        // Display error/warning messages.
        if (self.step.result_error_msgs.items.len > 0) {
            for (self.step.result_error_msgs.items) |msg| {
                print("{s}\n", .{msg});
            }
        }

        // Render compile errors at the bottom of the terminal.
        if (self.step.result_error_bundle.errorMessageCount() > 0) {
            self.step.result_error_bundle.renderToStdErr(.{ .ttyconf = .no_color });
        }
    }
};
