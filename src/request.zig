const std = @import("std");

pub const HttpRequest = struct {
    method: []const u8,
    uri: []const u8,
    version: []const u8,
    headers: std.ArrayList(Header),
    cookies: std.ArrayList(Cookie),
    body: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) HttpRequest {
        return .{
            .method = "",
            .uri = "",
            .version = "",
            .headers = std.ArrayList(Header).init(allocator),
            .cookies = std.ArrayList(Cookie).init(allocator),
            .body = "",
            .allocator = allocator,
        };
    }

    inline fn header_name_equals_ignore_case(header_name: []const u8, expected_name: []const u8) bool {
        if (header_name.len != expected_name.len) return false;
        for (header_name, expected_name) |h_char, e_char| {
            if (std.ascii.toLower(h_char) != e_char) return false;
        }
        return true;
    }

    pub fn deinit(self: *HttpRequest) void {
        self.headers.deinit();
        self.cookies.deinit();
    }

    pub fn getCookie(self: *HttpRequest, name: []const u8) ?[]const u8 {
        for (self.cookies.items) |cookie| {
            if (std.mem.eql(u8, cookie.name, name)) return cookie.value;
        }
        return null;
    }

    pub fn getHeader(self: *HttpRequest, name: []const u8) ?[]const u8 {
        for (self.headers.items) |header| {
            if (std.mem.eql(u8, header.name, name)) return header.value;
        }
        return null;
    }
};

pub const Header = struct {
    name: []const u8,
    value: []const u8,
};

pub const Cookie = struct {
    name: []const u8,
    value: []const u8,
};
