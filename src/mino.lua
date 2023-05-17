local direction = require("direction")
local color_scheme = require("gui/color_scheme")
local font_manager = require("font_manager")

local mino = {}
mino.__index = mino

-- Dimensions of a Mino in pixels
mino.WIDTH = 20
mino.HEIGHT = 20

--------------------------------------------------------------------------------
-- Creates a new square.
-- @param m the Matrix for this Mino
-- @param r the row of this Mino in the Matrix
-- @param c the column of this Mino in the Matrix
-- @param color the Color of this Mino
-- @param mobile true if this Mino can move

function mino.new(m, r, c, color, mobile)
	local self = {}
    setmetatable(self, mino)
    self.able_to_move = mobile
    self.matrix = m
    self.row = r
    self.col = c
    self.color = color
    return self
end

function mino:clone()
	return mino.new(self.matrix, self.row, self.col, self.color, self.able_to_move)
end

--------------------------------------------------------------------------------
-- Check whether this Mino can move one spot in a particular direction.
-- @param dir the Direction to test for possible move
-- @return true if the Mino can move

function mino:can_move(dir)
	if not self.able_to_move then return false end

	local r, c = self.row, self.col

	if dir == direction.DOWN then r = self.row + 1
	elseif dir == direction.LEFT then c = self.col - 1
	elseif dir == direction.RIGHT then c = self.col + 1
	end

	return self:can_move_to(r, c)
end

--------------------------------------------------------------------------------
-- Moves this square in the given direction if possible. The square will not
-- move if the direction is blocked, or if the square is unable to move. If it
-- attempts to move DOWN and it can't, the square is frozen and cannot move
-- anymore.
-- @param dir the direciton to move

function mino:move(dir)
	if self:can_move(dir) then
		if dir == direction.DOWN then self.row = self.row + 1
		elseif dir == direction.LEFT then self.col = self.col - 1
		elseif dir == direction.RIGHT then self.col = self.col + 1
		end
	end
end

--------------------------------------------------------------------------------
-- Checks if this Mino can be moved to an arbitrary location on its matrix.
-- @param r the row in the matrix to check
-- @param c the column in the matrix to check
-- @return true if it can be moved to that location

function mino:can_move_to(r, c)
	local in_row_range = 0 <= r and r < self.matrix.rows
	local in_col_range = 0 <= c and c < self.matrix.cols

	if in_row_range and in_col_range then
		return not self.matrix:is_set(r, c)
	elseif r < 0 and in_col_range then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------------
-- Gives the direction to move next when in the process of rotating a piece.
-- The center here is defined as the central cell in a Tetrimino, and therefore
-- all cells rotate about that central cell as if it were the center of the
-- diagram below. Works in a clockwise fashion.
-- 
-- > > > > > > v
-- ^ > > > > v v
-- ^ ^ > > v v v
-- ^ ^ ^   v v v
-- ^ ^ ^ < < v v
-- ^ ^ < < < < v
-- ^ < < < < < <
-- 
-- @param rx the x radius of the current location
-- @param ry the y radius of the current location
-- @return the direction the square should move

function get_dir(rx, ry)
	local dir = direction.NONE
	if rx == 0 and ry == 0 then dir = direction.NONE
	elseif rx >= ry and ry < -rx then dir = direction.RIGHT
	elseif ry > -rx and rx <= ry then dir = direction.LEFT
	elseif ry > rx and rx <= -ry then dir = direction.UP
	elseif rx >= -rx and ry < rx then dir = direction.DOWN
	end
	return dir
end

--------------------------------------------------------------------------------
-- Check whether this Mino can rotate about the given center. This algorithm
-- assumes that each Mino in a Tetrimino must move in a rectilinear manner and
-- pass through all intermediate cells to the destination. As long as nothing
-- obstructs the Mino's path, the rotation is valid.
-- @param center_row the square about which to test for possible rotation
-- @param center_col the square about which to test for possible rotation
-- @return true if the rotation is possible

function mino:can_rotate_about_old(center_row, center_col)
	if not self.able_to_move then return false end

	local move = true

	-- This square's coordinates relative to the center of rotation
	local rx, ry = self.col - center_col, self.row - center_row

	-- Calculate which "ring" of rotation this square is in
	local ring = math.max(math.abs(rx), math.abs(ry))

	-- Calculate the number of steps for a quarter rotation
	local quarter_rotation_steps = 2 * ring

	if self.debug then
		local debug_str = string.format("(%d, %d)", rx, ry)
	end

	-- Continue moving the square in the rotation direction unless a collision
	-- is detected or the destination is reached
	for i = 1, quarter_rotation_steps do
		-- Step in direction
		local dir = get_dir(rx, ry)
		if dir == direction.LEFT then rx = rx - 1
		elseif dir == direction.RIGHT then rx = rx + 1
		elseif dir == direction.DOWN then ry = ry + 1
		elseif dir == direction.UP then ry = ry - 1
		end

		if self.debug then
			debug_str = debug_str .. string.format(" -> (%d, %d)", rx, ry)
		end

		-- Check for collision
		if not self:can_move_to(center_row + ry, center_col + rx) then
			debug_str = debug_str .. string.format(" -> COLLISION (%d, %d)", center_row + ry, center_col + rx)
			move = false
			break
		end
	end

	if self.debug then
		print(debug_str)
	end

	return move
end

--------------------------------------------------------------------------------
-- Check whether this Mino can rotate about the given center, using only the
-- final rotation destination of this mino as verification for the rotation.

function mino:can_rotate_about(row, col)
	if not self.able_to_move then return false end

	local rx, ry = self.col - col, self.row - row
	rx, ry = -ry, rx
	return self:can_move_to(row + ry, col + rx)
end

--------------------------------------------------------------------------------
-- Rotates this square, whether or not it is possible.
-- @param center the location to rotate around

function mino:rotate_about(row, col)
	local rx, ry = self.col - col, self.row - row
	self.row, self.col = row + rx, col - ry
end

--------------------------------------------------------------------------------
-- Locks down this Mino at its current location in the Matrix.

function mino:lock_down()
	self.matrix:set(self.row, self.col, self.color)
end

--------------------------------------------------------------------------------
-- Draws this square on the given graphics context.

function mino:draw(is_ghost, label)
	-- Calculate the upper left (x,y) coordinate of this square
	local actual_x = self.matrix.left + self.col * mino.WIDTH
	local actual_y = self.matrix.top + self.row * mino.HEIGHT
	-- local margin = theme.tetrimino.default.margin

	-- local style

	-- if self.is_ghost then
	-- 	style = theme.tetrimino.ghost
	-- else
	-- 	style = theme.tetrimino.default
	-- end
	-- love.graphics.setLineWidth(style.border.width)

	if is_ghost then
		love.graphics.setColor(color_scheme.BASE_02)
		love.graphics.rectangle('fill', actual_x + 1, actual_y + 1, mino.WIDTH - 2, mino.HEIGHT - 2)
		love.graphics.setColor(color_scheme.BASE_00)
		love.graphics.rectangle('fill', actual_x + 3, actual_y + 3, mino.WIDTH - 6, mino.HEIGHT - 6)
	else
		love.graphics.setColor(self.color)
		love.graphics.rectangle('fill', actual_x + 1, actual_y + 1, mino.WIDTH - 2, mino.HEIGHT - 2)
	end

	if label then
		love.graphics.setFont(font_manager.mino)
		if is_ghost then
			love.graphics.setColor(color_scheme.BASE_02)
		else
			love.graphics.setColor(color_scheme.BASE_00)
		end
		local w = font_manager.mino:getWidth(label)
		love.graphics.print(label, actual_x + (20 - w) / 2, actual_y)
	end
end

return mino
