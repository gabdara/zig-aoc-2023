const std = @import("std");
const print = std.debug.print;
const FixedBufferStream = std.io.FixedBufferStream;
const File = std.fs.File;

test "Day 1: part 2" {
    const input =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;

    var input_stream = std.io.fixedBufferStream(input);
    const total = sumCalibrationValues(FixedBufferStream([]const u8), &input_stream);

    try std.testing.expectEqual(total, 281);
}

const digits = "0123456789";
const str_digits = [9][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn getNumberFromLine(line: []const u8) u8 {
    var first_digit_index = std.mem.indexOfAny(u8, line, digits);
    var last_digit_index = std.mem.lastIndexOfAny(u8, line, digits);

    var first_digit: usize = if (first_digit_index) |i| std.fmt.parseInt(u8, line[i .. i + 1], 10) catch 0 else 0;
    var last_digit: usize = if (last_digit_index) |i| std.fmt.parseInt(u8, line[i .. i + 1], 10) catch 0 else 0;

    for (str_digits, 0..) |str_digit, digit_pos| {
        if (std.mem.indexOf(u8, line, str_digit)) |i| {
            if (first_digit_index) |first_index| {
                if (i < first_index) {
                    first_digit_index = i;
                    first_digit = digit_pos + 1;
                }
            } else {
                first_digit_index = i;
                first_digit = digit_pos + 1;
            }
        }

        if (std.mem.lastIndexOf(u8, line, str_digit)) |i| {
            if (last_digit_index) |last_index| {
                if (i > last_index) {
                    last_digit_index = i;
                    last_digit = digit_pos + 1;
                }
            } else {
                last_digit_index = i;
                last_digit = digit_pos + 1;
            }
        }
    }

    var nrBuf: [2]u8 = undefined;
    const nrStr = std.fmt.bufPrint(nrBuf[0..], "{d}{d}", .{ first_digit, last_digit }) catch "0";

    return std.fmt.parseInt(u8, nrStr, 10) catch 0;
}

fn sumCalibrationValues(comptime T: type, input_stream: *T) u32 {
    var buf_reader = std.io.bufferedReader(input_stream.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: u32 = 0;
    while (in_stream.readUntilDelimiterOrEof(&buf, '\n') catch "0") |line| {
        const nr = getNumberFromLine(line);
        total += nr;
    }

    return total;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("../input.txt", .{});
    defer file.close();

    const total = sumCalibrationValues(File, &file);
    print("Total: {}\n", .{total});
}
