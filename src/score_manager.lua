
local score_manager = {}

local scores = {}
local FILE_NAME = "scores.dat"
local file = nil

function score_manager.init()
	file = love.filesystem.newFile(FILE_NAME)
	
	-- Read from file
	if love.filesystem.exists(FILE_NAME) then
		for line in love.filesystem.lines(FILE_NAME) do
			local p = string.match(line, "^([%w ]+)\t")
			local s = tonumber(string.match(line, "\t(%d+)$"))
			if p ~= nil and s ~= nil then
				table.insert(scores, { player = p, score = s })
			end
		end
	end
end

function trim(str)
	local result = string.gsub(str, "^%s+", "")
	result = string.gsub(result, "%s+$", "")
	return result
end

function score_manager.add(player, score)
	table.insert(scores, { player = trim(player), score = score })
	-- Sort descending
	table.sort(scores, function (a, b)
		return a.score > b.score
	end)
	score_manager.save()
end

function score_manager.get_num_scores()
	return #scores
end

function score_manager.get(i)
	return scores[i]
end

function score_manager.get_top_score()
	if #scores == 0 then return nil
	else return scores[1] end
end

function score_manager.save()
	local contents = ""
	for i, pscore in ipairs(scores) do
		local record = pscore.player .. '\t' .. pscore.score .. '\n'
		contents = contents .. record
	end

	love.filesystem.write(FILE_NAME, contents)
end

return score_manager
