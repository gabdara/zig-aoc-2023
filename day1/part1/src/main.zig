const std = @import("std");
const print = std.debug.print;
const FixedBufferStream = std.io.FixedBufferStream;
const File = std.fs.File;

test "Day 1: part 1" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;

    var input_stream = std.io.fixedBufferStream(input);
    const total = sumCalibrationValues(FixedBufferStream([]const u8), &input_stream);

    try std.testing.expectEqual(total, 142);
}

const digits = "0123456789";
fn getNumberFromLine(line: []const u8) u8 {
    const first_digit = if (std.mem.indexOfAny(u8, line, digits)) |i| line[i] else '0';
    const last_digit = if (std.mem.lastIndexOfAny(u8, line, digits)) |i| line[i] else '0';

    var nrBuf: [2]u8 = undefined;
    const nrStr = std.fmt.bufPrint(nrBuf[0..], "{c}{c}", .{ first_digit, last_digit }) catch "0";

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
