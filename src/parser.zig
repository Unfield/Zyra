const std = @import("std");
const req = @import("request.zig");
const utils = @import("utils.zig");

const ParserError = error{
    HttpVersionNotSupported,
    InvalidRequest,
    RequestTooLarge,
    FailedToInitializeRequest,
    InternalError,
    FailedToParseCookies,
};

const Options = struct {
    allocator: std.mem.Allocator,
};

/// Parses a raw HTTP/1.1 request into an `HttpRequest` object.
///
/// Allocates memory using `options.allocator`. The caller is responsible
/// for freeing the returned `HttpRequest` using `deinit()` on the returned `HttpRequest`.
///
/// Errors:
///   - `InvalidRequest`: The request is malformed or invalid.
///   - `InternalError`: An internal error occurred (e.g., memory allocation failure).
pub fn parse_http_request(raw_request: []const u8, options: Options) ParserError!req.HttpRequest {
    var request = req.HttpRequest.init(options.allocator);

    var i: usize = 0;
    const len = raw_request.len;

    const method_end = find_next(raw_request, i, ' ') orelse return error.InvalidRequest;
    request.method = raw_request[i..method_end];
    i = method_end + 1;

    const uri_end = find_next(raw_request, i, ' ') orelse return error.InvalidRequest;
    request.uri = raw_request[i..uri_end];
    i = uri_end + 1;

    const version_end = find_next(raw_request, i, '\r') orelse return error.InvalidRequest;
    request.version = raw_request[i..version_end];
    i = version_end + 2;

    if (!utils.check_for_http_version(request.version)) return error.HttpVersionNotSupported;

    var header_count: usize = 0;
    while (true) {
        const name_end = find_next(raw_request, i, ':') orelse {
            if (i + 1 < len and raw_request[i] == '\r' and raw_request[i + 1] == '\n') {
                i += 2;
                break;
            } else {
                return error.InvalidRequest;
            }
        };

        const name = raw_request[i..name_end];
        i = name_end + 1;

        while (i < len and raw_request[i] == ' ') {
            i += 1;
        }

        const value_end = find_next(raw_request, i, '\r') orelse {
            return error.InvalidRequest;
        };
        const value = raw_request[i..value_end];
        i = value_end + 2;

        request.headers.append(req.Header{ .name = name, .value = value }) catch return error.InternalError;
        header_count += 1;

        if (header_name_equals_ignore_case(name, "cookie")) {
            var cookie_start: usize = 0;

            while (cookie_start < value.len) {
                const cookie_end = find_next(value, cookie_start, ';') orelse value.len;
                const cookie = value[cookie_start..cookie_end];
                const equals_index = find_next(cookie, 0, '=') orelse cookie.len;
                const cookie_name = utils.trim_whitespace(cookie[0..equals_index]);
                const cookie_value = utils.trim_whitespace(if (equals_index < cookie.len) cookie[equals_index + 1 .. cookie.len] else "");
                request.cookies.append(req.Cookie{ .name = cookie_name, .value = cookie_value }) catch return error.FailedToParseCookies;
                cookie_start = cookie_end + 1;
                if (cookie_start >= value.len) break;
            }
        }
    }

    return request;
}

/// Compares two header names for equality, ignoring case.
///
/// The `expected_name` parameter MUST be lowercase.
inline fn header_name_equals_ignore_case(header_name: []const u8, expected_name: []const u8) bool {
    if (header_name.len != expected_name.len) return false;
    for (header_name, expected_name) |h_char, e_char| {
        if (std.ascii.toLower(h_char) != e_char) return false;
    }
    return true;
}

inline fn find_next(str: []const u8, start: usize, char: u8) ?usize {
    for (str[start..], 0..) |c, j| {
        if (c == char) {
            return start + j;
        }
    }
    return null;
}
