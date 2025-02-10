const std = @import("std");

pub fn trim_leading_whitespace(str: []const u8) []const u8 {
    var i: usize = 0;
    while (i < str.len and std.ascii.isWhitespace(str[i])) : (i += 1) {}
    return str[i..str.len];
}

pub fn trim_trailing_whitespace(str: []const u8) []const u8 {
    var i: usize = str.len;
    while (i > 0 and std.ascii.isWhitespace(str[i - 1])) : (i -= 1) {}
    return str[0..i];
}

pub fn trim_whitespace(str: []const u8) []const u8 {
    return trim_trailing_whitespace(trim_leading_whitespace(str));
}

pub inline fn check_for_http_version(version: []const u8) bool {
    if (std.mem.eql(u8, version, "HTTP/1.1")) return true;
    return false;
}

pub fn eq_ignore_case(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    var idx: usize = 0;
    for (a) |ch| {
        if (std.ascii.toLower(ch) != std.ascii.toLower(b[idx])) {
            return false;
        }
        idx += 1;
    }
    return true;
}
