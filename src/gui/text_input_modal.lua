local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")
local modal = require("gui/modal")

local text_input_modal = {}
text_input_modal.__index = text_input_modal
setmetatable(text_input_modal, modal)

local MAX_INPUT_CHARS = 16

local alphanumeric = "([a-zA-Z0-9 ]+)"

function text_input_modal.new(title, screen)
	local self = modal.new(title, screen)
	setmetatable(self, text_input_modal)
	self.super = modal

	self.text = nil
	self.caret_index = 1
	self.height = 140
	self:set_input_text("")

	return self
end

function text_input_modal:set_input_text(text)
	local max = math.min(string.len(text), MAX_INPUT_CHARS)
	self.text = string.sub(text, 1, max)
	-- Move caret to end
	self.caret_index = string.len(self.text) + 1
end

function text_input_modal:key_pressed(key)
	self.super.key_pressed(self, key)

	if key == "left" then
		if self.caret_index > 1 then
			self.caret_index = self.caret_index - 1
		end
	elseif key == "right" then
		if self.caret_index <= string.len(self.text) then
			self.caret_index = self.caret_index + 1
		end
	elseif key == "up" then
		self.caret_index = 1
	elseif key == "down" then
		self.caret_index = string.len(self.text) + 1
	elseif key == "backspace" then
		if self.caret_index > 1 then
			local before = string.sub(self.text, 1, self.caret_index - 2)
			local after = string.sub(self.text, self.caret_index)
			self.text = before .. after
			self.caret_index = self.caret_index - 1
		end
	elseif key == "delete" then
		if self.caret_index <= string.len(self.text) then
			local before = string.sub(self.text, 1, self.caret_index - 1)
			local after = string.sub(self.text, self.caret_index + 1)
			self.text = before .. after
		end
	end

end

function text_input_modal:text_input(text)
	self.super.text_input(self, key)

	if string.len(self.text) < MAX_INPUT_CHARS then
		local before = string.sub(self.text, 1, self.caret_index - 1)
		local after = string.sub(self.text, self.caret_index)
		local new = string.match(text, alphanumeric)
		if new ~= nil then
			self.text = before .. new .. after
			self.caret_index = self.caret_index + string.len(new)
		end
	end
end

function text_input_modal:draw(w, h)
	self.super.draw(self, w, h)

	-- Calculate maximum textfield width by em-width
	local m_width = font_manager.width("m")
	local textfield_w = m_width * MAX_INPUT_CHARS + 40

	local textfield_x = (w - textfield_w) / 2
	local textfield_y = self.y + self.height - 60
	local textfield_center = textfield_x + textfield_w / 2
	local text_width = font_manager.width(self.text)
	local textfield_start = textfield_center - text_width / 2

	-- Draw input text field
	love.graphics.setColor(color_scheme.BASE_06)
	love.graphics.rectangle('fill', textfield_x, textfield_y, textfield_w, 40)

	-- Draw input text
	love.graphics.setColor(color_scheme.BASE_00)
	love.graphics.print2(self.text, textfield_start, textfield_y + 5)

	-- Draw caret
	local text_before_caret = string.sub(self.text, 1, self.caret_index - 1)
	local caret_x = font_manager.width(text_before_caret)
	love.graphics.setColor(color_scheme.BASE_0D)
	love.graphics.rectangle('fill', textfield_start + caret_x - 1,
		textfield_y + 5, 2, 30)
end

return text_input_modal
