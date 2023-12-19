const std = @import("std");
const Allocator = std.mem.Allocator;
const AutoArrayHashMap = std.AutoArrayHashMap;

/// Returns the intersection of two sets of numbers.
/// @memory_owner caller
pub fn intersection(comptime T: type, allocator: Allocator, a: AutoArrayHashMap(T, void), b: AutoArrayHashMap(T, void)) ![]T {
    const buf = try allocator.alloc(T, @min(a.capacity(), b.capacity()));

    var i: usize = 0;
    const a_keys = a.keys();
    for (a_keys) |a_key| {
        if (b.contains(a_key)) {
            buf[i] = a_key;
            i += 1;
        }
    }

    return allocator.realloc(buf, i);
}

test "intersection" {
    const allocator = std.testing.allocator;

    var a = AutoArrayHashMap(u8, void).init(allocator);
    defer a.deinit();
    var b = AutoArrayHashMap(u8, void).init(allocator);
    defer b.deinit();

    try a.put(1, {});
    try a.put(2, {});
    try a.put(3, {});
    try a.put(4, {});
    try a.put(5, {});

    try b.put(3, {});
    try b.put(4, {});
    try b.put(5, {});
    try b.put(6, {});
    try b.put(7, {});

    const result = try intersection(u8, allocator, a, b);
    defer allocator.free(result);

    try std.testing.expect(std.mem.eql(u8, result, &[_]u8{ 3, 4, 5 }));
}
