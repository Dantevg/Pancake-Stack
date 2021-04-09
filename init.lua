local parser = require "pancakestack.parser"
local interpreter = require "pancakestack.interpreter"

local pancakestack = {}

pancakestack.parser = parser
pancakestack.interpreter = interpreter

function pancakestack.loadfile(path)
	local file = io.open(path)
	local content = file:read('a')
	file:close()
	return interpreter(parser.parse(content))
end

function pancakestack.dofile(path)
	local int = pancakestack.loadfile(path)
	while int.active do
		int:step()
	end
end

return pancakestack