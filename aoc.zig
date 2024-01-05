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
    std.debug.print("day5.1 {}\n", .{day5res[0]});
    std.debug.print("day5.2 {}\n", .{day5res[1]});
    const day6res = try day6();
    std.debug.print("day6.1 {}\n", .{day6res[0]});
    std.debug.print("day6.2 {}\n", .{day6res[1]});
}

fn calcIndex(row: usize, column: usize, columnCount: usize) usize {
    return row * columnCount + column;
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

test "day1" {
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

test "day2" {
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

test "day3" {
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

test "day4" {
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
    var nice_strings_bis: u16 = 0;
    var not_nice: u16 = 0;
    while (tokenizer.next()) |line| {
        const is_nice = day5isNiceString(line);
        if (is_nice) {
            nice_strings += 1;
        } else {
            not_nice += 1;
        }

        if (day5isNiceStringBis(line)) nice_strings_bis += 1;
    }

    return [2]i64{ nice_strings, nice_strings_bis };
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
    var twice = false;
    var rep = false;
    for (line, 0..) |char, i| {
        if (rep and twice) continue;
        var j: usize = i + 1;
        if (j > last_index) break;
        const pair = [2]u8{ char, line[j] };
        while (j <= last_index) : (j += 1) {
            if ((j + 1) > last_index) break; //avoid unbounds
            const next_pair = [2]u8{ line[j], line[j + 1] };
            if (std.mem.eql(u8, &pair, &next_pair) and j >= i + 2) {
                twice = true;
            }
            if (j == i + 1 and char == line[j + 1]) {
                rep = true;
            }
        }
    }
    return rep and twice;
}

test "day5" {
    const res = try day5();
    try expect(res[0] == 255);
    try expect(res[1] == 55);
}

fn day6() ![2]u64 {
    const allocator = std.heap.page_allocator;
    const contents = try std.fs.cwd()
        .readFileAlloc(allocator, "day6.txt", std.math.maxInt(usize));
    defer allocator.free(contents);
    var tokenizer = std.mem.tokenizeAny(u8, contents, "\n");
    const res = try day6Resolver(&tokenizer);
    return [2]u64{ res[0], res[1] };
}

fn day6Resolver(iterator: *std.mem.TokenIterator(u8, .any)) ![2]u64 {
    const row_count: usize = 1000;
    const column_count: usize = 1000;
    const buffer_size = row_count * column_count;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.debug.print("Memory leak detected\n", .{});
        }
    }
    var matrix = try allocator.alloc(u8, buffer_size);
    defer allocator.free(matrix);
    var inc_matrix = try allocator.alloc(u8, buffer_size);
    defer allocator.free(inc_matrix);

    const on = 1;
    const off = 0;
    @memset(matrix, off);
    @memset(inc_matrix, 0);
    while (iterator.next()) |line| {
        const turn_on = "turn on";
        const turn_off = "turn off";
        const toggle = "toggle";
        var data_index: u8 = 0;
        var tokenizer = std.mem.tokenizeAny(u8, line, " ");
        var on_from: [2]u64 = undefined;
        var on_to: [2]u64 = undefined;
        var off_from: [2]u64 = undefined;
        var off_to: [2]u64 = undefined;
        var toggle_from: [2]u64 = undefined;
        var toggle_to: [2]u64 = undefined;
        if (std.mem.indexOf(u8, line, turn_on)) |_| {
            while (tokenizer.next()) |data| : (data_index += 1) {
                if (data_index == 2) {
                    on_from = try day6ExtractCoords(data);
                }
                if (data_index == 4) {
                    on_to = try day6ExtractCoords(data);
                }
            }
            var on_col_count = on_from[0];
            while (on_col_count <= on_to[0]) : (on_col_count += 1) {
                var on_row_count = on_from[1];
                while (on_row_count <= on_to[1]) : (on_row_count += 1) {
                    const index = calcIndex(on_row_count, on_col_count, column_count);
                    matrix[index] = on;
                    inc_matrix[index] += 1;
                }
            }
        }
        if (std.mem.indexOf(u8, line, turn_off)) |_| {
            while (tokenizer.next()) |data| : (data_index += 1) {
                if (data_index == 2) {
                    off_from = try day6ExtractCoords(data);
                }
                if (data_index == 4) {
                    off_to = try day6ExtractCoords(data);
                }
            }
            var off_col_count = off_from[0];
            while (off_col_count <= off_to[0]) : (off_col_count += 1) {
                var off_row_count = off_from[1];
                while (off_row_count <= off_to[1]) : (off_row_count += 1) {
                    const index = calcIndex(off_row_count, off_col_count, column_count);
                    matrix[index] = off;
                    if (inc_matrix[index] > 0) inc_matrix[index] -= 1;
                }
            }
        }
        if (std.mem.indexOf(u8, line, toggle)) |_| {
            while (tokenizer.next()) |data| : (data_index += 1) {
                if (data_index == 1) {
                    toggle_from = try day6ExtractCoords(data);
                }
                if (data_index == 3) {
                    toggle_to = try day6ExtractCoords(data);
                }
            }
            var tog_col_count = toggle_from[0];
            while (tog_col_count <= toggle_to[0]) : (tog_col_count += 1) {
                var tog_row_count = toggle_from[1];
                while (tog_row_count <= toggle_to[1]) : (tog_row_count += 1) {
                    const index = calcIndex(tog_row_count, tog_col_count, column_count);
                    const actual = matrix[index];
                    if (actual == on) {
                        matrix[index] = off;
                    }
                    if (actual == off) {
                        matrix[index] = on;
                    }
                    inc_matrix[index] += 2;
                }
            }
        }
    }
    var res: u64 = 0;
    for (matrix) |ele| {
        if (ele == on) res += 1;
    }
    var res2: u64 = 0;
    for (inc_matrix) |ele| {
        res2 = res2 + ele;
    }
    return [2]u64{ res, res2 };
}

fn day6ExtractCoords(data: []const u8) ![2]u64 {
    var data_tzer = std.mem.tokenizeAny(u8, data, ",");
    var res_index: u8 = 0;
    var res: [2]u64 = undefined;
    while (data_tzer.next()) |coord| : (res_index += 1) {
        res[res_index] = try std.fmt.parseInt(u32, coord, 10);
    }
    return res;
}

test "day6" {
    const res = try day6();
    try expect(res[0] == 400410);
    try expect(res[1] == 15343601);
}

fn day7() ![2]u64 {
    const data: u32 = 123;
    const f: u32 = data << 2;
    const d: u32 = 123 & 456;
    const e: u32 = 123 | 456;
    std.debug.print("res {d}, {d}, {d}\n", .{ f, d, e });
    const allocator = std.heap.page_allocator;

    const contents = try std.fs.cwd()
        .readFileAlloc(allocator, "day7.txt", std.math.maxInt(usize));
    defer allocator.free(contents);
    var tokenizer = std.mem.tokenizeAny(u8, contents, "\n");
    while (tokenizer.next()) |line| {
        std.debug.print("line: {s}\n", .{line});
        var instructions_tzr = std.mem.tokenizeAny(u8, line, "-> ");
        while (instructions_tzr.next()) |part| {
            std.debug.print("part: {s}\n", .{part});
        }
    }
    return [2]u64{ 0, 0 };
}

test "day7" {
    _ = try day7();
}
