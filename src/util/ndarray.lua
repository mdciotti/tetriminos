local ndarray = {}
ndarray.__index = ndarray

function ndarray.new(cols, rows)
    local self = {}
    setmetatable(self, ndarray)
    self.cols = cols
    self.rows = rows
    self.data = {}
    return self
end

--------------------------------------------------------------------------------
-- Retrieves the element at the specified column and row
-- @param i the column index
-- @param j the row index
-- @return the value of the element

function ndarray:get(i, j)
    return self.data[j * self.cols + i]
end

--------------------------------------------------------------------------------
-- Sets the element at the specified column and row.
-- @param i the column index
-- @param j the row index
-- @param value the new value to set

function ndarray:set(i, j, value)
    self.data[j * self.cols + i] = value
end

--------------------------------------------------------------------------------
-- Iterate over all elements in this ndarray.
-- @param lambda the function to call on every element, receives parameters
--        column, row, and the value at that location.

function ndarray:each(lambda)
    for i = 0, self.cols - 1 do
        for j = 0, self.rows - 1 do
            lambda(i, j, self:get(i, j))
        end
    end
end

--------------------------------------------------------------------------------
-- Initialize the elements of this ndarray with a function.
-- @param lambda the initializing function, receives parameters column and row.

function ndarray:init(lambda)
    for i = 0, self.cols - 1 do
        for j = 0, self.rows - 1 do
            self:set(i, j, lambda(i, j))
        end
    end
end

return ndarray
