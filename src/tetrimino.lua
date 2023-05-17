local mino = require("mino")

local tetrimino = {}
tetrimino.__index = tetrimino

tetrimino.CELL_COUNT = 4
local CENTER = 2

function tetrimino.new(mat)
	local self = {}
    setmetatable(self, tetrimino)

    self.able_to_move = true
    self.is_ghost = false
    self.matrix = mat
    self.cells = {}
    return self
end

function tetrimino:clone()
	local clone = tetrimino.new()

	-- Copy member values
	clone.able_to_move = self.able_to_move
	clone.is_ghost = self.is_ghost
	clone.matrix = self.matrix

	-- Clone cells one by one
	clone.cells = {}
	for i, cell in ipairs(self.cells) do
		clone.cells[i] = cell:clone()
	end

	return clone
end

--------------------------------------------------------------------------------
-- Sets the Matrix that this Tetrimino belongs to.
-- @param mat the new Matrix

function tetrimino:set_matrix(mat)
	self.matrix = mat
	for i, cell in ipairs(self.cells) do
		cell.matrix = mat
	end
end

--------------------------------------------------------------------------------
-- Sets the position of this Tetrimino by moving all its cells from their
-- current location to the desired location. This follows the convention that
-- the (row, col) pair specifies the CENTER cell.
-- @param row the new row for the CENTER cell
-- @param col the new column for the CENTER cell

function tetrimino:set_position(row, col)
	local center_row = self.cells[CENTER].row
	local center_col = self.cells[CENTER].col

	for i, cell in ipairs(self.cells) do
		local dr = cell.row - center_row
		local dc = cell.col - center_col
		-- cell:set_position(row + dr, col + dc)
		cell.row = row + dr
		cell.col = col + dc
	end
end

--------------------------------------------------------------------------------
-- Moves the Tetrimino if possible, otherwise freeze the piece if it cannot
-- move down anymore.
-- @param dir the direction to move

function tetrimino:move(dir)
	for i, cell in ipairs(self.cells) do cell:move(dir) end
end

--------------------------------------------------------------------------------
-- Gets all the (row, col) Matrix coordinates occupied by this
-- Tetrimino's cells.
-- @return an array of (row, col) points

function tetrimino:get_locations()
	local points = {}
	for i, cell in ipairs(self.cells) do
		points[i] = { row = cell.row, col = cell.col }
	end
	return points
end

--------------------------------------------------------------------------------
-- Gets the color of this tetrimino.
-- @return the color index

function tetrimino:get_color()
	return cells[1]:get_color()
end

--------------------------------------------------------------------------------
-- Checks if this Tetrimino can move one block in the specified direction by
-- querying all of its constituent cells.
-- @param direction the Direction to check for movement capability
-- @return true if this Tetrimino can move in the given direction

function tetrimino:can_move(dir)
	if not self.able_to_move then return false end

	-- Each square must be able to move in that direction
	local answer = true
	for i, cell in ipairs(self.cells) do
		answer = answer and cell:can_move(dir)
	end
	return answer
end

--------------------------------------------------------------------------------
-- Checks whether this Tetrimino can rotate by querying all of its constituent
-- cells.
-- @return true if this Tetrimino can rotate

function tetrimino:can_rotate()
	if not self.able_to_move then return false end

	local center_row = self.cells[CENTER].row
	local center_col = self.cells[CENTER].col

	if self.debug then
		print(string.format("rotating about (%d, %d)", center_row, center_col))
	end

	-- Each square must be able to rotate
	local answer = true
	for i, cell in ipairs(self.cells) do
		if i ~= CENTER then
			answer = answer and cell:can_rotate_about(center_row, center_col)
		end
	end

	return answer
end

--------------------------------------------------------------------------------
-- Rotate this Tetrimino in the direction specified by telling all of its
-- constituent cells to rotate about the central cell.

function tetrimino:rotate()
	local center_row = self.cells[CENTER].row
	local center_col = self.cells[CENTER].col
	-- local center = self.cells[CENTER].coords
	
	for i, cell in ipairs(self.cells) do
		if i ~= CENTER then
			cell:rotate_about(center_row, center_col)
		end
	end
end

--------------------------------------------------------------------------------
-- Creates a ghost version of this Tetrimino in the same position and
-- orientation as this Tetrimino.

function tetrimino:make_ghost()
	local ghost = self:clone()
	ghost.is_ghost = true

	-- ghost.cells = {}
	-- for i, cell in ipairs(self.cells) do
	-- 	ghost.cells[i] = mino.new(self.matrix, cell.row, cell.col, 0, true)
	-- end
	return ghost
end

--------------------------------------------------------------------------------
-- Locks down this Tetrimino's cells at their current location in the Matrix.

function tetrimino:lock_down()
	-- Tell all the minos to lock down
	for i, cell in ipairs(self.cells) do
		cell:lock_down()
	end
end

--------------------------------------------------------------------------------
-- Calculate the height and width of this tetrimino in its current orientation.

function tetrimino:get_dimension()
	local min_col, min_row = 0, 0
	local max_col, max_row = 0, 0

    -- Find maximum and minimum column and row of this piece's cells
	for i, cell in ipairs(self.cells) do
		min_row = math.min(min_row, cell.row)
		min_col = math.min(min_col, cell.col)
		max_row = math.max(max_row, cell.row)
		max_col = math.max(max_col, cell.col)
	end

	-- Calculate width and height
	local width = (max_col - min_col + 1) * mino.WIDTH
	local height = (max_row - min_row + 1) * mino.HEIGHT

	return width, height
end

--------------------------------------------------------------------------------
-- Calculate the pixel offset from the top left of the central mino to the top
-- left of the bounding box for this tetrimino in its current orientation.

function tetrimino:get_central_offset()
	local min_col, min_row = 0, 0

    -- Find maximum and minimum column and row of this piece's cells
	for i, cell in ipairs(self.cells) do
		min_row = math.min(min_row, cell.row)
		min_col = math.min(min_col, cell.col)
	end

	local x = (self.cells[CENTER].col - min_col) * mino.WIDTH
	local y = (self.cells[CENTER].row - min_row) * mino.HEIGHT

	return x, y
end

--------------------------------------------------------------------------------
-- Draws the Tetrimino on the given Graphics context.

function tetrimino:draw()
	for i, cell in ipairs(self.cells) do
		if self.debug then
			cell:draw(self.is_ghost, i)
		else
			cell:draw(self.is_ghost)
		end
	end
end

return tetrimino
