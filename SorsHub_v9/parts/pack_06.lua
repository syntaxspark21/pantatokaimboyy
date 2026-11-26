-- SorsHub pack part 6/10
return function(P)
local player = game:GetService("Players").LocalPlayer
do
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]

task.wait()
local v2 = v:AddTab("Auto Block", "shield", "auto block features")
local v3 = v2:AddLeftTabbox()
local v4 = v3:AddTab("Auto-Block")
local Settings = v3:AddTab("Settings")
local Delay = v3:AddTab("Delay")
local v5 = v2:AddRightTabbox()
local Other = v5:AddTab("Other")
local Techs = v5:AddTab("Techs")
-- [SorsHub fix V20.7] Blok preview "Anti Bait Preview" dihapus: AddViewport
-- adalah no-op di WindUI (tidak ada elemen viewport 3D), sehingga section-nya
-- selalu kosong (tercatat 0 di diagnostik). Konstruksi clone/WorldModel dan
-- pencarian ViewportFrame 6 detik ikut dihapus karena hanya melayani preview.
v4:AddCheckbox(fn(), {
        Text = "Auto Block",
        Default = false,
        Callback = function(autoBlockEnabled)
            getgenv().autoBlockEnabled = autoBlockEnabled

            if autoBlockEnabled then
                if getgenv().autoBlockMode == "Normal + Anti Bait" then
                    getgenv().proxBoxEnabled = true
                    getgenv().proxBoxVisible = true
                    getgenv()._proxBox_measureAll()
                end
            else
                getgenv().proxBoxEnabled = false
                getgenv().proxBoxVisible = false
                getgenv()._proxBox_cleanup()
            end
        end,
    })
v4:AddCheckbox(fn(), {
        Text = "Auto Punch",
        Default = false,
        Callback = function(autoPunchEnabled)
            getgenv().autoPunchEnabled = autoPunchEnabled
            getgenv().AutoPunch.Enabled = autoPunchEnabled
        end,
    })
v4:AddDivider({MarginTop = 2, MarginBottom = 2})
v4:AddInput(fn(), {
        Text = "Detection Range",
        Placeholder = "20",
        Callback = function(arg)
            local baseDetectionRange = tonumber(arg)

            if baseDetectionRange and baseDetectionRange >= 1 and baseDetectionRange <= 100 then
                getgenv().baseDetectionRange = baseDetectionRange
                getgenv().detectionRange = baseDetectionRange
            end
        end,
    })
v4:AddCheckbox(fn(), {
        Text = "Show Detection Range",
        Default = false,
        Callback = function(showAutoBlockKillerRadius)
            getgenv().showAutoBlockKillerRadius = showAutoBlockKillerRadius

            if not showAutoBlockKillerRadius then
                for k, killerRadiusAdornment in pairs(getgenv().killerRadiusAdornments) do
                    if killerRadiusAdornment then
                        killerRadiusAdornment:Destroy()
                    end

                    getgenv().killerRadiusAdornments[k] = nil
                end
            end
        end,
    })
Delay:AddSlider(fn(), {
        Text = "Block Delay",
        Default = 0,
        Min = 0,
        Max = 0.5,
        Rounding = 2,
        Callback = function(arg)
            local num = tonumber(arg)
            local blockDelayDuration = num or 0
            getgenv().blockDelayDuration = blockDelayDuration
            local genv = getgenv()
            local blockDelayEnabled = blockDelayDuration > 0
            genv.blockDelayEnabled = blockDelayEnabled
        end,
    })
Delay:AddSlider(fn(), {
        Text = "Punch Delay",
        Default = 0,
        Min = 0,
        Max = 0.5,
        Rounding = 2,
        Callback = function(arg)
            local autoPunch = getgenv().AutoPunch
            local num = tonumber(arg)
            local cooldown = num or 0
            autoPunch.Cooldown = cooldown
        end,
    })
getgenv().proxBoxColor = Color3.fromRGB(255, 60, 60)
getgenv().proxBoxMaterial = Enum.Material.ForceField
getgenv().proxBoxZoneMode = "Part In Zone"
getgenv().proxBoxOffset = 2.5
getgenv().proxBoxDepthMult = 10
getgenv().proxBoxWidthMult = 10
getgenv().proxBoxHeightMult = 8
getgenv().proxBoxTransparency = 0.1
Settings:AddDropdown(fn(), {
        Text = "Range Mode",
        Values = {"Inside", "Inside/Outside"},
        Default = "Inside/Outside",
        Callback = function(autoBlockRangeMode)
            getgenv().autoBlockRangeMode = autoBlockRangeMode
        end,
    })
Settings:AddDropdown(fn(), {
        Text = "Block Mode",
        Values = {"Normal", "Normal + Anti Bait"},
        Default = "Normal",
        Callback = function(autoBlockMode)
            getgenv().autoBlockMode = autoBlockMode

            if autoBlockMode == "Normal + Anti Bait" then
                if getgenv().autoBlockEnabled then
                    getgenv().proxBoxEnabled = true
                    getgenv().proxBoxVisible = true
                    getgenv()._proxBox_measureAll()
                end
            else
                getgenv().proxBoxEnabled = false
                getgenv().proxBoxVisible = false
                getgenv()._proxBox_cleanup()
            end
        end,
    })
Settings:AddDropdown(fn(), {
        Text = "Zone Mode (ANTI BAIT)",
        Values = {"Part In Zone", "Full Body In Zone"},
        Default = "Part In Zone",
        Callback = function(proxBoxZoneMode)
            getgenv().proxBoxZoneMode = proxBoxZoneMode
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Depth Multiplier (ANTI BAIT)",
        Default = 10,
        Min = 0.1,
        Max = 30,
        Rounding = 2,
        Callback = function(arg)
            getgenv().proxBoxDepthMult = tonumber(arg)
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Width Multiplier (ANTI BAIT)",
        Default = 10,
        Min = 0.5,
        Max = 30,
        Rounding = 1,
        Callback = function(arg)
            getgenv().proxBoxWidthMult = tonumber(arg)
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Transparency (ANTI BAIT)",
        Default = 0.1,
        Min = 0.05,
        Max = 0.95,
        Rounding = 2,
        Callback = function(arg)
            getgenv().proxBoxTransparency = tonumber(arg)
        end,
    })
Settings:AddDivider({MarginTop = 2, MarginBottom = 2})
Techs:AddCheckbox(fn(), {
        Text = "HDT",
        Default = false,
        Callback = function(hitboxDraggingEnabled)
            getgenv().hitboxDraggingEnabled = hitboxDraggingEnabled

            if not hitboxDraggingEnabled then
                for k in pairs(getgenv().activeHDT) do
                    getgenv().activeHDT[k] = nil
                end

                local character = getgenv().lp.Character
                local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart then
                    getgenv().setHRPVelocitySafe(humanoidRootPart, Vector3.zero)
                end
            end
        end,
    })
Techs:AddInput(fn(), {
        Text = "HDT Speed",
        Placeholder = "5.6",
        Callback = function(arg)
            local dspeed = tonumber(arg)

            if dspeed and dspeed >= 1 and dspeed <= 20 then
                getgenv().Dspeed = dspeed
            end
        end,
    })
Techs:AddInput(fn(), {
        Text = "HDT Delay",
        Placeholder = "0.3",
        Callback = function(arg)
            local ddelay = tonumber(arg)

            if ddelay and ddelay >= 0 then
                getgenv().Ddelay = ddelay
            end
        end,
    })
Techs:AddInput(fn(), {
        Text = "HDT Detection Range",
        Placeholder = "6",
        Callback = function(arg)
            local hdtDetectRadius = tonumber(arg)

            if hdtDetectRadius and hdtDetectRadius >= 3 and hdtDetectRadius <= 50 then
                getgenv().HDT_DETECT_RADIUS = hdtDetectRadius
            end
        end,
    })
Settings:AddCheckbox(fn(), {
        Text = "Facing Check",
        Default = false,
        Callback = function(verifyFacingCheck)
            getgenv().verifyFacingCheck = verifyFacingCheck
        end,
    })
Settings:AddCheckbox(fn(), {
        Text = "Show Facing Check",
        Default = false,
        Callback = function(showVisionRange)
            getgenv().showVisionRange = showVisionRange

            if not showVisionRange then
                getgenv().cleanupVisionCone()
            end
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Vision Range",
        Default = 15,
        Min = 5,
        Max = 30,
        Rounding = 0,
        Callback = function(arg)
            getgenv().visionRange = tonumber(arg)
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Vision Angle",
        Default = 90,
        Min = 30,
        Max = 180,
        Rounding = 0,
        Callback = function(arg)
            getgenv().visionAngle = tonumber(arg)
        end,
    })
Settings:AddDivider({MarginTop = 2, MarginBottom = 2})
local genv = getgenv()
local wallCheckESPEnabled = getgenv().wallCheckESPEnabled
local wallCheckESPEnabled2 = wallCheckESPEnabled or false
genv.wallCheckESPEnabled = wallCheckESPEnabled2
local genv2 = getgenv()
local wallCheckESPConn = getgenv().wallCheckESPConn
local v6 = wallCheckESPConn or nil
genv2.wallCheckESPConn = v6
local genv3 = getgenv()
local wallCheckBeam = getgenv().wallCheckBeam
local v7 = wallCheckBeam or nil
genv3.wallCheckBeam = v7
local genv4 = getgenv()
local wallCheckBeamA0 = getgenv().wallCheckBeamA0
local v8 = wallCheckBeamA0 or nil
genv4.wallCheckBeamA0 = v8
local genv5 = getgenv()
local wallCheckBeamA1 = getgenv().wallCheckBeamA1
local v9 = wallCheckBeamA1 or nil
genv5.wallCheckBeamA1 = v9
local genv6 = getgenv()
local wallCheckSavedBrickColor = getgenv().wallCheckSavedBrickColor
local v10 = wallCheckSavedBrickColor or nil
genv6.wallCheckSavedBrickColor = v10
local genv7 = getgenv()
local wallCheckSelectMode = getgenv().wallCheckSelectMode
local wallCheckSelectMode2 = wallCheckSelectMode or false
genv7.wallCheckSelectMode = wallCheckSelectMode2
local genv8 = getgenv()
local wallCheckMouseConn = getgenv().wallCheckMouseConn
local v11 = wallCheckMouseConn or nil
genv8.wallCheckMouseConn = v11
getgenv().isWallBlocking = function()
        local character = game.Players.LocalPlayer.Character
        if not character then
            return nil
        end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return nil
        end
        local players = getgenv().Workspace:FindFirstChild("Players")
        local killers = players and players:FindFirstChild("Killers")
        local v12 = killers
        if not killers then
            return nil
        end
        local huge = math.huge
        local v13 = nil

        for i, child in ipairs(v12:GetChildren()) do
            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart2 then
                local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

                if magnitude < huge then
                    huge = magnitude
                    v13 = humanoidRootPart2
                end
            end
        end

        if not v13 then
            return nil
        end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character, v12}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.IgnoreWater = true
        local flag = getgenv().Workspace:Raycast(humanoidRootPart.Position, v13.Position - humanoidRootPart.Position, raycastParams) ~= nil
        return flag
    end
getgenv().createWallCheckBeam = function()
        if getgenv().wallCheckBeam then
            return
        end
        local character = game.Players.LocalPlayer.Character
        if not character then
            return
        end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return
        end
        local players = getgenv().Workspace:FindFirstChild("Players")
        local killers = players and players:FindFirstChild("Killers")
        local v12 = killers
        if not killers then
            return
        end
        local huge = math.huge
        local v13 = nil

        for i, child in ipairs(v12:GetChildren()) do
            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart2 then
                local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

                if magnitude < huge then
                    huge = magnitude
                    v13 = humanoidRootPart2
                end
            end
        end

        if not v13 then
            return
        end
        local attachment = Instance.new("Attachment")
        local attachment2 = Instance.new("Attachment")
        attachment.Parent = humanoidRootPart
        attachment2.Parent = v13
        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment
        beam.Attachment1 = attachment2
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.FaceCamera = true
        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
        beam.Parent = getgenv().Workspace
        getgenv().wallCheckBeam = beam
        getgenv().wallCheckBeamA0 = attachment
        getgenv().wallCheckBeamA1 = attachment2
    end
getgenv().destroyWallCheckBeam = function()
        if getgenv().wallCheckBeam then
            getgenv().wallCheckBeam:Destroy()
            getgenv().wallCheckBeam = nil
        end

        if getgenv().wallCheckBeamA0 then
            getgenv().wallCheckBeamA0:Destroy()
            getgenv().wallCheckBeamA0 = nil
        end

        if getgenv().wallCheckBeamA1 then
            getgenv().wallCheckBeamA1:Destroy()
            getgenv().wallCheckBeamA1 = nil
        end
    end
getgenv().startWallCheckESP = function()
        if getgenv().wallCheckESPConn then
            return
        end

        getgenv().wallCheckESPConn = game:GetService("RunService").RenderStepped:Connect(function()
            if not getgenv().wallCheckESPEnabled then
                return
            end
            getgenv().createWallCheckBeam()
            local wallCheckBeam2 = getgenv().wallCheckBeam
            if not wallCheckBeam2 then
                return
            end
            local v12 = getgenv().isWallBlocking()

            if v12 == nil then
                getgenv().destroyWallCheckBeam()
            elseif v12 then
                wallCheckBeam2.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
            else
                wallCheckBeam2.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
            end
        end)
    end
getgenv().stopWallCheckESP = function()
        if getgenv().wallCheckESPConn then
            getgenv().wallCheckESPConn:Disconnect()
            getgenv().wallCheckESPConn = nil
        end

        getgenv().destroyWallCheckBeam()
    end
Settings:AddCheckbox(fn(), {
        Text = "Wall Check",
        Default = false,
        Callback = function(autoBlockLOS)
            getgenv().autoBlockLOS = autoBlockLOS
        end,
    })
Settings:AddCheckbox(fn(), {
        Text = "Wall Check ESP",
        Default = false,
        Callback = function(wallCheckESPEnabled3)
            getgenv().wallCheckESPEnabled = wallCheckESPEnabled3

            if wallCheckESPEnabled3 then
                getgenv().startWallCheckESP()
            else
                getgenv().stopWallCheckESP()
            end
        end,
    })
Settings:AddDivider({MarginTop = 2, MarginBottom = 2})
Settings:AddLabel("<font color=\"#add8e6\">If the killer is higher than your character and uses M1 it wont block so you wont waste your ability</font>", true)
Settings:AddCheckbox(fn(), {
        Text = "High Elevation Check",
        Default = false,
        Callback = function(elevationCheckEnabled)
            getgenv().elevationCheckEnabled = elevationCheckEnabled
        end,
    })
Settings:AddDivider({MarginTop = 2, MarginBottom = 2})
Settings:AddCheckbox(fn(), {
        Text = "Zone if killer walks",
        Default = false,
        Callback = function(antiBaitWalkEnabled)
            getgenv().antiBaitWalkEnabled = antiBaitWalkEnabled
        end,
    })
Settings:AddCheckbox(fn(), {
        Text = "Zone if killer stands",
        Default = false,
        Callback = function(antiBaitIdleEnabled)
            getgenv().antiBaitIdleEnabled = antiBaitIdleEnabled
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Stand Zone Range",
        Default = 18,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(arg)
            getgenv().antiBaitIdleRange = tonumber(arg)
        end,
    })
Settings:AddSlider(fn(), {
        Text = "Walk Zone Range",
        Default = 18,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(arg)
            getgenv().antiBaitWalkRange = tonumber(arg)
        end,
    })
getgenv().blockAnimIds = {
        "98105697395689",
        "115706752305794",
        "72182155407310",
        "95802026624883",
        "96959123077498",
        "72722244508749",
        "138407964761603",
    }
getgenv().punchAnimIds = {
        "108911997126897",
        "82137285150006",
        "129843313690921",
        "140703210927645",
        "136007065400978",
        "86096387000557",
        "87259391926321",
        "86709774283672",
        "72685103823181",
    }
getgenv().createAnimationBlocker = function(arg)
        local flag = false
        local tbl = {}

        for i, v12 in ipairs(arg) do
            tbl[tostring(v12)] = true
        end

        local tbl2 = {}
        local tbl3 = {}

        local function fn2(arg2)
            if not arg2 or not arg2.Animation then
                return false
            end
            local match = tostring(arg2.Animation.AnimationId):match("%d+")
            local flag2 = match ~= nil and tbl[match] == true
            return flag2
        end

        local function fn3(arg2)
            if not flag then
                return
            end

            pcall(function()
                if fn2(arg2) then
                    arg2:Stop(0)
                end
            end)

            task.defer(function()
                if flag and fn2(arg2) then
                    pcall(function()
                        arg2:Stop(0)
                    end)
                end
            end)
        end

        local function fn4()
            for i, v12 in ipairs(tbl2) do
                pcall(function()
                    v12:Disconnect()
                end)
            end

            tbl2 = {}
        end

        local function fn5(arg2)
            fn4()
            if not arg2 then
                return
            end
            local humanoid = arg2:WaitForChild("Humanoid", 8)
            if not humanoid then
                return
            end
            local animator = humanoid:FindFirstChildOfClass("Animator")
            local animator2 = animator or Instance.new("Animator", humanoid)
            table.insert(tbl2, animator2.AnimationPlayed:Connect(fn3))

            if flag then
                for i, v12 in ipairs(animator2:GetPlayingAnimationTracks()) do
                    fn3(v12)
                end
            end

            table.insert(tbl2, arg2:GetAttributeChangedSignal("SkinName"):Connect(function()
                task.wait(0.3);
                fn5(arg2)
            end))
        end

        local tbl4 = {}

        tbl4.Enable = function()
            flag = true
            local character = player.Character

            if character then
                fn5(character)
            end

            if not tbl4._charConn then
                tbl4._charConn = player.CharacterAdded:Connect(function(character2)
                    task.wait(0.3)
                    fn5(character2)
                end)

                table.insert(tbl3, tbl4._charConn)
            end
        end

        tbl4.Disable = function()
            flag = false
        end

        tbl4.IsEnabled = function()
            return flag
        end

        tbl4.AddId = function(arg2)
            local match = tostring(arg2):match("%d+")
            local str = match or ""

            if str ~= "" then
                tbl[str] = true
            end

            if flag and player.Character then
                fn5(player.Character)
            end
        end

        tbl4.Destroy = function()
            fn4()

            for i, v12 in ipairs(tbl3) do
                pcall(function()
                    v12:Disconnect()
                end)
            end

            tbl3 = {}
            flag = false
        end

        return tbl4
    end
getgenv().ghostBlocker = getgenv().createAnimationBlocker(getgenv().blockAnimIds)
getgenv().ghostPuncher = getgenv().createAnimationBlocker(getgenv().punchAnimIds)
Other:AddCheckbox(fn(), {
        Text = "Ghost Block",
        Default = false,
        Callback = function(arg)
            if arg then
                getgenv().ghostBlocker:Enable()
            else
                getgenv().ghostBlocker:Disable()
            end
        end,
    })
Other:AddCheckbox(fn(), {
        Text = "Ghost Punch",
        Default = false,
        Callback = function(arg)
            if arg then
                getgenv().ghostPuncher:Enable()
            else
                getgenv().ghostPuncher:Disable()
            end
        end,
    })
Other:AddDivider({MarginTop = 2, MarginBottom = 2})
local genv9 = getgenv()
local pingGuiEnabled = getgenv().pingGuiEnabled
local pingGuiEnabled2 = pingGuiEnabled or false
genv9.pingGuiEnabled = pingGuiEnabled2
local genv10 = getgenv()
local pingGuiScreenGui = getgenv().pingGuiScreenGui
local v12 = pingGuiScreenGui or nil
genv10.pingGuiScreenGui = v12
local genv11 = getgenv()
local pingGuiConnection = getgenv().pingGuiConnection
local v13 = pingGuiConnection or nil
genv11.pingGuiConnection = v13
getgenv().createPingGui = function()
        if getgenv().pingGuiScreenGui then
            return
        end
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PingDisplay"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 110, 0, 38)
        frame.Position = UDim2.new(1, -128, 0, 28)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
        frame.BackgroundTransparency = 0.35
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 12)
        uiCorner.Parent = frame
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(100, 100, 255)
        uiStroke.Thickness = 1.5
        uiStroke.Transparency = 0.6
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.Parent = frame
        local uiGradient = Instance.new("UIGradient")

        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40)),
        })

        uiGradient.Rotation = 90
        uiGradient.Parent = frame
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -12, 1, -8)
        textLabel.Position = UDim2.new(0, 6, 0, 4)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Ping: --- ms"
        textLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Parent = frame
        getgenv().pingGuiScreenGui = screenGui

        getgenv().pingGuiConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local v14 = math.round(game.Players.LocalPlayer:GetNetworkPing() * 1000)
            textLabel.Text = "Ping: " .. v14 .. " ms"

            if v14 <= 80 then
                textLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
                uiStroke.Color = Color3.fromRGB(80, 255, 120)
            elseif v14 <= 150 then
                textLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
                uiStroke.Color = Color3.fromRGB(255, 220, 80)
            else
                textLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                uiStroke.Color = Color3.fromRGB(255, 80, 80)
            end
        end)
    end
getgenv().destroyPingGui = function()
        if getgenv().pingGuiConnection then
            getgenv().pingGuiConnection:Disconnect()
            getgenv().pingGuiConnection = nil
        end

        if getgenv().pingGuiScreenGui then
            getgenv().pingGuiScreenGui:Destroy()
            getgenv().pingGuiScreenGui = nil
        end
    end
Other:AddCheckbox(fn(), {
        Text = "Show Ping",
        Default = false,
        Callback = function(pingGuiEnabled3)
            getgenv().pingGuiEnabled = pingGuiEnabled3

            if pingGuiEnabled3 then
                getgenv().createPingGui()
            else
                getgenv().destroyPingGui()
            end
        end,
    })
Other:AddDivider({MarginTop = 2, MarginBottom = 2})
Other:AddCheckbox(fn(), {
        Text = "Aim Punch",
        Default = false,
        Callback = function(aimPunchActive)
            getgenv().aimPunchActive = aimPunchActive

            if aimPunchActive and getgenv().lp.Character then
                getgenv().setupAimPunch(getgenv().lp.Character)
            end
        end,
    })
Other:AddDropdown(fn(), {
        Text = "Aim Mode",
        Values = {"HRP", "CamLock"},
        Default = "HRP",
        Callback = function(aimPunchMode)
            getgenv().aimPunchMode = aimPunchMode
        end,
    })
Other:AddDivider({MarginTop = 2, MarginBottom = 2})
getgenv().VX_AutoParryEnabled = false
getgenv().VX_AutoParryKiller = "Slasher"
getgenv().VX_ParryRemote = "404 Error"
getgenv().Error404Range = 14
getgenv().Error404AutoParryEnabled = false
getgenv()._ERR404_CONNS = {}
getgenv()._ERR404_SOUNDHOOKS = {}
getgenv()._ERR404_TRIGGERED = {}
getgenv().RAGING_RANGE = 19
getgenv().RAGING_ENABLED = false
getgenv().RAGING_COOLDOWN = 5
getgenv()._RAGING_CONNS = {}
getgenv()._RAGING_TRIGGERED = {}
getgenv().Players = game:GetService("Players")
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().lp = getgenv().Players.LocalPlayer
local tbl = {
        ["116618003477002"] = true,
        ["119462383658044"] = true,
        ["131696603025265"] = true,
        ["121255898612475"] = true,
        ["133491532453922"] = true,
        ["103601716322988"] = true,
        ["86371356500204"] = true,
        ["72722244508749"] = true,
        ["87259391926321"] = true,
        ["96959123077498"] = true,
        ["100725497418533"] = true,
        ["115194624791339"] = true,
        ["89448354637442"] = true,
        ["108773914369470"] = true,
        ["105614318732282"] = true,
        ["77448521277146"] = true,
        ["110400453990786"] = true,
        ["108911997126897"] = true,
        ["82137285150006"] = true,
        ["129843313690921"] = true,
        ["140703210927645"] = true,
        ["136007065400978"] = true,
        ["86096387000557"] = true,
        ["86709774283672"] = true,
        ["72685103823181"] = true,
        ["106086955212611"] = true,
        ["111918351126361"] = true,
        ["127821549546951"] = true,
        ["79331370895011"] = true,
        ["81227838714974"] = true,
        ["122503338277352"] = true,
        ["98031287364865"] = true,
    }
local tbl2 = {["86710781315432"] = true, ["99820161736138"] = true}
local tbl3 = {
        ["86710781315432"] = true,
        ["99820161736138"] = true,
        ["609342351"] = true,
        ["81976396729343"] = true,
        ["12222225"] = true,
        ["80521472651047"] = true,
        ["139012439429121"] = true,
        ["91194698358028"] = true,
        ["111910850942168"] = true,
        ["83851356262523"] = true,
    }
local tbl4 = {
        ["86545133269813"] = true,
        ["89448354637442"] = true,
        ["87259391926321"] = true,
        ["73921036900313"] = true,
        ["90499469533503"] = true,
        ["119462383658044"] = true,
        ["116618003477002"] = true,
        ["131696603025265"] = true,
        ["111313169447787"] = true,
        ["100725497418533"] = true,
        ["115194624791339"] = true,
        ["108911997126897"] = true,
        ["82137285150006"] = true,
        ["129843313690921"] = true,
        ["140703210927645"] = true,
        ["136007065400978"] = true,
        ["86096387000557"] = true,
        ["86709774283672"] = true,
        ["72685103823181"] = true,
        ["106086955212611"] = true,
        ["111918351126361"] = true,
        ["127821549546951"] = true,
        ["79331370895011"] = true,
        ["81227838714974"] = true,
        ["122503338277352"] = true,
        ["98031287364865"] = true,
    }
local function fn2()
        pcall(function()
            getgenv().ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("Network", 10):WaitForChild("Network", 10):WaitForChild("RemoteEvent", 10):FireServer("UseActorAbility", {buffer.fromstring("\003\n\000\000\000RagingPace")})
        end)
    end
local function fn3(arg)
        local character = getgenv().lp.Character
        local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart or not arg then
            return false
        end
        local flag = (humanoidRootPart.Position - arg.Position).Magnitude <= getgenv().RAGING_RANGE
        return flag
    end
local function fn4(arg)
        local now = os.clock()
        if getgenv()._RAGING_TRIGGERED[arg] and now < getgenv()._RAGING_TRIGGERED[arg] then
            return
        end
        getgenv()._RAGING_TRIGGERED[arg] = now + getgenv().RAGING_COOLDOWN
        task.spawn(fn2)
    end
local function fn5(arg)
        if arg:GetAttribute("_VX_RAGING_HOOKED") then
            return
        end
        arg:SetAttribute("_VX_RAGING_HOOKED", true)

        local connection = arg.AnimationPlayed:Connect(function(arg2)
            if not getgenv().RAGING_ENABLED then
                return
            end
            local animation = arg2.Animation
            if not animation then
                return
            end
            local match = tostring(animation.AnimationId):match("%d+$")
            if not match or not tbl[match] then
                return
            end
            local parent = arg.Parent
            local humanoidRootPart = parent and arg.Parent:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart or not fn3(humanoidRootPart) then
                return
            end
            fn4(arg2)
        end)

        table.insert(getgenv()._RAGING_CONNS, connection)
    end
local function fn6(arg)
        local function fn7()
            if not getgenv().RAGING_ENABLED or not arg.IsPlaying then
                return
            end
            local match = tostring(arg.SoundId):match("%d+$")
            if not match or not tbl2[match] then
                return
            end
            local isBasePart = arg.Parent:IsA("BasePart")
            local parent = isBasePart and arg.Parent or arg.Parent:FindFirstChildWhichIsA("BasePart", true)
            if not parent or not fn3(parent) then
                return
            end
            fn4(arg)
        end

        table.insert(getgenv()._RAGING_CONNS, arg.Played:Connect(fn7))
        table.insert(getgenv()._RAGING_CONNS, arg:GetPropertyChangedSignal("IsPlaying"):Connect(fn7))
    end
local function fn7()
        for i, descendant in ipairs(game:GetDescendants()) do
            if descendant:IsA("Humanoid") then
                fn5(descendant)
            elseif descendant:IsA("Sound") then
                fn6(descendant)
            end
        end

        table.insert(getgenv()._RAGING_CONNS, game.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Humanoid") then
                fn5(descendant)
            elseif descendant:IsA("Sound") then
                fn6(descendant)
            end
        end))
    end
local function fn8()
        for i, ragingConn in ipairs(getgenv()._RAGING_CONNS) do
            pcall(function()
                ragingConn:Disconnect()
            end)
        end

        getgenv()._RAGING_CONNS = {}
        getgenv()._RAGING_TRIGGERED = {}
    end
local function fn9()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer("UseActorAbility", {buffer.fromstring("\003\008\000\000\000404Error")})
        end)
    end
local function fn10()
        pcall(function()
            game:GetService("ReplicatedStorage").Modules.Network.Network.RemoteEvent:FireServer("UseActorAbility", {buffer.fromstring("\003\r\000\000\000CorruptEnergy")})
        end)
    end
local function fn11(arg)
        if getgenv()._ERR404_SOUNDHOOKS[arg] then
            return
        end
        getgenv()._ERR404_SOUNDHOOKS[arg] = true

        local function fn12()
            if not getgenv().Error404AutoParryEnabled or not arg.IsPlaying then
                return
            end
            local match = tostring(arg.SoundId):match("%d+$")
            local str = match or ""
            if str == "" or not tbl3[str] then
                return
            end
            local character = getgenv().lp.Character
            local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then
                return
            end
            local isBasePart = arg.Parent:IsA("BasePart")
            local parent = isBasePart and arg.Parent or arg.Parent:FindFirstChildWhichIsA("BasePart", true)
            if not parent then
                return
            end
            local now = os.clock()
            if getgenv()._ERR404_TRIGGERED[arg] and now < getgenv()._ERR404_TRIGGERED[arg] then
                return
            end

            if (humanoidRootPart.Position - parent.Position).Magnitude <= getgenv().Error404Range then
                fn9()
                getgenv()._ERR404_TRIGGERED[arg] = now + 1.2
            end
        end

        table.insert(getgenv()._ERR404_CONNS, arg.Played:Connect(fn12))

        table.insert(getgenv()._ERR404_CONNS, arg:GetPropertyChangedSignal("IsPlaying"):Connect(function()
            if arg.IsPlaying then
                fn12()
            end
        end))
    end
local function fn12(arg)
        if arg:GetAttribute("_ERR404_HOOKED") then
            return
        end
        arg:SetAttribute("_ERR404_HOOKED", true)

        local connection = arg.AnimationPlayed:Connect(function(arg2)
            if not getgenv().Error404AutoParryEnabled then
                return
            end
            local animation = arg2.Animation
            if not animation then
                return
            end
            local match = tostring(animation.AnimationId):match("%d+$")
            local str = match or ""
            if str == "" or not tbl4[str] then
                return
            end
            local parent = arg.Parent
            local humanoidRootPart = parent and arg.Parent:FindFirstChild("HumanoidRootPart")
            local character = getgenv().lp.Character
            local humanoidRootPart2 = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart or not humanoidRootPart2 then
                return
            end
            local now = os.clock()
            if getgenv()._ERR404_TRIGGERED[arg2] and now < getgenv()._ERR404_TRIGGERED[arg2] then
                return
            end

            if (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= getgenv().Error404Range then
                fn9()
                getgenv()._ERR404_TRIGGERED[arg2] = now + 1.2
            end
        end)

        table.insert(getgenv()._ERR404_CONNS, connection)
    end
local function fn13()
        for i, descendant in ipairs(game:GetDescendants()) do
            if descendant:IsA("Sound") then
                fn11(descendant)
            elseif descendant:IsA("Humanoid") then
                fn12(descendant)
            end
        end

        table.insert(getgenv()._ERR404_CONNS, game.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Sound") then
                fn11(descendant)
            elseif descendant:IsA("Humanoid") then
                fn12(descendant)
            end
        end))
    end
local function fn14()
        for i, err404Conn in ipairs(getgenv()._ERR404_CONNS) do
            pcall(function()
                err404Conn:Disconnect()
            end)
        end

        getgenv()._ERR404_CONNS = {}
        getgenv()._ERR404_SOUNDHOOKS = {}
        getgenv()._ERR404_TRIGGERED = {}
    end
local function fn15()
        fn8()
        fn14()
        if not getgenv().VX_AutoParryEnabled then
            return
        end

        if getgenv().VX_AutoParryKiller == "Slasher" then
            getgenv().RAGING_ENABLED = true
            fn7()
        else
            getgenv().Error404AutoParryEnabled = true
            fn13()
        end
    end
local v14 = fn9
fn9 = function()
        if getgenv().VX_ParryRemote == "Corrupt Energy" then
            fn10()
        else
            v14()
        end
    end
Other:AddCheckbox(fn(), {
        Text = "Auto Parry",
        Default = false,
        Callback = function(vxAutoParryEnabled)
            getgenv().VX_AutoParryEnabled = vxAutoParryEnabled
            fn15()
        end,
    })
Other:AddDropdown(fn(), {
        Text = "Killer",
        Values = {"Slasher", "John Doe"},
        Default = "Slasher",
        Callback = function(arg)
            local genv12 = getgenv()
            local vxAutoParryKiller = arg == "John Doe" and "JohnDoe" or arg
            genv12.VX_AutoParryKiller = vxAutoParryKiller
            fn15()
        end,
    })
Other:AddDropdown(fn(), {
        Text = "Parry Mode JD",
        Values = {"404 Error", "Corrupt Energy"},
        Default = "404 Error",
        Callback = function(vxParryRemote)
            getgenv().VX_ParryRemote = vxParryRemote
        end,
    })
Other:AddInput(fn(), {
        Text = "Detection Range",
        Placeholder = "5 - 50",
        Callback = function(arg)
            local num = tonumber(arg)
            if not num then
                return
            end
            local ragingRange = math.clamp(num, 5, 50)
            getgenv().RAGING_RANGE = ragingRange
            getgenv().Error404Range = ragingRange
        end,
    })
end

getgenv().lp = game:GetService("Players").LocalPlayer
getgenv().RunService = game:GetService("RunService")
getgenv().Workspace = game:GetService("Workspace")
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().testRemote = getgenv().ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent")
getgenv().blockAction = "UseActorAbility"
getgenv().blockData = {buffer.fromstring("\003\005\000\000\000Block")}
getgenv().punchAction = "UseActorAbility"
getgenv().punchData = {buffer.fromstring("\003\005\000\000\000Punch")}
getgenv().KillersFolder = getgenv().Workspace:WaitForChild("Players"):WaitForChild("Killers")
do
local genv12 = getgenv()
local autoBlockEnabled = getgenv().autoBlockEnabled
local autoBlockEnabled2 = autoBlockEnabled or false
genv12.autoBlockEnabled = autoBlockEnabled2
end

do
local genv13 = getgenv()
local autoBlockMode = getgenv().autoBlockMode
local autoBlockMode2 = autoBlockMode or "Normal"
genv13.autoBlockMode = autoBlockMode2
end

do
local genv14 = getgenv()
local autoBlockRangeMode = getgenv().autoBlockRangeMode
local autoBlockRangeMode2 = autoBlockRangeMode or "Inside/Outside"
genv14.autoBlockRangeMode = autoBlockRangeMode2
end

do
local genv15 = getgenv()
local blockDelayEnabled = getgenv().blockDelayEnabled
local blockDelayEnabled2 = blockDelayEnabled or false
genv15.blockDelayEnabled = blockDelayEnabled2
end

do
local genv16 = getgenv()
local blockDelayDuration = getgenv().blockDelayDuration
local blockDelayDuration2 = blockDelayDuration or 0
genv16.blockDelayDuration = blockDelayDuration2
end

do
local genv17 = getgenv()
local autoPunchEnabled = getgenv().autoPunchEnabled
local autoPunchEnabled2 = autoPunchEnabled or false
genv17.autoPunchEnabled = autoPunchEnabled2
end

do
local genv18 = getgenv()
local autoBlockLOS = getgenv().autoBlockLOS
local autoBlockLOS2 = autoBlockLOS or false
genv18.autoBlockLOS = autoBlockLOS2
end

do
local genv19 = getgenv()
local elevationCheckEnabled = getgenv().elevationCheckEnabled
local elevationCheckEnabled2 = elevationCheckEnabled or false
genv19.elevationCheckEnabled = elevationCheckEnabled2
end

do
local genv20 = getgenv()
local elevationKillerHigherThreshold = getgenv().elevationKillerHigherThreshold
local elevationKillerHigherThreshold2 = elevationKillerHigherThreshold or 3
genv20.elevationKillerHigherThreshold = elevationKillerHigherThreshold2
end

do
local genv21 = getgenv()
local elevationIAmHigherThreshold = getgenv().elevationIAmHigherThreshold
local elevationIAmHigherThreshold2 = elevationIAmHigherThreshold or 3
genv21.elevationIAmHigherThreshold = elevationIAmHigherThreshold2
end

do
local genv22 = getgenv()
local baseDetectionRange = getgenv().baseDetectionRange
local baseDetectionRange2 = baseDetectionRange or 20
genv22.baseDetectionRange = baseDetectionRange2
end

do
local genv23 = getgenv()
local detectionRange = getgenv().detectionRange
local detectionRange2 = detectionRange or 20
genv23.detectionRange = detectionRange2
end

do
local genv24 = getgenv()
local antiBaitWalkEnabled = getgenv().antiBaitWalkEnabled
local antiBaitWalkEnabled2 = antiBaitWalkEnabled or false
genv24.antiBaitWalkEnabled = antiBaitWalkEnabled2
end

do
local genv25 = getgenv()
local antiBaitWalkRange = getgenv().antiBaitWalkRange
local antiBaitWalkRange2 = antiBaitWalkRange or 18
genv25.antiBaitWalkRange = antiBaitWalkRange2
end

do
local genv26 = getgenv()
local antiBaitIdleEnabled = getgenv().antiBaitIdleEnabled
local antiBaitIdleEnabled2 = antiBaitIdleEnabled or false
genv26.antiBaitIdleEnabled = antiBaitIdleEnabled2
end

do
local genv27 = getgenv()
local antiBaitIdleRange = getgenv().antiBaitIdleRange
local antiBaitIdleRange2 = antiBaitIdleRange or 18
genv27.antiBaitIdleRange = antiBaitIdleRange2
end

do
local genv28 = getgenv()
local showAutoBlockKillerRadius = getgenv().showAutoBlockKillerRadius
local showAutoBlockKillerRadius2 = showAutoBlockKillerRadius or false
genv28.showAutoBlockKillerRadius = showAutoBlockKillerRadius2
end

do
local genv29 = getgenv()
local killerRadiusAdornments = getgenv().killerRadiusAdornments
local killerRadiusAdornments2 = killerRadiusAdornments or {}
genv29.killerRadiusAdornments = killerRadiusAdornments2
end

do
local genv30 = getgenv()
local verifyFacingCheck = getgenv().verifyFacingCheck
local verifyFacingCheck2 = verifyFacingCheck or false
genv30.verifyFacingCheck = verifyFacingCheck2
end

do
local genv31 = getgenv()
local visionRange = getgenv().visionRange
local visionRange2 = visionRange or 15
genv31.visionRange = visionRange2
end

do
local genv32 = getgenv()
local visionAngle = getgenv().visionAngle
local visionAngle2 = visionAngle or 90
genv32.visionAngle = visionAngle2
end

do
local genv33 = getgenv()
local facingCheckMode = getgenv().facingCheckMode
local facingCheckMode2 = facingCheckMode or "Killer Facing Me"
genv33.facingCheckMode = facingCheckMode2
end

do
local genv34 = getgenv()
local showVisionRange = getgenv().showVisionRange
local showVisionRange2 = showVisionRange or false
genv34.showVisionRange = showVisionRange2
end

do
local genv35 = getgenv()
local proxBoxEnabled = getgenv().proxBoxEnabled
local proxBoxEnabled2 = proxBoxEnabled or false
genv35.proxBoxEnabled = proxBoxEnabled2
end

do
local genv36 = getgenv()
local proxBoxVisible = getgenv().proxBoxVisible
local proxBoxVisible2 = proxBoxVisible or false
genv36.proxBoxVisible = proxBoxVisible2
end

do
local genv37 = getgenv()
local proxBoxAdornments = getgenv().proxBoxAdornments
local proxBoxAdornments2 = proxBoxAdornments or {}
genv37.proxBoxAdornments = proxBoxAdornments2
end

do
local genv38 = getgenv()
local proxBoxLockedSizes = getgenv().proxBoxLockedSizes
local proxBoxLockedSizes2 = proxBoxLockedSizes or {}
genv38.proxBoxLockedSizes = proxBoxLockedSizes2
end

do
local genv39 = getgenv()
local proxBoxColor = getgenv().proxBoxColor
local color = proxBoxColor or Color3.fromRGB(255, 60, 60)
genv39.proxBoxColor = color
end

do
local genv40 = getgenv()
local proxBoxMaterial = getgenv().proxBoxMaterial
local forceField = proxBoxMaterial or Enum.Material.ForceField
genv40.proxBoxMaterial = forceField
end

do
local genv41 = getgenv()
local proxBoxZoneMode = getgenv().proxBoxZoneMode
local proxBoxZoneMode2 = proxBoxZoneMode or "Part In Zone"
genv41.proxBoxZoneMode = proxBoxZoneMode2
end

do
local genv42 = getgenv()
local proxBoxOffset = getgenv().proxBoxOffset
local proxBoxOffset2 = proxBoxOffset or 2.5
genv42.proxBoxOffset = proxBoxOffset2
end

do
local genv43 = getgenv()
local proxBoxDepthMult = getgenv().proxBoxDepthMult
local proxBoxDepthMult2 = proxBoxDepthMult or 10
genv43.proxBoxDepthMult = proxBoxDepthMult2
end

do
local genv44 = getgenv()
local proxBoxWidthMult = getgenv().proxBoxWidthMult
local proxBoxWidthMult2 = proxBoxWidthMult or 10
genv44.proxBoxWidthMult = proxBoxWidthMult2
end

do
local genv45 = getgenv()
local proxBoxHeightMult = getgenv().proxBoxHeightMult
local proxBoxHeightMult2 = proxBoxHeightMult or 8
genv45.proxBoxHeightMult = proxBoxHeightMult2
end

do
local genv46 = getgenv()
local proxBoxTransparency = getgenv().proxBoxTransparency
local proxBoxTransparency2 = proxBoxTransparency or 0.1
genv46.proxBoxTransparency = proxBoxTransparency2
end

do
local tbl5 = {
        Shedletsky = true,
        Elliot = true,
        ["Jane Doe"] = true,
        ["Two Time"] = true,
    }
getgenv().aimTargets = {}
for i, child in ipairs(getgenv().KillersFolder:GetChildren()) do
        if not tbl5[child.Name] then
            table.insert(getgenv().aimTargets, child.Name)
        end
    end
getgenv().KillersFolder.ChildAdded:Connect(function(child)
        if tbl5[child.Name] then
            return
        end

        for i, aimTarget in ipairs(getgenv().aimTargets) do
            if aimTarget == child.Name then
                return
            end
        end

        table.insert(getgenv().aimTargets, child.Name)
    end)
end

getgenv().KillersFolder.ChildRemoved:Connect(function(child)
        for i, aimTarget in ipairs(getgenv().aimTargets) do
            if aimTarget == child.Name then
                table.remove(getgenv().aimTargets, i)
                break
            end
        end
    end)
getgenv().Camera = getgenv().Workspace.CurrentCamera
do
local genv47 = getgenv()
local aimPunchActive = getgenv().aimPunchActive
local aimPunchActive2 = aimPunchActive or false
genv47.aimPunchActive = aimPunchActive2
end

do
local genv48 = getgenv()
local aimPunchMode = getgenv().aimPunchMode
local aimPunchMode2 = aimPunchMode or "HRP"
genv48.aimPunchMode = aimPunchMode2
end


end