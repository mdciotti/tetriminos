local audio_manager = require("audio_manager")
local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")
local hotspot = require("gui/hotspot")

local basic_menu = {}
basic_menu.__index = basic_menu

function basic_menu.new(s, x, y)
	local self = {}
	setmetatable(self, basic_menu)

	self.screen = s
	self.options = {}
	self.selected_index = 1
	self.num_options = 0
	self.parent = nil
	self.x = x
	self.y = y

	return self
end

function basic_menu:add_option(title, handler)
	table.insert(self.options, {
		text = title,
		callback = handler
	})
	self.num_options = self.num_options + 1

	-- Add mouse hotspot
	love.graphics.setFont(font_manager.menu_option)
	local i = #self.options
	local w = font_manager.width(title) + 40
	local y = self.y + i * 40
	local x = -w / 2

	local spot = hotspot.new(x, y, w, 40, 0.5, 0)
	spot:on('click', function ()
		audio_manager.play(audio_manager.LINE_CLEAR_1)
		handler()
	end)
	spot:on('mousemove', function ()
		if self.selected_index ~= i then
			audio_manager.play(audio_manager.PIECE_MOVE)
			self.selected_index = i
		end
	end)

	self.screen:add_hotspot(spot)
end

function basic_menu:move_down()
	self.selected_index = self.selected_index + 1
	if self.selected_index > self.num_options then
		self.selected_index = self.selected_index - self.num_options
	end
	audio_manager.play(audio_manager.PIECE_MOVE)
end

function basic_menu:move_up()
	self.selected_index = self.selected_index - 1
	if self.selected_index < 1 then
		self.selected_index = self.selected_index + self.num_options
	end
	audio_manager.play(audio_manager.PIECE_MOVE)
end

function basic_menu:select()
	audio_manager.play(audio_manager.LINE_CLEAR_1)
	self.options[self.selected_index].callback()
end

-----
-- Draws a basic menu at the coordinates.
-- @param x the center of the menu
-- @param y the top of the menu

function basic_menu:draw()
	love.graphics.setFont(font_manager.menu_option)
	-- Draw the menu options
	for i, o in ipairs(self.options) do
		local w = font_manager.width(o.text)
		local iy = self.y + i * 40
		local ix = self.x - w / 2

		if i == self.selected_index then
			-- Draw selection indication
			love.graphics.setColor(color_scheme.BASE_0D)
			love.graphics.rectangle('fill', ix - 20, iy, w + 40, 40)
			love.graphics.setColor(color_scheme.BASE_07)
		else
			love.graphics.setColor(color_scheme.BASE_03)
		end

		-- Draw menu item text
		love.graphics.print2(o.text, self.x, iy, 'center')
	end
end

return basic_menu
