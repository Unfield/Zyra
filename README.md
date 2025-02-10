# Zyra: A High-Performance HTTP Library in Zig

## Overview

Zyra is a high-performance HTTP/1.1 library written in Zig. It's designed to be:

*   **Fast:** Optimized for speed and efficiency.
*   **Robust:** Handles malformed requests and errors gracefully.
*   **Flexible:** Provides a foundation for building various network applications, including reverse proxies.
*   **Standards-Compliant:** Adheres to the HTTP/1.1 specifications.

## Goals

*   Implement a fully compliant HTTP/1.1 parser and generator.
*   Provide a foundation for building high-performance network applications.
*   Offer a clean and easy-to-use API.
*   Contribute to the growing Zig ecosystem.

## Current Status

[Describe the current state of the project. What features are implemented? What's working? What's still in progress?]

## Design Principles

*   **Minimize Memory Allocations:** Avoid unnecessary memory allocations and copies.
*   **Direct Parsing:** Use a single-pass parsing approach with explicit index manipulation.
*   **Explicit Error Handling:** Handle errors gracefully and provide informative error messages.
*   **Clear Ownership:** Maintain clear ownership of memory to prevent leaks and double-free errors.

## Naming Conventions

Zyra follows the standard Zig naming conventions:

*   **`snake_case`:**
    *   Variables (local, parameters, struct fields): `user_name`, `http_request`
    *   Functions: `parse_http_request`, `get_user_id`
    *   Files: `http_parser.zig`, `user_model.zig`
*   **`CamelCase`:**
    *   Types (structs, unions, enums): `HttpRequest`, `UserAccount`
    *   Enum variants: `HttpStatusCode.Ok`, `ParserError.InvalidRequest`
    *   Constants: `MaxConnections`, `DefaultTimeout`

## Key Components

*   **HTTP Parser:** Parses HTTP requests and responses.
*   **Request/Response Objects:** Represents HTTP requests and responses in a structured way.
*   **Connection Manager:** Manages TCP connections to clients and servers.
*   **I/O Abstraction:** Provides an abstraction over the underlying I/O operations.

## Data Structures

*   **HttpRequest:**

    ```zig
    const HttpRequest = struct {
        method: []const u8,
        uri: []const u8,
        version: []const u8,
        headers: std.ArrayList(Header), // Dynamic array for headers
        body: []const u8,
        allocator: std.mem.Allocator,

        pub fn deinit(self: *HttpRequest) void {
            self.headers.deinit(); // Deinitialize the ArrayList
        }
    };
    ```

*   **Header:**

    ```zig
    const Header = struct {
        name: []const u8,
        value: []const u8,
    };
    ```

## Contributing

[Explain how others can contribute to your project. Include information on coding style, testing, and submitting pull requests.]

## License

Zyra is licensed under the MIT License. See the `LICENSE` file for more information.

## Contact

[Your name/handle]

[Your email/website/social media]
