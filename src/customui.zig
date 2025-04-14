const std = @import("std");
// const testing = std.testing;

// pub export fn add(a: i32, b: i32) i32 {
//     return a + b;
// }

// test "basic add functionality" {
//     try testing.expect(add(3, 7) == 10);
// }


fn getFolder(allocator: std.mem.Allocator, folder_name: []const []const u8) ![]const u8 {
    const user_profile_folder = try std.process.getEnvVarOwned(allocator, "USERPROFILE");
    defer allocator.free(user_profile_folder);
    const absolute_folder_path = try std.fs.path.join(allocator, .{user_profile_folder, folder_name});
    return absolute_folder_path;
}

pub fn checkConfigExists(allocator: std.mem.Allocator) !bool {
    const downloads_folder = try getFolder(allocator, &.{"Downloads"} );
    defer allocator.free(downloads_folder);
    //std.debug.print("{s}", .{downloads_folder});
    std.log.err("This is an err message - {s}", .{downloads_folder});
    return true;
}