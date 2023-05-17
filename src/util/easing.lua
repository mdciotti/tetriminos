local easing = {}

easing.exponential = {}

function easing.exponential.ease_in(t)
	return 2 ^ (10.0 * (t - 1.0))
end

function easing.exponential.ease_out(t)
	return 1.0 - 2 ^ (-10.0 * t)
end

return easing
