-- SorsHub pack part 3/10
return function(P)
local RunService = game:GetService("RunService")
local lp = P.lp
local v = P["v@9466,10-9466,11"]
local fn = P["fn@9471,10-9471,12"]
local esp = P["esp@10494,10-10494,13"]
local Settings = P["Settings@10495,10-10495,18"]
local v6 = P["v6@10496,10-10496,12"]

task.spawn(function()
        local font = Font.new("rbxasset://fonts/families/Sarpanch.json", Enum.FontWeight.Bold)

        local vxEsp = {
            killersEnabled = false,
            survivorsEnabled = false,
            generatorsEnabled = false,
            itemsEnabled = false,
            colorKiller = Color3.fromRGB(255, 130, 130),
            colorSurvivor = Color3.fromRGB(150, 225, 255),
            colorGenerator = Color3.fromRGB(255, 215, 100),
            colorItem = Color3.fromRGB(210, 255, 210),
            healthConns = {},
            progressConns = {},
            chamsEnabled = true,
            tracerEnabled = false,
            boxEnabled = false,
            tracerPosition = "Bottom",
            showDistance = false,
            showName = false,
            showCharacter = true,
            showHealth = true,
            showRole = false,
            billboardsEnabled = false,
            fillTransparency = 0.8,
            textSize = 15,
            offset = 3.8,
            strokeThickness = 1.5,
        }

        local tbl4 = {
            Sarpanch = Font.new("rbxasset://fonts/families/Sarpanch.json", Enum.FontWeight.Bold),
            Arial = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Bold),
            SourceSans = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
            Gotham = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            Code = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold),
        }

        local tbl5 = {}
        local tbl6 = {}
        local tbl7 = {}

        local function fn12()
            local players = workspace:FindFirstChild("Players")
            local killers = players and players:FindFirstChild("Killers")
            return killers
        end

        local function fn13()
            local players = workspace:FindFirstChild("Players")
            local survivors = players and players:FindFirstChild("Survivors")
            return survivors
        end

        local function fn14()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and map:FindFirstChild("Ingame")
            local map2 = ingame and ingame:FindFirstChild("Map")
            return map2
        end

        local function fn15(adornee, name, fillColor, arg)
            local localPlayer4 = game:GetService("Players").LocalPlayer
            if not adornee or adornee == localPlayer4.Character or adornee.Name == localPlayer4.Name then
                return
            end

            if adornee:FindFirstChild(name) then
                return
            end
            local humanoidRootPart2 = adornee:FindFirstChild("HumanoidRootPart")
            local primaryPart = humanoidRootPart2 or adornee.PrimaryPart or adornee:FindFirstChildWhichIsA("BasePart")
            if not primaryPart then
                return
            end
            local str = name == "VX_ESP_Killer" and "Killer" or name == "VX_ESP_Survivor" and "Survivor" or nil

            pcall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = name
                highlight.FillColor = fillColor
                highlight.OutlineColor = fillColor
                highlight.FillTransparency = vxEsp.fillTransparency
                highlight.OutlineTransparency = 0.6
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = adornee
                highlight.Enabled = vxEsp.chamsEnabled
                highlight.Parent = adornee
                tbl6[highlight] = true
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = name .. "_Label"
                billboardGui.Adornee = primaryPart
                billboardGui.Size = UDim2.new(0, 220, 0, 60)
                billboardGui.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                billboardGui.AlwaysOnTop = true
                billboardGui.MaxDistance = math.huge
                billboardGui.Enabled = vxEsp.billboardsEnabled
                billboardGui.Parent = adornee
                tbl7[billboardGui] = true
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = fillColor
                textLabel.TextStrokeTransparency = 0.35
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.TextScaled = false
                textLabel.TextSize = vxEsp.textSize
                textLabel.FontFace = font
                textLabel.Parent = billboardGui
                tbl5[textLabel] = true

                local function fn16()
                    local tbl8 = {}

                    if vxEsp.showCharacter then
                        table.insert(tbl8, adornee.Name)
                    end

                    if vxEsp.showName then
                        local playerFromCharacter = game.Players:GetPlayerFromCharacter(adornee)

                        if playerFromCharacter then
                            table.insert(tbl8, playerFromCharacter.Name)
                        end
                    end

                    if vxEsp.showRole and str then
                        table.insert(tbl8, str)
                    end

                    if vxEsp.showHealth and arg then
                        local humanoid = adornee:FindFirstChildOfClass("Humanoid")

                        if humanoid and humanoid.MaxHealth > 0 then
                            table.insert(tbl8, math.floor(humanoid.Health / humanoid.MaxHealth * 100) .. "%")
                        end
                    end

                    if vxEsp.showDistance then
                        local character2 = game.Players.LocalPlayer.Character
                        local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart3 then
                            table.insert(tbl8, math.floor((primaryPart.Position - humanoidRootPart3.Position).Magnitude) .. "m")
                        end
                    end

                    local progress = adornee:FindFirstChild("Progress")

                    if progress then
                        local n3 = math.floor(progress.Value)
                        table.insert(tbl8, "Gen: " .. n3 .. "%")
                        local color = n3 >= 100 and Color3.fromRGB(0, 255, 0) or vxEsp.colorGenerator
                        local vxEspGenerator = adornee:FindFirstChild("VX_ESP_Generator")

                        if vxEspGenerator then
                            vxEspGenerator.FillColor = color
                            vxEspGenerator.OutlineColor = color
                        end

                        if textLabel.Parent then
                            textLabel.TextColor3 = color
                        end
                    end

                    if textLabel.Parent then
                        textLabel.Text = table.concat(tbl8, "  |  ")
                    end
                end

                fn16()

                task.spawn(function()
                    while adornee and adornee.Parent and adornee:FindFirstChild(name .. "_Label") and textLabel.Parent do
                        fn16()
                        task.wait(0.4)
                    end
                end)

                if arg then
                    local humanoid = adornee:FindFirstChildOfClass("Humanoid")

                    if humanoid then
                        vxEsp.healthConns[adornee] = humanoid.HealthChanged:Connect(fn16)
                    end
                end

                local progress = adornee:FindFirstChild("Progress")

                if progress then
                    vxEsp.progressConns[adornee] = progress.Changed:Connect(fn16)
                end
            end)
        end

        local function fn16(arg, arg2)
            if not arg then
                return
            end

            pcall(function()
                local v7 = arg:FindFirstChild(arg2)

                if v7 then
                    tbl6[v7] = nil
                    v7:Destroy()
                end

                local v8 = arg:FindFirstChild(arg2 .. "_Label")

                if v8 then
                    local textLabel = v8:FindFirstChildOfClass("TextLabel")

                    if textLabel then
                        tbl5[textLabel] = nil
                    end

                    tbl7[v8] = nil
                    v8:Destroy()
                end

                if vxEsp.healthConns[arg] then
                    vxEsp.healthConns[arg]:Disconnect()
                    vxEsp.healthConns[arg] = nil
                end

                if vxEsp.progressConns[arg] then
                    vxEsp.progressConns[arg]:Disconnect()
                    vxEsp.progressConns[arg] = nil
                end
            end)
        end

        local function fn17()
            local v7 = fn12()

            if v7 then
                for i, child in ipairs(v7:GetChildren()) do
                    fn16(child, "VX_ESP_Killer")

                    if vxEsp.killersEnabled then
                        fn15(child, "VX_ESP_Killer", vxEsp.colorKiller, true)
                    end
                end
            end

            local v8 = fn13()

            if v8 then
                for i, child in ipairs(v8:GetChildren()) do
                    fn16(child, "VX_ESP_Survivor")

                    if vxEsp.survivorsEnabled then
                        fn15(child, "VX_ESP_Survivor", vxEsp.colorSurvivor, true)
                    end
                end
            end

            local v9 = fn14()

            if v9 then
                for i, child in ipairs(v9:GetChildren()) do
                    if child.Name == "Generator" then
                        fn16(child, "VX_ESP_Generator")

                        if vxEsp.generatorsEnabled then
                            fn15(child, "VX_ESP_Generator", vxEsp.colorGenerator, false)
                        end
                    elseif child.Name == "BloxyCola" or child.Name == "Medkit" then
                        fn16(child, "VX_ESP_Item")

                        if vxEsp.itemsEnabled then
                            fn15(child, "VX_ESP_Item", vxEsp.colorItem, false)
                        end
                    end
                end
            end
        end

        local tbl8 = {}

        local function fn18(arg)
            if not tbl8[arg] then
                local ok, result2 = pcall(function()
                    local line = Drawing.new("Line")
                    line.Thickness = vxEsp.strokeThickness
                    line.Visible = false
                    return line
                end)

                local ok2, result3 = pcall(function()
                    local square = Drawing.new("Square")
                    square.Thickness = vxEsp.strokeThickness
                    square.Filled = false
                    square.Visible = false
                    return square
                end)

                local tbl9 = {}
                local v7 = ok and result2 or nil
                tbl9.tracer = v7
                local v8 = ok2 and result3 or nil
                tbl9.box = v8
                tbl8[arg] = tbl9
            end

            return tbl8[arg]
        end

        local function fn19(arg)
            local v7 = tbl8[arg]

            if v7 then
                pcall(function()
                    if v7.tracer then
                        v7.tracer:Remove()
                    end
                end)

                pcall(function()
                    if v7.box then
                        v7.box:Remove()
                    end
                end)

                tbl8[arg] = nil
            end
        end

        game:GetService("RunService").RenderStepped:Connect(function()
            if not vxEsp.tracerEnabled and not vxEsp.boxEnabled then
                for k in pairs(tbl8) do
                    fn19(k)
                end

                return
            end

            local currentCamera = workspace.CurrentCamera
            if not currentCamera then
                return
            end
            local tbl9 = {}

            local function fn20(arg, arg2, color)
                if not arg then
                    return
                end

                for i, child in ipairs(arg:GetChildren()) do
                    if child:FindFirstChild(arg2) then
                        local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart2 then
                            tbl9[child] = true
                            local v7 = fn18(child)
                            local v8, v9 = currentCamera:WorldToViewportPoint(humanoidRootPart2.Position)

                            if v9 then
                                if v7.tracer then
                                    v7.tracer.Visible = vxEsp.tracerEnabled
                                    v7.tracer.Color = color
                                    local tracer = v7.tracer
                                    local vector2 = Vector2.new
                                    local n3 = currentCamera.ViewportSize.X / 2
                                    local y = vxEsp.tracerPosition == "Top" and 0 or currentCamera.ViewportSize.Y
                                    tracer.From = vector2(n3, y)
                                    v7.tracer.To = Vector2.new(v8.X, v8.Y)
                                end

                                if v7.box then
                                    local v10 = currentCamera:WorldToViewportPoint(humanoidRootPart2.Position + Vector3.new(0, 3, 0))
                                    local n3 = math.abs(v8.Y - v10.Y) * 2
                                    local n4 = n3 * 0.6
                                    v7.box.Visible = vxEsp.boxEnabled
                                    v7.box.Color = color
                                    v7.box.Size = Vector2.new(n4, n3)
                                    v7.box.Position = Vector2.new(v8.X - n4 / 2, v8.Y - n3 / 1.4)
                                end
                            else
                                if v7.tracer then
                                    v7.tracer.Visible = false
                                end

                                if v7.box then
                                    v7.box.Visible = false
                                end
                            end
                        end
                    end
                end
            end

            fn20(fn12(), "VX_ESP_Killer", vxEsp.colorKiller)
            fn20(fn13(), "VX_ESP_Survivor", vxEsp.colorSurvivor)

            for k in pairs(tbl8) do
                if not tbl9[k] then
                    fn19(k)
                end
            end
        end)

        task.spawn(function()
            local v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26
            local v27, n3
            n3 = 1

            while true do
                if n3 == 1 then
                    task.wait(0.3)
                    v7 = fn12()

                    if v7 then
                        n3 = 2
                    else
                        n3 = 8
                    end
                elseif n3 == 2 then
                    v8, v9, v10 = ipairs(v7:GetChildren())
                    v11 = v10
                    n3 = 3
                elseif n3 == 3 then
                    v12, v13 = v8(v9, v11)

                    if v12 == nil then
                        n3 = 8
                    else
                        n3 = 4
                    end
                elseif n3 == 4 then
                    v11 = v12

                    if vxEsp.killersEnabled then
                        n3 = 5
                    else
                        n3 = 7
                    end
                elseif n3 == 5 then
                    if v13:FindFirstChild("VX_ESP_Killer") then
                        n3 = 3
                    else
                        n3 = 6
                    end
                elseif n3 == 6 then
                    fn15(v13, "VX_ESP_Killer", vxEsp.colorKiller, true)
                    n3 = 3
                elseif n3 == 7 then
                    fn16(v13, "VX_ESP_Killer")
                    n3 = 3
                elseif n3 == 8 then
                    v14 = fn13()

                    if v14 then
                        n3 = 9
                    else
                        n3 = 15
                    end
                elseif n3 == 9 then
                    v15, v16, v17 = ipairs(v14:GetChildren())
                    v18 = v17
                    n3 = 10
                elseif n3 == 10 then
                    v19, v20 = v15(v16, v18)

                    if v19 == nil then
                        n3 = 15
                    else
                        n3 = 11
                    end
                elseif n3 == 11 then
                    v18 = v19

                    if vxEsp.survivorsEnabled then
                        n3 = 12
                    else
                        n3 = 14
                    end
                elseif n3 == 12 then
                    if v20:FindFirstChild("VX_ESP_Survivor") then
                        n3 = 10
                    else
                        n3 = 13
                    end
                elseif n3 == 13 then
                    fn15(v20, "VX_ESP_Survivor", vxEsp.colorSurvivor, true)
                    n3 = 10
                elseif n3 == 14 then
                    fn16(v20, "VX_ESP_Survivor")
                    n3 = 10
                elseif n3 == 15 then
                    v21 = fn14()

                    if v21 then
                        n3 = 16
                    else
                        n3 = 1
                    end
                elseif n3 == 16 then
                    v22, v23, v24 = ipairs(v21:GetChildren())
                    v25 = v24
                    n3 = 17
                elseif n3 == 17 then
                    v26, v27 = v22(v23, v25)

                    if v26 == nil then
                        n3 = 1
                    else
                        n3 = 18
                    end
                elseif n3 == 18 then
                    v25 = v26

                    if v27.Name == "Generator" then
                        n3 = 24
                    else
                        n3 = 19
                    end
                elseif n3 == 19 then
                    if v27.Name ~= "BloxyCola" and v27.Name ~= "Medkit" then
                        n3 = 17
                    else
                        n3 = 20
                    end
                elseif n3 == 20 then
                    if vxEsp.itemsEnabled then
                        n3 = 21
                    else
                        n3 = 23
                    end
                elseif n3 == 21 then
                    if v27:FindFirstChild("VX_ESP_Item") then
                        n3 = 17
                    else
                        n3 = 22
                    end
                elseif n3 == 22 then
                    fn15(v27, "VX_ESP_Item", vxEsp.colorItem, false)
                    n3 = 17
                elseif n3 == 23 then
                    fn16(v27, "VX_ESP_Item")
                    n3 = 17
                elseif n3 == 24 then
                    if vxEsp.generatorsEnabled then
                        n3 = 25
                    else
                        n3 = 27
                    end
                elseif n3 == 25 then
                    if v27:FindFirstChild("VX_ESP_Generator") then
                        n3 = 17
                    else
                        n3 = 26
                    end
                elseif n3 == 26 then
                    fn15(v27, "VX_ESP_Generator", vxEsp.colorGenerator, false)
                    n3 = 17
                elseif n3 == 27 then
                    fn16(v27, "VX_ESP_Generator")
                    n3 = 17
                end
            end
        end)

        esp:AddCheckbox(fn(), {
            Text = "ESP Killers",
            Default = false,
            Callback = function(killersEnabled)
                vxEsp.killersEnabled = killersEnabled
                fn17()

                if getgenv().VX_DeviceESP_UpdateOffset then
                    getgenv().VX_DeviceESP_UpdateOffset()
                end
            end,
        }):AddColorPicker(fn(), {
            Default = vxEsp.colorKiller,
            Title = "Killer Color",
            Callback = function(colorKiller)
                vxEsp.colorKiller = colorKiller
                fn17()
            end,
        })

        esp:AddCheckbox(fn(), {
            Text = "ESP Survivors",
            Default = false,
            Callback = function(survivorsEnabled)
                vxEsp.survivorsEnabled = survivorsEnabled
                fn17()

                if getgenv().VX_DeviceESP_UpdateOffset then
                    getgenv().VX_DeviceESP_UpdateOffset()
                end
            end,
        }):AddColorPicker(fn(), {
            Default = vxEsp.colorSurvivor,
            Title = "Survivor Color",
            Callback = function(colorSurvivor)
                vxEsp.colorSurvivor = colorSurvivor
                fn17()
            end,
        })

        esp:AddCheckbox(fn(), {
            Text = "ESP Generators",
            Default = false,
            Callback = function(generatorsEnabled)
                vxEsp.generatorsEnabled = generatorsEnabled
                fn17()
            end,
        }):AddColorPicker(fn(), {
            Default = vxEsp.colorGenerator,
            Title = "Generator Color",
            Callback = function(colorGenerator)
                vxEsp.colorGenerator = colorGenerator
                fn17()
            end,
        })

        esp:AddCheckbox(fn(), {
            Text = "ESP Items",
            Default = false,
            Callback = function(itemsEnabled)
                vxEsp.itemsEnabled = itemsEnabled
                fn17()
            end,
        }):AddColorPicker(fn(), {
            Default = vxEsp.colorItem,
            Title = "Item Color",
            Callback = function(colorItem)
                vxEsp.colorItem = colorItem
                fn17()
            end,
        })

        getgenv().GraffitiEspEnabled = false
        getgenv().GraffitiEspHighlights = {}
        getgenv().GraffitiEspLabels = {}
        getgenv().GraffitiEspColor = Color3.fromRGB(255, 230, 100)

        getgenv().UpdateGraffitiEsp = function()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and workspace.Map:FindFirstChild("Ingame")
            local tbl9 = {}

            if ingame then
                for i, child in ipairs(ingame:GetChildren()) do
                    if child.Name:match("Spray$") then
                        tbl9[child] = child.Name:gsub("Spray$", "") .. "'s Graffiti"
                    end
                end
            end

            for k, graffitiEspHighlight in pairs(getgenv().GraffitiEspHighlights) do
                if not tbl9[k] or not getgenv().GraffitiEspEnabled then
                    pcall(function()
                        graffitiEspHighlight:Destroy()
                    end)

                    getgenv().GraffitiEspHighlights[k] = nil

                    if getgenv().GraffitiEspLabels[k] then
                        pcall(function()
                            getgenv().GraffitiEspLabels[k]:Destroy()
                        end)

                        getgenv().GraffitiEspLabels[k] = nil
                    end
                end
            end

            if not getgenv().GraffitiEspEnabled then
                return
            end

            for k, v7 in pairs(tbl9) do
                if not getgenv().GraffitiEspHighlights[k] or not getgenv().GraffitiEspHighlights[k].Parent then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = getgenv().GraffitiEspColor
                    highlight.OutlineColor = getgenv().GraffitiEspColor
                    highlight.FillTransparency = 0.8
                    highlight.OutlineTransparency = 0.6
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Adornee = k
                    highlight.Parent = workspace
                    getgenv().GraffitiEspHighlights[k] = highlight
                end

                if getgenv().GraffitiEspLabels[k] then
                    pcall(function()
                        getgenv().GraffitiEspLabels[k]:Destroy()
                    end)

                    getgenv().GraffitiEspLabels[k] = nil
                end

                local isBasePart = k:IsA("BasePart")
                local primaryPart = isBasePart and k or k.PrimaryPart or k:FindFirstChildWhichIsA("BasePart")

                if primaryPart then
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Adornee = primaryPart
                    billboardGui.Size = UDim2.new(0, 220, 0, 60)
                    billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3.8, 0)
                    billboardGui.AlwaysOnTop = true
                    billboardGui.MaxDistance = math.huge
                    billboardGui.Parent = k
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = getgenv().GraffitiEspColor
                    textLabel.TextStrokeTransparency = 0.35
                    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    textLabel.TextScaled = false
                    textLabel.TextSize = 15
                    textLabel.FontFace = font
                    textLabel.Text = v7
                    textLabel.Parent = billboardGui
                    getgenv().GraffitiEspLabels[k] = billboardGui
                end
            end
        end

        task.spawn(function()
            while true do
                task.wait(1)
                getgenv().UpdateGraffitiEsp()
            end
        end)

        esp:AddCheckbox(fn(), {
            Text = "ESP Graffiti",
            Default = false,
            Callback = function(graffitiEspEnabled)
                getgenv().GraffitiEspEnabled = graffitiEspEnabled
                getgenv().UpdateGraffitiEsp()
            end,
        }):AddColorPicker(fn(), {
            Default = getgenv().GraffitiEspColor,
            Title = "Graffiti Color",
            Callback = function(graffitiEspColor)
                getgenv().GraffitiEspColor = graffitiEspColor

                for k, graffitiEspHighlight in pairs(getgenv().GraffitiEspHighlights) do
                    graffitiEspHighlight.FillColor = graffitiEspColor
                    graffitiEspHighlight.OutlineColor = graffitiEspColor
                end

                for k, graffitiEspLabel in pairs(getgenv().GraffitiEspLabels) do
                    local textLabel = graffitiEspLabel:FindFirstChildOfClass("TextLabel")

                    if textLabel then
                        textLabel.TextColor3 = graffitiEspColor
                    end
                end
            end,
        })

        getgenv().JDQ_FolderESPEnabled = false
        getgenv().JDQ_FolderHighlights = {}
        getgenv().JDQ_ESPConn = nil
        getgenv().JDQ_FolderColor = Color3.fromRGB(100, 210, 255)

        getgenv().JDQ_AddFolderESP = function(adornee)
            if getgenv().JDQ_FolderHighlights[adornee] then
                return
            end
            local highlight = Instance.new("Highlight")
            highlight.Adornee = adornee
            highlight.FillColor = getgenv().JDQ_FolderColor
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = adornee
            getgenv().JDQ_FolderHighlights[adornee] = highlight
        end

        getgenv().JDQ_RemoveFolderESP = function(arg)
            if getgenv().JDQ_FolderHighlights[arg] then
                pcall(function()
                    getgenv().JDQ_FolderHighlights[arg]:Destroy()
                end)

                getgenv().JDQ_FolderHighlights[arg] = nil
            end
        end

        local v7 = esp:AddCheckbox(fn(), {
            Text = "ESP Folders",
            Default = false,
            Callback = function(jdqFolderESPEnabled)
                getgenv().JDQ_FolderESPEnabled = jdqFolderESPEnabled

                if jdqFolderESPEnabled then
                    for k, child in pairs(workspace:GetChildren()) do
                        if child.Name == "Model" then
                            getgenv().JDQ_AddFolderESP(child)
                        end
                    end

                    getgenv().JDQ_ESPConn = workspace.ChildAdded:Connect(function(child)
                        if child.Name == "Model" and getgenv().JDQ_FolderESPEnabled then
                            getgenv().JDQ_AddFolderESP(child)
                        end
                    end)
                else
                    for k in pairs(getgenv().JDQ_FolderHighlights) do
                        getgenv().JDQ_RemoveFolderESP(k)
                    end

                    if getgenv().JDQ_ESPConn then
                        getgenv().JDQ_ESPConn:Disconnect()
                        getgenv().JDQ_ESPConn = nil
                    end
                end
            end,
        })

        local addColorPicker = v7.AddColorPicker
        local v8 = fn()
        local tbl9 = {}
        local jdqFolderColor = getgenv().JDQ_FolderColor
        local color = jdqFolderColor or Color3.fromRGB(0, 170, 255)
        tbl9.Default = color
        tbl9.Title = "Folder Color"

        tbl9.Callback = function(jdqFolderColor2)
            getgenv().JDQ_FolderColor = jdqFolderColor2

            for k, jdqFolderHighlight in pairs(getgenv().JDQ_FolderHighlights) do
                jdqFolderHighlight.FillColor = jdqFolderColor2
            end
        end

        addColorPicker(v7, v8, tbl9)

        local function fn20(arg)
            local flag3 = arg == "GroundBulbModel" or arg == "VineModel"
            return flag3
        end

        local flag3 = false
        local color2 = Color3.fromRGB(100, 255, 100)
        local tbl10 = {}
        local tbl11 = {}
        local tbl12 = {}
        local connection2 = nil

        local function fn21(adornee)
            if not adornee or tbl10[adornee] then
                return
            end
            local primaryPart = adornee.PrimaryPart
            local basePart = primaryPart or adornee:FindFirstChildWhichIsA("BasePart")
            if not basePart then
                return
            end

            if tbl12[basePart] then
                return
            end

            pcall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "VX_ESP_Plant"
                highlight.FillColor = color2
                highlight.OutlineColor = color2
                highlight.FillTransparency = vxEsp.fillTransparency
                highlight.OutlineTransparency = 0.6
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = adornee
                highlight.Parent = adornee
                tbl10[adornee] = highlight
                tbl12[basePart] = adornee
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "VX_ESP_Plant_Label"
                billboardGui.Adornee = basePart
                billboardGui.Size = UDim2.new(0, 220, 0, 60)
                billboardGui.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                billboardGui.AlwaysOnTop = true
                billboardGui.MaxDistance = math.huge
                billboardGui.Parent = adornee
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = color2
                textLabel.TextStrokeTransparency = 0.35
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.TextScaled = false
                textLabel.TextSize = vxEsp.textSize
                textLabel.FontFace = font
                local text = adornee.Name == "VineModel" and "Vine" or "Bulb"
                textLabel.Text = text
                textLabel.Parent = billboardGui
                tbl11[adornee] = {bg = billboardGui, lbl = textLabel, root = basePart}
            end)
        end

        local function fn22(arg)
            if not arg then
                return
            end
            local v9 = tbl11[arg]

            if v9 and v9.root and tbl12[v9.root] == arg then
                tbl12[v9.root] = nil
            end

            pcall(function()
                local vxEspPlant = arg:FindFirstChild("VX_ESP_Plant")

                if vxEspPlant then
                    vxEspPlant:Destroy()
                end

                local vxEspPlantLabel = arg:FindFirstChild("VX_ESP_Plant_Label")

                if vxEspPlantLabel then
                    vxEspPlantLabel:Destroy()
                end
            end)

            tbl10[arg] = nil
            tbl11[arg] = nil
        end

        local function fn23()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and workspace.Map:FindFirstChild("Ingame")
            if not ingame then
                return
            end

            for i, child in ipairs(ingame:GetChildren()) do
                if fn20(child.Name) then
                    if flag3 then
                        if not tbl10[child] then
                            fn21(child)
                        end
                    else
                        fn22(child)
                    end
                end
            end
        end

        local function fn24()
            for k, v9 in pairs(tbl10) do
                if v9 and v9.Parent then
                    v9.FillColor = color2
                    v9.OutlineColor = color2
                    v9.FillTransparency = vxEsp.fillTransparency
                end
            end

            for k, v9 in pairs(tbl11) do
                if v9.lbl and v9.lbl.Parent then
                    v9.lbl.TextColor3 = color2
                    v9.lbl.TextSize = vxEsp.textSize
                    v9.lbl.FontFace = font
                end

                if v9.bg and v9.bg.Parent then
                    v9.bg.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                end
            end
        end

        task.spawn(function()
            while true do
                task.wait(0.5)

                if flag3 then
                    fn23()
                end

                if flag3 then
                    fn24()
                end
            end
        end)

        esp:AddCheckbox(fn(), {
            Text = "ESP Plants",
            Default = false,
            Callback = function(arg)
                flag3 = arg

                if arg then
                    fn23()
                else
                    for k in pairs(tbl10) do
                        fn22(k)
                    end

                    table.clear(tbl12)
                end

                if connection2 then
                    connection2:Disconnect()
                    connection2 = nil
                end

                if arg then
                    local map = workspace:FindFirstChild("Map")
                    local ingame = map and workspace.Map:FindFirstChild("Ingame")

                    if ingame then
                        connection2 = ingame.ChildAdded:Connect(function(child)
                            if fn20(child.Name) and flag3 then
                                task.wait(0.1)
                                fn21(child)
                            end
                        end)
                    end
                end
            end,
        }):AddColorPicker(fn(), {
            Default = color2,
            Title = "Plant Color",
            Callback = function(arg)
                color2 = arg
                fn24()
            end,
        })

        local flag4 = false
        local color3 = Color3.fromRGB(100, 180, 255)
        local tbl13 = {}
        local tbl14 = {}

        local tbl15 = {
            {
                parent = function()
                    local map = workspace:FindFirstChild("Map")
                    local map2 = map and workspace.Map
                    return map2
                end,
                name = "Azure",
                label = "Azure Body",
            },
            {
                parent = function()
                    local map = workspace:FindFirstChild("Map")
                    local ingame = map and workspace.Map:FindFirstChild("Ingame")
                    return ingame
                end,
                name = "MisterBeast",
                label = "Golem",
            },
        }

        local function fn25(adornee, text)
            if not adornee or tbl13[adornee] then
                return
            end
            local primaryPart = adornee.PrimaryPart
            local basePart = primaryPart or adornee:FindFirstChildWhichIsA("BasePart")
            if not basePart then
                return
            end
            local highlight = Instance.new("Highlight")
            highlight.Name = "VX_ESP_GolemAzure"
            highlight.FillColor = color3
            highlight.OutlineColor = color3
            highlight.FillTransparency = vxEsp.fillTransparency
            highlight.OutlineTransparency = 0.6
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = adornee
            highlight.Parent = adornee
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "VX_ESP_GolemAzure_Label"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(0, 150, 0, 20)
            billboardGui.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
            billboardGui.Adornee = basePart
            billboardGui.Parent = adornee
            local textLabel = Instance.new("TextLabel")
            textLabel.BackgroundTransparency = 1
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = text
            textLabel.TextColor3 = color3
            textLabel.TextStrokeTransparency = 0.35
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            textLabel.TextSize = vxEsp.textSize
            textLabel.FontFace = font
            textLabel.Parent = billboardGui
            tbl13[adornee] = highlight
            tbl14[adornee] = {bg = billboardGui, lbl = textLabel}
        end

        local function fn26(arg)
            local v9 = tbl13[arg]

            if v9 then
                pcall(function()
                    v9:Destroy()
                end)
            end

            local v10 = tbl14[arg]

            if v10 and v10.bg then
                pcall(function()
                    v10.bg:Destroy()
                end)
            end

            tbl13[arg] = nil
            tbl14[arg] = nil
        end

        local function fn27()
            for i, v9 in ipairs(tbl15) do
                local v10 = v9.parent()

                if v10 then
                    local v11 = v10:FindFirstChild(v9.name)

                    if v11 then
                        if flag4 then
                            if not tbl13[v11] then
                                fn25(v11, v9.label)
                            end
                        else
                            fn26(v11)
                        end
                    end
                end
            end
        end

        local function fn28()
            for k, v9 in pairs(tbl13) do
                if v9 and v9.Parent then
                    v9.FillColor = color3
                    v9.OutlineColor = color3
                    v9.FillTransparency = vxEsp.fillTransparency
                end
            end

            for k, v9 in pairs(tbl14) do
                if v9.lbl and v9.lbl.Parent then
                    v9.lbl.TextColor3 = color3
                    v9.lbl.TextSize = vxEsp.textSize
                    v9.lbl.FontFace = font
                end

                if v9.bg and v9.bg.Parent then
                    v9.bg.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                end
            end
        end

        task.spawn(function()
            while true do
                task.wait(0.5)

                if flag4 then
                    fn27()
                    fn28()
                end
            end
        end)

        esp:AddCheckbox(fn(), {
            Text = "ESP Golem & Azure Body",
            Default = false,
            Callback = function(arg)
                flag4 = arg

                if arg then
                    fn27()
                else
                    for k in pairs(tbl13) do
                        fn26(k)
                    end
                end
            end,
        }):AddColorPicker(fn(), {
            Default = color3,
            Title = "Golem & Azure Body Color",
            Callback = function(arg)
                color3 = arg
                fn28()
            end,
        })

        local flag5 = false
        local color4 = Color3.fromRGB(255, 80, 80)
        local tbl16 = {}
        local tbl17 = {}
        local connection3 = nil

        local tbl18 = {
            BuildermanSentry = "Sentry",
            BuildermanDispenser = "Dispenser",
        }

        local function fn29(adornee)
            if not adornee or tbl16[adornee] then
                return
            end
            local primaryPart = adornee.PrimaryPart
            local basePart = primaryPart or adornee:FindFirstChildWhichIsA("BasePart")
            if not basePart then
                return
            end
            local highlight = Instance.new("Highlight")
            highlight.Name = "VX_ESP_SentryDisp"
            highlight.FillColor = color4
            highlight.OutlineColor = color4
            highlight.FillTransparency = vxEsp.fillTransparency
            highlight.OutlineTransparency = 0.6
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = adornee
            highlight.Parent = adornee
            local v9 = tbl18[adornee.Name]
            local name = v9 or adornee.Name
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "VX_ESP_SentryDisp_Label"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(0, 100, 0, 20)
            billboardGui.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
            billboardGui.Adornee = basePart
            billboardGui.Parent = adornee
            local textLabel = Instance.new("TextLabel")
            textLabel.BackgroundTransparency = 1
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = name
            textLabel.TextColor3 = color4
            textLabel.TextSize = vxEsp.textSize
            textLabel.FontFace = font
            textLabel.Parent = billboardGui
            tbl16[adornee] = highlight
            tbl17[adornee] = {bg = billboardGui, lbl = textLabel}
        end

        local function fn30(arg)
            local v9 = tbl16[arg]

            if v9 then
                v9:Destroy()
            end

            local v10 = tbl17[arg]

            if v10 and v10.bg then
                v10.bg:Destroy()
            end

            tbl16[arg] = nil
            tbl17[arg] = nil
        end

        local function fn31()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and workspace.Map:FindFirstChild("Ingame")
            if not ingame then
                return
            end

            for k in pairs(tbl18) do
                local v9 = ingame:FindFirstChild(k)

                if v9 then
                    if flag5 then
                        if not tbl16[v9] then
                            fn29(v9)
                        end
                    else
                        fn30(v9)
                    end
                end
            end
        end

        local function fn32()
            for k, v9 in pairs(tbl16) do
                if v9 and v9.Parent then
                    v9.FillColor = color4
                    v9.OutlineColor = color4
                end
            end

            for k, v9 in pairs(tbl17) do
                if v9.lbl and v9.lbl.Parent then
                    v9.lbl.TextColor3 = color4
                    v9.lbl.TextSize = vxEsp.textSize
                    v9.lbl.FontFace = font
                end

                if v9.bg and v9.bg.Parent then
                    v9.bg.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                end
            end
        end

        task.spawn(function()
            while true do
                task.wait(0.5)

                if flag5 then
                    fn31()
                end

                if flag5 then
                    fn32()
                end
            end
        end)

        esp:AddCheckbox(fn(), {
            Text = "ESP Sentry & Dispenser",
            Default = false,
            Callback = function(arg)
                flag5 = arg

                if arg then
                    fn31()
                else
                    for k in pairs(tbl16) do
                        fn30(k)
                    end
                end

                if connection3 then
                    connection3:Disconnect()
                    connection3 = nil
                end

                if arg then
                    local map = workspace:FindFirstChild("Map")
                    local ingame = map and workspace.Map:FindFirstChild("Ingame")

                    if ingame then
                        connection3 = ingame.ChildAdded:Connect(function(child)
                            if tbl18[child.Name] and flag5 then
                                task.wait(0.1)
                                fn29(child)
                            end
                        end)
                    end
                end
            end,
        }):AddColorPicker(fn(), {
            Default = color4,
            Title = "Sentry & Dispenser Color",
            Callback = function(arg)
                color4 = arg
                fn32()
            end,
        })

        local color5 = Color3.fromRGB(255, 160, 0)
        local tbl19 = {}
        local tbl20 = {}
        local connection4 = nil

        local tbl21 = {
            PizzaDeliveryRig = "Pizza Minion",
            ["1x1x1x1Zombie"] = "Zombie Minion",
        }

        local function fn33(arg)
            local flag6 = tbl21[arg] ~= nil
            return flag6
        end

        local function fn34(adornee)
            if not adornee or tbl19[adornee] then
                return
            end
            local primaryPart = adornee.PrimaryPart
            local basePart = primaryPart or adornee:FindFirstChildWhichIsA("BasePart")
            if not basePart then
                return
            end

            pcall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "VX_ESP_Minion"
                highlight.FillColor = color5
                highlight.OutlineColor = color5
                highlight.FillTransparency = vxEsp.fillTransparency
                highlight.OutlineTransparency = 0.6
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = adornee
                highlight.Parent = adornee
                tbl19[adornee] = highlight
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "VX_ESP_Minion_Label"
                billboardGui.Adornee = basePart
                billboardGui.Size = UDim2.new(0, 220, 0, 60)
                billboardGui.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                billboardGui.AlwaysOnTop = true
                billboardGui.MaxDistance = math.huge
                billboardGui.Parent = adornee
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = color5
                textLabel.TextStrokeTransparency = 0.35
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.TextScaled = false
                textLabel.TextSize = vxEsp.textSize
                textLabel.FontFace = font
                local v9 = tbl21[adornee.Name]
                local name = v9 or adornee.Name
                textLabel.Text = name
                textLabel.Parent = billboardGui
                tbl20[adornee] = {bg = billboardGui, lbl = textLabel, root = basePart}
            end)
        end

        local function fn35(arg)
            if not arg then
                return
            end

            pcall(function()
                local vxEspMinion = arg:FindFirstChild("VX_ESP_Minion")

                if vxEspMinion then
                    vxEspMinion:Destroy()
                end

                local vxEspMinionLabel = arg:FindFirstChild("VX_ESP_Minion_Label")

                if vxEspMinionLabel then
                    vxEspMinionLabel:Destroy()
                end
            end)

            tbl19[arg] = nil
            tbl20[arg] = nil
        end

        local function fn36()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and workspace.Map:FindFirstChild("Ingame")
            if not ingame then
                return
            end

            for i, child in ipairs(ingame:GetChildren()) do
                if fn33(child.Name) then
                    if minionESPEnabled then
                        if not tbl19[child] then
                            fn34(child)
                        end
                    else
                        fn35(child)
                    end
                end
            end
        end

        local function fn37()
            for k, v9 in pairs(tbl19) do
                if v9 and v9.Parent then
                    v9.FillColor = color5
                    v9.OutlineColor = color5
                    v9.FillTransparency = vxEsp.fillTransparency
                end
            end

            for k, v9 in pairs(tbl20) do
                if v9.lbl and v9.lbl.Parent then
                    v9.lbl.TextColor3 = color5
                    v9.lbl.TextSize = vxEsp.textSize
                    v9.lbl.FontFace = font
                end

                if v9.bg and v9.bg.Parent then
                    v9.bg.StudsOffsetWorldSpace = Vector3.new(0, vxEsp.offset, 0)
                end
            end
        end

        task.spawn(function()
            while true do
                task.wait(0.5)

                if minionESPEnabled then
                    fn36()
                end

                if minionESPEnabled then
                    fn37()
                end
            end
        end)

        esp:AddCheckbox(fn(), {
            Text = "ESP Minions",
            Default = false,
            Callback = function(arg)
                if arg then
                    fn36()
                else
                    for k in pairs(tbl19) do
                        fn35(k)
                    end
                end

                if connection4 then
                    connection4:Disconnect()
                    connection4 = nil
                end

                if arg then
                    local map = workspace:FindFirstChild("Map")
                    local ingame = map and workspace.Map:FindFirstChild("Ingame")

                    if ingame then
                        connection4 = ingame.ChildAdded:Connect(function(child)
                            if fn33(child.Name) and minionESPEnabled then
                                task.wait(0.1)
                                fn34(child)
                            end
                        end)
                    end
                end
            end,
        }):AddColorPicker(fn(), {
            Default = color5,
            Title = "Minion Color",
            Callback = function(arg)
                color5 = arg
                fn37()
            end,
        })

        local localPlayer4 = game:GetService("Players").LocalPlayer
        local RunService_ = game:GetService("RunService")
        local currentCamera = workspace.CurrentCamera

        local tbl22 = {
            Mobile = "rbxassetid://89227325753198",
            PC = "rbxassetid://135066638879377",
            Console = "rbxassetid://118447973769044",
        }

        local tbl23 = {}
        local connection5 = nil
        local connection6 = nil

        local function fn38()
            local killersEnabled = vxEsp.killersEnabled
            local vector = (killersEnabled or vxEsp.survivorsEnabled) and Vector3.new(0, 5.5, 0) or Vector3.new(0, 2.8, 0)
            return vector
        end

        getgenv().VX_DeviceESP_UpdateOffset = function()
            for k, v9 in pairs(tbl23) do
                v9.StudsOffset = fn38()
            end
        end

        local function fn39(arg)
            if tbl23[arg] then
                tbl23[arg]:Destroy()
                tbl23[arg] = nil
            end
        end

        local function fn40(arg, arg2)
            local head = arg2:WaitForChild("Head", 5)
            if not head then
                return
            end

            if head:FindFirstChild("DeviceESP") then
                head.DeviceESP:Destroy()
            end

            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "DeviceESP"
            billboardGui.AlwaysOnTop = true
            billboardGui.LightInfluence = 0
            billboardGui.StudsOffset = fn38()
            billboardGui.Size = UDim2.fromOffset(28, 28)
            billboardGui.Parent = head
            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Size = UDim2.new(1, 0, 1, 0)
            imageLabel.BackgroundTransparency = 1
            imageLabel.ScaleType = Enum.ScaleType.Fit
            imageLabel.Parent = billboardGui

            local function fn41()
                local attribute = arg:GetAttribute("Device")
                local pc = attribute == "PC" and tbl22.PC or attribute == "Console" and tbl22.Console or tbl22.Mobile
                imageLabel.Image = pc
            end

            fn41()
            arg:GetAttributeChangedSignal("Device"):Connect(fn41)
            tbl23[arg] = billboardGui
        end

        local function fn41(player_)
            if player_ == localPlayer4 then
                return
            end

            if player_.Character then
                fn40(player_, player_.Character)
            end

            player_.CharacterAdded:Connect(function(character2)
                fn40(player_, character2)
            end)
        end

        local function fn42()
            for i, player_ in ipairs(game:GetService("Players"):GetPlayers()) do
                fn41(player_)
            end

            connection6 = game:GetService("Players").PlayerAdded:Connect(fn41)

            connection5 = RunService_.RenderStepped:Connect(function()
                for k, v9 in pairs(tbl23) do
                    if k.Character and k.Character:FindFirstChild("Head") then
                        local n3 = math.clamp(700 / (currentCamera.CFrame.Position - k.Character.Head.Position).Magnitude, 16, 28)
                        v9.Size = UDim2.fromOffset(n3, n3)
                    end
                end
            end)
        end

        local function fn43()
            if connection5 then
                connection5:Disconnect()
                connection5 = nil
            end

            if connection6 then
                connection6:Disconnect()
                connection6 = nil
            end

            for k in pairs(tbl23) do
                fn39(k)
            end
        end

        esp:AddCheckbox(fn(), {
            Text = "Device ESP",
            Default = false,
            Callback = function(arg)
                if arg then
                    fn42()
                else
                    fn43()
                end
            end,
        })

        esp:AddDivider({MarginTop = 2, MarginBottom = 2})
        local tbl24 = {GroundBulbModel = 30, VineModel = 20}
        local color6 = Color3.fromRGB(255, 30, 30)
        local tbl25 = {}
        local tbl26 = {}
        local connection7 = nil
        local connection8 = nil

        local function fn44()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and map:FindFirstChild("Ingame")
            return ingame
        end

        local function fn45(arg)
            local flag6 = arg == "GroundBulbModel" or arg == "VineModel"
            return flag6
        end

        local function createPart(arg, arg2)
            local part = Instance.new("Part")
            part.Name = "AzurePlantAttackZone"
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(6, arg2 * 2, arg2 * 2)
            part.CFrame = CFrame.new(arg.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
            part.Color = color6
            part.Material = Enum.Material.Neon
            part.Transparency = 0.75
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
            part.Anchored = true
            part.CastShadow = false
            part.Parent = workspace
            return part
        end

        local function fn46(arg)
            if tbl25[arg] then
                tbl25[arg]:Destroy()
                tbl25[arg] = nil
            end

            if tbl26[arg] then
                tbl26[arg]:Disconnect()
                tbl26[arg] = nil
            end
        end

        local function fn47()
            for k in pairs(tbl25) do
                fn46(k)
            end
        end

        local function fn48(arg)
            if tbl25[arg] then
                return
            end
            local primaryPart = arg.PrimaryPart
            local basePart = primaryPart or arg:FindFirstChildWhichIsA("BasePart")
            if not basePart then
                return
            end
            local v9 = tbl24[arg.Name]
            local n3 = v9 or 20
            local v10 = createPart(basePart, n3)
            tbl25[arg] = v10

            tbl26[arg] = RunService.Heartbeat:Connect(function()
                if arg.Parent and v10.Parent then
                    local primaryPart2 = arg.PrimaryPart
                    local basePart2 = primaryPart2 or arg:FindFirstChildWhichIsA("BasePart")

                    if basePart2 then
                        v10.CFrame = CFrame.new(basePart2.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
                    end

                    return
                end

                v10:Destroy()
                tbl25[arg] = nil

                if tbl26[arg] then
                    tbl26[arg]:Disconnect()
                    tbl26[arg] = nil
                end
            end)
        end

        local function fn49()
            local v9 = fn44()
            if not v9 then
                return
            end

            for i, descendant in ipairs(v9:GetDescendants()) do
                if fn45(descendant.Name) and descendant:IsA("Model") then
                    fn48(descendant)
                end
            end

            connection7 = v9.DescendantAdded:Connect(function(descendant)
                if fn45(descendant.Name) and descendant:IsA("Model") then
                    task.wait(0.1)
                    fn48(descendant)
                end
            end)

            connection8 = v9.DescendantRemoving:Connect(function(descendant)
                if fn45(descendant.Name) and descendant:IsA("Model") then
                    fn46(descendant)
                end
            end)
        end

        local function fn50()
            if connection7 then
                connection7:Disconnect()
                connection7 = nil
            end

            if connection8 then
                connection8:Disconnect()
                connection8 = nil
            end

            fn47()
        end

        esp:AddCheckbox(fn(), {
            Text = "Show Plants Attack Zone",
            Default = false,
            Callback = function(vxAzureShowPlantZones)
                getgenv().VX_AzureShowPlantZones = vxAzureShowPlantZones

                if vxAzureShowPlantZones then
                    fn49()
                else
                    fn50()
                end
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Chams",
            Default = true,
            Callback = function(enabled)
                for k in pairs(tbl6) do
                    pcall(function()
                        k.Enabled = enabled
                    end)
                end
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Tracer",
            Default = false,
            Callback = function(tracerEnabled)
                vxEsp.tracerEnabled = tracerEnabled
            end,
        })

        Settings:AddDropdown(fn(), {
            Text = "Tracer Position",
            Values = {"Bottom", "Top"},
            Default = "Bottom",
            Callback = function(tracerPosition)
                vxEsp.tracerPosition = tracerPosition
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "2D Box",
            Default = false,
            Callback = function(boxEnabled)
                vxEsp.boxEnabled = boxEnabled
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Billboards",
            Default = false,
            Callback = function(billboardsEnabled)
                vxEsp.billboardsEnabled = billboardsEnabled

                for k in pairs(tbl7) do
                    pcall(function()
                        k.Enabled = billboardsEnabled
                    end)
                end
            end,
        })

        Settings:AddDivider({MarginTop = 2, MarginBottom = 2})

        Settings:AddCheckbox(fn(), {
            Text = "Distance",
            Default = false,
            Callback = function(showDistance)
                vxEsp.showDistance = showDistance
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Name",
            Default = false,
            Callback = function(showName)
                vxEsp.showName = showName
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Character",
            Default = true,
            Callback = function(showCharacter)
                vxEsp.showCharacter = showCharacter
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Health",
            Default = true,
            Callback = function(showHealth)
                vxEsp.showHealth = showHealth
            end,
        })

        Settings:AddCheckbox(fn(), {
            Text = "Role",
            Default = false,
            Callback = function(showRole)
                vxEsp.showRole = showRole
            end,
        })

        Settings:AddDivider({MarginTop = 2, MarginBottom = 2})

        Settings:AddSlider(fn(), {
            Text = "Fill Transparency",
            Min = 0,
            Max = 100,
            Default = 80,
            Rounding = 0,
            Callback = function(arg)
                vxEsp.fillTransparency = arg / 100

                for k in pairs(tbl6) do
                    pcall(function()
                        k.FillTransparency = vxEsp.fillTransparency
                    end)
                end
            end,
        })

        Settings:AddSlider(fn(), {
            Text = "Text Size",
            Min = 8,
            Max = 30,
            Default = 15,
            Rounding = 0,
            Callback = function(textSize)
                vxEsp.textSize = textSize

                for k in pairs(tbl5) do
                    pcall(function()
                        k.TextSize = textSize
                    end)
                end
            end,
        })

        Settings:AddSlider(fn(), {
            Text = "Offset",
            Min = 0,
            Max = 10,
            Default = 3.8,
            Rounding = 1,
            Callback = function(offset)
                vxEsp.offset = offset

                for k in pairs(tbl5) do
                    pcall(function()
                        if k.Parent then
                            k.Parent.StudsOffsetWorldSpace = Vector3.new(0, offset, 0)
                        end
                    end)
                end
            end,
        })

        Settings:AddSlider(fn(), {
            Text = "Box Thickness",
            Min = 1,
            Max = 5,
            Default = 1.5,
            Rounding = 1,
            Callback = function(strokeThickness)
                vxEsp.strokeThickness = strokeThickness

                for k, v9 in pairs(tbl8) do
                    if v9.box then
                        pcall(function()
                            v9.box.Thickness = strokeThickness
                        end)
                    end

                    if v9.tracer then
                        pcall(function()
                            v9.tracer.Thickness = strokeThickness
                        end)
                    end
                end
            end,
        })

        Settings:AddDropdown(fn(), {
            Text = "Font",
            Values = {"Sarpanch", "Arial", "SourceSans", "Gotham", "Code"},
            Default = 1,
            Callback = function(arg)
                local v9 = tbl4[arg]
                local sarpanch = v9 or tbl4.Sarpanch
                font = sarpanch

                for k in pairs(tbl5) do
                    pcall(function()
                        k.FontFace = font
                    end)
                end
            end,
        })

        Settings:AddDivider({MarginTop = 2, MarginBottom = 2})

        Settings:AddSlider(fn(), {
            Text = "Aim Prediction",
            Min = 0,
            Max = 60,
            Default = 0,
            Rounding = 1,
            Callback = function(arg)
                local genv3 = getgenv()
                local num = tonumber(arg)
                local saPrediction = num or 0
                genv3.SA_Prediction = saPrediction
            end,
        })

        Settings:AddSlider(fn(), {
            Text = "Circle Radius",
            Min = 20,
            Max = 400,
            Default = 120,
            Rounding = 0,
            Callback = function(arg)
                local genv3 = getgenv()
                local num = tonumber(arg)
                local saCrosshairRadius = num or 120
                genv3.SA_CrosshairRadius = saCrosshairRadius
            end,
        })

        getgenv().VX_ESP = vxEsp
    end)
local localPlayer4 = game:GetService("Players").LocalPlayer
local TextChatService = game:GetService("TextChatService")
local flag3 = false
local tbl4 = {}
local function fn12(cameraMaxZoomDistance)
        pcall(function()
            localPlayer4.CameraMaxZoomDistance = cameraMaxZoomDistance
        end)

        local currentCamera = workspace.CurrentCamera
        if not currentCamera then
            return
        end

        pcall(function()
            currentCamera.CameraType = Enum.CameraType.Custom

            if localPlayer4.Character and localPlayer4.Character:FindFirstChildOfClass("Humanoid") then
                currentCamera.CameraSubject = localPlayer4.Character:FindFirstChildOfClass("Humanoid")
            end
        end)
    end
v6:AddSlider(fn(), {
        Text = "FOV",
        Min = 20,
        Max = 200,
        Default = 80,
        Rounding = 0,
        Callback = function(arg)
            local num = tonumber(arg)
            if not num then
                return
            end
            local v7 = buffer.create(9)
            buffer.writeu8(v7, 0, 2)
            buffer.writef64(v7, 1, num)
            local fieldOfView = localPlayer4:WaitForChild("PlayerData", 5):WaitForChild("Settings", 5):WaitForChild("Game", 5):WaitForChild("FieldOfView", 5)
            if not fieldOfView then
                return
            end
            local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules", 8):WaitForChild("Network", 8):WaitForChild("Network", 8):WaitForChild("RemoteEvent", 8)

            if remoteEvent then
                remoteEvent:FireServer("UpdateSettings", {fieldOfView, v7})
            end
        end,
    })
v6:AddCheckbox(fn(), {
        Text = "Infinite Camera Distance",
        Default = false,
        Callback = function(arg)
            if arg then
                fn12(1000000000)
            else
                fn12(20)
            end
        end,
    })
v6:AddCheckbox(fn(), {
        Text = "Camera Noclip",
        Default = false,
        Callback = function(arg)
            local invisicam = arg and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
            localPlayer4.DevCameraOcclusionMode = invisicam
        end,
    })
v6:AddCheckbox(fn(), {
        Text = "Show Chat Window",
        Default = false,
        Callback = function(arg)
            local v7 = nil
            flag3 = arg
            local v8 = tbl4

            while true do
                local v9, v10 = v8(nil, v7)
                if v9 == nil then
                    break
                end
                v7 = v9
                pcall(v10.Disconnect, v10)
            end

            tbl4 = {}

            if not arg then
                local chatWindowConfiguration = TextChatService:FindFirstChild("ChatWindowConfiguration")

                if chatWindowConfiguration then
                    chatWindowConfiguration.Enabled = false
                end

                return
            end

            local function fn13()
                local chatWindowConfiguration = TextChatService:WaitForChild("ChatWindowConfiguration", 5)

                if chatWindowConfiguration then
                    chatWindowConfiguration.Enabled = true
                end
            end

            task.spawn(fn13)

            table.insert(tbl4, localPlayer4.CharacterAdded:Connect(function()
                task.wait(0.8)
                fn13()
            end))

            table.insert(tbl4, game:GetService("RunService").Heartbeat:Connect(function()
                if not flag3 then
                    return
                end
                local chatWindowConfiguration = TextChatService:FindFirstChild("ChatWindowConfiguration")

                if chatWindowConfiguration and not chatWindowConfiguration.Enabled then
                    chatWindowConfiguration.Enabled = true
                end
            end))
        end,
    })
local connection2 = nil
v6:AddCheckbox(fn(), {
        Text = "Always Show Sidebar",
        Default = false,
        Callback = function(arg)
            local ok, result2 = pcall(function()
                return require(game:GetService("ReplicatedStorage").Systems.Player.UI.SidebarHandler)
            end)

            pcall(function()
                return game:GetService("Players").LocalPlayer.PlayerGui.MainUI.Sidebar
            end)

            local function fn13()
                local ok2, result3 = pcall(function()
                    return game:GetService("Players").LocalPlayer.PlayerGui.MainUI.Sidebar
                end)

                local v7 = ok2 and result3 or nil
                return v7
            end

            if connection2 then
                connection2:Disconnect()
                connection2 = nil
            end

            if arg then
                if ok and result2 then
                    result2.MenusHidden = false
                end

                local v7 = fn13()

                if v7 then
                    v7.Visible = true
                end

                connection2 = game:GetService("RunService").Heartbeat:Connect(function()
                    if ok and result2 then
                        result2.MenusHidden = false
                    end

                    local v8 = fn13()

                    if v8 then
                        v8.Visible = true
                    end
                end)
            else
                if ok and result2 then
                    result2.MenusHidden = true
                end

                local v7 = fn13()

                if v7 then
                    v7.Visible = false
                end
            end
        end,
    })
local connection3 = nil
v6:AddCheckbox(fn(), {
        Text = "Full Bright",
        Default = false,
        Callback = function(arg)
            local Lighting = game:GetService("Lighting")

            if arg then
                getgenv()._fbOrigBrightness = Lighting.Brightness
                getgenv()._fbOrigAmbient = Lighting.Ambient
                getgenv()._fbOrigOutdoor = Lighting.OutdoorAmbient
                getgenv()._fbOrigClockTime = Lighting.ClockTime
                getgenv()._fbOrigFogEnd = Lighting.FogEnd

                local function fn13()
                    Lighting.Brightness = 2
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                    Lighting.ClockTime = 12
                    Lighting.FogEnd = 100000
                end

                fn13()
                connection3 = game:GetService("RunService").Heartbeat:Connect(fn13)
            else
                if connection3 then
                    connection3:Disconnect()
                    connection3 = nil
                end

                if getgenv()._fbOrigBrightness ~= nil then
                    Lighting.Brightness = getgenv()._fbOrigBrightness
                    Lighting.Ambient = getgenv()._fbOrigAmbient
                    Lighting.OutdoorAmbient = getgenv()._fbOrigOutdoor
                    Lighting.ClockTime = getgenv()._fbOrigClockTime
                    Lighting.FogEnd = getgenv()._fbOrigFogEnd
                end
            end
        end,
    })
local tbl5 = {}
v6:AddCheckbox(fn(), {
        Text = "Anti Lag",
        Default = false,
        Callback = function(arg)
            if arg then
                tbl5 = {}

                for i, descendant in ipairs(workspace:GetDescendants()) do
                    if not descendant:IsA("ParticleEmitter") and not descendant:IsA("Trail") and not descendant:IsA("Beam") then
                        if descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
                            table.insert(tbl5, {obj = descendant, parent = descendant.Parent})

                            pcall(function()
                                descendant.Parent = nil
                            end)
                        end
                    else
                        table.insert(tbl5, {obj = descendant, wasEnabled = descendant.Enabled})

                        pcall(function()
                            descendant.Enabled = false
                        end)
                    end
                end
            else
                for i, v7 in ipairs(tbl5) do
                    pcall(function()
                        if v7.wasEnabled == nil then
                            if v7.parent then
                                v7.obj.Parent = v7.parent
                            end
                        else
                            v7.obj.Enabled = v7.wasEnabled
                        end
                    end)
                end

                tbl5 = {}
            end
        end,
    })
task.wait()
local Killers = v:AddTab("Killers", "swords", "Combat features for killers")
local Azure = Killers:AddLeftGroupbox("Azure")
local Noli = Killers:AddLeftGroupbox("Noli")
local v7 = Killers:AddRightTabbox()
local Nosferatu = v7:AddTab("Nosferatu")
local Settings2 = v7:AddTab("Settings")
task.wait()
local Survivors = v:AddTab("Survivors", "user", "Combat features for survivors")
local v8 = Survivors:AddLeftTabbox()
local Chance = v8:AddTab("Chance")
local Settings3 = v8:AddTab("Settings")
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
getgenv().createAnimationBlocker = function(arg)
        local flag4 = false
        local tbl6 = {}

        for i, v9 in ipairs(arg) do
            tbl6[tostring(v9)] = true
        end

        local tbl7 = {}
        local localPlayer5 = game:GetService("Players").LocalPlayer

        local function fn13(arg2)
            if not arg2 or not arg2.AnimationId then
                return false
            end
            local match = tostring(arg2.AnimationId):match("%d+")
            local v9 = match and tbl6[match]
            return v9
        end

        local function fn14(arg2)
            if not flag4 or not arg2 then
                return
            end

            pcall(function()
                if fn13(arg2.Animation) then
                    arg2:Stop()
                end
            end)
        end

        local function fn15(character2)
            if not character2 then
                return
            end
            local humanoid = character2:WaitForChild("Humanoid", 8)
            if not humanoid then
                return
            end
            local animator = humanoid:FindFirstChildOfClass("Animator")
            local v9 = animator

            if not animator then
                local animator2 = Instance.new("Animator")
                v9 = animator2
                animator2.Parent = humanoid
            end

            local connection4 = v9.AnimationPlayed:Connect(fn14)
            table.insert(tbl7, connection4)
        end

        local tbl8 = {}

        tbl8.Enable = function()
            if flag4 then
                return
            end
            flag4 = true

            if localPlayer5.Character then
                fn15(localPlayer5.Character)
            end

            if not tbl8._charAddedConn then
                tbl8._charAddedConn = localPlayer5.CharacterAdded:Connect(fn15)
                table.insert(tbl7, tbl8._charAddedConn)
            end
        end

        tbl8.Disable = function()
            flag4 = false
        end

        tbl8.IsEnabled = function()
            return flag4
        end

        tbl8.Destroy = function()
            for i, v9 in ipairs(tbl7) do
                pcall(function()
                    v9:Disconnect()
                end)
            end

            tbl7 = {}

            if tbl8._charAddedConn then
                pcall(function()
                    tbl8._charAddedConn:Disconnect()
                end)

                tbl8._charAddedConn = nil
            end

            flag4 = false
        end

        return tbl8
    end
getgenv().ghostShooter = getgenv().createAnimationBlocker(getgenv().shotAnimIds)
getgenv().active = false
getgenv().aimMode = "Normal"
getgenv().predictionMode = "Velocity"
getgenv().predictionValue = 4
getgenv().spinSpeed = 720
getgenv().movementThreshold = 1
getgenv().aiming = false
getgenv().lastTriggerTime = 0
getgenv().originalWS = nil
getgenv().originalJP = nil
getgenv().originalAutoRotate = nil
getgenv().prevFlintVisibleAim = false
getgenv().aimUseCount = 0
getgenv().aimTargets = {
        "Slasher",
        "c00lkidd",
        "JohnDoe",
        "1x1x1x1",
        "Noli",
        "Nosferatu",
        "Azure",
        "Sixer",
    }
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService_ = game:GetService("RunService")
local Stats = game:GetService("Stats")
local localPlayer5 = game:GetService("Players").LocalPlayer
getgenv().getValidTarget = function()
        local players = workspace:FindFirstChild("Players")
        local killers = players and workspace.Players:FindFirstChild("Killers")

        if killers then
            for i, aimTarget in ipairs(getgenv().aimTargets) do
                local v9 = killers:FindFirstChild(aimTarget)
                if v9 and v9:FindFirstChild("HumanoidRootPart") then
                    return v9.HumanoidRootPart, v9:FindFirstChild("Humanoid")
                end
            end
        end

        return nil, nil
    end
getgenv().getPingSeconds = function()
        local dataPing = Stats.Network.ServerStatsItem["Data Ping"]
        local n3 = dataPing and dataPing:GetValue() / 1000 or 0.1
        return n3
    end
getgenv().isFlintlockVisible = function()
        if not localPlayer5.Character then
            return false
        end
        local flintlock = localPlayer5.Character:FindFirstChild("Flintlock", true)
        local v9 = flintlock
        if not flintlock then
            return false
        end

        if not flintlock:IsA("BasePart") and not flintlock:IsA("MeshPart") and not flintlock:IsA("UnionOperation") then
            local basePart = flintlock:FindFirstChildWhichIsA("BasePart", true)
            v9 = basePart
            if not basePart then
                return false
            end
        end

        local flag4 = v9.Transparency < 1
        return flag4
    end
getgenv().getPredictedAimPosPing = function(arg)
        local v9 = getgenv().getPingSeconds()
        local assemblyLinearVelocity = arg.AssemblyLinearVelocity
        if assemblyLinearVelocity.Magnitude <= getgenv().movementThreshold then
            return arg.Position
        end
        return arg.Position + assemblyLinearVelocity * v9
    end
getgenv().getPredictedAimPosInfrontHRPPing = function(arg)
        local v9 = getgenv().getPingSeconds()
        if arg.AssemblyLinearVelocity.Magnitude <= getgenv().movementThreshold then
            return arg.Position
        end
        return arg.Position + arg.CFrame.LookVector * (v9 * 60)
    end
local humanoid = nil
local humanoidRootPart2 = nil
local function fn13(character2)
        humanoid = character2:WaitForChild("Humanoid")
        humanoidRootPart2 = character2:WaitForChild("HumanoidRootPart")
    end
if localPlayer5.Character then
        fn13(localPlayer5.Character)
    end
localPlayer5.CharacterAdded:Connect(fn13)
RunService_.RenderStepped:Connect(function()
        if not getgenv().active or not humanoid or not humanoidRootPart2 then
            return
        end
        local v9 = getgenv().isFlintlockVisible()

        if v9 and not getgenv().prevFlintVisibleAim and not getgenv().aiming then
            getgenv().lastTriggerTime = tick()
            getgenv().aiming = true
        end

        getgenv().prevFlintVisibleAim = v9

        if getgenv().aiming then
            local n3 = tick() - getgenv().lastTriggerTime

            local function fn14(arg)
                local n4

                if getgenv().predictionMode == "Ping" then
                    n4 = getgenv().getPredictedAimPosPing(arg)
                elseif getgenv().predictionMode == "Infront HRP" then
                    n4 = arg.Position + arg.CFrame.LookVector * getgenv().predictionValue
                elseif getgenv().predictionMode == "Infront HRP (Ping Adjust)" then
                    n4 = getgenv().getPredictedAimPosInfrontHRPPing(arg)
                else
                    local magnitude = arg.AssemblyLinearVelocity.Magnitude

                    if getgenv().movementThreshold < magnitude then
                        n4 = arg.Position + arg.AssemblyLinearVelocity * (getgenv().predictionValue / 60)
                    else
                        n4 = arg.Position
                    end
                end

                local n5 = n4 - humanoidRootPart2.Position
                local cFrame = CFrame.new(humanoidRootPart2.Position) * CFrame.Angles(0, math.atan(-n5.X, -n5.Z), 0)
                humanoidRootPart2.CFrame = cFrame
            end

            if getgenv().aimMode == "360" then
                local n4 = 360 / getgenv().spinSpeed

                if n3 <= n4 then
                    local cFrame = CFrame.new(humanoidRootPart2.Position) * CFrame.Angles(0, math.rad(360 * (n3 / n4)), 0)
                    humanoidRootPart2.CFrame = cFrame
                elseif n3 <= n4 + 1.7 then
                    if not getgenv().originalWS then
                        getgenv().originalWS = humanoid.WalkSpeed
                        getgenv().originalJP = humanoid.JumpPower
                        getgenv().originalAutoRotate = humanoid.AutoRotate
                    end

                    humanoid.AutoRotate = false
                    humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
                    local v10 = getgenv().getValidTarget()

                    if v10 then
                        fn14(v10)
                    end
                else
                    getgenv().aiming = false

                    if getgenv().originalWS then
                        local originalWS = getgenv().originalWS
                        humanoid.WalkSpeed = originalWS
                        local originalJP = getgenv().originalJP
                        humanoid.JumpPower = originalJP
                        local originalAutoRotate = getgenv().originalAutoRotate
                        humanoid.AutoRotate = originalAutoRotate
                        local genv3 = getgenv()
                        local genv4 = getgenv()
                        local genv5 = getgenv()
                        genv3.originalWS = nil
                        genv4.originalJP = nil
                        genv5.originalAutoRotate = nil
                    end
                end
            elseif n3 <= 1.7 then
                if not getgenv().originalWS then
                    getgenv().originalWS = humanoid.WalkSpeed
                    getgenv().originalJP = humanoid.JumpPower
                    getgenv().originalAutoRotate = humanoid.AutoRotate
                end

                humanoid.AutoRotate = false
                humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
                local v10 = getgenv().getValidTarget()

                if v10 then
                    fn14(v10)
                end
            else
                getgenv().aiming = false

                if getgenv().originalWS then
                    local originalWS = getgenv().originalWS
                    humanoid.WalkSpeed = originalWS
                    local originalJP = getgenv().originalJP
                    humanoid.JumpPower = originalJP
                    local originalAutoRotate = getgenv().originalAutoRotate
                    humanoid.AutoRotate = originalAutoRotate
                    local genv3 = getgenv()
                    local genv4 = getgenv()
                    local genv5 = getgenv()
                    genv3.originalWS = nil
                    genv4.originalJP = nil
                    genv5.originalAutoRotate = nil
                end
            end
        end
    end)
getgenv().storingHitboxEnabled = false
getgenv().storingDelay = 3
local remoteEvent = ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent")
if remoteEvent and remoteEvent.ClassName == "RemoteEvent" then
        getgenv().blockedName = localPlayer5.Name .. "ChanceFireShot"
        local v9 = getrawmetatable(game)
        local namecall = v9.__namecall
        setreadonly(v9, false)

        v9.__namecall = newcclosure(function(arg, ...)
            local v10 = getnamecallmethod()
            local tbl6 = {...}

            if getgenv().storingHitboxEnabled and v10 == "FireServer" and arg == remoteEvent then
                local v11 = tbl6[1]

                if type(v11) == "string" and v11 == getgenv().blockedName then
                    task.delay(getgenv().storingDelay, function()
                        getgenv().storingHitboxEnabled = false
                        local character2 = localPlayer5.Character
                        local humanoidRootPart3 = character2 and character2:FindFirstChild("HumanoidRootPart")
                        if not humanoidRootPart3 then
                            getgenv().storingHitboxEnabled = true
                            return
                        end
                        local lookVector = humanoidRootPart3.CFrame.LookVector

                        pcall(function()
                            remoteEvent:FireServer(v11, {Vector3.new(lookVector.X, lookVector.Y, lookVector.Z)})
                        end)

                        getgenv().storingHitboxEnabled = true
                    end)

                    return
                end
            end

            return namecall(arg, ...)
        end)

        setreadonly(v9, true)
    end
Chance:AddCheckbox(fn(), {
        Text = "Chance Aim",
        Default = false,
        Callback = function(active)
            getgenv().active = active

            if active then
                getgenv().aimUseCount = 0
            end
        end,
    })
Chance:AddDropdown(fn(), {
        Text = "Aim Behavior",
        Values = {"Normal", "360"},
        Default = 1,
        Callback = function(aimMode)
            getgenv().aimMode = aimMode
        end,
    })
Chance:AddDropdown(fn(), {
        Text = "Prediction Mode",
        Values = {
            "Velocity",
            "Ping",
            "Infront HRP",
            "Infront HRP (Ping Adjust)",
        },
        Default = 1,
        Callback = function(predictionMode)
            getgenv().predictionMode = predictionMode
        end,
    })
Chance:AddDivider({MarginTop = 2, MarginBottom = 2})
Settings3:AddSlider(fn(), {
        Text = "Prediction Strength",
        Min = 1,
        Max = 4,
        Default = 4,
        Rounding = 0,
        Callback = function(arg)
            getgenv().predictionValue = tonumber(arg)
        end,
    })
Settings3:AddSlider(fn(), {
        Text = "360 Spin Speed",
        Min = 720,
        Max = 2880,
        Default = 720,
        Rounding = 0,
        Callback = function(arg)
            getgenv().spinSpeed = tonumber(arg)
        end,
    })
Chance:AddCheckbox(fn(), {
        Text = "Storing Hitbox Gun",
        Default = false,
        Callback = function(storingHitboxEnabled)
            getgenv().storingHitboxEnabled = storingHitboxEnabled
        end,
    })
Chance:AddInput(fn(), {
        Text = "Store Delay",
        Placeholder = "3",
        Callback = function(arg)
            local storingDelay = tonumber(arg)

            if storingDelay and storingDelay > 0 then
                getgenv().storingDelay = storingDelay
            end
        end,
    })
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local RunService_2 = game:GetService("RunService")
local function fn14()
        local v9 = nil

        local ok, result2 = pcall(function()
            return require(ReplicatedStorage3.Modules.Gameplay.Actors)
        end)

        if not ok then
            return nil
        end
        local currentActors = result2.CurrentActors

        while true do
            local v10, v11 = currentActors(nil, v9)
            if v10 == nil then
                break
            end
            v9 = v10
            if v11.ActorName == "Azure" and v11.Player == lp then
                return v11
            end
        end
    end
local function fn15(arg, arg2)
        local primaryPart = nil
        local v9 = nil

        for i, descendant in ipairs(workspace:GetDescendants()) do
            if descendant.Name == arg2 and descendant:IsA("Model") and descendant.PrimaryPart then
                local magnitude = (descendant.PrimaryPart.Position - arg).Magnitude

                if not v9 or magnitude < v9 then
                    primaryPart = descendant.PrimaryPart
                    v9 = magnitude
                end
            end
        end

        return primaryPart
    end
getgenv().VX_AimTentaclesGrab = false
local connection4 = nil
Azure:AddCheckbox(fn(), {
        Text = "Aim on Tentacles (Grab)",
        Default = false,
        Callback = function(vxAimTentaclesGrab)
            getgenv().VX_AimTentaclesGrab = vxAimTentaclesGrab

            if connection4 then
                connection4:Disconnect()
                connection4 = nil
            end

            if vxAimTentaclesGrab then
                connection4 = RunService_2.RenderStepped:Connect(function()
                    local v9 = fn14()
                    if not v9 or not v9.State or v9.State.TrackingMousePosition ~= true then
                        return
                    end
                    local rig = v9.Rig
                    local position = rig and v9.Rig.PrimaryPart and v9.Rig.PrimaryPart.Position
                    if not position then
                        return
                    end
                    local vineModel = fn15(position, "VineModel")
                    if not vineModel then
                        return
                    end
                    local currentCamera = workspace.CurrentCamera
                    currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position, vineModel.Position)
                end)
            end
        end,
    })
getgenv().VX_AimBlossomGrab = false
local connection5 = nil
Azure:AddCheckbox(fn(), {
        Text = "Aim on Blossom (Grab)",
        Default = false,
        Callback = function(vxAimBlossomGrab)
            getgenv().VX_AimBlossomGrab = vxAimBlossomGrab

            if connection5 then
                connection5:Disconnect()
                connection5 = nil
            end

            if vxAimBlossomGrab then
                connection5 = RunService_2.RenderStepped:Connect(function()
                    local v9 = fn14()
                    if not v9 or not v9.State or v9.State.TrackingMousePosition ~= true then
                        return
                    end
                    local rig = v9.Rig
                    local position = rig and v9.Rig.PrimaryPart and v9.Rig.PrimaryPart.Position
                    if not position then
                        return
                    end
                    local groundBulbModel = fn15(position, "GroundBulbModel")
                    if not groundBulbModel then
                        return
                    end
                    local currentCamera = workspace.CurrentCamera
                    currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position, groundBulbModel.Position)
                end)
            end
        end,
    })
getgenv().VX_AimSurvivorsGrab = false
local connection6 = nil
local function fn16()
        if connection6 then
            connection6:Disconnect()
            connection6 = nil
        end

        if not getgenv().VX_AimSurvivorsGrab then
            return
        end

        connection6 = RunService_2.RenderStepped:Connect(function()
            local v9 = fn14()
            if not v9 or not v9.State or v9.State.TrackingMousePosition ~= true then
                return
            end
            local rig = v9.Rig
            local position = rig and v9.Rig.PrimaryPart and v9.Rig.PrimaryPart.Position
            if not position then
                return
            end
            local players = workspace:FindFirstChild("Players")
            local survivors = players and workspace.Players:FindFirstChild("Survivors")
            if not survivors then
                return
            end
            local v10 = nil
            local silentAimMode = getgenv().SilentAimMode
            local str = silentAimMode or "Nearest"

            if str == "Closest To Cursor" then
                local currentCamera = workspace.CurrentCamera
                local mouse = lp:GetMouse()
                local vector2 = Vector2.new(mouse.X, mouse.Y)
                local huge = math.huge

                for i, child in ipairs(survivors:GetChildren()) do
                    local humanoidRootPart3 = child:FindFirstChild("HumanoidRootPart")
                    local humanoid2 = child:FindFirstChildOfClass("Humanoid")

                    if humanoidRootPart3 and humanoid2 and humanoid2.Health > 0 then
                        local v11, v12 = currentCamera:WorldToViewportPoint(humanoidRootPart3.Position)

                        if v12 then
                            local magnitude = (Vector2.new(v11.X, v11.Y) - vector2).Magnitude

                            if magnitude < huge then
                                huge = magnitude
                                v10 = humanoidRootPart3
                            end
                        end
                    end
                end
            else
                local huge = math.huge

                for i, child in ipairs(survivors:GetChildren()) do
                    local humanoidRootPart3 = child:FindFirstChild("HumanoidRootPart")
                    local humanoid2 = child:FindFirstChildOfClass("Humanoid")

                    if humanoidRootPart3 and humanoid2 and humanoid2.Health > 0 then
                        local magnitude = (humanoidRootPart3.Position - position).Magnitude

                        if magnitude < huge then
                            huge = magnitude
                            v10 = humanoidRootPart3
                        end
                    end
                end
            end

            if not v10 then
                return
            end
            local currentCamera = workspace.CurrentCamera
            currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position, v10.Position)
        end)
    end
Azure:AddCheckbox(fn(), {
        Text = "Aim at Survivors (Grab)",
        Default = false,
        Callback = function(vxAimSurvivorsGrab)
            getgenv().VX_AimSurvivorsGrab = vxAimSurvivorsGrab
            fn16()
        end,
    })
Azure:AddDivider({MarginTop = 2, MarginBottom = 2})
local VirtualInputManager = game:GetService("VirtualInputManager")
getgenv().VX_AutoDisarmDelay = 0
local v9 = nil
local n3 = 0
local v10 = nil
local tbl6 = {}
local connection7 = nil
local function fn17()
        local playerGui = lp:FindFirstChildOfClass("PlayerGui")
        if not playerGui then
            return
        end
        local temporaryUI = playerGui:FindFirstChild("TemporaryUI")

        if not temporaryUI then
            v9 = nil
            v10 = nil
            table.clear(tbl6)
            return
        end

        local qte = temporaryUI:FindFirstChild("QTE")
        local v11 = qte

        if not qte then
            for i, child in ipairs(temporaryUI:GetChildren()) do
                if child:FindFirstChild("Line") then
                    v11 = child
                    break
                end
                continue
            end
        end

        if not v11 then
            v9 = nil
            v10 = nil
            table.clear(tbl6)
            return
        end

        if v9 ~= v11 then
            v9 = v11
            n3 = os.clock()
            v10 = nil
            table.clear(tbl6)
        end

        local line = v11:FindFirstChild("Line")
        if not line then
            return
        end
        local scale = line.Position.X.Scale

        if not v10 then
            v10 = scale
        end

        for i, child in ipairs(v11:GetChildren()) do
            if child.Name:sub(1, 4) == "Zone" and child.Visible then
                local v12 = tbl6[child]
                local n4 = v12 or 0

                if os.clock() - n4 >= 0.4 then
                    local scale2 = child.Position.X.Scale
                    local scale3 = child.Size.X.Scale
                    local n5 = scale2 + scale3 / 2
                    local n6 = math.min(v10, scale)

                    if scale2 - scale3 / 2 <= math.max(v10, scale) and n6 <= n5 then
                        tbl6[child] = os.clock()
                        VirtualInputManager:SendTouchEvent(0, 0, 200, 200)
                        task.wait(0.03)
                        VirtualInputManager:SendTouchEvent(0, 2, 200, 200)
                        break
                    end
                end
            end
        end

        v10 = scale
    end
Azure:AddCheckbox(fn(), {
        Text = "Auto Disarm Minigame",
        Default = false,
        Callback = function(arg)
            if connection7 then
                connection7:Disconnect()
                connection7 = nil
            end

            if arg then
                connection7 = game:GetService("RunService").Heartbeat:Connect(fn17)
            end
        end,
    })

P["Noli@12808,10-12808,14"] = Noli
P["Nosferatu@12810,10-12810,19"] = Nosferatu
P["Settings2@12811,10-12811,19"] = Settings2
P["Survivors@12813,10-12813,19"] = Survivors
end