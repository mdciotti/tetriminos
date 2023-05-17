local matrix = require("matrix")
local tetrimino = require("tetrimino")
local mino = require("mino")
local audio_manager = require("audio_manager")
local score_manager = require("score_manager")
local randomizer = require("util/randomizer")
local direction = require("direction")
local shapes = require("shapes")

--------------------------------------------------------------------------------
-- Manages the game Tetris. Keeps track of the current piece and the matrix.
-- Updates the display whenever the state of the game has changed.

local game = {}
game.__index = game

-- Description of fields:
-- matrix               the Matrix that makes up the Tetris board
-- piece                the current piece that is in play
-- next_piece           the next piece that will be in play
-- held_piece           the piece that the player is holding off to the side
-- last_piece_held      whether the player held the last piece or not
-- tetris_combo         the number of consecutive tetrises (4 lines cleared)
-- ghost                the preview of where the piece will fall
-- is_over              whether the game is over or not
-- paused               whether the game is paused or not
-- score                the current score
-- high_score           the high score of the current playing session
-- level                the current level (difficulty)
-- goal                 the number of line clears left to the next level
-- lock_on_next_tick    whether the game should lock the piece on the next tick

-- The number of different pieces
local NUM_PIECES = 7

-- The initial number of ticks per second
game.START_SPEED = 1.0

-- The multiplier amount by which the speed increases every level
game.SPEED_GROWTH_FACTOR = 1.15

--------------------------------------------------------------------------------
-- Creates a Tetris game.

function game.new()
    local self = {}
    setmetatable(self, game)

    self.randomizer = randomizer.new(NUM_PIECES)
    self.high_score = 0
    self:reset()
    return self
end

function game:get_high_score()
    local top_score = score_manager.get_top_score()
    if top_score ~= nil then return top_score.score
    else return 0 end
end

--------------------------------------------------------------------------------
-- On every tick the game piece falls down one block. Over time, the amount of
-- time between ticks decreases to make the game progressively harder.

function game:tick()
    if self.piece ~= nil then
        local can_move_down = self.piece:can_move(direction.DOWN)
        if self.lock_on_next_tick and not can_move_down then
            if self:check_lock_out() then self:over()
            else
                self.piece:lock_down()
                self.piece = nil
                self.ghost = nil
            end
        elseif can_move_down then
            self.piece:move(direction.DOWN)
            self.lock_on_next_tick = false
        else
            self.lock_on_next_tick = true
        end
    end
    self:update()
end

function game:pause()
    self.paused = not self.paused
    -- Mute music when paused
    audio_manager.set_muted(self.paused)
end

--------------------------------------------------------------------------------
-- Moves the current Tetrimino in the given direction.
-- @param dir the direction to move

function game:move_piece(dir)
    if self.piece ~= nil then
        if self.piece:can_move(dir) then
            audio_manager.play(audio_manager.PIECE_MOVE)
            self.piece:move(dir)
            if dir == direction.DOWN then
                self.score = self.score + 1
            end
        end
    end
    self:update()
end

--------------------------------------------------------------------------------
-- Rotate the piece.

function game:rotate_piece()
    if self.piece ~= nil then
        if self.piece:can_rotate() then
            audio_manager.play(audio_manager.PIECE_MOVE)
            self.piece:rotate()
        end
    end
    self:update()
end

--------------------------------------------------------------------------------
-- Drops the current Tetrimino to the bottom immediately.

function game:drop_piece()
    if self.piece ~= nil then
        audio_manager.play(audio_manager.HARD_DROP)

        local m = 0
        while self.piece:can_move(direction.DOWN) do
            self.piece:move(direction.DOWN)
            m = m + 1
        end
        self.score = self.score + 2 * m

        if self:check_lock_out() then self:over()
        else
            self.piece:lock_down()
            self.piece = nil
            self.ghost = nil
        end

        self:update()
    end
end

--------------------------------------------------------------------------------
-- Holds the currently falling piece off to the side so that the player can use
-- it later when it is more convenient.

function game:hold_piece()
    -- Don't do anything if the last piece was held
    if self.last_piece_held then
        audio_manager.play(audio_manager.NO_HOLD)
        return
    end

    -- Don't do anything if piece is nil
    if self.piece == nil then
        audio_manager.play(audio_manager.NO_HOLD)
        return
    end

    audio_manager.play(audio_manager.HOLD)

    if self.held_piece == nil then
        -- No piece in hold yet
        self.held_piece = self.piece
        self.piece = nil
    else
        -- A piece is already in hold, swap
        local temp = self.piece
        self.piece = self.held_piece
        self.piece:set_matrix(self.matrix)
        self.piece:set_position(1, 4)
        self.held_piece = temp
    end

    self.held_piece:set_position(0, 0)
    self:update()
    self.last_piece_held = true
end

--------------------------------------------------------------------------------
-- Checks whether the game end condition "Block Out" has been met. The game is
-- over if the piece occupies the same space as some non-empty part of the
-- matrix. This usually happens when a new piece is made.
-- @return true if a blockout condition is detected

function game:check_block_out()
    -- TODO: investigate this not working
    if self.piece == nil then return false end

    -- Check if game is already over
    if self.is_over then return false end

    -- Check every part of the piece
    for i, cell in ipairs(self.piece:get_locations()) do
        if cell.row > 0 then
            -- Check for Block Out condition
            if self.matrix:is_set(cell.row, cell.col) then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Checks whether the game end condition "Lock Out" has been met. This occurs
-- when a piece is locked down at least partially above the top of the Matrix.
-- @return true if a lockout condition is detected

function game:check_lock_out()
    if self.piece == nil then return false end

    -- Check if game is already over
    if self.is_over then return false end

    -- Check every part of the piece
    for i, cell in ipairs(self.piece:get_locations()) do
        -- Check for Lock Out condition
        if cell.row < 0 then return true end
    end

    return false
end

--------------------------------------------------------------------------------
-- Ends the current game.

function game:over()
    self.is_over = true
    self.piece = nil
    self.ghost = nil
    audio_manager.THEME_A:stop()
    audio_manager.set_muted(false)
end

--------------------------------------------------------------------------------
-- Clears all game states and sets them to their initial values.

function game:reset()
    self.goal = 5
    self.level = 1
    self.score = 0
    self.matrix = matrix.new(20, 10)
    self.is_over = false
    self.paused = false
    self.held_piece = nil
    self.last_piece_held = false
    self.next_piece = nil
    self.lock_on_next_tick = false
    self.tetris_combo = 0
    self.piece = nil
end

--------------------------------------------------------------------------------
-- Starts the game from scratch.

function game:start()
    self:reset()
    -- TODO: countdown
    self.next_piece = self:generate_piece(nil, 0, 0)
    local center_col = math.floor(self.matrix.cols / 2)
    self.piece = self:generate_piece(self.matrix, 0, center_col)
    self:update_ghost()
    audio_manager.play(audio_manager.THEME_A, true)
end

--------------------------------------------------------------------------------
-- Generate a new random piece at the specified location.
-- @param m the matrix into which the piece will be placed
-- @param row the row to set the center of the piece
-- @param col the column to set the center of the piece

function game:generate_piece(m, row, col)
    local n = self.randomizer:next()
    if n == 0 then return shapes.Z.new(row, col, m)
    elseif n == 1 then return shapes.O.new(row, col, m)
    elseif n == 2 then return shapes.J.new(row, col, m)
    elseif n == 3 then return shapes.T.new(row, col, m)
    elseif n == 4 then return shapes.S.new(row, col, m)
    elseif n == 5 then return shapes.L.new(row, col, m)
    else return shapes.I.new(row, col, m)
    end
end

--------------------------------------------------------------------------------
-- Runs all testing conditions and creates a new piece if need be.

function game:update()
    if self.piece == nil and self.next_piece ~= nil then
        self.piece = self.next_piece
        self.piece:set_matrix(self.matrix)
        self.piece:set_position(0, math.floor(self.matrix.cols / 2))
        self.next_piece = self:generate_piece(nil, 0, 0)
        self.last_piece_held = false
        if self:check_block_out() then game:over() end
    end
    self:update_ghost()

    local num_lines_cleared = self.matrix:check_rows()
    local points_awarded = 0
    local line_clears_awarded = 0

    if num_lines_cleared > 0 then
        local back_to_back = num_lines_cleared == 4 and self.tetris_combo > 0

        if num_lines_cleared == 4 then
            self.tetris_combo = self.tetris_combo + 1
        else self.tetris_combo = 0 end

        if num_lines_cleared == 1 then
            audio_manager.play(audio_manager.LINE_CLEAR_1)
            points_awarded = 100 * self.level
            line_clears_awarded = 1
        elseif num_lines_cleared == 2 then
            audio_manager.play(audio_manager.LINE_CLEAR_2)
            points_awarded = 300 * self.level
            line_clears_awarded = 3
        elseif num_lines_cleared == 3 then
            audio_manager.play(audio_manager.LINE_CLEAR_3)
            points_awarded = 500 * self.level
            line_clears_awarded = 5
        elseif num_lines_cleared == 4 then
            audio_manager.play(audio_manager.LINE_CLEAR_4)
            points_awarded = 800 * self.level
            line_clears_awarded = 8
        end

        if back_to_back then
            -- audio_manager.BACK_TO_BACK.play()
            line_clears_awarded = 2 * line_clears_awarded
            local combo_points = 50 * self.level * (self.tetris_combo - 1)
            points_awarded = 2 * points_awarded + combo_points
        end

        self.score = self.score + points_awarded

        -- Assign high score if current is best
        if self.score > self.high_score then self.high_score = self.score end

        if self.goal - line_clears_awarded <= 0 then
            -- audio_manager.LEVEL_UP.play()
            self.level = self.level + 1
            self.goal = 5 * self.level
        else
            self.goal = self.goal - line_clears_awarded
        end
    end
end

--------------------------------------------------------------------------------
-- Creates a new ghost piece and places it at the proper location.

function game:update_ghost()
    if self.piece ~= nil then
        -- Attempt to recreate the ghost
        self.ghost = self.piece:make_ghost()

        -- If successfully created the ghost:
        if self.ghost ~= nil then
            -- Drop ghost to bottom
            while self.ghost:can_move(direction.DOWN) do
                self.ghost:move(direction.DOWN)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Draws the current state of the game.

function game:draw(x, y)
    self.matrix:set_position(x + 10, y + 10)
    self.matrix:draw()
    if self.ghost ~= nil then self.ghost:draw() end
    if self.piece ~= nil then self.piece:draw() end
end

return game
