-- SorsHub pack part 5/10
return function(P)
local lp = P.lp
local fn = P["fn@9471,10-9471,12"]
local Blatant = P["Blatant@16527,10-16527,17"]
local Rage = P["Rage@16529,10-16529,14"]
local Soft = P["Soft@16530,10-16530,14"]
local Items = P["Items@16531,10-16531,15"]
local Obstacles = P["Obstacles@16532,10-16532,19"]
local fn23 = P["fn23@16559,19-16559,23"]
local fn25 = P["fn25@16590,19-16590,23"]

Items:AddCheckbox(fn(), {
        Text = "Auto Pickup Drop Items",
        Default = false,
        Callback = function(arg)
            if arg then
                fn23()
            end
        end,
    })
Items:AddCheckbox(fn(), {
        Text = "Auto Pick Up Near Items",
        Default = false,
        Callback = function(vxPickUpNear)
            getgenv().VX_pickUpNear = vxPickUpNear

            if vxPickUpNear then
                task.spawn(fn25)
            end
        end,
    })
Items:AddCheckbox(fn(), {
        Text = "Auto Pick Up All Items",
        Default = false,
        Callback = function(vxPickUpAll)
            getgenv().VX_pickUpAll = vxPickUpAll

            if vxPickUpAll then
                task.spawn(fn25)
            end
        end,
    })
Items:AddSlider(fn(), {
        Text = "Pick Up Near Range",
        Min = 5,
        Max = 50,
        Default = 10,
        Rounding = 0,
        Callback = function(arg)
            getgenv().VX_pickUpRange = tonumber(arg)
        end,
    })
Items:AddDropdown(fn(), {
        Text = "Item Filter",
        Values = {"Both", "Cola", "Medkit"},
        Default = "Both",
        Callback = function(vxPickUpFilter)
            getgenv().VX_pickUpFilter = vxPickUpFilter
        end,
    })
local v18 = Blatant:AddRightTabbox("rotate-cw")
local v19 = v18:AddTab("Smooth Turning")
local Settings6 = v18:AddTab("Settings")
task.spawn(function()
        local RunService_3 = game:GetService("RunService")
        local localPlayer8 = game.Players.LocalPlayer

        getgenv().DPAnimIDs = {
            ["rbxassetid://133363345661032"] = true,
            ["rbxassetid://128414736976503"] = true,
            ["rbxassetid://139309647473555"] = true,
        }

        getgenv().IsUsingPursuit = function()
            local character2 = localPlayer8.Character
            if not character2 then
                return false
            end
            local humanoid2 = character2:FindFirstChild("Humanoid")
            if not humanoid2 then
                return false
            end
            local animator = humanoid2:FindFirstChild("Animator")
            if not animator then
                return false
            end

            for i, v20 in ipairs(animator:GetPlayingAnimationTracks()) do
                if v20.Animation and getgenv().DPAnimIDs[v20.Animation.AnimationId] then
                    return true
                end
            end

            return false
        end

        getgenv().DPApplyVelocity = function(arg, arg2)
            local assemblyLinearVelocity = arg.AssemblyLinearVelocity
            local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
            local y = assemblyLinearVelocity.Y
            local vxDPSteerStrength = getgenv().VX_DPSteerStrength
            local n4 = vxDPSteerStrength or 5
            local n5 = math.clamp(n4 / 10, 0.01, 1)

            if magnitude > 1 then
                local v20 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Unit:Lerp(arg2, math.clamp(n5, 0, 1))
                local unit = v20

                if v20.Magnitude > 0 then
                    unit = v20.Unit
                end

                local n6 = unit * magnitude
                arg.AssemblyLinearVelocity = Vector3.new(n6.X, y, n6.Z)
            end

            for i, child in ipairs(arg:GetChildren()) do
                if child:IsA("AlignOrientation") then
                    child.Enabled = false
                elseif child:IsA("BodyGyro") then
                    child.MaxTorque = Vector3.new(0, 0, 0)
                    child.P = 0
                elseif child:IsA("BodyVelocity") then
                    local vector = Vector3.new(child.Velocity.X, 0, child.Velocity.Z)

                    if vector.Magnitude > 1 then
                        local n6 = arg2 * vector.Magnitude
                        child.Velocity = Vector3.new(n6.X, child.Velocity.Y, n6.Z)
                    end
                elseif child:IsA("LinearVelocity") then
                    local vector = Vector3.new(child.VectorVelocity.X, 0, child.VectorVelocity.Z)

                    if vector.Magnitude > 1 then
                        local n6 = arg2 * vector.Magnitude
                        child.VectorVelocity = Vector3.new(n6.X, child.VectorVelocity.Y, n6.Z)
                    end
                end
            end
        end

        getgenv().DemonicPursuitEnabled = false
        getgenv().DemonicPursuitConn = nil

        v19:AddCheckbox(fn(), {
            Text = "Demonic Pursuit Redirector",
            Default = false,
            Callback = function(demonicPursuitEnabled)
                getgenv().DemonicPursuitEnabled = demonicPursuitEnabled

                if demonicPursuitEnabled then
                    if not getgenv().DemonicPursuitConn then
                        getgenv().DemonicPursuitConn = RunService_3.Stepped:Connect(function()
                            if not getgenv().DemonicPursuitEnabled then
                                return
                            end

                            if not getgenv().IsUsingPursuit() then
                                return
                            end
                            local character2 = localPlayer8.Character
                            if not character2 or not character2.PrimaryPart then
                                return
                            end
                            local currentCamera = workspace.CurrentCamera
                            if not currentCamera then
                                return
                            end
                            local lookVector = currentCamera.CFrame.LookVector
                            local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

                            if vector.Magnitude > 0.001 then
                                getgenv().DPApplyVelocity(character2.PrimaryPart, vector.Unit)
                            end
                        end)
                    end
                elseif getgenv().DemonicPursuitConn then
                    getgenv().DemonicPursuitConn:Disconnect()
                    getgenv().DemonicPursuitConn = nil
                end
            end,
        })

        local genv7 = getgenv()
        local isChargeActive = getgenv().isChargeActive
        local isChargeActive2 = isChargeActive or false
        genv7.isChargeActive = isChargeActive2
        local genv8 = getgenv()
        local chargeConnection = getgenv().chargeConnection
        local v20 = chargeConnection or nil
        genv8.chargeConnection = v20
        local genv9 = getgenv()
        local dashSpeed = getgenv().dashSpeed
        local dashSpeed2 = dashSpeed or 50
        genv9.dashSpeed = dashSpeed2
        local genv10 = getgenv()
        local chargeControlEnabled = getgenv().chargeControlEnabled
        local chargeControlEnabled2 = chargeControlEnabled or false
        genv10.chargeControlEnabled = chargeControlEnabled2

        getgenv().stopCharge = function()
            if not getgenv().isChargeActive then
                return
            end
            getgenv().isChargeActive = false
            local character2 = localPlayer8.Character

            if character2 then
                local humanoid2 = character2:FindFirstChildOfClass("Humanoid")

                if humanoid2 then
                    humanoid2.AutoRotate = true
                    humanoid2:Move(Vector3.new())
                end
            end

            RunService_3:UnbindFromRenderStep("VX_ChargeSteer")
            getgenv().chargeConnection = nil
        end

        getgenv().startCharge = function(arg, arg2)
            if getgenv().isChargeActive then
                return
            end
            getgenv().isChargeActive = true
            getgenv().chargeSteerDir = nil
            getgenv().chargeConnection = true

            RunService_3:BindToRenderStep("VX_ChargeSteer", 1001, function(arg3)
                if arg and arg2 and arg.Parent then
                    arg.AutoRotate = false

                    if not getgenv().chargeSteerDir then
                        local lookVector = arg2.CFrame.LookVector
                        local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                        local genv11 = getgenv()
                        local unit = vector.Magnitude > 0.01 and vector.Unit or Vector3.new(0, 0, -1)
                        genv11.chargeSteerDir = unit
                    end

                    local lookVector = workspace.CurrentCamera.CFrame.LookVector
                    local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                    local unit = vector.Magnitude > 0.01 and vector.Unit or getgenv().chargeSteerDir
                    local vxChargeSteerStrength = getgenv().VX_ChargeSteerStrength
                    local n4 = vxChargeSteerStrength or 5

                    if n4 >= 10 then
                        getgenv().chargeSteerDir = unit
                    elseif n4 > 0 then
                        local n5 = math.clamp(arg3 * (n4 / 10) * 60, 0, 1)
                        getgenv().chargeSteerDir = getgenv().chargeSteerDir:Lerp(unit, n5).Unit
                    end

                    arg:Move(getgenv().chargeSteerDir)
                    return
                end

                getgenv().stopCharge()
            end)
        end

        local function fn26(character2)
            local humanoid2 = character2:WaitForChild("Humanoid", 5)
            local humanoidRootPart3 = character2:WaitForChild("HumanoidRootPart", 5)
            if not humanoid2 or not humanoidRootPart3 then
                return
            end
            RunService_3:UnbindFromRenderStep("VX_ChargeSteer")
            getgenv().chargeConnection = nil
            getgenv().isChargeActive = false
            local speedMultipliers = character2:WaitForChild("SpeedMultipliers", 8)
            if not speedMultipliers then
                return
            end

            local function fn27()
                if not getgenv().chargeControlEnabled then
                    getgenv().stopCharge()
                    return
                end

                if speedMultipliers:FindFirstChild("Guest1337Charge") then
                    getgenv().startCharge(humanoid2, humanoidRootPart3)
                else
                    getgenv().stopCharge()
                end
            end

            fn27()
            speedMultipliers.ChildAdded:Connect(fn27)
            speedMultipliers.ChildRemoved:Connect(fn27)
        end

        if localPlayer8.Character then
            task.spawn(fn26, localPlayer8.Character)
        end

        localPlayer8.CharacterAdded:Connect(fn26)
        v19:AddDivider({MarginTop = 2, MarginBottom = 2})

        v19:AddCheckbox(fn(), {
            Text = "Charge Redirector",
            Default = false,
            Callback = function(chargeControlEnabled3)
                getgenv().chargeControlEnabled = chargeControlEnabled3

                if not chargeControlEnabled3 then
                    getgenv().stopCharge()
                end
            end,
        })

        local flag5 = false
        local flag6 = false
        local humanoid2 = nil
        local humanoidRootPart3 = nil
        local unit = nil

        local function fn27(character2)
            humanoid2 = character2:WaitForChild("Humanoid")
            humanoidRootPart3 = character2:WaitForChild("HumanoidRootPart")
        end

        if localPlayer8.Character then
            fn27(localPlayer8.Character)
        end

        localPlayer8.CharacterAdded:Connect(fn27)

        local function fn28()
            if flag6 then
                return
            end
            flag6 = true
            unit = nil

            RunService_3:BindToRenderStep("VX_VoidRushSteer", 1001, function(arg)
                if not humanoid2 or not humanoidRootPart3 then
                    return
                end
                humanoid2.WalkSpeed = 60
                humanoid2.AutoRotate = false

                if not unit then
                    local lookVector = humanoidRootPart3.CFrame.LookVector
                    local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                    local unit2 = vector.Magnitude > 0.01 and vector.Unit or Vector3.new(0, 0, -1)
                    unit = unit2
                end

                local lookVector = workspace.CurrentCamera.CFrame.LookVector
                local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                local unit2 = vector.Magnitude > 0.01 and vector.Unit or unit
                local vxVoidRushSteerStrength = getgenv().VX_VoidRushSteerStrength
                local n4 = vxVoidRushSteerStrength or 5

                if n4 >= 10 then
                    unit = unit2
                elseif n4 > 0 then
                    local n5 = math.clamp(arg * (n4 / 10) * 60, 0, 1)
                    unit = unit:Lerp(unit2, n5).Unit
                end

                humanoid2:Move(unit)
            end)
        end

        local function fn29()
            if not flag6 then
                return
            end
            flag6 = false

            if humanoid2 then
                humanoid2.WalkSpeed = 16
                humanoid2.AutoRotate = true
                humanoid2:Move(Vector3.new(0, 0, 0))
            end

            RunService_3:UnbindFromRenderStep("VX_VoidRushSteer")
        end

        RunService_3.RenderStepped:Connect(function()
            if not flag5 then
                return
            end
            local character2 = localPlayer8.Character
            if not character2 then
                return
            end

            if character2:GetAttribute("VoidRushState") == "Dashing" then
                fn28()
            else
                fn29()
            end
        end)

        v19:AddDivider({MarginTop = 2, MarginBottom = 2})

        v19:AddCheckbox(fn(), {
            Text = "VoidRush Redirector",
            Default = false,
            Callback = function(arg)
                flag5 = arg

                if not arg then
                    fn29()
                end
            end,
        })

        local flag7 = false
        local flag8 = false
        local unit2 = nil
        local flag9 = false
        local humanoidRootPart4 = nil
        local humanoid3 = nil
        local tbl7 = {Timeout = true, Collide = true, Hit = true}

        local function fn30()
            if flag8 then
                return
            end
            flag8 = true
            unit2 = nil
            flag9 = false
            local character2 = localPlayer8.Character

            if character2 then
                local function fn31(arg)
                    local function fn32()
                        if tbl7[arg.Value] then
                            flag9 = true
                        end
                    end

                    fn32()
                    arg:GetPropertyChangedSignal("Value"):Connect(fn32)
                end

                local result2 = character2:FindFirstChild("Result")

                if result2 and result2:IsA("StringValue") then
                    fn31(result2)
                end

                character2.ChildAdded:Connect(function(child)
                    if child.Name == "Result" and child:IsA("StringValue") then
                        fn31(child)
                    end
                end)
            end

            RunService_3:BindToRenderStep("VX_WSOSteer", 1001, function(arg)
                if not humanoidRootPart4 or not humanoid3 then
                    return
                end

                if flag9 then
                    return
                end
                local linearVelocity = humanoidRootPart4:FindFirstChild("LinearVelocity")
                if not linearVelocity then
                    return
                end

                if not unit2 then
                    local lookVector = humanoidRootPart4.CFrame.LookVector
                    local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                    local unit3 = vector.Magnitude > 0.01 and vector.Unit or Vector3.new(0, 0, -1)
                    unit2 = unit3
                end

                local lookVector = workspace.CurrentCamera.CFrame.LookVector
                local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                local unit3 = vector.Magnitude > 0.01 and vector.Unit or unit2
                local vxWSOSteerStrength = getgenv().VX_WSOSteerStrength
                local n4 = vxWSOSteerStrength or 5

                if n4 >= 10 then
                    unit2 = unit3
                elseif n4 > 0 then
                    local n5 = math.clamp(arg * (n4 / 10) * 60, 0, 1)
                    unit2 = unit2:Lerp(unit3, n5).Unit
                end

                linearVelocity.VectorVelocity = Vector3.new(math.huge, math.huge, math.huge)
                linearVelocity.Enabled = false
                local vxWSOSpeed = getgenv().VX_WSOSpeed
                local n5 = vxWSOSpeed or 100
                local vector2 = Vector3.new(unit2.X * n5, humanoidRootPart4.Velocity.Y, unit2.Z * n5)
                humanoidRootPart4.Velocity = vector2
                local cframe = CFrame.new(humanoidRootPart4.Position, humanoidRootPart4.Position + unit2)
                humanoidRootPart4.CFrame = cframe
            end)
        end

        local function fn31()
            if not flag8 then
                return
            end
            flag8 = false
            unit2 = nil
            flag9 = false
            RunService_3:UnbindFromRenderStep("VX_WSOSteer")
        end

        local function fn32(arg)
            humanoid3 = arg:WaitForChild("Humanoid")
            humanoidRootPart4 = arg:WaitForChild("HumanoidRootPart")
        end

        if localPlayer8.Character then
            fn32(localPlayer8.Character)
        end

        localPlayer8.CharacterAdded:Connect(function(character2)
            fn31()
            fn32(character2)
        end)

        RunService_3.RenderStepped:Connect(function()
            if not flag7 then
                return
            end
            local character2 = localPlayer8.Character
            if not character2 or character2.Name ~= "c00lkidd" then
                return
            end
            local humanoidRootPart5 = character2:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart5 and humanoidRootPart5:FindFirstChild("LinearVelocity") then
                fn30()
            else
                fn31()
            end
        end)

        v19:AddDivider({MarginTop = 2, MarginBottom = 2})

        getgenv().VX_ToggleWSORedirector = function(arg)
            flag7 = arg

            if not arg then
                fn31()
            end
        end

        v19:AddCheckbox(fn(), {
            Text = "Walkspeed Override Redirector",
            Default = false,
            Callback = function(arg)
                getgenv().VX_ToggleWSORedirector(arg)
            end,
        })

        getgenv().TwoTimeVelocityFix = false
        getgenv().TwoTimeVelocityConn = nil

        getgenv().StartTwoTimeVelocityFix = function()
            if getgenv().TwoTimeVelocityConn then
                getgenv().TwoTimeVelocityConn:Disconnect()
            end

            getgenv().TwoTimeVelocityConn = RunService_3.Heartbeat:Connect(function()
                if not getgenv().TwoTimeVelocityFix then
                    return
                end
                local character2 = localPlayer8.Character
                if not character2 or character2.Name ~= "TwoTime" then
                    return
                end
                local humanoidRootPart5 = character2:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart5 then
                    return
                end
                local linearVelocity = humanoidRootPart5:FindFirstChild("LinearVelocity")

                if linearVelocity then
                    local vxCrouchLungeSteerStrength = getgenv().VX_CrouchLungeSteerStrength
                    local n4 = vxCrouchLungeSteerStrength or 5
                    local n5 = math.clamp(n4 / 10, 0, 1)
                    linearVelocity.LineDirection = linearVelocity.LineDirection:Lerp(humanoidRootPart5.CFrame.LookVector, n5)
                end
            end)
        end

        getgenv().StopTwoTimeVelocityFix = function()
            if getgenv().TwoTimeVelocityConn then
                getgenv().TwoTimeVelocityConn:Disconnect()
                getgenv().TwoTimeVelocityConn = nil
            end
        end

        v19:AddDivider({MarginTop = 2, MarginBottom = 2})

        v19:AddCheckbox(fn(), {
            Text = "Crouch Lunge Redirector",
            Default = false,
            Callback = function(twoTimeVelocityFix)
                getgenv().TwoTimeVelocityFix = twoTimeVelocityFix

                if twoTimeVelocityFix then
                    getgenv().StartTwoTimeVelocityFix()
                else
                    getgenv().StopTwoTimeVelocityFix()
                end
            end,
        })

        getgenv().JaneDoe_HatchetVelocityFix = false
        getgenv().JaneDoe_HatchetVelocityConn = nil

        getgenv().StartJaneDoe_HatchetController = function()
            if getgenv().JaneDoe_HatchetVelocityConn then
                getgenv().JaneDoe_HatchetVelocityConn:Disconnect()
            end

            getgenv().JaneDoe_HatchetVelocityConn = RunService_3.Heartbeat:Connect(function()
                if not getgenv().JaneDoe_HatchetVelocityFix then
                    return
                end
                local character2 = localPlayer8.Character
                if not character2 or character2.Name ~= "JaneDoe" then
                    return
                end
                local humanoidRootPart5 = character2:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart5 then
                    return
                end
                local linearVelocity = humanoidRootPart5:FindFirstChild("LinearVelocity")

                if linearVelocity then
                    local vxHatchetSteerStrength = getgenv().VX_HatchetSteerStrength
                    local n4 = vxHatchetSteerStrength or 5
                    local n5 = math.clamp(n4 / 10, 0, 1)
                    linearVelocity.LineDirection = linearVelocity.LineDirection:Lerp(humanoidRootPart5.CFrame.LookVector, n5)
                end
            end)
        end

        getgenv().StopJaneDoe_HatchetController = function()
            if getgenv().JaneDoe_HatchetVelocityConn then
                getgenv().JaneDoe_HatchetVelocityConn:Disconnect()
                getgenv().JaneDoe_HatchetVelocityConn = nil
            end
        end

        v19:AddDivider({MarginTop = 2, MarginBottom = 2})

        v19:AddCheckbox(fn(), {
            Text = "Hatchet Redirector",
            Default = false,
            Callback = function(janeDoeHatchetVelocityFix)
                getgenv().JaneDoe_HatchetVelocityFix = janeDoeHatchetVelocityFix

                if janeDoeHatchetVelocityFix then
                    getgenv().StartJaneDoe_HatchetController()
                else
                    getgenv().StopJaneDoe_HatchetController()
                end
            end,
        })

        local genv11 = getgenv()
        local vxDPSteerStrength = getgenv().VX_DPSteerStrength
        local vxDPSteerStrength2 = vxDPSteerStrength or 5
        genv11.VX_DPSteerStrength = vxDPSteerStrength2

        Settings6:AddSlider(fn(), {
            Text = "Demonic Pursuit Steer Strength",
            Min = 0,
            Max = 10,
            Default = 5,
            Rounding = 2,
            Callback = function(vxDPSteerStrength3)
                getgenv().VX_DPSteerStrength = vxDPSteerStrength3
            end,
        })

        Settings6:AddDivider({MarginTop = 2, MarginBottom = 2})
        local genv12 = getgenv()
        local vxChargeSteerStrength = getgenv().VX_ChargeSteerStrength
        local vxChargeSteerStrength2 = vxChargeSteerStrength or 5
        genv12.VX_ChargeSteerStrength = vxChargeSteerStrength2

        Settings6:AddSlider(fn(), {
            Text = "Charge Steer Strength",
            Min = 0,
            Max = 10,
            Default = 5,
            Rounding = 2,
            Callback = function(vxChargeSteerStrength3)
                getgenv().VX_ChargeSteerStrength = vxChargeSteerStrength3
            end,
        })

        Settings6:AddDivider({MarginTop = 2, MarginBottom = 2})
        local genv13 = getgenv()
        local vxVoidRushSteerStrength = getgenv().VX_VoidRushSteerStrength
        local vxVoidRushSteerStrength2 = vxVoidRushSteerStrength or 5
        genv13.VX_VoidRushSteerStrength = vxVoidRushSteerStrength2

        Settings6:AddSlider(fn(), {
            Text = "VoidRush Steer Strength",
            Min = 0,
            Max = 10,
            Default = 5,
            Rounding = 2,
            Callback = function(vxVoidRushSteerStrength3)
                getgenv().VX_VoidRushSteerStrength = vxVoidRushSteerStrength3
            end,
        })

        Settings6:AddDivider({MarginTop = 2, MarginBottom = 2})
        local genv14 = getgenv()
        local vxWSOSteerStrength = getgenv().VX_WSOSteerStrength
        local vxWSOSteerStrength2 = vxWSOSteerStrength or 5
        genv14.VX_WSOSteerStrength = vxWSOSteerStrength2

        Settings6:AddSlider(fn(), {
            Text = "Walkspeed Override Steer Strength",
            Min = 0,
            Max = 10,
            Default = 5,
            Rounding = 2,
            Callback = function(vxWSOSteerStrength3)
                getgenv().VX_WSOSteerStrength = vxWSOSteerStrength3
            end,
        })

        Settings6:AddDivider({MarginTop = 2, MarginBottom = 2})
        local genv15 = getgenv()
        local vxCrouchLungeSteerStrength = getgenv().VX_CrouchLungeSteerStrength
        local vxCrouchLungeSteerStrength2 = vxCrouchLungeSteerStrength or 5
        genv15.VX_CrouchLungeSteerStrength = vxCrouchLungeSteerStrength2

        Settings6:AddSlider(fn(), {
            Text = "Crouch Lunge Steer Strength",
            Min = 0,
            Max = 10,
            Default = 5,
            Rounding = 2,
            Callback = function(vxCrouchLungeSteerStrength3)
                getgenv().VX_CrouchLungeSteerStrength = vxCrouchLungeSteerStrength3
            end,
        })

        Settings6:AddDivider({MarginTop = 2, MarginBottom = 2})
        local genv16 = getgenv()
        local vxHatchetSteerStrength = getgenv().VX_HatchetSteerStrength
        local vxHatchetSteerStrength2 = vxHatchetSteerStrength or 5
        genv16.VX_HatchetSteerStrength = vxHatchetSteerStrength2

        Settings6:AddSlider(fn(), {
            Text = "Hatchet Steer Strength",
            Min = 0,
            Max = 10,
            Default = 5,
            Rounding = 2,
            Callback = function(vxHatchetSteerStrength3)
                getgenv().VX_HatchetSteerStrength = vxHatchetSteerStrength3
            end,
        })
    end)
task.spawn(function()
        local RunService_3 = game:GetService("RunService")
        local localPlayer8 = game.Players.LocalPlayer
        local genv7 = getgenv()
        local vxNoliHookRules = getgenv().VX_NoliHookRules
        local vxNoliHookRules2 = vxNoliHookRules or {}
        genv7.VX_NoliHookRules = vxNoliHookRules2
        local genv8 = getgenv()
        local vxNoliOrigNamecall = getgenv().VX_NoliOrigNamecall
        local v20 = vxNoliOrigNamecall or nil
        genv8.VX_NoliOrigNamecall = v20

        if not getgenv().VX_NoliOrigNamecall then
            getgenv().VX_NoliOrigNamecall = hookmetamethod(game, "__namecall", function(arg, ...)
                local tbl7 = {...}

                if getnamecallmethod() == "FireServer" then
                    for i, vxNoliHookRule in ipairs(getgenv().VX_NoliHookRules) do
                        if (not vxNoliHookRule.remoteName or arg.Name == vxNoliHookRule.remoteName) and (not vxNoliHookRule.blockedFirstArg or tbl7[1] == vxNoliHookRule.blockedFirstArg) and vxNoliHookRule.block then
                            return
                        end
                    end
                end

                return getgenv().VX_NoliOrigNamecall(arg, ...)
            end)
        end

        Obstacles:AddCheckbox(fn(), {
            Text = "Ignore Void Rush Obstacles",
            Default = false,
            Callback = function(arg)
                local str = localPlayer8.Name .. "VoidRushCollision"

                if arg then
                    local flag5 = false

                    for i, vxNoliHookRule in ipairs(getgenv().VX_NoliHookRules) do
                        if vxNoliHookRule.remoteName == "RemoteEvent" and vxNoliHookRule.blockedFirstArg == str then
                            flag5 = true
                            break
                        end
                    end

                    if not flag5 then
                        table.insert(getgenv().VX_NoliHookRules, {
                            remoteName = "RemoteEvent",
                            blockedFirstArg = str,
                            block = true,
                        })
                    end
                else
                    for i = #getgenv().VX_NoliHookRules, 1, -1 do
                        local v21 = getgenv().VX_NoliHookRules[i]

                        if v21.remoteName == "RemoteEvent" and v21.blockedFirstArg == str then
                            table.remove(getgenv().VX_NoliHookRules, i)
                        end
                    end
                end
            end,
        })

        local connection8 = nil

        Obstacles:AddCheckbox(fn(), {
            Text = "Ignore c00lkidd Obstacles",
            Default = false,
            Callback = function(arg)
                if arg then
                    connection8 = RunService_3.Heartbeat:Connect(function()
                        local character2 = localPlayer8.Character
                        if not character2 or character2.Name ~= "c00lkidd" then
                            return
                        end
                        local humanoidRootPart3 = character2:FindFirstChild("HumanoidRootPart")
                        if not humanoidRootPart3 then
                            return
                        end
                        local linearVelocity = humanoidRootPart3:FindFirstChild("LinearVelocity")
                        if not linearVelocity then
                            return
                        end
                        linearVelocity.VectorVelocity = Vector3.new(math.huge, math.huge, math.huge)
                        linearVelocity.Enabled = false
                    end)
                elseif connection8 then
                    connection8:Disconnect()
                    connection8 = nil
                end
            end,
        })

        local genv9 = getgenv()
        local vxChargeHookRules = getgenv().VX_ChargeHookRules
        local vxChargeHookRules2 = vxChargeHookRules or {}
        genv9.VX_ChargeHookRules = vxChargeHookRules2
        local genv10 = getgenv()
        local vxChargeOrigNamecall = getgenv().VX_ChargeOrigNamecall

        local v21 = vxChargeOrigNamecall or hookmetamethod(game, "__namecall", function(arg, ...)
            local tbl7 = {...}

            if getnamecallmethod() == "FireServer" then
                for i, vxChargeHookRule in ipairs(getgenv().VX_ChargeHookRules) do
                    if arg.Name == vxChargeHookRule.remoteName and tbl7[1] == vxChargeHookRule.blockedArg then
                        return
                    end
                end
            end

            return getgenv().VX_ChargeOrigNamecall(arg, ...)
        end)

        genv10.VX_ChargeOrigNamecall = v21

        getgenv().EnableChargeIgnore = function()
            local str = localPlayer8.Name .. "Guest1337Collision"

            for i, vxChargeHookRule in ipairs(getgenv().VX_ChargeHookRules) do
                if vxChargeHookRule.blockedArg == str then
                    return
                end
            end

            table.insert(getgenv().VX_ChargeHookRules, {remoteName = "RemoteEvent", blockedArg = str})
        end

        getgenv().DisableChargeIgnore = function()
            local str = localPlayer8.Name .. "Guest1337Collision"

            for i = #getgenv().VX_ChargeHookRules, 1, -1 do
                if getgenv().VX_ChargeHookRules[i].blockedArg == str then
                    table.remove(getgenv().VX_ChargeHookRules, i)
                end
            end
        end

        Obstacles:AddCheckbox(fn(), {
            Text = "Ignore Charge Obstacles",
            Default = false,
            Callback = function(arg)
                if arg then
                    getgenv().EnableChargeIgnore()
                else
                    getgenv().DisableChargeIgnore()
                end
            end,
        })
    end)
local localPlayer8 = game:GetService("Players").LocalPlayer
local v20 = nil
local flag5 = false
local function fn26(arg)
        if not arg then
            return
        end
        local humanoid2 = arg:FindFirstChildOfClass("Humanoid")
        if not humanoid2 then
            return
        end
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://75804462760596"
        v20 = humanoid2:LoadAnimation(animation)
        v20:Play()
        v20:AdjustSpeed(0)
    end
local function fn27()
        if v20 then
            v20:Stop()
            v20 = nil
        end
    end
Rage:AddCheckbox(fn(), {
        Text = "Invisibility",
        Default = false,
        Callback = function(arg)
            flag5 = arg

            if arg then
                if localPlayer8.Character then
                    fn26(localPlayer8.Character)
                end

                localPlayer8.CharacterAdded:Connect(function(character2)
                    task.wait(0.5)

                    if flag5 then
                        fn26(character2)
                    end
                end)
            else
                fn27()
            end
        end,
    })
getgenv().autoDeleteShadowsTI = false
getgenv().antiPuddleConn = nil
getgenv().antiPuddleLastFolder = nil
getgenv().disablePuddleParts = function(arg)
        if not arg then
            return
        end

        for k, descendant in pairs(arg:GetDescendants()) do
            if descendant:IsA("BasePart") then
                pcall(function()
                    descendant.CanTouch = false
                end)
            end
        end
    end
getgenv().watchPuddleFolder = function(arg)
        if not arg then
            return
        end
        getgenv().disablePuddleParts(arg)

        if getgenv().antiPuddleConn then
            getgenv().antiPuddleConn:Disconnect()
            getgenv().antiPuddleConn = nil
        end

        getgenv().antiPuddleConn = arg.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") then
                pcall(function()
                    descendant.CanTouch = false
                end)
            end
        end)
    end
Rage:AddCheckbox(fn(), {
        Text = "Walkable John Doe Puddle",
        Default = false,
        Callback = function(autoDeleteShadowsTI)
            getgenv().autoDeleteShadowsTI = autoDeleteShadowsTI

            if autoDeleteShadowsTI then
                task.spawn(function()
                    getgenv().antiPuddleLastFolder = nil

                    while getgenv().autoDeleteShadowsTI do
                        pcall(function()
                            local name = game.Players.LocalPlayer.Name
                            local map = workspace:FindFirstChild("Map")
                            local ingame = map and workspace.Map:FindFirstChild("Ingame")
                            if not ingame then
                                return
                            end
                            local v21 = ingame:FindFirstChild(name .. "Shadows")
                            local shadows = v21 or ingame:FindFirstChild("Shadows") or ingame:FindFirstChild("JohnDoePuddles") or ingame:FindFirstChild("Puddles")

                            if shadows and shadows ~= getgenv().antiPuddleLastFolder then
                                getgenv().antiPuddleLastFolder = shadows
                                getgenv().watchPuddleFolder(shadows)
                            end

                            for k, child in pairs(ingame:GetChildren()) do
                                if child:IsA("BasePart") and (child.Name:lower():find("shadow") or child.Name:lower():find("puddle")) then
                                    pcall(function()
                                        child.CanTouch = false
                                    end)
                                elseif (child:IsA("Model") or child:IsA("Folder")) and (child.Name:lower():find("shadow") or child.Name:lower():find("puddle") or child.Name == name .. "Shadows") then
                                    getgenv().disablePuddleParts(child)
                                end
                            end
                        end)

                        task.wait(0.5)
                    end

                    if getgenv().antiPuddleConn then
                        getgenv().antiPuddleConn:Disconnect()
                        getgenv().antiPuddleConn = nil
                    end

                    getgenv().antiPuddleLastFolder = nil
                end)
            elseif getgenv().antiPuddleConn then
                getgenv().antiPuddleConn:Disconnect()
                getgenv().antiPuddleConn = nil
            end
        end,
    })
getgenv()._antiNosPuddleEnabled = false
getgenv()._antiNosPuddleConn = nil
Rage:AddCheckbox(fn(), {
        Text = "Walkable Nos Puddles",
        Default = false,
        Callback = function(antiNosPuddleEnabled)
            getgenv()._antiNosPuddleEnabled = antiNosPuddleEnabled

            if antiNosPuddleEnabled then
                getgenv()._disableNosPuddleParts = function(arg)
                    if not arg then
                        return
                    end

                    for k, descendant in pairs(arg:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            pcall(function()
                                descendant.CanTouch = false
                            end)
                        end
                    end

                    if arg:IsA("BasePart") then
                        pcall(function()
                            arg.CanTouch = false
                        end)
                    end
                end

                task.spawn(function()
                    while getgenv()._antiNosPuddleEnabled do
                        pcall(function()
                            local map = workspace:FindFirstChild("Map")
                            local ingame = map and workspace.Map:FindFirstChild("Ingame")
                            if not ingame then
                                return
                            end

                            for k, child in pairs(ingame:GetChildren()) do
                                if child.Name:lower():match("puddle") then
                                    getgenv()._disableNosPuddleParts(child)

                                    if not getgenv()._antiNosPuddleConn then
                                        getgenv()._antiNosPuddleConn = child.DescendantAdded:Connect(function(descendant)
                                            if descendant:IsA("BasePart") then
                                                pcall(function()
                                                    descendant.CanTouch = false
                                                end)
                                            end
                                        end)
                                    end
                                end
                            end
                        end)

                        task.wait(0.5)
                    end

                    if getgenv()._antiNosPuddleConn then
                        getgenv()._antiNosPuddleConn:Disconnect()
                        getgenv()._antiNosPuddleConn = nil
                    end
                end)
            elseif getgenv()._antiNosPuddleConn then
                getgenv()._antiNosPuddleConn:Disconnect()
                getgenv()._antiNosPuddleConn = nil
            end
        end,
    })
getgenv().VX_AutoEscapeHook = false
local connection8 = nil
Rage:AddCheckbox(fn(), {
        Text = "Auto Escape Hook",
        Default = false,
        Callback = function(vxAutoEscapeHook)
            getgenv().VX_AutoEscapeHook = vxAutoEscapeHook

            if connection8 then
                connection8:Disconnect()
                connection8 = nil
            end

            if vxAutoEscapeHook then
                local remoteEvent2 = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent")

                connection8 = game:GetService("RunService").Heartbeat:Connect(function()
                    if not getgenv().VX_AutoEscapeHook then
                        return
                    end
                    local character2 = lp.Character
                    if not character2 or not character2.Parent or character2.Parent.Name ~= "Survivors" then
                        return
                    end
                    local playerGui = lp:FindFirstChild("PlayerGui")
                    if not playerGui then
                        return
                    end
                    local temporaryUI = playerGui:FindFirstChild("TemporaryUI")
                    if not temporaryUI then
                        return
                    end

                    if not temporaryUI:FindFirstChild("QTE") then
                        return
                    end
                    local name = nil

                    for i, player_ in ipairs(game:GetService("Players"):GetPlayers()) do
                        local character3 = player_.Character
                        if character3 and character3.Parent and character3.Parent.Name == "Killers" then
                            name = player_.Name
                            break
                        end
                    end

                    if not name then
                        return
                    end

                    pcall(function()
                        remoteEvent2:FireServer(name .. "NosHookQTE", {buffer.fromstring("\001\001")})
                    end)
                end)
            end
        end,
    })
getgenv().stabAnimIds = {"100725497418533", "106086955212611"}
getgenv().crouchStabAnimIds = {"89448354637442", "115194624791339", "119434518007321"}
getgenv().shotAnimIds = {
        "133491532453922",
        "90499469533503",
        "76649505662612",
        "111313169447787",
        "73921036900313",
        "111384272984267",
        "133607163653602",
        "108014891454394",
        "131189930305001",
        "79350075778160",
    }
getgenv().slashAnimIds = {
        "105614318732282",
        "121255898612475",
        "98031287364865",
        "131696603025265",
        "119462383658044",
        "77448521277146",
        "122503338277352",
        "110400453990786",
        "108773914369470",
    }
getgenv().hatchetAnimIds = {"111918351126361"}
getgenv().crystalAnimIds = {"106527725058030", "139929602101552"}
getgenv().tripwireAnimIds = {
        "97339712737072",
        "123920512025716",
        "130498773808198",
        "122093265676661",
        "77968235994360",
        "86590352475117",
        "72928066575114",
        "87925353650822",
    }
getgenv().tripmineAnimIds = {
        "134027914413177",
        "74613365376634",
        "139478062230955",
        "104325892922988",
    }
local function fn28()
        if not getgenv().createAnimationBlocker then
            return
        end

        if not getgenv().ghostStabber then
            getgenv().ghostStabber = getgenv().createAnimationBlocker(getgenv().stabAnimIds)
        end

        if not getgenv().ghostCrouchStabber then
            getgenv().ghostCrouchStabber = getgenv().createAnimationBlocker(getgenv().crouchStabAnimIds)
        end

        if not getgenv().ghostShooter then
            getgenv().ghostShooter = getgenv().createAnimationBlocker(getgenv().shotAnimIds)
        end

        if not getgenv().ghostSlasher then
            getgenv().ghostSlasher = getgenv().createAnimationBlocker(getgenv().slashAnimIds)
        end

        if not getgenv().ghostHatchetBlocker then
            getgenv().ghostHatchetBlocker = getgenv().createAnimationBlocker(getgenv().hatchetAnimIds)
        end

        if not getgenv().ghostCrystalBlocker then
            getgenv().ghostCrystalBlocker = getgenv().createAnimationBlocker(getgenv().crystalAnimIds)
        end

        if not getgenv().ghostTripwireBlocker then
            getgenv().ghostTripwireBlocker = getgenv().createAnimationBlocker(getgenv().tripwireAnimIds)
        end

        if not getgenv().ghostTripmineBlocker then
            getgenv().ghostTripmineBlocker = getgenv().createAnimationBlocker(getgenv().tripmineAnimIds)
        end
    end
local function fn29(arg)
        fn28()

        for i, v21 in ipairs({
            getgenv().ghostStabber,
            getgenv().ghostCrouchStabber,
            getgenv().ghostShooter,
            getgenv().ghostSlasher,
            getgenv().ghostHatchetBlocker,
            getgenv().ghostCrystalBlocker,
            getgenv().ghostTripwireBlocker,
            getgenv().ghostTripmineBlocker,
        }) do
            if v21 then
                if arg then
                    v21:Enable()
                else
                    v21:Disable()
                end
            end
        end
    end
Rage:AddCheckbox(fn(), {
        Text = "Ghost Abilities",
        Default = false,
        Callback = function(arg)
            fn29(arg)
        end,
    })
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local localPlayer9 = game:GetService("Players").LocalPlayer
if not getgenv().SkateFarm or not getgenv().SkateFarm.Initialized then
        getgenv().SkateFarm = {
            Enabled = false,
            LoopThread = nil,
            OldNamecall = nil,
            Connections = {},
            Initialized = true,
        }
    end
getgenv().SkateFarm.Cleanup = function()
        if getgenv().SkateFarm.LoopThread then
            pcall(task.cancel, getgenv().SkateFarm.LoopThread)
            getgenv().SkateFarm.LoopThread = nil
        end

        if getgenv().SkateFarm.OldNamecall then
            pcall(hookmetamethod, game, "__namecall", getgenv().SkateFarm.OldNamecall)
            getgenv().SkateFarm.OldNamecall = nil
        end

        for i, connection9 in ipairs(getgenv().SkateFarm.Connections) do
            pcall(function()
                connection9:Disconnect()
            end)
        end

        getgenv().SkateFarm.Connections = {}
    end
getgenv().SkateFarm.Start = function()
        if getgenv().SkateFarm.Enabled then
            return
        end
        getgenv().SkateFarm.Enabled = true
        getgenv().SkateFarm.Cleanup()

        getgenv().SkateFarm.OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(arg, ...)
            if not checkcaller() and arg.Name == "RemoteEvent" and arg.Parent and arg.Parent.Name == "Network" and arg.Parent.Parent and arg.Parent.Parent.Name == "Network" and arg.Parent.Parent.Parent and arg.Parent.Parent.Parent.Name == "Modules" and getnamecallmethod() == "FireServer" then
                local tbl7 = {...}
                if typeof(tbl7[1]) == "string" and tbl7[1]:match("StopSkate$") then
                    return
                end
            end

            return getgenv().SkateFarm.OldNamecall(arg, ...)
        end))

        local character2 = localPlayer9.Character
        local result2 = character2 or localPlayer9.CharacterAdded:Wait()

        repeat
            task.wait()
        until result2.Parent and result2:FindFirstChild("Skateboard") and result2.Skateboard.Transparency == 0

        result2.Skateboard.Transparency = 1

        if result2.PrimaryPart then
            result2.PrimaryPart.Anchored = true
        end

        repeat
            task.wait()
        until result2.Parent and result2:FindFirstChild("SpeedMultipliers") and not result2.SpeedMultipliers:FindFirstChild("Sk8")

        if result2.PrimaryPart then
            result2.PrimaryPart.Anchored = false
        end

        getgenv().SkateFarm.LoopThread = task.spawn(function()
            while getgenv().SkateFarm.Enabled and result2.Parent do
                pcall(function()
                    ReplicatedStorage5.Modules.Network.Network.RemoteEvent:FireServer(localPlayer9.Name .. "SkateTrick", {})
                end)

                task.wait(0.06)
            end
        end)
    end
getgenv().SkateFarm.Stop = function()
        getgenv().SkateFarm.Enabled = false
        getgenv().SkateFarm.Cleanup()
    end
Rage:AddCheckbox(fn(), {
        Text = "Sk8 Farm",
        Default = false,
        Callback = function(arg)
            if arg then
                getgenv().SkateFarm.Start()
            else
                getgenv().SkateFarm.Stop()
            end
        end,
    })
if not getgenv().SkateFarm.CharacterConn then
        getgenv().SkateFarm.CharacterConn = localPlayer9.CharacterAdded:Connect(function(character2)
            task.delay(1.5, function()
                if getgenv().SkateFarm.Enabled then
                    pcall(function()
                        local skateboard = character2:WaitForChild("Skateboard", 6)

                        if skateboard then
                            skateboard.Transparency = 1
                        end

                        if character2.PrimaryPart then
                            character2.PrimaryPart.Anchored = false
                        end
                    end)
                end
            end)
        end)

        table.insert(getgenv().SkateFarm.Connections, getgenv().SkateFarm.CharacterConn)
    end
Rage:AddCheckbox(fn(), {
        Text = "NOS KILL ALL FARM",
        Default = false,
        Risky = true,
        Disabled = true,
        DisabledTooltip = "Patched (For Now)",
        Callback = function() end,
    })
getgenv().BloxySpeed = {Enabled = false, Level = 2, Cooldown = 3}
getgenv().BloxyPlayers = game:GetService("Players")
getgenv().BloxyRS = game:GetService("ReplicatedStorage")
getgenv().BloxyRunService = game:GetService("RunService")
getgenv().BloxyLocalPlayer = getgenv().BloxyPlayers.LocalPlayer
getgenv().BloxyAnimId = "rbxassetid://102123566838185"
getgenv().BloxyStatuses = getgenv().BloxyRS.Modules.Gameplay.Statuses
getgenv().BloxyStatusContainer = getgenv().BloxyStatuses.StatusContainer
getgenv().BloxyStatusDisplay = getgenv().BloxyStatuses.StatusDisplay
getgenv().BloxySchematics = getgenv().BloxyRS.Modules.Schematics
getgenv().BloxyAnimConn = nil
getgenv().BloxyHumanoid = nil
getgenv().BloxyCurrentTrack = nil
getgenv().BloxyIsBoosting = false
getgenv().BloxyIsCooldown = false
getgenv().BloxyIsWaiting = false
getgenv().BloxyRoman = {
        {1000, "M"},
        {900, "CM"},
        {500, "D"},
        {400, "CD"},
        {100, "C"},
        {90, "XC"},
        {50, "L"},
        {40, "XL"},
        {10, "X"},
        {9, "IX"},
        {5, "V"},
        {4, "IV"},
        {1, "I"},
    }
getgenv().BloxyToRoman = function(arg)
        local v21, n4, str, bloxyRoman, v22, v23, n5
        n5 = 1

        while true do
            if n5 == 1 then
                v21 = nil
                n4 = arg
                str = ""
                bloxyRoman = getgenv().BloxyRoman
                n5 = 2
            elseif n5 == 2 then
                v22, v23 = bloxyRoman(nil, v21)

                if v22 == nil then
                    n5 = 6
                else
                    n5 = 3
                end
            elseif n5 == 3 then
                v21 = v22
                n5 = 4
            elseif n5 == 4 then
                if v23[1] <= n4 then
                    n5 = 5
                else
                    n5 = 2
                end
            elseif n5 == 5 then
                str = str .. v23[2]
                n4 = n4 - v23[1]
                n5 = 4
            elseif n5 == 6 then
                return str
            end
        end
    end
getgenv().BloxyFmtTime = function(arg)
        return string.format("%02d:%02d", math.floor(arg / 60), arg % 60)
    end
getgenv().BloxyShowStatus = function(name, arg, arg2)
        local mainUI = getgenv().BloxyLocalPlayer.PlayerGui:FindFirstChild("MainUI")
        if not mainUI then
            return
        end
        local statusContainer = mainUI:FindFirstChild("StatusContainer")
        local clone2 = statusContainer or getgenv().BloxyStatusContainer:Clone()
        clone2.Parent = mainUI

        if clone2:FindFirstChild(name) then
            clone2[name]:Destroy()
        end

        local clone3 = getgenv().BloxyStatusDisplay:Clone()
        clone3.Name = name
        clone3.Title.Text = name .. " " .. getgenv().BloxyToRoman(arg)
        clone3.Timer.Text = getgenv().BloxyFmtTime(arg2)
        clone3.Visible = true
        clone3.Parent = clone2
        local n4 = tick() + arg2
        local connection9 = nil

        connection9 = getgenv().BloxyRunService.Heartbeat:Connect(function()
            if clone3 and clone3.Parent then
                local n5 = math.max(0, n4 - tick())
                clone3.Timer.Text = getgenv().BloxyFmtTime(n5)

                if n5 <= 0 then
                    clone3:Destroy()
                    connection9:Disconnect()
                end

                return
            end

            connection9:Disconnect()
        end)
    end
getgenv().BloxyClick = function()
        local mainUI = getgenv().BloxyLocalPlayer.PlayerGui:FindFirstChild("MainUI")
        if not mainUI then
            return
        end
        local backpack = mainUI:FindFirstChild("Backpack")
        if not backpack then
            return
        end
        local bloxyCola = backpack:FindFirstChild("BloxyCola")
        if not bloxyCola then
            return
        end
        local v21 = getconnections(bloxyCola.MouseButton1Click)

        if v21[1] and type(v21[1].Function) == "function" then
            pcall(v21[1].Function)
        end
    end
getgenv().BloxyReset = function()
        getgenv().BloxyIsWaiting = false
        getgenv().BloxyIsBoosting = false
        getgenv().BloxyIsCooldown = false
        getgenv().BloxyCurrentTrack = nil
    end
getgenv().BloxyOnAnim = function()
        if not getgenv().BloxyHumanoid then
            return
        end

        for k, v21 in getgenv().BloxyHumanoid:GetPlayingAnimationTracks() do
            if v21.Animation and v21.Animation.AnimationId == getgenv().BloxyAnimId then
                if v21 == getgenv().BloxyCurrentTrack then
                    return
                end
                getgenv().BloxyCurrentTrack = v21

                if not getgenv().BloxyIsBoosting and not getgenv().BloxyIsCooldown and not getgenv().BloxyIsWaiting then
                    getgenv().BloxyIsWaiting = true
                    getgenv().BloxyShowStatus("Wait!", 1, 3.4)

                    task.delay(3.4, function()
                        if not v21.IsPlaying then
                            getgenv().BloxyReset()
                            return
                        end
                        getgenv().BloxyClick()
                        getgenv().BloxyIsWaiting = false
                        getgenv().BloxyIsBoosting = true
                        local speed = getgenv().BloxySchematics:FindFirstChild("Speed")

                        if speed then
                            local module = require(speed)

                            local tbl7 = {
                                Player = getgenv().BloxyLocalPlayer,
                                Level = getgenv().BloxySpeed.Level,
                                Data = module.Data,
                            }

                            module.Applied(tbl7)
                            getgenv().BloxyShowStatus("Speed", getgenv().BloxySpeed.Level, 10)

                            task.delay(10, function()
                                module.Removed(tbl7)
                                getgenv().BloxyIsBoosting = false
                                getgenv().BloxyIsCooldown = true
                                getgenv().BloxyShowStatus("Cooldown", 1, getgenv().BloxySpeed.Cooldown)

                                task.delay(getgenv().BloxySpeed.Cooldown, function()
                                    getgenv().BloxyIsCooldown = false
                                end)
                            end)
                        end

                        task.delay(10.5, getgenv().BloxyReset)
                    end)

                    return
                end

                task.delay(1, getgenv().BloxyClick)
                return
            end
        end
    end
getgenv().BloxyStartLoop = function()
        if getgenv().BloxyAnimConn then
            getgenv().BloxyAnimConn:Disconnect()
        end

        getgenv().BloxyAnimConn = getgenv().BloxyRunService.Heartbeat:Connect(function()
            if getgenv().BloxyLocalPlayer.Character and getgenv().BloxyHumanoid and getgenv().BloxyHumanoid.Parent then
                getgenv().BloxyOnAnim()
            else
                getgenv().BloxyReset()
            end
        end)
    end
getgenv().BloxyOnCharacter = function(arg)
        getgenv().BloxyReset()
        getgenv().BloxyHumanoid = arg:WaitForChild("Humanoid", 5)

        if getgenv().BloxySpeed.Enabled then
            getgenv().BloxyStartLoop()
        end
    end
if getgenv().BloxyLocalPlayer.Character then
        getgenv().BloxyOnCharacter(getgenv().BloxyLocalPlayer.Character)
    end
getgenv().BloxyLocalPlayer.CharacterAdded:Connect(getgenv().BloxyOnCharacter)
Soft:AddCheckbox(fn(), {
        Text = "Unli Bloxy Cola",
        Default = false,
        Callback = function(enabled)
            getgenv().BloxySpeed.Enabled = enabled

            if enabled and getgenv().BloxyLocalPlayer.Character then
                getgenv().BloxyOnCharacter(getgenv().BloxyLocalPlayer.Character)
            elseif not enabled and getgenv().BloxyAnimConn then
                getgenv().BloxyAnimConn:Disconnect()
                getgenv().BloxyAnimConn = nil
                getgenv().BloxyReset()
            end
        end,
    })
Soft:AddSlider(fn(), {
        Text = "Speed Level",
        Min = 1,
        Max = 20,
        Default = 2,
        Rounding = 0,
        Callback = function(arg)
            getgenv().BloxySpeed.Level = tonumber(arg)
        end,
    })
Soft:AddSlider(fn(), {
        Text = "Cooldown",
        Min = 1,
        Max = 10,
        Default = 3,
        Rounding = 0,
        Callback = function(arg)
            getgenv().BloxySpeed.Cooldown = tonumber(arg)
        end,
    })
local v21 = Blatant:AddRightTabbox("locate-fixed")
local Hitbox = v21:AddTab("Hitbox")
local Settings7 = v21:AddTab("Settings")
local flag6 = false
local n4 = 50
local str = "Look"
local str2 = "HumanoidRootPart"
local n5 = 0
local n6 = 1
local connection9 = nil
local connection10 = nil
local RunService_3 = game:GetService("RunService")
local localPlayer10 = game:GetService("Players").LocalPlayer
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local remoteEvent2 = nil
task.spawn(function()
        remoteEvent2 = ReplicatedStorage6:WaitForChild("Modules", 10):WaitForChild("Network", 10):WaitForChild("Network", 10):WaitForChild("RemoteEvent", 10)
    end)
local tbl7 = {
        Slash = true,
        Dagger = true,
        Charge = true,
        Punch = true,
        PlasmaBeam = true,
        Shoot = true,
        Behead = true,
        GashingWound = true,
        CorruptNature = true,
        WalkspeedOverride = true,
        Stab = true,
        VoidRush = true,
        Nova = true,
        MassInfection = true,
        Entanglement = true,
        ["Carving Slash"] = true,
        Axe = true,
    }
local function fn30(arg)
        local character2 = localPlayer10.Character
        if not character2 then
            return
        end
        local humanoidRootPart3 = character2:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart3 then
            return
        end
        local assemblyLinearVelocity = humanoidRootPart3.AssemblyLinearVelocity
        local unit

        if str == "Nearest Survivor" then
            local v22 = nil
            local huge = math.huge
            local players = workspace:FindFirstChild("Players")
            local survivors = players and workspace.Players:FindFirstChild("Survivors")

            if survivors then
                for i, child in ipairs(survivors:GetChildren()) do
                    local humanoidRootPart4 = child:FindFirstChild("HumanoidRootPart")
                    local humanoid2 = child:FindFirstChildOfClass("Humanoid")

                    if humanoidRootPart4 and humanoid2 and humanoid2.Health > 0 then
                        local magnitude = (humanoidRootPart4.Position - humanoidRootPart3.Position).Magnitude

                        if magnitude < huge then
                            huge = magnitude
                            v22 = child
                        end
                    end
                end
            end

            if v22 then
                local v23 = v22:FindFirstChild(str2)
                local humanoidRootPart4 = v23 or v22:FindFirstChild("HumanoidRootPart")
                local position = humanoidRootPart4.Position
                local n7 = position

                if n5 > 0 then
                    n7 = position + humanoidRootPart4.AssemblyLinearVelocity * (n5 / 100)
                end

                unit = (n7 - humanoidRootPart3.Position).Unit
            else
                unit = humanoidRootPart3.CFrame.LookVector
            end
        else
            unit = humanoidRootPart3.CFrame.LookVector
        end

        humanoidRootPart3.AssemblyLinearVelocity = assemblyLinearVelocity + unit * (arg * n6)
        RunService_3.RenderStepped:Wait()

        if humanoidRootPart3 and humanoidRootPart3.Parent then
            humanoidRootPart3.AssemblyLinearVelocity = assemblyLinearVelocity
        end
    end
local function fn31()
        if connection9 then
            return
        end

        connection9 = remoteEvent2.OnClientEvent:Connect(function(arg, arg2)
            if not flag6 then
                return
            end

            if arg ~= "UseActorAbility" then
                return
            end

            if typeof(arg2) ~= "table" or not arg2[1] then
                return
            end
            local str3

            if typeof(arg2[1]) == "buffer" then
                str3 = buffer.tostring(arg2[1]):sub(6):gsub("%z", "")
            else
                str3 = tostring(arg2[1]):gsub("\"", "")
            end

            if not tbl7[str3] then
                return
            end

            if connection10 then
                connection10:Disconnect()
                connection10 = nil
            end

            local now = os.clock()

            connection10 = RunService_3.Heartbeat:Connect(function()
                if os.clock() - now >= 1.5 then
                    connection10:Disconnect()
                    connection10 = nil
                    return
                end

                fn30(n4)
            end)
        end)
    end
local function fn32()
        if connection9 then
            connection9:Disconnect()
            connection9 = nil
        end

        if connection10 then
            connection10:Disconnect()
            connection10 = nil
        end
    end
Hitbox:AddCheckbox(fn(), {
        Text = "Hitbox Expander",
        Default = false,
        Callback = function(arg)
            flag6 = arg

            if arg then
                fn31()
            else
                fn32()
            end
        end,
    })
Hitbox:AddSlider(fn(), {
        Text = "Hitbox Studs",
        Min = 0,
        Max = 500,
        Default = 50,
        Rounding = 0,
        Callback = function(arg)
            n4 = tonumber(arg)
        end,
    })
Settings7:AddDropdown(fn(), {
        Text = "Lunge Direction",
        Values = {"Look", "Nearest Survivor"},
        Default = "Look",
        Callback = function(arg)
            str = arg
        end,
    })
Settings7:AddDropdown(fn(), {
        Text = "Target Part",
        Values = {"HumanoidRootPart", "Head", "Torso"},
        Default = "HumanoidRootPart",
        Callback = function(arg)
            str2 = arg
        end,
    })
Settings7:AddSlider(fn(), {
        Text = "Hitbox Prediction",
        Min = 0,
        Max = 100,
        Default = 0,
        Rounding = 0,
        Callback = function(arg)
            n5 = tonumber(arg)
        end,
    })
Settings7:AddSlider(fn(), {
        Text = "Hitbox Strength",
        Min = 0.5,
        Max = 3,
        Default = 1,
        Rounding = 2,
        Callback = function(arg)
            n6 = tonumber(arg)
        end,
    })

end