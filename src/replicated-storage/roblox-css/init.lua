--[[
-- Roblox CSS main
-- Expose mount() and dismount(), the main methods of the library
--]]

-- dependency
local Maid = require(script:FindFirstChild("Maid"))

-- public
local function mount(ParentContainer, StyleSheet)
	--[[
        @param: Instance ParentContainer
            - All descendants of this will be styled, including itself
        @param: table StyleSheet { className --> { propertyName --> styledValue } }
            - These properties will be applied to relevant classes
        @post: All existing descendants of ParentContainer are styled according to StyleSheet
        @post: When new descendants are added to ParentContainer, they will be styled according to StyleSheet
        @return: any dismountHandle
            - When passed into RobloxCSS.dismount(), descendants of ParentContainer are no longer styled
    ]]

	-- input validation
	assert(typeof(ParentContainer) == "Instance")
	assert(typeof(StyleSheet) == "table")
	for className, classProperties in StyleSheet do
		local s, RBXInstance, msg = pcall(Instance.new, className)
		if not s then
			error("'" .. className .. "' isn't a valid Instance ClassName")
		end

		for propertyName, value in classProperties do
			if not typeof(propertyName) == "string" then
				error(
					className
						.. "["
						.. tostring(propertyName)
						.. "] doesn't work because "
						.. tostring(propertyName)
						.. " is a "
						.. typeof(propertyName)
						.. " when it should be a string"
				)
			end
			s, msg = pcall(function()
				RBXInstance[propertyName] = value
			end)
			if not s then
				error(
					className .. "." .. propertyName .. " = " .. tostring(value) .. " doesn't work: " .. tostring(msg)
				)
			end
		end
	end

	--[[
	-- define a master stylesheet
	local MASTER_STYLESHEET = {} -- className --> { property --> value }
	local styleSaveInterface = setmetatable({}, {
		-- this is an overcomplicated interface for assigning styles, BUT...
		-- when exploiting the fact that Lua lets you call functions without parentheses for single arguments
		-- it allows the stylesheets to look like CSS code :^)

		__index = function(_, className)
			-- className must be a valid ROBLOX class
			local s, TestInstance = pcall(Instance.new, className)
			if not s then
				error(tostring(className) .. " isn't a valid ROBLOX Instance")
			end

			-- store properties to master style dictionary
			local CLASS_STYLESHEET = MASTER_STYLESHEET[className] or {}
			MASTER_STYLESHEET[className] = CLASS_STYLESHEET

			return function(Properties)
				assert(typeof(Properties) == "table")
				for propertyName, value in Properties do
					-- verify that setting this property to this value actually works
					local success, msg = pcall(function()
						TestInstance[propertyName] = value
					end)
					if not success then
						warn(className .. "." .. tostring(propertyName) .. " = " .. tostring(value) .. " doesn't work: " .. tostring(msg))
					end

					-- save property to master stylesheet
					-- note that it doesn't check if other stylesheets have already written to this property
					if success then
						CLASS_STYLESHEET[propertyName] = value
					end
				end
			end
		end,
	})

	-- save stylesheets to MASTER_STYLESHEET
	for i, styleSheet in StyleSheets do
		if typeof(styleSheet) == "function" then
			styleSheet(styleSaveInterface)
		elseif typeof(styleSheet) == "Instance" then
			-- search for .rcss module script Instances
			local Descendants = styleSheet:GetDescendants()
			table.insert(Descendants, styleSheet)

			for _, RcssModuleScript in Descendants do
				-- RCSS Modules file name must end in .rcss (or .rcss.lua if using Rojo + external editor)
				if ".rcss" ~= string.sub(RcssModuleScript.Name, string.len(RcssModuleScript.Name) - 5, -1) then
					continue
				end

				-- and it must be a ModuleScript (that returns a function)
				if not RcssModuleScript:IsA("ModuleScript") then
					continue
				end

				-- save the styles
				styleSheet = require(RcssModuleScript)
				styleSheet(styleSaveInterface)
			end
		else
			error(
				"Passed invalid Stylesheet: "
					.. tostring(styleSheet)
					.. " type="
					.. tostring(typeof(styleSheet))
					.. "; Stylesheets must be functions or Instances"
			)
		end
	end
--]]

	-- apply styles to ParentContainer & its descendants
	local DismountMaid = Maid()
	local function applyStyles(RBXInstance)
		if StyleSheet[RBXInstance.ClassName] then
			for propertyName, value in StyleSheet[RBXInstance.ClassName] do
				RBXInstance[propertyName] = value
			end
		end
	end

	DismountMaid(ParentContainer.DescendantAdded:Connect(applyStyles))

	local Descendants = ParentContainer:GetDescendants()
	table.insert(Descendants, ParentContainer)

	for i, RBXInstance in Descendants do
		applyStyles(RBXInstance)
	end

	-- dismount handle
	return DismountMaid
end
local function dismount(DismountMaid)
	--[[
        @param: any dismountHandle
			- the thing that mount() returns
        @post: styles are no longer applied to the ParentContainer that was originally mounted
    ]]
	DismountMaid:destroy()
end

-- expose roblox-css public API
return {
	mount = mount,
	dismount = dismount,
}
