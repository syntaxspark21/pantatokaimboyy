-- SorsHub pack part 7/10
return function(P)
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]

local genv = getgenv()
local aimPunchRotSpeed = getgenv().aimPunchRotSpeed
local aimPunchRotSpeed2 = aimPunchRotSpeed or 1
genv.aimPunchRotSpeed = aimPunchRotSpeed2
local genv2 = getgenv()
local punchPrediction = getgenv().punchPrediction
local punchPrediction2 = punchPrediction or 4
genv2.punchPrediction = punchPrediction2
local genv3 = getgenv()
local aimPunchDuration = getgenv().aimPunchDuration
local aimPunchDuration2 = aimPunchDuration or 0.8
genv3.aimPunchDuration = aimPunchDuration2
getgenv().punchAiming = false
getgenv().punchLastTriggerTime = 0
getgenv().originalWS = nil
getgenv().originalJP = nil
getgenv().originalAutoRotate = nil
getgenv().aimConnection = nil
getgenv().trackedPunchAnims = {
    ["87259391926321"] = true,
    ["140703210927645"] = true,
    ["136007065400978"] = true,
    ["129843313690921"] = true,
    ["78440860685556"] = true,
    ["86709774283672"] = true,
    ["108807732150251"] = true,
    ["138040001965654"] = true,
    ["81905101227053"] = true,
    ["86096387000557"] = true,
    ["105458270463374"] = true,
    ["126830014841198"] = true,
    ["106860049270347"] = true,
    ["130958529065375"] = true,
    ["94958041603347"] = true,
    ["118298475669935"] = true,
    ["109667959938617"] = true,
    ["108196996477620"] = true,
    ["125403313786645"] = true,
    ["74707328554358"] = true,
    ["129921445546291"] = true,
    ["92567970681901"] = true,
}
getgenv().getValidKillerTarget = function()
    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v2 = getgenv().KillersFolder:FindFirstChild(aimTarget)
        if v2 and v2:FindFirstChild("HumanoidRootPart") then
            return v2.HumanoidRootPart
        end
    end

    return nil
end
getgenv()._aimPunchCleanup = function(arg)
    getgenv().punchAiming = false

    if getgenv().aimConnection then
        getgenv().aimConnection:Disconnect()
        getgenv().aimConnection = nil
    end

    if getgenv()._aimCamConn then
        getgenv()._aimCamConn:Disconnect()
        getgenv()._aimCamConn = nil
    end

    if arg then
        if getgenv().originalWS then
            arg.WalkSpeed = getgenv().originalWS
        end

        if getgenv().originalJP then
            arg.JumpPower = getgenv().originalJP
        end

        if getgenv().originalAutoRotate ~= nil then
            arg.AutoRotate = getgenv().originalAutoRotate
        end
    end

    getgenv().originalWS = nil
    getgenv().originalJP = nil
    getgenv().originalAutoRotate = nil
end
getgenv().setupAimPunch = function(arg)
    if not arg then
        return
    end
    local humanoid = arg:WaitForChild("Humanoid", 5)
    if not humanoid then
        return
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        local connection = nil

        connection = humanoid.ChildAdded:Connect(function(child)
            if child:IsA("Animator") then
                connection:Disconnect()
                getgenv().setupAimPunch(arg)
            end
        end)

        return
    end

    if getgenv()._aimPunchAnimConn then
        getgenv()._aimPunchAnimConn:Disconnect()
        getgenv()._aimPunchAnimConn = nil
    end

    getgenv()._aimPunchAnimConn = animator.AnimationPlayed:Connect(function(arg2)
        if not getgenv().aimPunchActive then
            return
        end

        task.defer(function()
            local v2 = getgenv().extractNumericAnimationId(arg2)
            if not v2 or not getgenv().trackedPunchAnims[v2] then
                return
            end

            if not getgenv().getValidKillerTarget() then
                return
            end
            local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then
                return
            end
            getgenv()._aimPunchCleanup(humanoid)
            getgenv().punchAiming = true
            getgenv().punchLastTriggerTime = os.clock()
            getgenv().originalWS = humanoid.WalkSpeed
            getgenv().originalJP = humanoid.JumpPower
            getgenv().originalAutoRotate = humanoid.AutoRotate
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.AutoRotate = false

            getgenv().aimConnection = getgenv().RunService.Heartbeat:Connect(function()
                if not getgenv().aimPunchActive then
                    getgenv()._aimPunchCleanup(humanoid)
                    return
                end

                if not getgenv().punchAiming then
                    getgenv()._aimPunchCleanup(humanoid)
                    return
                end
                local n = os.clock() - getgenv().punchLastTriggerTime
                if getgenv().aimPunchDuration < n then
                    getgenv()._aimPunchCleanup(humanoid)
                    return
                end
                local v3 = getgenv().getValidKillerTarget()

                if v3 and humanoidRootPart and humanoidRootPart.Parent then
                    if getgenv().aimPunchMode ~= "CamLock" then
                        local assemblyLinearVelocity = v3.AssemblyLinearVelocity
                        local vector = assemblyLinearVelocity or Vector3.zero
                        local unit = (v3.Position + vector * (getgenv().punchPrediction / 10) - humanoidRootPart.Position).Unit
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + unit), math.clamp(getgenv().aimPunchRotSpeed, 0.01, 1))
                    end

                    return
                end

                getgenv()._aimPunchCleanup(humanoid)
            end)

            if getgenv()._aimCamConn then
                getgenv()._aimCamConn:Disconnect()
                getgenv()._aimCamConn = nil
            end

            if getgenv().aimPunchMode == "CamLock" then
                getgenv()._aimCamConn = getgenv().RunService.RenderStepped:Connect(function()
                    if getgenv().punchAiming and getgenv().aimPunchActive then
                        local v3 = getgenv().getValidKillerTarget()
                        if not v3 or not humanoidRootPart or not humanoidRootPart.Parent then
                            return
                        end
                        local assemblyLinearVelocity = v3.AssemblyLinearVelocity
                        local vector = assemblyLinearVelocity or Vector3.zero
                        local n = v3.Position + vector * (getgenv().punchPrediction / 10)
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + (n - humanoidRootPart.Position).Unit), math.clamp(getgenv().aimPunchRotSpeed, 0.01, 1))
                        getgenv().Camera.CFrame = CFrame.new(getgenv().Camera.CFrame.Position, n)
                        return
                    end

                    getgenv()._aimCamConn:Disconnect()
                    getgenv()._aimCamConn = nil
                end)
            end
        end)
    end)
end
getgenv().lp.CharacterAdded:Connect(function(character)
    getgenv()._aimPunchCleanup(nil)
    getgenv().setupAimPunch(character)
end)
if getgenv().lp.Character then
    getgenv().setupAimPunch(getgenv().lp.Character)
end
getgenv()._abSpeedCache = {}
getgenv().soundHooks = {}
local genv4 = getgenv()
local soundStartedOutOfRange = getgenv()._soundStartedOutOfRange
local soundStartedOutOfRange2 = soundStartedOutOfRange or {}
genv4._soundStartedOutOfRange = soundStartedOutOfRange2
getgenv().lastAnimBlockFire = {}
getgenv()._animStartedOutOfRange = {}
getgenv().visionCenterPart = nil
getgenv().visionLeftPart = nil
getgenv().visionRightPart = nil
getgenv().visionLeftToKiller = nil
getgenv().visionRightToKiller = nil
getgenv().visionLeftToCenter = nil
getgenv().visionCenterToRight = nil
getgenv().isInDetectionRange = function(arg, arg2)
    local num = tonumber(getgenv().detectionRange)
    local n = num or 20
    local flag = Vector3.new(arg2.X - arg.X, 0, arg2.Z - arg.Z).Magnitude <= n
    return flag
end
getgenv().hasAutoBlockLOS = function(arg, arg2)
    if not getgenv().autoBlockLOS then
        return true
    end

    if not arg or not arg2 then
        return false
    end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {getgenv().lp.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    local hit = workspace:Raycast(arg.Position, arg2 - arg.Position, raycastParams)
    local players = workspace:FindFirstChild("Players")
    local killers = players and workspace.Players:FindFirstChild("Killers")
    local flag = hit and killers

    if flag then
        if hit.Instance:IsDescendantOf(killers) then
            flag = false
        else
            flag = true
        end
    end

    local flag2

    if flag then
        flag2 = false
    else
        flag2 = true
    end

    return flag2
end
getgenv().checkVisionCone = function()
    local character = getgenv().lp.Character
    local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end

    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v2 = getgenv().KillersFolder:FindFirstChild(aimTarget)
        if not v2 then
            continue
        end
        local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart2 then
            continue
        end
        local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude
        if getgenv().visionRange < magnitude then
            continue
        end
        local v3

        if getgenv().facingCheckMode == "I Am Facing Killer" then
            v3 = humanoidRootPart.CFrame.LookVector:Dot((humanoidRootPart2.Position - humanoidRootPart.Position).Unit)
        else
            v3 = humanoidRootPart2.CFrame.LookVector:Dot((humanoidRootPart.Position - humanoidRootPart2.Position).Unit)
        end

        if math.cos(math.rad(getgenv().visionAngle / 2)) <= v3 then
            return true
        end
    end

    return false
end
getgenv().cleanupVisionCone = function()
    for i, v2 in ipairs({
        "visionCenterPart",
        "visionLeftPart",
        "visionRightPart",
        "visionLeftToKiller",
        "visionRightToKiller",
        "visionLeftToCenter",
        "visionCenterToRight",
    }) do
        if getgenv()[v2] then
            getgenv()[v2]:Destroy()
            getgenv()[v2] = nil
        end
    end
end
local genv5 = getgenv()
local isKiller = getgenv().IsKiller
local isKiller2 = isKiller or function()
    local character = getgenv().lp.Character
    local flag = character and character.Parent and character.Parent.Name == "Killers"
    return flag
end
genv5.IsKiller = isKiller2
getgenv().updateVisionCone = function()
    if getgenv().showVisionRange and not getgenv().IsKiller() then
        local character = getgenv().lp.Character
        local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            getgenv().cleanupVisionCone()
            return
        end
        local flag = false

        for i, aimTarget in ipairs(getgenv().aimTargets) do
            local v2 = getgenv().KillersFolder:FindFirstChild(aimTarget)
            local humanoidRootPart2 = v2 and v2:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart2 then
                flag = true
                local v3, lookVector

                if getgenv().facingCheckMode == "I Am Facing Killer" then
                    v3 = humanoidRootPart
                    lookVector = humanoidRootPart.CFrame.LookVector
                else
                    v3 = humanoidRootPart2
                    lookVector = humanoidRootPart2.CFrame.LookVector
                end

                local v4 = math.rad(getgenv().visionAngle / 2)
                local n = CFrame.Angles(0, v4, 0) * lookVector
                local n2 = CFrame.Angles(0, -v4, 0) * lookVector
                local position = v3.Position + lookVector * getgenv().visionRange
                local position2 = v3.Position + n * getgenv().visionRange
                local position3 = v3.Position + n2 * getgenv().visionRange

                local function fn2(arg, color, arg2)
                    if not getgenv()[arg] then
                        local part = Instance.new("Part")
                        local vector = arg2 or Vector3.new(0.15, 0.15, 0.15)
                        part.Size = vector
                        part.Color = color
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.3
                        part.Anchored = true
                        part.CanCollide = false
                        part.CastShadow = false
                        part.Parent = workspace
                        getgenv()[arg] = part
                    end

                    return getgenv()[arg]
                end

                fn2("visionCenterPart", Color3.fromRGB(180, 180, 255)).Position = position
                fn2("visionLeftPart", Color3.fromRGB(180, 180, 255)).Position = position2
                fn2("visionRightPart", Color3.fromRGB(180, 180, 255)).Position = position3
                local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude
                local v5

                if getgenv().facingCheckMode == "I Am Facing Killer" then
                    v5 = humanoidRootPart.CFrame.LookVector:Dot((humanoidRootPart2.Position - humanoidRootPart.Position).Unit)
                else
                    v5 = lookVector:Dot((humanoidRootPart.Position - humanoidRootPart2.Position).Unit)
                end

                local flag2 = magnitude <= getgenv().visionRange and math.cos(v4) <= v5

                if flag2 then
                    local visionLeftToKiller = fn2("visionLeftToKiller", Color3.fromRGB(100, 255, 160), Vector3.new(0.08, 0.08, 1))
                    visionLeftToKiller.Size = Vector3.new(0.08, 0.08, (position2 - v3.Position).Magnitude)
                    visionLeftToKiller.CFrame = CFrame.new((position2 + v3.Position) / 2, v3.Position)
                    local visionRightToKiller = fn2("visionRightToKiller", Color3.fromRGB(100, 255, 160), Vector3.new(0.08, 0.08, 1))
                    visionRightToKiller.Size = Vector3.new(0.08, 0.08, (position3 - v3.Position).Magnitude)
                    visionRightToKiller.CFrame = CFrame.new((position3 + v3.Position) / 2, v3.Position)
                else
                    if getgenv().visionLeftToKiller then
                        getgenv().visionLeftToKiller:Destroy()
                        getgenv().visionLeftToKiller = nil
                    end

                    if getgenv().visionRightToKiller then
                        getgenv().visionRightToKiller:Destroy()
                        getgenv().visionRightToKiller = nil
                    end
                end

                local visionLeftToCenter = fn2("visionLeftToCenter", Color3.fromRGB(160, 120, 255), Vector3.new(0.08, 0.08, 1))
                visionLeftToCenter.Size = Vector3.new(0.08, 0.08, (position2 - position).Magnitude)
                visionLeftToCenter.CFrame = CFrame.new((position2 + position) / 2, position)
                local visionCenterToRight = fn2("visionCenterToRight", Color3.fromRGB(160, 120, 255), Vector3.new(0.08, 0.08, 1))
                visionCenterToRight.Size = Vector3.new(0.08, 0.08, (position - position3).Magnitude)
                visionCenterToRight.CFrame = CFrame.new((position + position3) / 2, position3)
                break
            end

            continue
        end

        if not flag then
            getgenv().cleanupVisionCone()
        end

        return
    end

    getgenv().cleanupVisionCone()
end
getgenv().RunService.Heartbeat:Connect(getgenv().updateVisionCone)
getgenv().killerSoundIds = {
    ["1x1x1x1"] = {
        ["74809026448465"] = true,
        ["85853080745515"] = true,
        ["95079963655241"] = true,
        ["98111231282218"] = true,
        ["115026634746636"] = true,
        ["117173212095661"] = true,
        ["119089145505438"] = true,
        ["119942598489800"] = true,
        ["121954639447247"] = true,
        ["128856426573270"] = true,
        ["135319730390518"] = true,
    },
    Azure = {["133709029886490"] = true},
    JohnDoe = {
        ["86174610237192"] = true,
        ["98675142200448"] = true,
        ["105204810054381"] = true,
        ["123923371062204"] = true,
        ["140242176732868"] = true,
        ["131123355704017"] = true,
    },
    Noli = {
        ["89004992452376"] = true,
        ["96117920303138"] = true,
        ["108610718831698"] = true,
        ["109348678063422"] = true,
        ["112395455254818"] = true,
        ["114742322778642"] = true,
        ["115678417928765"] = true,
        ["128367348686124"] = true,
        ["131406927389838"] = true,
        ["136323728355613"] = true,
    },
    Nosferatu = {["104910828105172"] = true, ["119664480754070"] = true},
    ShedletskyFunny = {["117173212095661"] = true},
    Sixer = {
        ["71805956520207"] = true,
        ["74842815979546"] = true,
        ["79980897195554"] = true,
        ["108651070773439"] = true,
        ["117231507259853"] = true,
        ["119583605486352"] = true,
        ["125213046326879"] = true,
        ["127557531826290"] = true,
    },
    c00lkidd = {
        ["75330693422988"] = true,
        ["80516583309685"] = true,
        ["82221759983649"] = true,
        ["84307400688050"] = true,
        ["98733709078792"] = true,
        ["105516183226360"] = true,
        ["113413858159336"] = true,
        ["124234993291213"] = true,
        ["128195973631079"] = true,
    },
}
getgenv().killerAnimIds = {
    Slasher = {
        ["94958041603347"] = true,
        ["106860049270347"] = true,
        ["108196996477620"] = true,
        ["109667959938617"] = true,
        ["118298475669935"] = true,
        ["125403313786645"] = true,
        ["126830014841198"] = true,
        ["130958529065375"] = true,
    },
}
getgenv().autoBlockTriggerSounds = {}
local v2, v3, v4 = pairs(getgenv().killerSoundIds)
local v5 = v4
local v6 = v2
local v7 = v3
while true do
    local v8, v9 = v6(v7, v5)
    if v8 == nil then
        break
    end

    for k in pairs(v9) do
        getgenv().autoBlockTriggerSounds[k] = true
    end

    v5 = v8
end
getgenv().autoBlockTriggerAnimations = {}
local v8, v9, v10 = pairs(getgenv().killerAnimIds)
local v11 = v10
local v12 = v8
local v13 = v9
while true do
    local v14, v15 = v12(v13, v11)
    if v14 == nil then
        break
    end

    for k in pairs(v15) do
        getgenv().autoBlockTriggerAnimations[k] = true
    end

    v11 = v14
end
getgenv().extractNumericSoundId = function(arg)
    if arg and arg.SoundId then
        return tostring(arg.SoundId):match("%d+")
    end
    return nil
end
getgenv().extractNumericAnimationId = function(arg)
    if arg and arg.Animation then
        return tostring(arg.Animation.AnimationId):match("%d+")
    end
    return nil
end
getgenv().getSoundWorldPosition = function(arg)
    local parent = arg.Parent

    while parent do
        if parent:IsA("Model") then
            local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                return humanoidRootPart.Position
            end
        end

        parent = parent.Parent
    end

    return nil
end
local genv6 = getgenv()
local hitboxDraggingEnabled = getgenv().hitboxDraggingEnabled
local hitboxDraggingEnabled2 = hitboxDraggingEnabled or false
genv6.hitboxDraggingEnabled = hitboxDraggingEnabled2
local genv7 = getgenv()
local activeHDT = getgenv().activeHDT
local activeHDT2 = activeHDT or {}
genv7.activeHDT = activeHDT2
local genv8 = getgenv()
local dspeed = getgenv().Dspeed
local dspeed2 = dspeed or 5.6
genv8.Dspeed = dspeed2
local genv9 = getgenv()
local ddelay = getgenv().Ddelay
local ddelay2 = ddelay or 0.3
genv9.Ddelay = ddelay2
local genv10 = getgenv()
local hdtDetectRadius = getgenv().HDT_DETECT_RADIUS
local hdtDetectRadius2 = hdtDetectRadius or 6
genv10.HDT_DETECT_RADIUS = hdtDetectRadius2
getgenv().setHRPVelocitySafe = function(arg, assemblyLinearVelocity)
    if arg and arg:IsA("BasePart") then
        arg.AssemblyLinearVelocity = assemblyLinearVelocity
    end
end
getgenv().hdtIsBlockTriggered = function(arg)
    if not arg then
        return false
    end
    local humanoid = arg:FindFirstChildOfClass("Humanoid")

    if humanoid then
        local killerAnimIds = getgenv().killerAnimIds
        local v14 = killerAnimIds and getgenv().killerAnimIds[arg.Name]

        for i, v15 in ipairs(humanoid:GetPlayingAnimationTracks()) do
            local animation = v15.Animation
            local match = animation and tostring(v15.Animation.AnimationId):match("%d+")
            if match and (v14 and v14[match] or getgenv().autoBlockTriggerAnimations and getgenv().autoBlockTriggerAnimations[match]) then
                return true
            end
        end
    end

    local killerSoundIds = getgenv().killerSoundIds
    local v14 = killerSoundIds and getgenv().killerSoundIds[arg.Name]

    for i, descendant in ipairs(arg:GetDescendants()) do
        if descendant:IsA("Sound") and descendant.IsPlaying then
            local match = tostring(descendant.SoundId):match("%d+")
            if match and (v14 and v14[match] or getgenv().autoBlockTriggerSounds and getgenv().autoBlockTriggerSounds[match]) then
                return true
            end
        end
    end

    return false
end
getgenv().RunService.Heartbeat:Connect(function()
    if not getgenv().hitboxDraggingEnabled then
        return
    end
    local character = getgenv().lp.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end

    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v14 = getgenv().KillersFolder:FindFirstChild(aimTarget)
        local humanoidRootPart2 = v14 and v14:FindFirstChild("HumanoidRootPart")
        local humanoid = v14 and v14:FindFirstChildOfClass("Humanoid")

        if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
            if (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= getgenv().HDT_DETECT_RADIUS then
                if getgenv().hdtIsBlockTriggered(v14) then
                    if not getgenv().activeHDT[v14] then
                        getgenv().activeHDT[v14] = os.clock() + getgenv().Ddelay
                    end

                    local now = os.clock()

                    if getgenv().activeHDT[v14] <= now then
                        local unit = (humanoidRootPart2.Position - humanoidRootPart.Position).Unit
                        getgenv().setHRPVelocitySafe(humanoidRootPart, unit * getgenv().Dspeed)
                    end
                elseif getgenv().activeHDT[v14] then
                    getgenv().activeHDT[v14] = nil
                    getgenv().setHRPVelocitySafe(humanoidRootPart, Vector3.zero)
                end
            elseif getgenv().activeHDT[v14] then
                getgenv().activeHDT[v14] = nil
                getgenv().setHRPVelocitySafe(humanoidRootPart, Vector3.zero)
            end
        end
    end
end)
getgenv()._proxBox_getBoxDims = function()
    return getgenv().proxBoxWidthMult, getgenv().proxBoxHeightMult, getgenv().proxBoxDepthMult
end
getgenv()._proxBox_measureKillerSize = function(arg)
    if not arg then
        return
    end
    getgenv().proxBoxLockedSizes[arg] = Vector3.new(getgenv().proxBoxWidthMult, getgenv().proxBoxHeightMult, getgenv().proxBoxDepthMult)
end
getgenv()._proxBox_isPlayerInBox = function(arg, arg2, arg3)
    if not arg or not arg3 then
        return false
    end
    local v14, v15, v16 = getgenv()._proxBox_getBoxDims()
    local n = arg.CFrame * CFrame.new(0, 0, -(v16 / 2))

    if getgenv().proxBoxZoneMode == "Full Body In Zone" then
        local character = getgenv().lp.Character

        if character then
            for i, descendant in ipairs(character:GetDescendants()) do
                if not descendant:IsA("BasePart") then
                    continue
                end
                local v17 = n:PointToObjectSpace(descendant.Position)
                if v14 / 2 < math.abs(v17.X) or v15 / 2 < math.abs(v17.Y) or v16 / 2 < math.abs(v17.Z) then
                    return false
                end
            end

            return true
        end
    end

    local v17 = n:PointToObjectSpace(arg3.Position)
    local flag = math.abs(v17.X) <= v14 / 2 and math.abs(v17.Y) <= v15 / 2 and math.abs(v17.Z) <= v16 / 2
    return flag
end
getgenv()._proxBox_updateAdornment = function(arg, adornee)
    local v14 = getgenv().proxBoxAdornments[arg]

    if not getgenv().proxBoxVisible then
        if v14 then
            v14:Destroy()
        end

        getgenv().proxBoxAdornments[arg] = nil
        return
    end

    if not adornee then
        return
    end
    local v15, v16, v17 = getgenv()._proxBox_getBoxDims()

    if v14 and v14.Parent then
        v14:Destroy()
    end

    local boxHandleAdornment = Instance.new("BoxHandleAdornment")
    boxHandleAdornment.Adornee = adornee
    boxHandleAdornment.Size = Vector3.new(v15, v16, v17)
    boxHandleAdornment.CFrame = CFrame.new(0, 0, -(v17 / 2))
    boxHandleAdornment.Color3 = getgenv().proxBoxColor
    boxHandleAdornment.Transparency = getgenv().proxBoxTransparency
    boxHandleAdornment.AlwaysOnTop = true
    boxHandleAdornment.ZIndex = 1
    boxHandleAdornment.Parent = adornee
    getgenv().proxBoxAdornments[arg] = boxHandleAdornment
end
getgenv()._proxBox_cleanup = function()
    for k, proxBoxAdornment in pairs(getgenv().proxBoxAdornments) do
        if proxBoxAdornment then
            proxBoxAdornment:Destroy()
        end

        getgenv().proxBoxAdornments[k] = nil
    end

    for k in pairs(getgenv().proxBoxLockedSizes) do
        getgenv().proxBoxLockedSizes[k] = nil
    end
end
getgenv()._proxBox_measureAll = function()
    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v14 = getgenv().KillersFolder:FindFirstChild(aimTarget)

        if v14 then
            getgenv()._proxBox_measureKillerSize(v14)
        end
    end
end
getgenv().KillersFolder.ChildAdded:Connect(function(child)
    if getgenv().proxBoxEnabled then
        task.wait(0.2)
        getgenv()._proxBox_measureKillerSize(child)
    end
end)
getgenv().RunService.Heartbeat:Connect(function()
    if not getgenv().proxBoxEnabled and not getgenv().proxBoxVisible then
        return
    end

    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v14 = getgenv().KillersFolder:FindFirstChild(aimTarget)
        local humanoidRootPart = v14 and v14:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
            getgenv()._proxBox_updateAdornment(v14, humanoidRootPart)
        end
    end

    for k, proxBoxAdornment in pairs(getgenv().proxBoxAdornments) do
        if not k.Parent then
            if proxBoxAdornment then
                proxBoxAdornment:Destroy()
            end

            getgenv().proxBoxAdornments[k] = nil
            getgenv().proxBoxLockedSizes[k] = nil
        end
    end
end)
getgenv().attemptAutoBlockForSound = function(arg)
    if not getgenv().autoBlockEnabled or not arg:IsA("Sound") or not arg.IsPlaying then
        return
    end
    local v14 = getgenv().extractNumericSoundId(arg)
    if not v14 or not getgenv().autoBlockTriggerSounds[v14] then
        return
    end
    local model = arg:FindFirstAncestorOfClass("Model")
    local v15 = model and getgenv().killerSoundIds[model.Name]
    if not v15 or not v15[v14] then
        return
    end

    if getgenv().autoBlockRangeMode == "Inside" and getgenv()._soundStartedOutOfRange[arg] ~= false then
        return
    end
    local character = getgenv().lp.Character
    local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    local v16 = getgenv().getSoundWorldPosition(arg)
    if not v16 then
        return
    end

    if not getgenv().isInDetectionRange(humanoidRootPart.Position, v16) then
        return
    end

    if not getgenv().hasAutoBlockLOS(humanoidRootPart, v16) then
        return
    end

    if getgenv().elevationCheckEnabled then
        local n = v16.Y - humanoidRootPart.Position.Y
        if getgenv().elevationKillerHigherThreshold <= n then
            return
        end

        if n <= -getgenv().elevationIAmHigherThreshold then
            return
        end
    end

    if getgenv().verifyFacingCheck and not getgenv().checkVisionCone() then
        return
    end

    if getgenv().autoBlockMode == "Normal + Anti Bait" and getgenv().proxBoxEnabled then
        local model2 = arg:FindFirstAncestorOfClass("Model")
        local humanoidRootPart2 = model2 and model2:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart2 or not getgenv()._proxBox_isPlayerInBox(humanoidRootPart2, model2, humanoidRootPart) then
            return
        end
    end

    local blockDelayEnabled = getgenv().blockDelayEnabled
    local flag = blockDelayEnabled and tonumber(getgenv().blockDelayDuration) > 0

    if flag then
        local num = tonumber(getgenv().blockDelayDuration)
        flag = num or 0
    end

    if not flag then
        flag = 0
    end

    if flag > 0 then
        task.delay(flag, function()
            pcall(function()
                getgenv().testRemote:FireServer(getgenv().blockAction, getgenv().blockData)
            end)
        end)
    else
        pcall(function()
            getgenv().testRemote:FireServer(getgenv().blockAction, getgenv().blockData)
        end)
    end
end
getgenv().hookSound = function(arg)
    if getgenv().soundHooks[arg] then
        return
    end

    local connection = arg:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if arg.IsPlaying then
            local character = getgenv().lp.Character
            local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
            local v14 = getgenv().getSoundWorldPosition(arg)

            if humanoidRootPart and v14 then
                local soundStartedOutOfRange3 = getgenv()._soundStartedOutOfRange
                local flag

                if getgenv().isInDetectionRange(humanoidRootPart.Position, v14) then
                    flag = false
                else
                    flag = true
                end

                soundStartedOutOfRange3[arg] = flag
            end

            getgenv().attemptAutoBlockForSound(arg)

            if getgenv().autoBlockRangeMode == "Inside/Outside" and getgenv()._soundStartedOutOfRange[arg] == true then
                task.spawn(function()
                    while arg and arg.IsPlaying do
                        task.wait(0.05)
                        if not arg.IsPlaying then
                            break
                        end
                        getgenv().attemptAutoBlockForSound(arg)
                    end
                end)
            end
        else
            getgenv()._soundStartedOutOfRange[arg] = nil
        end
    end)

    getgenv().soundHooks[arg] = connection

    if arg.IsPlaying then
        getgenv().attemptAutoBlockForSound(arg)
    end
end
local genv11 = getgenv()
genv11.hookDescendantSounds = function(arg)
    for i, descendant in ipairs(arg:GetDescendants()) do
        if descendant:IsA("Sound") then
            getgenv().hookSound(descendant)
        end
    end

    arg.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") then
            getgenv().hookSound(descendant)
        end
    end)
end
local function fn2(arg)
    local humanoid = arg:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        arg.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                genv11(arg)
            end
        end)

        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        humanoid.ChildAdded:Connect(function(child)
            if child:IsA("Animator") then
                genv11(arg)
            end
        end)

        return
    end

    animator.AnimationPlayed:Connect(function(arg2)
        local v14 = getgenv().extractNumericAnimationId(arg2)
        local v15 = getgenv().killerAnimIds[arg.Name]
        if not v14 or not v15 or not v15[v14] then
            return
        end
        local character = getgenv().lp.Character
        local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
        local humanoidRootPart2 = arg:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart or not humanoidRootPart2 then
            return
        end

        if not getgenv()._animStartedOutOfRange[arg] then
            getgenv()._animStartedOutOfRange[arg] = {}
        end

        local v16 = getgenv()._animStartedOutOfRange[arg]
        local flag

        if getgenv().isInDetectionRange(humanoidRootPart.Position, humanoidRootPart2.Position) then
            flag = false
        else
            flag = true
        end

        v16[v14] = flag

        arg2.Stopped:Connect(function()
            if getgenv()._animStartedOutOfRange[arg] then
                getgenv()._animStartedOutOfRange[arg][v14] = nil
            end
        end)
    end)
end
for i, child in ipairs(getgenv().KillersFolder:GetChildren()) do
    getgenv().hookDescendantSounds(child)
    fn2(child)
end
getgenv().KillersFolder.ChildAdded:Connect(function(child)
    getgenv().hookDescendantSounds(child)
    fn2(child)
end)
getgenv().RunService.Heartbeat:Connect(function()
    local character, humanoidRootPart, v14, v15, v16, v17, v18, v19, v20, v21, v22, humanoidRootPart2, n, humanoid, animator, now, v23, tbl, vxAzureAnimIds, tbl2
    local v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, blockDelayEnabled, flag
    local num, n2
    n2 = 1

    while true do
        if n2 == 1 then
            if getgenv().autoBlockEnabled then
                n2 = 2
            else
                n2 = 46
            end
        elseif n2 == 2 then
            character = getgenv().lp.Character
            humanoidRootPart = character

            if character then
                n2 = 3
            else
                n2 = 4
            end
        elseif n2 == 3 then
            humanoidRootPart = getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
            n2 = 4
        elseif n2 == 4 then
            if humanoidRootPart then
                n2 = 5
            else
                n2 = 45
            end
        elseif n2 == 5 then
            v14, v15, v16 = ipairs(getgenv().aimTargets)
            v17 = v16
            v18 = v14
            v19 = v15
            n2 = 6
        elseif n2 == 6 then
            v20, v21 = v18(v19, v17)

            if v20 == nil then
                n2 = 44
            else
                n2 = 7
            end
        elseif n2 == 7 then
            v17 = v20
            v22 = getgenv().KillersFolder:FindFirstChild(v21)
            humanoidRootPart2 = v22

            if v22 then
                n2 = 8
            else
                n2 = 9
            end
        elseif n2 == 8 then
            humanoidRootPart2 = v22:FindFirstChild("HumanoidRootPart")
            n2 = 9
        elseif n2 == 9 then
            if humanoidRootPart2 and getgenv().isInDetectionRange(humanoidRootPart.Position, humanoidRootPart2.Position) and getgenv().hasAutoBlockLOS(humanoidRootPart, humanoidRootPart2.Position) then
                n2 = 10
            else
                n2 = 6
            end
        elseif n2 == 10 then
            if getgenv().elevationCheckEnabled then
                n2 = 11
            else
                n2 = 12
            end
        elseif n2 == 11 then
            n = humanoidRootPart2.Position.Y - humanoidRootPart.Position.Y

            if getgenv().elevationKillerHigherThreshold > n and n > -getgenv().elevationIAmHigherThreshold then
                n2 = 12
            else
                n2 = 6
            end
        elseif n2 == 12 then
            if (not getgenv().verifyFacingCheck or getgenv().checkVisionCone()) and (getgenv().autoBlockMode ~= "Normal + Anti Bait" or not getgenv().proxBoxEnabled or getgenv()._proxBox_isPlayerInBox(humanoidRootPart2, v22, humanoidRootPart)) then
                n2 = 13
            else
                n2 = 6
            end
        elseif n2 == 13 then
            humanoid = v22:FindFirstChildOfClass("Humanoid")
            animator = humanoid

            if humanoid then
                n2 = 14
            else
                n2 = 15
            end
        elseif n2 == 14 then
            animator = humanoid:FindFirstChildOfClass("Animator")
            n2 = 15
        elseif n2 == 15 then
            if animator then
                n2 = 16
            else
                n2 = 6
            end
        elseif n2 == 16 then
            now = os.clock()

            if getgenv().lastAnimBlockFire[v22] and now - getgenv().lastAnimBlockFire[v22] < 0.5 then
                n2 = 6
            else
                n2 = 17
            end
        elseif n2 == 17 then
            if v21 == "Azure" then
                n2 = 19
            else
                n2 = 18
            end
        elseif n2 == 18 then
            v23 = getgenv().killerAnimIds[v21]
            n2 = 25
        elseif n2 == 19 then
            tbl = {}
            v23 = tbl
            vxAzureAnimIds = getgenv().VX_AzureAnimIds
            tbl2 = vxAzureAnimIds

            if vxAzureAnimIds then
                n2 = 21
            else
                n2 = 20
            end
        elseif n2 == 20 then
            tbl2 = {}
            n2 = 21
        elseif n2 == 21 then
            v24, v25, v26 = ipairs(tbl2)
            v27 = v18
            v28 = v19
            v29 = v26
            n2 = 22
        elseif n2 == 22 then
            v30, v31 = v24(v25, v29)

            if v30 == nil then
                n2 = 24
            else
                n2 = 23
            end
        elseif n2 == 23 then
            v29 = v30
            tbl[v31] = true
            n2 = 22
        elseif n2 == 24 then
            v17 = v20
            v18 = v27
            v19 = v28
            n2 = 25
        elseif n2 == 25 then
            v32, v33, v34 = ipairs(animator:GetPlayingAnimationTracks())
            v35 = v17
            v36 = v18
            v37 = v19
            v38 = v34
            n2 = 26
        elseif n2 == 26 then
            v39, v40 = v32(v33, v38)

            if v39 == nil then
                n2 = 43
            else
                n2 = 27
            end
        elseif n2 == 27 then
            v38 = v39
            v41 = getgenv().extractNumericAnimationId(v40)

            if v41 and v23 and v23[v41] then
                n2 = 28
            else
                n2 = 26
            end
        elseif n2 == 28 then
            if getgenv()._animStartedOutOfRange[v22] then
                n2 = 30
            else
                n2 = 29
            end
        elseif n2 == 29 then
            getgenv()._animStartedOutOfRange[v22] = {}
            n2 = 30
        elseif n2 == 30 then
            if getgenv().autoBlockRangeMode == "Inside" and getgenv()._animStartedOutOfRange[v22][v41] ~= false then
                n2 = 43
            else
                n2 = 31
            end
        elseif n2 == 31 then
            getgenv().lastAnimBlockFire[v22] = now
            blockDelayEnabled = getgenv().blockDelayEnabled
            flag = blockDelayEnabled

            if blockDelayEnabled then
                n2 = 32
            else
                n2 = 35
            end
        elseif n2 == 32 then
            if tonumber(getgenv().blockDelayDuration) > 0 then
                n2 = 34
            else
                n2 = 33
            end
        elseif n2 == 33 then
            flag = false
            n2 = 35
        elseif n2 == 34 then
            flag = true
            n2 = 35
        elseif n2 == 35 then
            if flag then
                n2 = 36
            else
                n2 = 38
            end
        elseif n2 == 36 then
            num = tonumber(getgenv().blockDelayDuration)
            flag = num

            if num then
                n2 = 38
            else
                n2 = 37
            end
        elseif n2 == 37 then
            flag = 0
            n2 = 38
        elseif n2 == 38 then
            if flag then
                n2 = 40
            else
                n2 = 39
            end
        elseif n2 == 39 then
            flag = 0
            n2 = 40
        elseif n2 == 40 then
            if flag > 0 then
                n2 = 42
            else
                n2 = 41
            end
        elseif n2 == 41 then
            pcall(function()
                getgenv().testRemote:FireServer(getgenv().blockAction, getgenv().blockData)
            end)

            n2 = 43
        elseif n2 == 42 then
            task.delay(flag, function()
                pcall(function()
                    getgenv().testRemote:FireServer(getgenv().blockAction, getgenv().blockData)
                end)
            end)

            n2 = 43
        elseif n2 == 43 then
            v17 = v35
            v18 = v36
            v19 = v37
            n2 = 6
        elseif n2 == 44 then
            return
        elseif n2 == 45 then
            return
        elseif n2 == 46 then
            return
        end
    end
end)
getgenv().RunService.RenderStepped:Connect(function()
    if not getgenv().antiBaitIdleEnabled and not getgenv().antiBaitWalkEnabled then
        getgenv().detectionRange = getgenv().baseDetectionRange
        return
    end
    local v14 = nil

    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v15 = getgenv().KillersFolder:FindFirstChild(aimTarget)

        if v15 then
            local humanoidRootPart = v15:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then
                continue
            end
            v14 = humanoidRootPart
            break
        end

        continue
    end

    if not v14 then
        getgenv().detectionRange = getgenv().baseDetectionRange
        return
    end
    local parent = v14.Parent
    local now = tick()
    local vector = Vector3.new(v14.Position.X, 0, v14.Position.Z)
    local v15 = getgenv()._abSpeedCache[parent]
    local v16 = v15

    if not v15 then
        getgenv()._abSpeedCache[parent] = {
            lastPos = vector,
            lastTime = now,
            history = {},
            smoothed = 0,
        }

        v16 = getgenv()._abSpeedCache[parent]
    end

    local n = now - v16.lastTime

    if n > 0.01 then
        table.insert(v16.history, (vector - v16.lastPos).Magnitude / n)

        while #v16.history > 5 do
            table.remove(v16.history, 1)
        end

        local n2 = 0

        for i, v17 in ipairs(v16.history) do
            n2 = n2 + v17
        end

        v16.smoothed = n2 / #v16.history
        v16.lastPos = vector
        v16.lastTime = now
    end

    local smoothed = v16.smoothed

    if smoothed >= 20 then
        getgenv().detectionRange = getgenv().baseDetectionRange
    elseif getgenv().antiBaitWalkEnabled and smoothed >= 1 and smoothed < 20 then
        getgenv().detectionRange = getgenv().antiBaitWalkRange
    elseif getgenv().antiBaitIdleEnabled and smoothed < 1 then
        getgenv().detectionRange = getgenv().antiBaitIdleRange
    else
        getgenv().detectionRange = getgenv().baseDetectionRange
    end
end)
getgenv().RunService.Heartbeat:Connect(function()
    if not getgenv().antiBaitWalkEnabled then
        local antiBaitIdleEnabled = getgenv().antiBaitIdleEnabled
    end

    if getgenv().showAutoBlockKillerRadius then
        for i, aimTarget in ipairs(getgenv().aimTargets) do
            local v14 = getgenv().KillersFolder:FindFirstChild(aimTarget)
            local humanoidRootPart = v14 and v14:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                local v15 = getgenv().killerRadiusAdornments[v14]

                if v15 and v15.Parent then
                    local num = tonumber(getgenv().detectionRange)
                    local radius = num or 20
                    v15.Radius = radius
                else
                    local cylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
                    cylinderHandleAdornment.Adornee = humanoidRootPart
                    cylinderHandleAdornment.Color3 = Color3.new(1, 0, 0)
                    cylinderHandleAdornment.Transparency = 0.7
                    cylinderHandleAdornment.AlwaysOnTop = true
                    cylinderHandleAdornment.ZIndex = 1
                    local num = tonumber(getgenv().detectionRange)
                    local radius = num or 20
                    cylinderHandleAdornment.Radius = radius
                    cylinderHandleAdornment.Height = 0.1
                    cylinderHandleAdornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
                    cylinderHandleAdornment.Parent = humanoidRootPart
                    getgenv().killerRadiusAdornments[v14] = cylinderHandleAdornment
                end
            end
        end
    else
        for k, killerRadiusAdornment in pairs(getgenv().killerRadiusAdornments) do
            if killerRadiusAdornment then
                killerRadiusAdornment:Destroy()
            end

            getgenv().killerRadiusAdornments[k] = nil
        end
    end
end)
local genv12 = getgenv()
local autoPunch = getgenv().AutoPunch
local v14 = autoPunch
if not autoPunch then
    local tbl = {}
    v14 = tbl
    tbl.Enabled = false
    tbl.Cooldown = 0.15
    tbl.TrueDash = false
end
genv12.AutoPunch = v14
local genv13 = getgenv()
local autoPunchLastFire = getgenv()._autoPunchLastFire
local autoPunchLastFire2 = autoPunchLastFire or 0
genv13._autoPunchLastFire = autoPunchLastFire2
local genv14 = getgenv()
local autoPunchDetectedAt = getgenv()._autoPunchDetectedAt
local autoPunchDetectedAt2 = autoPunchDetectedAt or 0
genv14._autoPunchDetectedAt = autoPunchDetectedAt2
if getgenv()._autoPunchConn then
    getgenv()._autoPunchConn:Disconnect()
    getgenv()._autoPunchConn = nil
end
local function fn3()
    local character = getgenv().lp.Character
    local flag = character and character.Parent and character.Parent.Name == "Survivors"
    return flag
end
local function fn4()
    if not fn3() then
        return false
    end
    local mainUI = getgenv().lp.PlayerGui:FindFirstChild("MainUI")
    local abilityContainer = mainUI and mainUI:FindFirstChild("AbilityContainer")
    local punch = abilityContainer and abilityContainer:FindFirstChild("Punch")
    if not punch then
        return false
    end
    local imageColor3 = punch.ImageColor3
    if math.floor(imageColor3.R * 255 + 0.5) ~= 255 or math.floor(imageColor3.G * 255 + 0.5) ~= 255 or math.floor(imageColor3.B * 255 + 0.5) ~= 255 then
        return false
    end
    local charges = punch:FindFirstChild("Charges")
    local flag = charges and charges.Text ~= "0"
    return flag
end
local function fn5()
    local character = getgenv().lp.Character
    local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return nil
    end
    local v15 = nil
    local huge = math.huge

    for i, aimTarget in ipairs(getgenv().aimTargets) do
        local v16 = getgenv().KillersFolder:FindFirstChild(aimTarget)

        if v16 then
            local humanoidRootPart2 = v16:FindFirstChild("HumanoidRootPart")
            local humanoid = v16:FindFirstChildOfClass("Humanoid")

            if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
                local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                if magnitude < huge then
                    huge = magnitude
                    v15 = v16
                end
            end
        end
    end

    return v15
end
getgenv()._autoPunchConn = getgenv().RunService.RenderStepped:Connect(function()
    if not getgenv().autoPunchEnabled then
        return
    end

    if os.clock() - getgenv()._autoPunchLastFire < 0.2 then
        return
    end

    if not fn4() then
        getgenv()._autoPunchDetectedAt = 0
        return
    end

    if getgenv()._autoPunchDetectedAt == 0 then
        getgenv()._autoPunchDetectedAt = os.clock()
    end

    if os.clock() - getgenv()._autoPunchDetectedAt < getgenv().AutoPunch.Cooldown then
        return
    end

    if not fn5() then
        return
    end
    getgenv()._autoPunchLastFire = os.clock()
    getgenv()._autoPunchDetectedAt = 0

    pcall(function()
        getgenv().testRemote:FireServer(getgenv().punchAction, getgenv().punchData)
    end)

    if getgenv().AutoPunch.TrueDash then
        local character = getgenv().lp.Character
        local humanoidRootPart = character and getgenv().lp.Character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
            bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * 200
            bodyVelocity.Parent = humanoidRootPart

            task.delay(0.25, function()
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end)
        end
    end
end)
task.wait()
local Aim = v:AddTab("Aim", "crosshair", "aim assist features")
local v15 = Aim:AddLeftTabbox()
local Aimbot = v15:AddTab("Aimbot")
local Settings = v15:AddTab("Settings")
local v16 = Aim:AddRightTabbox()
local v17 = v16:AddTab("Silent Aim")
local Settings2 = v16:AddTab("Settings")
Settings2:AddSlider(fn(), {
    Text = "Prediction Strength",
    Min = 0,
    Max = 20,
    Default = 0,
    Rounding = 1,
    Callback = function(arg)
        local genv15 = getgenv()
        local num = tonumber(arg)
        local saPrediction = num or 0
        genv15.SA_Prediction = saPrediction
    end,
})
Settings2:AddDropdown(fn(), {
    Text = "Target Aiming",
    Values = {"Nearest", "Lowest HP", "Closest To Cursor"},
    Default = 1,
    Callback = function(silentAimMode)
        getgenv().SilentAimMode = silentAimMode

        if getgenv().SilentAimEnabled then
            getgenv().UpdateSilentAim(getgenv().SilentAimMode)
        end
    end,
})
getgenv().VX_AimbotEnabled = false
getgenv().VX_AimbotTarget = "1x1x1x1"
getgenv().VX_AimbotDelay = 0
getgenv().VX_AimbotLastFired = 0
getgenv().VX_AimbotSmoothing = 0.2
getgenv().VX_AimbotPriority = "Nearest"
getgenv().VX_AimbotPrediction = 0
getgenv().VX_AimbotMaxDistance = math.huge
getgenv().VX_AimbotFaceSameDirection = false
getgenv().VX_BezierEnabled = false
getgenv().VX_BezierActive = false
getgenv().VX_BezierLineParts = {}
getgenv().VX_BezierSphere = nil
local genv15 = getgenv()
local vxBezierColor = getgenv().VX_BezierColor
local color = vxBezierColor or Color3.fromRGB(30, 150, 255)
genv15.VX_BezierColor = color
local function fn6()
    return getgenv().VX_BezierColor
end
local function fn7()
    local vxBezierColor2 = getgenv().VX_BezierColor
    return Color3.fromRGB(math.min(255, math.floor(vxBezierColor2.R * 255 * 1.35)), math.min(255, math.floor(vxBezierColor2.G * 255 * 1.35)), math.min(255, math.floor(vxBezierColor2.B * 255 * 1.35)))
end
getgenv().VX_BezierObjs = nil
local function fn8(arg, arg2, arg3)
    local magnitude = (arg2 - arg).Magnitude
    if magnitude < 1 then
        return 0
    end

    if not arg3 then
        return 0
    end
    return magnitude * 0.35 * math.max(0, 1 - math.max(math.clamp(arg3:Dot((arg2 - arg).Unit), -1, 1), 0))
end
local function vxClearBezierInstant()
    local vxBezierObjs = getgenv().VX_BezierObjs

    if vxBezierObjs then
        if vxBezierObjs.tubes then
            for i, tube in ipairs(vxBezierObjs.tubes) do
                pcall(function()
                    if tube and tube.Parent then
                        tube:Destroy()
                    end
                end)
            end
        end

        pcall(function()
            if vxBezierObjs.sphere and vxBezierObjs.sphere.Parent then
                vxBezierObjs.sphere:Destroy()
            end
        end)

        getgenv().VX_BezierObjs = nil
    end

    getgenv().VX_BezierActive = false
end
getgenv().VX_SpawnBezierVisualizer = function(arg, arg2)
    if not getgenv().VX_BezierEnabled then
        return
    end

    if getgenv().VX_BezierActive then
        vxClearBezierInstant()
    end

    getgenv().VX_BezierActive = true

    local function fn9(arg3, arg4, arg5)
        local v18 = fn8(arg3, arg4, arg5)
        local n = (arg3 + arg4) * 0.5 + Vector3.new(0, v18, 0)
        local tbl = {}

        for i = 0, 16 do
            local n2 = i / 16
            local n3 = 1 - n2
            table.insert(tbl, n3 * n3 * arg3 + 2 * n3 * n2 * n + n2 * n2 * arg4)
        end

        return tbl
    end

    local v18 = (function(arg3)
        local tbl = {}

        for i = 1, #arg3 - 1 do
            local v18 = arg3[i]
            local v19 = arg3[i + 1]
            local magnitude = (v19 - v18).Magnitude

            if magnitude > 0.001 then
                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.CastShadow = false
                part.Shape = Enum.PartType.Cylinder
                part.CFrame = CFrame.new((v18 + v19) * 0.5, v19) * CFrame.Angles(0, -1.5707963267948966, 0)
                part.Size = Vector3.new(magnitude + 0.01, 0.1 * 2, 0.1 * 2)
                part.Color = fn6():Lerp(fn7(), math.sin((i - 1) / (#arg3 - 2) * 3.141592653589793))
                part.Material = Enum.Material.ForceField
                part.Transparency = 0.15
                part.Parent = workspace
                table.insert(tbl, part)
            end
        end

        return tbl
    end)(fn9(arg.Position, arg2.Position, arg.CFrame.LookVector))

    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.CastShadow = false
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(1.5, 1.5, 1.5)
    part.Material = Enum.Material.ForceField
    part.Color = fn6()
    part.Transparency = 0.1
    part.CFrame = CFrame.new(arg2.Position)
    part.Parent = workspace
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 4
    pointLight.Color = fn7()
    pointLight.Range = 14
    pointLight.Parent = part
    getgenv().VX_BezierObjs = {tubes = v18, sphere = part, tubeR = 0.1}
    local connection = nil

    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not getgenv().VX_BezierActive then
            connection:Disconnect()
            return
        end

        if arg and arg.Parent and arg2 and arg2.Parent then
            local position = arg.Position
            local position2 = arg2.Position

            if part.Parent then
                part.CFrame = CFrame.new(position2)
            end

            local v19 = fn9(position, position2, arg.CFrame.LookVector)
            local vxBezierObjs = getgenv().VX_BezierObjs
            if not vxBezierObjs then
                return
            end

            for i, tube in ipairs(vxBezierObjs.tubes) do
                local v20 = v19[i]
                local v21 = v19[i + 1]

                if v20 and v21 and tube.Parent then
                    local magnitude = (v21 - v20).Magnitude

                    if magnitude > 0.001 then
                        tube.CFrame = CFrame.new((v20 + v21) * 0.5, v21) * CFrame.Angles(0, -1.5707963267948966, 0)
                        tube.Size = Vector3.new(magnitude + 0.01, 0.1 * 2, 0.1 * 2)
                    end
                end
            end

            return
        end

        connection:Disconnect()
        vxClearBezierInstant()
    end)
end
getgenv().VX_ClearBezierInstant = vxClearBezierInstant
getgenv().VX_ClearBezierShatter = function()
    local vxBezierObjs = getgenv().VX_BezierObjs
    if not vxBezierObjs then
        return
    end
    getgenv().VX_BezierActive = false
    getgenv().VX_BezierObjs = nil
    local sphere = vxBezierObjs.sphere
    local position = sphere and vxBezierObjs.sphere.Parent and vxBezierObjs.sphere.Position or nil

    task.spawn(function()
        local tubeR = vxBezierObjs.tubeR
        local n = tubeR or 0.1

        if vxBezierObjs.tubes then
            for i, tube in ipairs(vxBezierObjs.tubes) do
                pcall(function()
                    if tube and tube.Parent then
                        tube.Color = Color3.new(1, 1, 1)
                        tube.Transparency = 0
                    end
                end)
            end
        end

        task.wait(0.06)
        local n2 = 0

        while true do
            local n3 = n2 + 1
            if n3 > 20 then
                break
            end
            n2 = n3
            task.wait(0.0325)
            local transparency = n3 / 20

            if vxBezierObjs.tubes then
                for i, tube in ipairs(vxBezierObjs.tubes) do
                    pcall(function()
                        if tube and tube.Parent then
                            tube.Transparency = transparency
                            local n4 = math.max(0.001, n * 2 * (1 - transparency))
                            tube.Size = Vector3.new(tube.Size.X, n4, n4)
                        end
                    end)
                end

                n2 = n3
            end
        end

        if vxBezierObjs.tubes then
            for i, tube in ipairs(vxBezierObjs.tubes) do
                pcall(function()
                    if tube and tube.Parent then
                        tube:Destroy()
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        if vxBezierObjs.sphere and vxBezierObjs.sphere.Parent then
            for i = 1, 5 do
                task.wait(0.016)

                pcall(function()
                    if vxBezierObjs.sphere and vxBezierObjs.sphere.Parent then
                        local n = 1 + i / 5 * 0.8
                        vxBezierObjs.sphere.Size = Vector3.new(1.5 * n, 1.5 * n, 1.5 * n)
                        vxBezierObjs.sphere.Transparency = 0.1 + i / 5 * 0.65
                    end
                end)
            end

            pcall(function()
                if vxBezierObjs.sphere and vxBezierObjs.sphere.Parent then
                    vxBezierObjs.sphere:Destroy()
                end
            end)
        end

        if not position then
            return
        end

        for i = 1, 20 do
            task.spawn(function()
                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.CastShadow = false
                local n = math.random(5, 16) * 0.05
                local n2 = math.random(3, 10) * 0.05
                part.Size = Vector3.new(n, 0.04, n2)
                part.CFrame = CFrame.new(position) * CFrame.Angles(math.random() * 3.141592653589793 * 2, math.random() * 3.141592653589793 * 2, math.random() * 3.141592653589793 * 2)
                part.Material = Enum.Material.ForceField
                part.Color = fn7()
                part.Transparency = 0.05
                part.Parent = workspace
                local n3 = Vector3.new(math.random(-100, 100) * 0.01, math.random(15, 100) * 0.01, math.random(-100, 100) * 0.01).Unit * math.random(5, 18)
                local n4 = (math.random() - 0.5) * 8
                local n5 = (math.random() - 0.5) * 4
                local n6 = 0
                local n7 = 0.3 + math.random() * 0.3

                while n6 < n7 do
                    local v18 = task.wait()
                    local n8 = n6 + v18
                    n6 = n8
                    if not part.Parent then
                        break
                    end
                    part.CFrame = CFrame.new(part.CFrame.Position + n3 * v18) * CFrame.Angles(0, n4 * v18, n5 * v18)
                    n3 = n3 - Vector3.new(0, 25 * v18, 0)
                    part.Transparency = n8 / n7
                end

                pcall(function()
                    if part.Parent then
                        part:Destroy()
                    end
                end)
            end)
        end
    end)
end
getgenv().VX_Azure_Slash = true
getgenv().VX_Azure_Pummeling = true
getgenv().VX_Azure_GolemShockwave = true
getgenv().VX_Azure_GolemFissure = true
getgenv().VX_AzureAnimIds = {}
getgenv().VX_AzureSoundIds = {}
getgenv().VX_1x1_Entanglement = true
getgenv().VX_1x1_MassInfection = true
getgenv().VX_1x1_Slash = true
getgenv().VX_1x1AnimIds = {}
getgenv().VX_1x1SoundIds = {}
getgenv().VX_Slasher_Behead = true
getgenv().VX_Slasher_GashingWound = true
getgenv().VX_Slasher_Slash = true
getgenv().VX_SlasherAnimIds = {}
getgenv().VX_SlasherSoundIds = {}
local function fn9()
    getgenv().VX_SlasherAnimIds = {}
    getgenv().VX_SlasherSoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local tbl = {
        Behead = getgenv().VX_Slasher_Behead,
        GashingWound = getgenv().VX_Slasher_GashingWound,
        Slash = getgenv().VX_Slasher_Slash,
    }

    local tbl2 = {
        Behead = {"BeheadWindup", "Behead", "BeheadHit"},
        GashingWound = {
            "GashingWoundWindup",
            "GashingWoundStart",
            "GashingWoundHit",
        },
        Slash = {"SlashWindup", "Slash", "SlashHit"},
    }

    local tbl3 = {GashingWound = "GashingWoundStart"}

    local function fn10(arg)
        if type(arg.Animations) == "table" then
            for k, v18 in pairs(tbl) do
                if v18 then
                    local v19 = tbl3[k]
                    local v20 = v19 or k
                    local v21 = arg.Animations[v20]

                    if type(v21) == "string" then
                        local vxSlasherAnimIds = getgenv().VX_SlasherAnimIds
                        local match = v21:match("%d+")
                        local v22 = match or v21
                        table.insert(vxSlasherAnimIds, v22)
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
                            local vxSlasherSoundIds = getgenv().VX_SlasherSoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vxSlasherSoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vxSlasherSoundIds = getgenv().VX_SlasherSoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vxSlasherSoundIds, v40)
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
        local Config = require(ReplicatedStorage.Assets.Killers.Slasher.Config)

        if Config then
            fn10(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local slasher = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("Slasher")
        if not slasher then
            return
        end

        for i, child in ipairs(slasher:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn10(module)
                    end
                end
            end)
        end
    end)
end
local function fn10()
    local v18 = nil

    v18 = v:AddDialog("VX_SlasherAimbotDialog_" .. tostring(tick()), {
        Title = "Slasher Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn9()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_SlasherDlg_Behead", {
        Text = "Behead",
        Default = getgenv().VX_Slasher_Behead,
        Callback = function(vxSlasherBehead)
            getgenv().VX_Slasher_Behead = vxSlasherBehead
        end,
    })

    v18:AddToggle("VX_SlasherDlg_GashingWound", {
        Text = "GashingWound",
        Default = getgenv().VX_Slasher_GashingWound,
        Callback = function(vxSlasherGashingWound)
            getgenv().VX_Slasher_GashingWound = vxSlasherGashingWound
        end,
    })

    v18:AddToggle("VX_SlasherDlg_Slash", {
        Text = "Slash",
        Default = getgenv().VX_Slasher_Slash,
        Callback = function(vxSlasherSlash)
            getgenv().VX_Slasher_Slash = vxSlasherSlash
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

    addSlider(v19, "VX_Slasher_AimbotDuration", tbl)
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

    addSlider2(v20, "VX_Slasher_AimbotDelay", tbl2)
end
getgenv().VX_JohnDoe_CorruptEnergy = true
getgenv().VX_JohnDoe_Slash = true
getgenv().VX_JohnDoeAnimIds = {}
getgenv().VX_JohnDoeSoundIds = {}
local function fn11()
    getgenv().VX_JohnDoeAnimIds = {}
    getgenv().VX_JohnDoeSoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local tbl = {
        CorruptEnergy = getgenv().VX_JohnDoe_CorruptEnergy,
        Slash = getgenv().VX_JohnDoe_Slash,
    }

    local tbl2 = {
        CorruptEnergy = {"CorruptEnergyWindup", "CorruptEnergy", "CorruptEnergyHit"},
        Slash = {"SlashWindup", "Slash", "SlashHit"},
    }

    local function fn12(arg)
        if type(arg.Animations) == "table" then
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
                    local v26 = arg.Animations[v24]

                    if type(v26) == "string" then
                        local vxJohnDoeAnimIds = getgenv().VX_JohnDoeAnimIds
                        local match = v26:match("%d+")
                        local v27 = match or v26
                        table.insert(vxJohnDoeAnimIds, v27)
                    elseif type(v26) == "table" then
                        for i, v27 in ipairs(v26) do
                            if type(v27) == "string" then
                                local vxJohnDoeAnimIds = getgenv().VX_JohnDoeAnimIds
                                local match = v27:match("%d+")
                                local v28 = match or v27
                                table.insert(vxJohnDoeAnimIds, v28)
                            end
                        end

                        v21 = v24
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
                            local vxJohnDoeSoundIds = getgenv().VX_JohnDoeSoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vxJohnDoeSoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vxJohnDoeSoundIds = getgenv().VX_JohnDoeSoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vxJohnDoeSoundIds, v40)
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
        local Config = require(ReplicatedStorage.Assets.Killers.JohnDoe.Config)

        if Config then
            fn12(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local johnDoe = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("JohnDoe")
        if not johnDoe then
            return
        end

        for i, child in ipairs(johnDoe:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn12(module)
                    end
                end
            end)
        end
    end)
end
local function fn12()
    local v18 = nil

    v18 = v:AddDialog("VX_JohnDoeAimbotDialog_" .. tostring(tick()), {
        Title = "John Doe Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn11()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_JohnDoeDlg_CorruptEnergy", {
        Text = "CorruptEnergy",
        Default = getgenv().VX_JohnDoe_CorruptEnergy,
        Callback = function(vxJohnDoeCorruptEnergy)
            getgenv().VX_JohnDoe_CorruptEnergy = vxJohnDoeCorruptEnergy
        end,
    })

    v18:AddToggle("VX_JohnDoeDlg_Slash", {
        Text = "Slash",
        Default = getgenv().VX_JohnDoe_Slash,
        Callback = function(vxJohnDoeSlash)
            getgenv().VX_JohnDoe_Slash = vxJohnDoeSlash
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

    addSlider(v19, "VX_JohnDoe_AimbotDuration", tbl)
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

    addSlider2(v20, "VX_JohnDoe_AimbotDelay", tbl2)
end
getgenv().VX_C00lkidd_WalkspeedOverride = true
getgenv().VX_C00lkidd_Punch = true
getgenv().VX_C00lkiddAnimIds = {}
getgenv().VX_C00lkiddSoundIds = {}
local function fn13()
    getgenv().VX_C00lkiddAnimIds = {}
    getgenv().VX_C00lkiddSoundIds = {}
    local v18 = game
    local ReplicatedStorage = v18:GetService("ReplicatedStorage")

    local function fn14(arg, arg2)
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

    local function fn15(arg)
        local animations = type(arg.Animations) == "table" and arg.Animations or {}
        local sounds = type(arg.Sounds) == "table" and arg.Sounds or {}
        local voicelines = type(arg.Voicelines) == "table" and arg.Voicelines or {}

        if getgenv().VX_C00lkidd_Punch then
            fn14(getgenv().VX_C00lkiddAnimIds, animations.Attack)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.Swing)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.Hit)
        end

        if getgenv().VX_C00lkidd_WalkspeedOverride then
            fn14(getgenv().VX_C00lkiddAnimIds, animations.WalkspeedOverrideStart)
            fn14(getgenv().VX_C00lkiddAnimIds, animations.WalkspeedOverrideLoop)
            fn14(getgenv().VX_C00lkiddAnimIds, animations.WalkspeedOverrideHit)
            fn14(getgenv().VX_C00lkiddAnimIds, animations.WalkspeedOverrideMiss)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.WalkspeedOverrideLoop)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.WalkspeedOverrideLunge)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.WalkspeedOverrideHit)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.WalkspeedOverrideTimeout)
            fn14(getgenv().VX_C00lkiddSoundIds, sounds.WalkspeedOverrideCollide)
            fn14(getgenv().VX_C00lkiddSoundIds, voicelines.WalkspeedOverride)
            fn14(getgenv().VX_C00lkiddSoundIds, voicelines.WalkspeedOverrideHit)
            fn14(getgenv().VX_C00lkiddSoundIds, voicelines.WalkspeedOverrideCollide)
            fn14(getgenv().VX_C00lkiddSoundIds, voicelines.WalkspeedOverrideTimeout)
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Killers.c00lkidd.Config)

        if Config then
            fn15(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local c00lkidd = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("c00lkidd")
        if not c00lkidd then
            return
        end

        for i, child in ipairs(c00lkidd:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn15(module)
                    end
                end
            end)
        end
    end)
end
local function fn14()
    local v18 = nil

    v18 = v:AddDialog("VX_C00lkiddAimbotDialog_" .. tostring(tick()), {
        Title = "c00lkidd Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn13()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_C00lkiddDlg_WalkspeedOverride", {
        Text = "WalkspeedOverride",
        Default = getgenv().VX_C00lkidd_WalkspeedOverride,
        Callback = function(vxC00lkiddWalkspeedOverride)
            getgenv().VX_C00lkidd_WalkspeedOverride = vxC00lkiddWalkspeedOverride
        end,
    })

    v18:AddToggle("VX_C00lkiddDlg_Punch", {
        Text = "Punch",
        Default = getgenv().VX_C00lkidd_Punch,
        Callback = function(vxC00lkiddPunch)
            getgenv().VX_C00lkidd_Punch = vxC00lkiddPunch
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

    addSlider(v19, "VX_C00lkidd_AimbotDuration", tbl)
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

    addSlider2(v20, "VX_C00lkidd_AimbotDelay", tbl2)
end
getgenv().VX_Noli_VoidRush = true
getgenv().VX_Noli_Stab = true
getgenv().VX_NoliAnimIds = {}
getgenv().VX_NoliSoundIds = {}
local function fn15()
    getgenv().VX_NoliAnimIds = {}
    getgenv().VX_NoliSoundIds = {}
    local v18 = game
    local ReplicatedStorage = v18:GetService("ReplicatedStorage")

    local function fn16(arg, arg2)
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

    local function fn17(arg)
        local animations = type(arg.Animations) == "table" and arg.Animations or {}
        local sounds = type(arg.Sounds) == "table" and arg.Sounds or {}
        local voicelines = type(arg.Voicelines) == "table" and arg.Voicelines or {}

        if getgenv().VX_Noli_Stab then
            fn16(getgenv().VX_NoliAnimIds, animations.Stab)
            fn16(getgenv().VX_NoliSoundIds, sounds.Swing)
            fn16(getgenv().VX_NoliSoundIds, sounds.Hit)
        end

        if getgenv().VX_Noli_VoidRush then
            fn16(getgenv().VX_NoliAnimIds, animations.VoidRush)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushStart)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushWindow)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushWeakHit1)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushWeakHit2)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushWeakHit3)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushWeakHit4)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushWeakHit5)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushLoop)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushCancel)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushMissTimeout)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushMissCancelled)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushMissCrashed)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushMissStunned)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushDash1)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushDash2)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushDashLoop)
            fn16(getgenv().VX_NoliSoundIds, sounds.VoidRushCutscene)
            fn16(getgenv().VX_NoliSoundIds, voicelines.VoidRushStart)
            fn16(getgenv().VX_NoliSoundIds, voicelines.Slam)
            fn16(getgenv().VX_NoliSoundIds, voicelines.VoidRushMissTimeout)
            fn16(getgenv().VX_NoliSoundIds, voicelines.VoidRushMissCrashed)
        end
    end

    pcall(function()
        local Config = require(ReplicatedStorage.Assets.Killers.Noli.Config)

        if Config then
            fn17(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local noli = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Killers") and ReplicatedStorage.Assets.Skins.Killers:FindFirstChild("Noli")
        if not noli then
            return
        end

        for i, child in ipairs(noli:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn17(module)
                    end
                end
            end)
        end
    end)
end
local function fn16()
    local v18 = nil

    v18 = v:AddDialog("VX_NoliAimbotDialog_" .. tostring(tick()), {
        Title = "Noli Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn15()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_NoliDlg_VoidRush", {
        Text = "VoidRush",
        Default = getgenv().VX_Noli_VoidRush,
        Callback = function(vxNoliVoidRush)
            getgenv().VX_Noli_VoidRush = vxNoliVoidRush
        end,
    })

    v18:AddToggle("VX_NoliDlg_Stab", {
        Text = "Stab",
        Default = getgenv().VX_Noli_Stab,
        Callback = function(vxNoliStab)
            getgenv().VX_Noli_Stab = vxNoliStab
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

    addSlider(v19, "VX_Noli_AimbotDuration", tbl)
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

    addSlider2(v20, "VX_Noli_AimbotDelay", tbl2)
end
getgenv().VX_Nos_Uppercut = true
getgenv().VX_Nos_Slash = true
getgenv().VX_NosAnimIds = {}
getgenv().VX_NosSoundIds = {}
getgenv().VX_Shedletsky_Slash = true
getgenv().VX_ShedletskyAnimIds = {}
getgenv().VX_ShedletskySoundIds = {}
getgenv().VX_Elliot_ThrowPizza = true
getgenv().VX_ElliotAnimIds = {}
getgenv().VX_ElliotSoundIds = {}
getgenv().VX_ElliotAimMode = "Nearest Survivor"
getgenv().VX_JaneDoe_Axe = true
getgenv().VX_JaneDoeAnimIds = {}
getgenv().VX_JaneDoeSoundIds = {}
getgenv().VX_TwoTime_Stab = true
getgenv().VX_TwoTimeAnimIds = {}
getgenv().VX_TwoTimeSoundIds = {}
getgenv().VX_Sixer_DemonicPursuit = true
getgenv().VX_Sixer_InfernalCry = true
getgenv().VX_Sixer_Slash = true
getgenv().VX_SixerAnimIds = {}
getgenv().VX_SixerSoundIds = {}
local function fn17()
    getgenv().VX_TwoTimeAnimIds = {}
    getgenv().VX_TwoTimeSoundIds = {}

    if getgenv().VX_TwoTime_Stab then
        table.insert(getgenv().VX_TwoTimeAnimIds, "100725497418533")
        table.insert(getgenv().VX_TwoTimeAnimIds, "106086955212611")
        table.insert(getgenv().VX_TwoTimeAnimIds, "107640065977686")
        table.insert(getgenv().VX_TwoTimeAnimIds, "77119710693654")
        table.insert(getgenv().VX_TwoTimeAnimIds, "112902284724598")
        table.insert(getgenv().VX_TwoTimeAnimIds, "89448354637442")
        table.insert(getgenv().VX_TwoTimeAnimIds, "115194624791339")
        table.insert(getgenv().VX_TwoTimeAnimIds, "119434518007321")
    end
end
local function fn18()
    local v18 = nil

    v18 = v:AddDialog("VX_TwoTimeAimbotDialog_" .. tostring(tick()), {
        Title = "Two Time Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn17()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_TwoTimeDlg_Stab", {
        Text = "Stab",
        Default = getgenv().VX_TwoTime_Stab,
        Callback = function(vxTwoTimeStab)
            getgenv().VX_TwoTime_Stab = vxTwoTimeStab
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

    addSlider(v19, "VX_TwoTime_AimbotDuration", tbl)
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

    addSlider2(v20, "VX_TwoTime_AimbotDelay", tbl2)
end
local function fn19()
    getgenv().VX_ShedletskyAnimIds = {}
    getgenv().VX_ShedletskySoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local tbl = {Slash = getgenv().VX_Shedletsky_Slash}
    local tbl2 = {Slash = {"Unsheath", "Slash", "Hit"}}

    local function fn20(arg)
        if type(arg.Animations) == "table" then
            for k, v18 in pairs(tbl) do
                if v18 then
                    local v19 = arg.Animations[k]

                    if type(v19) == "string" then
                        local vxShedletskyAnimIds = getgenv().VX_ShedletskyAnimIds
                        local match = v19:match("%d+")
                        local v20 = match or v19
                        table.insert(vxShedletskyAnimIds, v20)
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
                            local vxShedletskySoundIds = getgenv().VX_ShedletskySoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vxShedletskySoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vxShedletskySoundIds = getgenv().VX_ShedletskySoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vxShedletskySoundIds, v40)
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
        local Config = require(ReplicatedStorage.Assets.Survivors.Shedletsky.Config)

        if Config then
            fn20(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local shedletsky = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Survivors") and ReplicatedStorage.Assets.Skins.Survivors:FindFirstChild("Shedletsky")
        if not shedletsky then
            return
        end

        for i, child in ipairs(shedletsky:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn20(module)
                    end
                end
            end)
        end
    end)
end
local function fn20()
    local v18 = nil

    v18 = v:AddDialog("VX_ShedletskyAimbotDialog_" .. tostring(tick()), {
        Title = "Shedletsky Aimbot Config",
        Description = "Toggle which abilities trigger the aimbot, then click Apply.",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = {
            Apply = {
                Title = "Apply",
                Variant = "Primary",
                Order = 2,
                Callback = function()
                    fn19()
                    v18:Dismiss()
                end,
            },
        },
    })

    v18:AddToggle("VX_ShedletskyDlg_Slash", {
        Text = "Slash",
        Default = getgenv().VX_Shedletsky_Slash,
        Callback = function(vxShedletskySlash)
            getgenv().VX_Shedletsky_Slash = vxShedletskySlash
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

    addSlider(v19, "VX_Shed_AimbotDuration", tbl)
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

    addSlider2(v20, "VX_Shed_AimbotDelay", tbl2)
end
local function fn21()
    getgenv().VX_ElliotAnimIds = {}
    getgenv().VX_ElliotSoundIds = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local tbl = {ThrowPizza = getgenv().VX_Elliot_ThrowPizza}
    local tbl2 = {ThrowPizza = {"PizzaThrown", "PizzaEaten"}}

    local function fn22(arg)
        if type(arg.Animations) == "table" then
            for k, v18 in pairs(tbl) do
                if v18 then
                    local v19 = arg.Animations[k]

                    if type(v19) == "string" then
                        local vxElliotAnimIds = getgenv().VX_ElliotAnimIds
                        local match = v19:match("%d+")
                        local v20 = match or v19
                        table.insert(vxElliotAnimIds, v20)
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
                            local vxElliotSoundIds = getgenv().VX_ElliotSoundIds
                            local match = v38:match("%d+")
                            local v39 = match or v38
                            table.insert(vxElliotSoundIds, v39)
                        elseif type(v38) == "table" then
                            for i, v39 in ipairs(v38) do
                                if type(v39) == "string" then
                                    local vxElliotSoundIds = getgenv().VX_ElliotSoundIds
                                    local match = v39:match("%d+")
                                    local v40 = match or v39
                                    table.insert(vxElliotSoundIds, v40)
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
        local Config = require(ReplicatedStorage.Assets.Survivors.Elliot.Config)

        if Config then
            fn22(Config)
        end
    end)

    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local elliot = assets and ReplicatedStorage.Assets:FindFirstChild("Skins") and ReplicatedStorage.Assets.Skins:FindFirstChild("Survivors") and ReplicatedStorage.Assets.Skins.Survivors:FindFirstChild("Elliot")
        if not elliot then
            return
        end

        for i, child in ipairs(elliot:GetChildren()) do
            pcall(function()
                local config = child:FindFirstChild("Config")

                if config then
                    local module = require(config)

                    if module then
                        fn22(module)
                    end
                end
            end)
        end
    end)
end

P["Aimbot@21681,6-21681,12"] = Aimbot
P["Settings@21682,6-21682,14"] = Settings
P["v17@21684,6-21684,9"] = v17
P["fn9@22043,15-22043,18"] = fn9
P["fn10@22174,15-22174,19"] = fn10
P["fn11@22258,15-22258,19"] = fn11
P["fn12@22401,15-22401,19"] = fn12
P["fn13@22477,15-22477,19"] = fn13
P["fn14@22556,15-22556,19"] = fn14
P["fn15@22632,15-22632,19"] = fn15
P["fn16@22720,15-22720,19"] = fn16
P["fn17@22814,15-22814,19"] = fn17
P["fn18@22830,15-22830,19"] = fn18
P["fn19@22893,15-22893,19"] = fn19
P["fn20@23006,15-23006,19"] = fn20
P["fn21@23069,15-23069,19"] = fn21
end