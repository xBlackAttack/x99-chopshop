Config = {
    coreData = {
        eventPrefix = "InfinityFW",
        scriptName = "inf-core",
        smallEventPrefix = "inf-"
    },
    ChopLocation = vector3(-521.253, -1717.55, 19.544),
    ChopText = "Chop Vehicle",
    itemlist = {
        "plastic",
        "metalscrap",
        "copper",
        "aluminum",
        "aluminumoxide",
        "iron",
        "ironoxide",
        "steel",
        "rubber",
        "glass",
    },
    minCopCount = 4,
    enableNotAvailableText = true,
    dispatchEvent = {isServer = true, event = {
        "police:server:policeAlert", "Chopshop Alert"
    }}, -- if you use default qb policealert you dont need to edit this
    setPoliceCountEvent = "police:SetCopCount",

    VehicleChopBones = {
        {name = "wheel_lf", index = 0, type = "tyre"},
        {name = "wheel_rf", index = 1, type = "tyre"},
        {name = "wheel_lm", index = 2, type = "tyre"},
        {name = "wheel_rm", index = 3, type = "tyre"},
        {name = "wheel_lr", index = 4, type = "tyre"},
        {name = "wheel_rr", index = 5, type = "tyre"},
        {name = "wheel_lm1", index = 2, type = "tyre"},
        {name = "wheel_rm1", index = 3, type = "tyre"},
        {name = "door_dside_f", index = 0, type = "door"},
        {name = "door_pside_f", index = 1, type = "door"},
        {name = "door_dside_r", index = 2, type = "door"},
        {name = "door_pside_r", index = 3, type = "door"},
        {name = "bonnet", index = 4, type = "door"},
        {name = "boot", index = 5, type = "door"},
    },

    cheapNpc = {
        -- coords = vector3(-561.604, -1687.99, 18.268),
        coords = vector3(2058.3044433594, 3198.0419921875, 44.186496734619),
        heading = 149.40,
        type = 2,
        model = GetHashKey('s_m_m_lathandy_01'),
        items = {
            [1] = {
                name = "plastic",
                price = {100, 200}
            },
            [2] = {
                name = "metalscrap",
                price = {100, 200}
            },
            [3] = {
                name = "copper",
                price = {100, 200}
            },
            [4] = {
                name = "aluminum",
                price = {100, 200}
            },
            [5] = {
                name = "aluminumoxide",
                price = {100, 200}
            },
            [6] = {
                name = "iron",
                price = {100, 200}
            },
            [7] = {
                name = "steel",
                price = {100, 200}
            },
            [8] = {
                name = "rubber",
                price = {100, 200}
            },
            [9] = {
                name = "glass",
                price = {100, 200}
            },
            [10] = {
                name = "ironoxide",
                price = {100, 200}
            }
        }
    },
    
    secretNpc = {
        coords = vector3(61.10722, -1931.26, 20.482),
        heading = 144.09,
        type = 2,
        model = GetHashKey('s_m_m_lathandy_01'),
        animdict = "timetable@ron@ig_3_couch",
        animname = "base",
        items = {
            [1] = {
                name = "plastic",
                price = {150, 300}
            },
            [2] = {
                name = "metalscrap",
                price = {150, 300}
            },
            [3] = {
                name = "copper",
                price = {150, 300}
            },
            [4] = {
                name = "aluminum",
                price = {150, 300}
            },
            [5] = {
                name = "aluminumoxide",
                price = {150, 300}
            },
            [6] = {
                name = "iron",
                price = {150, 300}
            },
            [7] = {
                name = "steel",
                price = {150, 300}
            },
            [8] = {
                name = "rubber",
                price = {150, 300}
            },
            [9] = {
                name = "glass",
                price = {150, 300}
            },
        }
    },
    ProgressBar = {
        ["doors"] = {
            ["time"] = 4, -- sec
            ["text"] = "Taking of the door",
            ["drawtext"] = "Take the door",
        },
        ["tyre"] = {
            ["time"] = 5, -- sec
            ["text"] = "Taking of the tyre",
            ["drawtext"] = "Take the tyre",
        },
        ["trunk"] = {
            ["time"] = 4, -- sec
            ["text"] = "Taking of the trunk",
            ["drawtext"] = "Take the trunk",
        },
        ["hood"] = {
            ["time"] = 5, -- sec
            ["text"] = "Taking of the hood",
            ["drawtext"] = "Take the hood",
        },
        ["engine"] = {
            ["time"] = 4, -- sec
            ["text"] = "Taking of the other parts",
            ["drawtext"] = "Take the other parts",
        },
    }
}