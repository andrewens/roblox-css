-- this shouldn't get used because the name doesn't end in .rcss
return function(RBXClass, CustomClass, CustomProperty)
    CustomProperty.BackgroundColor3(function(RBXInstance, property, value)
        RBXInstance[property] = Color3.new(0, 0, 0)
    end)
    CustomProperty.BackgroundTransparency(function(RBXInstance, property, value)
        RBXInstance[property] = 1
    end)
end