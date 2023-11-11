return {
    --[[
        Format:

        1. 1st argument to mount() -- ParentContainer
            --> Formatted as JSON -- gets turned into real ROBLOX Instances
        2. 2nd argument to mount() -- RBXStyleSheet
        3. 3rd argument to mount() -- CustomProperties
        4. Expected result
            --> Formatted as JSON -- in the same way as #1
            --> Put "<ERROR>" if mount() should throw an error for these inputs

        * "<NIL>" gets replaced with nil
    ]]

    -- Test #1: normal styling with RBX classes
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
        },
    },
    "<NIL>",
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",

                        BackgroundColor3 = Color3.new(1, 0, 1),
                        Size = UDim2.new(0, 100, 0, 200),
                        ZIndex = 10,
                    }
                },

                Text = "ThisShouldBeChanged",
                TextColor3 = Color3.fromRGB(100, 200, 255),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Transparency = 0.5,
                Size = UDim2.new(1, -5, 1, -10),
            }
        },

        BackgroundColor3 = Color3.new(1, 0, 1),
        Size = UDim2.new(0, 100, 0, 200),
        ZIndex = 10,
    },

    -- Test #2: Bad input to ParentContainer
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
    "<NIL>",
    "<ERROR>", 

    -- Test #3: Bad input to RBXStyleSheet
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
    "<NIL>",
    "<ERROR>",

    -- Test #4: Empty RBXStylesheet is OK
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
    "<NIL>",
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

    -- Test #5: It's OK if some classes in stylesheet aren't applied
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
            BackgroundColor3 = Color3.new(1, 0, 1),
        },
    },
    "<NIL>",
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                        BackgroundColor3 = Color3.new(1, 0, 1),
                    }
                },
            }
        },

        BackgroundColor3 = Color3.new(1, 0, 1),
    },

    -- Test #6: Bad RBX class name in RBXStyleSheet
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
    "<NIL>",
    "<ERROR>",

    -- Test #7: Pass a bad value to a valid property name
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
    "<NIL>",
    "<ERROR>",

    -- Test #8: Passing no stylesheets is not OK
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
    "<NIL>",
    "<NIL>",
    "<ERROR>",

    -- Test #9: Normal styling with some custom classes
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
                _class = "CustomClassB", -- (underscores = Attributes)
            }
        },
        _class = "CustomClassA",
    },
    {
        _CustomClassA = { -- (underscores = custom class name, set as an Attribute)
            BackgroundColor3 = Color3.new(1, 0, 0),
        },
        CustomClassB = {
            BackgroundColor3 = Color3.new(0, 1, 1),
        },
    },
    "<NIL>",
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
                _class = "CustomClassB", -- (underscores = Attributes)
                BackgroundColor3 = Color3.new(0, 1, 1),
            }
        },
        _class = "CustomClassA",

        BackgroundColor3 = Color3.new(1, 0, 0),
    },

    -- Test #10: Normal styling with both custom classes and RBX Classes (underscores = Attributes)
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
                _class = "CustomClassB",
            }
        },
        _class = "CustomClassA",
    },
    {
        -- custom classes
        _CustomClassA = {
            BackgroundColor3 = Color3.new(1, 0, 0),
        },
        _CustomClassB = {
            BackgroundColor3 = Color3.new(0, 1, 1),
        },

        -- RBX classes
        Frame = {
            BackgroundColor3 = Color3.new(1, 1, 0),
        },
        TextLabel = {
            BackgroundColor3 = Color3.new(0, 1, 0),
        }
    },
    "<NIL>",
    {
        ClassName = "Frame",
        Children = {
            {
                ClassName = "TextLabel",
                Children = {
                    {
                        ClassName = "Frame",
                        BackgroundColor3 = Color3.new(1, 1, 0), -- default RBX class
                    }
                },
                _class = "CustomClassB",
                BackgroundColor3 = Color3.new(0, 1, 1),  -- Custom classes override RBX classes
            }
        },
        _class = "CustomClassA",
        BackgroundColor3 = Color3.new(1, 0, 0), -- Custom classes override RBX classes
    },
}