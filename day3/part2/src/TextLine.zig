const std = @import("std");
const print = std.debug.print;
const charToDigit = std.fmt.charToDigit;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;

pub fn getFullNumber(line: []const u8, pos: usize) ?usize {
    if (pos > line.len - 1) return null;
    const digit = charToDigit(line[pos], 10) catch return null;
    const left_nr = getLeftNumber(line, pos) orelse 0;
    const is_next_zero = line[pos + 1] == '0'; // reading number at right discards leading zeros
    const right_nr = getRightNumber(line, if (is_next_zero) pos + 1 else pos);

    var number = left_nr * 10 + digit;
    if (is_next_zero) number *= 10;

    if (right_nr) |nr| {
        var buf: [10]u8 = undefined;
        const nr_str = std.fmt.bufPrint(buf[0..], "{d}{d}", .{ number, nr }) catch return null;
        number = parseInt(usize, nr_str, 10) catch return null;
    }

    return number;
}

test "getFullNumber: returns number that has digit at position" {
    // when position inside number
    {
        const line = "..12305...";
        const number = getFullNumber(line, 4);
        try std.testing.expectEqual(number, 12305);
    }

    // when position at the begining of number
    {
        const line = "..12305...";
        const number = getFullNumber(line, 2);
        try std.testing.expectEqual(number, 12305);
    }

    // when position at the end of number
    {
        const line = "..12305...";
        const number = getFullNumber(line, 6);
        try std.testing.expectEqual(number, 12305);
    }
}

test "getFullNumber: returns null" {
    const line = "..12.345..";

    // when no digit at position
    {
        const number = getFullNumber(line, 4);
        try std.testing.expectEqual(number, null);
    }

    // when pos is bigger than line length
    {
        const number = getFullNumber(line, 20);
        try std.testing.expectEqual(number, null);
    }
}

pub fn getLeftNumber(line: []const u8, pos: usize) ?usize {
    if (pos > line.len - 1) return null;
    var left_it = std.mem.reverseIterator(line[0..pos]);
    var i: usize = 0;
    var number: ?usize = null;
    while (left_it.next()) |c| {
        const digit = charToDigit(c, 10) catch break;
        if (number) |*nr| {
            nr.* += digit * pow(usize, 10, i);
        } else {
            number = digit;
        }
        i += 1;
    }
    return number;
}

test "getLeftNumber: returns number to the left of position" {
    const line = "..123*..45";
    const number = getLeftNumber(line, 5);
    try std.testing.expectEqual(number, 123);
}

test "getLeftNumber: returns null" {
    const line = "...*.345.#";

    // when no number to the left of position
    {
        const number = getLeftNumber(line, 3);
        try std.testing.expectEqual(number, null);
    }

    // when pos is at begining of line
    {
        const number = getLeftNumber(line, 0);
        try std.testing.expectEqual(number, null);
    }

    // when pos is bigger than line length
    {
        const number = getLeftNumber(line, 20);
        try std.testing.expectEqual(number, null);
    }
}

pub fn getRightNumber(line: []const u8, pos: usize) ?usize {
    if (pos >= line.len - 1) return null;
    var number: ?usize = null;
    for (line[pos + 1 ..]) |c| {
        const digit = charToDigit(c, 10) catch break;
        if (number) |*nr| {
            nr.* = nr.* * 10 + digit;
        } else {
            number = digit;
        }
    }
    return number;
}

test "getRightNumber: returns number to the right of position" {
    const line = "..12*345...";
    const number = getRightNumber(line, 4);
    try std.testing.expectEqual(number, 345);
}

test "getRightNumber: returns null" {
    const line = "...12*.45.#";

    // when no number to the right of position
    {
        const number = getRightNumber(line, 5);
        try std.testing.expectEqual(number, null);
    }

    // when pos is at end of line
    {
        const number = getRightNumber(line, 10);
        try std.testing.expectEqual(number, null);
    }

    // when pos is bigger than line length
    {
        const number = getRightNumber(line, 20);
        try std.testing.expectEqual(number, null);
    }
}
