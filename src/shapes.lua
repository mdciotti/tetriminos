local tetrimino = require("tetrimino")
local mino = require("mino")
local color_scheme = require("gui/color_scheme")

local shapes = {}

--------------------------------------------------------------------------------
shapes.I = {}
shapes.I.__index = shapes.I
setmetatable(shapes.I, tetrimino)

function shapes.I.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.I)

    local color = color_scheme.BASE_0C
    self.cells[1] = mino.new(m, r, c - 1, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r, c + 1, color, true)
    self.cells[4] = mino.new(m, r, c + 2, color, true)

    return self
end

--------------------------------------------------------------------------------
shapes.S = {}
shapes.S.__index = shapes.S
setmetatable(shapes.S, tetrimino)

function shapes.S.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.S)

    local color = color_scheme.BASE_0B
    self.cells[1] = mino.new(m, r, c + 1, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r + 1, c, color, true)
    self.cells[4] = mino.new(m, r + 1, c - 1, color, true)

    return self
end

--------------------------------------------------------------------------------
shapes.Z = {}
shapes.Z.__index = shapes.Z
setmetatable(shapes.Z, tetrimino)

function shapes.Z.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.Z)

    local color = color_scheme.BASE_08
    self.cells[1] = mino.new(m, r, c - 1, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r + 1, c, color, true)
    self.cells[4] = mino.new(m, r + 1, c + 1, color, true)

    return self
end

--------------------------------------------------------------------------------
shapes.J = {}
shapes.J.__index = shapes.J
setmetatable(shapes.J, tetrimino)

function shapes.J.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.J)

    local color = color_scheme.BASE_0D
    self.cells[1] = mino.new(m, r - 1, c, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r + 1, c, color, true)
    self.cells[4] = mino.new(m, r + 1, c - 1, color, true)

    return self
end

--------------------------------------------------------------------------------
shapes.L = {}
shapes.L.__index = shapes.L
setmetatable(shapes.L, tetrimino)

function shapes.L.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.L)
    print()

    local color = color_scheme.BASE_09
    self.cells[1] = mino.new(m, r - 1, c, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r + 1, c, color, true)
    self.cells[4] = mino.new(m, r + 1, c + 1, color, true)

    return self
end

--------------------------------------------------------------------------------
shapes.T = {}
shapes.T.__index = shapes.T
setmetatable(shapes.T, tetrimino)

function shapes.T.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.T)

    local color = color_scheme.BASE_0E
    self.cells[1] = mino.new(m, r, c - 1, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r, c + 1, color, true)
    self.cells[4] = mino.new(m, r + 1, c, color, true)

    return self
end

--------------------------------------------------------------------------------
shapes.O = {}
shapes.O.__index = shapes.O
setmetatable(shapes.O, tetrimino)

function shapes.O.new(r, c, m)
	local self = tetrimino.new(m)
    setmetatable(self, shapes.O)

    local color = color_scheme.BASE_0A
    self.cells[1] = mino.new(m, r, c - 1, color, true)
    self.cells[2] = mino.new(m, r, c, color, true)
    self.cells[3] = mino.new(m, r + 1, c - 1, color, true)
    self.cells[4] = mino.new(m, r + 1, c, color, true)

    return self
end

-- Overwrite the rotate method so that this shape does not rotate.
function shapes.O:can_rotate()
	-- prevent rotation
	return false
end

return shapes
