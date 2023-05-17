--------------------------------------------------------------------------------
-- Abstracts the concept of a screen so that multiple screens can be defined and
-- swapped, each containing their own state and update/draw methods.

local screen = {}
screen.__index = screen

function screen.new(d, type)
	local self = {}
	setmetatable(self, screen)
	
	self.display = d
	self.type = type
	self.hotspots = {}

	return self
end

function screen:add_hotspot(spot)
	if spot ~= nil then
		table.insert(self.hotspots, spot)
	end
end

function screen:mouse_move(x, y, dx, dy, screen_width, screen_height)
	local w, h = screen_width, screen_height

	for i, spot in ipairs(self.hotspots) do
		local in_before = spot:test(x - dx, y - dy, w, h)
		local in_after = spot:test(x, y, w, h)
		if not in_before and in_after and spot.on_mouseenter ~= nil then
			spot:on_mouseenter(x, y)
		elseif in_before and not in_after and spot.on_mouseexit ~= nil then
			spot:on_mouseexit(x, y)
		elseif in_after and spot.on_mousemove ~= nil then
			spot:on_mousemove(x, y)
		end
	end
end

function screen:mouse_click(x, y, screen_width, screen_height)
	for i, spot in ipairs(self.hotspots) do
		if spot.on_click ~= nil then
			if spot:test(x, y, screen_width, screen_height) then
				spot:on_click(x, y)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Unload is called after the screen has fully left the view (if transitioning
-- to a new screen) or immediately if a new screen is set explicitly. Subclasses
-- of Screen are expected but not required to override this method with their
-- own unloading code.

function screen:load() end
function screen:unload() end

function screen:key_pressed(key) end
function screen:key_released(key) end
function screen:text_input(text) end
function screen:draw(screen_width, screen_height) end
function screen:draw_debug(screen_width, screen_height)
	love.graphics.setColor(255, 0, 0)
	for name, box in pairs(self.hotspots) do
		box:draw(screen_width, screen_height)
	end
end

function screen:update() end

return screen
