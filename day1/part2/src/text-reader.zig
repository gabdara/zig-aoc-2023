const std = @import("std");

/// Read text line by line from different sources.
/// eg. multi-line string, file, etc.
pub const TextReader = struct {
    /// Returns a iterator that can be used to read line by line.
    pub fn read(reader: anytype) TextBufferedReader(@TypeOf(reader)) {
        const TBR = TextBufferedReader(@TypeOf(reader));
        var tbr = TBR{ .reader = reader, .line_reader = undefined };
        return tbr.init();
    }

    fn TextBufferedReader(comptime T: type) type {
        return struct {
            reader: T,
            buf: [1024]u8 = undefined,
            line_reader: LineReader,

            const Self = @This();

            const BufferedReader = std.io.BufferedReader(4096, T);
            const LineReader = BufferedReader.Reader;

            pub fn init(self: *Self) Self {
                var buf_reader = std.io.bufferedReader(self.reader);
                var line_reader = buf_reader.reader();
                self.line_reader = line_reader;
                return self.*;
            }

            pub fn next(self: *Self) !?[]u8 {
                return self.line_reader.readUntilDelimiterOrEof(&self.buf, '\n');
            }
        };
    }
};
