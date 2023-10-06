-- dependency
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestsFolder = ReplicatedStorage:FindFirstChild("roblox-css-tests")

local TestEZ = require(ReplicatedStorage:FindFirstChild("TestEZ"))

--[[
    Run unit tests for roblox-css
    Even though this is a front-end library for clients, I run the tests
    on the server because it's faster to hit `Run` than `Play` in ROBLXO STUDIO 
]]
TestEZ.TestBootstrap:run({ TestsFolder })
