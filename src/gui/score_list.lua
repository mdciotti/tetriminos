local audio_manager = require("audio_manager")
local font_manager = require("font_manager")
local score_manager = require("score_manager")
local color_scheme = require("gui/color_scheme")
local number_format = require("util/number_format")

local score_list = {}
score_list.__index = score_list

-- Set up number formatting
local nf = number_format.new()

function score_list.new()
	local self = {}
	setmetatable(self, score_list)

	self.selected_index = 1
	self.current_page = 1
	self.row_height = 40
	self:set_size(0, 0)

	return self
end

function score_list:set_size(width, height)
	self.width, self.height = width, height
	self.num_scores_per_page = math.floor(self.height / self.row_height)

	self.current_page = self:get_page(self.selected_index)
end

function score_list:get_page(i)
	return math.floor((i - 1) / self.num_scores_per_page) + 1
end

function score_list:scroll_to_start()
	self.selected_index = 1
	self.current_page = 1
end

function score_list:scroll_to_end()
	self.selected_index = score_manager.get_num_scores()
	self.current_page = self:get_page(score_manager.get_num_scores())
end

function score_list:move_down()
	self.selected_index = self.selected_index + 1
	if self.selected_index > self.num_scores_per_page * self.current_page then
		self.current_page = self.current_page + 1
	end
	if self.selected_index > score_manager.get_num_scores() then
		self:scroll_to_start()
	end
	audio_manager.play(audio_manager.PIECE_MOVE)
end

function score_list:move_up()
	self.selected_index = self.selected_index - 1
	if self.selected_index <= self.num_scores_per_page * (self.current_page - 1) then
		self.current_page = self.current_page - 1
	end
	if self.selected_index <= 0 then
		self:scroll_to_end()
	end
	audio_manager.play(audio_manager.PIECE_MOVE)
end

function score_list:draw(x, y)

	local w, h = self.width, self.height
	local center_x = x + w / 2

	-- Draw "no scores" text if no scores
	if score_manager.get_num_scores() == 0 then
		love.graphics.setFont(font_manager.no_results)
		love.graphics.setColor(color_scheme.BASE_03)
		love.graphics.print2("no scores", center_x, y + 100, 'center')
		return
	end

	-- Draw all scores
	love.graphics.setFont(font_manager.score_list)

	local start_index = (self.current_page - 1) * self.num_scores_per_page + 1
	local end_index = self.current_page * self.num_scores_per_page

	-- Calculate maximum numeral width
	local max_numeral_width = 0
	for i = start_index, end_index do
		if i > score_manager.get_num_scores() then break end
		local numeral = nf:format(i)
		local nw = font_manager.width(numeral)
		max_numeral_width = math.max(max_numeral_width, nw)
	end

	for i = start_index, end_index do
		if i > score_manager.get_num_scores() then break end

		local o = score_manager.get(i)
		if o == nil then break end

		local pad = 20

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

		-- Draw numeral
		local numeral = nf:format(i)
		-- local numeral_width = font_manager.score_list:getWidth(numeral)
		love.graphics.print2(numeral, x + pad + max_numeral_width, iy, 'right')

		-- Draw score
		local score = nf:format(o.score)
		local score_width = font_manager.width(score)
		love.graphics.print2(score, x + w - pad, iy, 'right')

		-- Draw player name (truncate if too long)
		local max_player_width = w - max_numeral_width - score_width - 4 * pad
		local player = o.player
		local player_width = font_manager.width(player)
		if player_width > max_player_width then
			while player_width > max_player_width do
				player = string.sub(player, 1, string.len(player) - 1)
				player_width = font_manager.width(player .. "...")
			end
			player = player .. "..."
		end
		love.graphics.print2(player, x + 2 * pad + max_numeral_width, iy)
	end
end

return score_list
