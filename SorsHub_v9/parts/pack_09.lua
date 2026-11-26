-- SorsHub pack part 9/10
return function(P)
local lib = P["lib@9463,10-9463,13"]
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]
local v17 = P["v17@21684,6-21684,9"]

task.spawn(function()
    local vxMouseWait = os.clock()
    while not getgenv()._SharedMouseMod and os.clock() - vxMouseWait < 10 do
        task.wait()
    end
    if getgenv()._SharedMouseMod == nil then getgenv()._SharedMouseMod = {} end

    getgenv().MouseModule = getgenv()._SharedMouseMod

    if not getgenv().OriginalGetMousePos then
        getgenv().OriginalGetMousePos = getgenv().MouseModule.GetMousePos
    end

    getgenv().SilentAimEnabled = false
    getgenv().SilentAimMode = "Nearest"
    getgenv().AllowedCharacters = {}
    getgenv().SA_AimPart = "HumanoidRootPart"
    getgenv().SA_Prediction = 0
    getgenv().SA_CrosshairRadius = 120
    getgenv().SA_CrosshairCircle = nil
    getgenv().SA_CrosshairCircleConn = nil

    getgenv().CanUseSilentAim = function()
        local character = game:GetService("Players").LocalPlayer.Character
        if not character then
            return false
        end

        if #getgenv().AllowedCharacters == 0 then
            return true
        end

        for i, allowedCharacter in ipairs(getgenv().AllowedCharacters) do
            if character.Name == allowedCharacter then
                return true
            end
        end

        return false
    end

    getgenv().SA_GetAimPosition = function(arg)
        if not arg then
            return nil
        end
        local v20 = arg:FindFirstChild(getgenv().SA_AimPart)
        local humanoidRootPart = v20 or arg:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return nil
        end
        return humanoidRootPart.Position + humanoidRootPart.AssemblyLinearVelocity * (getgenv().SA_Prediction / 60)
    end

    getgenv().GetNearestKiller = function()
        local character = game:GetService("Players").LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        local players = workspace:FindFirstChild("Players")
        local killers = players and workspace.Players:FindFirstChild("Killers")
        if not killers then
            return nil
        end
        local v20 = nil
        local huge = math.huge

        for k, child in pairs(killers:GetChildren()) do
            if child ~= character then
                local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart then
                    local magnitude = (character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                    if magnitude < huge then
                        huge = magnitude
                        v20 = child
                    end
                end
            end
        end

        return v20
    end

    getgenv().GetNearestSurvivor = function()
        local character = game:GetService("Players").LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        local players = workspace:FindFirstChild("Players")
        local survivors = players and workspace.Players:FindFirstChild("Survivors")
        if not survivors then
            return nil
        end
        local v20 = nil
        local huge = math.huge

        for k, child in pairs(survivors:GetChildren()) do
            if child ~= character then
                local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart then
                    local magnitude = (character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                    if magnitude < huge then
                        huge = magnitude
                        v20 = child
                    end
                end
            end
        end

        return v20
    end

    getgenv().GetNearestLowestHPSurvivor = function()
        local character = game:GetService("Players").LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        local players = workspace:FindFirstChild("Players")
        local survivors = players and workspace.Players:FindFirstChild("Survivors")
        if not survivors then
            return nil
        end
        local humanoidRootPart = character.HumanoidRootPart
        local huge = math.huge

        for k, child in pairs(survivors:GetChildren()) do
            if child ~= character then
                local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart2 then
                    local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

                    if magnitude < huge then
                        huge = magnitude
                    end
                end
            end
        end

        local n = huge * 1.5
        local v20 = nil
        local huge2 = math.huge

        for k, child in pairs(survivors:GetChildren()) do
            if child ~= character then
                local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                local humanoid = child:FindFirstChildOfClass("Humanoid")

                if humanoidRootPart2 and humanoid and humanoid.Health > 0 and (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= n and humanoid.Health < huge2 then
                    huge2 = humanoid.Health
                    v20 = child
                end
            end
        end

        return v20
    end

    getgenv().GetCrosshairScreenPos = function()
        local ok, result = pcall(function()
            return game:GetService("Players").LocalPlayer.PlayerGui.MainUI.MobileUI.Crosshair
        end)

        if ok and result then
            local absolutePosition = result.AbsolutePosition
            local absoluteSize = result.AbsoluteSize
            return Vector2.new(absolutePosition.X + absoluteSize.X * 0.5, absolutePosition.Y + absoluteSize.Y * 0.5)
        end

        local viewportSize = workspace.CurrentCamera.ViewportSize
        return Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.5)
    end

    getgenv().SA_GetClosestToCrosshair = function()
        local v20 = getgenv().GetCrosshairScreenPos()
        if not v20 then
            return nil
        end
        local currentCamera = workspace.CurrentCamera
        local character = game:GetService("Players").LocalPlayer.Character
        local players = workspace:FindFirstChild("Players")
        local survivors = players and workspace.Players:FindFirstChild("Survivors")
        local players2 = workspace:FindFirstChild("Players")
        local killers = players2 and workspace.Players:FindFirstChild("Killers")
        local v21 = nil
        local huge = math.huge
        local v22, v23, v24 = ipairs({survivors, killers})
        local v25 = v24
        local v26 = v22
        local v27 = v23

        while true do
            local v28, v29 = v26(v27, v25)
            if v28 == nil then
                break
            end
            v25 = v28

            if v29 then
                for k, child in pairs(v29:GetChildren()) do
                    if child ~= character then
                        local v30 = child:FindFirstChild(getgenv().SA_AimPart)
                        local humanoidRootPart = v30 or child:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart then
                            local v31, v32 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)

                            if v32 then
                                local magnitude = (Vector2.new(v31.X, v31.Y) - v20).Magnitude

                                if magnitude <= getgenv().SA_CrosshairRadius and magnitude < huge then
                                    huge = magnitude
                                    v21 = child
                                end
                            end
                        end
                    end
                end

                v25 = v28
            end
        end

        return v21
    end

    getgenv().StartSA_CrosshairCircle = function()
        if getgenv().SA_CrosshairCircle then
            return
        end
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "SA_CrosshairCircleGui"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(255, 200, 0)
        uiStroke.Thickness = 1.5
        uiStroke.Transparency = 0.4
        uiStroke.Parent = frame
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = frame
        getgenv().SA_CrosshairCircle = screenGui

        getgenv().SA_CrosshairCircleConn = game:GetService("RunService").RenderStepped:Connect(function()
            local v20 = getgenv().GetCrosshairScreenPos()
            local n = getgenv().SA_CrosshairRadius * 2

            if v20 then
                local guiInset = game:GetService("GuiService"):GetGuiInset()
                frame.Size = UDim2.fromOffset(n, n)
                frame.AnchorPoint = Vector2.new(0.5, 0.5)
                frame.Position = UDim2.fromOffset(v20.X, v20.Y + guiInset.Y)
                screenGui.Enabled = true
            else
                screenGui.Enabled = false
            end
        end)
    end

    getgenv().StopSA_CrosshairCircle = function()
        if getgenv().SA_CrosshairCircleConn then
            getgenv().SA_CrosshairCircleConn:Disconnect()
            getgenv().SA_CrosshairCircleConn = nil
        end

        if getgenv().SA_CrosshairCircle then
            getgenv().SA_CrosshairCircle:Destroy()
            getgenv().SA_CrosshairCircle = nil
        end
    end

    getgenv().StartSA_FOVCircle = function() end
    getgenv().StopSA_FOVCircle = function() end

    getgenv().UpdateSilentAim = function(arg)
        if arg == "Closest To Cursor" then
            getgenv().StartSA_FOVCircle()
        else
            getgenv().StopSA_FOVCircle()
        end

        getgenv().StopSA_CrosshairCircle()
        if not getgenv().MouseModule then
            return
        end
        local tbl5 = {JaneDoe = true, Dusekkar = true}

        local function fn41()
            if not getgenv().SA_SwapActive then
                local character = game:GetService("Players").LocalPlayer.Character

                if character and tbl5[character.Name] then
                    local players = workspace:FindFirstChild("Players")
                    local killers = players and workspace.Players:FindFirstChild("Killers")
                    return killers
                end

                local players = workspace:FindFirstChild("Players")
                local survivors = players and workspace.Players:FindFirstChild("Survivors")
                return survivors
            end

            local players = workspace:FindFirstChild("Players")
            local survivors = players and workspace.Players:FindFirstChild("Survivors")
            return survivors
        end

        local function fn42(arg2)
            local character = game:GetService("Players").LocalPlayer.Character
            local saSwapTargetMode = getgenv().SA_SwapTargetMode
            local str = saSwapTargetMode or "Nearest"

            if str == "Nearest" then
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                    return nil
                end
                local v20 = nil
                local huge = math.huge

                for k, child in pairs(arg2:GetChildren()) do
                    if child ~= character then
                        local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart2 then
                            local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

                            if magnitude < huge then
                                huge = magnitude
                                v20 = child
                            end
                        end
                    end
                end

                return v20
            end

            if str == "Lowest HP" then
                local v20 = nil
                local huge = math.huge

                for k, child in pairs(arg2:GetChildren()) do
                    if child ~= character then
                        local humanoid = child:FindFirstChildOfClass("Humanoid")

                        if humanoid and humanoid.Health > 0 and humanoid.Health < huge then
                            huge = humanoid.Health
                            v20 = child
                        end
                    end
                end

                return v20
            end

            if str ~= "Closest to Cursor" then
                return nil
            end
            local currentCamera = workspace.CurrentCamera
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local vector2 = Vector2.new(mouse.X, mouse.Y)
            local v20 = nil
            local huge = math.huge

            for k, child in pairs(arg2:GetChildren()) do
                if child ~= character then
                    local v21 = child:FindFirstChild(getgenv().SA_AimPart)
                    local humanoidRootPart = v21 or child:FindFirstChild("HumanoidRootPart")

                    if humanoidRootPart then
                        local v22, v23 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)

                        if v23 then
                            local magnitude = (Vector2.new(v22.X, v22.Y) - vector2).Magnitude

                            if magnitude < huge then
                                huge = magnitude
                                v20 = child
                            end
                        end
                    end
                end
            end

            return v20
        end

        if arg == "Disabled" then
            getgenv().MouseModule.GetMousePos = getgenv().OriginalGetMousePos
        elseif arg == "Nearest" then
            getgenv().MouseModule.GetMousePos = function(...)
                if not getgenv().CanUseSilentAim() then
                    return getgenv().OriginalGetMousePos(...)
                end
                local v20 = fn41()
                if not v20 then
                    return getgenv().OriginalGetMousePos(...)
                end

                if not getgenv().SA_SwapActive then
                    local character = game:GetService("Players").LocalPlayer.Character
                    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then
                        return getgenv().OriginalGetMousePos(...)
                    end
                    local v21 = nil
                    local huge = math.huge

                    for k, child in pairs(v20:GetChildren()) do
                        if child ~= character then
                            local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

                            if humanoidRootPart2 then
                                local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

                                if magnitude < huge then
                                    huge = magnitude
                                    v21 = child
                                end
                            end
                        end
                    end

                    local v22 = getgenv().SA_GetAimPosition(v21)
                    local v23 = v22 or getgenv().OriginalGetMousePos(...)
                    return v23
                end

                local v21 = fn42(v20)
                local v22 = getgenv().SA_GetAimPosition(v21)
                local v23 = v22 or getgenv().OriginalGetMousePos(...)
                return v23
            end
        elseif arg == "Lowest HP" then
            getgenv().MouseModule.GetMousePos = function(...)
                if not getgenv().CanUseSilentAim() then
                    return getgenv().OriginalGetMousePos(...)
                end
                local v20 = fn41()
                if not v20 then
                    return getgenv().OriginalGetMousePos(...)
                end

                if not getgenv().SA_SwapActive then
                    local character = game:GetService("Players").LocalPlayer.Character
                    local v21 = nil
                    local huge = math.huge

                    for k, child in pairs(v20:GetChildren()) do
                        if child ~= character then
                            local humanoid = child:FindFirstChildOfClass("Humanoid")

                            if humanoid and humanoid.Health > 0 and humanoid.Health < huge then
                                huge = humanoid.Health
                                v21 = child
                            end
                        end
                    end

                    local v22 = getgenv().SA_GetAimPosition(v21)
                    local v23 = v22 or getgenv().OriginalGetMousePos(...)
                    return v23
                end

                local v21 = fn42(v20)
                local v22 = getgenv().SA_GetAimPosition(v21)
                local v23 = v22 or getgenv().OriginalGetMousePos(...)
                return v23
            end
        elseif arg == "Closest To Cursor" then
            getgenv().MouseModule.GetMousePos = function(...)
                if not getgenv().CanUseSilentAim() then
                    return getgenv().OriginalGetMousePos(...)
                end
                local v20 = fn41()
                if not v20 then
                    return getgenv().OriginalGetMousePos(...)
                end

                if not getgenv().SA_SwapActive then
                    local currentCamera = workspace.CurrentCamera
                    local character = game:GetService("Players").LocalPlayer.Character
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local vector2 = Vector2.new(mouse.X, mouse.Y)
                    local v21 = nil
                    local huge = math.huge

                    for k, child in pairs(v20:GetChildren()) do
                        if child ~= character then
                            local v22 = child:FindFirstChild(getgenv().SA_AimPart)
                            local humanoidRootPart = v22 or child:FindFirstChild("HumanoidRootPart")

                            if humanoidRootPart then
                                local v23, v24 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)

                                if v24 then
                                    local magnitude = (Vector2.new(v23.X, v23.Y) - vector2).Magnitude

                                    if magnitude < huge then
                                        huge = magnitude
                                        v21 = child
                                    end
                                end
                            end
                        end
                    end

                    local v22 = getgenv().SA_GetAimPosition(v21)
                    local v23 = v22 or getgenv().OriginalGetMousePos(...)
                    return v23
                end

                local v21 = fn42(v20)
                local v22 = getgenv().SA_GetAimPosition(v21)
                local v23 = v22 or getgenv().OriginalGetMousePos(...)
                return v23
            end
        end
    end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local localPlayer = Players.LocalPlayer
    local flag2 = false

    local function fn41()
        if flag2 then
            return
        end

        local ok, result = pcall(function()
            return require(ReplicatedStorage.Assets.Killers.Azure.Config)
        end)

        local ok2, result2 = pcall(function()
            return require(ReplicatedStorage.Modules.Network.Network)
        end)

        if not ok or not ok2 then
            return
        end
        local fireServerConnection = result2.FireServerConnection

        result2.FireServerConnection = function(arg, arg2, arg3, ...)
            if not getgenv().SilentAimEnabled or not getgenv().CanUseSilentAim() or type(arg2) ~= "string" or not arg2:find("AzureUpdateMouse") then
                return fireServerConnection(arg, arg2, arg3, ...)
            end
            local tbl5 = {...}
            local character = localPlayer.Character
            local humanoidRootPart = character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local players = workspace:FindFirstChild("Players")
            local survivors = players and workspace.Players:FindFirstChild("Survivors")

            if humanoidRootPart and survivors then
                local v20 = nil
                local silentAimMode = getgenv().SilentAimMode
                local str = silentAimMode or "Nearest"

                if str == "Closest To Cursor" then
                    local currentCamera = workspace.CurrentCamera
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local vector2 = Vector2.new(mouse.X, mouse.Y)
                    local huge = math.huge

                    for i, child in ipairs(survivors:GetChildren()) do
                        local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                        local primaryPart = humanoidRootPart2 or child.PrimaryPart

                        if primaryPart then
                            local v21, v22 = currentCamera:WorldToViewportPoint(primaryPart.Position)

                            if v22 then
                                local magnitude = (Vector2.new(v21.X, v21.Y) - vector2).Magnitude

                                if magnitude < huge then
                                    huge = magnitude
                                    v20 = primaryPart
                                end
                            end
                        end
                    end
                else
                    local grab = result.Grab
                    local hookRange = grab and result.Grab.HookRange or 300

                    for i, child in ipairs(survivors:GetChildren()) do
                        local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
                        local primaryPart = humanoidRootPart2 or child.PrimaryPart

                        if primaryPart then
                            local magnitude = (primaryPart.Position - humanoidRootPart.Position).Magnitude

                            if magnitude < hookRange then
                                v20 = primaryPart
                                hookRange = magnitude
                            end
                        end
                    end
                end

                if v20 then
                    tbl5[1] = (v20.Position - humanoidRootPart.Position).Unit
                end
            end

            return fireServerConnection(arg, arg2, arg3, unpack(tbl5))
        end

        flag2 = true
    end

    localPlayer.CharacterAdded:Connect(function(character)
        if character.Name == "Azure" then
            task.defer(fn41)
        end
    end)

    if localPlayer.Character and localPlayer.Character.Name == "Azure" then
        task.defer(fn41)
    end

    v17:AddCheckbox(fn(), {
        Text = "Enable Silent Aim",
        Default = false,
        Callback = function(silentAimEnabled)
            getgenv().SilentAimEnabled = silentAimEnabled

            if silentAimEnabled then
                local updateSilentAim = getgenv().UpdateSilentAim
                local silentAimMode = getgenv().SilentAimMode
                local str = silentAimMode or "Nearest"
                updateSilentAim(str)
            else
                getgenv().UpdateSilentAim("Disabled")
            end
        end,
    })

    v17:AddDropdown(fn(), {
        Text = "Which Character",
        Values = {
            "Dusekkar",
            "Nosferatu",
            "c00lkidd",
            "Noli",
            "Jane Doe",
            "Sixer",
            "Azure",
        },
        Default = {
            "Dusekkar",
            "Nosferatu",
            "c00lkidd",
            "Noli",
            "Jane Doe",
            "Sixer",
            "Azure",
        },
        Multi = true,
        Callback = function(arg)
            getgenv().AllowedCharacters = {}

            for i, v20 in ipairs(arg) do
                if v20 == "Jane Doe" then
                    local ok, result = pcall(function()
                        return game.Players.LocalPlayer:WaitForChild("PlayerData", 5):WaitForChild("Equipped", 5):WaitForChild("Survivor", 5)
                    end)

                    if ok and result and result.Value == "JaneDoe" then
                        table.insert(getgenv().AllowedCharacters, "JaneDoe")
                    end
                else
                    table.insert(getgenv().AllowedCharacters, v20)
                end
            end
        end,
    })

    local v20 = game:GetObjects("rbxassetid://9983142905")[1]

    if v20 then
        for i, descendant in ipairs(v20:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Anchored = true

                if descendant.Name == "HumanoidRootPart" then
                    descendant.Transparency = 1
                else
                    descendant.Color = Color3.fromRGB(138, 138, 138)
                    descendant.Transparency = 0
                end
            elseif not descendant:IsA("Clothing") and not descendant:IsA("Texture") then
                if descendant:IsA("Decal") and descendant.Name ~= "face" then
                    descendant:Destroy()
                end
            else
                descendant:Destroy()
            end
        end
    end

    local function fn42(arg)
        if not v20 then
            return
        end

        for i, descendant in ipairs(v20:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
                descendant.Color = Color3.fromRGB(138, 138, 138)
            end
        end

        local v21 = v20:FindFirstChild(arg, true)

        if v21 then
            v21.Color = Color3.fromRGB(115, 201, 115)
        end
    end

    fn42("Torso")

    v17:AddViewport(fn(), {
        Object = v20,
        Interactive = false,
        Focused = true,
        Height = 260,
    })

    task.spawn(function()
        local v21 = nil
        local n = os.clock() + 5

        local function fn43(arg)
            for i, descendant in ipairs(arg:GetDescendants()) do
                if descendant:IsA("ViewportFrame") and not descendant:FindFirstChildOfClass("WorldModel") and descendant:FindFirstChild("Torso", true) then
                    v21 = descendant
                    return
                end
            end
        end

        repeat
            task.wait(0.1)
            fn43(game:GetService("CoreGui"))

            if not v21 then
                fn43(game:GetService("Players").LocalPlayer.PlayerGui)
            end
        until v21 or n < os.clock()

        if not v21 then
            return
        end
        local currentCamera = v21.CurrentCamera
        local torso = v20 and v20:FindFirstChild("Torso")

        if currentCamera and torso then
            currentCamera.CameraType = Enum.CameraType.Scriptable
            currentCamera.CFrame = CFrame.new(torso.Position + torso.CFrame.LookVector * 4.8 + Vector3.new(0, 0.15, 0), torso.Position + Vector3.new(0, 0.15, 0))
        end

        local tbl5 = {}

        for i, descendant in ipairs(v21:GetDescendants()) do
            if descendant:IsA("BasePart") then
                tbl5[descendant.Name] = descendant
            end
        end

        local TweenService = game:GetService("TweenService")
        local v22 = nil
        local tween = nil
        local tween2 = nil
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local color2 = Color3.fromRGB(138, 138, 138)
        local color3 = Color3.fromRGB(115, 201, 115)

        local function fn44(arg)
            if v22 then
                if tween then
                    tween:Cancel()
                end

                tween = TweenService:Create(v22, tweenInfo, {Color = color2})
                tween:Play()
            end

            local v23 = tbl5[arg]

            if v23 then
                if tween2 then
                    tween2:Cancel()
                end

                v23.Color = color2
                tween2 = TweenService:Create(v23, tweenInfo, {Color = color3})
                tween2:Play()
                v22 = v23
            end
        end

        fn44("Torso")

        v21.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            local absolutePosition = v21.AbsolutePosition
            local absoluteSize = v21.AbsoluteSize
            local n2 = (input.Position.X - absolutePosition.X) / absoluteSize.X
            local n3 = (input.Position.Y - absolutePosition.Y) / absoluteSize.Y
            local nowTargeting

            if n3 < 0.28 then
                nowTargeting = "Head"
            elseif n3 < 0.62 then
                if n2 < 0.35 then
                    nowTargeting = "Right Arm"
                elseif n2 > 0.65 then
                    nowTargeting = "Left Arm"
                else
                    nowTargeting = "Torso"
                end
            elseif n2 < 0.5 then
                nowTargeting = "Right Leg"
            else
                nowTargeting = "Left Leg"
            end

            if nowTargeting then
                getgenv().SA_AimPart = nowTargeting
                fn44(nowTargeting)
                fn42(nowTargeting)

                lib:Notify({
                    Title = "Silent Aim Part",
                    Description = "Now targeting: " .. nowTargeting,
                    Icon = "crosshair",
                    Time = 2,
                })
            end
        end)
    end)

    v17:AddDivider({MarginTop = 2, MarginBottom = 2})
    v17:AddLabel("This automatically swaps the target from killer to survivor for Jane Doe and Dusekkar!", true)
    getgenv().SA_SwapEnabled = false
    getgenv().SA_SwapActive = false
    local tbl5 = {JaneDoe = true, Dusekkar = true}

    getgenv().SA_DoSwap = function(arg)
        local character = game:GetService("Players").LocalPlayer.Character

        if character and tbl5[character.Name] then
            if getgenv().SA_SwapEnabled and getgenv().SilentAimEnabled then
                local genv16 = getgenv()
                local saSwapActive

                if getgenv().SA_SwapActive then
                    saSwapActive = false
                else
                    saSwapActive = true
                end

                genv16.SA_SwapActive = saSwapActive

                if arg then
                    local saSwapActive2 = getgenv().SA_SwapActive
                    local color2 = saSwapActive2 and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(25, 25, 25)
                    arg.BackgroundColor3 = color2
                end

                return
            end

            if arg then
                lib:Notify({
                    Title = "Swap Target",
                    Description = "Enable Silent Aim + Target Swap first!",
                    Duration = 2,
                })
            end

            return
        end

        if arg then
            lib:Notify({
                Title = "Swap Target",
                Description = "Only usable as JaneDoe or Dusekkar!",
                Duration = 2,
            })
        end
    end

    getgenv().SA_SyncBtn = function(arg)
        if not arg then
            return
        end
        local saSwapActive = getgenv().SA_SwapActive
        local color2 = saSwapActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(25, 25, 25)
        arg.BackgroundColor3 = color2
    end

    v17:AddCheckbox(fn(), {
        Text = "Target Swap",
        Default = false,
        Callback = function(saSwapEnabled)
            getgenv().SA_SwapEnabled = saSwapEnabled

            if not saSwapEnabled then
                getgenv().SA_SwapActive = false
            end
        end,
    })

    getgenv().SA_SwapTargetMode = "Nearest"

    v17:AddDropdown(fn(), {
        Text = "Target Swap Target",
        Values = {"Nearest", "Lowest HP", "Closest to Cursor"},
        Default = "Nearest",
        Tooltip = "How the swap target is selected when swapping",
        Callback = function(saSwapTargetMode)
            getgenv().SA_SwapTargetMode = saSwapTargetMode
        end,
    })

    v17:AddLabel("Swap Target Keybind"):AddKeyPicker(fn(), {
        Text = "Swap Target Keybind",
        Default = "F",
        Mode = "Press",
        Callback = function()
            getgenv().SA_DoSwap(nil)
        end,
    })

    v17:AddCheckbox(fn(), {
        Text = "Swap Target GUI (Mobile)",
        Default = false,
        Callback = function(arg)
            if getgenv().SA_SwapGui then
                getgenv().SA_SwapGui:Destroy()
                getgenv().SA_SwapGui = nil
            end

            if not arg then
                return
            end

            if not getgenv().SA_SwapEnabled then
                lib:Notify({
                    Title = "Swap Target GUI",
                    Description = "Enable Target Swap first!",
                    Duration = 3,
                })

                return
            end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "SA_SwapGui"
            screenGui.ResetOnSpawn = false
            screenGui.IgnoreGuiInset = true
            screenGui.DisplayOrder = 999
            screenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
            local textButton = Instance.new("TextButton")
            textButton.Size = UDim2.new(0, 160, 0, 44)
            textButton.Position = UDim2.new(1, -170, 0, 10)
            textButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            textButton.BorderSizePixel = 0
            textButton.Text = "Swap Target"
            textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            textButton.TextSize = 15
            textButton.Font = Enum.Font.GothamBold
            textButton.Parent = screenGui
            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 8)
            uiCorner.Parent = textButton
            local uiStroke = Instance.new("UIStroke")
            uiStroke.Color = Color3.fromRGB(80, 80, 80)
            uiStroke.Thickness = 1
            uiStroke.Parent = textButton
            getgenv().SA_SyncBtn(textButton)
            local flag3 = false
            local position = nil
            local position2 = nil
            local flag4 = false

            textButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    flag3 = true
                    flag4 = false
                    position = input.Position
                    position2 = textButton.Position
                end
            end)

            textButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if not flag4 then
                        getgenv().SA_DoSwap(textButton)
                    end

                    flag3 = false
                    flag4 = false
                end
            end)

            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if flag3 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local n = input.Position - position

                    if n.Magnitude > 6 then
                        flag4 = true
                    end

                    textButton.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
                end
            end)

            getgenv().SA_SwapGui = screenGui
        end,
    })
end)
task.wait()
local Generators = v:AddTab("Generators", "battery-charging", "generator esp and solver")
local v20 = Generators:AddLeftTabbox("battery-charging")
local Generators2 = v20:AddTab("Generators")
local Settings3 = v20:AddTab("Settings")
local Difficulty = v20:AddTab("Difficulty")
local v21 = Generators:AddRightTabbox()
local Solver = v21:AddTab("Solver")
local Settings4 = v21:AddTab("Settings")
local flag2 = false
local flag3 = false
local n = 0.04
local n2 = 0.04
local n3 = 0.3
local function fn41(arg, arg2, arg3, arg4)
    if arg3 < arg then
        return "up"
    end

    if arg < arg3 then
        return "down"
    end

    if arg4 < arg2 then
        return "left"
    end

    if arg2 < arg4 then
        return "right"
    end
end
local function fn42(arg, arg2, arg3)
    local tbl5 = {}

    if arg and arg2 then
        local v22 = fn41(arg2.row, arg2.col, arg.row, arg.col)
        local str = v22

        if v22 == "up" then
            str = "down"
        elseif v22 == "down" then
            str = "up"
        elseif v22 == "left" then
            str = "right"
        elseif v22 == "right" then
            str = "left"
        end

        if str then
            tbl5[str] = true
        end
    end

    if arg3 and arg2 then
        local v22 = fn41(arg2.row, arg2.col, arg3.row, arg3.col)

        if v22 then
            tbl5[v22] = true
        end
    end

    return tbl5
end
local function fn43(arg, arg2, arg3, arg4)
    if arg3 == arg - 1 and arg4 == arg2 then
        return "up"
    end

    if arg3 == arg + 1 and arg4 == arg2 then
        return "down"
    end

    if arg3 == arg and arg4 == arg2 - 1 then
        return "left"
    end

    if arg3 == arg and arg4 == arg2 + 1 then
        return "right"
    end
    return false
end
local function fn44(arg)
    return arg.row .. "-" .. arg.col
end
local function fn45(arg, arg2)
    if not arg or #arg == 0 then
        return arg
    end
    local tbl5 = nil

    if arg2 then
        local v22, v23, v24 = pairs(arg2)
        local v25 = v24
        local v26 = v22
        local v27 = v23
        local v28, v29

        repeat
            v28, v29 = v26(v27, v25)
            if v28 == nil then
                break
            end

            for i, v30 in ipairs(arg) do
                if v30.row == v29.row and v30.col == v29.col then
                    tbl5 = {row = v29.row, col = v29.col}
                    break
                end
            end

            v25 = v28
        until tbl5
    end

    if not tbl5 then
        local tbl6 = {}

        for i, v22 in ipairs(arg) do
            tbl6[fn44(v22)] = v22
        end

        local v22, v23, v24 = ipairs(arg)
        local v25 = v24
        local v26 = v22
        local v27 = v23

        while true do
            local v28, v29 = v26(v27, v25)
            if v28 == nil then
                break
            end
            local n4 = 0

            for i, v30 in ipairs({
                {v29.row - 1, v29.col},
                {v29.row + 1, v29.col},
                {v29.row, v29.col - 1},
                {v29.row, v29.col + 1},
            }) do
                if tbl6[v30[1] .. "-" .. v30[2]] then
                    n4 = n4 + 1
                end
            end

            v25 = v28
            if n4 == 1 then
                tbl5 = {row = v29.row, col = v29.col}
                break
            end
        end
    end

    if not tbl5 then
        tbl5 = {row = arg[1].row, col = arg[1].col}
    end

    local tbl6 = {}

    for i, v22 in ipairs(arg) do
        tbl6[fn44(v22)] = {row = v22.row, col = v22.col}
    end

    local tbl7 = {}
    local tbl8 = {}
    local v22 = tbl8
    tbl8.row = tbl5.row
    tbl8.col = tbl5.col
    table.insert(tbl7, table.clone(tbl8))
    tbl6[fn44(tbl8)] = nil

    while next(tbl6) do
        local flag4 = false

        for k, v23 in pairs(tbl6) do
            if fn43(v22.row, v22.col, v23.row, v23.col) then
                table.insert(tbl7, table.clone(v23))
                tbl6[k] = nil
                v22 = v23
                flag4 = true
                break
            end

            continue
        end

        if not flag4 then
            return arg
        end
    end

    return tbl7
end
local tbl5 = {
    DrawSolutionOneByOne = function(arg)
        if not arg or not arg.Solution then
            return
        end
        local v22, v23, v24 = ipairs(arg.Solution)
        local v25 = v24
        local v26 = v22
        local v27 = v23

        while true do
            local v28, v29 = v26(v27, v25)
            if v28 == nil then
                break
            end
            local targetPairs = arg.targetPairs
            local v30 = targetPairs and arg.targetPairs[v28]
            local v31 = fn45(v29, v30)
            local paths = arg.paths
            local paths2 = paths or {}
            arg.paths = paths2
            arg.paths[v28] = {}
            local v32, v33, v34 = ipairs(v31)
            local v35 = v28
            local v36 = v26
            local v37 = v27
            local v38 = v34
            local v39 = v32
            local v40 = v33

            while true do
                local v41, v42 = v39(v40, v38)
                if v41 == nil then
                    break
                end
                v38 = v41

                if flag3 and v41 > 1 and v41 % 3 == 0 and math.random() < n3 then
                    local v43 = v31[v41 - 1]

                    if v43 then
                        local v44 = nil

                        for i, v45 in ipairs({
                            {row = v43.row - 1, col = v43.col},
                            {row = v43.row + 1, col = v43.col},
                            {row = v43.row, col = v43.col - 1},
                            {row = v43.row, col = v43.col + 1},
                        }) do
                            if v45.row ~= v42.row or v45.col ~= v42.col then
                                v44 = v45
                                break
                            end
                            continue
                        end

                        v38 = v41

                        if v44 then
                            table.insert(arg.paths[v28], {row = v44.row, col = v44.col})
                            local gridConnections = arg.gridConnections
                            local gridConnections2 = gridConnections or {}
                            arg.gridConnections = gridConnections2
                            arg.gridConnections[fn44(v44)] = fn42(v43, v44, nil)

                            pcall(function()
                                arg:updateGui()
                            end)

                            task.wait(n + math.random() * (n2 - n))
                            table.remove(arg.paths[v28])
                            arg.gridConnections[fn44(v44)] = nil

                            pcall(function()
                                arg:updateGui()
                            end)

                            task.wait(n + math.random() * (n2 - n))
                        end
                    end
                end

                table.insert(arg.paths[v28], {row = v42.row, col = v42.col})
                local gridConnections = arg.gridConnections
                local gridConnections2 = gridConnections or {}
                arg.gridConnections = gridConnections2
                arg.gridConnections[fn44(v42)] = fn42(v31[v41 - 1], v42, v31[v41 + 1])

                pcall(function()
                    arg:updateGui()
                end)

                task.wait(n + math.random() * (n2 - n))
            end

            v25 = v35
            v26 = v36
            v27 = v37

            if arg.checkForWin then
                pcall(function()
                    arg:checkForWin()
                end)
            end
        end

        if arg.checkForWin then
            pcall(function()
                arg:checkForWin()
            end)
        end
    end,
}
local modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
local minigames = modules and modules:FindFirstChild("Minigames")
if minigames then
    minigames = minigames:FindFirstChild("FlowGameManager")
end
if minigames then
    minigames = minigames:FindFirstChild("FlowGame")
end
if minigames then
    local module = require(minigames)
    local new = module.new

    module.new = function(...)
        local v22 = new(...)

        if flag2 then
            task.spawn(function()
                tbl5.DrawSolutionOneByOne(v22)
            end)
        end

        return v22
    end
end
Solver:AddToggle(fn(), {
    Text = "Automatic Solver",
    Default = false,
    Callback = function(arg)
        flag2 = arg
    end,
})
Settings4:AddToggle(fn(), {
    Text = "Incorrect Paths",
    Default = false,
    Callback = function(arg)
        flag3 = arg
    end,
})
Settings4:AddSlider(fn(), {
    Text = "Mistake Chance",
    Min = 0,
    Max = 100,
    Default = 30,
    Rounding = 0,
    Callback = function(arg)
        n3 = tonumber(arg) / 100
    end,
})
Solver:AddSlider(fn(), {
    Text = "Min Solve Speed",
    Min = 1,
    Max = 20,
    Default = 4,
    Rounding = 0,
    Callback = function(arg)
        n = tonumber(arg) / 100

        if n2 < n then
            n2 = n
        end
    end,
})
Solver:AddSlider(fn(), {
    Text = "Max Solve Speed",
    Min = 1,
    Max = 20,
    Default = 4,
    Rounding = 0,
    Callback = function(arg)
        n2 = tonumber(arg) / 100

        if n2 < n then
            n = n2
        end
    end,
})
task.spawn(function()
    local flag4 = false
    local n4 = 4

    Generators2:AddCheckbox(fn(), {
        Text = "Auto Gen",
        Default = false,
        Callback = function(arg)
            flag4 = arg
        end,
    })

    Generators2:AddSlider(fn(), {
        Text = "Gen Interval",
        Min = 0.1,
        Max = 50,
        Default = 4,
        Rounding = 1,
        Callback = function(arg)
            n4 = tonumber(arg)
        end,
    })

    local function fn46()
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            local map2 = map and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
            if not map2 then
                return
            end

            for k, child in pairs(map2:GetChildren()) do
                if child.Name == "Generator" then
                    local remotes = child:FindFirstChild("Remotes")
                    local re = remotes and child.Remotes:FindFirstChild("RE")

                    if re then
                        re:FireServer()
                    end
                end
            end
        end)
    end

    Generators2:AddDivider({MarginTop = 2, MarginBottom = 2})

    Generators2:AddCheckbox(fn(), {
        Text = "Generator Button",
        Default = false,
        Callback = function(arg)
            local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

            if not arg then
                local coolGeneratorGUI = playerGui:FindFirstChild("CoolGeneratorGUI")

                if coolGeneratorGUI then
                    coolGeneratorGUI:Destroy()
                end

                return
            end

            local TweenService = game:GetService("TweenService")
            local UserInputService = game:GetService("UserInputService")
            local coolGeneratorGUI = playerGui:FindFirstChild("CoolGeneratorGUI")

            if coolGeneratorGUI then
                coolGeneratorGUI:Destroy()
            end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "CoolGeneratorGUI"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = playerGui
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 220, 0, 160)
            frame.Position = UDim2.new(0, 20, 0, 20)
            frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            frame.BackgroundTransparency = 0.1
            frame.BorderSizePixel = 0
            frame.Parent = screenGui
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
            local frame2 = Instance.new("Frame")
            frame2.Size = UDim2.new(1, 0, 0, 40)
            frame2.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            frame2.BorderSizePixel = 0
            frame2.Parent = frame
            Instance.new("UICorner", frame2).CornerRadius = UDim.new(0, 12)
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, -40, 1, 0)
            textLabel.Position = UDim2.new(0, 10, 0, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "Generator Manual"
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextSize = 18
            textLabel.Parent = frame2
            local textButton = Instance.new("TextButton")
            textButton.Size = UDim2.new(0, 30, 0, 30)
            textButton.Position = UDim2.new(1, -35, 0, 5)
            textButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            textButton.Text = "−"
            textButton.TextColor3 = Color3.new(1, 1, 1)
            textButton.Font = Enum.Font.GothamBold
            textButton.TextSize = 28
            textButton.Parent = frame2
            Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 15)
            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(0.8, 0, 0, 40)
            textBox.Position = UDim2.new(0.1, 0, 0, 55)
            textBox.PlaceholderText = "Cooldown (seconds)"
            textBox.Text = "2.5"
            textBox.TextColor3 = Color3.new(1, 1, 1)
            textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            textBox.Font = Enum.Font.Gotham
            textBox.TextSize = 16
            textBox.ClearTextOnFocus = false
            textBox.Parent = frame
            Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)
            local textButton2 = Instance.new("TextButton")
            textButton2.Size = UDim2.new(0.8, 0, 0, 50)
            textButton2.Position = UDim2.new(0.1, 0, 0, 100)
            textButton2.Text = "CLICK GENERATOR"
            textButton2.TextColor3 = Color3.new(1, 1, 1)
            textButton2.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
            textButton2.Font = Enum.Font.GothamBold
            textButton2.TextSize = 20
            textButton2.Parent = frame
            Instance.new("UICorner", textButton2).CornerRadius = UDim.new(0, 10)
            local textButton3 = Instance.new("TextButton")
            textButton3.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
            textButton3.Text = "+"
            textButton3.TextColor3 = Color3.new(1, 1, 1)
            textButton3.Font = Enum.Font.GothamBold
            textButton3.TextSize = 36
            textButton3.BackgroundTransparency = 1
            textButton3.TextTransparency = 1
            textButton3.Size = UDim2.new(0, 0, 0, 0)
            textButton3.Visible = false
            textButton3.Parent = screenGui
            Instance.new("UICorner", textButton3).CornerRadius = UDim.new(0, 25)
            local flag5 = false
            local position = nil
            local position2 = nil

            frame2.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and frame.Visible then
                    flag5 = true
                    position = input.Position
                    position2 = frame.Position
                end
            end)

            frame2.InputChanged:Connect(function(input)
                if flag5 and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local n5 = input.Position - position
                    frame.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n5.X, position2.Y.Scale, position2.Y.Offset + n5.Y)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    flag5 = false
                end
            end)

            local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            textButton.MouseButton1Click:Connect(function()
                TweenService:Create(frame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()

                task.delay(0.4, function()
                    frame.Visible = false
                    textButton3.Size = UDim2.new(0, 0, 0, 0)
                    textButton3.BackgroundTransparency = 1
                    textButton3.TextTransparency = 1
                    textButton3.Visible = true

                    TweenService:Create(textButton3, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 50, 0, 50),
                        BackgroundTransparency = 0,
                        TextTransparency = 0,
                    }):Play()
                end)
            end)

            textButton3.MouseButton1Click:Connect(function()
                textButton3.Visible = false
                frame.Visible = true
                frame.Size = UDim2.new(0, 0, 0, 0)
                frame.BackgroundTransparency = 1

                TweenService:Create(frame, tweenInfo2, {
                    Size = UDim2.new(0, 220, 0, 160),
                    Position = UDim2.new(0, 20, 0, 20),
                    BackgroundTransparency = 0.1,
                }):Play()
            end)

            local flag6 = false

            textButton2.MouseButton1Click:Connect(function()
                if flag6 then
                    return
                end
                flag6 = true

                TweenService:Create(textButton2, TweenInfo.new(0.07, Enum.EasingStyle.Sine), {
                    Size = UDim2.new(0.75, 0, 0, 44),
                    BackgroundColor3 = Color3.fromRGB(0, 170, 130),
                }):Play()

                task.delay(0.07, function()
                    TweenService:Create(textButton2, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                        Size = UDim2.new(0.8, 0, 0, 50),
                        BackgroundColor3 = Color3.fromRGB(0, 200, 150),
                    }):Play()
                end)

                fn46()

                task.spawn(function()
                    local now = tick()
                    local num = tonumber(textBox.Text)
                    local n5 = num or 2.5

                    if n5 < 0.1 then
                        n5 = 0.1
                    end

                    local n6 = now + n5

                    while tick() < n6 do
                        textButton2.Text = string.format("WAIT %.1fs", math.max(0, n6 - tick()))
                        task.wait(0.05)
                    end

                    textButton2.Text = "CLICK GENERATOR"
                    flag6 = false
                end)
            end)
        end,
    })

    local function fn47()
        local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return false
        end
        local puzzleUI = playerGui:FindFirstChild("PuzzleUI")
        if not puzzleUI or not puzzleUI.Enabled then
            return false
        end

        for i, descendant in ipairs(puzzleUI:GetDescendants()) do
            if descendant:IsA("Frame") and descendant.Visible then
                return true
            end
        end

        return false
    end

    task.spawn(function()
        local n5 = 0

        while task.wait(0.1) do
            if flag4 then
                if fn47() then
                    if tick() - n5 >= n4 then
                        fn46()
                        n5 = tick()
                    end
                else
                    n5 = tick()
                end
            end
        end
    end)

    getgenv().VX_GenKeybindEnabled = true
    getgenv().VX_GenKeybindKey = Enum.KeyCode.X

    Settings3:AddInput(fn(), {
        Text = "Gen Keybind",
        Placeholder = "X",
        Callback = function(arg)
            pcall(function()
                if Enum.KeyCode[arg] then
                    getgenv().VX_GenKeybindKey = Enum.KeyCode[arg]
                end
            end)
        end,
    })

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if not getgenv().VX_GenKeybindEnabled then
            return
        end

        if input.KeyCode ~= getgenv().VX_GenKeybindKey then
            return
        end
        fn46()
    end)

    getgenv().HintEnabled = false
    getgenv().currentPuzzle = nil
    getgenv().HintOpacity = 0.4
    getgenv().LineThickness = 30

    local function fn48(arg)
        return arg.row .. "-" .. arg.col
    end

    local function fn49(arg)
        local tbl6, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40
        local tbl7, tbl8, v41, flag5, v42, v43, v44, n5
        n5 = 1

        while true do
            if n5 == 1 then
                tbl6 = {}
                v22, v23, v24 = ipairs(arg)
                v25 = v24
                n5 = 2
            elseif n5 == 2 then
                v26, v27 = v22(v23, v25)

                if v26 == nil then
                    n5 = 4
                else
                    n5 = 3
                end
            elseif n5 == 3 then
                v25 = v26
                tbl6[fn48(v27)] = v27
                n5 = 2
            elseif n5 == 4 then
                v28, v29, v30 = ipairs(arg)
                v31, v32 = v28(v29, v30)

                if v31 == nil then
                    n5 = 43
                else
                    n5 = 5
                end
            elseif n5 == 5 then
                v33 = v32
                v34 = v31
                n5 = 6
            elseif n5 == 6 then
                if tbl6[v33.row - 1 .. "-" .. v33.col] then
                    n5 = 7
                else
                    n5 = 13
                end
            elseif n5 == 7 then
                if tbl6[v33.row + 1 .. "-" .. v33.col] then
                    n5 = 8
                else
                    n5 = 14
                end
            elseif n5 == 8 then
                if tbl6[v33.row .. "-" .. v33.col - 1] then
                    n5 = 9
                else
                    n5 = 15
                end
            elseif n5 == 9 then
                if tbl6[v33.row .. "-" .. v33.col + 1] then
                    n5 = 10
                else
                    n5 = 16
                end
            elseif n5 == 10 then
                v35, v36 = v28(v29, v34)

                if v35 == nil then
                    n5 = 12
                else
                    n5 = 11
                end
            elseif n5 == 11 then
                v33 = v36
                v34 = v35
                n5 = 6
            elseif n5 == 12 then
                return {}
            elseif n5 == 13 then
                if tbl6[v33.row + 1 .. "-" .. v33.col] then
                    n5 = 14
                else
                    n5 = 19
                end
            elseif n5 == 14 then
                if tbl6[v33.row .. "-" .. v33.col - 1] then
                    n5 = 15
                else
                    n5 = 20
                end
            elseif n5 == 15 then
                if tbl6[v33.row .. "-" .. v33.col + 1] then
                    n5 = 16
                else
                    n5 = 21
                end
            elseif n5 == 16 then
                v37, v38 = v28(v29, v34)

                if v37 == nil then
                    n5 = 18
                else
                    n5 = 17
                end
            elseif n5 == 17 then
                v33 = v38
                v34 = v37
                n5 = 6
            elseif n5 == 18 then
                return {}
            elseif n5 == 19 then
                if tbl6[v33.row .. "-" .. v33.col - 1] then
                    n5 = 20
                else
                    n5 = 24
                end
            elseif n5 == 20 then
                if tbl6[v33.row .. "-" .. v33.col + 1] then
                    n5 = 21
                else
                    n5 = 25
                end
            elseif n5 == 21 then
                v39, v40 = v28(v29, v34)

                if v39 == nil then
                    n5 = 23
                else
                    n5 = 22
                end
            elseif n5 == 22 then
                v33 = v40
                v34 = v39
                n5 = 6
            elseif n5 == 23 then
                return {}
            elseif n5 == 24 then
                if tbl6[v33.row .. "-" .. v33.col + 1] then
                    n5 = 25
                else
                    n5 = 40
                end
            elseif n5 == 25 then
                if v33 then
                    n5 = 26
                else
                    n5 = 39
                end
            elseif n5 == 26 then
                tbl7 = {}
                tbl8 = {}
                v41 = v33

                if v41 then
                    n5 = 27
                else
                    n5 = 37
                end
            elseif n5 == 27 then
                table.insert(tbl7, v41)
                tbl8[fn48(v41)] = true
                flag5 = false

                if tbl6[v41.row - 1 .. "-" .. v41.col] and not tbl8[v41.row - 1 .. "-" .. v41.col] then
                    n5 = 34
                else
                    n5 = 28
                end
            elseif n5 == 28 then
                if tbl6[v41.row + 1 .. "-" .. v41.col] and not tbl8[v41.row + 1 .. "-" .. v41.col] then
                    n5 = 33
                else
                    n5 = 29
                end
            elseif n5 == 29 then
                if tbl6[v41.row .. "-" .. v41.col - 1] and not tbl8[v41.row .. "-" .. v41.col - 1] then
                    n5 = 32
                else
                    n5 = 30
                end
            elseif n5 == 30 then
                if tbl6[v41.row .. "-" .. v41.col + 1] and not tbl8[v41.row .. "-" .. v41.col + 1] then
                    n5 = 31
                else
                    n5 = 35
                end
            elseif n5 == 31 then
                v41 = tbl6[v41.row .. "-" .. v41.col + 1]
                flag5 = true
                n5 = 35
            elseif n5 == 32 then
                v41 = tbl6[v41.row .. "-" .. v41.col - 1]
                flag5 = true
                n5 = 35
            elseif n5 == 33 then
                v41 = tbl6[v41.row + 1 .. "-" .. v41.col]
                flag5 = true
                n5 = 35
            elseif n5 == 34 then
                v41 = tbl6[v41.row - 1 .. "-" .. v41.col]
                flag5 = true
                n5 = 35
            elseif n5 == 35 then
                if flag5 and v41 then
                    n5 = 27
                else
                    n5 = 36
                end
            elseif n5 == 36 then
                v42 = tbl7
                n5 = 38
            elseif n5 == 37 then
                v42 = tbl7
                n5 = 38
            elseif n5 == 38 then
                return v42
            elseif n5 == 39 then
                return {}
            elseif n5 == 40 then
                v43, v44 = v28(v29, v34)

                if v43 == nil then
                    n5 = 42
                else
                    n5 = 41
                end
            elseif n5 == 41 then
                v33 = v44
                v34 = v43
                n5 = 6
            elseif n5 == 42 then
                return {}
            elseif n5 == 43 then
                return {}
            end
        end
    end

    local function fn50(arg)
        if not arg or not arg.gridFrame then
            return
        end

        for i, child in ipairs(arg.gridFrame:GetChildren()) do
            if child.Name == "fart" then
                child:Destroy()
            end

            local effects = child:FindFirstChild("Effects")

            if effects then
                local hintFX = effects:FindFirstChild("HintFX")

                if hintFX then
                    hintFX:Destroy()
                end
            end
        end
    end

    local function fn51(arg)
        if not arg or not arg.Solution then
            return
        end
        fn50(arg)
        local v22, v23, v24 = ipairs(arg.Solution)
        local v25 = v24
        local v26 = v22
        local v27 = v23

        while true do
            local v28, v29 = v26(v27, v25)
            if v28 == nil then
                break
            end
            local v30 = fn49(v29)
            local colors = arg.colors
            local color2 = colors and arg.colors[v28] or Color3.fromRGB(0, 255, 255)

            for i, v31 in ipairs(v30) do
                local v32 = arg.gridFrame:FindFirstChild(fn48(v31))

                if v32 then
                    local effects = v32:FindFirstChild("Effects")

                    if effects then
                        local hintFX = effects:FindFirstChild("HintFX")

                        if hintFX then
                            hintFX:Destroy()
                        end

                        local frame = Instance.new("Frame")
                        frame.Name = "HintFX"
                        frame.Size = UDim2.fromScale(1, 1)
                        frame.BackgroundTransparency = 1
                        frame.ZIndex = 9
                        frame.Parent = effects
                        local n5 = getgenv().LineThickness / 100
                        local v33 = v30[i - 1]
                        local v34 = v30[i + 1]
                        local flag5 = false
                        local flag6 = false
                        local flag7 = false
                        local flag8 = false

                        if v33 then
                            if v33.row < v31.row then
                                flag7 = true
                            end

                            if v31.row < v33.row then
                                flag8 = true
                            end

                            if v33.col < v31.col then
                                flag5 = true
                            end

                            if v31.col < v33.col then
                                flag6 = true
                            end
                        end

                        if v34 then
                            if v34.row < v31.row then
                                flag7 = true
                            end

                            if v31.row < v34.row then
                                flag8 = true
                            end

                            if v34.col < v31.col then
                                flag5 = true
                            end

                            if v31.col < v34.col then
                                flag6 = true
                            end
                        end

                        if flag5 or flag6 then
                            local frame2 = Instance.new("Frame")
                            frame2.BackgroundColor3 = color2
                            frame2.BackgroundTransparency = getgenv().HintOpacity
                            frame2.BorderSizePixel = 0
                            frame2.ZIndex = 10
                            local udim2 = UDim2.fromScale
                            local n6 = flag5 and 0 or 0.5 - n5 / 2
                            frame2.Position = udim2(n6, 0.5 - n5 / 2)
                            local udim22 = UDim2.fromScale
                            local n7 = flag6 and 1 or 0.5 + n5 / 2
                            local n8 = flag5 and 0 or 0.5 - n5 / 2
                            frame2.Size = udim22(n7 - n8, n5)
                            frame2.Parent = frame
                        end

                        if flag7 or flag8 then
                            local frame2 = Instance.new("Frame")
                            frame2.BackgroundColor3 = color2
                            frame2.BackgroundTransparency = getgenv().HintOpacity
                            frame2.BorderSizePixel = 0
                            frame2.ZIndex = 10
                            local udim2 = UDim2.fromScale
                            local n6 = 0.5 - n5 / 2
                            local n7 = flag7 and 0 or 0.5 - n5 / 2
                            frame2.Position = udim2(n6, n7)
                            local udim22 = UDim2.fromScale
                            local n8 = flag8 and 1 or 0.5 + n5 / 2
                            local n9 = flag7 and 0 or 0.5 - n5 / 2
                            frame2.Size = udim22(n5, n8 - n9)
                            frame2.Parent = frame
                        end

                        local frame2 = Instance.new("Frame")
                        frame2.BackgroundColor3 = color2
                        frame2.BackgroundTransparency = getgenv().HintOpacity
                        frame2.BorderSizePixel = 0
                        frame2.ZIndex = 11
                        frame2.Position = UDim2.fromScale(0.5 - n5 / 2, 0.5 - n5 / 2)
                        frame2.Size = UDim2.fromScale(n5, n5)
                        frame2.Parent = frame
                    end
                end
            end

            v25 = v28
        end
    end

    local function fn52(arg)
        if not getgenv().HintEnabled then
            fn50(arg)
            return
        end
        fn51(arg)
    end

    if not getgenv().fh_hooked then
        getgenv().fh_hooked = true
        local modules2 = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        local minigames2 = modules2 and modules2:FindFirstChild("Minigames")

        if minigames2 then
            minigames2 = minigames2:FindFirstChild("FlowGameManager")
        end

        if minigames2 then
            minigames2 = minigames2:FindFirstChild("FlowGame")
        end

        if minigames2 then
            local module = require(minigames2)
            local new = module.new

            module.new = function(...)
                local v22 = new(...)

                if getgenv().currentPuzzle and getgenv().currentPuzzle ~= v22 then
                    fn50(getgenv().currentPuzzle)
                end

                getgenv().currentPuzzle = v22

                if getgenv().HintEnabled then
                    fn52(v22)
                end

                v22.gridFrame.AncestryChanged:Connect(function()
                    if not v22.gridFrame:IsDescendantOf(game) then
                        if getgenv().currentPuzzle == v22 then
                            getgenv().currentPuzzle = nil
                        end

                        fn50(v22)
                    end
                end)

                return v22
            end
        end
    end

    Settings3:AddCheckbox(fn(), {
        Text = "Generator Helper",
        Default = false,
        Callback = function(hintEnabled)
            getgenv().HintEnabled = hintEnabled

            if getgenv().currentPuzzle then
                if hintEnabled then
                    fn52(getgenv().currentPuzzle)
                else
                    fn50(getgenv().currentPuzzle)
                end
            end
        end,
    })

    local genv16 = getgenv()
    local generatorSize = getgenv().GeneratorSize
    local v22 = generatorSize

    if not generatorSize then
        local tbl6 = {}
        v22 = tbl6
        tbl6.Current = 6
        tbl6.Enabled = false
    end

    genv16.GeneratorSize = v22

    local function fn53(arg)
        local map = workspace:FindFirstChild("Map")
        local map2 = map and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
        if not map2 then
            return
        end

        for k, child in pairs(map2:GetChildren()) do
            if child.Name == "Generator" then
                child:SetAttribute("Size", arg)
            end
        end
    end

    local function fn54()
        if getgenv().GeneratorSize.Enabled then
            fn53(getgenv().GeneratorSize.Current)
        end
    end

    Difficulty:AddCheckbox(fn(), {
        Text = "Generator Difficulty",
        Default = false,
        Callback = function(enabled)
            getgenv().GeneratorSize.Enabled = enabled
            fn54()
        end,
    })

    Difficulty:AddInput(fn(), {
        Text = "Difficulty (2–30)",
        Placeholder = "2–30",
        Callback = function(arg)
            local num = tonumber(arg)
            if not num then
                return
            end
            local current = math.clamp(math.round(num), 2, 30)
            getgenv().GeneratorSize.Current = current

            if getgenv().GeneratorSize.Enabled then
                fn54()
            end
        end,
    })

    Settings3:AddCheckbox(fn(), {
        Text = "Hide Generator UI",
        Default = false,
        Callback = function(closeGeneratorsUI)
            getgenv().CloseGeneratorsUI = closeGeneratorsUI
            local playerGui = game:GetService("Players").LocalPlayer.PlayerGui

            local function fn55()
                local puzzleUI = playerGui:FindFirstChild("PuzzleUI")
                local temporaryUI = playerGui:FindFirstChild("TemporaryUI")
                local backgroundUI = temporaryUI and temporaryUI:FindFirstChild("BackgroundUI")

                if puzzleUI then
                    puzzleUI.Enabled = false
                end

                if backgroundUI then
                    backgroundUI.Enabled = false
                end
            end

            local function fn56()
                local puzzleUI = playerGui:FindFirstChild("PuzzleUI")
                local temporaryUI = playerGui:FindFirstChild("TemporaryUI")
                local backgroundUI = temporaryUI and temporaryUI:FindFirstChild("BackgroundUI")

                if puzzleUI then
                    puzzleUI.Enabled = true
                end

                if backgroundUI then
                    backgroundUI.Enabled = true
                end
            end

            if closeGeneratorsUI then
                fn55()

                getgenv().CloseGeneratorsUILoop = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv().CloseGeneratorsUI then
                        if getgenv().CloseGeneratorsUILoop then
                            getgenv().CloseGeneratorsUILoop:Disconnect()
                        end

                        return
                    end

                    fn55()
                end)
            else
                if getgenv().CloseGeneratorsUILoop then
                    getgenv().CloseGeneratorsUILoop:Disconnect()
                    getgenv().CloseGeneratorsUILoop = nil
                end

                fn56()
            end
        end,
    })

    getgenv().autoEnterGenEnabled = false

    Settings3:AddCheckbox(fn(), {
        Text = "Auto Enter Generator",
        Default = false,
        Tooltip = "Automatically enters a generator when standing at one",
        Callback = function(autoEnterGenEnabled)
            getgenv().autoEnterGenEnabled = autoEnterGenEnabled

            if autoEnterGenEnabled then
                task.spawn(function()
                    while getgenv().autoEnterGenEnabled do
                        task.wait(0.2)

                        pcall(function()
                            local localPlayer = game:GetService("Players").LocalPlayer
                            local Workspace = game:GetService("Workspace")
                            local map = Workspace:FindFirstChild("Map")
                            local map2 = map

                            if not map or not map.Parent then
                                map2 = Workspace:FindFirstChild("Map")
                            end

                            if not map2 then
                                return
                            end
                            local ingame = map2:FindFirstChild("Ingame")
                            if not ingame then
                                return
                            end
                            local map3 = ingame:FindFirstChild("Map")
                            if not map3 then
                                return
                            end

                            for k, child in pairs(map3:GetChildren()) do
                                if child.Name == "Generator" then
                                    pcall(function()
                                        local function fn55()
                                            local playerGui = localPlayer:FindFirstChild("PlayerGui")
                                            if playerGui and playerGui:FindFirstChild("PuzzleUI") then
                                                return
                                            end

                                            if activelyAutoing then
                                                return
                                            end
                                            local main = child:FindFirstChild("Main")
                                            if not main then
                                                return
                                            end
                                            local prompt = main:FindFirstChild("Prompt")

                                            if prompt and prompt:IsA("ProximityPrompt") then
                                                pcall(function()
                                                    fireproximityprompt(prompt)
                                                end)
                                            end

                                            task.wait(1)
                                        end

                                        local positions = child:FindFirstChild("Positions")
                                        if not positions then
                                            return
                                        end
                                        local center = positions:FindFirstChild("Center")
                                        local right = positions:FindFirstChild("Right")
                                        local left = positions:FindFirstChild("Left")
                                        local character = localPlayer.Character
                                        if not character then
                                            return
                                        end
                                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                                        if not humanoidRootPart then
                                            return
                                        end
                                        local position = humanoidRootPart.Position
                                        local flag5 = false

                                        if center and center.Position and (position - center.Position).Magnitude <= 4 then
                                            flag5 = true
                                        end

                                        if right and right.Position and (position - right.Position).Magnitude <= 4 then
                                            flag5 = true
                                        end

                                        if left and left.Position and (position - left.Position).Magnitude <= 4 then
                                            flag5 = true
                                        end

                                        if flag5 then
                                            fn55()
                                        end
                                    end)
                                end
                            end
                        end)
                    end
                end)
            end
        end,
    })
end)
task.wait()
local Misc = v:AddTab("Misc", "package", "miscellaneous features")
local v22 = Misc:AddLeftGroupbox("Other Stuff", "package")
local v23 = Misc:AddRightTabbox("shield-check")
local Spoofer = v23:AddTab("Spoofer")
local Anti = Misc:AddLeftGroupbox("Anti", "ban")
local v24 = Misc:AddRightGroupbox("Anti Slow", "shield-off")
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local localPlayer = game.Players.LocalPlayer
    getgenv()._antiBloodHookEnabled = false
    getgenv()._antiBloodHookConn = nil
    getgenv()._antiBloodHookOriginalFire = nil

    Anti:AddCheckbox(fn(), {
        Text = "Anti BloodHook",
        Default = false,
        Callback = function(antiBloodHookEnabled)
            getgenv()._antiBloodHookEnabled = antiBloodHookEnabled

            if antiBloodHookEnabled then
                local Network = require(ReplicatedStorage.Modules.Network.Network)

                if not getgenv()._antiBloodHookOriginalFire then
                    getgenv()._antiBloodHookOriginalFire = Network.FireServerConnection

                    Network.FireServerConnection = function(arg, arg2, arg3, ...)
                        if type(arg2) == "string" and arg2:match("NosHookQTE") then
                            return getgenv()._antiBloodHookOriginalFire(arg, arg2, arg3, false)
                        end
                        return getgenv()._antiBloodHookOriginalFire(arg, arg2, arg3, ...)
                    end
                end

                getgenv()._antiBloodHookConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv()._antiBloodHookEnabled then
                        return
                    end
                    local character = localPlayer.Character
                    if not character then
                        return
                    end
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then
                        return
                    end

                    for i, child in ipairs(humanoidRootPart:GetChildren()) do
                        if child:IsA("BodyMover") and not child:GetAttribute("Perm") then
                            child:Destroy()
                        end
                    end

                    if humanoidRootPart.AssemblyLinearVelocity.Magnitude > 60 then
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            else
                if getgenv()._antiBloodHookConn then
                    getgenv()._antiBloodHookConn:Disconnect()
                    getgenv()._antiBloodHookConn = nil
                end

                if getgenv()._antiBloodHookOriginalFire then
                    require(ReplicatedStorage.Modules.Network.Network).FireServerConnection = getgenv()._antiBloodHookOriginalFire
                    getgenv()._antiBloodHookOriginalFire = nil
                end
            end
        end,
    })

    getgenv()._antiPlantsNovaEnabled = false
    getgenv()._antiPlantsNovaConn = nil

    Anti:AddCheckbox(fn(), {
        Text = "Anti Plants and Nova",
        Default = false,
        Callback = function(antiPlantsNovaEnabled)
            getgenv()._antiPlantsNovaEnabled = antiPlantsNovaEnabled

            if antiPlantsNovaEnabled then
                getgenv()._antiPlantsNovaConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv()._antiPlantsNovaEnabled then
                        return
                    end
                    local character = localPlayer.Character
                    if not character then
                        return
                    end
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then
                        return
                    end

                    for i, child in ipairs(humanoidRootPart:GetChildren()) do
                        if child:IsA("BodyMover") and not child:GetAttribute("Perm") then
                            child:Destroy()
                        end
                    end

                    if humanoidRootPart.AssemblyLinearVelocity.Magnitude > 60 then
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            elseif getgenv()._antiPlantsNovaConn then
                getgenv()._antiPlantsNovaConn:Disconnect()
                getgenv()._antiPlantsNovaConn = nil
            end
        end,
    })

    getgenv()._antiNosPuddleEnabled = false
    getgenv()._antiNosPuddleConn = nil
    getgenv().NoliDeleting = false
    getgenv().NoliConnection = nil

    Anti:AddCheckbox(fn(), {
        Text = "Anti Fake Noli",
        Default = false,
        Callback = function(noliDeleting)
            getgenv().NoliDeleting = noliDeleting

            if getgenv().NoliConnection then
                getgenv().NoliConnection:Disconnect()
                getgenv().NoliConnection = nil
            end

            if noliDeleting then
                getgenv().NoliConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    pcall(function()
                        local players = workspace:FindFirstChild("Players")
                        local killers = players and workspace.Players:FindFirstChild("Killers")
                        if not killers then
                            return
                        end
                        local tbl6 = {}

                        for k, child in pairs(killers:GetChildren()) do
                            if child.Name == "Noli" and child:IsA("Model") then
                                table.insert(tbl6, child)
                            end
                        end

                        if #tbl6 > 1 then
                            for i = 2, #tbl6 do
                                pcall(function()
                                    tbl6[i]:Destroy()
                                end)
                            end
                        end

                        local v25 = tbl6[1]

                        if v25 then
                            for k, child in pairs(v25:GetChildren()) do
                                if child.Name == "Hallucination" then
                                    pcall(function()
                                        child:Destroy()
                                    end)
                                end
                            end
                        end
                    end)
                end)
            end
        end,
    })

    getgenv().GeneratorDeleting = false
    getgenv().GeneratorConnection = nil

    Anti:AddCheckbox(fn(), {
        Text = "Anti Fake Generator",
        Default = false,
        Callback = function(generatorDeleting)
            getgenv().GeneratorDeleting = generatorDeleting

            if getgenv().GeneratorConnection then
                getgenv().GeneratorConnection:Disconnect()
                getgenv().GeneratorConnection = nil
            end

            if generatorDeleting then
                getgenv().GeneratorConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    pcall(function()
                        local map = workspace:FindFirstChild("Map")
                        local ingame = map and workspace.Map:FindFirstChild("Ingame")
                        if not ingame then
                            return
                        end

                        for k, child in pairs(ingame:GetChildren()) do
                            local name = child.Name
                            local fakeGeneratorName = getgenv().FakeGeneratorName
                            local str = fakeGeneratorName or "FakeGenerator"

                            if name == str then
                                pcall(function()
                                    child:Destroy()
                                end)
                            end
                        end
                    end)
                end)
            end
        end,
    })

    local connection2 = nil

    Anti:AddCheckbox(fn(), {
        Text = "Anti Slow Fall",
        Default = false,
        Callback = function(arg)
            if connection2 then
                connection2:Disconnect()
                connection2 = nil
            end

            if arg then
                connection2 = localPlayer.CharacterAdded:Connect(function(character)
                    if not character:GetAttribute("NoFallSlow") then
                        character:SetAttribute("NoFallSlow", true)
                    end
                end)

                local character = localPlayer.Character

                if character and not character:GetAttribute("NoFallSlow") then
                    character:SetAttribute("NoFallSlow", true)
                end
            end
        end,
    })

    getgenv()._antiSentrySlowOriginalApply = nil

    Anti:AddCheckbox(fn(), {
        Text = "Anti Sentry Slow",
        Default = false,
        Callback = function(arg)
            if arg then
                local Statuses = require(ReplicatedStorage.Modules.Gameplay.Statuses)

                if not getgenv()._antiSentrySlowOriginalApply then
                    getgenv()._antiSentrySlowOriginalApply = Statuses.ApplyStatus

                    Statuses.ApplyStatus = function(arg2, arg3, arg4, arg5, ...)
                        local character = localPlayer.Character

                        if character and arg3 == character and arg4 == "Slowness" then
                            local primaryPart = character.PrimaryPart

                            if primaryPart then
                                for k, child in pairs(workspace.Map.Ingame:GetChildren()) do
                                    if child.Name == "BuildermanSentry" and not child:GetAttribute("Destroyed") then
                                        local primaryPart2 = child.PrimaryPart
                                        if not primaryPart2 then
                                            continue
                                        end
                                        local attribute = child:GetAttribute("EffectRadiusSize")
                                        local n4 = attribute or 30
                                        if (primaryPart.Position - primaryPart2.Position).Magnitude <= n4 then
                                            return
                                        end
                                    end
                                end
                            end
                        end

                        return getgenv()._antiSentrySlowOriginalApply(arg2, arg3, arg4, arg5, ...)
                    end
                end
            elseif getgenv()._antiSentrySlowOriginalApply then
                require(ReplicatedStorage.Modules.Gameplay.Statuses).ApplyStatus = getgenv()._antiSentrySlowOriginalApply
                getgenv()._antiSentrySlowOriginalApply = nil
            end
        end,
    })

    local schematics = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Schematics")

    local function fn46(arg)
        local v25 = schematics:FindFirstChild(arg, true)

        if v25 then
            v25:Destroy()
        end
    end;

    (function(arg, arg2)
        local connection3 = nil

        Anti:AddCheckbox(fn(), {
            Text = arg,
            Default = false,
            Callback = function(arg3)
                if connection3 then
                    connection3:Disconnect()
                    connection3 = nil
                end

                if arg3 then
                    fn46(arg2)

                    connection3 = game:GetService("RunService").Heartbeat:Connect(function()
                        fn46(arg2)
                    end)
                end
            end,
        })
    end)("Anti Stun", "Stunned")

    local statusEffects = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Schematics"):WaitForChild("StatusEffects")

    local function fn47(arg, arg2)
        local v25 = statusEffects

        if type(arg2) == "table" then
            for i, v26 in ipairs(arg2) do
                if not v25 then
                    break
                end
                v25 = v25:WaitForChild(v26, 10)
            end
        else
            v25 = statusEffects:WaitForChild(arg2, 10)
        end

        if not v25 then
            return
        end
        local ok, result = pcall(require, v25)
        if not ok or type(result) ~= "table" then
            return
        end
        local flag4 = false
        local v26 = nil

        if hookfunction then
            v26 = hookfunction(result.Applied, function(...)
                if not flag4 then
                    return v26(...)
                end
            end)
        else
            local applied = result.Applied

            result.Applied = function(...)
                if not flag4 then
                    return applied(...)
                end
            end
        end

        Anti:AddCheckbox(fn(), {
            Text = arg,
            Default = false,
            Callback = function(arg3)
                flag4 = arg3
            end,
        })
    end

    fn47("Anti Blindness", "Blindness")
    fn47("Anti Subspaced", {"SurvivorExclusive", "Subspaced"})
    fn47("Anti Slowness Effect", "Slowness")
end)
task.spawn(function()
    getgenv().VX_KillerDoorsEnabled = false

    local function fn46(canCollide)
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            local killerDoors = map and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map") and workspace.Map.Ingame.Map:FindFirstChild("MapBoundaries") and workspace.Map.Ingame.Map.MapBoundaries:FindFirstChild("KillerDoors")
            if not killerDoors then
                return
            end

            for i, descendant in ipairs(killerDoors:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.CanCollide = canCollide
                end
            end
        end)
    end

    v22:AddCheckbox(fn(), {
        Text = "Disable Killer Doors Collision",
        Default = false,
        Callback = function(vxKillerDoorsEnabled)
            getgenv().VX_KillerDoorsEnabled = vxKillerDoorsEnabled
            local flag4

            if vxKillerDoorsEnabled then
                flag4 = false
            else
                flag4 = true
            end

            fn46(flag4)

            if vxKillerDoorsEnabled then
                task.spawn(function()
                    while getgenv().VX_KillerDoorsEnabled do
                        fn46(false)
                        task.wait(1)
                    end
                end)
            end
        end,
    })

    v22:AddCheckbox(fn(), {
        Text = "Allow Jump",
        Default = false,
        Callback = function(mhhmmm2)
            _G.mhhmmm2 = mhhmmm2

            task.spawn(function()
                local localPlayer = game:GetService("Players").LocalPlayer

                while task.wait() and _G.mhhmmm2 do
                    if localPlayer.Character then
                        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

                        if humanoid then
                            humanoid.UseJumpPower = true
                            humanoid.JumpPower = 50
                        end
                    end
                end
            end)
        end,
    })

    v22:AddCheckbox(fn(), {
        Text = "Noclip Walls",
        Default = false,
        Callback = function(nokia)
            _G.nokia = nokia
            local tbl6 = {}

            task.spawn(function()
                local localPlayer, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, n4
                n4 = 1

                while true do
                    if n4 == 1 then
                        localPlayer = game:GetService("Players").LocalPlayer
                        n4 = 2
                    elseif n4 == 2 then
                        if task.wait() then
                            n4 = 3
                        else
                            n4 = 14
                        end
                    elseif n4 == 3 then
                        if _G.nokia then
                            n4 = 4
                        else
                            n4 = 9
                        end
                    elseif n4 == 4 then
                        if localPlayer.Character then
                            n4 = 5
                        else
                            n4 = 2
                        end
                    elseif n4 == 5 then
                        v25, v26, v27 = ipairs(localPlayer.Character:GetChildren())
                        v28 = v27
                        n4 = 6
                    elseif n4 == 6 then
                        v29, v30 = v25(v26, v28)

                        if v29 == nil then
                            n4 = 2
                        else
                            n4 = 7
                        end
                    elseif n4 == 7 then
                        v28 = v29

                        if v30:IsA("BasePart") and v30.CanCollide == true then
                            n4 = 8
                        else
                            n4 = 6
                        end
                    elseif n4 == 8 then
                        tbl6[v30] = true
                        v30.CanCollide = false
                        n4 = 6
                    elseif n4 == 9 then
                        v31, v32, v33 = pairs(tbl6)
                        v34 = v33
                        n4 = 10
                    elseif n4 == 10 then
                        v35 = v31(v32, v34)

                        if v35 == nil then
                            n4 = 13
                        else
                            n4 = 11
                        end
                    elseif n4 == 11 then
                        v34 = v35

                        if v35 and v35.Parent then
                            n4 = 12
                        else
                            n4 = 10
                        end
                    elseif n4 == 12 then
                        v35.CanCollide = true
                        n4 = 10
                    elseif n4 == 13 then
                        tbl6 = {}
                        n4 = 14
                    elseif n4 == 14 then
                        return
                    end
                end
            end)
        end,
    })
end)

-- [SorsHub fix] groupbox "Other Stuff" di pack ini bernama v22 (dulu ui di
-- script gabungan). Export memakai nama lama yang tidak didefinisikan sehingga
-- nil, dan pack_10 error di baris 142: attempt to index nil with 'AddCheckbox'.
P["ui@27851,6-27851,8"] = v22
P["Spoofer@27852,6-27852,13"] = Spoofer
P["v24@27854,6-27854,9"] = v24
end