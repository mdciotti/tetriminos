module "tetriminos.screens"

local screen_type = {
	NONE = 0,
	MAIN_MENU = 1,
	GAME = 2,
	OPTIONS = 3,
	TOP_SCORES = 4,
	TRANSITION = 5,
	ABOUT = 6
}

return screen_type
