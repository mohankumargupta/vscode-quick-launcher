const std = @import("std");

const CONFIG_FOLDER = ".vscode-quick-launcher";
const CONFIG_NAME = "vscode-portable-quick-launcher.zon";

// const testing = std.testing;

// pub export fn add(a: i32, b: i32) i32 {
//     return a + b;
// }

// test "basic add functionality" {
//     try testing.expect(add(3, 7) == 10);
// }

fn getFolder(allocator: std.mem.Allocator, folder_components: []const []const u8) ![]const u8 {
    const user_profile_folder = try std.process.getEnvVarOwned(allocator, "USERPROFILE");
    defer allocator.free(user_profile_folder);
    var components = std.ArrayList([]const u8).init(allocator);
    defer components.deinit();
    try components.append(user_profile_folder);
    try components.appendSlice(folder_components);
    const absolute_folder_path = try std.fs.path.join(allocator, components.items);
    return absolute_folder_path;
}

pub fn checkConfigExists(allocator: std.mem.Allocator) !bool {
    const config_path = try getFolder(allocator, &.{ CONFIG_FOLDER, CONFIG_NAME });
    defer allocator.free(config_path);
    //std.debug.print("{s}", .{downloads_folder});
    //std.log.err("This is an err message - {s}", .{config_path});
    // use std.fs.cwd().openFile for files relative to the current directory
    const file = std.fs.openFileAbsolute(config_path, .{}) catch return false;
    file.close();
    return true;
}
