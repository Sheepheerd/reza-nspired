-- TI-Nspire Lua Script: Interactive Same Subspace Checker

-- Helper: split string by separator
local function split(str, sep)
	local fields = {}
	str:gsub("([^" .. sep .. "]+)", function(c)
		fields[#fields + 1] = c
	end)
	return fields
end

-- Parse "{1,2,3}" into {1,2,3}
local function parseVector(s)
	s = s:gsub("[{}%s]", "") -- remove { }, spaces
	if s == "" then
		return {}
	end
	local nums = split(s, ",")
	local vec = {}
	for i = 1, #nums do
		vec[i] = tonumber(nums[i])
	end
	return vec
end

-- Check if vector is zero
local function isZero(vec)
	for _, v in ipairs(vec) do
		if v ~= 0 then
			return false
		end
	end
	return true
end

-- Check if two vectors are in the same subspace
local function sameSubspace(u, v)
	if #u ~= #v then
		return false
	end
	if isZero(u) or isZero(v) then
		return true
	end
	local ratio = nil
	for i = 1, #u do
		if u[i] ~= 0 then
			local current_ratio = v[i] / u[i]
			if ratio == nil then
				ratio = current_ratio
			elseif math.abs(current_ratio - ratio) > 1e-9 then
				return false
			end
		elseif v[i] ~= 0 then
			return false
		end
	end
	return true
end

-- State
local u_input = ""
local v_input = ""
local activeField = "u" -- toggle between "u" and "v"
local result = ""

-- Draw the UI
function on.paint(gc)
	gc:setFont("sansserif", "r", 12)
	gc:drawString("Same Subspace Checker", 10, 10, "top")

	-- Draw u input
	if activeField == "u" then
		gc:setColorRGB(0, 0, 255) -- blue highlight
	else
		gc:setColorRGB(0, 0, 0)
	end
	gc:drawString("u = " .. u_input, 10, 40, "top")

	-- Draw v input
	if activeField == "v" then
		gc:setColorRGB(0, 0, 255)
	else
		gc:setColorRGB(0, 0, 0)
	end
	gc:drawString("v = " .. v_input, 10, 70, "top")

	-- Draw result
	gc:setColorRGB(0, 0, 0)
	gc:drawString("Press [Enter] to check", 10, 100, "top")
	gc:drawString("Result: " .. result, 10, 130, "top")
end

-- Handle typing characters
function on.charIn(ch)
	if activeField == "u" then
		u_input = u_input .. ch
	else
		v_input = v_input .. ch
	end
	platform.window:invalidate()
end

-- Handle backspace
function on.backspaceKey()
	if activeField == "u" then
		u_input = u_input:sub(1, -2)
	else
		v_input = v_input:sub(1, -2)
	end
	platform.window:invalidate()
end

-- Switch fields with Tab
function on.tabKey()
	if activeField == "u" then
		activeField = "v"
	else
		activeField = "u"
	end
	platform.window:invalidate()
end

-- Run check with Enter
function on.enterKey()
	local u = parseVector(u_input)
	local v = parseVector(v_input)
	result = tostring(sameSubspace(u, v))
	platform.window:invalidate()
end
