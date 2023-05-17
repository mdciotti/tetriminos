local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")
local info_field = require("gui/info_field")

local text_field = {}
text_field.__index = text_field
setmetatable(text_field, info_field)

function text_field.new(title, height)
	local self = info_field.new(title, height)
	setmetatable(self, text_field)
	self.super = info_field

	self.value = ""

	return self
end

function text_field:draw(x, y)
	self.super.draw(self, x, y)

	-- Draw value
	love.graphics.setColor(color_scheme.BASE_07)
	love.graphics.setFont(font_manager.text_field)
	love.graphics.print2(self.value, x + self.width / 2, y + 12, 'center')
end

return text_field
