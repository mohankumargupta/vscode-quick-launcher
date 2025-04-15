const std = @import("std");
const raylib = @import("raylib");
const clay = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const lib = @import("customui");

const light_grey: clay.Color = .{ 224, 215, 210, 255 };
const COLOR_RED: clay.Color = .{ 168, 66, 28, 255 };
const COLOR_BEACH = raylib.Color.init(241, 239, 223, 255);
const COLOR_WHITE: clay.Color = .{ 255, 255, 255, 255 };
const COLOR_BLACK: clay.Color = .{ 0, 0, 0, 255 };

// const stdout_file = std.io.getStdOut().writer();
// var bw = std.io.bufferedWriter(stdout_file);
// const stdout = bw.writer();
// try stdout.print("Run `zig build test` to run the tests.\n", .{});
// try bw.flush(); // Don't forget to flush!

pub fn main() !void {
    //std.debug.print("hello {s}", .{"world"});
    //const allocator = std.heap.page_allocator;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // init clay
    const min_memory_size: u32 = clay.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);

    const config_exists = try lib.checkConfigExists(allocator);
    if (!config_exists) {
        std.log.err("App config does not exist.", .{});
    } else {
        std.log.err("App config found.", .{});
    }

    var vscode_folders = std.ArrayList(u8).init(allocator);
    defer vscode_folders.deinit();
    try lib.findVSCodePortableFolderNames(allocator, &vscode_folders);

    const arena: clay.Arena = clay.createArenaWithCapacityAndMemory(memory);
    _ = clay.initialize(
        arena,
        .{ .h = 1000, .w = 1000 },
        .{},
    );
    clay.setMeasureTextFunction(void, {}, renderer.measureText);

    // init raylib
    raylib.setConfigFlags(.{
        .msaa_4x_hint = true,
        .window_resizable = true,
    });
    raylib.initWindow(1024, 768, "VSCode Portable Quick Launcher");
    raylib.setWindowMinSize(300, 100);
    raylib.setTargetFPS(10);

    // load assets
    try loadFont(@embedFile("./resources/Roboto-Regular.ttf"), 0, 24);

    var debug_mode_enabled = false;

    while (!raylib.windowShouldClose()) {
        if (raylib.isKeyPressed(.d)) {
            debug_mode_enabled = !debug_mode_enabled;
            clay.setDebugModeEnabled(debug_mode_enabled);
        }

        clay.setLayoutDimensions(.{
            .w = @floatFromInt(raylib.getScreenWidth()),
            .h = @floatFromInt(raylib.getScreenHeight()),
        });
        var render_commands = createLayout();

        raylib.beginDrawing();
        raylib.clearBackground(COLOR_BEACH);
        try renderer.clayRaylibRender(&render_commands, allocator);
        raylib.endDrawing();
    }
}

fn loadFont(file_data: ?[]const u8, font_id: u16, font_size: i32) !void {
    renderer.raylib_fonts[font_id] = try raylib.loadFontFromMemory(
        ".ttf",
        file_data,
        font_size * 2,
        null,
    );
    raylib.setTextureFilter(
        renderer.raylib_fonts[font_id].?.texture,
        .bilinear,
    );
}

fn createLayout() clay.ClayArray(clay.RenderCommand) {
    clay.beginLayout();
    clay.UI()(.{
        .id = .ID("Container"),
        .layout = .{
            .direction = .top_to_bottom,
            .sizing = .{ .h = .grow, .w = .grow },
            .padding = .{ .left = 32, .right = 32, .top = 48 },
            .child_alignment = .{ .x = .left, .y = .top },
            .child_gap = 16,
        },
    })({
        clay.UI()(.{
            .id = .ID("QuickLaunch"),
            .layout = .{
                .direction = .top_to_bottom,
                .sizing = .{ .h = .fixed(500), .w = .grow },
                //.child_alignment = .{.x = .left, .y = .top},
                //.padding = { .left = 20, .right = 20, .top = 50, .bottom = 0},
            },
            .border = .{ .width = .all(2), .color = COLOR_BLACK },
            .background_color = COLOR_WHITE,
        })({
            clay.text("Clay - UI Library", .{
                .font_size = 24,
                .color = COLOR_RED,
            });
        });

        // clay.text("Clay - UI Library", .{
        //     .font_size = 24,
        //     .color = COLOR_RED,
        // });
        // button(0, "Button1");
    });
    return clay.endLayout();
}

fn button(index: u32, text: []const u8) void {
    clay.UI()(.{ .id = .IDI("Button", index), .corner_radius = .all(32), .layout = .{
        .sizing = .{ .w = .growMinMax(.{ .max = 500 }) },
        .direction = .top_to_bottom,
        .child_alignment = .{ .x = .center },
        .padding = .all(32),
        .child_gap = 32,
    }, .border = .{
        .width = .outside(4),
        .color = COLOR_RED,
    } })({
        clay.text(text, .{
            .font_size = 16,
            .color = COLOR_RED,
        });
    });
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }

// test "use other module" {
//     try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
// }

// test "fuzz example" {
//     const Context = struct {
//         fn testOne(context: @This(), input: []const u8) anyerror!void {
//             _ = context;
//             // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//             try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
//         }
//     };
//     try std.testing.fuzz(Context{}, Context.testOne, .{});
// }
