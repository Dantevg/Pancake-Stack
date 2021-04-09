-- Make top refer to top element of stack, for __index and __newindex
local Stack = {}
function Stack.__index(t, k) return k == "top" and t[#t] end
function Stack.__newindex(t, k, v) rawset(t, k == "top" and #t or k, v) end
setmetatable(Stack, {__call = function() return setmetatable({}, Stack) end})

local interpreter = {}

function interpreter.new(program)
	local self = {}
	self.stack = Stack()
	self.instructions = program
	self.labels = {}
	self.pc = 1
	self.active = true
	
	return setmetatable(self, {__index = interpreter})
end

function interpreter:push(x)
	table.insert(self.stack, x)
end

function interpreter:pop()
	return table.remove(self.stack)
end

function interpreter:jump(label)
	if not self.labels[label] then error "no such label" end
	if not self.instructions[self.labels[label]] then error "label out of bounds" end
	self.pc = self.labels[label]
end

-- Put this X pancake on top!
-- Push the word length of X on top of the stack, i.e. "wonderful" would push 9.
function interpreter:putThisPancakeOnTop(x)
	self:push(#x)
end

-- Eat the pancake on top!
-- Pop the top value off of the stack, and discard it.
function interpreter:eatThePancakeOnTop()
	self:pop()
end

-- Put the top pancakes together!
-- Pop off the top two values, add them, and push the result.
function interpreter:putTheTopPancakesTogether()
	self:push(self:pop() + self:pop())
end

-- Give me a pancake!
-- Input a number value and push it on the stack.
function interpreter:giveMeAPancake()
	self:push(io.read('n') or 0)
end

-- How about a hotcake?
-- Input an ASCII character and push its value on the stack.
function interpreter:howAboutAHotcake()
	local char = io.read(1)
	self:push(char and string.byte(char) or 0)
end

-- Show me a pancake!
-- Output the top value on the stack as an ASCII character, but don't pop it.
function interpreter:showMeAPancake()
	io.write(string.char(self.stack[#self.stack]))
end

-- Take from the top pancakes!
-- Pop off the top two values, subtract the second one from the first one, and push the result.
function interpreter:takeFromTheTopPancakes()
	self:push(self:pop() - self:pop())
end

-- Flip the pancakes on top!
-- Pop off the top two values, swap them, and push them back.
function interpreter:flipThePancakesOnTop()
	self.stack.top, self.stack[#self.stack-1] = self.stack[#self.stack-1], self.stack.top
end

-- Put another pancake on top!
-- Pop off the top value and push it twice.
function interpreter:putAnotherPancakeOnTop()
	self:push(self.stack.top)
end

-- [label]
-- Defines a label to go back to (Can also define a comment, if needed).
-- When you go back to the label, it goes to the line number (1 indexed)
-- of the top value of the stack when the label was defined.
function interpreter:label(label)
	self.labels[label] = self.stack.top
end

-- If the pancake isn't tasty, go over to "label".
-- Go to label [label] if the top value is 0.
function interpreter:ifThePancakeIsntTastyGoOverTo(label)
	if self.stack.top == 0 then
		self:jump(label)
	end
end

-- If the pancake is tasty, go over to "label".
-- Same as above, except go if the top value is not 0.
function interpreter:ifThePancakeIsTastyGoOverTo(label)
	if self.stack.top ~= 0 then
		self:jump(label)
	end
end

-- Put syrup on the pancakes!
-- Increment all stack values.
function interpreter:putSyrupOnThePancakes()
	for i = 1, #self.stack do
		self.stack[i] = self.stack[i] + 1
	end
end

-- Put butter on the pancakes!
-- Increment only the top stack value.
function interpreter:putButterOnThePancakes()
	self.stack.top = self.stack.top + 1
end

-- Take off the syrup!
-- Decrement all stack values.
function interpreter:takeOffTheSyrup()
	for i = 1, #self.stack do
		self.stack[i] = self.stack[i] - 1
	end
end

-- Take off the butter!
-- Decrement only the top stack value.
function interpreter:takeOffTheButter()
	self.stack.top = self.stack.top - 1
end

-- Eat all of the pancakes!
-- Terminate the program.
function interpreter:eatAllOfThePancakes()
	self.active = false
end

-- Perform one instruction
-- Returns whether it successfully executed
function interpreter:step()
	if not self.active then return false end
	
	local currentPC = self.pc
	self.pc = self.pc+1 -- Increment program counter before executing (for jumps)
	local instruction = self.instructions[currentPC]
	local success, err = pcall(instruction.fn, self, table.unpack(instruction.args))
	if not success then
		self.active = false
		print(err)
		print("On instruction #"..currentPC)
		return false
	end
	
	if self.pc > #self.instructions then self.active = false end
	return true
end

return setmetatable(interpreter, {
	__call = function(_, ...) return interpreter.new(...) end,
})
