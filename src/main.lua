local display = require("display")
local score_manager = require("score_manager")
local audio_manager = require("audio_manager")
local timer = require("util/timer")

function love.conf(t)
    t.version = '0.10.1'
	t.identity = "tetriminos"
	t.modules.physics = false
	t.modules.joystick = false
	t.modules.video = false
end

function love.load()
	score_manager.init()
	audio_manager.init()
	love.math.setRandomSeed(love.timer.getTime())
	love.keyboard.setKeyRepeat(true)
	display.init()
end

function love.keypressed(key)
	display.key_pressed(key)
end

function love.keyreleased(key)
	display.key_released(key)
end

function love.textinput(text)
	display.text_input(text)
end

function love.mousemoved(x, y, dx, dy)
	display.mouse_moved(x, y, dx, dy)
end
-- function love.mousepressed() end
function love.mousereleased(x, y, button, is_touch)
	display.mouse_released(x, y, button)
end

function love.resize(w, h)
	display.resize(w, h)
end

function love.update()
	display.update()
	timer.update()

	-- if display.transition ~= nil then
	-- 	display.transition:update()
	-- end
end

function love.draw()
	display.draw()
end
