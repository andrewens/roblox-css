return function()
	-- dependency
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RobloxCSS = require(ReplicatedStorage:FindFirstChild("roblox-css"))
	local isEqual = require(script.Parent:FindFirstChild("isEqual"))

	--[[
        1st version:
            * Specify properties by roblox class
            * Apply them on mount
            * And as new descendants are added
    ]]

	describe("mount", function()
		it("@param: ParentContainer must be an Instance", function()
			local TestStylesheets = {
				function(Class)
					Class.TextLabel({
						BackgroundColor3 = Color3.new(1, 0.5, 0.25),
					})
				end,
			}

			-- these should all throw errors
			local s1 = pcall(RobloxCSS.mount, nil, TestStylesheets)
			local s2 = pcall(RobloxCSS.mount, 1, TestStylesheets)
			local s3 = pcall(RobloxCSS.mount, { NotAn = "Instance" }, TestStylesheets)

			assert(not s1)
			assert(not s2)
			assert(not s3)
		end)
		it("@param: StyleSheets must be an array of Instances or functions", function()
			local TestContainer = Instance.new("ScreenGui")

			-- these should all throw errors
			local s1 = pcall(RobloxCSS.mount, TestContainer, nil)
			local s2 = pcall(RobloxCSS.mount, TestContainer, 23580)
			local s3 = pcall(RobloxCSS.mount, TestContainer, { ThisIsnt = "AFunctionOrInstance" })
			local s4 = pcall(RobloxCSS.mount, TestContainer, Instance.new("Part"))
			local s5 =
				pcall(RobloxCSS.mount, TestContainer, { Instance.new("Part"), { ThisIsnt = "AFunctionOrInstance" } })

			assert(not s1)
			assert(not s2)
			assert(not s3)
			assert(not s4)
			assert(not s5)
		end)
		it(
			"@post: Styles are applied to all descendants of ParentContainer, including itself, until dismount()",
			function()
				--[[
				-- Two classes: TextLabel & Frame
				-- ParentContainer is a Frame
				--]]

				-- define styles & instances
				local PROPERTIES = {
					TextLabel = {
						Text = "ThisShouldBeChanged",
						TextColor3 = Color3.fromRGB(100, 200, 255), -- can we do equality comparisons with this though?
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Transparency = 0.5,
						Size = UDim2.new(1, -5, 1, -10),
					},
					Frame = {
						BackgroundColor3 = Color3.new(1, 0, 1),
						Size = UDim2.new(0, 100, 0, 200),
						ZIndex = 10,
						Name = "ThisIsAFrame",
					},
				}
				local Stylesheets = {
					function(Class)
						-- apply styles from properties
						for className, properties in PROPERTIES do
							Class[className](properties)
						end
					end,
				}

				local ParentContainer = Instance.new("Frame")
				local TextLabel1 = Instance.new("TextLabel", ParentContainer)
				local TextLabel2 = Instance.new("TextLabel", TextLabel1)
				local TextLabel3 = Instance.new("TextLabel", TextLabel1)
				local Frame1 = Instance.new("Frame", ParentContainer)
				local Frame2 = Instance.new("Frame", TextLabel2)
				local TextLabel4 = Instance.new("TextLabel", Frame2)

				local Random1 = Instance.new("UIListLayout", Frame1)
				local Random2 = Instance.new("UIPadding", ParentContainer)
				local Random3 = Instance.new("UICorner", TextLabel4)

				-- function to verify ParentContainer's descendants match the stylesheets
				local function checkEquality(RootInstance)
					-- post-order traversal to hit all nodes even if errors happen
					for _, Child in RootInstance:GetChildren() do
						checkEquality(Child)
					end

					-- verify properties match the class
					local properties = PROPERTIES[RootInstance.ClassName]
					if properties then
						for key, value in properties do
							if not isEqual(RootInstance[key], value) then
								error(
									"Failed to assign property '"
										.. tostring(key)
										.. "' to "
										.. RootInstance.ClassName
										.. ";\nExpected value: "
										.. tostring(value)
										.. ";\nActual value: "
										.. tostring(RootInstance[key])
								)
							end
						end
					end
				end

				-- Styles are applied to ParentContainer & its descendants immediately after mount()
				local StyleMaid = RobloxCSS.mount(ParentContainer, Stylesheets)
				checkEquality(ParentContainer)

				-- Styles are applied to new descendants of ParentContainer
				local TextLabel5 = Instance.new("TextLabel", ParentContainer)
				local TextLabel6 = Instance.new("TextLabel", TextLabel5)
				local TextLabel7 = Instance.new("TextLabel")
				local Frame3 = Instance.new("Frame", TextLabel7)
				local TextLabel8 = Instance.new("TextLabel", Frame3)
				TextLabel7.Parent = Random3

				checkEquality(ParentContainer)

				-- dismount() stops applying Styles to new descendants of ParentContainre
				RobloxCSS.dismount(StyleMaid)

				local TextLabel9 = Instance.new("TextLabel", ParentContainer)
				local TextLabel10 = Instance.new("TextLabel", TextLabel9)
				local Frame4 = Instance.new("Frame", TextLabel7)

				local s = pcall(checkEquality, ParentContainer)
				assert(not s)
			end
		)
	end)
	describe("dismount", function()
		-- dismount() is used already in a test above. I don't think it's necessary to define these unit tests for now:
		-- it("@param: only accepts 'handles' from mount() calls")
		-- it("@post: stops applying styles to descendants of ParentContainer")
	end)
end
