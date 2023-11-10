return {
    --[[
        Format:

        1. 1st argument to mount() -- ParentContainer
            --> Formatted as JSON -- gets turned into real ROBLOX Instances
        2. 2nd argument to mount() -- StyleSheet
        3. Expected result
            --> false: it should throw an error from bad args
            --> true: it should apply styles to all descendants of ParentContainer

        ** If none of the Stylesheet's classes exist in the ParentContainer then the test
            will throw an error because it will think that styles are still being applied
            after calling dismount() because assertStylesWereApplied won't throw an error
    ]]

    -- Test #1
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                    }
                },
            }
        }
    },
    {
        TextLabel = {
            Text = "ThisShouldBeChanged",
            TextColor3 = Color3.fromRGB(100, 200, 255),
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
    },
    true,

    -- Test #2
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
    false,

    -- Test #3
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                    }
                },
            }
        }
    },
    "BadInput",
    false,

    -- Test #4
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                    }
                },
            }
        }
    },
    {},
    true,

    -- Test #5
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                    }
                },
            }
        }
    },
    {
        Part = {
            Size = Vector3.new(1, 2, 3),
        },
        Frame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
        },
    },
    true,

    -- Test #6
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                    }
                },
            }
        }
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
    false,

    -- Test #7
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                    }
                },
            }
        }
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
    false,
}