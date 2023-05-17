local hotspot = {}
hotspot.__index = hotspot

function hotspot.new(x, y, w, h, ax, ay)
	local self = {}
	setmetatable(self, hotspot)

	self.x = x
	self.y = y
	self.width = w
	self.height = h

	if ax == 'top' then self.ax = 0
	elseif ax == 'center' then self.ax = 0.5
	elseif ax == 'bottom' then self.ax = 1
	elseif ax == nil then self.ax = 0
	else self.ax = ax
	end

	if ay == 'top' then self.ay = 0
	elseif ay == 'center' then self.ay = 0.5
	elseif ay == 'bottom' then self.ay = 1
	elseif ay == nil then self.ay = 0
	else self.ay = ay
	end

	return self
end

function hotspot:on(event, fn)
	if fn ~= nil then
		if event == 'click' then
			self.on_click = fn
		elseif event == 'mouseenter' then
			self.on_mouseenter = fn
		elseif event == 'mouseexit' then
			self.on_mouseexit = fn
		elseif event == 'mousemove' then
			self.on_mousemove = fn
		end
	end
end

function hotspot:test(x, y, screen_width, screen_height)
	local left = self.x + self.ax * screen_width
	local top = self.y + self.ay * screen_height
	if top <= y and y < top + self.height then
		if left <= x and x < left + self.width then
			return true
		end
	end
	return false
end

function hotspot:draw(screen_width, screen_height)
	local x = self.x + self.ax * screen_width
	local y = self.y + self.ay * screen_height
	love.graphics.rectangle('line', x, y, self.width, self.height)
end

return hotspot
