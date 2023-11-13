return function(RBXClass, CustomClass, CustomProperty)
    CustomClass.CustomClassA({
        BackgroundColor3 = "red",
        BackgroundTransparency = "half",
    })
    CustomClass.CustomClassB({
        BackgroundColor3 = Color3.new(0, 1, 1),
    })
end