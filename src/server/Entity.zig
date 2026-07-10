const std = @import("std");

const main = @import("main");
const ZonElement = main.ZonElement;
const vec = main.vec;
const Vec3f = vec.Vec3f;
const Vec3d = vec.Vec3d;
const NeverFailingAllocator = main.heap.NeverFailingAllocator;

pos: Vec3d = .{0, 0, 0},
vel: Vec3d = .{0, 0, 0},
rot: Vec3f = .{0, 0, 0},

prefix: ?[]const u8 = null, // ADDED: Stores the player's custom prefix
tpa_request_from: ?usize = null,
still_time: f32 = 0.0,
is_afk: bool = false,
home_pos: ?Vec3d = null,
back_pos: ?Vec3d = null,
playtime: u64 = 0,
login_time: i64 = 0,
health: f32 = 8,
maxHealth: f32 = 8,
energy: f32 = 8,
maxEnergy: f32 = 8,
name: ?[]const u8 = null,
id: main.entity.Entity = .noValue,

pub fn loadFrom(self: *@This(), id: main.entity.Entity, zon: ZonElement, comptime side: main.sync.Side) !void {
	self.id = id;
	self.pos = zon.get(Vec3d, "position") orelse .{0, 0, 0};
	self.vel = zon.get(Vec3d, "velocity") orelse .{0, 0, 0};
	self.rot = zon.get(Vec3f, "rotation") orelse .{0, 0, 0};
	self.health = zon.get(f32, "health") orelse self.maxHealth;
	self.energy = zon.get(f32, "energy") orelse self.maxEnergy;

	self.playtime = zon.get(u64, "playtime") orelse 0;
	self.login_time = @intCast(@divTrunc(main.timestamp().toNanoseconds(), 1000000000));

	if (zon.getChildOrNull("components")) |components| {
		try main.entity.loadComponentsFromBase64(components.as([]const u8) orelse "", self.id, side);
	}

	if (zon.getChildOrNull("name")) |name| {
		if (self.name) |oldname| {
			main.globalAllocator.free(oldname);
		}
		self.name = main.globalAllocator.dupe(u8, name.as([]const u8) orelse "invalid name");
	}

	self.home_pos = zon.get(Vec3d, "home_pos");
	self.back_pos = zon.get(Vec3d, "back_pos");

	if (zon.getChildOrNull("prefix")) |prefix_node| {
		if (self.prefix) |old| main.globalAllocator.free(old);
		self.prefix = main.globalAllocator.dupe(u8, prefix_node.as([]const u8) orelse "");
	}
}

pub fn clone(self: *@This(), copy: *@This()) void {
	const originalID = copy.id;
	std.debug.assert(copy.name == null);
	copy.* = self.*;
	copy.name = if (self.name) |name| main.globalAllocator.dupe(u8, name) else null;
	copy.id = originalID;
}

pub fn save(self: *const @This(), allocator: NeverFailingAllocator, audience: main.entity.AudienceInfo) ZonElement {
	const zon = ZonElement.initObject(allocator);
	zon.put("position", self.pos);
	zon.put("velocity", self.vel);
	zon.put("rotation", self.rot);
	zon.put("health", self.health);
	zon.put("energy", self.energy);
	zon.put("id", @intFromEnum(self.id));

	const current_time = @as(i64, @intCast(@divTrunc(main.timestamp().toNanoseconds(), 1000000000)));
	const session_seconds = if (current_time > self.login_time) current_time - self.login_time else 0;
	zon.put("playtime", self.playtime + @as(u64, @intCast(session_seconds)));

	var base64 = main.entity.server.componentsToBase64(allocator, self.id, audience);
	defer base64.deinit(allocator);
	zon.putOwnedString("components", base64.getEncodedMessage());

	if (self.home_pos) |hp| {
		zon.put("home_pos", hp);
	}
	if (self.back_pos) |bp| {
		zon.put("back_pos", bp);
	}
	if (self.prefix) |p| {
		zon.put("prefix", p);
	}
	if (self.name) |name| {
		zon.put("name", name);
	}
	return zon;
}

pub fn deinit(self: *@This(), comptime side: main.sync.Side) void {
	if (self.prefix) |p| {
		main.globalAllocator.free(p);
		self.prefix = null;
	}
	if (self.name) |name| {
		main.globalAllocator.free(name);
		self.name = null;
	}
	if (side == .server) {
		main.entity.server.removeAllComponents(self.id);
	} else {
		main.entity.client.removeAllComponents(self.id);
	}
}
