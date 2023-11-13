-- I was SO close to defining module scripts 100% with InstanceJSON...
-- But I don't have permission to write the Source of ModuleScripts T_T
local TestCaseInstances = script.Parent:FindFirstChild("test-case-instances")
local Instance17a = assert(TestCaseInstances:FindFirstChild("test-17a"))
local Instance17b = assert(TestCaseInstances:FindFirstChild("test-17b.rcss"))

return {
	--[[
        Format:

        1. 1st argument to mount() -- ParentContainer
            --> Formatted as JSON -- gets turned into real ROBLOX Instances
        2. 2nd argument to mount() -- StyleSheet
        3. Expected result
            --> Formatted as JSON -- in the same way as #1
            --> Put "<ERROR>" if mount() should throw an error for these inputs

        * "<NIL>" gets replaced with nil
    ]]

	-- Test #1: normal styling with RBX classes
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	{
		TextLabel = {
			Text = "ThisShouldBeChanged",
			TextColor3 = Color3.fromRGB(100, 200, 255),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, -5, 1, -10),
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 0, 1),
			Size = UDim2.new(0, 100, 0, 200),
			ZIndex = 10,
		},
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",

						BackgroundColor3 = Color3.new(1, 0, 1),
						Size = UDim2.new(0, 100, 0, 200),
						ZIndex = 10,
					},
				},

				Text = "ThisShouldBeChanged",
				TextColor3 = Color3.fromRGB(100, 200, 255),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 0.5,
				Size = UDim2.new(1, -5, 1, -10),
			},
		},

		BackgroundColor3 = Color3.new(1, 0, 1),
		Size = UDim2.new(0, 100, 0, 200),
		ZIndex = 10,
	},

	-- Test #2: Bad input to ParentContainer
	"BadInput",
	{
		TextLabel = {
			Text = "ThisShouldBeChanged",
			TextColor3 = Color3.fromRGB(100, 200, 255),
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 0, 1),
			Size = UDim2.new(0, 100, 0, 200),
		},
	},
	"<ERROR>",

	-- Test #3: Bad input to RBXStyleSheet
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	"BadInput",
	"<ERROR>",

	-- Test #4: Empty RBXStylesheet is OK
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	{},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},

	-- Test #5: It's OK if some classes in stylesheet aren't applied
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	{
		Part = {
			Size = Vector3.new(1, 2, 3),
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 0, 1),
		},
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 0, 1),
					},
				},
			},
		},

		BackgroundColor3 = Color3.new(1, 0, 1),
	},

	-- Test #6: Bad RBX class name in RBXStyleSheet
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	{
		ThisIsntAClassName = {
			Size = Vector3.new(1, 2, 3),
		},
		TextLabel = {
			Text = "ThisShouldBeChanged",
			TextColor3 = Color3.fromRGB(100, 200, 255),
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 0, 1),
			Size = UDim2.new(0, 100, 0, 200),
		},
	},
	"<ERROR>",

	-- Test #7: Pass a bad value to a valid property name
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	{
		TextLabel = {
			Text = "TestTestTestTestTest",
			TextColor3 = "This isn't a Color3!",
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 0, 1),
			Size = UDim2.new(0, 100, 0, 200),
		},
	},
	"<ERROR>",

	-- Test #8: Passing no stylesheets is not OK
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
			},
		},
	},
	"<NIL>",
	"<ERROR>",

	-- Test #9: Normal styling with some custom classes
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB", -- (underscores = Attributes)
			},
		},
		_class = "CustomClassA",
	},
	{
		_CustomClassA = { -- (underscores = custom class name, set as an Attribute)
			BackgroundColor3 = Color3.new(1, 0, 0),
		},
		_CustomClassB = {
			BackgroundColor3 = Color3.new(0, 1, 1),
		},
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB", -- (underscores = Attributes)
				BackgroundColor3 = Color3.new(0, 1, 1),
			},
		},
		_class = "CustomClassA",

		BackgroundColor3 = Color3.new(1, 0, 0),
	},

	-- Test #10: Normal styling with both custom classes and RBX Classes (underscores = Attributes)
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		-- custom classes
		_CustomClassA = {
			BackgroundColor3 = Color3.new(1, 0, 0),
		},
		_CustomClassB = {
			BackgroundColor3 = Color3.new(0, 1, 1),
		},

		-- RBX classes
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(0, 1, 0),
		},
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 1, 0), -- default RBX class
					},
				},
				_class = "CustomClassB",
				BackgroundColor3 = Color3.new(0, 1, 1), -- Custom classes override RBX classes
			},
		},
		_class = "CustomClassA",
		BackgroundColor3 = Color3.new(1, 0, 0), -- Custom classes override RBX classes
	},

	-- Test #11: Overlapping custom classes
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB CustomClassA",
			},
		},
		_class = "CustomClassA CustomClassB",
	},
	{
		-- custom classes
		_CustomClassA = {
			BackgroundColor3 = Color3.new(1, 0, 0),
			BackgroundTransparency = 0.5,
		},
		_CustomClassB = {
			BackgroundColor3 = Color3.new(0, 1, 1),
		},

		-- RBX classes
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 0),
		},
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 1, 0),
					},
				},
				_class = "CustomClassB CustomClassA",

				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(1, 0, 0), -- the last custom class takes priority
			},
		},
		_class = "CustomClassA CustomClassB",

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(0, 1, 1), -- the last custom class takes priority
	},

	-- Test #12: Custom properties
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		-- custom properties
		BackgroundColor3 = function(RBXInstance, property, value)
			if value == "red" then
				value = Color3.new(1, 0, 0)
			elseif value == "yellow" then
				value = Color3.new(1, 1, 0)
			end
			RBXInstance[property] = value
		end,
		BackgroundTransparency = function(RBXInstance, property, value)
			if value == "half" then
				value = 0.5
			end
			RBXInstance[property] = value
		end,

		-- custom classes
		_CustomClassA = {
			BackgroundColor3 = "red",
			BackgroundTransparency = "half",
		},
		_CustomClassB = {
			BackgroundColor3 = Color3.new(0, 1, 1),
		},

		-- RBX classes
		Frame = {
			BackgroundColor3 = "yellow",
		},
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 1, 0),
					},
				},
				_class = "CustomClassB",

				BackgroundColor3 = Color3.new(0, 1, 1),
			},
		},
		_class = "CustomClassA",

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(1, 0, 0),
	},

	-- Test #13: Stylesheets defined as functions
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		-- you could mix/match these style definitions if you wanted but
		-- I decided to organize them each in their own module
		function(RBXClass, CustomClass, CustomProperty)
			RBXClass.Frame({
				BackgroundColor3 = "yellow",
			})
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomClass.CustomClassA({
				BackgroundColor3 = "red",
				BackgroundTransparency = "half",
			})
			CustomClass.CustomClassB({
				BackgroundColor3 = Color3.new(0, 1, 1),
			})
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomProperty.BackgroundColor3(function(RBXInstance, property, value)
				if value == "red" then
					value = Color3.new(1, 0, 0)
				elseif value == "yellow" then
					value = Color3.new(1, 1, 0)
				end
				RBXInstance[property] = value
			end)
			CustomProperty.BackgroundTransparency(function(RBXInstance, property, value)
				if value == "half" then
					value = 0.5
				end
				RBXInstance[property] = value
			end)
		end,
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 1, 0),
					},
				},
				_class = "CustomClassB",

				BackgroundColor3 = Color3.new(0, 1, 1),
			},
		},
		_class = "CustomClassA",

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(1, 0, 0),
	},

	-- Test #14: Incorrect stylesheet module format (with equal sign)
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		function(RBXClass, CustomClass, CustomProperty)
			RBXClass.Frame = { -- this is illegal because of the equal sign
				BackgroundColor3 = "yellow",
			}
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomClass.CustomClassA({
				BackgroundColor3 = "red",
				BackgroundTransparency = "half",
			})
			CustomClass.CustomClassB({
				BackgroundColor3 = Color3.new(0, 1, 1),
			})
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomProperty.BackgroundColor3(function(RBXInstance, property, value)
				if value == "red" then
					value = Color3.new(1, 0, 0)
				elseif value == "yellow" then
					value = Color3.new(1, 1, 0)
				end
				RBXInstance[property] = value
			end)
			CustomProperty.BackgroundTransparency(function(RBXInstance, property, value)
				if value == "half" then
					value = 0.5
				end
				RBXInstance[property] = value
			end)
		end,
	},
	"<ERROR>",

	-- Test #15: Incorrect stylesheet module format (with equal sign)
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		function(RBXClass, CustomClass, CustomProperty)
			RBXClass.Frame({
				BackgroundColor3 = "yellow",
			})
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomClass.CustomClassA({
				BackgroundColor3 = "red",
				BackgroundTransparency = "half",
			})
			CustomClass.CustomClassB = { -- this is illegal because of the equal sign
				BackgroundColor3 = Color3.new(0, 1, 1),
			}
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomProperty.BackgroundColor3(function(RBXInstance, property, value)
				if value == "red" then
					value = Color3.new(1, 0, 0)
				elseif value == "yellow" then
					value = Color3.new(1, 1, 0)
				end
				RBXInstance[property] = value
			end)
			CustomProperty.BackgroundTransparency(function(RBXInstance, property, value)
				if value == "half" then
					value = 0.5
				end
				RBXInstance[property] = value
			end)
		end,
	},
	"<ERROR>",

	-- Test #16: Incorrect stylesheet module format (with equal sign)
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		function(RBXClass, CustomClass, CustomProperty)
			RBXClass.Frame({
				BackgroundColor3 = "yellow",
			})
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomClass.CustomClassA({
				BackgroundColor3 = "red",
				BackgroundTransparency = "half",
			})
			CustomClass.CustomClassB({
				BackgroundColor3 = Color3.new(0, 1, 1),
			})
		end,
		function(RBXClass, CustomClass, CustomProperty)
			CustomProperty.BackgroundColor3(function(RBXInstance, property, value)
				if value == "red" then
					value = Color3.new(1, 0, 0)
				elseif value == "yellow" then
					value = Color3.new(1, 1, 0)
				end
				RBXInstance[property] = value
			end)
			CustomProperty.BackgroundTransparency = function(RBXInstance, property, value) -- this is illegal because of the equal sign
				if value == "half" then
					value = 0.5
				end
				RBXInstance[property] = value
			end
		end,
	},
	"<ERROR>",

	-- Test #17: Stylesheets defined as nested ModuleScripts
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		Instance17a,
		Instance17b
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 1, 0),
					},
				},
				_class = "CustomClassB",

				BackgroundColor3 = Color3.new(0, 1, 1),
			},
		},
		_class = "CustomClassA",

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(1, 0, 0),
	},

	-- Test #18: Custom Properties can only be defined once
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		Instance17b, -- this module defines some custom properties
		Instance17b -- so passing it twice should throw an error
	},
	"<ERROR>",

	-- Test #19: Custom Properties can only be defined once (different inputs)
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		Instance17b, -- this module defines CustomProperty.BackgroundColor3
		BackgroundColor3 = function(RBXInstance, propertyName, value)
			-- this is a second definition of CustomProperty.BackgroundColor3 which should throw
			return Color3.new(1, 1, 1)
		end,
	},
	"<ERROR>",

	-- Test #20: RbxClasses can have overlapping definitions
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassB",
			},
		},
		_class = "CustomClassA",
	},
	{
		function(RbxClass, CustomClass, CustomProperty)
			RbxClass.Frame {
				BackgroundColor3 = Color3.new(1, 1, 0),
			}
		end,
		function(RbxClass, CustomClass, CustomProperty)
			RbxClass.Frame {
				BackgroundTransparency = 0.5,
			}
		end
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
						BackgroundColor3 = Color3.new(1, 1, 0),
						BackgroundTransparency = 0.5,
					},
				},
			},
		},

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(1, 1, 0),
	},

	-- Test #21: CustomClasses can have overlapping definitions
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},
				_class = "CustomClassA",
			},
		},
		_class = "CustomClassA",
	},
	{
		function(RbxClass, CustomClass, CustomProperty)
			CustomClass.CustomClassA {
				BackgroundColor3 = Color3.new(1, 1, 0),
			}
		end,
		function(RbxClass, CustomClass, CustomProperty)
			CustomClass.CustomClassA {
				BackgroundTransparency = 0.5,
			}
		end
	},
	{
		ClassName = "Frame",
		Children = {
			{
				ClassName = "TextLabel",
				Children = {
					{
						ClassName = "Frame",
					},
				},

				BackgroundColor3 = Color3.new(1, 1, 0),
				BackgroundTransparency = 0.5,
			},
		},

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(1, 1, 0),
	},
}
