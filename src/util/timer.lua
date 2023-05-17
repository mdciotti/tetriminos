local timer = {}
timer.__index = timer

local timers = {}

-- TODO: handle non-looping timers
function timer.update()
	local now = love.timer.getTime()

	for i, t in ipairs(timers) do
		if t.running then
			if now - t.start_time >= t.duration then
				t.listener:on_tick()
				if t.loop then
					t.start_time = now
				else
					-- table.remove(timers, i)
				end
			end
		end
	end
end

function timer.new(duration, listener, loop)
	local self = {}
	setmetatable(self, timer)

	self.start_time = nil
	self.duration = duration
	self.listener = listener
	self.loop = loop
	self.running = false
	table.insert(timers, self)

	return self
end

function timer:start()
	self.running = true
	self.start_time = love.timer.getTime()
end

function timer:stop()
	self.running = false
	-- TODO: remove timer from list
	-- table.remove(timers, self)
end

function timer:set_delay(duration)
	self.duration = duration
end

return timer
