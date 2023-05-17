
local font_manager = {}

local Dosis = {}
Dosis.bold = "resources/dosis/Dosis-Bold.otf"
Dosis.regular = "resources/dosis/Dosis-Regular.otf"
local scale = 1

function font_manager.init(s)
	scale = s
	font_manager.menu_title = love.graphics.newFont(Dosis.bold, 48 * s)
	font_manager.menu_option = love.graphics.newFont(Dosis.regular, 30 * s)
	font_manager.mino = love.graphics.newFont(Dosis.regular, 16 * s)
	font_manager.info_field_title = love.graphics.newFont(Dosis.bold, 20 * s)
	font_manager.text_field = love.graphics.newFont(Dosis.regular, 32 * s)
	font_manager.modal_title = love.graphics.newFont(Dosis.bold, 32 * s)
	font_manager.modal_body = love.graphics.newFont(Dosis.regular, 20 * s)
	font_manager.screen_title = love.graphics.newFont(Dosis.bold, 36 * s)
	font_manager.score_list = love.graphics.newFont(Dosis.regular, 30 * s)
	font_manager.no_results = love.graphics.newFont(Dosis.regular, 30 * s)
	font_manager.list_item = love.graphics.newFont(Dosis.regular, 30 * s)
end

function font_manager.width(str)
	return love.graphics.getFont():getWidth(str) / scale
end

return font_manager
