local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")
local gaussian_blur = require("effects/gaussian_blur")
local direction = require("direction")
local animation = require("util/animation")

local modal = {}
modal.__index = modal

function modal.new(title, screen)
	local self = {}
	setmetatable(self, modal)

	self.title = title
	self.screen = screen
	self.body = {}

	self.visible = false
	self.height = 90
	self.y = 0
	self.line_height = 30
	self.window_shade = true

	self.blur_background = true
	self.bg_blur_buffer = nil
	self.blur_effect = gaussian_blur.new(8, 3, color_scheme.BASE_01)

	self.animation_in = animation.new(0.5)
	self.animation_out = animation.new(0.5)

	self.animation_out:on_end(function ()
		self.visible = false
	end)

	return self
end

function modal:add_body_line(line)
	table.insert(self.body, line)
	self.height = self.height + self.line_height
end

function modal:set_body_line(i, line)
	if self.body[i] ~= nil then
		self.body[i] = line
	end
end

function modal:show()
	self.animation_in:start()
	self.visible = true
	if self.blur_background then
		-- Blur the background behind the modal
		local screen = self.screen.display.screen_buffer
		-- First draw the screen buffer at (1/scale) / 2
		local scale = self.screen.display.scale
		local w = self.screen.display.width / scale
		local h = self.screen.display.height / scale
		local buffer = love.graphics.newCanvas(w, h)
		love.graphics.push()
		love.graphics.setCanvas(buffer)
		love.graphics.scale(1 / scale)
		love.graphics.draw(screen)
		love.graphics.setCanvas()
		love.graphics.pop()
		self.bg_blur_buffer = self.blur_effect:apply(buffer)
		-- self.bg_blur_buffer = buffer
	end
end

function modal:hide()
	self.animation_out:start()
end

function modal:key_pressed(key)
end

function modal:key_released(key)
end

function modal:text_input(text)
end

function modal:update()
	self.animation_in:update()
	self.animation_out:update()
end

function modal:draw(width, height)

	local t_in = self.animation_in.progress
	local t_out = self.animation_out.progress

	local opacity = 1
	if self.animation_out.active then
		opacity = 1 - t_out
	elseif self.animation_in.active then
		opacity = t_in
	end

	local alpha = 255

	if self.blur_background then
		-- Draw the blurred background
		-- This does some calculations to ensure the blurred buffer is always
		-- drawn centered in the window, and covering the entire window
		alpha = math.floor(255 * opacity)
		love.graphics.setColor(255, 255, 255, alpha)
		local disp_scale = self.screen.display.scale
		local src_w = self.bg_blur_buffer:getWidth()
		local src_h = self.bg_blur_buffer:getHeight()
		local dst_w, dst_h = love.graphics.getDimensions()
		dst_w, dst_h = dst_w / disp_scale, dst_h / disp_scale
		local scale = math.max(dst_w / src_w, dst_h / src_h)
		local ox, oy = (dst_w - src_w * scale) / 2, (dst_h - src_h * scale) / 2
		love.graphics.draw(self.bg_blur_buffer, ox, oy, 0, scale)
	end

	if self.window_shade then
		-- Draw a shadow over the entire window
		alpha = math.floor(128 * opacity)
		love.graphics.setColor(add_alpha(color_scheme.BASE_00, alpha))
		love.graphics.rectangle('fill', 0, 0, width, height)
	end

	self.y = (height - self.height) / 2
	if self.animation_out.active then
		self.y = self.y - t_out * height
	elseif self.animation_in.active then
		self.y = self.y - t_in * height + height
	end

	alpha = math.floor(255 * (-math.log(1-opacity)/5))
	alpha = math.max(math.min(255, alpha), 0)

	-- Draw the overlay background
	love.graphics.setColor(add_alpha(color_scheme.BASE_07, alpha))
	love.graphics.rectangle('fill', 0, self.y, width, self.height)

	-- Draw the overlay title
	love.graphics.setFont(font_manager.modal_title)
	love.graphics.setColor(add_alpha(color_scheme.BASE_02, alpha))
	love.graphics.print2(self.title, width / 2, self.y + 18, 'center')

	-- Draw the overlay body text
	love.graphics.setFont(font_manager.modal_body)
	love.graphics.setColor(add_alpha(color_scheme.BASE_03, alpha))
	for i, line in ipairs(self.body) do
		local iy = self.y + 40 + i * self.line_height
		love.graphics.print2(line, width / 2, iy, 'center')
	end
end

function add_alpha(color, alpha)
	return { color[1], color[2], color[3], alpha }
end

return modal
