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
local function mount(ParentContainer, StyleSheet)
	--[[
        @param: Instance ParentContainer
            - All descendants of this will be styled, including itself
        @param: table StyleSheet
			- DEFINE CLASS STYLES
				- { string rbxClassName --> { propertyName --> styledValue } }
					- rbxClassName must be something you could pass to Instance.new() without error
				- { string _customClassName --> { propertyName --> styledValue } }
					- Prepend with an underscore; the underscore isn't a part of the custom class name
			- CUSTOM PROPERTIES
				- { string propertyName --> function(...): ? }
					- Any time this property is set anywhere, it will go through this function once
					- Can only define one function per property (or else error)
			- PROVIDE STYLESHEET MODULES
				- { [int i] --> function(RBXClass, CustomClass, CustomProperty): nil }
				- { [int i] --> ModuleScript: function(RBXClass, CustomClass, CustomProperty): nil }
			- You can combine any of these input formats in one big Stylesheet table
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
	assert(typeof(StyleSheet) == "table")

	-- master stylesheet definition
	local ROBLOX_CLASSES = {} -- RBXInstanceClassName --> { property --> value }
	local CUSTOM_CLASSES = {} -- CustomAttributeClassName --> { property --> value }
	local CUSTOM_PROPERTIES = {} -- propertyName --> function(RBXInstance, property, value)

	local function applyProperty(RBXInstance, propertyName, value)
		if CUSTOM_PROPERTIES[propertyName] then
			CUSTOM_PROPERTIES[propertyName](RBXInstance, propertyName, value)
			return
		end
		RBXInstance[propertyName] = value
	end
	local function applyStyles(RBXInstance)
		-- apply style from RBX class
		if ROBLOX_CLASSES[RBXInstance.ClassName] then
			for propertyName, value in ROBLOX_CLASSES[RBXInstance.ClassName] do
				applyProperty(RBXInstance, propertyName, value)
			end
		end

		-- apply style from custom class
		local customClassNames = RBXInstance:GetAttribute(CLASS_ATTRIBUTE_NAME)
		if customClassNames then
			-- custom classes support multiple classes
			for _, className in string.split(customClassNames, CLASS_SEPARATOR_SYMBOL) do
				if CUSTOM_CLASSES[className] then
					for propertyName, value in CUSTOM_CLASSES[className] do
						applyProperty(RBXInstance, propertyName, value)
					end
				end
			end
		end
	end

	-- extract stylesheet
	for className, classProperties in StyleSheet do
		-- .rcss modules aren't supported yet (CONTINUES)
		if typeof(className) ~= "string" then
			continue
		end

		-- support custom properties (CONTINUES)
		if typeof(classProperties) == "function" then
			local propertyName, callback = className, classProperties
			CUSTOM_PROPERTIES[propertyName] = callback
			continue
		end

		-- support custom classes (CONTINUES)
		if string.sub(className, 1, string.len(CUSTOM_CLASS_SYMBOL)) == CUSTOM_CLASS_SYMBOL then
			assert(typeof(classProperties) == "table")
			local customClassName = string.sub(className, string.len(CUSTOM_CLASS_SYMBOL) + 1, -1)
			CUSTOM_CLASSES[customClassName] = classProperties
			continue
		end

		-- support Roblox Instance classes
		assert(typeof(classProperties) == "table")
		ROBLOX_CLASSES[className] = classProperties
	end

	-- verify that ROBLOX classes won't cause errors when styles are actually applied
	for className, classProperties in ROBLOX_CLASSES do
		local s1, RBXInstance = pcall(Instance.new, className)
		if not s1 then
			error(tostring(className) .. " isn't a valid Instance class")
		end

		local s2, msg = pcall(applyStyles, RBXInstance)
		if not s2 then
			error("StyleSheet for ROBLOX Class '" .. tostring(className) .. "' is formatted incorrectly: " .. tostring(msg))
		end

		RBXInstance:Destroy()
	end

	-- apply styles to ParentContainer & its descendants
	local DismountMaid = Maid()
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
