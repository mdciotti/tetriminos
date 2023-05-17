local matrix = require("matrix")
local tetrimino = require("tetrimino")
local color_scheme = require("gui/color_scheme")
local info_field = require("gui/info_field")

local tetrimino_field = {}
tetrimino_field.__index = tetrimino_field
setmetatable(tetrimino_field, info_field)

function tetrimino_field.new(title, height)
	local self = info_field.new(title, height)
	setmetatable(self, tetrimino_field)
	self.super = info_field

	self.matrix = matrix.new(4, 4)
	self.tetrimino = nil

	return self
end

function tetrimino_field:set_tetrimino(tetrimino)
	if tetrimino ~= nil then
		self.tetrimino = tetrimino
		self.tetrimino:set_matrix(self.matrix)
	end
end

function tetrimino_field:draw(x, y)
	self.super.draw(self, x, y)

	-- self.matrix:set_position(x, y)

	-- Draw tetrimino
	if self.tetrimino ~= nil then
        -- Calculate offset to center piece based on its dimensions
        local width, height = self.tetrimino:get_dimension()
        local ox, oy = self.tetrimino:get_central_offset()
        local offset_x = ox + (self.width - width) / 2
        local offset_y = oy + (self.height - height) / 2

        -- Fake centering by translating the underlying matrix
        self.matrix:set_position(x + offset_x, y + offset_y)
        self.tetrimino:draw()
	end
end

return tetrimino_field
