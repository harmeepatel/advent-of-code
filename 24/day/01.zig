const std = @import("std");

const ArrayList = std.ArrayList;
const print = std.debug.print;
const input = @embedFile("input/01");
const InputType = i32;

pub fn main() !void {
    var timer = try std.time.Timer.start();
    defer std.debug.print("―――――― time: {}ms ―――――――", .{timer.read() / std.time.ns_per_ms});

    var new_split = std.mem.tokenizeScalar(u8, input, '\n');
    var input_len: usize = 0;
    while (new_split.next()) |_| {
        input_len += 1;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var left_arr = try allocator.alloc(InputType, input_len);
    defer allocator.free(left_arr);
    var right_arr = try allocator.alloc(InputType, input_len);
    defer allocator.free(right_arr);

    var i: usize = 0;
    new_split.reset();
    while (new_split.next()) |line| : (i += 1) {
        var tab_split = std.mem.tokenizeScalar(u8, line, ' ');
        const left = tab_split.next().?;
        const right = tab_split.next().?;

        left_arr[i] = try std.fmt.parseInt(InputType, left, 10);
        right_arr[i] = try std.fmt.parseInt(InputType, right, 10);
    }
    std.mem.sort(InputType, left_arr, {}, comptime std.sort.asc(InputType));
    std.mem.sort(InputType, right_arr, {}, comptime std.sort.asc(InputType));

    var output: InputType = 0;
    for (left_arr, right_arr) |l, r| {
        output += @intCast(@abs(l - r));
    }
    print("part 1: {any}\n", .{output});

    output = 0;
    var count: InputType = 0;
    for (left_arr) |l| {
        for (right_arr) |r| {
            if (l == r) {
                count += 1;
            }
        }
        output += l * count;
        count = 0;
    }
    print("part 2: {any}\n", .{output});
}
