return function()
	-- dependency
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Tests = script.Parent

	local buildInstanceJSON = require(Tests:FindFirstChild("buildInstanceJSON"))
	local isEqual = require(Tests:FindFirstChild("isEqual"))
	local MOUNT_TEST_CASES = require(Tests:FindFirstChild("mount-test-cases"))
	local Table = require(Tests:FindFirstChild("Table"))
	local RobloxCSS = require(ReplicatedStorage:FindFirstChild("roblox-css"))

	--[[
        1st version:
            * Specify properties by roblox class
            * Apply them on mount
            * And as new descendants are added
    ]]

	-- method for verifying if styles were actually applied
	local function assertStylesWereApplied(RBXInstance, RBXClassProperties)
		--[[
			@param: Instance RBXInstance
			@param: table RBXClassProperties { className --> { propertyName --> value } }
				- these are defined by the stylesheet
			@post: throws error if not all RXInstance properties match the stylesheet properties
			@post: recurses over all descendants of RBXInstance
		]]

		-- post-order traversal to hit all nodes even if errors happen
		for _, ChildInstance in RBXInstance:GetChildren() do
			assertStylesWereApplied(ChildInstance, RBXClassProperties)
		end

		-- verify styles were applied correctly
		if RBXClassProperties[RBXInstance.ClassName] then
			for propertyName, expectedValue in RBXClassProperties[RBXInstance.ClassName] do
				if not isEqual(RBXInstance[propertyName], expectedValue) then
					error("Failed to assign property '"
					.. tostring(propertyName)
					.. "' to "
					.. RBXInstance.ClassName
					.. ";\nExpected value: "
					.. tostring(expectedValue)
					.. ";\nActual value: "
					.. tostring(RBXInstance[propertyName]))
				end
			end
		end
	end

	-- test that RobloxCSS.mount updates properties of ParentContainer's descendants
	-- as specified by the provided stylesheet, and stops after calling RobloxCSS.dismount
	for i = 1, #MOUNT_TEST_CASES, 3 do
		-- read file of test cases
		local parentContainerJSON = MOUNT_TEST_CASES[i]
		local styleSheet = MOUNT_TEST_CASES[i + 1]
		local shouldThrowError = not MOUNT_TEST_CASES[i + 2]
		local testNumber = tostring((i + 2) / 3)

		it("Test #" .. testNumber, function()
			-- build ROBLOX Instances out of JSON
			local ParentContainer = parentContainerJSON
			if typeof(ParentContainer) == "table" and ParentContainer.ClassName then
				ParentContainer = buildInstanceJSON(ParentContainer)
			end

			-- invoke mount() method
			local s, output = pcall(RobloxCSS.mount, ParentContainer, styleSheet)

			-- catch both unexpected errors & incorrect successes
			if s == shouldThrowError then
				error("RobloxCSS.mount failed Test #" .. testNumber .. "\n" .. Table.toString(output))
			end

			-- if it's supposed to error, and it did, then we're done testing (RETURNS)
			if shouldThrowError then
				return
			end

			-- styles should be applied to all descendants of ParentContainer, including itself
			assertStylesWereApplied(ParentContainer, styleSheet)

			-- styles should be applied to new descendants of ParentContainer
			local DuplicateParentContainer = buildInstanceJSON(parentContainerJSON)
			DuplicateParentContainer.Parent = ParentContainer
			assertStylesWereApplied(ParentContainer, styleSheet)

			-- styles should no longer be applied after calling dismount
			RobloxCSS.dismount(output) -- output == dismountHandle
			DuplicateParentContainer = buildInstanceJSON(parentContainerJSON)
			DuplicateParentContainer.Parent = ParentContainer

			if Table.next(styleSheet) then -- if styleSheet is empty {}, the styles would still be "applied" and this doesn't work
				s, output = pcall(assertStylesWereApplied, ParentContainer, styleSheet)
				if s then
					error("RobloxCSS.dismount failed Test #" .. testNumber .. "; styles were still applied after dismount() was invoked")
				end
			end

			-- cleanup
			ParentContainer:Destroy()
		end)
	end
end
