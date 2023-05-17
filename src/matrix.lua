local color_scheme = require("gui/color_scheme")
local mino = require("mino")

local ndarray = require("util/ndarray")

local matrix = {}
matrix.__index = matrix

local EMPTY = nil
local PADDING = 10

--------------------------------------------------------------------------------
-- Creates a new matrix object.

function matrix.new(rows, cols)
	local self = {}
	setmetatable(self, matrix)
	self.rows = rows
	self.cols = cols
	self.board = ndarray.new(cols, rows)
	self.board:init(function (i, j)
		return mino.new(self, j, i, EMPTY, false)
	end)

	-- self.board = {}
	-- for j = 0, self.rows do
	-- 	board[j] = {}
	-- 	for i = 0, self.cols do
	-- 		board[j][i] = mino.new(self, j, i, EMPTY, false)
	-- 	end
	-- end

	self.left = 100
	self.top = 50
	return self
end

function matrix:set_position(left, top)
	self.top = top
	self.left = left
end

function matrix:get_position()
	return self.left, self.top
end

--------------------------------------------------------------------------------
-- Returns true if the location (row, col) on the matrix is occupied.

function matrix:is_set(r, c)
	local i, j = c, r
	local cell = self.board:get(i, j)
	if cell then
		return cell.color ~= EMPTY
	end
	return true
end

--------------------------------------------------------------------------------
-- Sets the value of one cell in the matrix.

function matrix:set(r, c, val)
	local i, j = c, r
	self.board:get(i, j).color = val
end

--------------------------------------------------------------------------------
-- Checks for and clears all solid rows of cells. If a solid row is found and
-- cleared, all rows above it are moved down and the top row set to empty.
-- @return the number of full rows that were cleared

function matrix:check_rows()
	local num_rows_cleared = 0

	for row = 0, self.rows - 1 do
		for col = 0, self.cols - 1 do
			-- Move to next row if we come across an empty cell
			if not self:is_set(row, col) then break end

			-- A row is filled when row contains WIDTH cells
			if col == self.cols - 1 then
				clear_row(self, row)
				num_rows_cleared = num_rows_cleared + 1
			end
		end
	end

	return num_rows_cleared
end

--------------------------------------------------------------------------------
-- Sets the cells in the given row to EMPTY and shifts the above rows down by
-- one.

function clear_row(self, row)
	if self.debug then
		print("clearing row " .. row)
	end

	for col = 0, self.cols - 1 do
		self.board:get(col, row).color = EMPTY
	end

	for r = row - 1, 0, -1 do
		for c = 0, self.cols - 1 do
			if self:is_set(r, c) then
				local i, j = c, r
				local color = self.board:get(i, j).color
				self.board:get(i, j).color = EMPTY
				self.board:get(i, j + 1).color = color
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Draws the matrix on the current graphics context.

function matrix:draw()
	-- Draw the matrix background
	love.graphics.setColor(color_scheme.BASE_00)
	love.graphics.rectangle('fill',
		self.left - PADDING, self.top - PADDING,
		self.cols * mino.WIDTH + 2 * PADDING,
		self.rows * mino.HEIGHT + 2 * PADDING)

	-- Draw all the cells in the matrix, skipping empty ones
	for r = 0, self.rows - 1 do
		for c = 0, self.cols - 1 do
			local i, j = c, r
			local cell = self.board:get(i, j)
			if cell.color ~= EMPTY then
				cell:draw(false)
			elseif self.debug and r == 0 then
				cell:draw(true, c)
			elseif self.debug and c == 0 then
				cell:draw(true, r)
			elseif self.debug then
				cell:draw(true)
			end
		end
	end
end

return matrix
