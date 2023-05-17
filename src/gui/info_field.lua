local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")

local info_field = {}
info_field.__index = info_field

function info_field.new(title, height)
	local self = {}
	setmetatable(self, info_field)

	self.title = title
	self.width = 100
	self.height = height

	return self
end

function info_field:draw(x, y)
	-- Draw background
	love.graphics.setColor(color_scheme.BASE_00)
	love.graphics.rectangle('fill', x, y, self.width, self.height)

	-- Draw title
	love.graphics.setFont(font_manager.info_field_title)
	love.graphics.setColor(color_scheme.BASE_04)
	love.graphics.print2(self.title, x + self.width / 2, y - 12, 'center')
end

return info_field
