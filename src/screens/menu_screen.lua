local font_manager = require("font_manager")
local direction = require("direction")
local screen = require("screens/screen")
local screen_type = require("screens/screen_type")
local color_scheme = require("gui/color_scheme")
local basic_menu = require("gui/basic_menu")

local menu_screen = {}
menu_screen.__index = menu_screen
setmetatable(menu_screen, screen)

function menu_screen.new(d)
	local self = screen.new(d, screen_type.MAIN_MENU)
	setmetatable(self, menu_screen)
	self.super = screen

	self.title = "T E T R I M I N O S"
	self.menu = basic_menu.new(self, d.width / 2, 140)
	self.menu:add_option("play", function ()
		d.transition_screen(screen_type.GAME, direction.DOWN)
	end)
	self.menu:add_option("top scores", function ()
		d.transition_screen(screen_type.TOP_SCORES, direction.LEFT)
	end)
	self.menu:add_option("options", function ()
		d.transition_screen(screen_type.OPTIONS, direction.RIGHT)
	end)
	self.menu:add_option("quit", function ()
		love.event.quit(0)
	end)
	return self
end

function menu_screen:key_pressed(key)
	if key == "escape" then
		if self.menu.parent == nil then
			love.event.quit(0)
		end
		return
	elseif key == "down" then self.menu:move_down()
	elseif key == "up" then self.menu:move_up()
	elseif key == "return" then self.menu:select()
	end
	self.display.update()
end

function menu_screen:draw(screen_width, screen_height)
	-- Draw background
	love.graphics.setColor(color_scheme.BASE_00)
	love.graphics.rectangle('fill', 0, 0, screen_width, screen_height)

	-- Draw overlay background
	love.graphics.setColor(color_scheme.BASE_07)
	love.graphics.rectangle('fill', 0, 20, screen_width, screen_height - 40)

	-- Draw menu title
	love.graphics.setFont(font_manager.menu_title)
	love.graphics.setColor(color_scheme.BASE_02)
	love.graphics.print2(self.title, screen_width / 2, 90, 'center')

	self.menu.x = screen_width / 2
	self.menu:draw()
end

return menu_screen
