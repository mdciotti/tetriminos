local font_manager = require("font_manager")
local score_manager = require("score_manager")
local direction = require("direction")
local screen = require("screens/screen")
local screen_type = require("screens/screen_type")
local color_scheme = require("gui/color_scheme")
local game = require("game")
local timer = require("util/timer")
local number_format = require("util/number_format")
local text_field = require("gui/text_field")
local tetrimino_field = require("gui/tetrimino_field")
local modal = require("gui/modal")
local text_input_modal = require("gui/text_input_modal")
local mino = require("mino")

local game_screen = {}
game_screen.__index = game_screen
setmetatable(game_screen, screen)

-- Set up number formatting
local nf = number_format.new()

function game_screen.new(d)
	local self = screen.new(d, screen_type.GAME)
	setmetatable(self, game_screen)

	local delay = game.START_SPEED
	self.timer = timer.new(delay, self, true)

	-- Create the game
	self.game = game.new(self.display)

	-- Information Fields
	self.score_field = text_field.new("SCORE", 60)
	self.top_score_field = text_field.new("TOP SCORE", 60)
	self.level_field = text_field.new("LEVEL", 60)
	self.goal_field = text_field.new("GOAL", 60)
	self.next_piece_field = tetrimino_field.new("NEXT", 100)
	self.hold_field = tetrimino_field.new("HOLD", 100)

	-- Modals
	self.game_over_modal = text_input_modal.new("G A M E   O V E R", self)
	self.game_over_modal:add_body_line("")
	self.game_over_modal:add_body_line("enter your name to save this score")
	self.game_over_modal:add_body_line("or press esc to quit to the menu")

	self.paused_modal = modal.new("P A U S E D", self)
	self.paused_modal:add_body_line("press escape to resume play")
	self.paused_modal:add_body_line("or press q to quit to the menu")

	return self
end

-- This is called when tht timer ticks
function game_screen:on_tick()
	if self.game.is_over then self.timer:stop()
	else
		self.game:tick()
		local speed = game.START_SPEED * game.SPEED_GROWTH_FACTOR ^ (self.game.level - 1)
		self.timer:set_delay(1.0 / speed)
	end
	self.display.update()
end

function game_screen:load()
	self.game:start()
	self.timer:start()
	-- self.game_over_modal:hide()
	-- self.paused_modal:hide()
end

function game_screen:unload()
	self.game:reset()
	self.timer:stop()
	self.game_over_modal.visible = false
	self.paused_modal.visible = false
	-- self.game_over_modal:hide()
	-- self.paused_modal:hide()
end

function game_screen:update()
	if self.game ~= nil then
		if self.game.is_over and not self.game_over_modal.visible then
			local points = nf:format(self.game.score)
			local str = string.format("you reached level %d with %s points",
				self.game.level, points)
			self.game_over_modal:set_body_line(1, str)
			self.game_over_modal:set_input_text("Anonymous")
			self.game_over_modal:show()
		elseif not self.game.is_over and
			self.game_over_modal.visible and
			not self.game_over_modal.animation_out.active then
			self.game_over_modal:hide()
		end

		if self.game.paused and not self.paused_modal.visible then
			self.paused_modal:show()
		elseif not self.game.paused and
			self.paused_modal.visible and
			not self.paused_modal.animation_out.active then
			self.paused_modal:hide()
		end
	end

	self.paused_modal:update()
	self.game_over_modal:update()
end

function game_screen:key_pressed(key)
	if key == "escape" then
		if not self.game.is_over then
			self.game:pause()
			if self.game.paused then self.timer:stop()
			else self.timer:start() end
		end
	end

	-- Handle user input events only if the game is not over
	if not self.game.is_over and not self.game.paused then
		if key == "down" then self.game:move_piece(direction.DOWN)
		elseif key == "left" then self.game:move_piece(direction.LEFT)
		elseif key == "right" then self.game:move_piece(direction.RIGHT)
		elseif key == "space" then self.game:drop_piece()
		elseif key == "up" then self.game:rotate_piece()
		elseif key == "lshift" then self.game:hold_piece()
		end
	elseif self.game.is_over then
		self.game_over_modal:key_pressed(key)
		self.display.update()

		if key == "escape" then
			-- Quit to menu (don't save score)
			self.display.transition_screen(screen_type.MAIN_MENU, direction.UP)
		elseif key == "return" then
			-- Save score and quit to menu
			score_manager.add(self.game_over_modal.text, self.game.score)
			self.display.transition_screen(screen_type.MAIN_MENU, direction.UP)
		end
	elseif self.game.paused then
		if key == "q" then
			self.game:over()
			self.display.transition_screen(screen_type.MAIN_MENU, direction.UP)
		end
	end
	self.display.update()
end

function game_screen:text_input(text)
	if self.game.is_over then
		self.game_over_modal:text_input(text)
		self.display.update()
	end
end

function game_screen:draw(screen_width, screen_height)
	-- Draw background
	love.graphics.setColor(color_scheme.BASE_02)
	love.graphics.rectangle('fill', 0, 0, screen_width, screen_height)

	-- Draw the actual game
    local w = self.game.matrix.cols * mino.WIDTH
	self.game:draw((screen_width - w) / 2, 0)

	-- Calculate sidebar offsets
	local right_side = screen_width / 2 + 130
	local left_side = screen_width / 2 - 230

	-- Draw score
	self.score_field.value = nf:format(self.game.score)
	self.score_field:draw(right_side, 420 - 160)

	-- Draw top score
	self.top_score_field.value = nf:format(self.game.get_high_score())
	self.top_score_field:draw(right_side, 420 - 80)

	-- Draw level
	self.level_field.value = nf:format(self.game.level)
	self.level_field:draw(left_side, 420 - 160)

	-- Draw goal
	self.goal_field.value = nf:format(self.game.goal)
	self.goal_field:draw(left_side, 420 - 80)

	-- Draw next piece
	self.next_piece_field:set_tetrimino(self.game.next_piece)
	self.next_piece_field:draw(right_side, 20)

	-- Draw hold
	self.hold_field:set_tetrimino(self.game.held_piece)
	self.hold_field:draw(left_side, 20)

	-- Draw Game Over modal
	if self.game_over_modal.visible then
		self.game_over_modal:draw(screen_width, screen_height)
	end

	-- Draw pause modal
	if self.paused_modal.visible then
		self.paused_modal:draw(screen_width, screen_height)
	end
end

return game_screen
