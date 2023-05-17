
local audio_manager = {}

audio_manager.music_volume = 1.0
audio_manager.sound_volume = 1.0
audio_manager.muted = false

function audio_manager.init()
	audio_manager.THEME_A = love.audio.newSource("resources/music/theme_a.wav", "stream")
	audio_manager.PIECE_MOVE = love.audio.newSource("resources/sfx/tap.wav", "static")
	audio_manager.LINE_CLEAR_1 = love.audio.newSource("resources/sfx/pop.wav", "static")
	audio_manager.LINE_CLEAR_2 = love.audio.newSource("resources/sfx/pop2.wav", "static")
	audio_manager.LINE_CLEAR_3 = love.audio.newSource("resources/sfx/pop3.wav", "static")
	audio_manager.LINE_CLEAR_4 = love.audio.newSource("resources/sfx/pop4.wav", "static")
	audio_manager.HOLD = love.audio.newSource("resources/sfx/scuff.wav", "static")
	audio_manager.NO_HOLD = love.audio.newSource("resources/sfx/dink.wav", "static")
	audio_manager.HARD_DROP = love.audio.newSource("resources/sfx/thump.wav", "static")
end

function audio_manager.stop_all()
	love.audio.stop()
end

function audio_manager.play(source, loop)
	if source:getType() == "stream" then
		source:setLooping(loop)
		source:setVolume(0.5 * audio_manager.music_volume)
		source:play()
	else
		source:setVolume(audio_manager.sound_volume)
		source:play()
	end
end

function audio_manager.set_muted(muted)
	audio_manager.muted = muted
	if audio_manager.muted then
		love.audio.setVolume(0.0)
	else
		love.audio.setVolume(1.0)
	end
end

function audio_manager.toggle_mute()
	audio_manager.set_muted(not audio_manager.muted)
end

function audio_manager.set_music_volume(vol)
	audio_manager.music_volume = math.max(0.0, math.min(vol, 1.0))
end

function audio_manager.set_sound_volume(vol)
	audio_manager.sound_volume = math.max(0.0, math.min(vol, 1.0))
end

return audio_manager
