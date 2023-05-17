local randomizer = {}
randomizer.__index = randomizer

function randomizer.new(size)
	local self = {}
	setmetatable(self, randomizer)

	self.queue = {}
	self.queue_size = size
	self.last = 0

	return self
end

--------------------------------------------------------------------------------
-- Create a randomized array of integers 0 <= n < queueSize with no repeats.

function generate_queue(self)
	for i = 0, self.queue_size do
		local j = love.math.random(0, i)
		if j ~= i then self.queue[i] = self.queue[j] end
		self.queue[j] = i
	end
	self.last = self.queue_size - 1
end

--------------------------------------------------------------------------------
-- Retrieves the next random value.

function randomizer:next()
	self.last = self.last - 1

	-- Create a new queue when empty
	if self.last < 0 then generate_queue(self) end

	-- Return the last item in the queue
	return self.queue[self.last]
end

return randomizer
