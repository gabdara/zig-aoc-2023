const std = @import("std");
const print = std.debug.print;
const TextReader = @import("TextReader.zig");
const NumberSet = @import("NumberSet.zig");
const Allocator = std.mem.Allocator;
const File = std.fs.File;
const ArrayList = std.ArrayList;
const AutoArrayHashMap = std.AutoArrayHashMap;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;

test "Day 4: part 1" {
    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;

    var input_stream = std.io.fixedBufferStream(input);

    const total = try solvePuzzle(input_stream.reader());

    try std.testing.expectEqual(@as(usize, 13), total);
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("../input.txt", .{});
    defer file.close();

    const total = try solvePuzzle(file.reader());

    print("Total: {d}\n", .{total});
}

fn solvePuzzle(reader: anytype) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var cards = ArrayList(Card).init(allocator);
    defer cards.deinit();

    var line_it = TextReader.read(reader);
    while (line_it.next() catch null) |line| {
        var card_it = tokenizeScalar(u8, line[5..], ':');
        const index_str = std.mem.trimLeft(u8, card_it.next().?, " ");
        var card = Card.init(allocator, try parseInt(u8, index_str, 10));

        var numbers_it = tokenizeScalar(u8, card_it.next().?[1..], '|');

        var wining_numbers_it = tokenizeScalar(u8, numbers_it.next().?, ' ');
        while (wining_numbers_it.next()) |nr_str| {
            try card.wining_numbers.put(try parseInt(u8, nr_str, 10), {});
        }

        var user_numbers_it = tokenizeScalar(u8, numbers_it.next().?, ' ');
        while (user_numbers_it.next()) |nr_str| {
            try card.user_numbers.put(try parseInt(u8, nr_str, 10), {});
        }

        try cards.append(card);
    }

    var total: usize = 0;
    for (cards.items) |card| {
        const lucky_numbers = try NumberSet.intersection(u8, allocator, card.wining_numbers, card.user_numbers);
        if (lucky_numbers.len == 0) continue;
        total += std.math.pow(usize, 2, lucky_numbers.len - 1);
    }
    return total;
}

const Card = struct {
    index: usize,
    wining_numbers: AutoArrayHashMap(u8, void),
    user_numbers: AutoArrayHashMap(u8, void),

    pub fn init(allocator: Allocator, index: usize) Card {
        return Card{
            .index = index,
            .wining_numbers = AutoArrayHashMap(u8, void).init(allocator),
            .user_numbers = AutoArrayHashMap(u8, void).init(allocator),
        };
    }

    pub fn deinit(self: *Card) void {
        self.wining_numbers.deinit();
        self.user_numbers.deinit();
    }
};
