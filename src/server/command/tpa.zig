const std = @import("std");
const main = @import("main");
const User = main.server.User;

pub const description = "Request to teleport to another player.";
pub const usage = "\\/tpa <player>";

const Args = union(enum) { @"/tpa <target>": struct { target: []const u8 } };
const ArgParser = main.argparse.Parser(Args, .{ .commandName = "/tpa" });

pub fn execute(args: []const u8, source: *User) void {
    var errorMessage: main.List(u8) = .empty;
    defer errorMessage.deinit(main.stackAllocator);

    const result = ArgParser.parse(main.stackAllocator, args, &errorMessage) catch {
        source.sendMessage("#ff0000{s}", .{errorMessage.items});
        return;
    };

    const target_str = switch (result) {
        .@"/tpa <target>" => |p| p.target,
    };

    var target_user: ?*User = null;

    // Resolve target by @ index if specifier is present, otherwise fallback to name match
    if (std.ascii.startsWithIgnoreCase(target_str, "@")) {
        const cleanIndexStr = std.mem.trim(u8, target_str[1..], &std.ascii.whitespace);
        if (std.fmt.parseInt(usize, cleanIndexStr, 10)) |index| {
            target_user = main.server.getUserByIndexAndIncreaseRefCount(index);
        } else |_| {}
    } else {
        const online_users = main.server.getUserListAndIncreaseRefCount(main.stackAllocator);
        defer main.server.freeUserListAndDecreaseRefCount(main.stackAllocator, online_users);
        var partialMatches = 0;
        for (online_users) |u| {
            //Exact Match
            if (std.mem.eql(u8, u.name, target_str)) {
                u.increaseRefCount();
                target_user = u;
                break;
            }
            //Partial Match
            if (std.mem.indexOf(u8, u.name, target_str) != null) {
                partialMatches += 1;
                target_user = u;
            }
        }
        if (partialMatches != 1) {
            target_user = null;
        }
    }

    // Process the resolved target
    if (target_user) |u| {
        defer u.decreaseRefCount();

        if (u.playerIndex == source.playerIndex) {
            source.sendMessage("#ff0000You cannot teleport to yourself!", .{});
            return;
        }

        u.player().tpa_request_from = @intCast(source.playerIndex);
        source.sendMessage("#00ff00Teleport request sent to {s}.", .{u.name});
        u.sendMessage("#ffff00{s} wants to teleport to you. Type #00ff00/tpaccept #ffff00to accept.", .{source.name});
    } else {
        source.sendMessage("#ff0000Player '{s}' not found or offline.", .{target_str});
    }
}
