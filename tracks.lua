local track_pieces = {}

local track_type_names = {
	"racingphysics:tilt1",
	"racingphysics:flat1",
	"racingphysics:tilt2",
	"racingphysics:qpipe1",
	"racingphysics:qpipecorner",
	"racingphysics:qpipe1sideways",
	--"racingphysics:straightdip1",
}

minetest.register_node("racingphysics:tilt1", {
	description = "testtilt",
	drawtype = "mesh",
	mesh = "tilt1.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})
minetest.register_node("racingphysics:tilt2", {
	description = "testtilt2",
	drawtype = "mesh",
	mesh = "tilt2.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})
minetest.register_node("racingphysics:flat1", {
	description = "testflat",
	drawtype = "mesh",
	mesh = "flat1.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})
minetest.register_node("racingphysics:qpipe1", {
	description = "qpipe1",
	drawtype = "mesh",
	mesh = "quarterpipe2.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})
minetest.register_node("racingphysics:qpipecorner", {
	description = "qpipe1corner",
	drawtype = "mesh",
	mesh = "cornerquarter1.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})
minetest.register_node("racingphysics:qpipe1sideways", {
	description = "qpipe1sideways",
	drawtype = "mesh",
	mesh = "quarterpipe2sideways.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})
minetest.register_node("racingphysics:straightdip1", {
	description = "straightdip1",
	drawtype = "mesh",
	mesh = "straightdip1.obj",
	tiles = { "default_coal_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_coal_block.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -5, -0.5, -5, 5, 1.5, 5 },
	},
})

local track_types = {
	["racingphysics:tilt1"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 4.5 / 2, 0), vector.new(1, 2, 0):normalize() },
		},
	},
	["racingphysics:flat1"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 1.5, 0), vector.new(0, 1, 0) },
		},
	},
	["racingphysics:tilt2"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 0.5, 0), vector.new(1, 5, 0):normalize() },
		},
	},
	["racingphysics:qpipe1"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			--{vector.new(0,-0.5,-5),vector.new(0,0,-1)},
			{
				type = "function",
				func = function(offset, param2)
					local center =
						vector.new(0, 5.5, -5.5):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local xdir = vector.new(0, 0, 1):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local ydir = vector.new(0, 1, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local radius = 11
					local mult = -1
					local pos = offset - xdir:cross(ydir) * xdir:cross(ydir):dot(offset)
					return {
						(pos:distance(center) - radius) * mult,
						(-pos:direction(center)) * mult,
					}
				end,
			},
		},
	},
	["racingphysics:qpipe1sideways"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			--{vector.new(0,-0.5,-5),vector.new(0,0,-1)},
			{
				type = "function",
				func = function(offset, param2)
					local center =
						vector.new(-5.5, 0, -5.5):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local radius = 11
					local mult = -1
					local pos = offset - vector.new(0, offset.y, 0) --xdir:cross(ydir)*xdir:cross(ydir):dot(offset)
					return {
						(pos:distance(center) - radius) * mult,
						(-pos:direction(center)) * mult,
					}
				end,
			},
		},
	},
	["racingphysics:qpipecorner"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			--{vector.new(0,-0.5,-5),vector.new(0,0,-1)},
			{
				type = "function",
				func = function(offset, param2)
					local center =
						vector.new(0, 4.5, 5):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local radius = 10
					local mult = -1
					local pos = offset
					return {
						(pos:distance(center) - radius) * mult,
						(-pos:direction(center)) * mult,
					}
				end,
			},
		},
	},
	["racingphysics:straightdip1"] = {
		shape = {
			--{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			--{vector.new(0,-0.5,-5),vector.new(0,0,-1)},
			{
				type = "function",
				func = function(offset, param2)
					local center =
						vector.new(0, 5, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local xdir = vector.new(0, 0, 1):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local ydir = vector.new(0, 1, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local radius = 11
					local mult = -1
					local pos = offset - xdir:cross(ydir) * xdir:cross(ydir):dot(offset)
					return {
						(pos:distance(center) - radius) * mult,
						(-pos:direction(center)) * mult,
					}
				end,
			},
		},
	},
}

--return track_pieces
