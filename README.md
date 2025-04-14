# VSCode Portable Quick Launcher

Toy program written in Zig.


### Mimicking user interfaces

https://learn.microsoft.com/en-us/windows/win32/controls/images/lv-iconview.png

const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

// Helper function to join the user profile directory with subsequent path components.
// Takes ownership of the returned path string, caller must free it.
fn getFolder(allocator: Allocator, folder_parts: []const []const u8) ![]const u8 {
    // 1. Get the base user profile folder
    const user_profile_folder = try std.process.getEnvVarOwned(allocator, "USERPROFILE");
    // Ensure user_profile_folder is freed even if subsequent operations fail
    defer allocator.free(user_profile_folder);

    // 2. Build the complete list of path components for joining
    //    We need an ArrayList because we're combining a single string
    //    with a slice of strings dynamically.
    var all_parts = ArrayList([]const u8).init(allocator);
    // Ensure the ArrayList's internal buffer is freed
    defer all_parts.deinit();

    // Add the base profile folder first
    try all_parts.append(user_profile_folder);
    // Add the subsequent folder parts
    try all_parts.appendSlice(folder_parts);

    // 3. Join all parts into a single path string
    //    std.fs.path.join allocates a new string for the result.
    const absolute_folder_path = try std.fs.path.join(allocator, all_parts.items);

    // We successfully created absolute_folder_path.
    // Since user_profile_folder was appended to all_parts, its memory is now
    // logically "part" of the components used to build absolute_folder_path.
    // The 'defer allocator.free(user_profile_folder)' above handles freeing the
    // original allocation from getEnvVarOwned.
    // The 'defer all_parts.deinit()' handles freeing the ArrayList's buffer.
    // The caller of getFolder is now responsible for freeing absolute_folder_path.
    return absolute_folder_path;
}

pub fn checkConfigExists(allocator: Allocator) !bool {
    // Pass the relative path parts as a slice literal
    const downloads_folder = try getFolder(allocator, &.{"Downloads"});
    // The caller (this function) is responsible for freeing the path returned by getFolder
    defer allocator.free(downloads_folder);

    // Use std.log for structured logging (info level seems appropriate here)
    std.log.info("Checking path: {s}", .{downloads_folder});

    // TODO: Add actual logic to check if a config file exists in downloads_folder
    // Example:
    // const config_path = try std.fs.path.join(allocator, .{downloads_folder, "my_config.json"});
    // defer allocator.free(config_path);
    // return std.fs.path.exists(config_path);

    // For now, just return true as in the original code
    return true;
}

// Example usage (requires an allocator, e.g., in a main function or test)
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const exists = try checkConfigExists(allocator);
    std.debug.print("Config check returned: {}\n", .{exists});

    // Example with multiple path parts
    const docs_proj_folder = try getFolder(allocator, &.{"Documents", "MyProject"});
    defer allocator.free(docs_proj_folder);
    std.debug.print("Multi-part path: {s}\n", .{docs_proj_folder});
}

// Optional: Add a test
test "getFolder basic functionality" {
    // Mocking environment variables in tests can be tricky.
    // This test assumes USERPROFILE is set in the test environment.
    // For more robust tests, consider dependency injection for getEnvVarOwned.
    const allocator = std.testing.allocator;
    const downloads = try getFolder(allocator, &.{"Downloads"});
    defer allocator.free(downloads);

    // We can't know the exact USERPROFILE path, but we can check if "Downloads" is at the end.
    try std.testing.expect(std.mem.endsWith(u8, downloads, std.fs.path.sep_str ++ "Downloads"));

    const multi_part = try getFolder(allocator, &.{"Documents", "Test"});
    defer allocator.free(multi_part);
    try std.testing.expect(std.mem.endsWith(u8, multi_part, std.fs.path.sep_str ++ "Documents" ++ std.fs.path.sep_str ++ "Test"));
}

test "checkConfigExists basic run" {
     const allocator = std.testing.allocator;
     // This test just ensures the function runs without crashing.
     // A real test would mock file system access or set up test files.
     _ = try checkConfigExists(allocator);
}