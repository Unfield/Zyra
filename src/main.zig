const std = @import("std");
const parse_http_request = @import("parser.zig").parse_http_request;
const zyra_request = @import("request.zig");
const log = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check != .ok) {
            std.debug.print("Error: {any}\n", .{check});
        }
    }
    const allocator = gpa.allocator();

    const raw_request = "POST /api/users HTTP/1.1\r\nHost: www.example.com\r\nCookie: sessionid=1234567890; othercookie=abcdefgh\r\n\r\n";
    var request = try parse_http_request(raw_request, .{ .allocator = allocator });
    defer request.deinit();

    std.debug.print("Request Method: {s}\n", .{request.method});
    std.debug.print("Request URI: {s}\n", .{request.uri});
    std.debug.print("Request HTTP Version: {s}\n", .{request.version});
    std.debug.print("Request Headers: {d}\n", .{request.headers.items.len});
    for (request.headers.items) |item| {
        std.debug.print("Header name: {s} value: {s}\n", .{ item.name, item.value });
    }

    std.debug.print("Request Cookies: {d}\n", .{request.cookies.items.len});
    for (request.cookies.items) |cookie| {
        std.debug.print("Cookies name: {s} value: {s}\n", .{ cookie.name, cookie.value });
    }
}
