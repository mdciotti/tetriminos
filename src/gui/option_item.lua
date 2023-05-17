local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")
-- local list_item = require("gui/list_item")

--------------------------------------------------------------------------------

local option_item = {}
option_item.__index = option_item
-- setmetatable(option_item, list_item)

function option_item.new(text)
	-- local self = list_item.new()
	local self = {}
	setmetatable(self, option_item)

	self.text = text
	self.parent = nil
	self.listeners = {}

	return self
end

function option_item:fire_event(value)
	for i, listener in ipairs(self.listeners) do
		listener(value)
	end
end

function option_item:add_listener(fn)
	if fn ~= nil then
		table.insert(self.listeners, fn)
	end
end

function option_item:remove_listener(fn)
	-- TODO: find and remove
end

function option_item:select() end
function option_item:key_left() end
function option_item:key_right() end

function option_item:draw(x, y)
	love.graphics.print2(self.text, x + 20, y)
end

--------------------------------------------------------------------------------

option_item.toggle = {}
option_item.toggle.__index = option_item.toggle
setmetatable(option_item.toggle, option_item)

function option_item.toggle.new(text, enabled)
	local self = option_item.new(text)
	setmetatable(self, option_item.toggle)
	self.super = option_item

	self.enabled = enabled

	return self
end

function option_item.toggle:select()
	self.enabled = not self.enabled
	self:fire_event(self.enabled)
end

function option_item.toggle:draw(x, y)
	self.super.draw(self, x, y)

	local w = self.parent.width
	local pad = 20
	local end_x = x + w - pad

	if self.enabled then
		love.graphics.circle('fill', end_x - 10, y + 20, 10, 32)
	else
		love.graphics.circle('line', end_x - 10, y + 20, 10, 32)
	end
end

--------------------------------------------------------------------------------

option_item.button = {}
option_item.button.__index = option_item.button
setmetatable(option_item.button, option_item)

function option_item.button.new(text, enabled)
	local self = option_item.new(text)
	setmetatable(self, option_item.button)
	self.super = option_item

	return self
end

function option_item.button:select()
	self:fire_event()
end

function option_item.button:draw(x, y)
	self.super.draw(self, x, y)

	local w = self.parent.width
	local pad = 20
	local end_x = x + w - pad

	love.graphics.line(end_x - 10, y + 10, end_x, y + 20, end_x - 10, y + 30)
end

--------------------------------------------------------------------------------

option_item.slider = {}
option_item.slider.__index = option_item.slider
setmetatable(option_item.slider, option_item)

function option_item.slider.new(text, value)
	local self = option_item.new(text)
	setmetatable(self, option_item.slider)
	self.super = option_item

	self.value = value
	self.step = 0.1

	return self
end

function option_item.slider:key_left()
	-- Decrement
	if self.value >= self.step then self.value = self.value - self.step
	else self.value = 0 end
	self:fire_event(self.value)
end

function option_item.slider:key_right()
	-- Increment
	if self.value <= 1 - self.step then self.value = self.value + self.step
	else self.value = 1 end
	self:fire_event(self.value)
end

function option_item.slider:draw(x, y)
	self.super.draw(self, x, y)

	local w = self.parent.width
	local pad = 20
	local end_x = x + w - pad
	local slider_w = 100
	local val_x = end_x - slider_w + math.floor(self.value * slider_w)

	love.graphics.line(end_x - slider_w, y + 20, end_x, y + 20)
	love.graphics.circle('fill', val_x, y + 20, 10, 32)
end

--------------------------------------------------------------------------------

return option_item
