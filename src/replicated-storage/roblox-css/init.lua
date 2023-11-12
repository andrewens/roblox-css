--[[
-- Roblox CSS main
-- Expose mount() and dismount(), the main methods of the library
--]]

-- dependency
local Maid = require(script:FindFirstChild("Maid"))
local CONFIG = require(script:FindFirstChild("config"))

local CLASS_ATTRIBUTE_NAME = CONFIG.CLASS_ATTRIBUTE_NAME
local CLASS_SEPARATOR_SYMBOL = CONFIG.CLASS_SEPARATOR_SYMBOL
local CUSTOM_CLASS_SYMBOL = CONFIG.CUSTOM_CLASS_SYMBOL

-- public
local function mount(ParentContainer, StyleSheets, CustomProperties)
	--[[
        @param: Instance ParentContainer
            - All descendants of this will be styled, including itself
        @param: table StyleSheets
			- { string rbxClassName --> { propertyName --> styledValue } }
			- { string _customClassName --> { propertyName --> styledValue } }
			- { [int i] --> function(RBXClass, CustomClass): nil }
			- { [int i] --> ModuleScript: function(RBXClass, CustomClass): nil }
            - These properties will be applied to relevant classes
		@param: table CustomProperties
			- { string propertyName --> function(...): ? }
			- { [int i] --> ModuleScript: ? }
        @post: All existing descendants of ParentContainer are styled according to StyleSheet
        @post: When new descendants are added to ParentContainer, they will be styled according to StyleSheet
        @return: any dismountHandle
            - When passed into RobloxCSS.dismount(), descendants of ParentContainer are no longer styled
    ]]

	--[[
		1. Compile master style sheet (no longer is the parameter)
			- RBX Classes
				- Validate the class
			- Custom classes
			- functions
			- Modulescripts / instances
		2. Define apply style in terms of master style sheet
		3. Apply style to the parent container and its descendants and new descendants
		4. return dismountHandle (and applyStyle?)
	]]

	-- input validation
	assert(typeof(ParentContainer) == "Instance")
	assert(typeof(StyleSheets) == "table")
	assert(CustomProperties == nil or typeof(CustomProperties) == "table")

	-- extract custom properties
	local CUSTOM_PROPERTIES = {} -- propertyName --> function(RBXInstance, property, value)
	if CustomProperties then
		for property, callback in CustomProperties do
			if typeof(property) ~= "string" then
				error()
			end
			if typeof(callback) ~= "function" then
				error()
			end

			CUSTOM_PROPERTIES[property] = callback
		end
	end
	local function applyProperty(RBXInstance, propertyName, value)
		if CUSTOM_PROPERTIES[propertyName] then
			CUSTOM_PROPERTIES[propertyName](RBXInstance, propertyName, value)
			return
		end
		RBXInstance[propertyName] = value
	end

	-- extract stylesheets
	local ROBLOX_MASTER_STYLESHEET = {} -- RBXInstanceClassName --> { property --> value }
	local CUSTOM_MASTER_STYLESHEET = {} -- CustomAttributeClassName --> { property --> value }

	for className, classProperties in StyleSheets do
		-- className should be a string
		if not typeof(className) == "string" then
			continue
		end

		-- classProperties should be a table
		if typeof(classProperties) ~= "table" then
			error("Stylesheet[" .. tostring(className) .. "] = " .. tostring(classProperties) .. ", which isn't a table")
		end

		-- save custom attribute classes
		if string.sub(className, 1, 1) == CUSTOM_CLASS_SYMBOL then
			className = string.sub(className, 2, -1)
			local CLASS_STYLESHEET = CUSTOM_MASTER_STYLESHEET[className] or {}
			CUSTOM_MASTER_STYLESHEET[className] = CLASS_STYLESHEET

			for propertyName, value in classProperties do
				-- Roblox Instance properties never have lowercase first letter, so we can do some input validation here
				local firstChar = string.sub(propertyName, 1, 1)
				if string.upper(firstChar) ~= firstChar then
					error("Stylesheet[" .. tostring(className) .. "][" .. tostring(propertyName) .. "] is invalid because the first letter of '" .. propertyName .. "' is lowercase")
				end

				CLASS_STYLESHEET[propertyName] = value
			end

			continue
		end

		-- save roblox instance classes
		local s, RBXInstance, msg = pcall(Instance.new, className)
		if not s then
			error("'" .. className .. "' isn't a valid Instance ClassName")
		end

		local INSTANCE_STYLESHEET = ROBLOX_MASTER_STYLESHEET[className] or {}
		ROBLOX_MASTER_STYLESHEET[className] = INSTANCE_STYLESHEET

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
			s, msg = pcall(applyProperty, RBXInstance, propertyName, value)
			if not s then
				error(
					className .. "." .. propertyName .. " = " .. tostring(value) .. " doesn't work: " .. tostring(msg)
				)
			end

			-- save to master stylesheet
			INSTANCE_STYLESHEET[propertyName] = value
		end

		RBXInstance:Destroy()
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
		-- apply properties from RBX class
		if ROBLOX_MASTER_STYLESHEET[RBXInstance.ClassName] then
			for propertyName, value in ROBLOX_MASTER_STYLESHEET[RBXInstance.ClassName] do
				applyProperty(RBXInstance, propertyName, value)
			end
		end

		-- apply custom properties
		local customClassNames = RBXInstance:GetAttribute(CLASS_ATTRIBUTE_NAME)
		if customClassNames then
			for _, className in string.split(customClassNames, CLASS_SEPARATOR_SYMBOL) do
				if CUSTOM_MASTER_STYLESHEET[className] then
					for propertyName, value in CUSTOM_MASTER_STYLESHEET[className] do
						applyProperty(RBXInstance, propertyName, value)
					end
				end
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
