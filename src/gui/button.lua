-- local component = require("gui/component")
local hotspot = require("gui/hotspot")

local button = {}
button.__index = button
-- setmetatable(button, component)

function button.new(x, y, w, h)
	local self = {}
	-- local self = component.new(x, y)
	setmetatable(self, button)

	self.x = x
	self.y = y
	self.width = w
	self.height = h
	
	self.hotspot = hotspot.new(x, y, w, 40, 0.5, 0)
	self.hotspot:on('click', self.on_press)
	self.hotspot:on('mousemove', self.on_hover)

	return self
end

function button:pressed()

end

function button:hover()

end

return button
