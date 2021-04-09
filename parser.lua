local interpreter = require "pancakestack.interpreter"

local parser = {}

-- [label]
-- Defines a label to go back to (Can also define a comment, if needed).
-- When you go back to the label, it goes to the line number (1 indexed)
-- of the top value of the stack when the label was defined.
-- only used as identifier here
local function label() end

-- Maps statements (syntax) to functions, matching their arguments
-- The keys are used as patterns for string.match,
-- so non-pattern characters need to be escaped.
parser.statements = {
	["put this (%w+) pancake on top!"] = interpreter.putThisPancakeOnTop,
	["eat the pancake on top!"] = interpreter.eatThePancakeOnTop,
	["put the top pancakes together!"] = interpreter.putTheTopPancakesTogether,
	["give me a pancake!"] = interpreter.giveMeAPancake,
	["how about a hotcake?"] = interpreter.howAboutAHotcake,
	["show me a pancake!"] = interpreter.showMeAPancake,
	["take from the top pancakes!"] = interpreter.takeFromTheTopPancakes,
	["flip the pancakes on top!"] = interpreter.flipThePancakesOnTop,
	["put another pancake on top!"] = interpreter.putAnotherPancakeOnTop,
	["%[(%w+)%]"] = label,
	["if the pancake isn't tasty, go over to \"(%w+)\"%."] = interpreter.ifThePancakeIsntTastyGoOverTo,
	["if the pancake is tasty, go over to \"(%w+)\"%."] = interpreter.ifThePancakeIsTastyGoOverTo,
	["put syrup on the pancakes!"] = interpreter.putSyrupOnThePancakes,
	["put butter on the pancakes!"] = interpreter.putButterOnThePancakes,
	["take off the syrup!"] = interpreter.takeOffTheSyrup,
	["take off the butter!"] = interpreter.takeOffTheButter,
	["eat all of the pancakes!"] = interpreter.eatAllOfThePancakes,
}

function parser.parseLine(line)
	for statement, fn in pairs(parser.statements) do
		local captures = {line:lower():match(statement)}
		if #captures > 0 then
			return {fn = fn, args = captures}
		end
	end
end

function parser.parse(input)
	local program = {
		instructions = {},
		labels = {},
	}
	for line in input:gmatch("([^\n]+)") do
		local statement = parser.parseLine(line)
		if not statement then error("No such statement: "..line) end
		if statement.fn == label then
			program.labels[statement.args[1]] = #program.instructions + 1
		else
			table.insert(program.instructions, statement)
		end
	end
	return program
end

return parser
