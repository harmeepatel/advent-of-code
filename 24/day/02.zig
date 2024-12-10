const std = @import("std");
const print = std.debug.print;
const InputType = u32;

const Line = std.ArrayList(InputType);
const Lines = std.ArrayList(Line);

fn parseInput(allocator: std.mem.Allocator) !Lines {
    const input = @embedFile("input/02");
    var new_line = std.mem.tokenizeScalar(u8, input, '\n');
    var lines = Lines.init(allocator);

    while (new_line.next()) |l| {
        var line = Line.init(allocator);

        var nums = std.mem.tokenizeScalar(u8, l, ' ');
        while (nums.next()) |n| {
            const i = try std.fmt.parseInt(u8, n, 10);
            try line.append(i);
        }
        try lines.append(line);
    }

    return lines;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    defer std.debug.print("―――――― time: {}ms ―――――――", .{timer.read() / std.time.ns_per_ms});

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloca = gpa.allocator();
    defer _ = gpa.deinit();

    const lines = try parseInput(alloca);
    print("{any}\n", .{lines.items.len});
}
