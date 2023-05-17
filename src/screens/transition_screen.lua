local screen_type = require("screens/screen_type")
local direction = require("direction")
local screen = require("screens/screen")
local animation = require("util/animation")

local transition_screen = {}
transition_screen.__index = transition_screen
setmetatable(transition_screen, screen)

function transition_screen.new(display)
	local self = screen.new(display, screen_type.TRANSITION)
	setmetatable(self, transition_screen)

	-- The "from" screen
	self.current = nil
	-- The "to" screen
	self.next = nil
	-- The direction to animate the screen transition
	self.direction = direction
	
	self.animation = animation.new(0.5)

	self.animation:on_end(function ()
		display.set_screen(self.next.type)
	end)

	return self
end

function transition_screen:load()
	self.animation:start()
end

function transition_screen:unload()
	self.current:unload()
end

function transition_screen:update()
	self.animation:update()
end

function transition_screen:draw(screen_width, screen_height)
	local w, h = screen_width, screen_height
	local t = self.animation.progress
	local x, y = t * w, t * h

	local dir = self.direction

	if dir == direction.LEFT then
		love.graphics.translate(-x, 0)
		if self.current ~= nil then self.current:draw(w, h) end
		love.graphics.translate(w, 0)
		if self.next ~= nil then self.next:draw(w, h) end
	elseif dir == direction.RIGHT then
		love.graphics.translate(-w + x, 0)
		if self.next ~= nil then self.next:draw(w, h) end
		love.graphics.translate(w, 0)
		if self.current ~= nil then self.current:draw(w, h) end
	elseif dir == direction.UP then
		love.graphics.translate(0, -h + y)
		if self.next ~= nil then self.next:draw(w, h) end
		love.graphics.translate(0, h)
		if self.current ~= nil then self.current:draw(w, h) end
	elseif dir == direction.DOWN then
		love.graphics.translate(0, -y)
		if self.current ~= nil then self.current:draw(w, h) end
		love.graphics.translate(0, h)
		if self.next ~= nil then self.next:draw(w, h) end
	end
end

return transition_screen
