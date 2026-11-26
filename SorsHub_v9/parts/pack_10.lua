-- SorsHub pack part 10/10
return function(P)
local lib = P["lib@9463,10-9463,13"]
local lib2 = P["lib2@9464,10-9464,14"]
local lib3 = P["lib3@9465,10-9465,14"]
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]
local ui = P["ui@27851,6-27851,8"]
local Spoofer = P["Spoofer@27852,6-27852,13"]
local v24 = P["v24@27854,6-27854,9"]

task.spawn(function()
    local tbl6 = {Username = true, PlayerName = true, PlayerUsername = true}
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    getgenv().VX_ProtectEnabled = false
    local connection2 = nil
    local connection3 = nil
    local tbl7 = {}
    local tbl8 = {}
    local tbl9 = {}
    local tbl10 = {}

    local function fn46(arg)
        if arg:IsA("TextLabel") and tbl6[arg.Name] then
            tbl9[arg] = true
        elseif (arg:IsA("ImageLabel") or arg:IsA("ImageButton")) and arg.Name == "Icon" then
            local parent = arg.Parent

            if parent then
                local flag4 = false

                for i, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextLabel") and tbl6[child.Name] then
                        flag4 = true
                        break
                    end
                end

                if flag4 then
                    tbl10[arg] = true
                end
            end
        end
    end

    local function fn47()
        tbl9 = {}
        tbl10 = {}

        for i, descendant in ipairs(playerGui:GetDescendants()) do
            fn46(descendant)
        end
    end

    local function fn48()
        for k in pairs(tbl10) do
            if k and k.Parent then
                if not tbl7[k] then
                    tbl7[k] = k.Image
                end

                if k.Image ~= "rbxassetid://89532725296741" then
                    k.Image = "rbxassetid://89532725296741"
                end
            else
                tbl10[k] = nil
            end
        end

        for k in pairs(tbl9) do
            if k and k.Parent then
                if not tbl8[k] then
                    tbl8[k] = k.Text
                end

                if k.Text ~= "SorsHub" then
                    k.Text = "SorsHub"
                end
            else
                tbl9[k] = nil
            end
        end
    end

    local function fn49()
        for k, v25 in pairs(tbl7) do
            if k and k.Parent then
                k.Image = v25
            end
        end

        tbl7 = {}

        for k, v25 in pairs(tbl8) do
            if k and k.Parent then
                k.Text = v25
            end
        end

        tbl8 = {}
    end

    local function fn50()
        if connection2 then
            return
        end
        fn47()

        connection3 = playerGui.DescendantAdded:Connect(function(descendant)
            if getgenv().VX_ProtectEnabled then
                fn46(descendant)
            end
        end)

        connection2 = game:GetService("RunService").Heartbeat:Connect(function()
            if getgenv().VX_ProtectEnabled then
                pcall(fn48)
            end
        end)
    end

    local function fn51()
        getgenv().VX_ProtectEnabled = false

        if connection3 then
            connection3:Disconnect()
            connection3 = nil
        end

        if connection2 then
            connection2:Disconnect()
            connection2 = nil
        end

        fn49()
        tbl9 = {}
        tbl10 = {}
    end

    getgenv()._hiddenStatsCache = {}

    ui:AddCheckbox(fn(), {
        Text = "See Hidden Stats",
        Default = false,
        Callback = function(arg)
            if arg then
                getgenv()._hiddenStatsCache = {}
                local v25, v26, v27 = ipairs(game.Players:GetPlayers())
                local v28 = v27
                local v29 = v25
                local v30 = v26

                while true do
                    local v31, v32 = v29(v30, v28)
                    if v31 == nil then
                        break
                    end
                    v28 = v31
                    local playerData = v32:FindFirstChild("PlayerData")
                    local privacy = playerData and v32.PlayerData:FindFirstChild("Settings") and v32.PlayerData.Settings:FindFirstChild("Privacy")

                    if privacy then
                        local tbl11 = {}

                        for i, v33 in ipairs({"HideSurvivorWins", "HidePlaytime", "HideKillerWins"}) do
                            local v34 = privacy:FindFirstChild(v33)

                            if v34 and v34:IsA("BoolValue") then
                                tbl11[v33] = v34.Value
                                v34.Value = false
                            end
                        end

                        v28 = v31
                        getgenv()._hiddenStatsCache[v32.UserId] = {privacy = privacy, values = tbl11}
                    end
                end
            else
                local v25, v26, v27 = pairs(getgenv()._hiddenStatsCache)
                local v28 = v27
                local v29 = v25
                local v30 = v26

                while true do
                    local v31, v32 = v29(v30, v28)
                    if v31 == nil then
                        break
                    end
                    v28 = v31

                    if v32.privacy and v32.privacy.Parent then
                        for k, value in pairs(v32.values) do
                            local v33 = v32.privacy:FindFirstChild(k)

                            if v33 and v33:IsA("BoolValue") then
                                v33.Value = value
                            end
                        end

                        v28 = v31
                    end
                end

                getgenv()._hiddenStatsCache = {}
            end
        end,
    })

    ui:AddCheckbox(fn(), {
        Text = "Protections",
        Default = false,
        Callback = function(vxProtectEnabled)
            getgenv().VX_ProtectEnabled = vxProtectEnabled

            if vxProtectEnabled then
                fn50()
            else
                fn51()
            end
        end,
    })

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local Network = nil

    pcall(function()
        if ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Network") then
            Network = require(ReplicatedStorage.Modules.Network.Network)
        elseif ReplicatedStorage:FindFirstChild("Network") then
            Network = require(ReplicatedStorage.Network)
        end
    end);

    (function()
        local lastInputType = UserInputService:GetLastInputType()
        if lastInputType.Name:find("Gamepad") then
            return "Console"
        end

        if not lastInputType.Name:find("Touch") then
            return "PC"
        end
        return "Mobile"
    end)()

    local v25 = nil

    local function fn52(arg)
        if Network then
            pcall(function()
                Network:FireServerConnection("SetDevice", "REMOTE_EVENT", arg)
            end)
        end
    end

    Spoofer:AddDropdown(fn(), {
        Text = "Device Spoofer",
        Values = {"Console", "Mobile", "PC", "Unknown"},
        Default = nil,
        Callback = function(arg)
            local str = arg == "Unknown" and "Idk" or arg
            v25 = str
            fn52(v25)
        end,
    })

    local function fn53(arg)
        pcall(function()
            local roundTimer = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RoundTimer", 10)
            if not roundTimer then
                return
            end
            local main = roundTimer:WaitForChild("Main", 10)
            if not main then
                return
            end
            local n4

            if arg == "Left" then
                n4 = 0.1
            elseif arg == "Right" then
                n4 = 0.9
            else
                n4 = 0.5
            end

            main.Position = UDim2.new(n4, 0, -0.018, 0)
        end)
    end

    local str = "Middle"

    Spoofer:AddDropdown(fn(), {
        Text = "Timer Position",
        Values = {"Left", "Middle", "Right"},
        Default = 2,
        Callback = function(arg)
            str = arg
            fn53(str)
        end,
    })

    task.spawn(function()
        fn53(str)
    end)

    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        task.delay(1, function()
            fn53(str)
        end)
    end)

    task.spawn(function()
        local spectate = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("Spectate")
        local username = spectate:WaitForChild("Username")
        local clone = username:Clone()
        clone.Name = "FalseUser"
        clone.Visible = false
        clone.Parent = spectate

        ui:AddInput(fn(), {
            Text = "Custom Spectate Username",
            Placeholder = "Enter username",
            Callback = function(text)
                if text == "" then
                    clone.Visible = false
                    username.Visible = true
                else
                    username.Visible = false
                    clone.Text = text
                    clone.Visible = true
                end
            end,
        })
    end)
end)
task.spawn(function()
    local localPlayer = game:GetService("Players").LocalPlayer
    local players = workspace:FindFirstChild("Players")
    local survivors = players and workspace.Players:FindFirstChild("Survivors") or workspace:WaitForChild("Players", 10):WaitForChild("Survivors", 10)

    local function fn46()
        local mainUI = localPlayer.PlayerGui:FindFirstChild("MainUI")
        if not mainUI then
            return
        end
        local statusContainer = mainUI:FindFirstChild("StatusContainer")
        if not statusContainer then
            return
        end
        local slowness = statusContainer:FindFirstChild("Slowness")

        if slowness then
            slowness.Visible = false
        end
    end

    local tbl6 = {
        Slowness = {
            Values = {"SlowedStatus"},
            Connections = {},
            Enabled = false,
            hideUI = true,
        },
        Skills = {
            Values = {
                "StunningKiller",
                "EatFriedChicken",
                "GuestBlocking",
                "PunchAbility",
                "SubspaceTripmine",
                "TaphTripwire",
                "PlasmaBeam",
                "SpawnProtection",
                "c00lgui",
                "ShootingGun",
                "TwoTimeStab",
                "TwoTimeCrouching",
                "DrinkingCola",
                "DrinkingSlateskin",
                "SlateskinStatus",
                "EatingGhostburger",
            },
            Connections = {},
            Enabled = false,
        },
        Items = {
            Values = {"BloxyColaItem", "Medkit"},
            Connections = {},
            Enabled = false,
        },
        Emotes = {Values = {"Emoting"}, Connections = {}, Enabled = false},
        Builderman = {
            Values = {"DispenserConstruction", "SentryConstruction"},
            Connections = {},
            Enabled = false,
        },
    }

    local function fn47(arg, arg2)
        if arg:GetAttribute("Username") ~= localPlayer.Name then
            return
        end

        local connection2 = game:GetService("RunService").RenderStepped:Connect(function()
            if not arg.Parent or not arg2.Enabled then
                return
            end
            local speedMultipliers = arg:FindFirstChild("SpeedMultipliers")

            if speedMultipliers then
                for i, value in ipairs(arg2.Values) do
                    local v25 = speedMultipliers:FindFirstChild(value)

                    if v25 and v25:IsA("NumberValue") and v25.Value ~= 1 then
                        v25.Value = 1
                    end
                end
            end

            if arg2.hideUI then
                fn46()
            end
        end)

        table.insert(arg2.Connections, connection2)
    end

    local function fn48(arg)
        arg.Enabled = true

        for k, child in pairs(survivors:GetChildren()) do
            fn47(child, arg)
        end

        survivors.ChildAdded:Connect(function(child)
            task.wait(0.1)
            fn47(child, arg)
        end)
    end

    local function fn49(arg)
        arg.Enabled = false

        for i, connection2 in ipairs(arg.Connections) do
            if connection2 then
                connection2:Disconnect()
            end
        end

        arg.Connections = {}
    end

    v24:AddCheckbox(fn(), {
        Text = "Anti Speed Slowness",
        Default = false,
        Callback = function(arg)
            if arg then
                fn48(tbl6.Slowness)
            else
                fn49(tbl6.Slowness)
            end
        end,
    })

    v24:AddCheckbox(fn(), {
        Text = "Anti Slow Builderman",
        Default = false,
        Callback = function(arg)
            if arg then
                fn48(tbl6.Builderman)
            else
                fn49(tbl6.Builderman)
            end
        end,
    })

    v24:AddCheckbox(fn(), {
        Text = "Anti Slow Skills",
        Default = false,
        Callback = function(arg)
            local skills = tbl6.Skills

            if arg then
                fn48(skills)

                for k, descendant in pairs(game:GetDescendants()) do
                    if descendant.Name == "jdaw" or descendant.Name == "JDEndlagAxe" then
                        pcall(function()
                            descendant:Destroy()
                        end)
                    end
                end

                if not getgenv()._AntiSlowSkills_HatchetConn then
                    getgenv()._AntiSlowSkills_HatchetConn = game.DescendantAdded:Connect(function(descendant)
                        if descendant.Name == "jdaw" or descendant.Name == "JDEndlagAxe" then
                            task.spawn(function()
                                pcall(function()
                                    descendant:Destroy()
                                end)
                            end)
                        end
                    end)
                end
            else
                fn49(skills)

                if getgenv()._AntiSlowSkills_HatchetConn then
                    getgenv()._AntiSlowSkills_HatchetConn:Disconnect()
                    getgenv()._AntiSlowSkills_HatchetConn = nil
                end
            end
        end,
    })

    v24:AddCheckbox(fn(), {
        Text = "Anti Slow Items",
        Default = false,
        Callback = function(arg)
            if arg then
                fn48(tbl6.Items)
            else
                fn49(tbl6.Items)
            end
        end,
    })

    v24:AddCheckbox(fn(), {
        Text = "Anti Slow Emotes",
        Default = false,
        Callback = function(arg)
            if arg then
                fn48(tbl6.Emotes)
            else
                fn49(tbl6.Emotes)
            end
        end,
    })
end)
task.wait()
local Fun = v:AddTab("Fun", "smile", "Fun features to use")
local Animations = Fun:AddLeftGroupbox("Animations", "person-standing")
local v25 = Fun:AddRightGroupbox("Free Emotes", "person-standing")
task.spawn(function()
    local genv16 = getgenv()
    local runService = getgenv().RunService
    local RunService_ = runService or game:GetService("RunService")
    genv16.RunService = RunService_
    local genv17 = getgenv()
    local players = getgenv().Players
    local Players = players or game:GetService("Players")
    genv17.Players = Players
    local genv18 = getgenv()
    local marketplaceService = getgenv().MarketplaceService
    local MarketplaceService = marketplaceService or game:GetService("MarketplaceService")
    genv18.MarketplaceService = MarketplaceService
    getgenv().player = getgenv().Players.LocalPlayer
    local genv19 = getgenv()
    local replacementAnimations = getgenv().replacementAnimations
    local v26 = replacementAnimations

    if not replacementAnimations then
        local tbl6 = {}
        v26 = tbl6
        tbl6.idle = "rbxassetid://134624270247120"
        tbl6.walk = "rbxassetid://132377038617766"
        tbl6.run = "rbxassetid://115946474977409"
    end

    genv19.replacementAnimations = v26
    local genv20 = getgenv()
    local animationNameCache = getgenv().animationNameCache
    local animationNameCache2 = animationNameCache or {}
    genv20.animationNameCache = animationNameCache2
    local genv21 = getgenv()
    local animReplaceState = getgenv()._animReplaceState
    local animReplaceState2 = animReplaceState or {}
    genv21._animReplaceState = animReplaceState2
    local genv22 = getgenv()
    local fakeinjuredanimation = getgenv().fakeinjuredanimation
    local fakeinjuredanimation2 = fakeinjuredanimation or false
    genv22.fakeinjuredanimation = fakeinjuredanimation2
    local genv23 = getgenv()
    local parseAssetId = getgenv().parseAssetId

    local parseAssetId2 = parseAssetId or function(arg)
        if not arg then
            return nil
        end
        local match = tostring(arg):match("(%d+)")
        local num = match and tonumber(match) or nil
        return num
    end

    genv23.parseAssetId = parseAssetId2
    local genv24 = getgenv()
    local getAnimationNameFromId = getgenv().getAnimationNameFromId

    local getAnimationNameFromId2 = getAnimationNameFromId or function(arg)
        if not arg then
            return nil
        end

        if getgenv().animationNameCache[arg] then
            return getgenv().animationNameCache[arg]
        end

        local ok, result = pcall(function()
            return getgenv().MarketplaceService:GetProductInfo(arg, Enum.InfoType.Asset)
        end)

        if not ok or not result or not result.Name then
            return nil
        end
        getgenv().animationNameCache[arg] = result.Name
        return result.Name
    end

    genv24.getAnimationNameFromId = getAnimationNameFromId2
    local genv25 = getgenv()
    local playReplacementAnimation = getgenv().playReplacementAnimation

    local playReplacementAnimation2 = playReplacementAnimation or function(arg, arg2)
        if not arg or not getgenv().replacementAnimations[arg2] then
            return nil
        end

        local ok, result = pcall(function()
            local flag4 = arg.Parent ~= nil
            return flag4
        end)

        if not ok or not result then
            return nil
        end
        local animation = Instance.new("Animation")
        animation.Name = string.format("__replacement_%s", arg2)
        animation.AnimationId = getgenv().replacementAnimations[arg2]

        local ok2, result2 = pcall(function()
            return arg:LoadAnimation(animation)
        end)

        if not ok2 or not result2 then
            return nil
        end
        result2.Priority = Enum.AnimationPriority.Movement
        result2:Play()
        return result2
    end

    genv25.playReplacementAnimation = playReplacementAnimation2
    local genv26 = getgenv()
    local disconnectIfAlive = getgenv().disconnectIfAlive

    local disconnectIfAlive2 = disconnectIfAlive or function(arg)
        if arg and typeof(arg) == "RBXScriptConnection" then
            arg:Disconnect()
        end
    end

    genv26.disconnectIfAlive = disconnectIfAlive2
    local genv27 = getgenv()
    local setupCharacter = getgenv().setupCharacter

    local setupCharacter2 = setupCharacter or function(arg)
        if not arg then
            return
        end
        local humanoid = arg:WaitForChild("Humanoid")
        local animator = humanoid:FindFirstChildOfClass("Animator")

        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end

        local tbl6 = getgenv()._animReplaceState[arg]

        if tbl6 then
            getgenv().disconnectIfAlive(tbl6.heartbeatConn)
            getgenv().disconnectIfAlive(tbl6.playedConn)

            if tbl6.currentTrack and tbl6.currentTrack.IsPlaying then
                pcall(function()
                    tbl6.currentTrack:Stop()
                end)
            end
        end

        tbl6 = {
            animator = animator,
            humanoid = humanoid,
            currentTrack = nil,
            currentType = nil,
            heartbeatConn = nil,
            playedConn = nil,
        }

        getgenv()._animReplaceState[arg] = tbl6
        local replSet = {}

        for k, replacementAnimation in pairs(getgenv().replacementAnimations) do
            local v27 = getgenv().parseAssetId(replacementAnimation)

            if v27 then
                replSet[v27] = true
            end
        end

        tbl6.replSet = replSet

        tbl6.heartbeatConn = getgenv().RunService.Heartbeat:Connect(function()
            if not getgenv().fakeinjuredanimation then
                return
            end
            local currentTrack = tbl6.currentTrack

            if currentTrack and tbl6.currentType and currentTrack.IsPlaying then
                local walkSpeed = tbl6.humanoid.WalkSpeed
                local n4 = walkSpeed or 16
                local n5 = math.clamp(n4, 0, 100)

                if tbl6.currentType == "idle" then
                    pcall(function()
                        currentTrack:AdjustSpeed(1)
                    end)
                elseif tbl6.currentType == "walk" then
                    pcall(function()
                        currentTrack:AdjustSpeed(math.max(n5 / 12, 0.2))
                    end)
                elseif tbl6.currentType == "run" then
                    pcall(function()
                        currentTrack:AdjustSpeed(math.max(n5 / 26, 0.2))
                    end)
                end
            end
        end)

        tbl6.playedConn = animator.AnimationPlayed:Connect(function(arg2)
            if not getgenv().fakeinjuredanimation then
                return
            end

            if not arg2 or not arg2.Animation then
                return
            end
            local animationId = arg2.Animation.AnimationId
            local str = animationId or ""
            local str2 = tostring(str)
            local v27 = getgenv().parseAssetId(str2)
            if v27 and tbl6.replSet[v27] then
                return
            end

            if tbl6.currentTrack == arg2 then
                return
            end
            local v28 = v27 and getgenv().getAnimationNameFromId(v27) or str2

            if type(v28) == "string" then
                local str3 = v28:lower()
                local pos = str3:find("idle")
                local currentType = pos and "idle"

                if not currentType then
                    local pos2 = str3:find("walk")
                    currentType = pos2 and "walk"
                end

                if not currentType then
                    local pos2 = str3:find("run")
                    currentType = pos2 and "run"
                end

                if currentType then
                    if tbl6.currentTrack then
                        pcall(function()
                            tbl6.currentTrack:Stop()
                        end)
                    end

                    local v29 = getgenv().playReplacementAnimation(animator, currentType)

                    if v29 then
                        tbl6.currentTrack = v29
                        tbl6.currentType = currentType
                    end
                end
            end
        end)
    end

    genv27.setupCharacter = setupCharacter2

    getgenv().player.CharacterRemoving:Connect(function(character)
        local v27 = getgenv()._animReplaceState[character]

        if v27 then
            getgenv().disconnectIfAlive(v27.heartbeatConn)
            getgenv().disconnectIfAlive(v27.playedConn)

            if v27.currentTrack then
                pcall(function()
                    v27.currentTrack:Stop()
                end)
            end

            getgenv()._animReplaceState[character] = nil
        end
    end)

    if getgenv().player.Character then
        getgenv().setupCharacter(getgenv().player.Character)
    end

    getgenv().player.CharacterAdded:Connect(getgenv().setupCharacter)

    Animations:AddCheckbox(fn(), {
        Text = "Fake Injured",
        Default = false,
        Callback = function(fakeinjuredanimation3)
            getgenv().fakeinjuredanimation = fakeinjuredanimation3

            if not fakeinjuredanimation3 then
                for k, v27 in pairs(getgenv()._animReplaceState) do
                    if v27.currentTrack then
                        pcall(function()
                            v27.currentTrack:Stop()
                        end)

                        v27.currentTrack = nil
                        v27.currentType = nil
                    end
                end
            end
        end,
    })

    local genv28 = getgenv()
    local n007MovementEnabled = getgenv()._007_movementEnabled
    local n007MovementEnabled2 = n007MovementEnabled or false
    genv28._007_movementEnabled = n007MovementEnabled2

    Animations:AddCheckbox(fn(), {
        Text = "Fake Clone",
        Default = false,
        Callback = function(n007MovementEnabled3)
            getgenv()._007_movementEnabled = n007MovementEnabled3

            if not n007MovementEnabled3 then
                pcall(function()
                    getgenv()._007_runTrack:Stop(0)
                end)

                pcall(function()
                    getgenv()._007_idleTrack:Stop(0)
                end)
            end
        end,
    })

    local tbl6 = {
        {
            Name = "Sancho",
            Idle = "rbxassetid://134912704311964",
            Walk = "rbxassetid://95213748170889",
            Run = "rbxassetid://75409814098993",
        },
        {
            Name = "Herobrine",
            Idle = "rbxassetid://107799240559806",
            Walk = "rbxassetid://89380107485006",
            Run = "rbxassetid://134157363854022",
        },
        {
            Name = "Sukuna",
            Idle = "rbxassetid://115268929362938",
            Walk = "rbxassetid://123678890237669",
            Run = "rbxassetid://132086389849889",
        },
        {
            Name = "Erlking",
            Idle = "rbxassetid://93727662665079",
            Walk = "rbxassetid://97625643261790",
            Run = "rbxassetid://119357938208454",
        },
        {
            Name = "Martial Artist",
            Idle = "rbxassetid://131082534135875",
            Walk = "rbxassetid://108018357044094",
            Run = "rbxassetid://136252471123500",
        },
    }

    local tbl7 = {}

    for i, v27 in ipairs(tbl6) do
        table.insert(tbl7, v27.Name)
    end

    local genv29 = getgenv()
    local customAnimEnabled = getgenv()._customAnim_enabled
    local customAnimEnabled2 = customAnimEnabled or false
    genv29._customAnim_enabled = customAnimEnabled2
    local genv30 = getgenv()
    local customAnimSelected = getgenv()._customAnim_selected
    local v27 = customAnimSelected or tbl6[1]
    genv30._customAnim_selected = v27
    local genv31 = getgenv()
    local customAnimConn = getgenv()._customAnim_conn
    local v28 = customAnimConn or nil
    genv31._customAnim_conn = v28

    local function fn46()
        pcall(function()
            getgenv()._customAnim_idleTrack:Stop(0)
            getgenv()._customAnim_idleTrack:Destroy()
        end)

        pcall(function()
            getgenv()._customAnim_walkTrack:Stop(0)
            getgenv()._customAnim_walkTrack:Destroy()
        end)

        pcall(function()
            getgenv()._customAnim_runTrack:Stop(0)
            getgenv()._customAnim_runTrack:Destroy()
        end)

        getgenv()._customAnim_idleTrack = nil
        getgenv()._customAnim_walkTrack = nil
        getgenv()._customAnim_runTrack = nil
    end

    local function fn47(arg, arg2)
        fn46()
        local animation = Instance.new("Animation")
        animation.AnimationId = arg2.Idle
        local animation2 = Instance.new("Animation")
        animation2.AnimationId = arg2.Walk
        local animation3 = Instance.new("Animation")
        animation3.AnimationId = arg2.Run
        getgenv()._customAnim_idleTrack = arg:LoadAnimation(animation)
        getgenv()._customAnim_walkTrack = arg:LoadAnimation(animation2)
        getgenv()._customAnim_runTrack = arg:LoadAnimation(animation3)
    end

    local function fn48()
        if getgenv()._customAnim_conn then
            getgenv()._customAnim_conn:Disconnect()
            getgenv()._customAnim_conn = nil
        end

        local localPlayer = game:GetService("Players").LocalPlayer
        local character = localPlayer.Character
        if not character then
            return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart then
            return
        end
        fn47(humanoid, getgenv()._customAnim_selected)
        local animator = humanoid:FindFirstChildOfClass("Animator")

        if animator then
            for i, v29 in ipairs(animator:GetPlayingAnimationTracks()) do
                local animation = v29.Animation
                local animationId = animation and v29.Animation.AnimationId or ""

                if animationId ~= "" then
                    v29:Stop(0)
                end
            end
        end

        getgenv()._customAnim_conn = game:GetService("RunService").Heartbeat:Connect(function()
            if not getgenv()._customAnim_enabled then
                return
            end
            character = localPlayer.Character
            if not character then
                return
            end
            humanoid = character:FindFirstChildOfClass("Humanoid")
            humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not humanoidRootPart then
                return
            end
            local flag4 = humanoid.MoveDirection.Magnitude > 0.1
            local sprintModule = getgenv().SprintModule
            local isSprinting = sprintModule and getgenv().SprintModule.IsSprinting

            if flag4 then
                if isSprinting then
                    if getgenv()._customAnim_idleTrack and getgenv()._customAnim_idleTrack.IsPlaying then
                        getgenv()._customAnim_idleTrack:Stop()
                    end

                    if getgenv()._customAnim_walkTrack and getgenv()._customAnim_walkTrack.IsPlaying then
                        getgenv()._customAnim_walkTrack:Stop()
                    end

                    if getgenv()._customAnim_runTrack and not getgenv()._customAnim_runTrack.IsPlaying then
                        getgenv()._customAnim_runTrack:Play()
                    end
                else
                    if getgenv()._customAnim_idleTrack and getgenv()._customAnim_idleTrack.IsPlaying then
                        getgenv()._customAnim_idleTrack:Stop()
                    end

                    if getgenv()._customAnim_runTrack and getgenv()._customAnim_runTrack.IsPlaying then
                        getgenv()._customAnim_runTrack:Stop()
                    end

                    if getgenv()._customAnim_walkTrack and not getgenv()._customAnim_walkTrack.IsPlaying then
                        getgenv()._customAnim_walkTrack:Play()
                    end
                end
            else
                if getgenv()._customAnim_runTrack and getgenv()._customAnim_runTrack.IsPlaying then
                    getgenv()._customAnim_runTrack:Stop()
                end

                if getgenv()._customAnim_walkTrack and getgenv()._customAnim_walkTrack.IsPlaying then
                    getgenv()._customAnim_walkTrack:Stop()
                end

                if getgenv()._customAnim_idleTrack and not getgenv()._customAnim_idleTrack.IsPlaying then
                    getgenv()._customAnim_idleTrack:Play()
                end
            end
        end)

        localPlayer.CharacterAdded:Connect(function(character2)
            task.wait(0.2)
            if not getgenv()._customAnim_enabled then
                return
            end
            local humanoid2 = character2:WaitForChild("Humanoid", 5)

            if humanoid2 then
                fn47(humanoid2, getgenv()._customAnim_selected)
            end
        end)
    end

    local function fn49()
        if getgenv()._customAnim_conn then
            getgenv()._customAnim_conn:Disconnect()
            getgenv()._customAnim_conn = nil
        end

        fn46()
    end

    Animations:AddCheckbox(fn(), {
        Text = "Enable Custom Animations",
        Default = false,
        Callback = function(customAnimEnabled3)
            getgenv()._customAnim_enabled = customAnimEnabled3

            if customAnimEnabled3 then
                fn48()
            else
                fn49()
            end
        end,
    })

    Animations:AddDropdown(fn(), {
        Text = "Character",
        Values = tbl7,
        Default = 1,
        Callback = function(arg)
            for i, v29 in ipairs(tbl6) do
                if v29.Name == arg then
                    getgenv()._customAnim_selected = v29
                    break
                end
            end

            if getgenv()._customAnim_enabled then
                local character = game:GetService("Players").LocalPlayer.Character

                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    if humanoid then
                        fn47(humanoid, getgenv()._customAnim_selected)
                    end
                end
            end
        end,
    })
end)
task.spawn(function()
    local localPlayer = game:GetService("Players").LocalPlayer
    local v26 = nil
    local humanoid = nil
    local v27 = nil
    local humanoidRootPart = nil

    local function fn46(character)
        v26 = character
        humanoid = character:WaitForChild("Humanoid", 8)
        humanoidRootPart = character:WaitForChild("HumanoidRootPart", 8)
        local v28 = humanoid
        local animator = v28

        if v28 then
            local animator2 = humanoid:FindFirstChildOfClass("Animator")
            animator = animator2 or Instance.new("Animator", humanoid)
        end

        v27 = animator
    end

    if localPlayer.Character then
        fn46(localPlayer.Character)
    end

    localPlayer.CharacterAdded:Connect(fn46)

    local tbl6 = {
        Shucks = {
            Animation = "rbxassetid://74238051754912",
            Sound = "rbxassetid://123236721947419",
        },
        Subterfuge = {
            Animation = "rbxassetid://87482480949358",
            Sound = "rbxassetid://132297506693854",
        },
        ["I Miss The Quiet"] = {
            Animation = "rbxassetid://100986631322204",
            Sound = "rbxassetid://131936418953291",
        },
        ["Silly Billy"] = {
            Animation = "rbxassetid://107464355830477",
            Sound = "rbxassetid://77601084987544",
        },
        ["Thick of It"] = {
            Animation = "rbxassetid://120176009143091",
            Sound = "rbxassetid://120176009143091",
        },
        Hakari = {
            Animation = "rbxassetid://138019937280193",
            Sound = "rbxassetid://109474987384441",
            VFX = function(parent)
                local humanoidRootPart2 = parent and parent:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart2 then
                    return
                end
                local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
                local hakariDance = assets and game:GetService("ReplicatedStorage").Assets:FindFirstChild("Emotes") and game:GetService("ReplicatedStorage").Assets.Emotes:FindFirstChild("HakariDance")
                if not hakariDance then
                    return
                end
                local hakariBeamEffect = hakariDance:FindFirstChild("HakariBeamEffect")
                if not hakariBeamEffect then
                    return
                end
                local clone = hakariBeamEffect:Clone()
                clone.Name = "PlayerEmoteVFX"
                clone.CFrame = humanoidRootPart2.CFrame * CFrame.new(0, -1, -0.3)
                clone.WeldConstraint.Part0 = humanoidRootPart2
                clone.WeldConstraint.Part1 = clone
                clone.Parent = parent
                return clone
            end,
        },
        ["Bang Bang Bang"] = {
            Animation = "rbxassetid://87633945335192",
            Sound = "rbxassetid://84366149407976",
        },
        Locked = {
            Animation = "rbxassetid://77920404652731",
            Sound = "rbxassetid://117520733630504",
            VFX = function(parent)
                local torso = parent and parent:FindFirstChild("Torso")
                if not torso then
                    return
                end
                local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
                local locked = assets and game:GetService("ReplicatedStorage").Assets:FindFirstChild("Emotes") and game:GetService("ReplicatedStorage").Assets.Emotes:FindFirstChild("Locked")
                if not locked then
                    return
                end
                local folder = Instance.new("Folder")
                folder.Name = "PlayerEmoteVFX"
                folder.Parent = parent
                local effect1 = locked:FindFirstChild("Effect1")

                if effect1 then
                    effect1:Clone().Parent = torso
                end

                local effect2 = locked:FindFirstChild("Effect2")

                if effect2 then
                    effect2:Clone().Parent = torso
                end

                return folder
            end,
        },
        Encore = {
            Animation = "rbxassetid://119279036033739",
            Sound = "rbxassetid://128623442010139",
        },
        Rambunctious = {
            Animation = "rbxassetid://134229395028226",
            Sound = "rbxassetid://78302710217332",
        },
        Metroman = {
            Animation = "rbxassetid://130782464742780",
            Sound = "rbxassetid://134449853247802",
        },
        Sukuna = {
            Animation = "rbxassetid://112276030300130",
            Sound = "rbxassetid://137906124003434",
            VFX = function(parent)
                local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
                local sukuna = assets and game:GetService("ReplicatedStorage").Assets:FindFirstChild("Emotes") and game:GetService("ReplicatedStorage").Assets.Emotes:FindFirstChild("Sukuna")
                if not sukuna then
                    return
                end
                local folder = Instance.new("Folder")
                folder.Name = "PlayerEmoteVFX"
                folder.Parent = parent
                local v28, v29, v30 = pairs(sukuna:GetChildren())
                local v31 = v30
                local v32 = v28
                local v33 = v29

                while true do
                    local v34, v35 = v32(v33, v31)
                    if v34 == nil then
                        break
                    end
                    v31 = v34

                    if v35.Name:find("Handle") then
                        local clone = v35:Clone()
                        local motor6D = clone:FindFirstChildWhichIsA("Motor6D")
                        local v36 = string.gsub(clone.Name, "Handle", "")
                        local v37 = parent:FindFirstChild(v36 .. " Arm")

                        if motor6D and v37 then
                            motor6D.Part0 = v37
                            clone.Name = "PlayerEmoteHand"

                            for k, descendant in pairs(clone:GetDescendants()) do
                                if descendant:IsA("BasePart") then
                                    descendant.Color = v37.Color
                                end
                            end

                            v31 = v34
                            clone.Parent = parent
                        end
                    end
                end

                local dismantleFX = sukuna:FindFirstChild("DismantleFX")

                if dismantleFX then
                    local clone = dismantleFX:Clone()
                    clone.DismantleFX.Part0 = parent:FindFirstChild("HumanoidRootPart")
                    clone.Parent = parent
                end

                return folder
            end,
        },
    }

    local v28 = nil
    local v29 = nil
    local v30 = nil

    local function fn47()
        if humanoidRootPart then
            humanoidRootPart.Anchored = true
        end
    end

    local function fn48()
        if humanoidRootPart then
            humanoidRootPart.Anchored = false
        end
    end

    local function fn49()
        if v28 then
            v28:Stop()
            v28 = nil
        end

        if v29 then
            v29:Stop()
            v29:Destroy()
            v29 = nil
        end

        if v30 then
            pcall(function()
                v30:Destroy()
            end)

            if v26 then
                for k, child in pairs(v26:GetChildren()) do
                    if child.Name == "PlayerEmoteVFX" or child.Name == "PlayerEmoteHand" or child.Name == "DismantleFX" then
                        child:Destroy()
                    end
                end

                local torso = v26:FindFirstChild("Torso")

                if torso then
                    for k, child in pairs(torso:GetChildren()) do
                        if child.Name == "Effect1" or child.Name == "Effect2" then
                            child:Destroy()
                        end
                    end
                end
            end

            v30 = nil
        end

        fn48()
    end

    local function fn50(arg)
        local v31 = tbl6[arg]
        if not v31 or not v27 then
            return
        end
        fn49()
        local animation = Instance.new("Animation")
        animation.AnimationId = v31.Animation
        local v32 = v27:LoadAnimation(animation)
        v32.Priority = Enum.AnimationPriority.Action
        v32.Looped = true
        v32:Play()
        local v33 = nil

        if v31.Sound then
            local sound = Instance.new("Sound")
            v33 = sound
            sound.SoundId = v31.Sound
            sound.Volume = 1
            sound.Looped = true
            sound.Parent = v26
            sound:Play()
        end

        v28 = v32
        v29 = v33
        local v34 = nil

        if v31.VFX then
            pcall(function()
                v34 = v31.VFX(v26)
            end)
        end

        v30 = v34
        fn47()
    end

    getgenv()._selectedEmote = "Shucks"

    v25:AddDropdown(fn(), {
        Text = "Play Removed Emote",
        Values = {"Shucks", "Subterfuge", "I Miss The Quiet", "Silly Billy"},
        Default = 1,
        Callback = function(selectedEmote)
            getgenv()._selectedEmote = selectedEmote
        end,
    })

    v25:AddDivider({MarginTop = 2, MarginBottom = 2})

    v25:AddDropdown(fn(), {
        Text = "Purchasable Emotes",
        Values = {
            "Hakari",
            "Bang Bang Bang",
            "Locked",
            "Encore",
            "Rambunctious",
            "Metroman",
            "Sukuna",
        },
        Default = 1,
        Callback = function(selectedEmote)
            getgenv()._selectedEmote = selectedEmote
        end,
    })

    v25:AddCheckbox(fn(), {
        Text = "Play / Stop Emote",
        Default = false,
        Callback = function(arg)
            if arg then
                fn50(getgenv()._selectedEmote)
            else
                fn49()
            end
        end,
    })
end)
task.wait()
local v26 = v:AddTab("UI Settings", "settings", "theme and config management")
lib2:SetLibrary(lib)
lib2:IgnoreThemeSettings()
lib2:SetIgnoreIndexes({"MenuKeybind"})
lib2:SetFolder("SorsHub")
lib2:BuildConfigSection(v26)
lib2:LoadAutoloadConfig()
lib3:SetLibrary(lib)
lib3:SetFolder("SorsHub")
lib3:SetDefaultTheme({
    FontColor = Color3.fromRGB(230, 220, 255),
    MainColor = Color3.fromRGB(18, 14, 32),
    AccentColor = Color3.fromRGB(140, 80, 255),
    BackgroundColor = Color3.fromRGB(11, 8, 22),
    OutlineColor = Color3.fromRGB(35, 18, 65),
})
lib3:ApplyToTab(v26)
lib3:LoadDefault()
local Interface = v26:AddRightGroupbox("Interface", "sliders-horizontal")
Interface:AddCheckbox(fn(), {
    Text = "Custom Cursor",
    Default = false,
    Tooltip = "Enables the Obsidian-styled cursor",
    Callback = function(showCustomCursor)
        lib.ShowCustomCursor = showCustomCursor
    end,
})
Interface:AddDropdown(fn(), {
    Text = "Notification Side",
    Values = {"Left", "Right"},
    Default = "Right",
    Tooltip = "Which side of the screen notifications appear on",
    Callback = function(arg)
        lib:SetNotifySide(arg)
    end,
})
Interface:AddSlider(fn(), {
    Text = "DPI Scale",
    Min = 75,
    Max = 150,
    Default = 100,
    Rounding = 0,
    Tooltip = "Scales the entire UI (100 = normal)",
    Callback = function(arg)
        lib:SetDPIScale(tonumber(arg))
    end,
})
Interface:AddDropdown(fn(), {
    Text = "Font",
    Values = {
        "GothamMedium",
        "Gotham",
        "GothamBold",
        "GothamBlack",
        "Arial",
        "ArialBold",
        "Roboto",
        "SourceSans",
        "SourceSansBold",
        "Code",
    },
    Default = "GothamMedium",
    Tooltip = "Font used across the entire UI",
    Callback = function(arg)
        pcall(function()
            lib:SetFont(Enum.Font[arg])
        end)
    end,
})
Interface:AddDivider({MarginTop = 2, MarginBottom = 2})
Interface:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {Default = "P", NoUI = true, Text = "Toggle menu keybind"})
lib.ToggleKeybind = Options.MenuKeybind

end