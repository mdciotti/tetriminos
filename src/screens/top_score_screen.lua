local font_manager = require("font_manager")
local direction = require("direction")
local basic_screen = require("screens/basic_screen")
local screen_type = require("screens/screen_type")
local color_scheme = require("gui/color_scheme")
local score_list = require("gui/score_list")
local button = require("gui/button")

local top_score_screen = {}
top_score_screen.__index = top_score_screen
setmetatable(top_score_screen, basic_screen)

function top_score_screen.new(d)
	local self = basic_screen.new(d, screen_type.TOP_SCORES, "TOP SCORES")
	setmetatable(self, top_score_screen)
	self.super = basic_screen

	self.scores = score_list.new()

	self.back_button = button.new(-20, 40, 40, 40, 'right', 'top')
	
	return self
end

function top_score_screen:load()
	self.scores:scroll_to_start()
end

function top_score_screen:unload()
	self.scores:scroll_to_start()
end

function top_score_screen:key_pressed(key)
	if key == "escape" then
		self.display.transition_screen(screen_type.MAIN_MENU, direction.RIGHT)
	elseif key == "down" then self.scores:move_down()
	elseif key == "up" then self.scores:move_up()
	end
	self.display.update()
end

function top_score_screen:draw(screen_width, screen_height)
	self.super.draw(self, screen_width, screen_height)
	self.scores:set_size(screen_width - 40, screen_height - 140)
	self.scores:draw(20, 100)
end

return top_score_screen
