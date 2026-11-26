-- SorsHub pack part 8/10
return function(P)
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]
local Aimbot = P["Aimbot@21681,6-21681,12"]
local Settings = P["Settings@21682,6-21682,14"]
local fn9 = P["fn9@22043,15-22043,18"]
local fn10 = P["fn10@22174,15-22174,19"]
local fn11 = P["fn11@22258,15-22258,19"]
local fn12 = P["fn12@22401,15-22401,19"]
local fn13 = P["fn13@22477,15-22477,19"]
local fn14 = P["fn14@22556,15-22556,19"]
local fn15 = P["fn15@22632,15-22632,19"]
local fn16 = P["fn16@22720,15-22720,19"]
local fn17 = P["fn17@22814,15-22814,19"]
local fn18 = P["fn18@22830,15-22830,19"]
local fn19 = P["fn19@22893,15-22893,19"]
local fn20 = P["fn20@23006,15-23006,19"]
local fn21 = P["fn21@23069,15-23069,19"]

local function fn22()
    local v18 = nil

    v18 = v:AddDialog("VX_ElliotAimbotDialog_" .. tostring(tick()), {
        Title = "Elliot Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn21()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_ElliotDlg_ThrowPizza", {
        Text = "ThrowPizza",
        Default = getgenv().VX_Elliot_ThrowPizza,
        Callback = function(vxElliotThrowPizza)
            getgenv().VX_Elliot_ThrowPizza = vxElliotThrowPizza
        end,
    })

    local v19 = v18
    local addSlider = v18.AddSlider
    local tbl = {Text = "Aimbot Duration", Min = 0, Max = 5}
    local vxAimbotDuration = getgenv().VX_AimbotDuration
    local default = vxAimbotDuration or 0
    tbl.Default = default
    tbl.Rounding = 2

    tbl.Callback = function(arg)
        getgenv().VX_AimbotDuration = tonumber(arg)
    end

    addSlider(v19, "VX_Elliot_AimbotDuration", tbl)
    local v20 = v18
    local addSlider2 = v18.AddSlider
    local tbl2 = {Text = "Aimbot Delay", Min = 0, Max = 2}
    local vxAimbotDelay = getgenv().VX_AimbotDelay
    local default2 = vxAimbotDelay or 0
    tbl2.Default = default2
    tbl2.Rounding = 2
    tbl2.Suffix = "s"

    tbl2.Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay2 = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay2
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end

    addSlider2(v20, "VX_Elliot_AimbotDelay", tbl2)
end
local function fn23()
    getgenv().VX_JaneDoeAnimIds = {}
    getgenv().VX_JaneDoeSoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local tbl = {Axe = getgenv().VX_JaneDoe_Axe}
    local tbl2 = {Axe = {"Draw", "Swing", "DefaultHit"}}

    local function fn24(arg)
        if type(arg.Animations) == "table" then
            for k, v18 in pairs(tbl) do
                if v18 then
                    local v19 = arg.Animations[k]

                    if type(v19) == "string" then
                        local vxJaneDoeAnimIds = getgenv().VX_JaneDoeAnimIds
                        local match = v19:match("%d+")
                        local v20 = match or v19
                        table.insert(vxJaneDoeAnimIds, v20)
                    end
                end
            end
        end

        if type(arg.Sounds) == "table" then
            local v18, v19, v20 = pairs(tbl)
            local v21 = v20
            local v22 = v18
            local v23 = v19

            while true do
                local v24, v25 = v22(v23, v21)
                if v24 == nil then
                    break
                end
                v21 = v24

                if v25 then
                    local v26 = tbl2[v24]
                    local tbl3 = v26 or {}
                    local v27, v28, v29 = ipairs(tbl3)
                    local v30 = v24
                    local v31 = v22
                    local v32 = v23
                    local v33 = v29
                    local v34 = v27
                    local v35 = v28

                    while true do
                        local v36, v37 = v34(v35, v33)
                        if v36 == nil then
                            break
                        end
                        v33 = v36
                        local v38 = arg.Sounds[v37]

                        if type(v38) == "string" then
                            local vxJaneDoeSoundIds = getgenv().VX_JaneDoeSoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vxJaneDoeSoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vxJaneDoeSoundIds = getgenv().VX_JaneDoeSoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vxJaneDoeSoundIds, v40)
                                end
                            end

                            v33 = v36
                        end
                    end

                    v21 = v30
                    v22 = v31
                    v23 = v32
                end
            end
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Survivors.JaneDoe.Config)

        if Config then
            fn24(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local janeDoe = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Survivors") and ReplicatedStorage.Assets.Skins.Survivors:FindFirstChild("JaneDoe")
        if not janeDoe then
            return
        end

        for i, child in ipairs(janeDoe:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn24(module)
                    end
                end
            end)
        end
    end)
end
local function fn24()
    local v18 = nil

    v18 = v:AddDialog("VX_JaneDoeAimbotDialog2_" .. tostring(tick()), {
        Title = "Jane Doe Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn23()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_JaneDlg_Axe", {
        Text = "Axe",
        Default = getgenv().VX_JaneDoe_Axe,
        Callback = function(vxJaneDoeAxe)
            getgenv().VX_JaneDoe_Axe = vxJaneDoeAxe
        end,
    })

    local v19 = v18
    local addSlider = v18.AddSlider
    local tbl = {Text = "Aimbot Duration", Min = 0, Max = 5}
    local vxAimbotDuration = getgenv().VX_AimbotDuration
    local default = vxAimbotDuration or 0
    tbl.Default = default
    tbl.Rounding = 2

    tbl.Callback = function(arg)
        getgenv().VX_AimbotDuration = tonumber(arg)
    end

    addSlider(v19, "VX_Jane_AimbotDuration", tbl)
    local v20 = v18
    local addSlider2 = v18.AddSlider
    local tbl2 = {Text = "Aimbot Delay", Min = 0, Max = 2}
    local vxAimbotDelay = getgenv().VX_AimbotDelay
    local default2 = vxAimbotDelay or 0
    tbl2.Default = default2
    tbl2.Rounding = 2
    tbl2.Suffix = "s"

    tbl2.Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay2 = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay2
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end

    addSlider2(v20, "VX_Jane_AimbotDelay", tbl2)
end
local function fn25()
    getgenv().VX_NosAnimIds = {}
    getgenv().VX_NosSoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local tbl = {
        Uppercut = getgenv().VX_Nos_Uppercut,
        Slash = getgenv().VX_Nos_Slash,
    }

    local tbl2 = {
        Uppercut = {"UppercutWindup", "Uppercut", "UppercutHit"},
        Slash = {"SlashWindup", "Slash", "SlashHit"},
    }

    local function fn26(arg)
        if type(arg.Animations) == "table" then
            for k, v18 in pairs(tbl) do
                if v18 then
                    local v19 = arg.Animations[k]

                    if type(v19) == "string" then
                        local vxNosAnimIds = getgenv().VX_NosAnimIds
                        local match = v19:match("%d+")
                        local v20 = match or v19
                        table.insert(vxNosAnimIds, v20)
                    end
                end
            end
        end

        if type(arg.Sounds) == "table" then
            local v18, v19, v20 = pairs(tbl)
            local v21 = v20
            local v22 = v18
            local v23 = v19

            while true do
                local v24, v25 = v22(v23, v21)
                if v24 == nil then
                    break
                end
                v21 = v24

                if v25 then
                    local v26 = tbl2[v24]
                    local tbl3 = v26 or {}
                    local v27, v28, v29 = ipairs(tbl3)
                    local v30 = v24
                    local v31 = v22
                    local v32 = v23
                    local v33 = v29
                    local v34 = v27
                    local v35 = v28

                    while true do
                        local v36, v37 = v34(v35, v33)
                        if v36 == nil then
                            break
                        end
                        v33 = v36
                        local v38 = arg.Sounds[v37]

                        if type(v38) == "string" then
                            local vxNosSoundIds = getgenv().VX_NosSoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vxNosSoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vxNosSoundIds = getgenv().VX_NosSoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vxNosSoundIds, v40)
                                end
                            end

                            v33 = v36
                        end
                    end

                    v21 = v30
                    v22 = v31
                    v23 = v32
                end
            end
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Killers.Nosferatu.Config)

        if Config then
            fn26(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local nosferatu = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("Nosferatu")
        if not nosferatu then
            return
        end

        for i, child in ipairs(nosferatu:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn26(module)
                    end
                end
            end)
        end
    end)
end
local function fn26()
    local v18 = nil

    v18 = v:AddDialog("VX_NosAimbotDialog_" .. tostring(tick()), {
        Title = "Nosferatu Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn25()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_NosDlg_Uppercut", {
        Text = "Uppercut",
        Default = getgenv().VX_Nos_Uppercut,
        Callback = function(vxNosUppercut)
            getgenv().VX_Nos_Uppercut = vxNosUppercut
        end,
    })

    v18:AddToggle("VX_NosDlg_Slash", {
        Text = "Slash",
        Default = getgenv().VX_Nos_Slash,
        Callback = function(vxNosSlash)
            getgenv().VX_Nos_Slash = vxNosSlash
        end,
    })

    local v19 = v18
    local addSlider = v18.AddSlider
    local tbl = {Text = "Aimbot Duration", Min = 0, Max = 5}
    local vxAimbotDuration = getgenv().VX_AimbotDuration
    local default = vxAimbotDuration or 0
    tbl.Default = default
    tbl.Rounding = 2

    tbl.Callback = function(arg)
        getgenv().VX_AimbotDuration = tonumber(arg)
    end

    addSlider(v19, "VX_Nos_AimbotDuration", tbl)
    local v20 = v18
    local addSlider2 = v18.AddSlider
    local tbl2 = {Text = "Aimbot Delay", Min = 0, Max = 2}
    local vxAimbotDelay = getgenv().VX_AimbotDelay
    local default2 = vxAimbotDelay or 0
    tbl2.Default = default2
    tbl2.Rounding = 2
    tbl2.Suffix = "s"

    tbl2.Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay2 = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay2
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end

    addSlider2(v20, "VX_Nos_AimbotDelay", tbl2)
end
local function fn27()
    getgenv().VX_SixerAnimIds = {}
    getgenv().VX_SixerSoundIds = {}
    local v18 = game
    local ReplicatedStorage = v18:GetService("ReplicatedStorage")

    local function fn28(arg, arg2)
        if type(arg2) == "string" then
            local match = arg2:match("%d+")

            if match then
                table.insert(arg, match)
            end
        elseif type(arg2) == "table" then
            for k, v19 in pairs(arg2) do
                v18(arg, v19)
            end
        end
    end

    local function fn29(arg)
        local animations = type(arg.Animations) == "table" and arg.Animations or {}
        local sounds = type(arg.Sounds) == "table" and arg.Sounds or {}

        if getgenv().VX_Sixer_Slash then
            fn28(getgenv().VX_SixerAnimIds, animations.Slash)
            fn28(getgenv().VX_SixerSoundIds, sounds.Swing)
            fn28(getgenv().VX_SixerSoundIds, sounds.Chomp)
            fn28(getgenv().VX_SixerSoundIds, sounds.Hit)
        end

        if getgenv().VX_Sixer_DemonicPursuit then
            fn28(getgenv().VX_SixerAnimIds, animations.DemonicPursuitStart)
            fn28(getgenv().VX_SixerAnimIds, animations.DemonicPursuitLoop)
            fn28(getgenv().VX_SixerAnimIds, animations.DemonicPursuitLunge)
            fn28(getgenv().VX_SixerAnimIds, animations.DemonicPursuitCutscene)
            fn28(getgenv().VX_SixerSoundIds, sounds.DemonicPursuitPrepare)
            fn28(getgenv().VX_SixerSoundIds, sounds.DemonicPursuitPrepareWARN)
            fn28(getgenv().VX_SixerSoundIds, sounds.DemonicPursuitLunge)
            fn28(getgenv().VX_SixerSoundIds, sounds.DemonicPursuitHit)
            fn28(getgenv().VX_SixerSoundIds, sounds.DemonicPursuitCutscene)
            fn28(getgenv().VX_SixerSoundIds, sounds.Crashed)
            fn28(getgenv().VX_SixerSoundIds, sounds.Landed)
            fn28(getgenv().VX_SixerSoundIds, sounds.Slide)
        end

        if getgenv().VX_Sixer_InfernalCry then
            fn28(getgenv().VX_SixerAnimIds, animations.Cry)
            fn28(getgenv().VX_SixerSoundIds, sounds.CryWindup)
            fn28(getgenv().VX_SixerSoundIds, sounds.CryShockwave)
            fn28(getgenv().VX_SixerSoundIds, sounds.CryHit)
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Killers.Sixer.Config)

        if Config then
            fn29(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local sixer = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("Sixer")
        if not sixer then
            return
        end

        for i, child in ipairs(sixer:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn29(module)
                    end
                end
            end)
        end
    end)
end
local function fn28()
    local v18 = nil

    v18 = v:AddDialog("VX_SixerAimbotDialog_" .. tostring(tick()), {
        Title = "Sixer Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn27()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_SixerDlg_DemonicPursuit", {
        Text = "Demonic Pursuit",
        Default = getgenv().VX_Sixer_DemonicPursuit,
        Callback = function(vxSixerDemonicPursuit)
            getgenv().VX_Sixer_DemonicPursuit = vxSixerDemonicPursuit
        end,
    })

    v18:AddToggle("VX_SixerDlg_InfernalCry", {
        Text = "Infernal Cry",
        Default = getgenv().VX_Sixer_InfernalCry,
        Callback = function(vxSixerInfernalCry)
            getgenv().VX_Sixer_InfernalCry = vxSixerInfernalCry
        end,
    })

    v18:AddToggle("VX_SixerDlg_Slash", {
        Text = "Slash",
        Default = getgenv().VX_Sixer_Slash,
        Callback = function(vxSixerSlash)
            getgenv().VX_Sixer_Slash = vxSixerSlash
        end,
    })

    local v19 = v18
    local addSlider = v18.AddSlider
    local tbl = {Text = "Aimbot Duration", Min = 0, Max = 5}
    local vxAimbotDuration = getgenv().VX_AimbotDuration
    local default = vxAimbotDuration or 0
    tbl.Default = default
    tbl.Rounding = 2

    tbl.Callback = function(arg)
        getgenv().VX_AimbotDuration = tonumber(arg)
    end

    addSlider(v19, "VX_Sixer_AimbotDuration", tbl)
    local v20 = v18
    local addSlider2 = v18.AddSlider
    local tbl2 = {Text = "Aimbot Delay", Min = 0, Max = 2}
    local vxAimbotDelay = getgenv().VX_AimbotDelay
    local default2 = vxAimbotDelay or 0
    tbl2.Default = default2
    tbl2.Rounding = 2
    tbl2.Suffix = "s"

    tbl2.Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay2 = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay2
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end

    addSlider2(v20, "VX_Sixer_AimbotDelay", tbl2)
end
local function fn29()
    getgenv().VX_1x1AnimIds = {}
    getgenv().VX_1x1_3DAnimIds = {}
    getgenv().VX_1x1SoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local tbl = {
        Entanglement = getgenv().VX_1x1_Entanglement,
        MassInfection = getgenv().VX_1x1_MassInfection,
        Slash = getgenv().VX_1x1_Slash,
    }

    local tbl2 = {
        Entanglement = getgenv().VX_1x1_Entanglement,
        MassInfection = getgenv().VX_1x1_MassInfection,
    }

    local tbl3 = {
        Slash = {"Swing"},
        MassInfection = {"MassInfectionActivate", "MassInfectionProjectile"},
        Entanglement = {"EntanglementActivate", "EntanglementProjectile"},
    }

    local function fn30(arg)
        if type(arg.Animations) == "table" then
            for k, v18 in pairs(tbl) do
                if v18 then
                    local v19 = arg.Animations[k]

                    if type(v19) == "string" then
                        local vx1x1AnimIds = getgenv().VX_1x1AnimIds
                        local match = v19:match("%d+")
                        local v20 = match or v19
                        table.insert(vx1x1AnimIds, v20)
                    end
                end
            end

            for k, v18 in pairs(tbl2) do
                if v18 then
                    local v19 = arg.Animations[k]

                    if type(v19) == "string" then
                        local vx1x13DAnimIds = getgenv().VX_1x1_3DAnimIds
                        local match = v19:match("%d+")
                        local v20 = match or v19
                        table.insert(vx1x13DAnimIds, v20)
                    end
                end
            end
        end

        if type(arg.Sounds) == "table" then
            local v18, v19, v20 = pairs(tbl)
            local v21 = v20
            local v22 = v18
            local v23 = v19

            while true do
                local v24, v25 = v22(v23, v21)
                if v24 == nil then
                    break
                end
                v21 = v24

                if v25 then
                    local v26 = tbl3[v24]
                    local tbl4 = v26 or {}
                    local v27, v28, v29 = ipairs(tbl4)
                    local v30 = v24
                    local v31 = v22
                    local v32 = v23
                    local v33 = v29
                    local v34 = v27
                    local v35 = v28

                    while true do
                        local v36, v37 = v34(v35, v33)
                        if v36 == nil then
                            break
                        end
                        v33 = v36
                        local v38 = arg.Sounds[v37]

                        if type(v38) == "string" then
                            local vx1x1SoundIds = getgenv().VX_1x1SoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vx1x1SoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vx1x1SoundIds = getgenv().VX_1x1SoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vx1x1SoundIds, v40)
                                end
                            end

                            v33 = v36
                        end
                    end

                    v21 = v30
                    v22 = v31
                    v23 = v32
                end
            end
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Killers["1x1x1x1"].Config)

        if Config then
            fn30(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local n1x1x1x1 = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("1x1x1x1")
        if not n1x1x1x1 then
            return
        end

        for i, child in ipairs(n1x1x1x1:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn30(module)
                    end
                end
            end)
        end
    end)
end
local function fn30()
    local v18 = nil

    v18 = v:AddDialog("VX_1x1AimbotDialog_" .. tostring(tick()), {
        Title = "1x1x1x1 Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn29()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_1x1Dlg_Entanglement", {
        Text = "Entanglement",
        Default = getgenv().VX_1x1_Entanglement,
        Callback = function(vx1x1Entanglement)
            getgenv().VX_1x1_Entanglement = vx1x1Entanglement
        end,
    })

    v18:AddToggle("VX_1x1Dlg_MassInfection", {
        Text = "MassInfection",
        Default = getgenv().VX_1x1_MassInfection,
        Callback = function(vx1x1MassInfection)
            getgenv().VX_1x1_MassInfection = vx1x1MassInfection
        end,
    })

    v18:AddToggle("VX_1x1Dlg_Slash", {
        Text = "Slash",
        Default = getgenv().VX_1x1_Slash,
        Callback = function(vx1x1Slash)
            getgenv().VX_1x1_Slash = vx1x1Slash
        end,
    })

    local v19 = v18
    local addSlider = v18.AddSlider
    local tbl = {Text = "Aimbot Duration", Min = 0, Max = 5}
    local vxAimbotDuration = getgenv().VX_AimbotDuration
    local default = vxAimbotDuration or 0
    tbl.Default = default
    tbl.Rounding = 2

    tbl.Callback = function(arg)
        getgenv().VX_AimbotDuration = tonumber(arg)
    end

    addSlider(v19, "VX_1x1_AimbotDuration", tbl)
    local v20 = v18
    local addSlider2 = v18.AddSlider
    local tbl2 = {Text = "Aimbot Delay", Min = 0, Max = 2}
    local vxAimbotDelay = getgenv().VX_AimbotDelay
    local default2 = vxAimbotDelay or 0
    tbl2.Default = default2
    tbl2.Rounding = 2
    tbl2.Suffix = "s"

    tbl2.Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay2 = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay2
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end

    addSlider2(v20, "VX_1x1_AimbotDelay", tbl2)
end
local function fn31()
    getgenv().VX_AzureAnimIds = {}
    getgenv().VX_AzureSoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local tbl = {
        {
            toggle = getgenv().VX_Azure_Slash,
            animKey = "Slash",
            soundKeys = {"SlashWindup", "Slash", "SlashHit"},
        },
        {
            toggle = getgenv().VX_Azure_Pummeling,
            animKey = "GolemSlash",
            soundKeys = {"SmashWindup", "Smash", "SmashHit"},
        },
        {
            toggle = getgenv().VX_Azure_GolemShockwave,
            animKey = "GolemShockwave",
            soundKeys = {"ShockwaveWindup", "Shockwave"},
        },
        {
            toggle = getgenv().VX_Azure_GolemFissure,
            animKey = "GolemFissure",
            soundKeys = {"FissureWindup", "FissureStomp"},
        },
    }

    local function fn32(arg)
        local v18, v19, v20 = ipairs(tbl)
        local v21 = v20
        local v22 = v18
        local v23 = v19

        while true do
            local v24, v25 = v22(v23, v21)
            if v24 == nil then
                break
            end
            v21 = v24

            if v25.toggle then
                if type(arg.Animations) == "table" then
                    local v26 = arg.Animations[v25.animKey]

                    if type(v26) == "string" then
                        local vxAzureAnimIds = getgenv().VX_AzureAnimIds
                        local match = v26:match("%d+")
                        local v27 = match or v26
                        table.insert(vxAzureAnimIds, v27)
                    end
                end

                if type(arg.Sounds) == "table" then
                    local v26, v27, v28 = ipairs(v25.soundKeys)
                    local v29 = v24
                    local v30 = v22
                    local v31 = v23
                    local v32 = v28
                    local v33 = v26
                    local v34 = v27

                    while true do
                        local v35, v36 = v33(v34, v32)
                        if v35 == nil then
                            break
                        end
                        v32 = v35
                        local v37 = arg.Sounds[v36]

                        if type(v37) == "string" then
                            local vxAzureSoundIds = getgenv().VX_AzureSoundIds
                            local match = v37:match("%d+")
                            local v38 = match or v37
                            table.insert(vxAzureSoundIds, v38)
                        elseif type(v37) == "table" then
                            for i, v38 in ipairs(v37) do
                                if type(v38) == "string" then
                                    local vxAzureSoundIds = getgenv().VX_AzureSoundIds
                                    local match = v38:match("%d+")
                                    local v39 = match or v38
                                    table.insert(vxAzureSoundIds, v39)
                                end
                            end

                            v32 = v35
                        end
                    end

                    v21 = v29
                    v22 = v30
                    v23 = v31
                end
            end
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Killers.Azure.Config)

        if Config then
            fn32(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local azure = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("Azure")
        if not azure then
            return
        end

        for i, child in ipairs(azure:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn32(module)
                    end
                end
            end)
        end
    end)
end
local function fn32()
    local v18 = nil

    v18 = v:AddDialog("VX_AzureAimbotDialog_" .. tostring(tick()), {
        Title = "Azure Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn31()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_AzDlg_Slash", {
        Text = "Perforating (Azure M1)",
        Default = getgenv().VX_Azure_Slash,
        Callback = function(vxAzureSlash)
            getgenv().VX_Azure_Slash = vxAzureSlash
        end,
    })

    v18:AddToggle("VX_AzDlg_Pummeling", {
        Text = "Pummeling (Golem M1)",
        Default = getgenv().VX_Azure_Pummeling,
        Callback = function(vxAzurePummeling)
            getgenv().VX_Azure_Pummeling = vxAzurePummeling
        end,
    })

    v18:AddToggle("VX_AzDlg_GolemShockwave", {
        Text = "Blooming (Golem Shockwave)",
        Default = getgenv().VX_Azure_GolemShockwave,
        Callback = function(vxAzureGolemShockwave)
            getgenv().VX_Azure_GolemShockwave = vxAzureGolemShockwave
        end,
    })

    v18:AddToggle("VX_AzDlg_GolemFissure", {
        Text = "Unearthing (Golem Fissure)",
        Default = getgenv().VX_Azure_GolemFissure,
        Callback = function(vxAzureGolemFissure)
            getgenv().VX_Azure_GolemFissure = vxAzureGolemFissure
        end,
    })

    local v19 = v18
    local addSlider = v18.AddSlider
    local tbl = {Text = "Aimbot Duration", Min = 0, Max = 5}
    local vxAimbotDuration = getgenv().VX_AimbotDuration
    local default = vxAimbotDuration or 0
    tbl.Default = default
    tbl.Rounding = 2

    tbl.Callback = function(arg)
        getgenv().VX_AimbotDuration = tonumber(arg)
    end

    addSlider(v19, "VX_Azure_AimbotDuration", tbl)
    local v20 = v18
    local addSlider2 = v18.AddSlider
    local tbl2 = {Text = "Aimbot Delay", Min = 0, Max = 2}
    local vxAimbotDelay = getgenv().VX_AimbotDelay
    local default2 = vxAimbotDelay or 0
    tbl2.Default = default2
    tbl2.Rounding = 2
    tbl2.Suffix = "s"

    tbl2.Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay2 = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay2
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end

    addSlider2(v20, "VX_Azure_AimbotDelay", tbl2)
end
local tbl = {
    Azure = true,
    ["1x1x1x1"] = true,
    Slasher = true,
    ["John Doe"] = true,
    Nosferatu = true,
    Sixer = true,
    c00lkidd = true,
    Noli = true,
    Shedletsky = true,
    Elliot = true,
    ["Jane Doe"] = true,
    Chance = true,
    ["Two Time"] = true,
}
local function fn33(arg)
    if arg == "Azure" then
        return getgenv().VX_AzureAnimIds
    end

    if arg == "1x1x1x1" then
        return getgenv().VX_1x1AnimIds
    end

    if arg == "Slasher" then
        return getgenv().VX_SlasherAnimIds
    end

    if arg == "John Doe" then
        return getgenv().VX_JohnDoeAnimIds
    end

    if arg == "Nosferatu" then
        return getgenv().VX_NosAnimIds
    end

    if arg == "Sixer" then
        return getgenv().VX_SixerAnimIds
    end

    if arg == "c00lkidd" then
        return getgenv().VX_C00lkiddAnimIds
    end

    if arg == "Noli" then
        return getgenv().VX_NoliAnimIds
    end

    if arg == "Shedletsky" then
        return getgenv().VX_ShedletskyAnimIds
    end

    if arg == "Elliot" then
        return getgenv().VX_ElliotAnimIds
    end

    if arg == "Jane Doe" then
        return getgenv().VX_JaneDoeAnimIds
    end

    if arg == "Two Time" then
        return getgenv().VX_TwoTimeAnimIds
    end
    return {}
end
local tbl2 = {
    Shedletsky = true,
    Elliot = true,
    ["Jane Doe"] = true,
    ["Two Time"] = true,
}
local function fn34(arg)
    local v18 = fn33(arg)
    if not v18 or #v18 == 0 then
        return false
    end
    local tbl3 = {}

    for i, v19 in ipairs(v18) do
        tbl3[tostring(v19)] = true
    end

    local character = game:GetService("Players").LocalPlayer.Character
    if not character then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return false
    end

    for i, v19 in ipairs(animator:GetPlayingAnimationTracks()) do
        if not v19.Animation then
            continue
        end
        local match = tostring(v19.Animation.AnimationId):match("%d+")
        if match and tbl3[match] then
            return true
        end
    end

    return false
end
local function fn35()
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then
        return false
    end
    local flintlock = character:FindFirstChild("Flintlock", true)
    local v18 = flintlock
    if not flintlock then
        return false
    end

    if not flintlock:IsA("BasePart") and not flintlock:IsA("MeshPart") and not flintlock:IsA("UnionOperation") then
        local basePart = flintlock:FindFirstChildWhichIsA("BasePart", true)
        v18 = basePart
        if not basePart then
            return false
        end
    end

    local flag = v18.Transparency < 1
    return flag
end
getgenv().VX_AimbotSurvivorConn = nil
getgenv().VX_AimbotSurvivorHRPConn = nil
getgenv().VX_AimbotDelayActive = false
getgenv().VX_AimbotWasActive = false
getgenv().VX_AimbotBestHRP = nil
getgenv().VX_AimbotPredictedPos = nil;
(function()
    if getgenv().VX_AimbotSurvivorConn then
        getgenv().VX_AimbotSurvivorConn:Disconnect()
        getgenv().VX_AimbotSurvivorConn = nil
    end

    if getgenv().VX_AimbotSurvivorHRPConn then
        getgenv().VX_AimbotSurvivorHRPConn:Disconnect()
        getgenv().VX_AimbotSurvivorHRPConn = nil
    end

    local function fn36()
        if not getgenv().VX_AimbotEnabled then
            getgenv().VX_AimbotWasActive = false
            getgenv().VX_AimbotDelayActive = false
            getgenv().VX_AimbotBestHRP = nil
            getgenv().VX_AimbotPredictedPos = nil
            return false
        end

        local vxAimbotTargets = getgenv().VX_AimbotTargets
        local tbl3 = vxAimbotTargets or {}
        local v18 = nil

        for k in pairs(tbl3) do
            if tbl[k] then
                local flag = false

                if k == "Chance" then
                    flag = fn35()
                else
                    pcall(function()
                        flag = fn34(k)
                    end)
                end

                if not flag then
                    continue
                end
                v18 = k
                break
            end

            continue
        end

        local flag = v18 ~= nil

        if not flag then
            getgenv().VX_AimbotDurationCooling = false
        end

        if flag and not getgenv().VX_AimbotWasActive and not getgenv().VX_AimbotDurationCooling then
            getgenv().VX_AimbotWasActive = true
            getgenv().VX_AimbotDelayActive = true
            getgenv().VX_AimbotLastTarget = v18
            local vxAimbotDuration = getgenv().VX_AimbotDuration
            local n = vxAimbotDuration or 0
            local genv16 = getgenv()
            local vxAimbotDurationExpiry = n > 0 and os.clock() + n or nil
            genv16.VX_AimbotDurationExpiry = vxAimbotDurationExpiry
            local vxAimbotDelay = getgenv().VX_AimbotDelay
            local n2 = vxAimbotDelay or 0

            if n2 > 0 then
                task.delay(n2, function()
                    getgenv().VX_AimbotDelayActive = false
                end)
            else
                getgenv().VX_AimbotDelayActive = false
            end
        end

        local vxAimbotDurationExpiry = getgenv().VX_AimbotDurationExpiry
        local flag2 = vxAimbotDurationExpiry

        if vxAimbotDurationExpiry then
            local now = os.clock()
            flag2 = getgenv().VX_AimbotDurationExpiry <= now
        end

        if flag2 then
            getgenv().VX_AimbotWasActive = false
            getgenv().VX_AimbotDelayActive = false
            getgenv().VX_AimbotDurationExpiry = nil
            getgenv().VX_AimbotDurationCooling = true
        elseif not flag and getgenv().VX_AimbotWasActive and not getgenv().VX_AimbotDurationExpiry then
            getgenv().VX_AimbotWasActive = false
            getgenv().VX_AimbotDelayActive = false
        end

        if getgenv().VX_AimbotWasActive and not getgenv().VX_AimbotDelayActive then
            local vxAimbotLastTarget = v18 or getgenv().VX_AimbotLastTarget
            local localPlayer = game:GetService("Players").LocalPlayer
            local character = localPlayer and localPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then
                return false
            end
            local players = workspace:FindFirstChild("Players")
            if not players then
                return false
            end
            local survivors

            if vxAimbotLastTarget == "Elliot" then
                survivors = players:FindFirstChild("Survivors")
            elseif vxAimbotLastTarget ~= "Chance" and not tbl2[vxAimbotLastTarget] then
                survivors = players:FindFirstChild("Survivors")
            else
                survivors = players:FindFirstChild("Killers")
            end

            if not survivors then
                return false
            end

            local function fn37()
                return survivors:GetChildren()
            end

            local v19 = nil

            if vxAimbotLastTarget == "Chance" then
                local huge = math.huge
                local vxAimbotMaxDistance = getgenv().VX_AimbotMaxDistance
                local huge2 = vxAimbotMaxDistance or math.huge

                for i, child in ipairs(survivors:GetChildren()) do
                    if child.Name ~= "Chance" then
                        local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                        local humanoid = child:FindFirstChildOfClass("Humanoid")

                        if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                            local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                            if magnitude <= huge2 and magnitude < huge then
                                huge = magnitude
                                v19 = humanoidRootPart2
                            end
                        end
                    end
                end
            elseif vxAimbotLastTarget == "Elliot" then
                local vxElliotAimMode = getgenv().VX_ElliotAimMode
                local str = vxElliotAimMode or "Nearest Survivor"
                local vxAimbotMaxDistance = getgenv().VX_AimbotMaxDistance
                local huge = vxAimbotMaxDistance or math.huge

                if str == "Nearest Survivor" then
                    local huge2 = math.huge

                    for i, child in ipairs(survivors:GetChildren()) do
                        if child.Name ~= localPlayer.Name then
                            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                            local humanoid = child:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                                local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                                if magnitude <= huge and magnitude < huge2 then
                                    huge2 = magnitude
                                    v19 = humanoidRootPart2
                                end
                            end
                        end
                    end
                elseif str == "Lowest HP" then
                    local huge2 = math.huge

                    for i, child in ipairs(survivors:GetChildren()) do
                        if child.Name ~= localPlayer.Name then
                            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                            local humanoid = child:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart2 and humanoid and humanoid.Health > 0 and humanoid.Health < huge2 and (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= huge then
                                huge2 = humanoid.Health
                                v19 = humanoidRootPart2
                            end
                        end
                    end
                elseif str == "Closest to Cursor" then
                    local currentCamera = workspace.CurrentCamera
                    local mouse = localPlayer:GetMouse()
                    local huge2 = math.huge

                    for i, child in ipairs(survivors:GetChildren()) do
                        if child.Name ~= localPlayer.Name then
                            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                            local humanoid = child:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart2 and humanoid and humanoid.Health > 0 and (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= huge then
                                local v20, v21 = currentCamera:WorldToScreenPoint(humanoidRootPart2.Position)

                                if v21 then
                                    local n = v20.X - mouse.X
                                    local n2 = v20.Y - mouse.Y
                                    local v22 = math.sqrt(n * n + n2 * n2)

                                    if v22 < huge2 then
                                        huge2 = v22
                                        v19 = humanoidRootPart2
                                    end
                                end
                            end
                        end
                    end
                end
            else
                local vxAimbotPriority = getgenv().VX_AimbotPriority
                local str = vxAimbotPriority or "Nearest"
                local vxAimbotMaxDistance = getgenv().VX_AimbotMaxDistance
                local huge = vxAimbotMaxDistance or math.huge
                local name = character and character.Name or localPlayer.Name

                if str == "Closest to Cursor" then
                    local currentCamera = workspace.CurrentCamera
                    local mouse = localPlayer:GetMouse()
                    local huge2 = math.huge

                    for i, v20 in ipairs(fn37()) do
                        if v20.Name ~= name then
                            local humanoidRootPart2 = v20:FindFirstChild("HumanoidRootPart")
                            local humanoid = v20:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart2 and humanoid and humanoid.Health > 0 and (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= huge then
                                local v21, v22 = currentCamera:WorldToScreenPoint(humanoidRootPart2.Position)

                                if v22 then
                                    local n = v21.X - mouse.X
                                    local n2 = v21.Y - mouse.Y
                                    local v23 = math.sqrt(n * n + n2 * n2)

                                    if v23 < huge2 then
                                        huge2 = v23
                                        v19 = humanoidRootPart2
                                    end
                                end
                            end
                        end
                    end
                else
                    local huge2 = math.huge

                    for i, v20 in ipairs(fn37()) do
                        if v20.Name ~= name then
                            local humanoidRootPart2 = v20:FindFirstChild("HumanoidRootPart")
                            local humanoid = v20:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                                local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                                if magnitude <= huge and magnitude < huge2 then
                                    huge2 = magnitude
                                    v19 = humanoidRootPart2
                                end
                            end
                        end
                    end
                end
            end

            if not v19 then
                getgenv().VX_AimbotBestHRP = nil
                getgenv().VX_AimbotPredictedPos = nil
                return false
            end

            local vxAimbotPrediction = getgenv().VX_AimbotPrediction
            local n = vxAimbotPrediction or 0
            local vxAimbotPredictedPos

            if n > 0 then
                vxAimbotPredictedPos = v19.Position + v19.AssemblyLinearVelocity * (n / 60)
            else
                vxAimbotPredictedPos = v19.Position
            end

            if getgenv().VX_AimbotTargets and getgenv().VX_AimbotTargets["Two Time"] then
                vxAimbotPredictedPos = vxAimbotPredictedPos - v19.CFrame.LookVector * 2
            end

            local vxAimbotWallCheckMode = getgenv().VX_AimbotWallCheckMode
            local str = vxAimbotWallCheckMode or "Off"

            if str ~= "Off" then
                local position = str == "Camera" and workspace.CurrentCamera.CFrame.Position or humanoidRootPart.Position
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {humanoidRootPart.Parent, v19.Parent}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                local hit = workspace:Raycast(position, v19.Position - position, raycastParams)

                if hit and hit.Instance and not hit.Instance:IsDescendantOf(v19.Parent) then
                    getgenv().VX_AimbotBestHRP = nil
                    getgenv().VX_AimbotPredictedPos = nil
                    return false
                end
            end

            getgenv().VX_AimbotBestHRP = v19
            getgenv().VX_AimbotPredictedPos = vxAimbotPredictedPos
            return true, humanoidRootPart, vxAimbotPredictedPos
        end

        getgenv().VX_AimbotBestHRP = nil
        getgenv().VX_AimbotPredictedPos = nil
        return false
    end

    getgenv().VX_AimbotSurvivorConn = game:GetService("RunService").RenderStepped:Connect(function()
        local v18, v19, v20 = fn36()
        if not v18 then
            return
        end
        local vxAimbotMode = getgenv().VX_AimbotMode
        if vxAimbotMode ~= "Camera" and vxAimbotMode ~= "Both" then
            return
        end
        local currentCamera = workspace.CurrentCamera
        local vxAimbotSmoothing = getgenv().VX_AimbotSmoothing
        local n = vxAimbotSmoothing or 0.2
        local n2 = math.clamp(n, 0.01, 1)

        if getgenv().VX_AimbotFaceSameDirection and getgenv().VX_AimbotTargets and getgenv().VX_AimbotTargets["Two Time"] then
            local vxAimbotBestHRP = getgenv().VX_AimbotBestHRP

            if vxAimbotBestHRP and vxAimbotBestHRP.Parent then
                pcall(function()
                    local lookVector = vxAimbotBestHRP.CFrame.LookVector
                    local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

                    if vector.Magnitude > 0.001 then
                        local cframe = CFrame.new(currentCamera.CFrame.Position, currentCamera.CFrame.Position + vector.Unit)
                        currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe, n2)
                    end
                end)

                return
            end
        end

        local cframe = CFrame.new(currentCamera.CFrame.Position, v20)
        currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe, n2)
    end)

    getgenv().VX_AimbotSurvivorHRPConn = game:GetService("RunService").Heartbeat:Connect(function()
        local v18, v19, v20 = fn36()
        if not v18 then
            return
        end
        local vxAimbotMode = getgenv().VX_AimbotMode
        local vxAimbotSmoothing = getgenv().VX_AimbotSmoothing
        local n = vxAimbotSmoothing or 0.2
        local n2 = math.clamp(n, 0.01, 1)

        if vxAimbotMode == "HRP" or vxAimbotMode == "Both" then
            local cframe = CFrame.new(v19.Position, Vector3.new(v20.X, v19.Position.Y, v20.Z))
            v19.CFrame = v19.CFrame:Lerp(cframe, n2)
        end

        if getgenv().VX_AimbotFaceSameDirection and getgenv().VX_AimbotTargets and getgenv().VX_AimbotTargets["Two Time"] then
            local vxAimbotBestHRP = getgenv().VX_AimbotBestHRP

            if vxAimbotBestHRP and vxAimbotBestHRP.Parent then
                pcall(function()
                    local lookVector = vxAimbotBestHRP.CFrame.LookVector
                    local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

                    if vector.Magnitude > 0.001 then
                        local cframe = CFrame.new(v19.Position, v19.Position + vector.Unit)
                        v19.CFrame = v19.CFrame:Lerp(cframe, n2)
                    end
                end)
            end
        end
    end)
end)()
local vxClearBezierInstant2 = getgenv().VX_ClearBezierInstant
vxClearBezierInstant2 = getgenv().VX_ClearBezierShatter
vxClearBezierInstant2 = getgenv().VX_SpawnBezierVisualizer
getgenv()._VX_BezierHookConn = game:GetService("RunService").Heartbeat:Connect(function()
    if not getgenv().VX_BezierEnabled then
        if getgenv().VX_BezierActive then
            pcall(getgenv().VX_ClearBezierInstant)
        end

        return
    end

    if not getgenv().VX_AimbotEnabled then
        if getgenv().VX_BezierActive then
            pcall(getgenv().VX_ClearBezierInstant)
        end

        return
    end

    local vxAimbotTargets = getgenv().VX_AimbotTargets
    local tbl3 = vxAimbotTargets or {}
    local flag = false
    local v18 = nil

    for k in pairs(tbl3) do
        if tbl[k] then
            local flag2 = false

            if k == "Chance" then
                flag2 = fn35()
            else
                pcall(function()
                    flag2 = fn34(k)
                end)
            end

            if not flag2 then
                continue
            end
            flag = true
            v18 = k
            break
        end

        continue
    end

    if not flag then
        if getgenv().VX_BezierActive then
            pcall(getgenv().VX_ClearBezierShatter)
        end

        return
    end

    if getgenv().VX_BezierActive then
        return
    end
    local localPlayer = game:GetService("Players").LocalPlayer
    local character = localPlayer and localPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    local players = workspace:FindFirstChild("Players")
    if not players then
        return
    end
    local survivors

    if v18 == "Elliot" then
        survivors = players:FindFirstChild("Survivors")
    elseif v18 ~= "Chance" and not tbl2[v18] then
        survivors = players:FindFirstChild("Survivors")
    else
        survivors = players:FindFirstChild("Killers")
    end

    if not survivors then
        return
    end
    local v19 = nil
    local huge = math.huge

    if v18 == "Chance" then
        for i, child in ipairs(survivors:GetChildren()) do
            if child.Name ~= "Chance" then
                local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                local humanoid = child:FindFirstChildOfClass("Humanoid")

                if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                    local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                    if magnitude < huge then
                        huge = magnitude
                        v19 = humanoidRootPart2
                    end
                end
            end
        end
    else
        local name = localPlayer.Name

        for i, child in ipairs(survivors:GetChildren()) do
            if child.Name ~= name then
                local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                local humanoid = child:FindFirstChildOfClass("Humanoid")

                if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                    local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                    if magnitude < huge then
                        huge = magnitude
                        v19 = humanoidRootPart2
                    end
                end
            end
        end
    end

    if v19 then
        pcall(function()
            getgenv().VX_SpawnBezierVisualizer(humanoidRootPart, v19)
        end)
    end
end)
Aimbot:AddCheckbox(fn(), {
    Text = "Aimbot",
    Default = false,
    Callback = function(vxAimbotEnabled)
        getgenv().VX_AimbotEnabled = vxAimbotEnabled
    end,
})
getgenv().VX_3DAimbot = {
    Enabled = false,
    Uppercut = true,
    MassInfection = true,
    Entanglement = true,
    Gun = true,
}
local function fn36(arg)
    local localPlayer = game:GetService("Players").LocalPlayer
    local character = localPlayer and localPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return nil
    end
    local players = workspace:FindFirstChild("Players")
    local v18 = players and workspace.Players:FindFirstChild(arg)
    if not v18 then
        return nil
    end
    local v19 = nil
    local huge = math.huge

    for i, child in ipairs(v18:GetChildren()) do
        if child.Name ~= localPlayer.Name then
            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
            local humanoid = child:FindFirstChildOfClass("Humanoid")

            if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                if magnitude < huge then
                    huge = magnitude
                    v19 = humanoidRootPart2
                end
            end
        end
    end

    return v19
end
local function fn37()
    if not getgenv().VX_3DAimbot.Uppercut then
        return false
    end
    local tbl3 = {}
    local vxNosAnimIds = getgenv().VX_NosAnimIds
    local tbl4 = vxNosAnimIds or {}

    for i, v18 in ipairs(tbl4) do
        tbl3[tostring(v18)] = true
    end

    if not next(tbl3) then
        return false
    end
    local players = workspace:FindFirstChild("Players")
    local killers = players and workspace.Players:FindFirstChild("Killers")
    local nosferatu = killers and killers:FindFirstChild("Nosferatu")
    if not nosferatu then
        return false
    end
    local humanoid = nosferatu:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return false
    end

    for i, v18 in ipairs(animator:GetPlayingAnimationTracks()) do
        if not v18.Animation then
            continue
        end
        local match = tostring(v18.Animation.AnimationId):match("%d+")
        if match and tbl3[match] then
            return true
        end
    end

    return false
end
local function fn38()
    if not getgenv().VX_3DAimbot.MassInfection and not getgenv().VX_3DAimbot.Entanglement then
        return false
    end
    local tbl3 = {}
    local vx1x13DAnimIds = getgenv().VX_1x1_3DAnimIds
    local tbl4 = vx1x13DAnimIds or {}

    for i, v18 in ipairs(tbl4) do
        tbl3[tostring(v18)] = true
    end

    if not next(tbl3) then
        return false
    end
    local players = workspace:FindFirstChild("Players")
    local killers = players and workspace.Players:FindFirstChild("Killers")
    local n1x1x1x1 = killers and killers:FindFirstChild("1x1x1x1")
    if not n1x1x1x1 then
        return false
    end
    local humanoid = n1x1x1x1:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return false
    end

    for i, v18 in ipairs(animator:GetPlayingAnimationTracks()) do
        if not v18.Animation then
            continue
        end
        local match = tostring(v18.Animation.AnimationId):match("%d+")
        if match and tbl3[match] then
            return true
        end
    end

    return false
end
local function fn39()
    if not getgenv().VX_3DAimbot.Gun then
        return false
    end
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then
        return false
    end
    local flintlock = character:FindFirstChild("Flintlock", true)
    local v18 = flintlock
    if not flintlock then
        return false
    end

    if not flintlock:IsA("BasePart") and not flintlock:IsA("MeshPart") and not flintlock:IsA("UnionOperation") then
        local basePart = flintlock:FindFirstChildWhichIsA("BasePart", true)
        v18 = basePart
        if not basePart then
            return false
        end
    end

    local flag = v18.Transparency < 1
    return flag
end
local connection = nil
local function fn40()
    if connection then
        connection:Disconnect()
        connection = nil
    end

    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not getgenv().VX_3DAimbot.Enabled then
            return
        end
        local Survivors = nil

        if fn37() then
            Survivors = fn36("Survivors")
        elseif fn38() then
            Survivors = fn36("Survivors")
        elseif fn39() then
            local players = workspace:FindFirstChild("Players")
            local killers = players and workspace.Players:FindFirstChild("Killers")

            if killers then
                local localPlayer = game:GetService("Players").LocalPlayer
                local character = localPlayer and localPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                local huge = math.huge

                for i, child in ipairs(killers:GetChildren()) do
                    if child.Name ~= "Chance" then
                        local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                        local humanoid = child:FindFirstChildOfClass("Humanoid")

                        if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                            local magnitude = humanoidRootPart and (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude or 0

                            if magnitude < huge then
                                huge = magnitude
                                Survivors = humanoidRootPart2
                            end
                        end
                    end
                end
            end
        end

        if not Survivors then
            return
        end
        local localPlayer = game:GetService("Players").LocalPlayer
        local character = localPlayer and localPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return
        end
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, Survivors.Position)
    end)
end
local v18 = nil
Aimbot:AddCheckbox(fn(), {
    Text = "3D Aimbot",
    Default = false,
    Callback = function(enabled)
        getgenv().VX_3DAimbot.Enabled = enabled

        if enabled then
            fn40()

            if v18 then
                pcall(function()
                    v18:Dismiss()
                end)
            end

            v18 = v:AddDialog("VX_3DAimbotCfgDlg_" .. tostring(tick()), {
                Title = "3D Aimbot Config",
                Description = "Choose which abilities trigger the 3D aimbot.",
                AutoDismiss = false,
                OutsideClickDismiss = true,
                FooterButtons = {
                    Apply = {
                        Title = "Apply",
                        Variant = "Primary",
                        Order = 2,
                        Callback = function()
                            pcall(fn25)
                            pcall(fn29)
                            v18:Dismiss()
                        end,
                    },
                },
            })

            v18:AddToggle("VX_3D_Uppercut", {
                Text = "Uppercut  (Nosferatu)",
                Default = getgenv().VX_3DAimbot.Uppercut,
                Callback = function(uppercut)
                    getgenv().VX_3DAimbot.Uppercut = uppercut
                    getgenv().VX_Nos_Uppercut = uppercut
                end,
            })

            v18:AddToggle("VX_3D_MassInfection", {
                Text = "MassInfection  (1x1x1x1)",
                Default = getgenv().VX_3DAimbot.MassInfection,
                Callback = function(massInfection)
                    getgenv().VX_3DAimbot.MassInfection = massInfection
                    getgenv().VX_1x1_MassInfection = massInfection
                end,
            })

            v18:AddToggle("VX_3D_Entanglement", {
                Text = "Entanglement  (1x1x1x1)",
                Default = getgenv().VX_3DAimbot.Entanglement,
                Callback = function(entanglement)
                    getgenv().VX_3DAimbot.Entanglement = entanglement
                    getgenv().VX_1x1_Entanglement = entanglement
                end,
            })

            v18:AddToggle("VX_3D_Gun", {
                Text = "Gun  (Chance)",
                Default = getgenv().VX_3DAimbot.Gun,
                Callback = function(gun)
                    getgenv().VX_3DAimbot.Gun = gun
                end,
            })

            local v19 = v18
            local addSlider = v19.AddSlider
            local tbl3 = {Text = "Aimbot Duration", Min = 0, Max = 5}
            local vxAimbotDuration = getgenv().VX_AimbotDuration
            local default = vxAimbotDuration or 0
            tbl3.Default = default
            tbl3.Rounding = 1

            tbl3.Callback = function(arg)
                getgenv().VX_AimbotDuration = tonumber(arg)
            end

            addSlider(v19, "VX_VX_3D_AimbotDuration", tbl3)
            local v20 = v18
            local addSlider2 = v20.AddSlider
            local tbl4 = {Text = "Aimbot Delay", Min = 0, Max = 2}
            local vxAimbotDelay = getgenv().VX_AimbotDelay
            local default2 = vxAimbotDelay or 0
            tbl4.Default = default2
            tbl4.Rounding = 2
            tbl4.Suffix = "s"

            tbl4.Callback = function(arg)
                local genv16 = getgenv()
                local num = tonumber(arg)
                local vxAimbotDelay2 = num or 0
                genv16.VX_AimbotDelay = vxAimbotDelay2
                getgenv().VX_AimbotWasActive = false
                getgenv().VX_AimbotDelayActive = false
            end

            addSlider2(v20, "VX_VX_3D_AimbotDelay", tbl4)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end,
})
Aimbot:AddCheckbox(fn(), {
    Text = "Face Same Direction",
    Default = false,
    Callback = function(vxAimbotFaceSameDirection)
        getgenv().VX_AimbotFaceSameDirection = vxAimbotFaceSameDirection
    end,
})
Aimbot:AddCheckbox(fn(), {
    Text = "Curve Visualizer",
    Default = false,
    Callback = function(vxBezierEnabled)
        getgenv().VX_BezierEnabled = vxBezierEnabled

        if not vxBezierEnabled then
            pcall(getgenv().VX_ClearBezierInstant)
        end
    end,
})
local tbl3 = {
    "Azure",
    "1x1x1x1",
    "c00lkidd",
    "Slasher",
    "John Doe",
    "Noli",
    "Sixer",
    "Nosferatu",
    "Shedletsky",
    "Elliot",
    "Jane Doe",
    "Two Time",
}
getgenv().VX_AimbotTarget = "1x1x1x1"
getgenv().VX_AimbotTargets = {}
for i, v19 in ipairs(tbl3) do
    getgenv().VX_AimbotTargets[v19] = true
end
local handlers = {
    Azure = fn32,
    ["1x1x1x1"] = fn30,
    Slasher = fn10,
    ["John Doe"] = fn12,
    Nosferatu = fn26,
    Sixer = fn28,
    c00lkidd = fn14,
    Noli = fn16,
    Shedletsky = fn20,
    Elliot = fn22,
    ["Jane Doe"] = fn24,
    ["Two Time"] = fn18,
}
local tbl4 = {}
for i, v19 in ipairs(tbl3) do
    tbl4[v19] = true
end
local flag = false
local v19 = Aimbot:AddDropdown(fn(), {
    Text = "Select Characters",
    Values = tbl3,
    Default = tbl3,
    Multi = true,
})
v19:OnChanged(function()
    local activeValues = v19:GetActiveValues()
    if #activeValues == 0 then
        flag = true
        return
    end
    local vxAimbotTargets = {}

    for i, activeValue in ipairs(activeValues) do
        vxAimbotTargets[activeValue] = true
    end

    if flag then
        for i, activeValue in ipairs(activeValues) do
            if not tbl4[activeValue] and handlers[activeValue] then
                handlers[activeValue]()
            end
        end
    else
        flag = true
    end

    tbl4 = vxAimbotTargets
    getgenv().VX_AimbotTargets = vxAimbotTargets
    local genv16 = getgenv()
    local v20 = activeValues[1]
    local vxAimbotTarget = v20 or "1x1x1x1"
    genv16.VX_AimbotTarget = vxAimbotTarget
end)
task.spawn(function()
    pcall(fn31)
    pcall(fn29)
    pcall(fn9)
    pcall(fn11)
    pcall(fn13)
    pcall(fn15)
    pcall(fn19)
    pcall(fn21)
    pcall(fn23)
    pcall(fn25)
    pcall(fn27)
    pcall(fn17)
end)
getgenv().VX_AimbotWallCheckMode = "Off"
getgenv().VX_AimbotMode = "Both"
Aimbot:AddDropdown(fn(), {
    Text = "Aimbot Mode",
    Values = {"Camera", "HRP", "Both"},
    Default = 3,
    Callback = function(vxAimbotMode)
        getgenv().VX_AimbotMode = vxAimbotMode
    end,
})
Aimbot:AddDropdown(fn(), {
    Text = "Wall Check",
    Values = {"Off", "Camera", "Character"},
    Default = 1,
    Callback = function(vxAimbotWallCheckMode)
        getgenv().VX_AimbotWallCheckMode = vxAimbotWallCheckMode
    end,
})
Settings:AddDropdown(fn(), {
    Text = "Elliot Target",
    Values = {"Nearest Survivor", "Lowest HP", "Closest to Cursor"},
    Default = "Nearest Survivor",
    Callback = function(vxElliotAimMode)
        getgenv().VX_ElliotAimMode = vxElliotAimMode
    end,
})
Settings:AddDropdown(fn(), {
    Text = "Priority",
    Values = {"Nearest", "Closest to Cursor"},
    Default = 1,
    Callback = function(vxAimbotPriority)
        getgenv().VX_AimbotPriority = vxAimbotPriority
    end,
})
Settings:AddSlider(fn(), {
    Text = "Aim Delay",
    Min = 0,
    Max = 2,
    Default = 0,
    Rounding = 2,
    Suffix = "s",
    Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotDelay = num or 0
        genv16.VX_AimbotDelay = vxAimbotDelay
        getgenv().VX_AimbotWasActive = false
        getgenv().VX_AimbotDelayActive = false
    end,
})
Settings:AddSlider(fn(), {
    Text = "Aim Speed",
    Min = 1,
    Max = 100,
    Default = 20,
    Rounding = 0,
    Suffix = "%",
    Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local n = num or 20
        genv16.VX_AimbotSmoothing = math.clamp(n / 100, 0.01, 1)
    end,
})
Settings:AddSlider(fn(), {
    Text = "Prediction",
    Min = 0,
    Max = 20,
    Default = 0,
    Rounding = 1,
    Suffix = " frames",
    Callback = function(arg)
        local genv16 = getgenv()
        local num = tonumber(arg)
        local vxAimbotPrediction = num or 0
        genv16.VX_AimbotPrediction = vxAimbotPrediction
    end,
})
Settings:AddLabel("Visualizer Color"):AddColorPicker(fn(), {
    Default = Color3.fromRGB(30, 150, 255),
    Title = "Visualizer Color",
    Callback = function(vxBezierColor2)
        getgenv().VX_BezierColor = vxBezierColor2
    end,
})
Settings:AddSlider(fn(), {
    Text = "Aimbot Distance",
    Min = 10,
    Max = 100,
    Default = 100,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(arg)
        local num = tonumber(arg)
        local n = num or 100
        local genv16 = getgenv()
        local huge = n >= 100 and math.huge or n
        genv16.VX_AimbotMaxDistance = huge
    end,
})

end