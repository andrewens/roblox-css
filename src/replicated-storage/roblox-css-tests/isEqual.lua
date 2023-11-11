-- to support more types, simply add a new type and comparison function
-- it is always assumed that typeof(v1) == typeof(v2)
local IS_EQUAL = { -- typeof --> isEqual(v1, v2)
	["UDim"] = function(v1, v2)
		return v1.Scale == v2.Scale and v1.Offset == v2.Offset
	end,
	["UDim2"] = function(v1, v2)
		return v1.X.Scale == v2.X.Scale
			and v1.X.Offset == v2.X.Offset
			and v1.Y.Scale == v2.Y.Scale
			and v1.Y.Offset == v2.Y.Offset
	end,
	["Vector2"] = function(v1, v2)
        -- might need to implement this as a fuzzy equals later
        return v1.X == v2.X and v1.Y == v2.Y
    end,
	["Vector3"] = function(v1, v2) 
        return v1.X == v2.X and v1.Y == v2.Y and v1.Z == v2.Z
    end,
	["Color3"] = function(v1, v2)
        return v1.R == v2.R and v1.G == v2.G and v1.B == v2.B
    end,
}
local function defaultIsEqual(v1, v2)
	return v1 == v2
end

return function(v1, v2)
	--[[
        ROBLOX data types like UDim2, AnchorPoint, Vector, etc compare the object's memory address
        instead of the values. This method compares those values by their actual value.
    ]]

	-- IS_EQUAL<type> methods assume that v1 and v2 have the same type
	-- so we need this guard to prevent errors
	if typeof(v1) ~= typeof(v2) then
		return false
	end

	-- this defaults to the == operator if typeof(v1) isn't defined in the IS_EQUAL table
	return (IS_EQUAL[typeof(v1)] or defaultIsEqual)(v1, v2)
end
