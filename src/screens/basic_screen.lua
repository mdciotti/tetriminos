local font_manager = require("font_manager")
local screen = require("screens/screen")
local color_scheme = require("gui/color_scheme")

local basic_screen = {}
basic_screen.__index = basic_screen
setmetatable(basic_screen, screen)

function basic_screen.new(d, type, title)
	local self = screen.new(d, type)
	setmetatable(self, basic_screen)
	self.super = screen

	self.title = title
	
	return self
end

function basic_screen:draw(screen_width, screen_height)
	-- Draw background
	love.graphics.setColor(color_scheme.BASE_00)
	love.graphics.rectangle('fill', 0, 0, screen_width, screen_height)

	-- Draw overlay background
	love.graphics.setColor(color_scheme.BASE_07)
	love.graphics.rectangle('fill', 0, 20, screen_width, screen_height - 40)

	-- Draw screen title
	love.graphics.setFont(font_manager.screen_title)
	love.graphics.setColor(color_scheme.BASE_02)
	love.graphics.print2(self.title, 20, 40)
end

return basic_screen
