const std = @import("std");
const main = @import("main");
const User = main.server.User;

pub const description = "Manage and teleport to your saved home location.";
pub const usage =
\\/home
\\/home add <name>
\\/home remove
;

const Args = union(enum) {
    @"/home": struct {
        raw_args: ?[]const u8 = null,
    },
};
const ArgParser = main.argparse.Parser(Args, .{.commandName = "/home"});

pub fn execute(args: []const u8, source: *User) void {
    const clean_args = std.mem.trim(u8, args, &std.ascii.whitespace);

    if (clean_args.len == 0) {
        const home_pos = source.player().home_pos orelse {
            source.sendMessage("#ff0000You do not have a home set. Use /home add <name> first.", .{});
            return;
        };

        source.player().back_pos = source.player().pos;
        source.player().pos = home_pos;
        main.network.protocols.genericUpdate.sendTPCoordinates(source.conn, home_pos);
        source.sendMessage("#00ff00Teleporting home...", .{});
        return;
    }

    var token_iter = std.mem.tokenizeScalar(u8, clean_args, ' ');
    const subcommand = token_iter.next() orelse return;

    if (std.mem.eql(u8, subcommand, "add")) {
        const name = token_iter.next() orelse {
            source.sendMessage("#ff0000Usage: /home add <name>", .{});
            return;
        };

        source.player().home_pos = source.player().pos;
        source.sendMessage("#00ff00Home saved as '{s}'! (Limit: 1 home). You will respawn here upon death.", .{name});
    } else if (std.mem.eql(u8, subcommand, "remove")) {
        if (source.player().home_pos == null) {
            source.sendMessage("#ff0000You do not have a home set.", .{});
            return;
        }
        source.player().home_pos = null;
        source.sendMessage("#00ff00Your home has been successfully removed.", .{});
    } else {
        source.sendMessage("#ff0000Unknown syntax. Valid uses:\n{s}", .{usage});
    }
}
