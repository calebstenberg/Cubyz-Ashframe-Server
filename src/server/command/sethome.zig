const std = @import("std");
const main = @import("main");
const User = main.server.User;

pub const description = "Set your current location as your home.";
pub const usage = "\\/sethome";

const Args = union(enum) { @"/sethome": struct {} };
const ArgParser = main.argparse.Parser(Args, .{.commandName = "/sethome"});

pub fn execute(args: []const u8, source: *User) void {
    var errorMessage: main.List(u8) = .empty;
    defer errorMessage.deinit(main.stackAllocator);

    _ = ArgParser.parse(main.stackAllocator, args, &errorMessage) catch {
        source.sendMessage("#ff0000{s}", .{errorMessage.items});
        return;
    };

    source.player().home_pos = source.player().pos;
    source.sendMessage("#00ff00Home location saved! You will now respawn here upon death.", .{});
}
