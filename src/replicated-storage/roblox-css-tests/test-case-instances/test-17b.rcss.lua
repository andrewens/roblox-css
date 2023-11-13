return function(RBXClass, CustomClass, CustomProperty)
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
end