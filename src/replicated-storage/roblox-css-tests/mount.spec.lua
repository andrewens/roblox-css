return function()
	-- dependency
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Tests = script.Parent

	local InstanceJSON = require(Tests:FindFirstChild("InstanceJSON"))
	local MOUNT_TEST_CASES = require(Tests:FindFirstChild("mount-test-cases"))
	local Table = require(Tests:FindFirstChild("Table"))
	local RobloxCSS = require(ReplicatedStorage:FindFirstChild("roblox-css"))

	-- test that RobloxCSS.mount updates properties of ParentContainer's descendants
	-- as specified by the provided stylesheet, and stops after calling RobloxCSS.dismount
	for i = 1, #MOUNT_TEST_CASES, 4 do
		-- read file of test cases
		local parentContainerJSON = MOUNT_TEST_CASES[i]
		local styleSheet = MOUNT_TEST_CASES[i + 1]
		local customProperties = MOUNT_TEST_CASES[i + 2]
		local expectedResult = MOUNT_TEST_CASES[i + 3]
		local testNumber = (i + 3) / 4
		testNumber = (if testNumber < 10 then "0" else "") .. tostring(testNumber)

		-- support macros
		if parentContainerJSON == "<NIL>" then
			parentContainerJSON = nil
		end
		if styleSheet == "<NIL>" then
			styleSheet = nil
		end
		if customProperties == "<NIL>" then
			customProperties = nil
		end
		if expectedResult == "<NIL>" then
			expectedResult = nil
		end
		local shouldThrowError = expectedResult == "<ERROR>"

		it("Test #" .. testNumber, function()
			-- build ROBLOX Instances out of JSON
			local ParentContainer = parentContainerJSON
			if typeof(ParentContainer) == "table" and ParentContainer.ClassName then
				ParentContainer = InstanceJSON.build(ParentContainer)
			end

			-- invoke mount() method
			local s, output = pcall(RobloxCSS.mount, ParentContainer, styleSheet, customProperties)

			-- catch both unexpected errors & incorrect successes
			if s == shouldThrowError then
				error("RobloxCSS.mount failed Test #" .. testNumber .. "\n" .. Table.toString(output))
			end

			-- if it's supposed to error, and it did, then we're done testing (RETURNS)
			if shouldThrowError then
				return
			end

			-- styles should be applied to all descendants of ParentContainer, including itself
			if not InstanceJSON.isEqual(expectedResult, ParentContainer) then
				ParentContainer.Name = "Test #" .. testNumber .. " failed"
				ParentContainer.Parent = workspace
				error("RobloxCSS.mount failed Test #" .. testNumber .. "\nExpected result: " .. Table.toString(expectedResult) .. "\nActual result (is in workspace)")
			end

			-- styles should be applied to new descendants of ParentContainer
			local DuplicateParentContainer = InstanceJSON.build(parentContainerJSON)
			DuplicateParentContainer.Parent = ParentContainer
			if not InstanceJSON.isEqual(expectedResult, DuplicateParentContainer) then
				ParentContainer.Name = "Test #" .. testNumber .. " failed"
				ParentContainer.Parent = workspace
				error("RobloxCSS.mount failed Test #" .. testNumber .. "; failed to apply changes to new descendants")
			end

			-- styles should no longer be applied after calling dismount
			RobloxCSS.dismount(output) -- output == dismountHandle
			DuplicateParentContainer = InstanceJSON.build(parentContainerJSON)
			DuplicateParentContainer.Parent = ParentContainer

			if Table.next(styleSheet) then -- if styleSheet is empty {}, the styles would still be "applied" and this doesn't work
				if InstanceJSON.isEqual(expectedResult, DuplicateParentContainer) then
					ParentContainer.Name = "Test #" .. testNumber .. " failed"
					ParentContainer.Parent = workspace
					error("RobloxCSS.dismount failed Test #" .. testNumber .. "; changes were applied after invoking dismount()")
				end
			end

			-- cleanup
			ParentContainer:Destroy()
		end)
	end
end
