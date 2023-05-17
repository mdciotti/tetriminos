
function main()
	print("Testing number_format.lua")

	local nf = number_format.new()
	assert(nf:format(0), "0")
	assert(nf:format(1), "1")
	assert(nf:format(12), "12")
	assert(nf:format(123), "123")
	assert(nf:format(1234), "1,234")
	assert(nf:format(12345), "12,345")
	assert(nf:format(123456), "123,456")
	assert(nf:format(1234567), "1,234,567")
	assert(nf:format(12345678), "12,345,678")
	assert(nf:format(123456789), "123,456,789")
	assert(nf:format(1234567890), "1,234,567,890")

	print("All tests passed")
end
