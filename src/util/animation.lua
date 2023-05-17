local direction = require("direction")
local easing = require("util/easing")

local animation = {}
animation.__index = animation

function animation.new(duration)
	local self = {}
	setmetatable(self, animation)

	-- The starting timestamp of the animation
	self.start_time = nil
	-- The duration of the animation, in seconds
	self.duration = duration
	-- A tweening value (to control animation progress)
	self.progress = 0
	-- The transition function
	self.easing = easing.exponential
	-- The function to call when complete
	self.on_complete = function () end
	-- Whether or not it is currently animating
	self.active = false

	return self
end

function animation:start()
	self.start_time = love.timer.getTime()
	self.active = true
end

function animation:on_end(fn)
	if fn ~= nil then
		self.on_complete = fn
	end
end

function animation:update()
	if self.active then
		local now = love.timer.getTime()
		local dt = now - self.start_time
		self.progress = self.easing.ease_out(dt / self.duration)
		if dt >= self.duration then
			self.on_complete()
			self.active = false
		end
	end
end

return animation
