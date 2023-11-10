local IGNORED_PROPERTIES = {
    -- these fields are ignored when building Instances out of JSON
    ClassName = true,
    Children = true,
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
        @return: an actual Instance with specified properties
        @post: if instanceJSON is a table, it is never modified
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
        if IGNORED_PROPERTIES[property] then
            continue
        end

        -- this will automatically throw for bad property names or values
        RBXInstance[property] = value
    end

    -- build descendant Instances if they're specified
    if Children then
        for _, childJSON in Children do
            buildInstanceJSON(childJSON).Parent = RBXInstance
        end
    end

    return RBXInstance
end
return buildInstanceJSON
