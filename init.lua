local modname = minetest.get_modpath("racingphysics")
local track_pieces = {}--dofile(modname .. "/tracks.lua")local track_pieces = {}

local track_type_names = {
	"racingphysics:tilt1",
	"racingphysics:flat1",
	"racingphysics:flatboost1",
	"racingphysics:tilt2",
	"racingphysics:qpipe1",
	"racingphysics:qpipecorner",
	"racingphysics:qpipe1sideways",
	"racingphysics:straightdip1",
}

local forward_impulse_force=0.001
local backward_impulse_force=0.001
local turn_force=0.01*20
local gravity = vector.new(0, -0.001, 0)
local iterations = 3
local angular_damp = 0.9
local linear_damp = 1
local linear_friction=0.01*0.1
local sideways_friction=0.5
local skid_limit=0.9
local margin = 1.5
local search_radius = 6
local press_forward=false
local max_turning_angle=0.5

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
minetest.register_node("racingphysics:flatboost1", {
	description = "testflat",
	drawtype = "mesh",
	mesh = "flat1.obj",
	tiles = { "default_gold_block.png" },
	groups = { cracky = 1 },
	paramtype2 = "facedir",
	wield_image = "default_gold_block.png",
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

local dp=1--down padding
local track_types = {
	["racingphysics:tilt1"] = {
		shape = {
			{vector.new(0,-0.5-dp,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 4.5 / 2, 0), vector.new(1, 2, 0):normalize() },
		},
	},
	["racingphysics:flat1"] = {
		shape = {
			{vector.new(0,-0.5,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 1.5, 0), vector.new(0, 1, 0) },
		},
	},
	["racingphysics:straightgutter1"] = {
		shape = {
			{vector.new(0,-0.5-dp,0),vector.new(0,-1,0)},
			{ vector.new(5*0.85, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5*0.85, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5*0.85), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5*0.85), vector.new(0, 0, -1) },
			{
				type = "function",
				func = function(offset, param2)
					local center =
						vector.new(0, 10.5, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local cylnormal = vector.new(1, 0, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local radius = 10
					local mult = -1
					local pos = offset - cylnormal * cylnormal:dot(offset)
					return {
						(pos:distance(center) - radius) * mult,
						(-pos:direction(center)) * mult,
					}
				end,
			},
		},
	},
	["racingphysics:flatboost1"] = {
		boost=vector.new(0,0,10)*forward_impulse_force,
		shape = {
			{vector.new(0,-0.5-dp,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 1.5, 0), vector.new(0, 1, 0) },
		},
	},
	["racingphysics:tilt2"] = {
		shape = {
			{vector.new(0,-0.5-dp,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{ vector.new(0, -0.5, -5), vector.new(0, 0, -1) },
			{ vector.new(0, 0.5, 0), vector.new(1, 5, 0):normalize() },
		},
	},
	["racingphysics:qpipe1"] = {
		shape = {
			--{vector.new(0,-0.5-dp,0),vector.new(0,-1,0)},
			{ vector.new(5.6, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5.6, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5.6), vector.new(0, 0, 1) },
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
			{vector.new(0,-0.5-dp,0),vector.new(0,-1,0)},
			{ vector.new(5, -0.5, 0), vector.new(1, 0, 0) },
			{ vector.new(-5, -0.5, 0), vector.new(-1, 0, 0) },
			{ vector.new(0, -0.5, 5), vector.new(0, 0, 1) },
			{vector.new(0,-0.5,-5),vector.new(0,0,-1)},
			{
				type = "function",
				func = function(offset, param2)
					local center =
						vector.new(0, 10.5, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local cylnormal = vector.new(1, 0, 0):rotate_around_axis(vector.new(0, 1, 0), -param2 / 4 * 2 * math.pi)
					local radius = 10
					local mult = -1
					local pos = offset - cylnormal * cylnormal:dot(offset)
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


local angular_force = function(force, offset)
	return force:normalize():cross(offset:normalize())
end

local transform = function(right, up, forward, v)
	return v.x * right + v.y * up + v.z * forward
end

local get_collision_plane = function(pos, shape, param2)
	local colliding = true
	local maxdist = -100
	local maxidx = 1
	local rotation_amount = -(param2 / 4 * 2 * math.pi - math.pi / 2)
	for i, plane in pairs(shape) do
		local dist

		if plane.type == "function" then
			dist = plane.func(pos, param2)[1]
		else
			dist = (pos - plane[1]:rotate_around_axis(vector.new(0, 1, 0), rotation_amount)):dot(
				plane[2]:rotate_around_axis(vector.new(0, 1, 0), rotation_amount)
			)
		end
		colliding = colliding and (dist < 0)
		if dist > maxdist then
			maxdist = dist
			maxidx = i
		end
	end
	if colliding then
		if shape[maxidx].type == "function" then
			local dist_dir = shape[maxidx].func(pos, param2)
			return { pos - dist_dir[2] * dist_dir[1], dist_dir[2] }
		else
			return {
				shape[maxidx][1]:rotate_around_axis(vector.new(0, 1, 0), rotation_amount),
				shape[maxidx][2]:rotate_around_axis(vector.new(0, 1, 0), rotation_amount),
			}
		end
	end
end

local forced_dtime = 0.05

local dim = vector.new(2, 0.3, 0.8)
local verticies = {
	vector.new(dim.x, dim.y, dim.z),
	vector.new(-dim.x, dim.y, dim.z),
	vector.new(dim.x, -dim.y, dim.z),
	vector.new(dim.x, dim.y, -dim.z),
	vector.new(-dim.x, -dim.y, dim.z),
	vector.new(-dim.x, dim.y, -dim.z),
	vector.new(dim.x, -dim.y, -dim.z),
	vector.new(-dim.x, -dim.y, -dim.z),
	vector.new(0, -dim.y, 0),
	vector.new(0, -dim.y, 0),
	vector.new(dim.x, dim.y/2, dim.z*1.1),
	vector.new(-dim.x, dim.y/2, dim.z*1.1),
}

local points = {}
local connections = {}
local mesh = nil
local wheels={}

local k = 0
for i, vert1 in pairs(verticies) do
	for j, vert2 in pairs(verticies) do
		if i ~= j then
			k = k + 1
			connections[k] = { i, j, vert1:distance(vert2) }
		end
	end
end

local impulse =
	function(dir, point)
		if points and points[1] and points[1]:get_pos() then
			local averagepos = vector.new(0, 0, 0)
			for idx, point in pairs(points) do
				averagepos = averagepos + point:get_pos()
			end
			averagepos = averagepos / #points
			local one = points[1]:get_pos()
			local two = points[2]:get_pos()
			local three = points[3]:get_pos()
			local four = points[4]:get_pos()
			local five = points[5]:get_pos()
			local seven = points[7]:get_pos()
			local averageright = (one + two + three + five) / 4
			local averageforward = (one + three + four + seven) / 4
			local forward1 = (averageforward - averagepos):normalize()
			local right1 = (averageright - averagepos):normalize()
			local up1 = forward1:cross(right1)
			point:get_luaentity()._prev_pos = point:get_luaentity()._prev_pos
				- (forward1 * dir.x + up1 * dir.y + right1 * dir.z)
			if (point:get_pos() - averagepos):dot(averageforward - averagepos) < 0 then
				--point:set_pos(point:get_pos()-gravity*60)
			end
			--point:set_pos(point:get_pos()-gravity*0.3)
		end
	end
local torque = function(normal, point)
	if points and points[1] and points[1]:get_pos() then
		local averagepos = vector.new(0, 0, 0)
		for idx, point in pairs(points) do
			averagepos = averagepos + point:get_pos()
		end
		averagepos = averagepos / #points
		local added_vel = (averagepos - point:get_pos()):cross(normal)
		point:get_luaentity()._prev_pos = point:get_luaentity()._prev_pos + added_vel --/point:get_pos():distance(averagepos)
	end
end

basic_mesh = {
	visual = "mesh",
	mesh = "RandomRaceCarNoWheels.obj",
	visual_size = vector.new(1, 1, 1),
	textures = { "carcolors.png^noise.png" },
	_driver = nil,

	on_rightclick = function(self, clicker)
		if self._driver == clicker then
			self._driver:set_detach()
			player_api.player_attached[clicker:get_player_name()] = false
			self._driver = nil
		elseif self.driver == nil then
			clicker:set_attach(self.object, nil, vector.new(2, -3, 0), vector.new(0, 90, 0))
			--clicker:set_animation({x=81,y=161},15)
			player_api.player_attached[clicker:get_player_name()] = true
			minetest.after(0.5, function()
				player_api.set_animation(clicker, "sit", 15.0)
			end)
			self._driver = clicker
		end
	end,
}
basic_wheel={
	visual="mesh",
	mesh="RandomRaceCarWheel.obj",
	textures = { "tire.png" },
	pointable=false,
}
minetest.register_entity("racingphysics:basic_wheel", basic_wheel)
minetest.register_entity("racingphysics:basic_mesh", basic_mesh)

local freeze_physics=false
rigid_point = {
	_lifetime = 0,

	_mass = 1,

	_prev_pos = nil,

	_static = false,
	_original_pos = nil,

	--physical = true,
	pointable = false,
	visual = "cube",
	visual_size = vector.new(0.0, 0.0, 0.0),
	textures = {
		"default_coal_block.png",
		"default_coal_block.png",
		"default_coal_block.png",
		"default_coal_block.png",
		"default_coal_block.png",
		"default_coal_block.png",
	},

	on_activate = function(self, staticdata, dtime_s)
		self._prev_pos = self.object:get_pos()
		if minetest.deserialize(staticdata) and minetest.deserialize(staticdata).static == true then
			self._static = true
			self._original_pos = self.object:get_pos()
		else
			--self.object:set_acceleration(vector.new(0, -9.8, 0))
		end
	end,

	on_step = function(self, dtime, moveresult)
		--[[
		local tmppos = self.object:get_pos() + (self.object:get_pos() - self._prev_pos)
		if not self._static and not freeze_physics then
			self._prev_pos = self.object:get_pos()
			self.object:set_pos(tmppos + gravity)
		end
		]]
	end,
}

local spawn_car=function(pos)
	for i, vert in ipairs(verticies) do
		points[i] = minetest.add_entity(
			pos + vert,
			"racingphysics:rigid_point",
			minetest.serialize({ static = false })
		)
	end
	mesh = minetest.add_entity(pos, "racingphysics:basic_mesh")
	wheels[1]=minetest.add_entity(pos+vector.new(-1.21,0,0.738), "racingphysics:basic_wheel")
	wheels[2]=minetest.add_entity(pos+vector.new(-1.21,0,-0.738), "racingphysics:basic_wheel")
	wheels[3]=minetest.add_entity(pos+vector.new(1.65,0,0.738), "racingphysics:basic_wheel")
	wheels[4]=minetest.add_entity(pos+vector.new(1.65,0,-0.738), "racingphysics:basic_wheel")
end

minetest.register_chatcommand("test2", {
	description = "test2",
	func = function(name, param)
		spawn_car(minetest.get_player_by_name(name):get_pos())
	end,
})

local sign = function(n)
	if n > 0 then
		return 1
	elseif n < 0 then
		return -1
	else
		return 0
	end
end
local weaksign=function(n,range)
	if n > range then
		return 1
	elseif n < -range then
		return -1
	else
		return n
	end
end

local get_surface_of_cube = function(pos)
	local rounded = pos:round()
	local offset = pos - rounded
	if offset.x > offset.y and offset.x > offset.z then
		offset.x = sign(offset.x) / 2
	elseif offset.y > offset.x and offset.y > offset.z then
		offset.y = sign(offset.y) / 2
	elseif offset.z > offset.y and offset.z > offset.x then
		offset.z = sign(offset.z) / 2
	end
	return rounded + offset
end

local fix = function(data)
	if points and points[data[1]] and points[data[2]] and points[data[1]]:get_pos() and points[data[2]]:get_pos() then
		if points[data[1]]:get_luaentity()._static then
			points[data[2]]:set_pos(
				points[data[1]]:get_pos() + points[data[1]]:get_pos():direction(points[data[2]]:get_pos()) * data[3]
			)
		elseif points[data[2]]:get_luaentity()._static then
			points[data[1]]:set_pos(
				points[data[2]]:get_pos() + points[data[2]]:get_pos():direction(points[data[1]]:get_pos()) * data[3]
			)
		else
			local oldpos1 = points[data[1]]:get_pos()
			local oldpos2 = points[data[2]]:get_pos()
			points[data[2]]:set_pos(
				(points[data[1]]:get_pos() + points[data[2]]:get_pos()) / 2
					+ points[data[1]]:get_pos():direction(points[data[2]]:get_pos()) * data[3] / 2
			)
			points[data[1]]:set_pos((oldpos1 + oldpos2) / 2 + oldpos2:direction(oldpos1) * data[3] / 2)
		end
	end
end

local friction=function(velocity,amount)
	if velocity:length()<amount then
		return velocity*0
	else
		return velocity:normalize()*(velocity:length()-amount)
	end
end

local tmp_turn_amount=0
local dist_taveled=0
minetest.register_globalstep(function(dtime)
	if freeze_physics then
		return
	end

	for _, data in pairs(connections) do
		fix(data)
	end

	local averagevel = vector.new(0, 0, 0)
	local averagepos = vector.new(0, 0, 0)
	for idx, point in pairs(points) do
		if point and point:get_pos() then
			averagevel = averagevel + (point:get_pos() - point:get_luaentity()._prev_pos)
			averagepos = averagepos + point:get_pos()
		end
	end
	averagevel = averagevel / #points
	averagepos = averagepos / #points

	for i = 0, iterations do
		if points[1] == nil then
			break
		end
		local one = points[1]:get_pos()
		if one == nil then
			break
		end
		local two = points[2]:get_pos()
		local three = points[3]:get_pos()
		local four = points[4]:get_pos()
		local five = points[5]:get_pos()
		local six = points[6]:get_pos()
		local seven = points[7]:get_pos()
		local eight = points[8]:get_pos()

		local averageup = (one + two + four + six) / 4
		local averagedown = (three + five + seven + eight) / 4
		local averageright = (one + two + three + five) / 4
		local averageleft = (four + six + seven + eight) / 4
		local averageforward = (one + three + four + seven) / 4
		local averageback = (two + five + six + eight) / 4

		local right1 = ((averageright - averagepos) - (averageleft - averagepos)):normalize()
		local forward1 = ((averageforward - averagepos) - (averageback - averagepos)):normalize()
		local up1=right1:cross(forward1)
		local carcolliding=false
		for _, point in ipairs(points) do
			local tmppos = point:get_pos() + (point:get_pos() - point:get_luaentity()._prev_pos)
			if not point:get_luaentity()._static and not freeze_physics then
				point:get_luaentity()._prev_pos = point:get_pos()
				point:set_pos(tmppos + gravity)
			end
			--Collisions
			local colliding = false
			local pos = point:get_pos()
			local oldvel = pos - point:get_luaentity()._prev_pos
			if pos then
				local nodes, names = minetest.find_nodes_in_area(
					pos - vector.new(search_radius, search_radius, search_radius),
					pos + vector.new(search_radius, search_radius, search_radius),
					track_type_names,
					true
				)

				for nodename, nodeposes in pairs(nodes) do
					for _, trackpos in pairs(nodeposes) do
						local facedir = minetest.get_node(trackpos).param2
						if math.floor(facedir / 4) == 0 then
							local slopeoffset = pos - trackpos
							local plane = get_collision_plane(slopeoffset, track_types[nodename].shape, facedir)
							if plane then
								local planepos = plane[1]
								local dist = (slopeoffset - plane[1]):dot(plane[2])
								--Test
								--point:get_luaentity()._prev_pos = pos
								point:set_pos(pos + plane[2] * -dist)
								colliding = true
								carcolliding = true

								if track_types[nodename].boost then
									local boostdir=track_types[nodename].boost:rotate_around_axis(vector.new(0, 1, 0), -facedir / 4 * 2 * math.pi)
									impulse(boostdir*boostdir:dot(forward1),point)
								end
							end
						end
					end
				end
			end

			if pos and minetest.get_node(pos).name ~= "air" then
				colliding = true
				local rc = minetest.raycast(averagepos, pos)
				local rc2 = minetest.raycast(
					point:get_luaentity()._prev_pos,
					point:get_luaentity()._prev_pos + (pos - point:get_luaentity()._prev_pos) * 3
				)

				for thing in rc2 do
					if thing.type == "node" and false then
						local velocity = point:get_pos() - point:get_luaentity()._prev_pos
						velocity.y = 0
						point:get_luaentity()._prev_pos = point:get_pos() - velocity
					end
				end
				for thing in rc do
					if pos.y < 8.5 then
						--Test
						--point:get_luaentity()._prev_pos = pos
						point:set_pos(pos - vector.new(0, pos.y - 8.5001, 0))
						break
					end

					if thing.type == "node" then
						--Test
						--point:get_luaentity()._prev_pos = pos
						--point:set_pos(thing.intersection_point)
						if track_type_names[minetest.get_node(point:get_pos()).name]==nil then
							local cubepos = get_surface_of_cube(point:get_pos())
							if thing.intersection_point:distance(cubepos) < margin then
								point:set_pos(cubepos)
							else
								point:set_pos(thing.intersection_point)
							end
							break
						end
					elseif thing.type == "object" and thing.ref:get_luaentity() == nil and false then
						--Test
						--point:get_luaentity()._prev_pos = pos
						point:set_pos(thing.intersection_point)
						break
					end
				end
			end
			if pos then
				local turning=false
				local velalignment=oldvel:dot(forward1)
				local velalignmentnorm=oldvel:normalize():dot(forward1)
				local velalignmentnorm2=oldvel:normalize():dot(right1)
				dist_taveled=dist_taveled+oldvel:length()*velalignmentnorm*(0.25)
				if colliding then

					local velocity = point:get_pos() - point:get_luaentity()._prev_pos
					if velocity:length()>0.01 then
						--minetest.chat_send_all(velocity:length())
						if (point:get_pos()-averagepos):dot(forward1)>0 then
							velocity=velocity-right1*velocity:dot(right1:rotate_around_axis(up1,tmp_turn_amount))
						else
							velocity=velocity-right1*velocity:dot(right1)
						end
						velocity=friction(velocity,linear_friction*math.abs(velalignmentnorm2))
						--minetest.chat_send_all(velocity:length())
						
					end
					point:get_luaentity()._prev_pos = point:get_pos() - velocity
					
					--torque(vector.new(0,0.1,0))
					--impulse(oldvel-(point:get_luaentity()._prev_pos-point:get_pos()),point)
					if mesh and mesh:get_luaentity()._driver then
						local keys = mesh:get_luaentity()._driver:get_player_control()
						if keys.up then
							impulse(vector.new(forward_impulse_force, 0, 0), point)
						end
						if keys.down then
							impulse(vector.new(-backward_impulse_force, 0, 0), point)
						end
						local tmp_max_turning_angle=max_turning_angle/math.max(velocity:length()*10,1)
						if keys.right then
							turning=true
							tmp_turn_amount=math.min(tmp_max_turning_angle,math.max(-tmp_max_turning_angle,tmp_turn_amount-0.01))
							--torque(up1*turn_force*tmp_turn_amount*weaksign(velalignment,3), point)
						end
						if keys.left then
							turning=true
							tmp_turn_amount=math.min(tmp_max_turning_angle,math.max(-tmp_max_turning_angle,tmp_turn_amount+0.01))
							--torque(up1*turn_force*tmp_turn_amount*weaksign(velalignment,3), point)
						end
					end
					if press_forward then
						impulse(vector.new(forward_impulse_force, 0, 0), point)
					end


					local velocity = point:get_pos() - point:get_luaentity()._prev_pos
					local new_velocity = ((velocity - averagevel) * angular_damp + averagevel)
					point:get_luaentity()._prev_pos = point:get_pos() - new_velocity
				end
				if not turning then
					tmp_turn_amount=tmp_turn_amount*0.99
					--tmp_turn_amount=tmp_turn_amount-weaksign(tmp_turn_amount,max_turning_angle/10)/100
				end
			end
		end

		for _, data in pairs(connections) do
			fix(data)
		end

		for k,wheel in pairs(wheels) do
			local wheeldir=right1
			if k==1 then
				--vector.new(-1.21,0,0.738)
				wheel:set_pos(averagepos+transform(right1,up1,forward1,vector.new(0.738,0,-1.21)))
			elseif k==2 then
				wheel:set_pos(averagepos+transform(right1,up1,forward1,vector.new(-0.738,0,-1.21)))
			elseif k==3 then
				wheel:set_pos(averagepos+transform(right1,up1,forward1,vector.new(0.738,0,1.65)))
				wheeldir=right1:rotate_around_axis(up1,tmp_turn_amount)
			elseif k==4 then
				wheel:set_pos(averagepos+transform(right1,up1,forward1,vector.new(-0.738,0,1.65)))
				wheeldir=right1:rotate_around_axis(up1,tmp_turn_amount)
			end
			wheel:set_rotation(vector.dir_to_rotation(wheeldir, up1:rotate_around_axis(wheeldir,dist_taveled)))
		end

		if mesh then
			mesh:set_pos(averagepos+transform(right1,up1,forward1,vector.new(0,0,0.4)))
			mesh:set_rotation(vector.dir_to_rotation(right1, up1))
		end
	end

	--Orient Mesh
end)

minetest.register_entity("racingphysics:rigid_point", rigid_point)

minetest.register_chatcommand("impulse", {
	description = "impulse",
	func = function(name, param)
		impulse()
	end,
})

minetest.register_chatcommand("freeze", {
	description = "freeze physics",
	func = function(name, param)
		freeze_physics=not freeze_physics
	end,
})

minetest.register_chatcommand("pf", {
	description = "freeze physics",
	func = function(name, param)
		press_forward=not press_forward
	end,
})

local pf_spawnpoint
minetest.register_chatcommand("pf_set_start", {
	description = "Set starting point for automatic pf track",
	func = function(name, param)
		pf_spawnpoint=minetest.get_player_by_name(name):get_pos()
		minetest.chat_send_all(pf_spawnpoint)
	end,
})

minetest.register_chatcommand("pfstart", {
	description = "Spawn car at pf spawnpoint",
	func = function(name, param)
		if pf_spawnpoint then
			spawn_car(pf_spawnpoint)
			freeze_physics=false
		end
	end,
})

minetest.register_node("racingphysics:pfstart",{
	description="pfstart",
	tiles={"default_gold_block.png"},
	drawtype="mesh",
	mesh="arch1.obj",
	groups={cracky=1},
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 },
	},
	on_rightclick=function(pos,node,clicker,itemstack,pointed_thing)
		spawn_car(pos+vector.new(0,1,0))
		freeze_physics=false
	end

})