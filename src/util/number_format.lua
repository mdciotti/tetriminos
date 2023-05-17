local number_format = {}
number_format.__index = number_format

function number_format.new(format)
	local self = {}
	setmetatable(self, number_format)

	self.decimal = '.'
	self.grouping = ','
	self.group_size = 3

	return self
end

--------------------------------------------------------------------------------
-- Retrieves the next random value.

function number_format:format(num)
	-- TODO: handle floating point numbers
	-- TODO: handle negative numbers
	local str = string.format("%d", num)
	local result = ""
	local n = string.len(str)
	local count = 0

	for i = n, 1, -1 do
		local c = str:sub(i, i)
		result = c .. result
		count = count + 1
		local should_group = count % self.group_size == 0
		if should_group and i ~= 1 then
			result = self.grouping .. result
		end
	end

	return result
end

return number_format
