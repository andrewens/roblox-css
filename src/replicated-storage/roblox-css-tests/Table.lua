--[[
    Various utility methods for use on values that might be tables.
    Methods default to normal operators for non-table values.
    October 2023
    Andrew Ens
]]

--[[
    any, any tableNext(table t)
    An equivalent to global method `next`, but it respects the
    __iter metamethod in ROBLOX Luau
]]
local function tableNext(t)
	for k, v in t do
		return k, v
	end
end

--[[
    string tableToString(table | any Table, string? indent)
    Convert a table into a readable string. If `Table` isn't actually
    a table then it just defaults to `tostring(Table)`
    (You can specify how much to indent by modifying the constant below)
]]
local INDENT_STRING = "  " -- how many spaces/tabs per indent?
local function tableToString(Table, indent)
	if typeof(Table) ~= "table" then
		return tostring(Table)
	end
	if tableNext(Table) == nil then
		return "{}"
	end

	indent = indent or ""
	local str = "{\n"
	for k, v in Table do
		str = str .. indent .. "  " .. tostring(k) .. ": " .. tableToString(v, indent .. INDENT_STRING) .. "\n"
	end
	return str .. indent .. "}"
end

--[[
    bool tableIsSubsetOf(a, b)

	Returns true if `a` is a subset of `b`.

    If both `a` and `b` are tables:
        - Returns true if all key/value pairs in `a` exist in `b`
		- Deep comparison -- checks at all levels recursively
    If neither `a` or `b` are tables:
        - Returns true if `a == b`
    Otherwise returns false
]]
local function tableIsSubsetOf(a, b)
	if typeof(a) ~= typeof(b) then
		return false
	end
	if typeof(a) ~= "table" then
		return a == b
	end

	for keyA, valueA in a do
		local typeA = typeof(valueA)

		local valueB = b[keyA]
		local typeB = typeof(valueB)

		if typeA ~= typeB then
			return false
		end
		if typeA == "table" then
			return tableIsSubsetOf(valueA, valueB)
		elseif valueA ~= valueB then
			return false
		end
	end

	return true
end

--[[
	bool isArray(any t)
]]
local function tableIsArray(t)
	return typeof(t) == "table" and t[1] ~= nil
end

return {
	isSubsetOf = tableIsSubsetOf,
	next = tableNext,
	toString = tableToString,
	isArray = tableIsArray,
}
