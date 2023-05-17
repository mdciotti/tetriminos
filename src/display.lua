local font_manager = require("font_manager")
local screen_type = require("screens/screen_type")
local menu_screen = require("screens/menu_screen")
local game_screen = require("screens/game_screen")
local transition_screen = require("screens/transition_screen")
local top_score_screen = require("screens/top_score_screen")
local option_screen = require("screens/option_screen")
-- local about_screen = require("screens/about_screen")

local display = {}

local MIN_WIDTH = 500
local MIN_HEIGHT = 420
local screens = {}

function display.init()
	local display = display
	setmetatable(display, display)

	display.current_screen = nil
	display.screens = {}

	display.resize(MIN_WIDTH * 2, MIN_HEIGHT * 2)
	display.is_fullscreen = false

	-- Setup window
	love.window.setTitle("Tetriminos")
	love.window.setMode(display.width, display.height, {
		resizable = true,
		fullscreen = false,
		centered = true,
		minwidth = MIN_WIDTH,
		minheight = MIN_HEIGHT
	})

	-- Create screens
	display.screens[screen_type.MAIN_MENU] = menu_screen.new(display)
	display.screens[screen_type.GAME] = game_screen.new(display)
	display.screens[screen_type.TOP_SCORES] = top_score_screen.new(display)
	display.screens[screen_type.OPTIONS] = option_screen.new(display)
	-- display.screens[screen_type.ABOUT] = about_screen.new(display)
	display.set_screen(screen_type.MAIN_MENU)

	-- Set up transition screen for later
	display.transition = transition_screen.new(display)

	-- Set up cursor
	display.cursor = { x = 0, y = 0 }

	display.debug = false
end

function display.transition_screen(s, dir)
	local screen = display.screens[s]
	if screen ~= nil then
		display.transition.current = display.current_screen
		display.transition.next = screen
		display.transition.direction = dir
		display.transition:load()
		display.current_screen = display.transition
		-- display.update()
	end
end

function display.set_screen(s)
	local screen = display.screens[s]

	if display.debug then
		print("setting screen " .. s)
	end

	if screen ~= nil then
		if display.current_screen ~= nil then
			display.current_screen:unload()
		end
		display.current_screen = screen
		display.current_screen:load()
		display.update()
	end
end

function display.key_pressed(key)
	display.current_screen:key_pressed(key)
end

function display.key_released(key)
	display.current_screen:key_released(key)
end

function display.text_input(text)
	display.current_screen:text_input(text)
end

function display.mouse_moved(x, y, dx, dy)
	display.cursor.x = x / display.scale
	display.cursor.y = y / display.scale
	local scaled_width = display.width / display.scale
	local scaled_height = display.height / display.scale
	display.current_screen:mouse_move(
		display.cursor.x, display.cursor.y,
		dx / display.scale, dy / display.scale,
		scaled_width, scaled_height)
end

function display.mouse_released(x, y, button)
	if button == 1 then
		-- Primary button was released
		display.cursor.x = x / display.scale
		display.cursor.y = y / display.scale
		local scaled_width = display.width / display.scale
		local scaled_height = display.height / display.scale
		display.current_screen:mouse_click(display.cursor.x, display.cursor.y,
			scaled_width, scaled_height)
	end
end

function display.set_fullscreen(fs)
	display.is_fullscreen = fs
	love.window.setFullscreen(fs)
end

function display.toggle_fullscreen()
	display.set_fullscreen(not display.is_fullscreen)
end

function display.update()
	display.current_screen:update()
	display.render()
end

function display.resize(w, h)
	display.screen_buffer = love.graphics.newCanvas(w, h, "normal", 2)
	display.width = w
	display.height = h

	local sw = math.floor(w / MIN_WIDTH)
	local sh = math.floor(h / MIN_HEIGHT)
	display.set_scale(math.max(1, math.min(sw, sh)))
end

function display.set_scale(scale)
	local old_scale = display.scale

	if scale ~= old_scale then
		display.scale = scale
		font_manager.init(display.scale)
	end

	display.render()
end

function display.render()
	-- Draw to a screen buffer only on significant updates, not every frame
	love.graphics.push()
	love.graphics.setCanvas(display.screen_buffer)
	love.graphics.clear()
	love.graphics.scale(display.scale)

	-- Draw current screen
	if display.current_screen ~= nil then
		local scaled_width = display.width / display.scale
		local scaled_height = display.height / display.scale
		display.current_screen:draw(scaled_width, scaled_height)
		-- display.current_screen:draw_debug(scaled_width, scaled_height)
	end

	-- Draw mouse cursor
	if display.cursor ~= nil then
		-- love.graphics.setColor(255, 0, 0, 255)
		-- love.graphics.circle('fill', display.cursor.x, display.cursor.y, 10, 32)
	end

	love.graphics.setCanvas()
	love.graphics.pop()
end

function display.draw()
	-- Draw pre-rendered buffer (at 60fps)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(display.screen_buffer)
end

--------------------------------------------------------------------------------
-- Define new text-drawing function that handles scaling better.
-- @param txt the text to draw
-- @param x the x-coordinate of where to draw the text
-- @param y the y-coordinate of where to draw the text
-- @param align the alignment of the text (left, center, right)

function love.graphics.print2(txt, x, y, align)
	love.graphics.push()
	local font = love.graphics.getFont()

	local offset
	if align == 'center' then
		offset = -font_manager.width(txt) / 2
	elseif align == 'right' then
		offset = -font_manager.width(txt)
	else -- align == 'left'
		offset = 0
	end

	love.graphics.translate(math.floor(x + offset), y)
	love.graphics.scale(1 / display.scale)
	love.graphics.print(txt)
	love.graphics.pop()
	-- love.graphics.print(txt, x, y)
end

return display
