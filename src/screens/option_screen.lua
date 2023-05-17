local audio_manager = require("audio_manager")
local font_manager = require("font_manager")
local direction = require("direction")
local basic_screen = require("screens/basic_screen")
local screen_type = require("screens/screen_type")
local color_scheme = require("gui/color_scheme")
local option_list = require("gui/option_list")
local option_item = require("gui/option_item")

local option_screen = {}
option_screen.__index = option_screen
setmetatable(option_screen, basic_screen)

function option_screen.new(d)
	local self = basic_screen.new(d, screen_type.OPTIONS, "OPTIONS")
	setmetatable(self, option_screen)
	self.super = basic_screen

	self.options = option_list.new()

	-- Create full screen toggle
	self.full_screen = option_item.toggle.new("Full screen", d.is_fullscreen)
	self.full_screen:add_listener(function (val)
		d.toggle_fullscreen(val)
		audio_manager.play(audio_manager.LINE_CLEAR_1)
	end)
	self.options:add(self.full_screen)

	-- Create dark mode toggle
	local dark_mode = option_item.toggle.new("Dark mode", false)
	-- self.dark_mode:add_listener(function (val) end)
	self.options:add(dark_mode)

	-- Create music volume slider
	local music_volume = option_item.slider.new("Music volume", audio_manager.music_volume)
	music_volume:add_listener(function (val)
		audio_manager.set_music_volume(val)
		audio_manager.play(audio_manager.PIECE_MOVE)
	end)
	self.options:add(music_volume)

	-- Create sound effects volume slider
	local sound_volume = option_item.slider.new("Sound volume", audio_manager.sound_volume)
	sound_volume:add_listener(function (val)
		audio_manager.set_sound_volume(val)
		audio_manager.play(audio_manager.PIECE_MOVE)
	end)
	self.options:add(sound_volume)

	-- Create about game submenu
	local about = option_item.button.new("About")
	about:add_listener(function ()
		d.transition_screen(screen_type.ABOUT, direction.RIGHT)
		audio_manager.play(audio_manager.LINE_CLEAR_1)
	end)
	self.options:add(about)
	
	return self
end

function option_screen:load()
	self.options:scroll_to_start()
end

function option_screen:unload()
	self.options:scroll_to_start()
end

function option_screen:update()
	self.full_screen.enabled = self.display.is_fullscreen
end

function option_screen:key_pressed(key)
	if key == "escape" then
		self.display.transition_screen(screen_type.MAIN_MENU, direction.LEFT)
	elseif key == "down" then self.options:move_down()
	elseif key == "up" then self.options:move_up()
	elseif key == "left" then self.options:key_left()
	elseif key == "right" then self.options:key_right()
	elseif key == "return" then self.options:select()
	end
	self.display.update()
end

function option_screen:draw(screen_width, screen_height)
	self.super.draw(self, screen_width, screen_height)
	self.options:set_size(screen_width - 40, screen_height - 140)
	self.options:draw(20, 100)
end

return option_screen
