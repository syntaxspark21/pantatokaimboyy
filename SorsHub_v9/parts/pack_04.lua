-- SorsHub pack part 4/10
return function(P)
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]
local Noli = P["Noli@12808,10-12808,14"]
local Nosferatu = P["Nosferatu@12810,10-12810,19"]
local Settings2 = P["Settings2@12811,10-12811,19"]
local Survivors = P["Survivors@12813,10-12813,19"]

local v11 = Survivors:AddLeftGroupbox("Jane Doe")
local v12 = Survivors:AddLeftTabbox()
local Veeronica = v12:AddTab("Veeronica")
local Settings4 = v12:AddTab("Settings")
local genv3 = getgenv()
local vxSk8SteerStrength = getgenv().VX_Sk8SteerStrength
local vxSk8SteerStrength2 = vxSk8SteerStrength or 60
genv3.VX_Sk8SteerStrength = vxSk8SteerStrength2
Settings4:AddSlider(fn(), {
        Text = "Steer Strength",
        Min = 30,
        Max = 150,
        Default = 60,
        Rounding = 0,
        Callback = function(vxSk8SteerStrength3)
            getgenv().VX_Sk8SteerStrength = vxSk8SteerStrength3
        end,
    })
Settings4:AddDivider({MarginTop = 2, MarginBottom = 2})
-- [SorsHub fix V20.2] applyHighJump/revertHighJump hilang saat script gabungan
-- dipecah jadi pack (yang tersisa hanya panggilannya, sehingga toggle "High Sk8
-- Trick" error "attempt to call a nil value"). Direkonstruksi memakai pola
-- Actors.CurrentActors seperti fitur "Sk8 Everywhere": cari actor Veeronica
-- milik local player, lalu kalikan field config terkait lompatan trick Sk8
-- dengan VX_HighJumpMult. Nilai asli disimpan di getgenv().VX_HighJumpOrigValue
-- dan dipulihkan oleh revertHighJump().
local function vxIsHighJumpField(key)
    if type(key) ~= "string" then return false end
    local k = string.lower(key)
    local match = k:find("jump") or k:find("ollie")
        or (k:find("trick") and (k:find("power") or k:find("height") or k:find("velocity") or k:find("force")))
    if not match then return false end
    for _, bad in ipairs({"cooldown", "time", "duration", "cost", "stamina", "delay", "rate", "chance", "charge"}) do
        if k:find(bad, 1, true) then return false end
    end
    return true
end

local function vxGetVeeronicaActor()
    local ok, actor = pcall(function()
        local Actors = require(game:GetService("ReplicatedStorage").Modules.Gameplay.Actors)
        local currentActors = Actors.CurrentActors
        local key = nil
        while true do
            local k, a = currentActors(nil, key)
            if k == nil then return nil end
            key = k
            if a.ActorName == "Veeronica" and a.Player == game:GetService("Players").LocalPlayer then
                return a
            end
        end
    end)
    if ok then return actor end
    return nil
end

local function vxHighJumpContainers(actor)
    local list = {}
    local config = actor and actor.Config
    if type(config) == "table" then
        for _, name in ipairs({"Sk8", "Sk8Trick", "Trick"}) do
            if type(config[name]) == "table" then table.insert(list, config[name]) end
        end
    end
    local behavior = actor and actor.Behavior
    local abilities = type(behavior) == "table" and behavior.Abilities
    if type(abilities) == "table" then
        for _, name in ipairs({"Sk8", "Sk8Trick", "Trick"}) do
            if type(abilities[name]) == "table" then table.insert(list, abilities[name]) end
        end
    end
    -- [SorsHub fix V20.4] Dari dump path game: Assets.Survivors.Veeronica punya
    -- ModuleScript Config dan Behavior. Scan module bersamanya juga supaya
    -- fitur tetap bekerja walau actor belum aktif (mis. masih di lobby).
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local assets = rs:FindFirstChild("Assets")
        local survivors = assets and assets:FindFirstChild("Survivors")
        local folder = survivors and survivors:FindFirstChild("Veeronica")
        if not folder then return end
        local configModule = folder:FindFirstChild("Config")
        if configModule then
            local cfg = require(configModule)
            if type(cfg) == "table" then table.insert(list, cfg) end
        end
        local behaviorModule = folder:FindFirstChild("Behavior")
        if behaviorModule then
            local beh = require(behaviorModule)
            local ab = type(beh) == "table" and beh.Abilities
            if type(ab) == "table" then
                for _, name in ipairs({"Sk8", "Sk8Trick", "Trick"}) do
                    if type(ab[name]) == "table" then table.insert(list, ab[name]) end
                end
            end
        end
    end)
    return list
end

local revertHighJump
local function applyHighJump()
    local g = getgenv()
    if not g.VX_HighJumpEnabled then return end
    local mult = tonumber(g.VX_HighJumpMult) or 2
    local actor = vxGetVeeronicaActor()
    local tracked = g.VX_HighJumpOrigValue
    if type(tracked) ~= "table" then tracked = {}; g.VX_HighJumpOrigValue = tracked end
    local seen = {}
    local function scan(tbl, depth)
        if type(tbl) ~= "table" or seen[tbl] or depth > 3 then return end
        seen[tbl] = true
        for key, val in pairs(tbl) do
            if type(val) == "number" and vxIsHighJumpField(key) then
                local rec = nil
                for _, r in ipairs(tracked) do
                    if r.tbl == tbl and r.key == key then rec = r; break end
                end
                if not rec then
                    rec = {tbl = tbl, key = key, orig = val}
                    table.insert(tracked, rec)
                end
                pcall(function() tbl[key] = rec.orig * mult end)
            elseif type(val) == "table" then
                scan(val, depth + 1)
            end
        end
    end
    local containers = vxHighJumpContainers(actor)
    for _, container in ipairs(containers) do scan(container, 1) end
    if #tracked == 0 and not g._VX_HighJumpWarned then
        g._VX_HighJumpWarned = true
        local numericKeys = {}
        for _, container in ipairs(containers) do
            for key, val in pairs(container) do
                if type(key) == "string" and type(val) == "number" and #numericKeys < 15 then
                    table.insert(numericKeys, key)
                end
            end
        end
        warn("[SorsHub] High Sk8 Trick: tidak ada field jump di config Sk8 Veeronica versi ini. Field numerik yang terlihat: " .. table.concat(numericKeys, ", "))
    end
    if not g.VX_HighJumpConn then
        local last = 0
        g.VX_HighJumpConn = game:GetService("RunService").Heartbeat:Connect(function()
            if not getgenv().VX_HighJumpEnabled then
                revertHighJump()
                return
            end
            local now = os.clock()
            if now - last >= 0.5 then
                last = now
                applyHighJump()
            end
        end)
    end
end

revertHighJump = function()
    local g = getgenv()
    if g.VX_HighJumpConn then
        pcall(function() g.VX_HighJumpConn:Disconnect() end)
        g.VX_HighJumpConn = nil
    end
    local tracked = g.VX_HighJumpOrigValue
    if type(tracked) == "table" then
        for _, r in ipairs(tracked) do
            pcall(function() r.tbl[r.key] = r.orig end)
        end
    end
    g.VX_HighJumpOrigValue = nil
    g._VX_HighJumpWarned = nil
end

-- Bersihkan sisa state eksekusi sebelumnya (getgenv bertahan antar re-execute):
-- putuskan koneksi lama dan pulihkan nilai asli supaya multiplier tidak menumpuk.
pcall(function()
    local g = getgenv()
    if g.VX_HighJumpConn then
        pcall(function() g.VX_HighJumpConn:Disconnect() end)
        g.VX_HighJumpConn = nil
    end
    if type(g.VX_HighJumpOrigValue) == "table" then
        for _, r in ipairs(g.VX_HighJumpOrigValue) do
            pcall(function() r.tbl[r.key] = r.orig end)
        end
    end
    g.VX_HighJumpOrigValue = nil
end)

Settings4:AddCheckbox(fn(), {
        Text = "High Sk8 Trick",
        Default = false,
        Callback = function(vxHighJumpEnabled)
            getgenv().VX_HighJumpEnabled = vxHighJumpEnabled

            if vxHighJumpEnabled then
                applyHighJump()
            else
                revertHighJump()
            end
        end,
    })
Settings4:AddSlider(fn(), {
        Text = "How High (Multiplier)",
        Min = 1,
        Max = 4,
        Default = 2,
        Rounding = 2,
        Callback = function(vxHighJumpMult)
            getgenv().VX_HighJumpMult = vxHighJumpMult

            if getgenv().VX_HighJumpEnabled then
                applyHighJump()
            end
        end,
    })
Settings4:AddDivider({MarginTop = 2, MarginBottom = 2})
local genv4 = getgenv()
local autoPitchKillers = getgenv().AutoPitchKillers
local autoPitchKillers2 = autoPitchKillers or {}
genv4.AutoPitchKillers = autoPitchKillers2
getgenv().AutoPitchKillers.AnimationId = 117058860640843
getgenv().AutoPitchKillers.Enabled = false
getgenv().AutoPitchKillers.PitchAngle = 100
getgenv().AutoPitchKillers.DistanceRange = 20
getgenv().AutoPitchKillers.Players = game:GetService("Players")
getgenv().AutoPitchKillers.RunService = game:GetService("RunService")
getgenv().AutoPitchKillers.LocalPlayer = getgenv().AutoPitchKillers.Players.LocalPlayer
getgenv().AutoPitchKillers.Update = function()
        if not getgenv().AutoPitchKillers.Enabled then
            return
        end
        getgenv().AutoPitchKillers.Char = getgenv().AutoPitchKillers.LocalPlayer.Character
        if not getgenv().AutoPitchKillers.Char then
            return
        end
        getgenv().AutoPitchKillers.HRP = getgenv().AutoPitchKillers.Char:FindFirstChild("HumanoidRootPart")
        getgenv().AutoPitchKillers.Humanoid = getgenv().AutoPitchKillers.Char:FindFirstChildOfClass("Humanoid")
        if not getgenv().AutoPitchKillers.HRP or not getgenv().AutoPitchKillers.Humanoid then
            return
        end
        getgenv().AutoPitchKillers.Playing = false

        for k, v13 in pairs(getgenv().AutoPitchKillers.Humanoid:GetPlayingAnimationTracks()) do
            if v13.Animation.AnimationId == "rbxassetid://" .. tostring(getgenv().AutoPitchKillers.AnimationId) then
                getgenv().AutoPitchKillers.Playing = true
                break
            end
        end

        if not getgenv().AutoPitchKillers.Playing then
            return
        end
        getgenv().AutoPitchKillers.ClosestKiller = nil
        getgenv().AutoPitchKillers.MinDist = getgenv().AutoPitchKillers.DistanceRange

        if workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers") then
            for k, child in pairs(workspace.Players.Killers:GetChildren()) do
                if child:FindFirstChild("HumanoidRootPart") then
                    local magnitude = (getgenv().AutoPitchKillers.HRP.Position - child.HumanoidRootPart.Position).Magnitude

                    if magnitude <= getgenv().AutoPitchKillers.MinDist then
                        getgenv().AutoPitchKillers.MinDist = magnitude
                        getgenv().AutoPitchKillers.ClosestKiller = child
                    end
                end
            end
        end

        if getgenv().AutoPitchKillers.ClosestKiller and getgenv().AutoPitchKillers.ClosestKiller:FindFirstChild("HumanoidRootPart") then
            getgenv().AutoPitchKillers.TargetPos = getgenv().AutoPitchKillers.ClosestKiller.HumanoidRootPart.Position
            getgenv().AutoPitchKillers.LookAtCF = CFrame.new(getgenv().AutoPitchKillers.HRP.Position, getgenv().AutoPitchKillers.TargetPos) * CFrame.Angles(math.rad(getgenv().AutoPitchKillers.PitchAngle), 0, 0)
            getgenv().AutoPitchKillers.HRP.CFrame = getgenv().AutoPitchKillers.LookAtCF
        end
    end
getgenv().AutoPitchKillers.RunService.RenderStepped:Connect(function()
        getgenv().AutoPitchKillers.Update()
    end)
Settings4:AddCheckbox(fn(), {
        Text = "Super Bumper",
        Default = false,
        Callback = function(enabled)
            getgenv().AutoPitchKillers.Enabled = enabled
        end,
    })
Settings4:AddSlider(fn(), {
        Text = "Pitch Angle",
        Min = 1,
        Max = 100,
        Default = 100,
        Rounding = 0,
        Callback = function(arg)
            getgenv().AutoPitchKillers.PitchAngle = tonumber(arg)
        end,
    })
Settings4:AddSlider(fn(), {
        Text = "Distance Range",
        Min = 1,
        Max = 100,
        Default = 20,
        Rounding = 0,
        Callback = function(arg)
            getgenv().AutoPitchKillers.DistanceRange = tonumber(arg)
        end,
    })
local v13 = Survivors:AddRightTabbox()
local v14 = v13:AddTab("007n7")
local Settings5 = v13:AddTab("Settings")
local Dusekkar = Survivors:AddRightGroupbox("Dusekkar")
local v15 = Survivors:AddRightGroupbox("Two Time")
task.spawn(function()
        local RunService_3 = game:GetService("RunService")
        local Players2 = game:GetService("Players")
        local PathfindingService = game:GetService("PathfindingService")
        local localPlayer6 = Players2.LocalPlayer
        local n4 = 80
        workspace:WaitForChild("Players", 10):WaitForChild("Survivors", 10)
        local flag4 = false
        local flag5 = false
        local connection8 = nil
        local humanoid2 = nil
        local humanoidRootPart3 = nil
        local flag6 = false
        local character2 = nil
        local str = "Nearest"

        local function fn18(character3)
            humanoid2 = character3:WaitForChild("Humanoid")
            humanoidRootPart3 = character3:WaitForChild("HumanoidRootPart")

            humanoid2.Died:Connect(function()
                if flag4 then
                    getgenv().Noli_StopOverride()
                end
            end)
        end

        if localPlayer6.Character then
            fn18(localPlayer6.Character)
        end

        localPlayer6.CharacterAdded:Connect(fn18)
        local genv5 = getgenv()
        local hasLineOfSight = getgenv().hasLineOfSight

        local hasLineOfSight2 = hasLineOfSight or function(arg, arg2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {localPlayer6.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.IgnoreWater = true
            local hit = workspace:Raycast(arg, arg2 - arg, raycastParams)
            local flag7 = hit

            if hit then
                if hit.Instance:IsDescendantOf(workspace.Players.Survivors) then
                    flag7 = false
                else
                    flag7 = true
                end
            end

            local flag8

            if flag7 then
                flag8 = false
            else
                flag8 = true
            end

            return flag8
        end

        genv5.hasLineOfSight = hasLineOfSight2

        local function fn19(arg)
            local assemblyLinearVelocity = arg.AssemblyLinearVelocity
            if assemblyLinearVelocity.Magnitude < 1 then
                return arg.Position
            end
            return arg.Position + assemblyLinearVelocity * ((arg.Position - humanoidRootPart3.Position).Magnitude / n4) * 0.3
        end

        local function fn20(arg)
            if not humanoidRootPart3 or false then
                return nil
            end

            local v16 = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentCanClimb = false,
                WaypointSpacing = 4,
                Costs = {Water = 20},
            })

            if pcall(function()
                v16:ComputeAsync(humanoidRootPart3.Position, fn19(arg))
            end) and v16.Status == Enum.PathStatus.Success then
                return v16:GetWaypoints()
            end
            return nil
        end

        local function fn21(arg)
            if arg == localPlayer6 then
                return false
            end
            local character3 = arg.Character
            if not character3 then
                return false
            end
            local humanoidRootPart4 = character3:FindFirstChild("HumanoidRootPart")
            local humanoid3 = character3:FindFirstChild("Humanoid")
            local flag7 = humanoidRootPart4 and humanoid3 and humanoid3.Health > 0
            return flag7
        end

        local function fn22()
            if not humanoidRootPart3 then
                return nil
            end
            local v16 = nil
            local huge = math.huge
            local v17 = nil
            local huge2 = math.huge

            for i, player_ in ipairs(Players2:GetPlayers()) do
                if fn21(player_) then
                    local humanoidRootPart4 = player_.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid3 = player_.Character:FindFirstChild("Humanoid")

                    if humanoidRootPart4 then
                        local magnitude = (humanoidRootPart4.Position - humanoidRootPart3.Position).Magnitude

                        if magnitude < huge then
                            huge = magnitude
                            v16 = player_
                        end

                        if humanoid3 and humanoid3.Health < huge2 then
                            huge2 = humanoid3.Health
                            v17 = player_
                        end
                    end
                end
            end

            if str == "Lowest HP" then
                return v17
            end
            return v16
        end

        local function fn23(arg)
            if not arg or #arg == 0 then
                return
            end
            flag6 = true
            local n5 = 2
            local now = tick()

            while flag6 and n5 <= #arg and humanoidRootPart3 and humanoid2 and humanoid2.Health > 0 do
                if tick() - now > 10 then
                    flag6 = false
                    break
                end
                local v16 = arg[n5]
                local vector = Vector3.new(v16.Position.X - humanoidRootPart3.Position.X, 0, v16.Position.Z - humanoidRootPart3.Position.Z)

                if vector.Magnitude < 3 then
                    n5 = n5 + 1
                else
                    local cframe = CFrame.new(humanoidRootPart3.Position, Vector3.new(v16.Position.X, humanoidRootPart3.Position.Y, v16.Position.Z))
                    humanoidRootPart3.CFrame = cframe
                    local vector2 = Vector3.new(vector.Unit.X * n4, humanoidRootPart3.AssemblyLinearVelocity.Y, vector.Unit.Z * n4)
                    humanoidRootPart3.AssemblyLinearVelocity = vector2
                end

                task.wait()
            end

            flag6 = false
        end

        getgenv().Noli_StartOverride = function()
            if flag4 or not humanoid2 or not humanoidRootPart3 then
                return
            end
            flag4 = true

            connection8 = RunService_3.Heartbeat:Connect(function()
                if not humanoid2 or not humanoidRootPart3 or humanoid2.Health <= 0 then
                    return
                end
                local v16 = fn22()

                if v16 and v16.Character and v16.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart4 = v16.Character.HumanoidRootPart
                    character2 = v16.Character
                    local v17 = fn19(humanoidRootPart4)

                    if not getgenv().hasLineOfSight(humanoidRootPart3.Position, humanoidRootPart4.Position) and flag5 then
                        if not flag6 then
                            local v18 = fn20(humanoidRootPart4)

                            if v18 then
                                task.spawn(function()
                                    fn23(v18)
                                end)
                            else
                                flag6 = false
                                local vector = Vector3.new(0, humanoidRootPart3.AssemblyLinearVelocity.Y, 0)
                                humanoidRootPart3.AssemblyLinearVelocity = vector
                            end
                        end
                    else
                        flag6 = false
                        local n5 = v17 - humanoidRootPart3.Position
                        local vector = Vector3.new(n5.X, 0, n5.Z)

                        if vector.Magnitude > 4 then
                            local cframe = CFrame.new(humanoidRootPart3.Position, Vector3.new(v17.X, humanoidRootPart3.Position.Y, v17.Z))
                            humanoidRootPart3.CFrame = cframe
                            local assemblyLinearVelocity = humanoidRootPart3.AssemblyLinearVelocity

                            if true then
                                local vector2 = Vector3.new(vector.Unit.X * n4, assemblyLinearVelocity.Y, vector.Unit.Z * n4)
                                humanoidRootPart3.AssemblyLinearVelocity = vector2
                            else
                                local vector2 = Vector3.new(0, assemblyLinearVelocity.Y, 0)
                                humanoidRootPart3.AssemblyLinearVelocity = vector2
                            end
                        else
                            local vector2 = Vector3.new(0, humanoidRootPart3.AssemblyLinearVelocity.Y, 0)
                            humanoidRootPart3.AssemblyLinearVelocity = vector2
                        end
                    end
                else
                    character2 = nil
                    local vector = Vector3.new(0, humanoidRootPart3.AssemblyLinearVelocity.Y, 0)
                    humanoidRootPart3.AssemblyLinearVelocity = vector
                end
            end)
        end

        getgenv().Noli_StopOverride = function()
            if not flag4 then
                return
            end
            flag4 = false
            flag6 = false

            if connection8 then
                connection8:Disconnect()
                connection8 = nil
            end

            if humanoidRootPart3 then
                local vector = Vector3.new(0, humanoidRootPart3.AssemblyLinearVelocity.Y, 0)
                humanoidRootPart3.AssemblyLinearVelocity = vector
            end
        end

        Noli:AddCheckbox(fn(), {
            Text = "Auto Target",
            Default = false,
            Callback = function(arg)
                flag5 = arg
            end,
        })

        Noli:AddDropdown(fn(), {
            Text = "Target Mode",
            Values = {"Nearest", "Lowest HP"},
            Default = 1,
            Callback = function(arg)
                str = arg
            end,
        })

        Noli:AddSlider(fn(), {
            Text = "Dash Speed",
            Min = 40,
            Max = 200,
            Default = 80,
            Rounding = 0,
            Callback = function(arg)
                n4 = tonumber(arg)
            end,
        })

        getgenv().VoidstarAutoNovaEnabled = false
        Noli:AddDivider({MarginTop = 2, MarginBottom = 2})

        Noli:AddCheckbox(fn(), {
            Text = "Auto Detonate Nova",
            Default = false,
            Callback = function(voidstarAutoNovaEnabled)
                getgenv().VoidstarAutoNovaEnabled = voidstarAutoNovaEnabled
            end,
        })

        game:GetService("RunService").Heartbeat:Connect(function()
            if not getgenv().VoidstarAutoNovaEnabled then
                return
            end
            local map = workspace:FindFirstChild("Map")
            local ingame = map and workspace.Map:FindFirstChild("Ingame")
            if not ingame then
                return
            end
            local voidstar = ingame:FindFirstChild("Voidstar")
            if not voidstar then
                return
            end
            local players = workspace:FindFirstChild("Players")
            local survivors = players and workspace.Players:FindFirstChild("Survivors")
            if not survivors then
                return
            end
            local humanoidRootPart4 = voidstar:FindFirstChild("HumanoidRootPart")
            local position = humanoidRootPart4 and voidstar.HumanoidRootPart.Position

            if not position then
                local isBasePart = voidstar:IsA("BasePart")
                position = isBasePart and voidstar.Position
            end

            if not position then
                return
            end

            for i, child in ipairs(survivors:GetChildren()) do
                local humanoidRootPart5 = child:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart5 and (position - humanoidRootPart5.Position).Magnitude <= 8 then
                    getgenv().VoidstarAutoNovaEnabled = false
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer("UseActorAbility", {buffer.fromstring("\003\004\000\000\000Nova")})
                    return
                end
            end
        end)
    end)
task.spawn(function()
        local flag4 = false
        local n4 = 0.3

        Nosferatu:AddCheckbox(fn(), {
            Text = "Auto Minigame",
            Default = false,
            Callback = function(arg)
                flag4 = arg

                if arg then
                    task.spawn(function()
                        local remoteEvent2 = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent")

                        while flag4 do
                            local character2 = game.Players.LocalPlayer.Character
                            local flag5 = character2 and character2.Parent and character2.Parent.Name == "Killers"
                            local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")

                            if playerGui then
                                local temporaryUI = playerGui:FindFirstChild("TemporaryUI")

                                if temporaryUI then
                                    local qte = temporaryUI:FindFirstChild("QTE")
                                    local imageButton = qte

                                    if qte then
                                        local activeButton = qte:FindFirstChild("ActiveButton")
                                        imageButton = activeButton or qte:FindFirstChildWhichIsA("ImageButton")
                                    end

                                    if imageButton then
                                        if flag5 then
                                            local name = game.Players.LocalPlayer.Name

                                            pcall(function()
                                                remoteEvent2:FireServer(name .. "NosHookQTE", {buffer.fromstring("\001\001")})
                                            end)
                                        elseif character2 and character2.Parent and character2.Parent.Name == "Survivors" then
                                            local name = nil

                                            for i, player_ in ipairs(game:GetService("Players"):GetPlayers()) do
                                                local character3 = player_.Character
                                                if character3 and character3.Parent and character3.Parent.Name == "Killers" then
                                                    name = player_.Name
                                                    break
                                                end
                                            end

                                            if name then
                                                pcall(function()
                                                    remoteEvent2:FireServer(name .. "NosHookQTE", {buffer.fromstring("\001\001")})
                                                end)
                                            end
                                        end
                                    end
                                end
                            end

                            task.wait(n4)
                        end
                    end)
                end
            end,
        })

        Nosferatu:AddSlider(fn(), {
            Text = "Fire Delay",
            Min = 0.05,
            Max = 2,
            Default = 0.3,
            Rounding = 2,
            Callback = function(arg)
                n4 = tonumber(arg)
            end,
        })

        Nosferatu:AddDivider({MarginTop = 2, MarginBottom = 2})
        getgenv().Nos_InfFlightEnabled = false
        getgenv().Nos_DiveControlEnabled = false

        getgenv().Nos_GetActor = function()
            local v16 = nil
            local character2 = game:GetService("Players").LocalPlayer.Character
            if not character2 then
                return nil
            end
            local ok, result2 = pcall(require, game:GetService("ReplicatedStorage").Modules.Gameplay.Actors)
            if not ok or not result2 or not result2.CurrentActors then
                return nil
            end
            local currentActors = result2.CurrentActors

            while true do
                local v17, v18 = currentActors(nil, v16)
                if v17 == nil then
                    break
                end
                v16 = v17
                if v18.ActorName == "Nosferatu" and v18.Rig == character2 then
                    return v18
                end
            end

            return nil
        end

        getgenv().StartNosFlightMods = function()
            local RunService_3 = game:GetService("RunService")
            RunService_3:UnbindFromRenderStep("NosVX_FlightMods")
            RunService_3:UnbindFromRenderStep("NosVX_DiveControl")

            RunService_3:BindToRenderStep("NosVX_FlightMods", 1, function()
                local v16 = getgenv().Nos_GetActor()
                if not v16 then
                    return
                end

                if getgenv().Nos_InfFlightEnabled and v16.State and v16.State.InFlight and v16.Config and v16.Config.AscentFlight then
                    v16.Config.AscentFlight.Duration = math.huge

                    if v16.HeldAbilities and v16.HeldAbilities.Ascent then
                        v16.HeldAbilities.Ascent = false
                    end
                end
            end)

            RunService_3:BindToRenderStep("NosVX_DiveControl", 4, function()
                if not getgenv().Nos_DiveControlEnabled then
                    return
                end
                local v16 = getgenv().Nos_GetActor()
                if not v16 or not v16.State or not v16.State.Slashing then
                    return
                end

                if not v16.Rig or not v16.Rig.PrimaryPart then
                    return
                end
                local config = v16.Config
                local ascentBite = config and v16.Config.AscentBite
                local windup = ascentBite and ascentBite.Windup or 0.4
                local meta = v16.Meta
                local vxDiveStart = meta and v16.Meta._vxDiveStart

                if not vxDiveStart then
                    local meta2 = v16.Meta
                    local meta3 = meta2 or {}
                    v16.Meta = meta3
                    v16.Meta._vxDiveStart = os.clock()
                    vxDiveStart = v16.Meta._vxDiveStart
                end

                if os.clock() - vxDiveStart < windup then
                    return
                end
                local bodyVelocity = v16.Rig.PrimaryPart:FindFirstChildOfClass("BodyVelocity")
                local v17 = bodyVelocity

                if not bodyVelocity then
                    for i, child in ipairs(v16.Rig.PrimaryPart:GetChildren()) do
                        if child:IsA("BodyVelocity") and not child:GetAttribute("Perm") then
                            v17 = child
                            break
                        end
                    end
                end

                if not v17 then
                    return
                end
                local lookVector = workspace.CurrentCamera.CFrame.LookVector
                if lookVector.Magnitude < 0.001 then
                    return
                end
                local unit = lookVector.Unit
                local speed = ascentBite and ascentBite.Speed or v17.Velocity.Magnitude

                if speed < 1 then
                    speed = 80
                end

                v17.MaxForce = Vector3.new(10000000, 10000000, 10000000)
                v17.P = math.huge
                v17.Velocity = unit * speed
            end)
        end

        getgenv().StopNosFlightMods = function()
            local RunService_3 = game:GetService("RunService")
            RunService_3:UnbindFromRenderStep("NosVX_FlightMods")
            RunService_3:UnbindFromRenderStep("NosVX_DiveControl")
            local v16 = getgenv().Nos_GetActor()

            if v16 and v16.Meta then
                v16.Meta._vxDiveStart = nil
            end
        end

        getgenv().Nos_UpdateFlightConn = function()
            if not getgenv().Nos_InfFlightEnabled and not getgenv().Nos_DiveControlEnabled then
                getgenv().StopNosFlightMods()
            else
                getgenv().StartNosFlightMods()
            end
        end

        Nosferatu:AddCheckbox(fn(), {
            Text = "Unlimited Flight Duration",
            Default = false,
            Callback = function(nosInfFlightEnabled)
                getgenv().Nos_InfFlightEnabled = nosInfFlightEnabled
                getgenv().Nos_UpdateFlightConn()
            end,
        })

        Nosferatu:AddCheckbox(fn(), {
            Text = "Dive Control",
            Default = false,
            Callback = function(nosDiveControlEnabled)
                getgenv().Nos_DiveControlEnabled = nosDiveControlEnabled
                getgenv().Nos_UpdateFlightConn()
            end,
        })

        local genv5 = getgenv()
        local nosSpeed = getgenv().nosSpeed
        local nosSpeed2 = nosSpeed or 6.5
        genv5.nosSpeed = nosSpeed2
        getgenv().modifyNosSpeed = false

        Settings2:AddCheckbox(fn(), {
            Text = "Custom Fly Speed",
            Default = false,
            Callback = function(modifyNosSpeed)
                getgenv().modifyNosSpeed = modifyNosSpeed

                if modifyNosSpeed then
                    task.spawn(function()
                        while getgenv().modifyNosSpeed do
                            pcall(function()
                                local nosFlying = workspace.Players.Killers.Nosferatu.SpeedMultipliers:FindFirstChild("NosFlying")

                                if nosFlying then
                                    local nosSpeed3 = getgenv().nosSpeed
                                    local value = nosSpeed3 or 6.5
                                    nosFlying.Value = value
                                end
                            end)

                            task.wait(0.1)
                        end
                    end)
                end
            end,
        })

        Settings2:AddSlider(fn(), {
            Text = "Fly Speed",
            Min = 6.5,
            Max = 20,
            Default = 6.5,
            Rounding = 1,
            Callback = function(arg)
                getgenv().nosSpeed = tonumber(arg)
            end,
        })
    end)
task.spawn(function()
        local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
        local UserInputService = game:GetService("UserInputService")
        local virtualInputManager = getgenv().VirtualInputManager
        local VirtualInputManager2 = virtualInputManager or game:GetService("VirtualInputManager")
        local localPlayer6 = game.Players.LocalPlayer

        if not localPlayer6.Character then
            localPlayer6.CharacterAdded:Wait()
        end

        local touchEnabled = UserInputService.TouchEnabled
        local flag4 = touchEnabled

        if touchEnabled then
            if UserInputService.KeyboardEnabled then
                flag4 = false
            else
                flag4 = true
            end
        end

        if flag4 then
            flag4 = "Mobile"
        end

        if not flag4 then
            flag4 = "PC"
        end

        local behavior = ReplicatedStorage4:WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("Veeronica"):WaitForChild("Behavior")
        local n4 = 0

        local function fn18()
            local now = tick()
            if now - n4 < 0.2 then
                return
            end
            n4 = now
            VirtualInputManager2:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait()
            VirtualInputManager2:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end

        local function fn19()
            local sprintingButton = localPlayer6.PlayerGui:WaitForChild("MainUI"):WaitForChild("SprintingButton")

            for k, v16 in pairs(getconnections(sprintingButton.MouseButton1Down)) do
                pcall(function()
                    if v16.Fire then
                        v16:Fire()
                    end

                    if v16.Function then
                        v16:Function()
                    end
                end)
            end
        end

        local function fn20(arg)
            local character2 = localPlayer6.Character
            if not character2 or not arg.Adornee then
                return false
            end
            local flag5 = arg.Adornee == character2

            if not flag5 then
                local v16 = character2:FindFirstChild(arg.Adornee.Name)
                flag5 = v16 and arg.Adornee:IsDescendantOf(character2)
            end

            return flag5
        end

        local Players2 = game:GetService("Players")
        local RunService_3 = game:GetService("RunService")
        local UserInputService2 = game:GetService("UserInputService")
        local localPlayer7 = Players2.LocalPlayer
        local currentCamera = game:GetService("Workspace").CurrentCamera
        local flag5 = false
        local connection8 = nil
        local connection9 = nil
        local tbl7 = {"117058860640843"}
        local tbl8 = {}
        local genv5 = getgenv()
        local vxSk8SteerStrength3 = getgenv().VX_Sk8SteerStrength
        local vxSk8SteerStrength4 = vxSk8SteerStrength3 or 60
        genv5.VX_Sk8SteerStrength = vxSk8SteerStrength4

        local function fn21(arg)
            if connection8 then
                connection8:Disconnect()
                connection8 = nil
            end

            if not arg then
                UserInputService2.MouseBehavior = Enum.MouseBehavior.Default
                return
            end
            UserInputService2.MouseBehavior = Enum.MouseBehavior.LockCenter

            connection8 = RunService_3.RenderStepped:Connect(function(deltaTime)
                local character2 = localPlayer7.Character
                local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart3 then
                    local lookVector = currentCamera.CFrame.LookVector
                    local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

                    if vector.Magnitude > 0 then
                        local vector2 = Vector3.new(humanoidRootPart3.CFrame.LookVector.X, 0, humanoidRootPart3.CFrame.LookVector.Z)
                        local vxSk8SteerStrength5 = getgenv().VX_Sk8SteerStrength
                        local n5 = vxSk8SteerStrength5 or 60
                        local n6 = math.clamp(deltaTime * n5 / 5, 0, 1)
                        local v16 = vector2:Lerp(vector.Unit, n6)

                        if v16.Magnitude > 0 then
                            humanoidRootPart3.CFrame = CFrame.new(humanoidRootPart3.Position, humanoidRootPart3.Position + v16)
                        end
                    end
                end
            end)
        end

        local function fn22()
            local character2 = localPlayer7.Character
            local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")
            return humanoid2
        end

        local function fn23(arg)
            if tbl8[arg] then
                return
            end
            local tbl9 = {WalkSpeed = arg.WalkSpeed}

            if not pcall(function()
                tbl9.JumpPower = arg.JumpPower
            end) then
                pcall(function()
                    tbl9.JumpPower = arg.JumpHeight
                end)
            end

            local ok, autoRotate = pcall(function()
                return arg.AutoRotate
            end)

            if ok then
                tbl9.AutoRotate = autoRotate
            end

            tbl9.PlatformStand = arg.PlatformStand
            tbl8[arg] = tbl9
        end

        local function fn24(arg)
            local v16 = tbl8[arg]
            if not v16 then
                return
            end
            arg.WalkSpeed = v16.WalkSpeed

            if not pcall(function()
                arg.JumpPower = v16.JumpPower
            end) then
                pcall(function()
                    arg.JumpHeight = v16.JumpPower
                end)
            end

            if v16.AutoRotate ~= nil then
                arg.AutoRotate = v16.AutoRotate
            end

            arg.PlatformStand = v16.PlatformStand
            tbl8[arg] = nil
        end

        local function fn25()
            local v16 = fn22()
            if not v16 then
                return false
            end

            for i, v17 in ipairs(v16:GetPlayingAnimationTracks()) do
                local ok, result2 = pcall(function()
                    return tostring(v17.Animation.AnimationId):match("%d+")
                end)

                if ok and result2 and table.find(tbl7, result2) then
                    return true
                end
            end

            return false
        end

        local function fn26()
            if flag5 then
                return
            end
            local v16 = fn22()
            if not v16 then
                return
            end
            flag5 = true
            fn23(v16)
            v16.WalkSpeed = 60
            v16.AutoRotate = false
            fn21(true)

            connection9 = RunService_3.RenderStepped:Connect(function()
                local v17 = fn22()
                local humanoidRootPart3 = v17 and v17.Parent:FindFirstChild("HumanoidRootPart")
                if not v17 or not humanoidRootPart3 then
                    return
                end
                v17.WalkSpeed = 60
                v17.AutoRotate = false
                local lookVector = humanoidRootPart3.CFrame.LookVector
                local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

                if vector.Magnitude > 0 then
                    v17:Move(vector.Unit)
                else
                    v17:Move(Vector3.zero)
                end
            end)
        end

        local function fn27()
            if not flag5 then
                return
            end
            flag5 = false

            if connection9 then
                connection9:Disconnect()
                connection9 = nil
            end

            fn21(false)
            local v16 = fn22()

            if v16 then
                fn24(v16)
                v16:Move(Vector3.zero)
            end
        end

        localPlayer7.CharacterAdded:Connect(function()
            if connection8 then
                connection8:Disconnect()
                connection8 = nil
            end
        end)

        Veeronica:AddCheckbox(fn(), {
            Text = "Sk8 Control",
            Default = false,
            Callback = function(arg)
                if getgenv().Sk8ControlConn then
                    getgenv().Sk8ControlConn:Disconnect()
                    getgenv().Sk8ControlConn = nil
                end

                if arg then
                    getgenv().Sk8ControlConn = RunService_3.RenderStepped:Connect(function()
                        if not fn22() then
                            if flag5 then
                                fn27()
                            end

                            return
                        end

                        local v16 = fn25()

                        if v16 and not flag5 then
                            fn26()
                        elseif not v16 and flag5 then
                            fn27()
                        end
                    end)
                else
                    fn27()
                end
            end,
        })

        getgenv().VX_AutoSk8Trick = false

        game:GetService("RunService").Heartbeat:Connect(function()
            if not getgenv().VX_AutoSk8Trick then
                return
            end

            for i, descendant in ipairs(behavior:GetDescendants()) do
                if descendant:IsA("Highlight") and fn20(descendant) then
                    if flag4 == "Mobile" then
                        fn19()
                    else
                        fn18()
                    end
                end
            end
        end)

        Veeronica:AddCheckbox(fn(), {
            Text = "Auto Sk8 Trick",
            Default = false,
            Callback = function(vxAutoSk8Trick)
                getgenv().VX_AutoSk8Trick = vxAutoSk8Trick
            end,
        })

        getgenv().VX_BlockSk8Rebound = false
        local name = localPlayer6.Name
        local v16 = nil

        v16 = hookmetamethod(game, "__namecall", function(arg, ...)
            local tbl9 = {...}

            if getnamecallmethod() == "FireServer" and getgenv().VX_BlockSk8Rebound then
                local str = tostring(tbl9[1])
                if str == name .. "Sk8Rebound" then
                    return nil
                end

                if str == name .. "StopSk8" and typeof(tbl9[2]) == "table" then
                    for i, v17 in ipairs(tbl9[2]) do
                        if typeof(v17) == "Instance" then
                            -- [SorsHub fix V20.4] RemoteEvent ada di Modules.Network.Network.RemoteEvent
                            -- (terkonfirmasi dari dump path game); path lama kurang satu level
                            -- "Network" sehingga WaitForChild("RemoteEvent") menggantung selamanya.
                            ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(name .. "StopSk8", {buffer.fromstring("\"Manual\"")})
                            return nil
                        end
                    end
                end
            end

            return v16(arg, ...)
        end)

        Veeronica:AddCheckbox(fn(), {
            Text = "Anti Rebound",
            Default = false,
            Callback = function(vxBlockSk8Rebound)
                getgenv().VX_BlockSk8Rebound = vxBlockSk8Rebound
            end,
        })

        getgenv().VX_HighJumpEnabled = false
        getgenv().VX_HighJumpMult = 2
        getgenv().VX_HighJumpOrigValue = nil
        require(ReplicatedStorage4.Modules.Gameplay.Actors)
        getgenv().VX_Sk8Everywhere = false

        Veeronica:AddCheckbox(fn(), {
            Text = "Sk8 Everywhere",
            Default = false,
            Callback = function(vxSk8Everywhere)
                getgenv().VX_Sk8Everywhere = vxSk8Everywhere

                if vxSk8Everywhere and not getgenv()._Sk8EverywhereConn then
                    getgenv()._Sk8EverywhereConn = game:GetService("RunService").Heartbeat:Connect(function()
                        if not getgenv().VX_Sk8Everywhere then
                            return
                        end

                        pcall(function()
                            local v17 = nil
                            local Actors = require(ReplicatedStorage4.Modules.Gameplay.Actors)
                            local Util = require(ReplicatedStorage4.Modules.Utilities.Util)
                            local currentActors = Actors.CurrentActors

                            while true do
                                local v18, v19 = currentActors(nil, v17)
                                if v18 == nil then
                                    break
                                end
                                v17 = v18

                                if v19.ActorName == "Veeronica" and v19.Player == localPlayer6 then
                                    v19.State.InZone = true
                                    v19.State.ClosestSpray = true

                                    if v19.Behavior and v19.Behavior.Abilities and v19.Behavior.Abilities.Sk8 then
                                        local sk8 = v19.Behavior.Abilities.Sk8

                                        if not getgenv()._Sk8OrigCallback then
                                            getgenv()._Sk8OrigCallback = sk8.Callback

                                            sk8.Callback = function(arg, arg2, ...)
                                                local str = arg2

                                                if getgenv().VX_Sk8Everywhere and arg2 == "BAD" then
                                                    str = "SPRAY"
                                                end

                                                return getgenv()._Sk8OrigCallback(arg, str, ...)
                                            end
                                        end
                                    end

                                    if not v19.State.isSkating then
                                        Util:ToggleLockForAbilityIcon("Sk8", "NoCharges", false)
                                    end
                                end
                            end
                        end)
                    end)
                elseif not vxSk8Everywhere and getgenv()._Sk8EverywhereConn then
                    getgenv()._Sk8EverywhereConn:Disconnect()
                    getgenv()._Sk8EverywhereConn = nil

                    pcall(function()
                        local v17 = nil
                        local currentActors = require(ReplicatedStorage4.Modules.Gameplay.Actors).CurrentActors

                        while true do
                            local v18, v19 = currentActors(nil, v17)
                            if v18 == nil then
                                break
                            end
                            v17 = v18

                            if v19.ActorName == "Veeronica" and v19.Player == localPlayer6 and getgenv()._Sk8OrigCallback and v19.Behavior and v19.Behavior.Abilities and v19.Behavior.Abilities.Sk8 then
                                v19.Behavior.Abilities.Sk8.Callback = getgenv()._Sk8OrigCallback
                                getgenv()._Sk8OrigCallback = nil
                            end
                        end
                    end)
                end
            end,
        })
    end)
task.spawn(function()
        pcall(function()
            local Behavior = require(game:GetService("ReplicatedStorage").Assets.Survivors.JaneDoe.Behavior)
            local callback = Behavior.Abilities.Crystal.Callback
            local minChargeTime = nil
            local maxChargeTime = nil

            Behavior.Abilities.Crystal.Callback = function(arg, arg2)
                if not minChargeTime then
                    minChargeTime = arg.Config.Crystal.MinChargeTime
                    maxChargeTime = arg.Config.Crystal.MaxChargeTime
                end

                if not getgenv().JaneDoe_AutoInstantChargeEnabled then
                    arg.Config.Crystal.MinChargeTime = minChargeTime
                    arg.Config.Crystal.MaxChargeTime = maxChargeTime
                    return callback(arg, arg2)
                end

                arg.Config.Crystal.MaximumHoldTime = math.huge
                arg.Config.Crystal.MinChargeTime = 0
                arg.Config.Crystal.MaxChargeTime = 0.1
                return callback(arg, arg2)
            end
        end)

        v11:AddCheckbox(fn(), {
            Text = "Instant Charge",
            Default = false,
            Callback = function(janeDoeAutoInstantChargeEnabled)
                getgenv().JaneDoe_AutoInstantChargeEnabled = janeDoeAutoInstantChargeEnabled
            end,
        })

        getgenv().JaneDoe_InfHold2Enabled = false
        getgenv().JaneDoe_InfHold2Conn = nil
        getgenv().JaneDoe_InfHold2OldCallback = nil
        getgenv().JaneDoe_InfHold2OldMaxHoldTime = nil
        getgenv().JaneDoe_InfHold2Actor = nil

        getgenv().JaneDoe_PatchInfHold2Actor = function(janeDoeInfHold2Actor)
            if janeDoeInfHold2Actor.Config and janeDoeInfHold2Actor.Config.Crystal then
                if getgenv().JaneDoe_InfHold2OldMaxHoldTime == nil then
                    getgenv().JaneDoe_InfHold2OldMaxHoldTime = janeDoeInfHold2Actor.Config.Crystal.MaximumHoldTime
                end

                janeDoeInfHold2Actor.Config.Crystal.MaximumHoldTime = math.huge
            end

            if janeDoeInfHold2Actor.Behavior and janeDoeInfHold2Actor.Behavior.Abilities and janeDoeInfHold2Actor.Behavior.Abilities.Crystal and not getgenv().JaneDoe_InfHold2OldCallback then
                getgenv().JaneDoe_InfHold2Actor = janeDoeInfHold2Actor
                getgenv().JaneDoe_InfHold2OldCallback = janeDoeInfHold2Actor.Behavior.Abilities.Crystal.Callback

                janeDoeInfHold2Actor.Behavior.Abilities.Crystal.Callback = function(arg, arg2)
                    if getgenv().JaneDoe_InfHold2Enabled and arg.Config and arg.Config.Crystal then
                        arg.Config.Crystal.MaximumHoldTime = math.huge
                    end

                    if not getgenv().JaneDoe_InfHold2OldCallback then
                        return
                    end
                    return getgenv().JaneDoe_InfHold2OldCallback(arg, arg2)
                end
            end
        end

        getgenv().StartJaneDoe_InfHold2 = function()
            local Actors = require(game:GetService("ReplicatedStorage").Modules.Gameplay.Actors)

            pcall(function()
                local v16 = nil
                local currentActors = Actors.CurrentActors

                while true do
                    local v17, v18 = currentActors(nil, v16)
                    if v17 == nil then
                        break
                    end
                    v16 = v17
                    if v18.ActorName == "JaneDoe" then
                        getgenv().JaneDoe_PatchInfHold2Actor(v18)
                        break
                    end
                end
            end)

            if getgenv().JaneDoe_InfHold2Conn then
                return
            end

            getgenv().JaneDoe_InfHold2Conn = game:GetService("RunService").Heartbeat:Connect(function()
                local v16 = nil
                if not getgenv().JaneDoe_InfHold2Enabled then
                    return
                end
                local character2 = game:GetService("Players").LocalPlayer.Character
                if not character2 or character2.Name ~= "JaneDoe" then
                    return
                end
                local currentActors = Actors.CurrentActors

                while true do
                    local v17, v18 = currentActors(nil, v16)
                    if v17 == nil then
                        break
                    end
                    v16 = v17
                    if v18.ActorName == "JaneDoe" and v18.Rig == character2 then
                        pcall(getgenv().JaneDoe_PatchInfHold2Actor, v18)
                        break
                    end
                end
            end)
        end

        getgenv().StopJaneDoe_InfHold2 = function()
            if getgenv().JaneDoe_InfHold2Conn then
                getgenv().JaneDoe_InfHold2Conn:Disconnect()
                getgenv().JaneDoe_InfHold2Conn = nil
            end

            pcall(function()
                local janeDoeInfHold2Actor = getgenv().JaneDoe_InfHold2Actor

                if janeDoeInfHold2Actor then
                    if janeDoeInfHold2Actor.Config and janeDoeInfHold2Actor.Config.Crystal and getgenv().JaneDoe_InfHold2OldMaxHoldTime ~= nil then
                        janeDoeInfHold2Actor.Config.Crystal.MaximumHoldTime = getgenv().JaneDoe_InfHold2OldMaxHoldTime
                    end

                    if janeDoeInfHold2Actor.Behavior and janeDoeInfHold2Actor.Behavior.Abilities and janeDoeInfHold2Actor.Behavior.Abilities.Crystal and getgenv().JaneDoe_InfHold2OldCallback then
                        janeDoeInfHold2Actor.Behavior.Abilities.Crystal.Callback = getgenv().JaneDoe_InfHold2OldCallback
                    end
                end
            end)

            getgenv().JaneDoe_InfHold2OldCallback = nil
            getgenv().JaneDoe_InfHold2OldMaxHoldTime = nil
            getgenv().JaneDoe_InfHold2Actor = nil
        end

        v11:AddCheckbox(fn(), {
            Text = "Unlimited Crystal Hold",
            Default = false,
            Callback = function(janeDoeInfHold2Enabled)
                getgenv().JaneDoe_InfHold2Enabled = janeDoeInfHold2Enabled

                if janeDoeInfHold2Enabled then
                    getgenv().StartJaneDoe_InfHold2()
                else
                    getgenv().StopJaneDoe_InfHold2()
                end
            end,
        })

        v11:AddDivider({MarginTop = 2, MarginBottom = 2})
        local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
        game:GetService("RunService")
        local localPlayer6 = game:GetService("Players").LocalPlayer
        local currentCamera = workspace.CurrentCamera
        local remoteFunction = nil
        local flag4 = false
        local flag5 = false
        local n4 = -0.3
        local n5 = 0.6
        local tbl7 = {}

        pcall(function()
            remoteFunction = ReplicatedStorage4:WaitForChild("Modules", 10):WaitForChild("Network", 10):WaitForChild("Network", 10):WaitForChild("RemoteFunction", 10)
        end)

        local tbl8 = {
            hooks = {},
            installed = false,
            originalCallback = nil,
            install = function(arg, arg2)
                if arg.installed or not arg2 then
                    return
                end

                if typeof(getcallbackvalue) == "function" then
                    arg.originalCallback = getcallbackvalue(arg2, "OnClientInvoke")
                else
                    arg.originalCallback = arg2.OnClientInvoke
                end

                local tbl8 = {GetMousePosition = true, GetCameraCF = true}

                arg2.OnClientInvoke = function(arg3, ...)
                    if tbl8[arg3] then
                        for k, hook in pairs(arg.hooks) do
                            local ok, result2 = pcall(hook, arg3, ...)
                            if ok and result2 ~= nil then
                                return result2
                            end
                        end
                    end

                    if arg.originalCallback then
                        local ok, result2 = pcall(arg.originalCallback, arg3, ...)
                        if ok then
                            return result2
                        end
                    end
                end

                arg.installed = true
            end,
            uninstall = function(arg, arg2)
                if not arg.installed or not arg2 then
                    return
                end

                if arg.originalCallback then
                    arg2.OnClientInvoke = arg.originalCallback
                end

                arg.hooks = {}
                arg.originalCallback = nil
                arg.installed = false
            end,
        }

        local function fn18(arg)
            local ok, result2 = pcall(function()
                local now = tick()
                local position = arg.Position
                local v16 = tbl7[arg]
                if not v16 then
                    tbl7[arg] = {lastPos = position, lastTime = now, velocity = Vector3.zero}
                    return Vector3.zero
                end
                local n6 = now - v16.lastTime
                if n6 <= 0 then
                    return v16.velocity
                end
                local velocity = (position - v16.lastPos) / n6
                v16.lastPos = position
                v16.lastTime = now
                v16.velocity = velocity
                return velocity
            end)

            local vector = ok and result2 or Vector3.zero
            return vector
        end

        local function fn19()
            local character2 = localPlayer6.Character
            local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart3 then
                return nil
            end
            local players = workspace:FindFirstChild("Players")
            local killers = players and workspace.Players:FindFirstChild("Killers")
            if not killers then
                return nil
            end
            local v16 = nil
            local huge = math.huge

            for i, child in ipairs(killers:GetChildren()) do
                local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")
                local humanoid2 = child:FindFirstChildOfClass("Humanoid")

                if humanoidRootPart4 and humanoid2 and humanoid2.Health > 0 then
                    local magnitude = (humanoidRootPart4.Position - humanoidRootPart3.Position).Magnitude

                    if magnitude < huge then
                        huge = magnitude
                        v16 = child
                    end
                end
            end

            return v16
        end

        local function fn20(arg, arg2)
            local ok, result2 = pcall(function()
                local parent = arg.Parent
                local humanoid2 = parent and arg.Parent:FindFirstChildOfClass("Humanoid")
                local hipHeight = humanoid2 and humanoid2.HipHeight or 1.35
                local n6 = arg.CFrame.Position + Vector3.new(0, (hipHeight + arg.Size.Y / 2) / 2, 0)
                local v16 = fn18(arg2)
                local n7 = arg2.Position + v16 * n5 + Vector3.new(0, n4, 0) - n6
                local vector = Vector3.new(n7.X, 0, n7.Z)
                local magnitude = vector.Magnitude
                local y = n7.Y
                if magnitude < 0.01 then
                    local vector2 = y >= 0 and Vector3.new(0, 1, 0) or Vector3.new(0, -1, 0)
                    return CFrame.new(currentCamera.CFrame.Position, currentCamera.CFrame.Position + vector2)
                end
                local unit = vector.Unit
                local n8 = 250 * 250
                local n9 = n8 * n8 - 40 * (40 * magnitude * magnitude + 2 * y * n8)
                local flag6 = n9 < 0 and math.atan(y, magnitude) or math.atan(n8 - math.sqrt(n9), 40 * magnitude)
                local v17 = math.tan(flag6)
                local n10 = 3 + v17
                local n11 = math.abs(n10) < 0.0001 and -1.5707963267948966 or math.atan(3 * v17 - 1, n10)
                return CFrame.new(currentCamera.CFrame.Position, currentCamera.CFrame.Position + unit) * CFrame.Angles(n11, 0, 0)
            end)

            local v16 = ok and result2 or nil
            return v16
        end

        local function fn21()
            if flag4 or not remoteFunction then
                return
            end
            tbl8:install(remoteFunction)

            tbl8.hooks.jd_crystal = function(arg)
                if not flag5 then
                    return nil
                end
                local character2 = localPlayer6.Character
                local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart3 then
                    return nil
                end
                local v16 = fn19()
                local humanoidRootPart4 = v16 and v16:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart4 then
                    return nil
                end

                if arg == "GetMousePosition" then
                    local v17 = fn18(humanoidRootPart4)
                    return humanoidRootPart4.Position + v17 * n5 + Vector3.new(0, n4, 0)
                end

                if arg == "GetCameraCF" then
                    return fn20(humanoidRootPart3, humanoidRootPart4)
                end
                return nil
            end

            flag4 = true
        end

        local function jdCrystalSARemovePatch()
            if not flag4 then
                return
            end
            tbl8.hooks.jd_crystal = nil

            if next(tbl8.hooks) == nil then
                tbl8:uninstall(remoteFunction)
            end

            flag4 = false
        end

        getgenv()._jdCrystalSA_removePatch = jdCrystalSARemovePatch

        v11:AddCheckbox(fn(), {
            Text = "Crystal Silent Aim",
            Default = false,
            Tooltip = "Intercepts GetMousePosition/GetCameraCF to aim crystal at nearest killer automatically",
            Callback = function(arg)
                flag5 = arg

                if arg then
                    fn21()
                else
                    jdCrystalSARemovePatch()
                    tbl7 = {}
                end
            end,
        })

        v11:AddSlider(fn(), {
            Text = "Aim Offset (Y)",
            Min = -5,
            Max = 5,
            Default = n4,
            Rounding = 1,
            Callback = function(arg)
                n4 = tonumber(arg)
            end,
        })

        v11:AddSlider(fn(), {
            Text = "Prediction",
            Min = 0,
            Max = 1,
            Default = n5,
            Rounding = 2,
            Callback = function(arg)
                n5 = tonumber(arg)
            end,
        })
    end)
task.spawn(function()
        getgenv()._007_autoCloneEnabled = false
        getgenv()._007_detectionRange = 20
        getgenv()._007_M1SoundConns = {}
        getgenv()._007_wallCheck = false
        getgenv()._007_elevCheck = false
        getgenv()._007_cloneDelay = 0
        getgenv()._007_cloneHPEnabled = false
        getgenv()._007_cloneHPThreshold = 30
        local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
        local localPlayer6 = game:GetService("Players").LocalPlayer

        local function fn18()
            pcall(function()
                ReplicatedStorage4.Modules.Network.Network.RemoteEvent:FireServer("UseActorAbility", {buffer.fromstring("\003\005\000\000\000Clone")})
            end)
        end

        local function fn19(arg)
            if getgenv()._007_M1SoundConns[arg] then
                for i, v16 in ipairs(getgenv()._007_M1SoundConns[arg]) do
                    pcall(function()
                        v16:Disconnect()
                    end)
                end

                getgenv()._007_M1SoundConns[arg] = nil
            end
        end

        local function fn20(arg)
            if not getgenv()._007_autoCloneEnabled then
                return
            end
            local character2 = localPlayer6.Character
            local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")
            local humanoidRootPart4 = arg:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart3 or not humanoidRootPart4 then
                return
            end
            local magnitude = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude
            if getgenv()._007_detectionRange < magnitude then
                return
            end

            if getgenv()._007_wallCheck and getgenv().isWallBlocking and getgenv().isWallBlocking() then
                return
            end

            if getgenv()._007_elevCheck and humanoidRootPart4.Position.Y - humanoidRootPart3.Position.Y > 3 then
                return
            end

            if getgenv()._007_cloneHPEnabled then
                local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")

                if humanoid2 then
                    local health = humanoid2.Health
                    if getgenv()._007_cloneHPThreshold < health then
                        return
                    end
                end
            end

            local n007CloneDelay = getgenv()._007_cloneDelay
            local n4 = n007CloneDelay or 0

            if n4 > 0 then
                task.delay(n4, fn18)
            else
                fn18()
            end
        end

        local function fn21(arg, arg2)
            local killerSoundIds = getgenv().killerSoundIds
            local v16 = killerSoundIds and getgenv().killerSoundIds[arg.Name]
            if not v16 then
                return
            end
            local n007M1SoundConns = getgenv()._007_M1SoundConns
            local v17 = getgenv()._007_M1SoundConns[arg]
            local tbl7 = v17 or {}
            n007M1SoundConns[arg] = tbl7

            table.insert(getgenv()._007_M1SoundConns[arg], arg2.Played:Connect(function()
                local match = tostring(arg2.SoundId):match("%d+")
                if not match or not v16[match] then
                    return
                end
                fn20(arg)
            end))
        end

        local function fn22(arg)
            local humanoid2 = arg:FindFirstChildOfClass("Humanoid")

            if not humanoid2 then
                arg.ChildAdded:Connect(function(child)
                    if child:IsA("Humanoid") then
                        fn22(arg)
                    end
                end)

                return
            end

            local animator = humanoid2:FindFirstChildOfClass("Animator")

            if not animator then
                humanoid2.ChildAdded:Connect(function(child)
                    if child:IsA("Animator") then
                        fn22(arg)
                    end
                end)

                return
            end

            local n007M1SoundConns = getgenv()._007_M1SoundConns
            local v16 = getgenv()._007_M1SoundConns[arg]
            local tbl7 = v16 or {}
            n007M1SoundConns[arg] = tbl7

            table.insert(getgenv()._007_M1SoundConns[arg], animator.AnimationPlayed:Connect(function(arg2)
                local killerAnimIds = getgenv().killerAnimIds
                local v17 = killerAnimIds and getgenv().killerAnimIds[arg.Name]
                if not v17 then
                    return
                end
                local animation = arg2.Animation
                local match = animation and tostring(arg2.Animation.AnimationId):match("%d+")
                if not match or not v17[match] then
                    return
                end
                fn20(arg)
            end))
        end

        local function fn23(arg)
            fn19(arg)
            getgenv()._007_M1SoundConns[arg] = {}

            for i, descendant in ipairs(arg:GetDescendants()) do
                if descendant:IsA("Sound") then
                    fn21(arg, descendant)
                end
            end

            table.insert(getgenv()._007_M1SoundConns[arg], arg.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Sound") then
                    task.wait()
                    fn21(arg, descendant)
                end
            end))

            fn22(arg)
        end

        local function fn24(arg)
            if not arg then
                return
            end

            for i, child in ipairs(arg:GetChildren()) do
                task.spawn(function()
                    task.wait(0.3)
                    fn23(child)
                end)
            end

            arg.ChildAdded:Connect(function(child)
                task.wait(0.5)
                fn23(child)
            end)

            arg.ChildRemoved:Connect(function(child)
                fn19(child)
            end)
        end

        v14:AddCheckbox(fn(), {
            Text = "Auto Clone",
            Default = false,
            Callback = function(n007AutoCloneEnabled)
                getgenv()._007_autoCloneEnabled = n007AutoCloneEnabled
            end,
        })

        v14:AddSlider(fn(), {
            Text = "Detection Range",
            Min = 5,
            Max = 100,
            Default = 20,
            Rounding = 0,
            Callback = function(arg)
                getgenv()._007_detectionRange = tonumber(arg)
            end,
        })

        Settings5:AddCheckbox(fn(), {
            Text = "Clone On HP",
            Default = false,
            Callback = function(n007CloneHPEnabled)
                getgenv()._007_cloneHPEnabled = n007CloneHPEnabled
            end,
        })

        Settings5:AddSlider(fn(), {
            Text = "Clone HP Threshold",
            Default = 30,
            Min = 1,
            Max = 100,
            Rounding = 0,
            Callback = function(arg)
                local genv5 = getgenv()
                local num = tonumber(arg)
                local n007CloneHPThreshold = num or 30
                genv5._007_cloneHPThreshold = n007CloneHPThreshold
            end,
        })

        Settings5:AddDivider({MarginTop = 2, MarginBottom = 2})

        Settings5:AddSlider(fn(), {
            Text = "Clone Delay",
            Default = 0,
            Min = 0,
            Max = 0.5,
            Rounding = 2,
            Callback = function(arg)
                local genv5 = getgenv()
                local num = tonumber(arg)
                local n007CloneDelay = num or 0
                genv5._007_cloneDelay = n007CloneDelay
            end,
        })

        Settings5:AddCheckbox(fn(), {
            Text = "Wall Check",
            Default = false,
            Callback = function(n007WallCheck)
                getgenv()._007_wallCheck = n007WallCheck
            end,
        })

        Settings5:AddCheckbox(fn(), {
            Text = "High Elevation Check",
            Default = false,
            Callback = function(n007ElevCheck)
                getgenv()._007_elevCheck = n007ElevCheck
            end,
        })

        Settings5:AddDivider({MarginTop = 2, MarginBottom = 2})

        Settings5:AddSlider(fn(), {
            Text = "Prediction",
            Min = 0,
            Max = 1,
            Default = 0.2,
            Rounding = 2,
            Callback = function(arg)
                getgenv()._007_bbPrediction = tonumber(arg)
            end,
        })

        Settings5:AddSlider(fn(), {
            Text = "Circle Radius",
            Min = 1,
            Max = 50,
            Default = 5,
            Rounding = 1,
            Callback = function(arg)
                getgenv()._007_bbCircleRadius = tonumber(arg)
            end,
        });

        (function()
            local players = workspace:FindFirstChild("Players")
            local killers = players and players:FindFirstChild("Killers")

            if killers then
                fn24(killers)
            else
                workspace.DescendantAdded:Connect(function(descendant)
                    if descendant.Name == "Killers" and descendant.Parent and descendant.Parent.Name == "Players" then
                        fn24(descendant)
                    end
                end)
            end
        end)()

        local flag4 = false
        local connection8 = nil

        local function fn25()
            local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
            local modules = ReplicatedStorage5:FindFirstChild("Modules")
            local themes = modules and ReplicatedStorage5.Modules:FindFirstChild("Gameplay") and ReplicatedStorage5.Modules.Gameplay:FindFirstChild("Themes") or workspace:FindFirstChild("Themes")
            local lastSurvivor = themes and themes:FindFirstChild("LastSurvivor")
            return lastSurvivor
        end

        local function fn26()
            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer("UseActorAbility", {buffer.fromstring("\003\007\000\000\000c00lgui")})
        end

        v14:AddCheckbox(fn(), {
            Text = "Auto Coolgui LMS",
            Default = false,
            Callback = function(arg)
                flag4 = arg

                if arg then
                    connection8 = game:GetService("RunService").Heartbeat:Connect(function()
                        local character2 = game.Players.LocalPlayer.Character
                        if not character2 or not character2.Parent or character2.Parent.Name ~= "Survivors" then
                            return
                        end

                        if fn25() then
                            fn26()
                        end
                    end)
                elseif connection8 then
                    connection8:Disconnect()
                    connection8 = nil
                end
            end,
        })

        local localPlayer7 = game:GetService("Players").LocalPlayer
        getgenv().VX_CancelCoolguiEnabled = false
        local screenGui = nil

        local function fn27()
            if screenGui then
                screenGui:Destroy()
            end

            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "CancelCoolguiGui"
            screenGui.ResetOnSpawn = false
            screenGui.IgnoreGuiInset = true
            screenGui.Parent = localPlayer7.PlayerGui
            local imageButton = Instance.new("ImageButton")
            imageButton.Size = UDim2.fromOffset(60, 60)
            imageButton.Position = UDim2.new(1, -80, 0.5, -30)
            imageButton.BackgroundTransparency = 1
            imageButton.Image = "rbxassetid://89910721511648"
            imageButton.Parent = screenGui

            imageButton.MouseButton1Click:Connect(function()
                if not getgenv().VX_CancelCoolguiEnabled then
                    return
                end
                local character2 = localPlayer7.Character
                if not character2 then
                    return
                end

                pcall(function()
                    local boolValue = Instance.new("BoolValue")
                    boolValue.Name = "Result"
                    boolValue.Parent = character2
                    game:GetService("Debris"):AddItem(boolValue, 2)
                end)
            end)
        end

        v14:AddCheckbox(fn(), {
            Text = "Cancel Coolgui",
            Default = false,
            Callback = function(vxCancelCoolguiEnabled)
                getgenv().VX_CancelCoolguiEnabled = vxCancelCoolguiEnabled

                if vxCancelCoolguiEnabled then
                    fn27()
                elseif screenGui then
                    screenGui:Destroy()
                    screenGui = nil
                end
            end,
        })

        v14:AddDivider({MarginTop = 2, MarginBottom = 2})

        getgenv()._007_canUseBodyBlock = function()
            local character2 = getgenv()._007_lp.Character
            if not character2 then
                return false
            end
            local flag5 = character2.Name == "007n7" and character2.Parent == getgenv()._007_workspace.Players.Survivors
            return flag5
        end

        getgenv()._007_getNearestKillerChar = function()
            local huge = math.huge
            local v16 = nil
            local players = getgenv()._007_workspace.Players
            local killers = players and getgenv()._007_workspace.Players:FindFirstChild("Killers")
            if not killers then
                return nil
            end
            local n007Char = getgenv()._007_char
            local humanoidRootPart3 = n007Char and getgenv()._007_char:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart3 then
                return nil
            end

            for k, child in pairs(killers:GetChildren()) do
                local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart4 then
                    local magnitude = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude

                    if magnitude < huge then
                        v16 = child
                        huge = magnitude
                    end
                end
            end

            return v16
        end

        getgenv()._007_getNearestSurvivorChar = function()
            local huge = math.huge
            local v16 = nil
            local players = getgenv()._007_workspace.Players
            local survivors = players and getgenv()._007_workspace.Players:FindFirstChild("Survivors")
            if not survivors then
                return nil
            end
            local n007Char = getgenv()._007_char
            local humanoidRootPart3 = n007Char and getgenv()._007_char:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart3 then
                return nil
            end

            for k, child in pairs(survivors:GetChildren()) do
                if child ~= getgenv()._007_char then
                    local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")

                    if humanoidRootPart4 then
                        local magnitude = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude

                        if magnitude < huge then
                            v16 = child
                            huge = magnitude
                        end
                    end
                end
            end

            return v16
        end

        getgenv()._007_currentTargetMode = "Disabled"
        getgenv()._007_bbBehavior = "Normal"
        getgenv()._007_bbPrediction = 0.2
        getgenv()._007_bbCircleRadius = 5
        getgenv()._007_bbCircleSpeed = 1
        getgenv()._007_bbZigzagAmplitude = 6
        getgenv()._007_bbZigzagFrequency = 2
        getgenv()._007_bbRunDistance = 20
        getgenv()._007_bbStrafeWidth = 4
        getgenv()._007_bbStrafeSpeed = 3
        getgenv()._007_bbAggressiveOffset = 0.5
        getgenv()._007_bbInterceptPrediction = 0.6

        getgenv()._007_getTargetPos = function()
            local n007CurrentTargetMode = getgenv()._007_currentTargetMode

            local function fn28(arg)
                return arg.Position + arg.AssemblyLinearVelocity * getgenv()._007_bbPrediction, arg
            end

            if n007CurrentTargetMode == "Killers" then
                local v16 = getgenv()._007_getNearestKillerChar()
                if v16 and v16:FindFirstChild("HumanoidRootPart") then
                    return fn28(v16.HumanoidRootPart)
                end
            elseif n007CurrentTargetMode == "Survivors" then
                local v16 = getgenv()._007_getNearestSurvivorChar()
                if v16 and v16:FindFirstChild("HumanoidRootPart") then
                    return fn28(v16.HumanoidRootPart)
                end
            elseif n007CurrentTargetMode == "Yourself" then
                local character2 = getgenv()._007_lp.Character
                if character2 and character2:FindFirstChild("HumanoidRootPart") then
                    return fn28(character2.HumanoidRootPart)
                end
            elseif n007CurrentTargetMode == "Random Survivor" then
                local players = getgenv()._007_workspace.Players
                local survivors = players and getgenv()._007_workspace.Players:FindFirstChild("Survivors")

                if survivors then
                    local tbl7 = {}

                    for k, child in pairs(survivors:GetChildren()) do
                        if child ~= getgenv()._007_char and child:FindFirstChild("HumanoidRootPart") then
                            table.insert(tbl7, child)
                        end
                    end

                    if #tbl7 > 0 then
                        return fn28(tbl7[math.random(1, #tbl7)].HumanoidRootPart)
                    end
                end
            elseif n007CurrentTargetMode == "Nearest Survivor" then
                local players = getgenv()._007_workspace.Players
                local survivors = players and getgenv()._007_workspace.Players:FindFirstChild("Survivors")
                local n007Char = getgenv()._007_char
                local humanoidRootPart3 = n007Char and getgenv()._007_char:FindFirstChild("HumanoidRootPart")

                if survivors and humanoidRootPart3 then
                    local huge = math.huge
                    local v16 = nil

                    for k, child in pairs(survivors:GetChildren()) do
                        if child ~= getgenv()._007_char then
                            local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")

                            if humanoidRootPart4 then
                                local magnitude = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude

                                if magnitude < huge then
                                    huge = magnitude
                                    v16 = child
                                end
                            end
                        end
                    end

                    if v16 then
                        return fn28(v16.HumanoidRootPart)
                    end
                end
            elseif n007CurrentTargetMode == "Lowest HP" then
                local players = getgenv()._007_workspace.Players
                local survivors = players and getgenv()._007_workspace.Players:FindFirstChild("Survivors")

                if survivors then
                    local huge = math.huge
                    local v16 = nil

                    for k, child in pairs(survivors:GetChildren()) do
                        if child ~= getgenv()._007_char then
                            local humanoid2 = child:FindFirstChildOfClass("Humanoid")

                            if humanoid2 and humanoid2.Health > 0 and humanoid2.Health < huge then
                                huge = humanoid2.Health
                                v16 = child
                            end
                        end
                    end

                    if v16 and v16:FindFirstChild("HumanoidRootPart") then
                        return fn28(v16.HumanoidRootPart)
                    end
                end
            elseif n007CurrentTargetMode == "Nearest + Lowest HP" then
                local players = getgenv()._007_workspace.Players
                local survivors = players and getgenv()._007_workspace.Players:FindFirstChild("Survivors")
                local n007Char = getgenv()._007_char
                local humanoidRootPart3 = n007Char and getgenv()._007_char:FindFirstChild("HumanoidRootPart")

                if survivors and humanoidRootPart3 then
                    local huge = math.huge
                    local v16 = nil

                    for k, child in pairs(survivors:GetChildren()) do
                        if child ~= getgenv()._007_char then
                            local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")
                            local humanoid2 = child:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart4 and humanoid2 and humanoid2.Health > 0 then
                                local n4 = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude + humanoid2.Health

                                if n4 < huge then
                                    huge = n4
                                    v16 = child
                                end
                            end
                        end
                    end

                    if v16 and v16:FindFirstChild("HumanoidRootPart") then
                        return fn28(v16.HumanoidRootPart)
                    end
                end
            elseif n007CurrentTargetMode == "Random" then
                local players = getgenv()._007_workspace.Players
                local killers = players and getgenv()._007_workspace.Players:FindFirstChild("Killers")
                local players2 = getgenv()._007_workspace.Players
                local survivors = players2 and getgenv()._007_workspace.Players:FindFirstChild("Survivors")
                local tbl7 = {}

                if killers then
                    for k, child in pairs(killers:GetChildren()) do
                        if child:FindFirstChild("HumanoidRootPart") then
                            table.insert(tbl7, child)
                        end
                    end
                end

                if survivors then
                    for k, child in pairs(survivors:GetChildren()) do
                        if child ~= getgenv()._007_char and child:FindFirstChild("HumanoidRootPart") then
                            table.insert(tbl7, child)
                        end
                    end
                end

                if #tbl7 > 0 then
                    return fn28(tbl7[math.random(1, #tbl7)].HumanoidRootPart)
                end
            elseif n007CurrentTargetMode == "Nearest" then
                local n007Char = getgenv()._007_char
                local humanoidRootPart3 = n007Char and getgenv()._007_char:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart3 then
                    local huge = math.huge
                    local v16 = nil
                    local players = getgenv()._007_workspace.Players
                    local killers = players and getgenv()._007_workspace.Players:FindFirstChild("Killers")
                    local players2 = getgenv()._007_workspace.Players
                    local survivors = players2 and getgenv()._007_workspace.Players:FindFirstChild("Survivors")

                    if killers then
                        for k, child in pairs(killers:GetChildren()) do
                            local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")

                            if humanoidRootPart4 then
                                local magnitude = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude

                                if magnitude < huge then
                                    huge = magnitude
                                    v16 = child
                                end
                            end
                        end
                    end

                    if survivors then
                        for k, child in pairs(survivors:GetChildren()) do
                            if child ~= getgenv()._007_char then
                                local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")

                                if humanoidRootPart4 then
                                    local magnitude = (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude

                                    if magnitude < huge then
                                        huge = magnitude
                                        v16 = child
                                    end
                                end
                            end
                        end
                    end

                    if v16 and v16:FindFirstChild("HumanoidRootPart") then
                        return fn28(v16.HumanoidRootPart)
                    end
                end
            elseif n007CurrentTargetMode == "Closest To Crosshair" then
                local saGetClosestToCrosshair = getgenv().SA_GetClosestToCrosshair
                local v16 = saGetClosestToCrosshair and getgenv().SA_GetClosestToCrosshair()
                if v16 and v16:FindFirstChild("HumanoidRootPart") then
                    return fn28(v16.HumanoidRootPart)
                end
            elseif n007CurrentTargetMode == "Closest To Cursor" then
                local UserInputService = game:GetService("UserInputService")
                if not UserInputService.KeyboardEnabled or UserInputService.TouchEnabled then
                    return nil, nil
                end
                local currentCamera = workspace.CurrentCamera
                local character2 = getgenv()._007_lp.Character
                local mouse = getgenv()._007_lp:GetMouse()
                local vector2 = Vector2.new(mouse.X, mouse.Y)
                local huge = math.huge
                local v16 = nil
                local players = workspace:FindFirstChild("Players")
                local tbl7 = {}
                local survivors = players and players:FindFirstChild("Survivors")
                local killers = players and players:FindFirstChild("Killers")
                tbl7[1] = survivors
                tbl7[2] = killers
                local v17, v18, v19 = ipairs(tbl7)
                local v20 = v19
                local v21 = v17
                local v22 = v18

                while true do
                    local v23, v24 = v21(v22, v20)
                    if v23 == nil then
                        break
                    end
                    v20 = v23

                    if v24 then
                        for k, child in pairs(v24:GetChildren()) do
                            if child ~= character2 then
                                local humanoidRootPart3 = child:FindFirstChild("HumanoidRootPart")

                                if humanoidRootPart3 then
                                    local v25, v26 = currentCamera:WorldToViewportPoint(humanoidRootPart3.Position)

                                    if v26 then
                                        local magnitude = (Vector2.new(v25.X, v25.Y) - vector2).Magnitude
                                        local saCrosshairRadius = getgenv().SA_CrosshairRadius
                                        local n4 = saCrosshairRadius or 120

                                        if magnitude <= n4 and magnitude < huge then
                                            huge = magnitude
                                            v16 = child
                                        end
                                    end
                                end
                            end
                        end

                        v20 = v23
                    end
                end

                if v16 and v16:FindFirstChild("HumanoidRootPart") then
                    return fn28(v16.HumanoidRootPart)
                end
            end

            return nil, nil
        end

        getgenv()._007_MouseModule = nil
        getgenv()._007_OriginalGetMousePos = nil

        pcall(function()
            getgenv()._007_MouseModule = require(getgenv()._007_RepStorage.Systems.Player.Miscellaneous.GetPlayerMousePosition)
            getgenv()._007_OriginalGetMousePos = getgenv()._007_MouseModule.GetMousePos
        end)

        getgenv()._007_updateBodyBlock = function(n007CurrentTargetMode)
            getgenv()._007_currentTargetMode = n007CurrentTargetMode

            pcall(function()
                getgenv().StopSA_FOVCircle()
            end)

            pcall(function()
                getgenv().StopSA_CrosshairCircle()
            end)

            if n007CurrentTargetMode == "Closest To Cursor" then
                local UserInputService = game:GetService("UserInputService")

                if UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled then
                    pcall(function()
                        getgenv().StartSA_FOVCircle()
                    end)
                end
            elseif n007CurrentTargetMode == "Closest To Crosshair" then
                pcall(function()
                    getgenv().StartSA_CrosshairCircle()
                end)
            end

            if not getgenv()._007_MouseModule or not getgenv()._007_OriginalGetMousePos then
                return
            end

            if n007CurrentTargetMode == "Disabled" then
                getgenv()._007_MouseModule.GetMousePos = getgenv()._007_OriginalGetMousePos
            else
                getgenv()._007_MouseModule.GetMousePos = function(...)
                    if not getgenv()._007_canUseBodyBlock() then
                        return getgenv()._007_OriginalGetMousePos(...)
                    end
                    local v16, v17 = getgenv()._007_getTargetPos()
                    if not v16 then
                        return getgenv()._007_OriginalGetMousePos(...)
                    end
                    local n007BbBehavior = getgenv()._007_bbBehavior
                    local character2 = getgenv()._007_lp.Character
                    local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")
                    if n007BbBehavior == "Normal" then
                        return v16
                    end

                    if n007BbBehavior == "Zigzag" then
                        local n4 = os.clock() * getgenv()._007_bbZigzagFrequency
                        local unit = humanoidRootPart3 and (v16 - humanoidRootPart3.Position).Unit or Vector3.new(0, 0, 1)
                        return v16 + Vector3.new(-unit.Z, 0, unit.X) * math.sin(n4) * getgenv()._007_bbZigzagAmplitude
                    end

                    if n007BbBehavior == "Run Away" then
                        if not humanoidRootPart3 then
                            return v16
                        end
                        return humanoidRootPart3.Position + (humanoidRootPart3.Position - v16).Unit * getgenv()._007_bbRunDistance
                    end

                    if n007BbBehavior == "Orbit" then
                        local n4 = os.clock() * getgenv()._007_bbCircleSpeed
                        return Vector3.new(v16.X + math.cos(n4) * getgenv()._007_bbCircleRadius, v16.Y, v16.Z + math.sin(n4) * getgenv()._007_bbCircleRadius)
                    end

                    if n007BbBehavior == "Front" then
                        if v17 then
                            return v17.Position + v17.CFrame.LookVector * 2.5
                        end
                    elseif n007BbBehavior == "Back" then
                        if v17 then
                            return v17.Position - v17.CFrame.LookVector * 2.5
                        end
                    elseif n007BbBehavior == "Push" then
                        if v17 then
                            local lookVector = v17.CFrame.LookVector
                            v17.AssemblyLinearVelocity = v17.AssemblyLinearVelocity + lookVector * 80
                            return v17.Position - lookVector * 1.5
                        end
                    elseif n007BbBehavior == "Strafe" then
                        if v17 then
                            return v17.Position + v17.CFrame.RightVector * math.sin(os.clock() * getgenv()._007_bbStrafeSpeed) * getgenv()._007_bbStrafeWidth
                        end
                    elseif n007BbBehavior == "Mirror" then
                        if v17 then
                            local assemblyLinearVelocity = v17.AssemblyLinearVelocity
                            local vector = assemblyLinearVelocity.Magnitude > 0.1 and -assemblyLinearVelocity.Unit or Vector3.new(0, 0, 1)
                            return v17.Position + vector * 3
                        end
                    elseif n007BbBehavior == "Aggressive" then
                        if v17 and humanoidRootPart3 then
                            return v17.Position - (v17.Position - humanoidRootPart3.Position).Unit * getgenv()._007_bbAggressiveOffset
                        end
                    elseif n007BbBehavior == "Intercept" and v17 then
                        return v17.Position + v17.AssemblyLinearVelocity * getgenv()._007_bbInterceptPrediction
                    end

                    return v16
                end
            end
        end

        local worldModel2 = Instance.new("WorldModel")
        local clone2
        do
            local okRig2, rigSrc2 = pcall(function()
                local surv = game:GetService("ReplicatedStorage").Assets.Survivors["007n7"]
                return surv:FindFirstChild("Rig") or surv:FindFirstChildWhichIsA("Model")
            end)
            if okRig2 and rigSrc2 then clone2 = rigSrc2:Clone() end
            if not clone2 then clone2 = Instance.new("Model") end -- [SorsHub fix] Rig tidak ada
        end
        clone2.Name = "CloneModel"

        for i, descendant in ipairs(clone2:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if descendant.Name == "HumanoidRootPart" then
                    descendant.Anchored = true
                    descendant.Transparency = 1
                else
                    descendant.Anchored = false
                end
            end
        end

        pcall(function() clone2:PivotTo(CFrame.new(-3, 1.4, 0) * CFrame.Angles(0, math.rad(-90), 0)) end)
        clone2.Parent = worldModel2
        local clone3
do
        local okRig, rigSrc = pcall(function()
            local slasher = game:GetService("ReplicatedStorage").Assets.Killers.Slasher
            return slasher:FindFirstChild("Rig") or slasher:FindFirstChildWhichIsA("Model")
        end)
        if okRig and rigSrc then clone3 = rigSrc:Clone() end
        if not clone3 then clone3 = Instance.new("Model") end -- [SorsHub fix] Rig tidak ada di game ini
    end
        clone3.Name = "KillerModel"

        for i, descendant in ipairs(clone3:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if descendant.Name == "HumanoidRootPart" then
                    descendant.Anchored = true
                    descendant.Transparency = 1
                else
                    descendant.Anchored = false
                end
            end
        end

        pcall(function() clone3:PivotTo(CFrame.new(0, 1.4, 0) * CFrame.Angles(0, math.rad(-90), 0)) end)
        clone3.Parent = worldModel2

        v14:AddViewport(fn(), {
            Object = worldModel2,
            Interactive = false,
            Height = 260,
            AutoFocus = false,
        })

        task.spawn(function()
            local v16 = nil
            local n4 = os.clock() + 6

            repeat
                task.wait(0.1)

                for i, descendant in ipairs(game:GetService("CoreGui"):GetDescendants()) do
                    if descendant:IsA("ViewportFrame") and descendant:FindFirstChild("CloneModel", true) then
                        v16 = descendant
                        break
                    end
                end

                if not v16 then
                    for i, descendant in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                        if descendant:IsA("ViewportFrame") and descendant:FindFirstChild("CloneModel", true) then
                            v16 = descendant
                            break
                        end
                    end
                end
            until v16 or n4 < os.clock()

            if not v16 then
                return
            end
            local currentCamera = v16.CurrentCamera

            if currentCamera then
                currentCamera.CFrame = CFrame.new(Vector3.new(0, 2.5, 7), Vector3.new(0, 1.5, 0))
            end

            local cloneModel = v16:FindFirstChild("CloneModel", true)
            local killerModel = v16:FindFirstChild("KillerModel", true)
            local v17 = nil
            local v18 = nil

            if cloneModel then
                local humanoid2 = cloneModel:FindFirstChildOfClass("Humanoid")
                local humanoid3 = humanoid2 or cloneModel:FindFirstChild("Humanoid", true)

                if humanoid3 then
                    local animator = humanoid3:FindFirstChildOfClass("Animator")
                    local animator2 = animator or Instance.new("Animator", humanoid3)
                    local animation = Instance.new("Animation")
                    animation.AnimationId = "rbxassetid://131082534135875"
                    v17 = animator2:LoadAnimation(animation)
                    v17.Looped = true
                    local animation2 = Instance.new("Animation")
                    animation2.AnimationId = "rbxassetid://136252471123500"
                    v18 = animator2:LoadAnimation(animation2)
                    v18.Looped = true
                    v17:Play()
                end
            end

            if killerModel then
                local humanoid2 = killerModel:FindFirstChildOfClass("Humanoid")
                local humanoid3 = humanoid2 or killerModel:FindFirstChild("Humanoid", true)

                if humanoid3 then
                    local animator = humanoid3:FindFirstChildOfClass("Animator")
                    local animator2 = animator or Instance.new("Animator", humanoid3)
                    local animation = Instance.new("Animation")
                    animation.AnimationId = "rbxassetid://116050994905421"
                    local v19 = animator2:LoadAnimation(animation)
                    v19.Looped = true
                    v19:Play()
                end
            end

            local n5 = 0
            local flag5 = false

            game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
                n5 = n5 + deltaTime * 1.5
                local n007BbBehavior = getgenv()._007_bbBehavior
                local str = n007BbBehavior or "Normal"
                local cloneModel2 = v16:FindFirstChild("CloneModel", true)
                local killerModel2 = v16:FindFirstChild("KillerModel", true)
                if not cloneModel2 or not killerModel2 then
                    return
                end
                local humanoidRootPart3 = killerModel2:FindFirstChild("HumanoidRootPart", true)
                if not humanoidRootPart3 then
                    return
                end
                local position = humanoidRootPart3.Position
                local lookVector = humanoidRootPart3.CFrame.LookVector
                local rightVector = humanoidRootPart3.CFrame.RightVector
                local cframe = CFrame.Angles(0, math.rad(-90), 0)
                local flag6

                if str == "Orbit" then
                    cloneModel2:PivotTo(CFrame.new(position + Vector3.new(math.cos(n5) * 2.8, 0, math.sin(n5) * 2.8)) * cframe)
                    flag6 = true
                elseif str == "Zigzag" then
                    local vector = Vector3.new(-lookVector.Z, 0, lookVector.X)
                    cloneModel2:PivotTo(CFrame.new(position + lookVector * 2.5 + vector * math.sin(n5 * 3) * 2) * cframe)
                    flag6 = true
                elseif str == "Run Away" then
                    cloneModel2:PivotTo(CFrame.new(position + lookVector * (2.5 + math.sin(n5 * 2) * 2.5)) * cframe)
                    flag6 = true
                elseif str == "Front" then
                    cloneModel2:PivotTo(CFrame.new(position + lookVector * 2.5) * cframe)
                    flag6 = false
                elseif str == "Back" then
                    cloneModel2:PivotTo(CFrame.new(position - lookVector * 2.5) * cframe)
                    flag6 = false
                elseif str == "Push" then
                    cloneModel2:PivotTo(CFrame.new(position - lookVector * (1.5 + math.abs(math.sin(n5 * 3)) * 3)) * cframe)
                    flag6 = true
                elseif str == "Strafe" then
                    cloneModel2:PivotTo(CFrame.new(position + rightVector * math.sin(n5) * 2.5) * cframe)
                    flag6 = true
                elseif str == "Aggressive" then
                    cloneModel2:PivotTo(CFrame.new(position + lookVector * (0.5 + math.abs(math.sin(n5 * 4)) * 0.5) + rightVector * math.sin(n5 * 5) * 0.6) * cframe)
                    flag6 = true
                elseif str == "Intercept" then
                    cloneModel2:PivotTo(CFrame.new(position + lookVector * 2 + rightVector * math.cos(n5) * 2) * cframe)
                    flag6 = true
                else
                    cloneModel2:PivotTo(CFrame.new(position + Vector3.new(-3, 0, 0)) * cframe)
                    flag6 = false
                end

                if flag6 ~= flag5 then
                    flag5 = flag6

                    if v17 and v18 then
                        if flag6 then
                            v17:Stop(0)
                            v18:Play(0)
                        else
                            v18:Stop(0)
                            v17:Play(0)
                        end
                    end
                end
            end)
        end)

        v14:AddCheckbox(fn(), {
            Text = "Enable BodyBlock",
            Default = false,
            Callback = function(arg)
                if arg then
                    local n007UpdateBodyBlock = getgenv()._007_updateBodyBlock
                    local n007CurrentTargetMode = getgenv()._007_currentTargetMode ~= "Disabled" and getgenv()._007_currentTargetMode or "Killers"
                    n007UpdateBodyBlock(n007CurrentTargetMode)
                else
                    getgenv()._007_updateBodyBlock("Disabled")
                end
            end,
        })

        v14:AddDropdown(fn(), {
            Text = "BodyBlock Target",
            Values = {
                "Killers",
                "Survivors",
                "Yourself",
                "Random Survivor",
                "Nearest Survivor",
                "Lowest HP",
                "Nearest + Lowest HP",
                "Random",
                "Nearest",
                "Closest To Crosshair",
                "Closest To Cursor",
            },
            Default = 1,
            Callback = function(arg)
                getgenv()._007_updateBodyBlock(arg)
            end,
        })

        v14:AddDropdown(fn(), {
            Text = "BodyBlock Behavior",
            Values = {
                "Normal",
                "Zigzag",
                "Run Away",
                "Orbit",
                "Front",
                "Back",
                "Push",
                "Strafe",
                "Mirror",
                "Aggressive",
                "Intercept",
            },
            Default = 1,
            Callback = function(n007BbBehavior)
                getgenv()._007_bbBehavior = n007BbBehavior
                getgenv()._007_updateBodyBlock(getgenv()._007_currentTargetMode)
            end,
        })

        task.spawn(function()
            task.wait(0.6)

            if getgenv()._007_currentTargetMode and getgenv()._007_currentTargetMode ~= "Disabled" then
                getgenv()._007_updateBodyBlock(getgenv()._007_currentTargetMode)
            end
        end)
    end)
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local localPlayer6 = game:GetService("Players").LocalPlayer
if not getgenv().DusekkarHookInitialized then
        getgenv().DusekkarHookInitialized = true
        getgenv().DusekkarProtectionActive = false
        local v16 = nil

        v16 = hookmetamethod(game, "__namecall", newcclosure(function(arg, ...)
            local v17 = getnamecallmethod()
            local tbl7 = {...}

            if getgenv().DusekkarProtectionActive and v17 == "FireServer" then
                local name = localPlayer6.Name
                if type(tbl7[1]) == "string" and tbl7[1] == name .. "DusekkarCancel" then
                    return
                end
            end

            return v16(arg, ...)
        end))
    end
getgenv().EnableDusekkarProtection = function()
        getgenv().DusekkarProtectionActive = true

        task.spawn(function()
            task.wait(4)

            pcall(function()
                ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer({localPlayer6.Name .. "DusekkarCancel"})
            end)
        end)
    end
getgenv().DisableDusekkarProtection = function()
        getgenv().DusekkarProtectionActive = false
    end
Dusekkar:AddCheckbox(fn(), {
        Text = "Anti-Cancelled Protection",
        Default = false,
        Callback = function(arg)
            if arg then
                getgenv().EnableDusekkarProtection()
            else
                getgenv().DisableDusekkarProtection()
            end
        end,
    })
getgenv().DusekkarInfiniteRangeEnabled = false
Dusekkar:AddCheckbox(fn(), {
        Text = "Infinite Range Protection",
        Default = false,
        Callback = function(dusekkarInfiniteRangeEnabled)
            getgenv().DusekkarInfiniteRangeEnabled = dusekkarInfiniteRangeEnabled

            if dusekkarInfiniteRangeEnabled then
                pcall(function()
                    local Config = require(ReplicatedStorage4.Assets.Survivors.Dusekkar.Config)
                    local origSpawnDist = Config._origSpawnDist
                    local spawnProtectionEffectMaxDistance = origSpawnDist or Config.SpawnProtectionEffectMaxDistance
                    Config._origSpawnDist = spawnProtectionEffectMaxDistance
                    local origBeamRange = Config._origBeamRange
                    local plasmaBeamHitboxRange = origBeamRange or Config.PlasmaBeamHitboxRange
                    Config._origBeamRange = plasmaBeamHitboxRange
                    Config.SpawnProtectionEffectMaxDistance = math.huge
                    Config.PlasmaBeamHitboxRange = math.huge
                end)
            else
                pcall(function()
                    local Config = require(ReplicatedStorage4.Assets.Survivors.Dusekkar.Config)
                    local origSpawnDist = Config._origSpawnDist
                    local spawnProtectionEffectMaxDistance = origSpawnDist or 100
                    Config.SpawnProtectionEffectMaxDistance = spawnProtectionEffectMaxDistance
                    local origBeamRange = Config._origBeamRange
                    local plasmaBeamHitboxRange = origBeamRange or 100
                    Config.PlasmaBeamHitboxRange = plasmaBeamHitboxRange
                end)
            end
        end,
    })
getgenv().DusekkarWallbangEnabled = false
getgenv().DusekkarWallbangHook = nil
Dusekkar:AddCheckbox(fn(), {
        Text = "Protection Wallbang",
        Default = false,
        Callback = function(dusekkarWallbangEnabled)
            if dusekkarWallbangEnabled then
                if not getgenv().DusekkarWallbangHook then
                    getgenv().DusekkarWallbangHook = hookfunction(require(game:GetService("ReplicatedStorage").Modules.Util).IsOnScreen, function()
                        return true
                    end)
                end
            elseif getgenv().DusekkarWallbangHook then
                hookfunction(require(game:GetService("ReplicatedStorage").Modules.Util).IsOnScreen, getgenv().DusekkarWallbangHook)
                getgenv().DusekkarWallbangHook = nil
            end

            getgenv().DusekkarWallbangEnabled = dusekkarWallbangEnabled
        end,
    })
local genv5 = getgenv()
local twoTimeStab = getgenv().TwoTimeStab
local v16 = twoTimeStab
if not twoTimeStab then
        local tbl7 = {}
        v16 = tbl7
        tbl7.Enabled = false
        tbl7.StartDelay = 0.05
        tbl7.Duration = 0.5
        tbl7.BehindStuds = 4
    end
genv5.TwoTimeStab = v16
local flag4 = false
local function fn18()
        local players = workspace:FindFirstChild("Players")
        if not players then
            return nil
        end
        local killers = players:FindFirstChild("Killers")
        if not killers then
            return nil
        end

        for i, descendant in ipairs(killers:GetDescendants()) do
            if not descendant:IsA("Model") then
                continue
            end
            local humanoid2 = descendant:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart3 = descendant:FindFirstChild("HumanoidRootPart")
            if humanoid2 and humanoidRootPart3 and humanoid2.Health > 0 then
                return humanoidRootPart3
            end
        end

        return nil
    end
local function fn19()
        if not getgenv().TwoTimeStab.Enabled or flag4 then
            return
        end
        flag4 = true
        local localPlayer7 = game:GetService("Players").LocalPlayer
        local character2 = localPlayer7.Character
        local parent = character2 or localPlayer7.CharacterAdded:Wait()
        local humanoidRootPart3 = parent:WaitForChild("HumanoidRootPart")
        task.wait(getgenv().TwoTimeStab.StartDelay)
        if not parent.Parent then
            flag4 = false
            return
        end
        local part = Instance.new("Part")
        part.Name = "TwoTimePlace"
        part.Size = Vector3.new(2, 2, 2)
        part.Transparency = 0
        part.CanCollide = false
        part.Anchored = true
        part.Parent = parent
        local primaryPart = parent.PrimaryPart
        parent.PrimaryPart = part
        local now = os.clock()

        while os.clock() - now < getgenv().TwoTimeStab.Duration and parent.Parent and part.Parent and getgenv().TwoTimeStab.Enabled do
            local v17 = fn18()

            if v17 then
                part.CFrame = v17.CFrame * CFrame.new(0, 0, getgenv().TwoTimeStab.BehindStuds)
                humanoidRootPart3.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end

            game:GetService("RunService").PreRender:Wait()
        end

        if part and part.Parent then
            part:Destroy()
        end

        if parent and parent.Parent then
            parent.PrimaryPart = primaryPart
        end

        flag4 = false
    end
local function fn20(character2)
        character2:WaitForChild("Humanoid"):WaitForChild("Animator").AnimationPlayed:Connect(function(arg)
            if not arg or not arg.Animation then
                return
            end
            local animationId = arg.Animation.AnimationId
            local str = animationId or ""
            local str2 = tostring(str):gsub("%D", "")

            if (str2 == "100725497418533" or str2 == "89448354637442") and getgenv().TwoTimeStab.Enabled then
                task.spawn(fn19)
            end
        end)
    end
local localPlayer7 = game:GetService("Players").LocalPlayer
if localPlayer7.Character then
        fn20(localPlayer7.Character)
    end
localPlayer7.CharacterAdded:Connect(fn20)
v15:AddCheckbox(fn(), {
        Text = "Automatic Stab",
        Default = false,
        Callback = function(enabled)
            getgenv().TwoTimeStab.Enabled = enabled
        end,
    })
v15:AddSlider(fn(), {
        Text = "Fire Delay",
        Min = 0,
        Max = 0.5,
        Default = 0.05,
        Rounding = 2,
        Callback = function(arg)
            getgenv().TwoTimeStab.StartDelay = tonumber(arg)
        end,
    })
v15:AddSlider(fn(), {
        Text = "Hold Time",
        Min = 0.1,
        Max = 2,
        Default = 0.5,
        Rounding = 1,
        Callback = function(arg)
            getgenv().TwoTimeStab.Duration = tonumber(arg)
        end,
    })
v15:AddSlider(fn(), {
        Text = "Backdistance",
        Min = 1,
        Max = 10,
        Default = 4,
        Rounding = 1,
        Callback = function(arg)
            getgenv().TwoTimeStab.BehindStuds = tonumber(arg)
        end,
    })
task.wait()
local Blatant = v:AddTab("Blatant", "zap", "blatant cheats")
local v17 = Blatant:AddLeftTabbox()
local Rage = v17:AddTab("Rage")
local Soft = v17:AddTab("Soft")
local Items = Blatant:AddLeftGroupbox("Items", "package")
local Obstacles = Blatant:AddRightGroupbox("Obstacles", "shield")
local genv6 = getgenv()
local vxTrackedItems = getgenv().VX_trackedItems
local vxTrackedItems2 = vxTrackedItems or {}
genv6.VX_trackedItems = vxTrackedItems2
getgenv().VX_pickUpNear = false
getgenv().VX_pickUpAll = false
getgenv().VX_pickUpFilter = "Both"
getgenv().VX_pickUpRange = 10
local function fn21(descendant)
        if descendant:IsA("Tool") and descendant:FindFirstChild("ItemRoot") then
            table.insert(getgenv().VX_trackedItems, descendant.ItemRoot)
        end
    end
local function fn22(descendant)
        if descendant:IsA("Tool") and descendant:FindFirstChild("ItemRoot") then
            for i, vxTrackedItem in ipairs(getgenv().VX_trackedItems) do
                if vxTrackedItem == descendant.ItemRoot then
                    table.remove(getgenv().VX_trackedItems, i)
                    break
                end
            end
        end
    end
local function fn23()
        getgenv().VX_trackedItems = {}
        local map = workspace:FindFirstChild("Map")
        local ingame = map and workspace.Map:FindFirstChild("Ingame")

        if ingame then
            for i, descendant in ipairs(ingame:GetDescendants()) do
                fn21(descendant)
            end

            ingame.DescendantAdded:Connect(fn21)
            ingame.DescendantRemoving:Connect(fn22)
        end
    end
fn23()
local function fn24(arg)
        local vxPickUpFilter = getgenv().VX_pickUpFilter
        if vxPickUpFilter == "Cola" then
            local flag5 = arg == "BloxyCola"
            return flag5
        end

        if vxPickUpFilter ~= "Medkit" then
            return true
        end
        local flag5 = arg == "Medkit"
        return flag5
    end
local function fn25()
        while task.wait() and (getgenv().VX_pickUpNear or getgenv().VX_pickUpAll) do
            pcall(function()
                local localPlayer8 = game.Players.LocalPlayer
                local character2 = localPlayer8.Character
                local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")
                local backpack = localPlayer8:FindFirstChild("Backpack")
                if not character2 or not humanoidRootPart3 or character2.Parent.Name ~= "Survivors" then
                    return
                end

                for i, vxTrackedItem in ipairs(getgenv().VX_trackedItems) do
                    if vxTrackedItem and vxTrackedItem.Parent then
                        local proximityPrompt = vxTrackedItem:FindFirstChild("ProximityPrompt")
                        local name = vxTrackedItem.Parent.Name

                        if proximityPrompt and fn24(name) then
                            if getgenv().VX_pickUpNear and (humanoidRootPart3.Position - vxTrackedItem.Position).Magnitude <= getgenv().VX_pickUpRange then
                                fireproximityprompt(proximityPrompt)
                            end

                            if getgenv().VX_pickUpAll and backpack and not backpack:FindFirstChild(name) then
                                humanoidRootPart3.CFrame = vxTrackedItem.CFrame
                                task.wait(0.1)
                                fireproximityprompt(proximityPrompt)
                            end
                        end
                    end
                end
            end)
        end
    end

P["Blatant@16527,10-16527,17"] = Blatant
P["Rage@16529,10-16529,14"] = Rage
P["Soft@16530,10-16530,14"] = Soft
P["Items@16531,10-16531,15"] = Items
P["Obstacles@16532,10-16532,19"] = Obstacles
P["fn23@16559,19-16559,23"] = fn23
P["fn25@16590,19-16590,23"] = fn25
end