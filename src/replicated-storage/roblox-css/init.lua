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

	-- basic input validation
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

	-- interface for saving to master stylesheet
	local function extractRbxClass(className, classProperties)
		assert(typeof(className) == "string")
		assert(typeof(classProperties) == "table")
		ROBLOX_CLASSES[className] = classProperties
	end
	local function extractCustomClass(className, classProperties)
		assert(typeof(className) == "string")
		assert(typeof(classProperties) == "table")
		CUSTOM_CLASSES[className] = classProperties
	end
	local function extractCustomProperty(propertyName, callback)
		assert(typeof(propertyName) == "string")
		assert(typeof(callback) == "function")
		CUSTOM_PROPERTIES[propertyName] = callback
	end

	-- module interface: .rcss module --> master stylesheet
	-- i agree that it's overcomplicated but it allows the syntax to look like real CSS :^)
	local RbxClassInterface = setmetatable({}, {
		__index = function(self, className)
			return function(classProperties)
				extractRbxClass(className, classProperties)
			end
		end,
		__newindex = function(self, key, value)
			error("Don't use an equal sign to define RBXClass." .. tostring(key))
		end,
	})
	local CustomClassInterface = setmetatable({}, {
		__index = function(self, className)
			return function(classProperties)
				extractCustomClass(className, classProperties)
			end
		end,
		__newindex = function(self, key, value)
			error("Don't use an equal sign to define CustomClass." .. tostring(key))
		end,
	})
	local CustomPropertyInterface = setmetatable({}, {
		__index = function(self, propertyName)
			return function(callback)
				extractCustomProperty(propertyName, callback)
			end
		end,
		__newindex = function(self, key, value)
			error("Don't use an equal sign to define rcss CustomProperty[\"" .. tostring(key) .. '"]')
		end,
	})

	-- extract stylesheet modules
	for i, rcssModule in ipairs(StyleSheet) do
		-- ModuleScripts/Instances aren't supported yet (CONTINUES)
		if typeof(rcssModule) ~= "function" then
			continue
		end

		-- extract stylesheet from rcss module
		local s, msg = pcall(rcssModule, RbxClassInterface, CustomClassInterface, CustomPropertyInterface)
		if not s then
			error("rcss module function #" .. tostring(i) .. " failed with exception: " .. msg)
		end
	end

	-- extract default stylesheet
	for className, classProperties in StyleSheet do
		-- we already extracted .rcss modules (CONTINUES)
		if typeof(className) ~= "string" then
			continue
		end

		-- support custom properties (CONTINUES)
		if typeof(classProperties) == "function" then
			-- className == propertyName; classProperties == callback
			extractCustomProperty(className, classProperties)
			continue
		end

		-- support custom classes (CONTINUES)
		if string.sub(className, 1, string.len(CUSTOM_CLASS_SYMBOL)) == CUSTOM_CLASS_SYMBOL then
			local customClassName = string.sub(className, string.len(CUSTOM_CLASS_SYMBOL) + 1, -1)
			extractCustomClass(customClassName, classProperties)
			continue
		end

		-- support Roblox Instance classes
		extractRbxClass(className, classProperties)
	end

	-- verify that ROBLOX classes won't cause errors when styles are actually applied
	for className, classProperties in ROBLOX_CLASSES do
		local s1, RBXInstance = pcall(Instance.new, className)
		if not s1 then
			error(tostring(className) .. " isn't a valid Instance class")
		end

		local s2, msg = pcall(applyStyles, RBXInstance)
		if not s2 then
			error(
				"StyleSheet for ROBLOX Class '"
					.. tostring(className)
					.. "' is formatted incorrectly: "
					.. tostring(msg)
			)
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
