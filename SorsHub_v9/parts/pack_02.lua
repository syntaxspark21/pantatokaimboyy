-- SorsHub pack part 2/10
return function(P)
local lib = P["lib@9463,10-9463,13"]
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]

task.wait()
task.wait()
local Stamina = v:AddTab("Stamina", "battery", "manage your stamina settings")
local v3 = Stamina:AddLeftGroupbox("Stamina System", "battery")
local zap = Stamina:AddRightTabbox("zap")
local Stuff = zap:AddTab("Stuff")
local Walkspeed = zap:AddTab("Walkspeed")
getgenv().SM_Enabled = false
getgenv().SM_Threshold = 10
local function fn2()
        local localPlayer4 = game:GetService("Players").LocalPlayer
        local playerGui = localPlayer4 and localPlayer4:FindFirstChild("PlayerGui")
        local amount = playerGui and playerGui:FindFirstChild("TemporaryUI") and playerGui.TemporaryUI:FindFirstChild("PlayerInfo") and playerGui.TemporaryUI.PlayerInfo:FindFirstChild("Bars") and playerGui.TemporaryUI.PlayerInfo.Bars:FindFirstChild("Stamina") and playerGui.TemporaryUI.PlayerInfo.Bars.Stamina:FindFirstChild("Amount")
        if not amount then
            return nil
        end
        local match, v4 = amount.Text:match("(%d+)%s*/%s*(%d+)")
        return tonumber(match), tonumber(v4)
    end
local function fn3()
        local sharedSprintMod = getgenv()._SharedSprintMod
        local sprintModule = sharedSprintMod or getgenv().SprintModule
        if not sprintModule then
            return
        end

        pcall(function()
            sprintModule.IsSprinting = false
            sprintModule.__sprintedEvent:Fire(false)
        end)
    end
game:GetService("RunService").Heartbeat:Connect(function()
        if not getgenv().SM_Enabled then
            return
        end
        local v4 = fn2()
        if not v4 then
            return
        end

        if v4 <= getgenv().SM_Threshold then
            local sharedSprintMod = getgenv()._SharedSprintMod
            local sprintModule = sharedSprintMod or getgenv().SprintModule
            if not sprintModule then
                return
            end

            if sprintModule.IsSprinting then
                fn3()

                task.delay(2, function()
                    pcall(function()
                        sprintModule.CanSprint = true
                    end)
                end)
            end
        end
    end)
Stuff:AddCheckbox(fn(), {
        Text = "Auto Unsprint",
        Default = false,
        Callback = function(smEnabled)
            getgenv().SM_Enabled = smEnabled
        end,
    })
Stuff:AddInput(fn(), {
        Text = "Unsprint at Stamina",
        Placeholder = "10",
        Callback = function(arg)
            local smThreshold = tonumber(arg)

            if smThreshold then
                getgenv().SM_Threshold = smThreshold
            end
        end,
    })
local genv = getgenv()
local disableDirSpeedConn = getgenv()._disableDirSpeedConn
local v4 = disableDirSpeedConn or nil
genv._disableDirSpeedConn = v4
getgenv().getDirectionalMovement = function()
        local speedMultipliers = workspace:FindFirstChild("SpeedMultipliers", true)
        if not speedMultipliers then
            return nil
        end
        return speedMultipliers:FindFirstChild("DirectionalMovement")
    end
Stuff:AddCheckbox(fn(), {
        Text = "Keep Directional Speed",
        Default = false,
        Callback = function(arg)
            if getgenv()._disableDirSpeedConn then
                getgenv()._disableDirSpeedConn:Disconnect()
                getgenv()._disableDirSpeedConn = nil
            end

            if arg then
                getgenv()._disableDirSpeedConn = game:GetService("RunService").Heartbeat:Connect(function()
                    local v5 = getgenv().getDirectionalMovement()

                    if v5 and v5:IsA("NumberValue") then
                        v5.Value = 1
                    end
                end)
            end
        end,
    })
local genv2 = getgenv()
local disableDirMovementEnabled = getgenv()._disableDirMovementEnabled
local disableDirMovementEnabled2 = disableDirMovementEnabled or false
genv2._disableDirMovementEnabled = disableDirMovementEnabled2
Stuff:AddCheckbox(fn(), {
        Text = "Remove Movement Lock",
        Default = false,
        Callback = function(disableDirMovementEnabled3)
            getgenv()._disableDirMovementEnabled = disableDirMovementEnabled3

            if disableDirMovementEnabled3 then
                local function fn4()
                    local speedMultipliers = workspace:FindFirstChild("SpeedMultipliers", true)

                    if speedMultipliers then
                        if getgenv()._disableDirMovConn then
                            getgenv()._disableDirMovConn:Disconnect()
                        end

                        getgenv()._disableDirMovConn = speedMultipliers.ChildAdded:Connect(function(child)
                            if child.Name == "DirectionalMovement" and getgenv()._disableDirMovementEnabled then
                                child:Destroy()
                            end
                        end)

                        local directionalMovement = speedMultipliers:FindFirstChild("DirectionalMovement")

                        if directionalMovement then
                            directionalMovement:Destroy()
                        end
                    end
                end

                fn4()

                if getgenv()._disableDirMovRehookConn then
                    getgenv()._disableDirMovRehookConn:Disconnect()
                end

                getgenv()._disableDirMovRehookConn = workspace.DescendantAdded:Connect(function(descendant)
                    if descendant.Name == "SpeedMultipliers" and getgenv()._disableDirMovementEnabled then
                        fn4()
                    end
                end)
            else
                if getgenv()._disableDirMovConn then
                    getgenv()._disableDirMovConn:Disconnect()
                    getgenv()._disableDirMovConn = nil
                end

                if getgenv()._disableDirMovRehookConn then
                    getgenv()._disableDirMovRehookConn:Disconnect()
                    getgenv()._disableDirMovRehookConn = nil
                end
            end
        end,
    })
task.spawn(function()
        local ok, result2 = pcall(function()
            return require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting)
        end)

        local ok2, result3 = pcall(function()
            return require(game:GetService("ReplicatedStorage").Systems.Player.Miscellaneous.GetPlayerMousePosition)
        end)

        local genv3 = getgenv()
        local sharedSprintMod = ok and result2 or {}
        genv3._SharedSprintMod = sharedSprintMod
        local genv4 = getgenv()
        local v5 = ok2 and result3 or nil
        genv4._SharedMouseMod = v5
    end)
local vxSprintWait = os.clock()
while not getgenv()._SharedSprintMod and os.clock() - vxSprintWait < 10 do
        task.wait()
    end
if getgenv()._SharedSprintMod == nil then getgenv()._SharedSprintMod = {} end
getgenv().SprintModule = getgenv()._SharedSprintMod
getgenv().SprintDefaults = {}
getgenv().StaminaStats = {
        MaxStamina = 100,
        MinStamina = 0,
        StaminaGain = 20,
        StaminaLoss = 10,
        SprintSpeed = 26,
    }
getgenv().StaminaToggles = {
        MaxStamina = false,
        MinStamina = false,
        StaminaGain = false,
        StaminaLoss = false,
        SprintSpeed = false,
    }
getgenv().UnlimitedEnabled = false
local function fn4(arg)
        if getgenv().SprintDefaults[arg] == nil then
            getgenv().SprintDefaults[arg] = getgenv().SprintModule[arg]
        end
    end
v3:AddCheckbox(fn(), {
        Text = "Unlimited Stamina",
        Default = false,
        Callback = function(unlimitedEnabled)
            if unlimitedEnabled then
                fn4("StaminaLoss")
            end

            getgenv().UnlimitedEnabled = unlimitedEnabled
            local sprintModule = getgenv().SprintModule
            local staminaLoss = unlimitedEnabled and 0 or getgenv().SprintDefaults.StaminaLoss
            if staminaLoss ~= nil then sprintModule.StaminaLoss = staminaLoss end -- [SorsHub fix] jangan isi nil
        end,
    })
local flag = false
local tbl2 = {}
local tbl3 = {}
v3:AddCheckbox(fn(), {
        Text = "Stamina Checker",
        Default = false,
        Callback = function(arg)
            flag = arg
            local Players2 = game:GetService("Players")
            local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
            local localPlayer4 = Players2.LocalPlayer

            if not arg then
                for k, player_ in pairs(Players2:GetPlayers()) do
                    if player_.Character then
                        local staminaBillboard = player_.Character:FindFirstChild("StaminaBillboard")

                        if staminaBillboard then
                            staminaBillboard:Destroy()
                        end

                        player_.Character:SetAttribute("StaminaActive", nil)
                    end
                end

                for k, v5 in pairs(tbl2) do
                    if v5 and v5.Connected then
                        v5:Disconnect()
                    end
                end

                tbl2 = {}
                tbl3 = {}
                return
            end

            local tbl4 = {
                MaxStamina = 100,
                StaminaLossPerSec = 10,
                StaminaGainPerSec = 20,
            }

            local function fn5(arg2)
                local humanoidRootPart2 = arg2:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart2 then
                    return 0
                end
                local now = tick()
                local vector = Vector3.new(humanoidRootPart2.Position.X, 0, humanoidRootPart2.Position.Z)

                if not tbl3[arg2] then
                    tbl3[arg2] = {
                        lastPosition = vector,
                        lastTime = now,
                        speedHistory = {},
                        smoothedSpeed = 0,
                    }

                    return 0
                end

                local v5 = tbl3[arg2]
                local n2 = now - v5.lastTime

                if n2 > 0.01 then
                    table.insert(v5.speedHistory, (vector - v5.lastPosition).Magnitude / n2)

                    while #v5.speedHistory > 5 do
                        table.remove(v5.speedHistory, 1)
                    end

                    local n3 = 0

                    for i, v6 in ipairs(v5.speedHistory) do
                        n3 = n3 + v6
                    end

                    v5.smoothedSpeed = n3 / #v5.speedHistory
                    v5.lastPosition = vector
                    v5.lastTime = now
                end

                return v5.smoothedSpeed
            end

            local function fn6(arg2)
                local tbl5 = {}
                local assets = ReplicatedStorage2:WaitForChild("Assets")
                local v5 = assets:WaitForChild("Killers"):FindFirstChild(arg2.Name)
                local v6 = v5 or assets:WaitForChild("Survivors"):FindFirstChild(arg2.Name)
                local config = v6 and v6:FindFirstChild("Config")

                local ok, result2 = pcall(function()
                    local module = config and require(config)
                    return module
                end)

                if ok and result2 then
                    local maxStamina = result2.MaxStamina
                    local maxStamina2 = maxStamina or tbl4.MaxStamina
                    tbl5.MaxStamina = maxStamina2
                    local staminaLoss = result2.StaminaLoss
                    local staminaDrain = staminaLoss or result2.StaminaDrain or tbl4.StaminaLossPerSec
                    tbl5.StaminaLossPerSec = staminaDrain
                    local staminaGain = result2.StaminaGain
                    local staminaGainPerSec = staminaGain or tbl4.StaminaGainPerSec
                    tbl5.StaminaGainPerSec = staminaGainPerSec
                else
                    tbl5.MaxStamina = tbl4.MaxStamina
                    tbl5.StaminaLossPerSec = tbl4.StaminaLossPerSec
                    tbl5.StaminaGainPerSec = tbl4.StaminaGainPerSec
                end

                tbl5.LossTick = tbl5.StaminaLossPerSec * 0.01
                tbl5.GainTick = tbl5.StaminaGainPerSec * 0.01
                return tbl5
            end

            local function createTextLabel(parent)
                local head

                repeat
                    head = parent:FindFirstChild("Head")
                    task.wait(0.1)
                until head or not parent.Parent or not flag

                if not head or not flag then
                    return nil
                end

                if parent:FindFirstChild("StaminaBillboard") then
                    return parent.StaminaBillboard:FindFirstChild("StaminaText")
                end
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "StaminaBillboard"
                billboardGui.Adornee = head
                billboardGui.Size = UDim2.new(4, 0, 1, 0)
                billboardGui.StudsOffset = Vector3.new(0, 3, 0)
                billboardGui.AlwaysOnTop = true
                billboardGui.ResetOnSpawn = false
                billboardGui.Parent = parent
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "StaminaText"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                textLabel.TextScaled = true
                textLabel.FontFace = Font.new("rbxasset://fonts/families/Sarpanch.json", Enum.FontWeight.Bold)
                textLabel.Text = "100"
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Parent = billboardGui
                return textLabel
            end

            local function fn7(arg2)
                if arg2:GetAttribute("StaminaActive") then
                    return
                end
                arg2:SetAttribute("StaminaActive", true)
                local humanoid = arg2:WaitForChild("Humanoid", 10)
                local v5 = fn6(arg2)
                local maxStamina = v5.MaxStamina
                local lossTick = v5.LossTick
                local gainTick = v5.GainTick
                local v6 = createTextLabel(arg2)

                if humanoid and v6 then
                    local n2 = maxStamina
                    local flag2 = false
                    local n3 = 0
                    local n4 = 0

                    task.spawn(function()
                        while arg2.Parent and humanoid.Health > 0 and flag do
                            task.wait(0.01)
                            if not v6.Parent then
                                break
                            end
                            local flag3 = fn5(arg2) >= 20

                            if flag3 then
                                n4 = 0.1
                                n2 = n2 - lossTick

                                if n2 <= 0 then
                                    n2 = 0
                                    flag2 = true
                                    n3 = 2
                                end
                            elseif n4 > 0 then
                                n4 = n4 - 0.01
                            elseif flag2 then
                                n3 = n3 - 0.01

                                if n3 <= 0 then
                                    n3 = 0
                                    flag2 = false
                                end
                            else
                                n2 = n2 + gainTick
                            end

                            n2 = math.clamp(n2, 0, maxStamina)
                            v6.Text = string.format("%d", math.floor(n2))

                            if flag2 then
                                local color = math.sin(tick() * 10) > 0 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(150, 0, 0)
                                v6.TextColor3 = color
                            else
                                local n5 = n2 / maxStamina
                                local color = n5 > 0.63 and Color3.fromRGB(100, 255, 150) or n5 > 0.27 and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(255, 80, 80)
                                v6.TextColor3 = color
                            end
                        end

                        arg2:SetAttribute("StaminaActive", nil)

                        if v6 and v6.Parent and v6.Parent.Parent then
                            v6.Parent:Destroy()
                        end

                        tbl3[arg2] = nil
                    end)

                    return
                end

                arg2:SetAttribute("StaminaActive", nil)
            end

            local function fn8(player_)
                table.insert(tbl2, player_.CharacterAdded:Connect(function(character2)
                    task.spawn(function()
                        task.wait(0.5)

                        if flag then
                            fn7(character2)
                        end
                    end)
                end))

                if player_.Character then
                    fn7(player_.Character)
                end
            end

            table.insert(tbl2, Players2.PlayerAdded:Connect(fn8))

            for k, player_ in pairs(Players2:GetPlayers()) do
                fn8(player_)
            end
        end,
    })
v3:AddCheckbox(fn(), {
        Text = "No Stamina Penalty",
        Default = false,
        Callback = function(vxNoStaminaPenalty)
            getgenv().VX_NoStaminaPenalty = vxNoStaminaPenalty

            if vxNoStaminaPenalty then
                if getgenv().VX_NoStaminaPenaltyConn then
                    return
                end

                getgenv().VX_NoStaminaPenaltyConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv().VX_NoStaminaPenalty then
                        return
                    end
                    local character2 = game:GetService("Players").LocalPlayer.Character
                    if not character2 then
                        return
                    end
                    local sharedSprintMod = getgenv()._SharedSprintMod

                    if sharedSprintMod then
                        sharedSprintMod.timeUntilStaminaRecovers = 0
                    end

                    if character2:GetAttribute("StaminaPenaltyActive") then
                        character2:SetAttribute("StaminaPenaltyActive", nil)
                    end
                end)
            elseif getgenv().VX_NoStaminaPenaltyConn then
                getgenv().VX_NoStaminaPenaltyConn:Disconnect()
                getgenv().VX_NoStaminaPenaltyConn = nil
            end
        end,
    })
v3:AddDivider({MarginTop = 2, MarginBottom = 2})
local function fn5(arg, arg2, arg3, arg4)
        arg:AddCheckbox(fn(), {
            Text = "Enable " .. arg2,
            Default = false,
            Callback = function(arg5)
                if arg5 then
                    fn4(arg3)
                end

                getgenv().StaminaToggles[arg3] = arg5

                if not arg5 then
                    getgenv().SprintModule[arg3] = getgenv().SprintDefaults[arg3]
                end
            end,
        })

        arg:AddInput(fn(), {
            Text = arg2,
            Placeholder = tostring(arg4),
            Callback = function(arg5)
                local num = tonumber(arg5)

                if num and not getgenv().UnlimitedEnabled then
                    getgenv().StaminaStats[arg3] = num
                end
            end,
        })
    end
fn5(v3, "Max Stamina", "MaxStamina", 100)
fn5(v3, "Min Stamina", "MinStamina", 0)
fn5(v3, "Stamina Gain", "StaminaGain", 20)
fn5(v3, "Stamina Loss", "StaminaLoss", 10)
task.spawn(function()
        while task.wait(0.1) do
            local staminaToggles = getgenv().StaminaToggles
            local staminaStats = getgenv().StaminaStats
            local sprintModule = getgenv().SprintModule

            if getgenv().UnlimitedEnabled or staminaToggles.MaxStamina or staminaToggles.MinStamina or staminaToggles.StaminaGain or staminaToggles.StaminaLoss or staminaToggles.SprintSpeed then
                if staminaToggles.MaxStamina then
                    sprintModule.MaxStamina = staminaStats.MaxStamina
                end

                if staminaToggles.MinStamina then
                    sprintModule.MinStamina = staminaStats.MinStamina
                end

                if staminaToggles.StaminaGain then
                    sprintModule.StaminaGain = staminaStats.StaminaGain
                end

                if staminaToggles.SprintSpeed then
                    sprintModule.SprintSpeed = staminaStats.SprintSpeed
                end

                if getgenv().UnlimitedEnabled then
                    sprintModule.StaminaLoss = 0
                elseif staminaToggles.StaminaLoss then
                    sprintModule.StaminaLoss = staminaStats.StaminaLoss
                end
            end
        end
    end)
local flag2 = false
local n2 = 1
local connection = nil
local TweenService = game:GetService("TweenService")
local function fn6(arg, arg2, arg3)
        if arg.__currentSpeedTween then
            arg.__currentSpeedTween:Cancel()
            arg.__currentSpeedTween = nil
        end

        local tween = TweenService:Create(arg2, TweenInfo.new(0.75), {Value = arg3})
        arg.__currentSpeedTween = tween
        tween:Play()

        tween.Completed:Connect(function()
            if arg.__currentSpeedTween == tween then
                arg.__currentSpeedTween = nil
            end
        end)
    end
local function fn7(arg)
        task.defer(function()
            local sharedSprintMod = getgenv()._SharedSprintMod
            local sprintModule = sharedSprintMod or getgenv().SprintModule
            if not sprintModule then
                return
            end
            local character2 = game.Players.LocalPlayer.Character
            if not character2 then
                return
            end
            local speedMultipliers = character2:FindFirstChild("SpeedMultipliers")
            local sprinting = speedMultipliers and character2.SpeedMultipliers:FindFirstChild("Sprinting")
            if not sprinting then
                return
            end
            local humanoid = character2:FindFirstChildOfClass("Humanoid")
            local attribute = humanoid and humanoid:GetAttribute("BaseSpeed") or 16
            local n3 = arg and sprintModule.SprintSpeed / attribute or n2
            fn6(sprintModule, sprinting, n3)
        end)
    end
local function fn8()
        if connection then
            connection:Disconnect()
            connection = nil
        end

        local sharedSprintMod = getgenv()._SharedSprintMod
        local sprintModule = sharedSprintMod or getgenv().SprintModule

        if sprintModule and sprintModule.SprintToggled then
            connection = sprintModule.SprintToggled:Connect(fn7)
            fn7(sprintModule.IsSprinting)
        end
    end
local function fn9()
        if connection then
            connection:Disconnect()
            connection = nil
        end

        local sharedSprintMod = getgenv()._SharedSprintMod
        local sprintModule = sharedSprintMod or getgenv().SprintModule
        if not sprintModule then
            return
        end
        local character2 = game.Players.LocalPlayer.Character
        if not character2 then
            return
        end
        local speedMultipliers = character2:FindFirstChild("SpeedMultipliers")
        local sprinting = speedMultipliers and character2.SpeedMultipliers:FindFirstChild("Sprinting")
        if not sprinting then
            return
        end
        local humanoid = character2:FindFirstChildOfClass("Humanoid")
        local attribute = humanoid and humanoid:GetAttribute("BaseSpeed") or 16
        local isSprinting = sprintModule.IsSprinting
        local n3 = isSprinting and sprintModule.SprintSpeed / attribute or 1
        fn6(sprintModule, sprinting, n3)
    end
Walkspeed:AddCheckbox(fn(), {
        Text = "Walkspeed Multiplier",
        Default = false,
        Callback = function(arg)
            flag2 = arg

            if arg then
                fn8()
            else
                fn9()
            end
        end,
    })
Walkspeed:AddSlider(fn(), {
        Text = "Multiplier",
        Min = 0.5,
        Max = 5,
        Default = 1,
        Rounding = 2,
        Callback = function(arg)
            n2 = tonumber(arg)

            if flag2 then
                local sharedSprintMod = getgenv()._SharedSprintMod
                local sprintModule = sharedSprintMod or getgenv().SprintModule or {}
                fn7(sprintModule.IsSprinting)
            end
        end,
    })
local v5 = Stamina:AddRightGroupbox("Speed Changer", "zap")
getgenv().VX_SurvSprintSpeed = 26
getgenv().VX_SurvSprintEnabled = false
getgenv().VX_SurvSprintConn = nil
local function fn10()
        pcall(function()
            local character2 = game:GetService("Players").LocalPlayer.Character
            if not character2 then
                return
            end

            if not character2.Parent or character2.Parent.Name ~= "Survivors" then
                return
            end
            local speedMultipliers = character2:FindFirstChild("SpeedMultipliers")
            local sprinting = speedMultipliers and character2.SpeedMultipliers:FindFirstChild("Sprinting")
            local humanoid = character2:FindFirstChildOfClass("Humanoid")
            if not sprinting then
                return
            end
            local sharedSprintMod = getgenv()._SharedSprintMod
            local sprintModule = sharedSprintMod or getgenv().SprintModule
            local isSprinting = sprintModule and sprintModule.IsSprinting
            local attribute = humanoid and humanoid:GetAttribute("BaseSpeed") or 16
            local vxSurvSprintSpeed = getgenv().VX_SurvSprintSpeed
            local sprintSpeed = vxSurvSprintSpeed or 26

            if isSprinting then
                sprinting.Value = sprintSpeed / attribute
            end

            if sprintModule and sprintModule.Character == character2 then
                sprintModule.SprintSpeed = sprintSpeed
            end
        end)
    end
v5:AddInput(fn(), {
        Text = "Survivor Sprint Speed",
        Default = "26",
        Numeric = true,
        Finished = false,
        Callback = function(arg)
            local genv3 = getgenv()
            local num = tonumber(arg)
            local vxSurvSprintSpeed = num or 26
            genv3.VX_SurvSprintSpeed = vxSurvSprintSpeed

            if getgenv().VX_SurvSprintEnabled then
                fn10()
            end
        end,
    })
v5:AddCheckbox(fn(), {
        Text = "Enable Survivor Sprint Speed",
        Default = false,
        Callback = function(vxSurvSprintEnabled)
            getgenv().VX_SurvSprintEnabled = vxSurvSprintEnabled

            if vxSurvSprintEnabled then
                fn10()

                getgenv().VX_SurvSprintConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv().VX_SurvSprintEnabled then
                        return
                    end
                    fn10()
                end)
            else
                if getgenv().VX_SurvSprintConn then
                    getgenv().VX_SurvSprintConn:Disconnect()
                    getgenv().VX_SurvSprintConn = nil
                end

                pcall(function()
                    local sharedSprintMod = getgenv()._SharedSprintMod
                    local sprintModule = sharedSprintMod or getgenv().SprintModule

                    if sprintModule then
                        local sprintDefaults = getgenv().SprintDefaults
                        local sprintSpeed = sprintDefaults and getgenv().SprintDefaults.SprintSpeed or 26
                        sprintModule.SprintSpeed = sprintSpeed
                    end
                end)
            end
        end,
    })
v5:AddDivider({MarginTop = 2, MarginBottom = 2})
getgenv().VX_KillerSprintSpeed = 27
getgenv().VX_KillerSprintEnabled = false
getgenv().VX_KillerSprintConn = nil
local function fn11()
        pcall(function()
            local character2 = game:GetService("Players").LocalPlayer.Character
            if not character2 or not character2.Parent or character2.Parent.Name ~= "Killers" then
                return
            end
            local players = workspace:FindFirstChild("Players")
            local killers = players and workspace.Players:FindFirstChild("Killers")
            if not killers then
                return
            end
            local vxKillerSprintSpeed = getgenv().VX_KillerSprintSpeed
            local n3 = vxKillerSprintSpeed or 27

            for i, child in ipairs(killers:GetChildren()) do
                local speedMultipliers = child:FindFirstChild("SpeedMultipliers")
                local sprinting = speedMultipliers and child.SpeedMultipliers:FindFirstChild("Sprinting")
                local humanoid = child:FindFirstChildOfClass("Humanoid")
                local attribute = humanoid and humanoid:GetAttribute("BaseSpeed") or 16

                if sprinting and sprinting.Value > 1 then
                    sprinting.Value = n3 / attribute
                end
            end
        end)
    end
v5:AddInput(fn(), {
        Text = "Killer Sprint Speed",
        Default = "27",
        Numeric = true,
        Finished = false,
        Callback = function(arg)
            local genv3 = getgenv()
            local num = tonumber(arg)
            local vxKillerSprintSpeed = num or 27
            genv3.VX_KillerSprintSpeed = vxKillerSprintSpeed

            if getgenv().VX_KillerSprintEnabled then
                fn11()
            end
        end,
    })
v5:AddCheckbox(fn(), {
        Text = "Enable Killer Sprint Speed",
        Default = false,
        Callback = function(vxKillerSprintEnabled)
            getgenv().VX_KillerSprintEnabled = vxKillerSprintEnabled

            if vxKillerSprintEnabled then
                fn11()

                getgenv().VX_KillerSprintConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv().VX_KillerSprintEnabled then
                        return
                    end
                    fn11()
                end)
            elseif getgenv().VX_KillerSprintConn then
                getgenv().VX_KillerSprintConn:Disconnect()
                getgenv().VX_KillerSprintConn = nil
            end
        end,
    })
task.wait()
local Visual = v:AddTab("Visual", "eye", "esp and camera settings")
local eye = Visual:AddLeftTabbox("eye")
local esp = eye:AddTab("ESP")
local Settings = eye:AddTab("Settings")
local v6 = Visual:AddRightGroupbox("FOV / Camera", "camera")

P["esp@10494,10-10494,13"] = esp
P["Settings@10495,10-10495,18"] = Settings
P["v6@10496,10-10496,12"] = v6
end