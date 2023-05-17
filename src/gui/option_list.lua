local audio_manager = require("audio_manager")
local font_manager = require("font_manager")
local color_scheme = require("gui/color_scheme")

local option_list = {}
option_list.__index = option_list

function option_list.new()
	local self = {}
	setmetatable(self, option_list)

	self.selected_index = 1
	self.current_page = 1
	self.row_height = 40
	self:set_size(0, 0)

	self.items = {}
	self.empty_msg = "no options"

	return self
end

function option_list:add(item)
	table.insert(self.items, item)
	item.parent = self
end

function option_list:set_size(width, height)
	self.width, self.height = width, height
	self.num_items_per_page = math.floor(self.height / self.row_height)

	self.current_page = self:get_page(self.selected_index)
end

function option_list:get_page(i)
	return math.floor((i - 1) / self.num_items_per_page) + 1
end

function option_list:scroll_to_start()
	self.selected_index = 1
	self.current_page = 1
end

function option_list:scroll_to_end()
	self.selected_index = #self.items
	self.current_page = self:get_page(#self.items)
end

function option_list:move_down()
	self.selected_index = self.selected_index + 1
	if self.selected_index > self.num_items_per_page * self.current_page then
		self.current_page = self.current_page + 1
	end
	if self.selected_index > #self.items then
		self:scroll_to_start()
	end
	audio_manager.play(audio_manager.PIECE_MOVE)
end

function option_list:move_up()
	self.selected_index = self.selected_index - 1
	if self.selected_index <= self.num_items_per_page * (self.current_page - 1) then
		self.current_page = self.current_page - 1
	end
	if self.selected_index <= 0 then
		self:scroll_to_end()
	end
	audio_manager.play(audio_manager.PIECE_MOVE)
end

function option_list:key_left()
	-- Delegate to selected option item
	self.items[self.selected_index]:key_left()
end

function option_list:key_right()
	-- Delegate to selected option item
	self.items[self.selected_index]:key_right()
end

function option_list:select()
	self.items[self.selected_index]:select()
end

function option_list:draw(x, y)

	local w, h = self.width, self.height
	local center_x = x + w / 2

	-- Draw empty message if no items
	if #self.items == 0 then
		love.graphics.setFont(font_manager.no_results)
		love.graphics.setColor(color_scheme.BASE_03)
		love.graphics.print2(self.empty_msg, center_x, y + 100, 'center')
		return
	end

	-- Draw all items
	love.graphics.setFont(font_manager.list_item)


	local start_index = (self.current_page - 1) * self.num_items_per_page + 1
	local end_index = self.current_page * self.num_items_per_page

	for i = start_index, end_index do
		if i > #self.items then break end

		local item = self.items[i]
		if item == nil then break end

		local iy = y + (i - start_index) * self.row_height

		if i == self.selected_index then
			-- Draw selection indication
			love.graphics.setColor(color_scheme.BASE_0D)
			love.graphics.rectangle('fill', x, iy, w, self.row_height)
			love.graphics.setColor(color_scheme.BASE_07)
		elseif i % 2 == 1 then
			-- Draw banded rows
			local shade = color_scheme.BASE_06
			love.graphics.setColor(shade[1], shade[2], shade[3], 96)
			love.graphics.rectangle('fill', x, iy, w, self.row_height)
			love.graphics.setColor(color_scheme.BASE_03)
		else
			love.graphics.setColor(color_scheme.BASE_03)
		end

		item:draw(x, iy)
	end
end

return option_list
