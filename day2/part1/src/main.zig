const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;
const Allocator = std.mem.Allocator;
const FixedBufferStream = std.io.FixedBufferStream;
const File = std.fs.File;
const ArrayList = std.ArrayList;

test "Day 2: part 1" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;

    var input_stream = std.io.fixedBufferStream(input);

    const bag = Bag{ .red = 12, .green = 13, .blue = 14 };
    const total = bag.run(FixedBufferStream([]const u8), &input_stream);

    try std.testing.expectEqual(total, 8);
}

const Bag = struct {
    red: u8,
    green: u8,
    blue: u8,

    fn getRGB(self: Bag) RGB {
        return RGB{ self.red, self.green, self.blue };
    }

    pub fn run(self: Bag, comptime T: type, input_stream: *T) !u32 {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var games = std.ArrayList(Game).init(allocator);

        var buf_reader = std.io.bufferedReader(input_stream.reader());
        var buf: [1024]u8 = undefined;
        while (buf_reader.reader().readUntilDelimiterOrEof(&buf, '\n') catch "0") |line| {
            var lineIt = tokenizeScalar(u8, line[5..], ':');
            var game = Game.init(allocator, parseInt(u8, lineIt.next().?, 10) catch 0);

            var rollIt = tokenizeScalar(u8, lineIt.next().?, ';');
            var i: u8 = 0;
            while (rollIt.next()) |rollStr| {
                var roll: RGB = @splat(0);

                var cubesIt = tokenizeSequence(u8, rollStr[1..], ", ");
                while (cubesIt.next()) |cubesLine| {
                    var cubeIt = tokenizeScalar(u8, cubesLine, ' ');
                    const cube_no = parseInt(u8, cubeIt.next().?, 10) catch 0;
                    const cube_type = cubeIt.next().?;

                    var pos: u8 = undefined;
                    if (std.mem.eql(u8, cube_type, "red")) {
                        pos = 0;
                    } else if (std.mem.eql(u8, cube_type, "green")) {
                        pos = 1;
                    } else if (std.mem.eql(u8, cube_type, "blue")) {
                        pos = 2;
                    } else {
                        pos = 0;
                    }
                    roll[pos] = cube_no;
                }

                try game.rolls.append(roll);
                i += 1;
            }

            try games.append(game);
        }

        const bagRGB = self.getRGB();
        var total: u32 = 0;
        games: for (games.items) |game| {
            for (game.rolls.items) |roll| {
                const validGame = @reduce(.And, roll <= bagRGB);
                if (!validGame) continue :games;
            }
            total += game.index;
        }

        return total;
    }
};

const Game = struct {
    index: u8,
    rolls: ArrayList(RGB),

    pub fn init(allocator: Allocator, index: u8) Game {
        return Game{ .index = index, .rolls = ArrayList(RGB).init(allocator) };
    }
};

const RGB = @Vector(3, u8);

pub fn main() !void {
    var file = try std.fs.cwd().openFile("../input.txt", .{});
    defer file.close();

    const bag = Bag{ .red = 12, .green = 13, .blue = 14 };
    const total = bag.run(File, &file);

    print("Total: {!d}\n", .{total});
}
