const std = @import("std");
const TextReader = @import("TextReader.zig");
const TextLine = @import("TextLine.zig");
const Allocator = std.mem.Allocator;
const File = std.fs.File;
const print = std.debug.print;
const isAlphanumeric = std.ascii.isAlphanumeric;
const ArrayList = std.ArrayList;

test "Day 3: part 1" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;

    var input_stream = std.io.fixedBufferStream(input);

    const total = try solvePuzzle(input_stream.reader(), 10);

    try std.testing.expectEqual(total, 4361);
}

fn solvePuzzle(reader: anytype, comptime line_len: usize) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var symbols = ArrayList(Symbol).init(allocator);
    defer symbols.deinit();

    var line_it = TextReader.read(reader);

    const empty_line = "." ** line_len;
    var line0 = try allocator.dupe(u8, empty_line);

    var next_line: ?[]const u8 = line_it.next() catch null;
    var line1 = try allocator.dupe(u8, next_line.?);

    next_line = line_it.next() catch null;
    var line2 = try allocator.dupe(u8, next_line.?);

    var line_index: usize = 1;
    var has_line = next_line != null;
    while (has_line) {
        has_line = next_line != null;
        for (line1, 0..) |c, pos| {
            if (!Symbol.isSymbol(c)) continue;
            var symbol = Symbol{
                .line = line_index,
                .position = pos,
                .value = c,
                .numbers = ArrayList(usize).init(allocator),
            };

            try symbol.findAdjacentNumbers([3][]u8{ line0, line1, line2 });

            if (symbol.numbers.items.len > 0) {
                try symbols.append(symbol);
            }
        }

        next_line = line_it.next() catch null;

        @memcpy(line0, line1);
        @memcpy(line1, line2);
        @memcpy(line2, next_line orelse empty_line);

        line_index += 1;
    }

    var total: usize = 0;
    for (symbols.items) |symbol| {
        for (symbol.numbers.items) |number| {
            total += number;
        }
    }

    return total;
}

const Symbol = struct {
    /// Line index in the input
    line: usize,
    /// Symbol position in the line
    position: usize,
    /// Symbol value
    value: u8,

    numbers: ArrayList(usize),

    pub fn isSymbol(c: u8) bool {
        return c != '.' and !isAlphanumeric(c);
    }

    /// Given the symbol sits between two lines, find the adjacent numbers.
    /// eg. symbol position on lines, adjacent numbers [123, 56]
    /// ...123...
    /// ....*....
    /// .4...56..
    pub fn findAdjacentNumbers(self: *Symbol, lines: [3][]u8) !void {
        const pos = self.position;
        const line0 = lines[0];
        const line1 = lines[1];
        const line2 = lines[2];

        // numbers on same line
        if (TextLine.getLeftNumber(line1, pos)) |number| {
            try self.numbers.append(number);
        }
        if (TextLine.getRightNumber(line1, pos)) |number| {
            try self.numbers.append(number);
        }

        // numbers on previous line
        if (TextLine.getFullNumber(line0, pos)) |number| {
            try self.numbers.append(number);
        } else {
            if (TextLine.getLeftNumber(line0, pos)) |number| {
                try self.numbers.append(number);
            }
            if (TextLine.getRightNumber(line0, pos)) |number| {
                try self.numbers.append(number);
            }
        }

        // numbers on next line
        if (TextLine.getFullNumber(line2, pos)) |number| {
            try self.numbers.append(number);
        } else {
            if (TextLine.getLeftNumber(line2, pos)) |number| {
                try self.numbers.append(number);
            }
            if (TextLine.getRightNumber(line2, pos)) |number| {
                try self.numbers.append(number);
            }
        }
    }
};

pub fn main() !void {
    var file = try std.fs.cwd().openFile("../input.txt", .{});
    defer file.close();

    const total = try solvePuzzle(file.reader(), 140);

    print("Total: {d}\n", .{total});
}
