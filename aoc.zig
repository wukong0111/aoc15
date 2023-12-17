const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    const day1res = try day1();
    std.debug.print("day1.1 {}\n", .{day1res[0]});
    std.debug.print("day1.2 {}\n", .{day1res[1]});
    const day2res = try day2();
    std.debug.print("day2.1 {}\n", .{day2res[0]});
    std.debug.print("day2.2 {}\n", .{day2res[1]});
    const day3res = try day3();
    std.debug.print("day3.1 {}\n", .{day3res[0]});
    std.debug.print("day3.2 {}\n", .{day3res[1]});
    const day4res = try day4();
    std.debug.print("day4.1 {}\n", .{day4res[0]});
    std.debug.print("day4.2 {}\n", .{day4res[1]});
    const day5res = try day5();
    std.debug.print("{}\n", .{day5res[0]});
}

fn day1() ![2]i64 {
    var allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd()
        .readFileAlloc(allocator, "day1.txt", std.math.maxInt(usize));
    defer allocator.free(contents);

    var floor: i32 = 0;

    var pos: i64 = 1;
    var base_pos: i64 = 1;
    var base_reached = false;

    for (contents) |char| {
        switch (char) {
            '(' => floor += 1,
            ')' => floor -= 1,
            else => continue,
        }

        if (!base_reached and floor == -1) {
            base_pos = pos;
            base_reached = true;
        }
        pos += 1;
    }
    return [2]i64{ floor, base_pos };
}

test "day1 test" {
    const res = try day1();
    try expect(res[0] == 138);
    try expect(res[1] == 1771);
}

fn day2() ![2]i64 {
    var allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd()
        .readFileAlloc(allocator, "day2.txt", std.math.maxInt(usize));
    defer allocator.free(contents);

    var tokenizer = std.mem.tokenizeAny(u8, contents, "\n");
    var nums: [3]i32 = undefined;
    var paper: i64 = 0;
    var ribbon: i64 = 0;
    while (tokenizer.next()) |line| {
        var numTokenizer = std.mem.tokenizeAny(u8, line, "x");
        var i: usize = 0;
        while (numTokenizer.next()) |numStr| {
            nums[i] = std.fmt.parseInt(i32, numStr, 10) catch continue;
            i += 1;
        }
        const l = nums[0];
        const w = nums[1];
        const h = nums[2];
        const lw = l * w;
        const wh = w * h;
        const hl = h * l;
        const slack = @min(@min(lw, wh), hl);
        const area = 2 * lw + 2 * wh + 2 * hl;
        const boxPaper = area + slack;
        paper += boxPaper;

        std.sort.insertion(i32, &nums, {}, std.sort.asc(i32));
        const boxRibbon = nums[0] + nums[0] + nums[1] + nums[1] + (l * w * h);
        ribbon += boxRibbon;
    }
    return [2]i64{ paper, ribbon };
}

test "day2 test" {
    const res = try day2();
    try expect(res[0] == 1588178);
    try expect(res[1] == 3783758);
}

fn day3() ![2]i64 {
    var allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd()
        .readFileAlloc(allocator, "day3.txt", std.math.maxInt(usize));
    defer allocator.free(contents);
    var houses = std.AutoHashMap([2]i64, void).init(std.heap.page_allocator);
    defer houses.deinit();
    var san_rob_houses = std.AutoHashMap([2]i64, void).init(std.heap.page_allocator);
    defer san_rob_houses.deinit();
    var santa_pos = [2]i64{ 0, 0 };
    var robo_santa_pos = [2]i64{ 0, 0 };
    var robo_pos = [2]i64{ 0, 0 };
    var mov_counter: u64 = 0;
    var santa_time = true;
    for (contents) |ele| {
        mov_counter += 1;

        if ((mov_counter % 2) == 0) {
            santa_time = false;
        } else {
            santa_time = true;
        }
        try houses.put(santa_pos, {});
        if (santa_time) {
            try san_rob_houses.put(robo_santa_pos, {});
        } else {
            try san_rob_houses.put(robo_pos, {});
        }

        // std.debug.print("santa: {}{}, robot: {}{}, san time {}\n", .{ robo_santa_pos[0], robo_santa_pos[1], robo_pos[0], robo_pos[1], (mov_counter % 2) });
        switch (ele) {
            '^' => {
                santa_pos[1] += 1;
                if (santa_time) {
                    robo_santa_pos[1] += 1;
                } else {
                    robo_pos[1] += 1;
                }
            },
            'v' => {
                santa_pos[1] -= 1;
                if (santa_time) {
                    robo_santa_pos[1] -= 1;
                } else {
                    robo_pos[1] -= 1;
                }
            },
            '<' => {
                santa_pos[0] -= 1;
                if (santa_time) {
                    robo_santa_pos[0] -= 1;
                } else {
                    robo_pos[0] -= 1;
                }
            },
            '>' => {
                santa_pos[0] += 1;
                if (santa_time) {
                    robo_santa_pos[0] += 1;
                } else {
                    robo_pos[0] += 1;
                }
            },
            else => {},
        }
    }
    const houses_size = houses.count();
    const san_rob_houses_size = san_rob_houses.count();
    return [2]i64{ houses_size, san_rob_houses_size };
}

test "day3 test" {
    const res = try day3();
    try expect(res[0] == 2592);
    try expect(res[1] == 2360);
}

fn day4() ![2]u64 {
    const key = "yzbqklnj";
    var counter: u64 = 0;
    var res1: u64 = 0;
    var res2: u64 = 0;
    var buffer: [128]u8 = undefined;
    while (true) : (counter += 1) {
        const str = try std.fmt.bufPrint(&buffer, "{s}{d}", .{ key, counter });
        var h = std.crypto.hash.Md5.init(.{});
        var out: [16]u8 = undefined;
        h.update(str);
        h.final(out[0..]);
        const res = std.fmt.fmtSliceHexLower(out[0..]);
        const resStr = try std.fmt.bufPrint(&buffer, "{}", .{res});

        if (resStr[0] == '0' and
            resStr[1] == '0' and
            resStr[2] == '0' and
            resStr[3] == '0' and
            resStr[4] == '0')
        {
            if (res1 == 0) {
                res1 = counter;
            }
            if (resStr[5] == '0') {
                res2 = counter;
                break;
            }
        }
    }
    return [2]u64{ res1, res2 };
}

test "day4 test" {
    const res = try day4();
    try expect(res[0] == 282749);
    try expect(res[1] == 9962624);
}

fn day5() ![2]i64 {
    var alloc = std.heap.page_allocator;
    const contents = try std.fs.cwd().readFileAlloc(alloc, "day5.txt", std.math.maxInt(usize));
    defer alloc.free(contents);
    var tokenizer = std.mem.tokenizeAny(u8, contents, "\n");
    var nice_strings: u16 = 0;
    var not_nice: u16 = 0;
    while (tokenizer.next()) |line| {
        const is_nice = day5isNiceString(line);
        if (is_nice) {
            nice_strings += 1;
        } else {
            not_nice += 1;
        }

        _ = day5isNiceStringBis(line);
    }

    return [2]i64{ nice_strings, not_nice };
}

fn day5isNiceString(line: []const u8) bool {
    var has_bad_combo = false;
    var has_twice_in_a_row = false;
    var vowels_num: u8 = 0;
    var pre_char: u8 = undefined;
    for (line) |char| {
        if (pre_char == char) {
            has_twice_in_a_row = true;
        }
        if (!has_bad_combo) {
            has_bad_combo = (pre_char == 'a' and char == 'b') or
                (pre_char == 'c' and char == 'd') or
                (pre_char == 'p' and char == 'q') or
                (pre_char == 'x' and char == 'y');
        }
        pre_char = char;
        switch (char) {
            'a' => vowels_num += 1,
            'e' => vowels_num += 1,
            'i' => vowels_num += 1,
            'o' => vowels_num += 1,
            'u' => vowels_num += 1,
            else => {},
        }
    }
    return (vowels_num > 2 and has_twice_in_a_row and !has_bad_combo);
}

fn day5isNiceStringBis(line: []const u8) bool {
    const last_index = line.len - 1;
    var next_index: u8 = 0;
    var twice = false;
    var pal = false;
    for (line, 0..) |char, i| {
        if (pal and twice) continue;
        const u8i = @as(u8, @intCast(i));
        var j: u8 = u8i;
        next_index = u8i + 1;
        while (j <= last_index) : (j += 1) {
            if ((j + 2) > last_index) break; //avoid unbounds
            if (j > i) {
                if (char == line[j + 1] and line[next_index] == line[j + 2]) {
                    twice = true;
                }
            }
            if (char == line[j + 2] and char != line[j + 1]) {
                pal = true;
            }
        }
        if (pal and twice) {
            std.debug.print("{c}{c}\n", .{ char, line[j] });
            std.debug.print("nice: {s}\n", .{line});
        }
    }
    return pal and twice;
}

test "day 5" {
    const res = try day5();
    try expect(res[0] == 255);
}
