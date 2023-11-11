-- const
local ATTRIBUTE_SYMBOL = "_" -- properties prepended with this are interpreted as Attributes instead of normal properties
local IGNORED_PROPERTIES = {
    -- these JSON fields are ignored when building Instances out of JSON
    ClassName = true,
    Children = true,
    Name = true, -- we use names for looking up children to vastly simplify the comparison algorithm
}

-- turn table of Instance properties into actual
-- ROBLOX Instances for making test cases lightweight
local function buildInstanceJSON(instanceJSON)
    --[[
        @param: table | Instance instanceJSON
            - One table = one Instance
            - ClassName (string) specifies the kind of Instance to create
            - Children (table) allows specifying further descendants
            - If instanceJSON is already an Instance, nothing happens
            - Properties will be interpreted as Attributes if prepended with ATTRIBUTE_SYMBOL
        @return: an actual Instance with specified properties
        @post: instanceJSON is never modified so you can reuse it
    ]]

    -- input validation
    if typeof(instanceJSON) == "Instance" then
        return instanceJSON
    end
    if typeof(instanceJSON) ~= "table" then
        error("Must pass a table to buildInstanceJSON(); you passed: " .. tostring(instanceJSON))
    end
    local className = instanceJSON.ClassName
    if className == nil then
        error("No class name specified for instanceJSON Object " .. tostring(instanceJSON))
    end
    local Children = instanceJSON.Children
    if Children and typeof(Children) ~= "table" then
        error("Children must be a table in instanceJSON Object " .. tostring(instanceJSON))
    end

    -- build Instance out of JSON
    local RBXInstance = Instance.new(className)
    for property, value in instanceJSON do
        -- escape hatch for things like ClassName and Children, which we don't want to set as a property
        if IGNORED_PROPERTIES[property] then
            continue
        end

        -- support setting Attributes
        if string.sub(property, 1, 1) == ATTRIBUTE_SYMBOL then
            RBXInstance:SetAttribute(string.sub(property, 2, -1), value)
            continue
        end

        -- this will automatically throw for bad property names or values
        RBXInstance[property] = value
    end

    -- build descendant Instances if they're specified
    if Children then
        for i, childJSON in Children do
            local ChildInstance = buildInstanceJSON(childJSON)
            ChildInstance.Name = "Instance" .. tostring(i)
            ChildInstance.Parent = RBXInstance
        end
    end

    return RBXInstance
end

-- method for comparing JSON to actual Instances
local function jsonEqualsInstance(instanceJSON, RBXInstance)
    --[[
        @param: table instanceJSON
            - assumed that it's valid
        @param: Instance | nil RBXInstance
        @return: true if all properties/children exist in RBXInstance
            - it's assumed that children will be named "Instance" .. i
            - where `i` is the # child they are in the Json
            - TLDR this works best if the RBXInstance was generated from InstanceJSON.build
    ]]

    if RBXInstance == nil then
        return false
    end

    -- should be same class name
    if instanceJSON.ClassName ~= RBXInstance.ClassName then
        return false
    end

    -- should have same properties
    for property, value in instanceJSON do
        -- ignore ClassName, Children, etc
        if IGNORED_PROPERTIES[property] then
            continue
        end

        -- attributes should be same
        if string.sub(property, 1, 1) == ATTRIBUTE_SYMBOL then
            local attributeName = string.sub(property, 2, -1)
            if RBXInstance:GetAttribute(attributeName) ~= value then
                return false
            end
            continue
        end

        -- explicit properties should be the same
        if RBXInstance[property] ~= value then
            return false
        end
    end

    -- every child instanceJson must have an equal counterpart
    if instanceJSON.Children then
        for i, childJSON in instanceJSON.Children do
            local ChildInstance = RBXInstance:FindFirstChild("Instance" .. tostring(i))
            if not jsonEqualsInstance(childJSON, ChildInstance) then
                return false
            end
        end
    end

    return true
end

return {
    build = buildInstanceJSON,
    isEqual = jsonEqualsInstance,
}
