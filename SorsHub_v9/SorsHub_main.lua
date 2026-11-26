print("SorsHub 1.2 loading...")
-- [SorsHub] Penanda build: kalau baris ini TIDAK muncul di console, berarti
-- main yang dijalankan BUKAN versi repo ini (mis. main lama di device).
print("[SorsHub] main build: V20.6-repo (2026-11-26)")

-- ============================================================
-- BOOT STATUS (visible even when the executor console is hidden)
-- ============================================================
local bootGui, bootLabel

pcall(function()
    local player = game:GetService("Players").LocalPlayer
    if not player then return end
    local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    bootGui = Instance.new("ScreenGui")
    bootGui.Name = "SorsHub_Boot"
    bootGui.IgnoreGuiInset = true
    bootGui.ResetOnSpawn = false
    bootGui.DisplayOrder = 50

    bootLabel = Instance.new("TextLabel")
    bootLabel.Size = UDim2.new(0, 280, 0, 26)
    bootLabel.Position = UDim2.new(0.5, -140, 0, 8)
    bootLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    bootLabel.BackgroundTransparency = 0.2
    bootLabel.TextColor3 = Color3.fromRGB(255, 210, 90)
    bootLabel.Font = Enum.Font.GothamBold
    bootLabel.TextSize = 14
    bootLabel.TextScaled = false
    bootLabel.Text = "SorsHub: starting..."
    bootLabel.Parent = bootGui
    bootGui.Parent = playerGui
end)

local function bootStatus(message)
    if not bootLabel then return end
    pcall(function() bootLabel.Text = "SorsHub: " .. tostring(message) end)
end

local function bootDone()
    if not bootGui then return end
    pcall(function() bootGui:Destroy() end)
    bootGui = nil
    bootLabel = nil
end

-- ============================================================
-- ERROR HANDLER
-- ============================================================
local function flashError(msg)
    local ok, flashErr = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local gui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
        if not gui then return end
        
        local errorGui = Instance.new("ScreenGui")
        errorGui.Name = "SorsHub_Error"
        errorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        errorGui.Parent = gui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 500, 0, 100)
        frame.Position = UDim2.new(0.5, -250, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 3
        frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
        frame.Parent = errorGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, -20)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.Text = "⚠️ SorsHub ERROR\n\n" .. tostring(msg):sub(1, 420)
        label.TextColor3 = Color3.fromRGB(255, 200, 200)
        label.TextScaled = true
        label.BackgroundTransparency = 1
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 80, 0, 30)
        closeBtn.Position = UDim2.new(1, -90, 1, -40)
        closeBtn.Text = "Dismiss"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeBtn.BorderSizePixel = 0
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = frame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            errorGui:Destroy()
        end)
        
        task.delay(15, function()
            pcall(function() errorGui:Destroy() end)
        end)
    end)
    if not ok then warn("[SorsHub] flashError itself failed: " .. tostring(flashErr)) end
end

local function sorsHubTraceback(errorValue)
    local message = tostring(errorValue)
    local ok, trace = pcall(function()
        if debug and type(debug.traceback) == "function" then
            return debug.traceback(message, 2)
        end
    end)
    if ok and type(trace) == "string" and trace ~= "" then return trace end
    return message
end

local success, err = xpcall(function()

local svc = {
    Players        = game:GetService("Players"),
    Run            = game:GetService("RunService"),
    Input          = game:GetService("UserInputService"),
    RS             = game:GetService("ReplicatedStorage"),
    WS             = game:GetService("Workspace"),
    TweenService   = game:GetService("TweenService"),
    TextChat       = game:GetService("TextChatService"),
    Http           = game:GetService("HttpService"),
    SoundService   = game:GetService("SoundService"),
    Stats          = game:GetService("Stats"),
}

local lp  = svc.Players.LocalPlayer
do -- [SorsHub: scope local]
local gui = lp:WaitForChild("PlayerGui", 10)
end -- [SorsHub: scope local]


local fs = {
    hasFolder = isfolder     or function() return false end,
    makeFolder= makefolder   or function() end,
    write     = writefile    or function() end,
    hasFile   = isfile       or function() return false end,
    read      = readfile     or function() return "" end,
    asset     = getcustomasset or function(p) return p end,
}

local WIND_DIR  = "SorsHub"
local WIND_FILE = WIND_DIR .. "/WindUI.lua"
local WIND_URL  = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

-- HTTP fallback for executors where game:HttpGet is missing/broken.
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return res end

    local attempts = {
        function() return syn and syn.request and syn.request({ Url = url, Method = "GET" }).Body end,
        function() return http and http.request and http.request({ Url = url, Method = "GET" }).Body end,
        function() return request and request({ Url = url, Method = "GET" }).Body end,
        function() return http_request and http_request({ Url = url, Method = "GET" }).Body end,
        function() return fluxus and fluxus.request and fluxus.request({ Url = url, Method = "GET" }).Body end,
    }
    for _, attempt in ipairs(attempts) do
        local ok2, res2 = pcall(attempt)
        if ok2 and type(res2) == "string" and #res2 > 0 then return res2 end
    end
    return nil
end

-- loadstring fallback (some executors only expose `load`).
local function compileScript(src)
    local loaderFn = loadstring or load
    if type(loaderFn) ~= "function" then return nil, "loadstring/load not available" end

    -- Keep the real compiler message: loadstring returns (nil, err) on failure.
    local packed = table.pack(pcall(loaderFn, src))
    if packed[1] and type(packed[2]) == "function" then return packed[2] end
    local err = packed[1] and (packed[3] or packed[2]) or packed[2]
    return nil, tostring(err)
end

local function loadWindUI()
    if fs.hasFolder(WIND_DIR) and fs.hasFile(WIND_FILE) then
        local src = fs.read(WIND_FILE)
        if src and #src > 100 then
            local result, cacheErr = compileScript(src)
            if result then
                local ok2, ui = pcall(result)
                if ok2 and ui then
                    print("[SorsHub] WindUI loaded from cache")
                    return ui
                end
            else
                warn("[SorsHub] cached WindUI compile error: " .. tostring(cacheErr))
            end
        end
    end
    
    print("[SorsHub] Downloading WindUI...")
    local src = httpGet(WIND_URL)
    if src and #src > 100 then
        pcall(function()
            if not fs.hasFolder(WIND_DIR) then fs.makeFolder(WIND_DIR) end
            fs.write(WIND_FILE, src)
        end)
        
        local result, dlErr = compileScript(src)
        if result then
            local ok2, ui = pcall(result)
            if ok2 and ui then
                print("[SorsHub] WindUI downloaded and loaded")
                return ui
            end
        else
            warn("[SorsHub] WindUI download compile error: " .. tostring(dlErr))
        end
    end
    
    print("[SorsHub] Trying alternative WindUI URL...")
    local altURL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"
    local src2 = httpGet(altURL)
    if src2 and #src2 > 100 then
        local result, altErr = compileScript(src2)
        if result then
            local ok2, ui = pcall(result)
            if ok2 and ui then
                print("[SorsHub] WindUI loaded from alternative URL")
                return ui
            end
        else
            warn("[SorsHub] WindUI alt download compile error: " .. tostring(altErr))
        end
    end
    
    error("Failed to load WindUI from all sources")
    return nil
end

bootStatus("loading WindUI...")
local ui = loadWindUI()

if not ui then
    error("WindUI is nil - cannot create window")
end

bootStatus("creating window...")
local win
-- Responsive dimensions: keep the panel usable on both desktop and mobile.
local uiViewport = Vector2.new(900, 700)
pcall(function()
    local camera = svc.WS.CurrentCamera
    if camera then uiViewport = camera.ViewportSize end
end)
local uiAvailableWidth = math.max(300, math.floor(uiViewport.X - 28))
local uiAvailableHeight = math.max(360, math.floor(uiViewport.Y - 86))
local uiWidth = math.min(560, uiAvailableWidth)
local uiHeight = math.min(620, uiAvailableHeight)
local uiMinWidth = math.min(340, uiWidth)
local uiMinHeight = math.min(400, uiHeight)
local uiMaxWidth = math.min(720, uiAvailableWidth)
local uiMaxHeight = math.min(740, uiAvailableHeight)
local uiSidebarWidth = math.clamp(math.floor(uiWidth * 0.29), 100, 165)

pcall(function()
    win = ui:CreateWindow({
        Title          = "SorsHub",
        Icon           = "sparkles",
        Author         = "G1-menh",
        Folder         = "SorsHub",
        Size           = UDim2.fromOffset(uiWidth, uiHeight),
        MinSize        = Vector2.new(uiMinWidth, uiMinHeight),
        MaxSize        = Vector2.new(uiMaxWidth, uiMaxHeight),
        Transparent    = false,
        Theme          = "Amber",
        Resizable      = true,
        SideBarWidth   = uiSidebarWidth,
        HideSearchBar  = false,
        ScrollBarEnabled = true,
    })
end)

if not win then
    error("Failed to create window - WindUI may be incompatible")
end

local ConfigManager = win.ConfigManager
local v1prConfig = ConfigManager:CreateConfig("SorsHub")

-- Guard WindUI config reloads: malformed/legacy Toggle values must never be
-- passed straight into Toggle:Set(), which expects a boolean.
pcall(function()
    local parser = ConfigManager and ConfigManager.Parser and ConfigManager.Parser.Toggle
    if type(parser) == "table" then
        parser.Load = function(element, data)
            if not (element and type(element.Set) == "function") then return end
            local raw = type(data) == "table" and data.value or nil
            local value = (raw == true or raw == "true" or raw == 1 or raw == "1")
            local ok, loadErr = pcall(function() element:Set(value) end)
            if not ok then warn("[SorsHub] safe toggle config load failed: " .. tostring(loadErr)) end
        end
    end
end)

-- [SorsHub fix] variabel yang dipakai lintas-blok di-deklarasikan di sini
local ac, applyTimerPos, atEnabled, atStartManager, atStopManager, chanceAimEnabled, chatForceConn, chatForceEnabled, enforceChatOn, esp, espStart, espStop, flow, g_hookSound, g_updateVision, gv, gvConfig, gvStart, gvStop, hb, hbStart, hbStop, mob_stopPunchOverride, mset, platDevice, platEnabled, platStart, platStop, sk8_controlActive, sk8_controlEnabled, sk8_stopOverride, speedHack, speedStart, spoofActive, spoofStart, spoofStop, sprayBaseCF, sprayPhase, stam, stamApply, stamStart, tabGlobal, timerSide, tt_backstabType, tt_daggerEnabled, tt_enabled, tt_rangeMode, updateTransparency, vee_fastSpray


bootStatus("building UI...")
win:SetToggleKey(Enum.KeyCode.L)

-- [SorsHub] registry tab: create pages in a deliberate order so the sidebar
-- starts with core features, then utility pages, then character-specific pages.
local vxTabRegistry = {}
pcall(function()
    local origTab = win.Tab
    if type(origTab) ~= "function" then return end

    local function keyOf(title)
        return (string.lower(tostring(title)):gsub("[^%w]", ""))
    end

    -- Give every page consistent boxed sections. Normalize boolean fields at
    -- the UI boundary so stale configs cannot pass strings/numbers to WindUI.
    local function safeBoolean(value, fallback)
        if type(value) == "boolean" then return value end
        if value == 1 or value == "1" or value == "true" then return true end
        if value == 0 or value == "0" or value == "false" then return false end
        return fallback == true
    end

    local function styleTab(tab)
        if not tab or type(tab.Section) ~= "function" then return tab end
        local originalSection = tab.Section
        local wrappedSection = function(self, cfg, ...)
            if type(cfg) == "table" then
                local styled = table.clone(cfg)
                if styled.Box == nil then styled.Box = true end
                styled.Opened = safeBoolean(styled.Opened, false)
                local section = originalSection(self, styled, ...)

                -- WindUI's current Toggle API documents Value as the boolean
                -- default. Older SorsHub configs used Default, so support both.
                pcall(function()
                    if section and type(section.Toggle) == "function"
                        and not section.__sorshubBoolTogglePatched then
                        local originalToggle = section.Toggle
                        section.Toggle = function(sectionSelf, toggleCfg, ...)
                            if type(toggleCfg) == "table" then
                                local safeCfg = table.clone(toggleCfg)
                                local fallback = safeBoolean(safeCfg.Default, false)
                                safeCfg.Value = safeBoolean(safeCfg.Value, fallback)
                                safeCfg.Default = safeCfg.Value
                                return originalToggle(sectionSelf, safeCfg, ...)
                            end
                            return originalToggle(sectionSelf, toggleCfg, ...)
                        end
                        section.__sorshubBoolTogglePatched = true
                    end
                end)
                -- [SorsHub fix V20.6] Kegagalan render kontrol sebelumnya ditelan
                -- pcall tanpa jejak. Bungkus method elemen supaya error tampil di
                -- console dengan judul kontrolnya (hasil asli tetap dikembalikan).
                pcall(function()
                    if section and not section.__sorshubRenderLogged then
                        section.__sorshubRenderLogged = true
                        for _, m in ipairs({"Toggle", "Slider", "Dropdown", "Input", "Keybind", "Colorpicker", "Button"}) do
                            local orig = section[m]
                            if type(orig) == "function" then
                                section[m] = function(self2, cfg2, ...)
                                    local packed = table.pack(pcall(orig, self2, cfg2, ...))
                                    if not packed[1] then
                                        warn("[SorsHub] gagal render " .. m .. " '" .. tostring(type(cfg2) == "table" and cfg2.Title) .. "': " .. tostring(packed[2]))
                                        return nil
                                    end
                                    return table.unpack(packed, 2, packed.n)
                                end
                            end
                        end
                    end
                end)
                return section
            end
            return originalSection(self, cfg, ...)
        end
        pcall(function() tab.Section = wrappedSection end)
        return tab
    end

    local function wrapper(self, cfg, ...)
        local key = type(cfg) == "table" and cfg.Title and keyOf(cfg.Title)
        if key and vxTabRegistry[key] then return vxTabRegistry[key] end
        local created = styleTab(origTab(self, cfg, ...))
        if key and created then vxTabRegistry[key] = created end
        return created
    end

    win.Tab = wrapper
    if win.Tab ~= wrapper then return end

    -- Main pages first. Related pack pages are aliased below to avoid creating
    -- duplicate top-level tabs for the same feature area.
    local orderedTabs = {
        { "Global", "globe" },
        { "Setting", "settings" },
        { "Aimbot", "crosshair" },
        { "ESP", "eye" },
        { "Guest1337", "shield" },
        { "Blatant", "zap" },
        { "Extras", "wrench" },
        { "Fun", "smile" },
        { "Interface", "scan" },
        { "Report", "flag" },
        -- Character-specific pages stay separate so each character's controls
        -- and its unload button keep their original behavior.
        { "007n7", "user" }, { "Chance", "crosshair" },
        { "Dusekkar", "zap" }, { "Elliot", "crosshair" },
        { "Jane Doe", "gem" }, { "TwoTime", "sword" },
        { "Veeronica", "zap" }, { "Azure", "swords" },
        { "Noli", "swords" }, { "Nosferatu", "swords" },
    }

    for _, entry in ipairs(orderedTabs) do
        pcall(function() win:Tab({ Title = entry[1], Icon = entry[2] }) end)
    end

    -- Consolidate related pack pages into their matching native pages. Their
    -- controls remain as independent, named sections inside the destination.
    local tabAliases = {
        stamina = "global",
        generators = "global",
        visual = "esp",
        aim = "aimbot",
        misc = "extras",
        uisettings = "interface",
    }
    for alias, target in pairs(tabAliases) do
        if vxTabRegistry[target] then vxTabRegistry[alias] = vxTabRegistry[target] end
    end
end)
-- [/SorsHub] registry tab
pcall(function() ui:SetFont("rbxasset://fonts/families/GothamSSm.json") end)

pcall(function()
    win:EditOpenButton({
        Title          = "SorsHub",
        Icon           = "sparkles",
        CornerRadius   = UDim.new(0, 14),
        StrokeThickness = 1,
        Color = ColorSequence.new(Color3.fromRGB(255, 190, 82), Color3.fromRGB(190, 105, 34)),
        OnlyMobile = false,
        Enabled    = true,
        Draggable  = true,
    })
end)

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Resolve known game paths one segment at a time. This avoids brittle direct
-- property chains when the round/map folders are still loading or are replaced.
local function findPath(root, ...)
    local node = root
    for i = 1, select("#", ...) do
        if not node then return nil end
        -- select(i, ...) returns all values from i onward when used as the
        -- final function argument. Store it first so FindFirstChild receives
        -- only the child name, not a string as its recursive boolean argument.
        local segment = select(i, ...)
        node = node:FindFirstChild(segment)
    end
    return node
end

local function getTeamFolder(name)
    return findPath(svc.WS, "Players", name)
end

local function getIngame()
    return findPath(svc.WS, "Map", "Ingame")
end

local function getMapContent()
    return findPath(svc.WS, "Map", "Ingame", "Map")
end

local function safeRequirePath(root, ...)
    local moduleScript = findPath(root, ...)
    if not moduleScript or not moduleScript:IsA("ModuleScript") then return nil end
    local ok, result = pcall(require, moduleScript)
    if ok then return result end
    return nil
end

local _networkModule = nil
local function getNetwork()
    if _networkModule then return _networkModule end
    _networkModule = safeRequirePath(svc.RS, "Modules", "Network", "Network")
    return _networkModule
end

local _hbRemote = nil
local function hbGetRemote()
    if _hbRemote and _hbRemote.Parent then return _hbRemote end
    _hbRemote = findPath(svc.RS, "Modules", "Network", "Network", "RemoteEvent")
    return _hbRemote
end

-- ============================================================
-- SHARED RF DISPATCHER SYSTEM
-- ============================================================
local rfDispatch = {
    hooks = {},
    installed = false,
    originalCallback = nil,
    activeRemote = nil
}

function rfDispatch:register(id, callback)
    self.hooks[id] = callback
end

function rfDispatch:unregister(id)
    self.hooks[id] = nil
end

function rfDispatch:install(remoteFunction)
    if self.installed then return end
    
    self.activeRemote = remoteFunction
    
    if typeof(getcallbackvalue) == "function" then
        self.originalCallback = getcallbackvalue(remoteFunction, "OnClientInvoke")
    else
        self.originalCallback = remoteFunction.OnClientInvoke
    end

    remoteFunction.OnClientInvoke = function(requestName, ...)
        local shouldIntercept = false
        local interceptRequests = {"GetMousePosition", "GetCameraCF"}
        
        for _, req in ipairs(interceptRequests) do
            if requestName == req then
                shouldIntercept = true
                break
            end
        end
        
        if shouldIntercept then
            for id, hookFunc in pairs(self.hooks) do
                local success, result = pcall(hookFunc, requestName, ...)
                if success and result ~= nil then
                    return result
                end
            end
        end
        
        if self.originalCallback then
            local ok, res = pcall(self.originalCallback, requestName, ...)
            if ok then return res end
        end
    end
    self.installed = true
end

function rfDispatch:uninstall(remoteFunction)
    if not self.installed then return end
    if remoteFunction and self.originalCallback then
        remoteFunction.OnClientInvoke = self.originalCallback
    end
    self.hooks = {}
    self.originalCallback = nil
    self.installed = false
    self.activeRemote = nil
end

-- ============================================================
-- SETTINGS TAB
-- ============================================================

do -- tabSettings
local tabSettings = win:Tab({ Title = "Setting", Icon = "settings" })

-- QTE SECTION
local secQTE = (vxTabRegistry["global"] or tabSettings):Section({ Title = "QTE", Opened = true })

local qteConfig = {
    enabled = false,
    clickDelay = 0.08,
    debounceTime = 0.25,
    zoneMargin = 0.02,
    clickOffset = 0.0,
    spamWaitTime = 0.03,
    preClickAttempts = 3,
}

local qteConnection = nil

local function disarmQTEStart()
    if qteConnection then return end
    
    pcall(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = Players.LocalPlayer
        
        local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        
        local autoQTEEnabled = true
        local qteModuleInstance = nil
        local qteActive = false
        local qteUI = nil
        
        local lastClickTime = 0
        local clickCount = 0
        local successCount = 0
        local failCount = 0
        local qteStartTime = 0
        local lastLinePos = 0
        local lineDirection = 1
        
        local function getQTEModule()
            if qteModuleInstance then return qteModuleInstance end
            local assets = ReplicatedStorage:FindFirstChild("Assets")
            if not assets then return nil end
            local killers = assets:FindFirstChild("Killers")
            if not killers then return nil end
            local azure = killers:FindFirstChild("Azure")
            if not azure then return nil end
            local config = azure:FindFirstChild("mike old")
            if not config then return nil end
            config = config:FindFirstChild("[OLD] Config")
            if not config then return nil end
            local workaround = config:FindFirstChild("cl_WorkaroundModules")
            if not workaround then return nil end
            local module = workaround:FindFirstChild("cl_QTEUI")
            if not module then return nil end
            local result = require(module)
            if type(result) ~= "table" then return nil end
            qteModuleInstance = result
            return qteModuleInstance
        end
        
        local function getQTEUI()
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not playerGui then return nil end
            local tempUI = playerGui:FindFirstChild("TemporaryUI")
            if tempUI then local qte = tempUI:FindFirstChild("QTE") if qte then return qte end end
            local mainUI = playerGui:FindFirstChild("MainUI")
            if mainUI then local qte = mainUI:FindFirstChild("QTE") if qte then return qte end end
            return playerGui:FindFirstChild("QTE")
        end
        
        local function onQTEAppeared()
            if qteActive then return end
            qteActive = true
            qteStartTime = os.clock()
            clickCount = 0 successCount = 0 failCount = 0 lastLinePos = 0
            getQTEModule()
        end
        
        local function onQTEDisappeared()
            if not qteActive then return end
            qteActive = false
        end
        
        local function getClickableArea(ui)
            if not ui then return nil end
            for _, name in ipairs({"ClickArea", "Button", "TextLabel", "Frame", "ImageLabel"}) do
                local obj = ui:FindFirstChild(name)
                if obj and obj.Visible then return obj end
            end
            for _, child in ipairs(ui:GetChildren()) do
                if (child:IsA("ImageButton") or child:IsA("TextButton")) and child.Visible then return child end
            end
            if ui:IsA("GuiObject") and ui.Visible then return ui end
            return nil
        end
        
        local function simulateMouseClick(ui)
            local clickable = getClickableArea(ui)
            if not clickable or not VirtualInputManager then return false end
            local absPos = clickable.AbsolutePosition
            local absSize = clickable.AbsoluteSize
            if absPos.X <= 0 or absPos.Y <= 0 then return false end
            local x = absPos.X + absSize.X / 2
            local y = absPos.Y + absSize.Y / 2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
            return true
        end
        
        local function simulateTouch(ui)
            local clickable = getClickableArea(ui)
            if not clickable or not VirtualInputManager then return false end
            local absPos = clickable.AbsolutePosition
            local absSize = clickable.AbsoluteSize
            if absPos.X <= 0 or absPos.Y <= 0 then return false end
            local x = absPos.X + absSize.X / 2
            local y = absPos.Y + absSize.Y / 2
            local screenSize = game:GetService("Workspace").CurrentCamera.ViewportSize
            if x > screenSize.X or y > screenSize.Y then x = screenSize.X / 2 y = screenSize.Y / 2 end
            VirtualInputManager:SendTouchEvent(1, 0, x, y)
            task.wait(0.05)
            VirtualInputManager:SendTouchEvent(1, 2, x, y)
            return true
        end
        
        local function useModuleMethod(ui)
            local module = getQTEModule()
            if not module or not module.OnButtonPressed then return false end
            module.OnButtonPressed(ui)
            return true
        end
        
        local function pressQTE()
            if not qteActive then return false end
            local ui = getQTEUI()
            if not ui or not ui.Visible then return false end
            local currentTime = os.clock()
            if currentTime - lastClickTime < qteConfig.debounceTime then return false end
            lastClickTime = currentTime
            clickCount = clickCount + 1
            local success = isMobile and simulateTouch(ui) or simulateMouseClick(ui)
            if not success then success = useModuleMethod(ui) end
            if success then successCount = successCount + 1 return true end
            failCount = failCount + 1
            return false
        end
        
        local function trackLineMovement(ui)
            local line = ui:FindFirstChild("Line")
            if not line then return end
            local currentPos = line.Position.X.Scale
            local delta = currentPos - lastLinePos
            if math.abs(delta) > 0.001 then lineDirection = delta > 0 and 1 or -1 end
            lastLinePos = currentPos
        end
        
        local function autoQTELoop()
            if not qteActive then return end
            local ui = getQTEUI()
            if not ui or not ui.Visible then onQTEDisappeared() return end
            trackLineMovement(ui)
            local line = ui:FindFirstChild("Line")
            if not line then return end
            local linePos = line.Position.X.Scale
            local zones = {}
            for _, child in ipairs(ui:GetChildren()) do
                if child.Name:find("Zone") and child.Visible then
                    table.insert(zones, {
                        Min = child.Position.X.Scale - child.Size.X.Scale / 2,
                        Max = child.Position.X.Scale + child.Size.X.Scale / 2,
                        Center = child.Position.X.Scale
                    })
                end
            end
            if #zones == 0 then return end
            for _, zone in ipairs(zones) do
                if linePos >= zone.Min and linePos <= zone.Max then
                    local retries = 0
                    while retries < 5 do
                        local stillInZone = line.Position.X.Scale >= zone.Min and line.Position.X.Scale <= zone.Max
                        if not stillInZone then break end
                        pressQTE()
                        retries = retries + 1
                        task.wait(qteConfig.spamWaitTime)
                    end
                    task.wait(qteConfig.debounceTime)
                    return
                end
                local distToEdge = lineDirection > 0 and (zone.Min - linePos) or (linePos - zone.Max)
                if distToEdge > 0 and distToEdge <= qteConfig.zoneMargin then
                    task.wait(qteConfig.clickDelay)
                    for _ = 1, qteConfig.preClickAttempts do
                        local currentPos = line.Position.X.Scale
                        if currentPos >= zone.Min and currentPos <= zone.Max then
                            pressQTE()
                            task.wait(qteConfig.spamWaitTime)
                        else
                            break
                        end
                    end
                    task.wait(qteConfig.debounceTime)
                    return
                end
            end
        end
        
        local function setupQTEWatcher()
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not playerGui then return end
            local function checkForQTE()
                local ui = getQTEUI()
                if ui and not qteUI then
                    qteUI = ui
                    ui:GetPropertyChangedSignal("Visible"):Connect(function()
                        if ui.Visible then onQTEAppeared() else onQTEDisappeared() end
                    end)
                    if ui.Visible then onQTEAppeared() end
                end
            end
            checkForQTE()
            playerGui.ChildAdded:Connect(function(child)
                if child.Name == "TemporaryUI" or child.Name == "MainUI" then
                    task.wait(0.1) checkForQTE()
                end
            end)
            task.spawn(function()
                while autoQTEEnabled do
                    task.wait(0.5)
                    local ui = getQTEUI()
                    if ui and ui.Visible and not qteActive then onQTEAppeared()
                    elseif (not ui or not ui.Visible) and qteActive then onQTEDisappeared() end
                end
            end)
        end
        
        autoQTEEnabled = true
        qteActive = false
        qteStartTime = 0
        setupQTEWatcher()
        qteConnection = RunService.Heartbeat:Connect(function()
            if autoQTEEnabled then autoQTELoop() end
        end)
    end)
end

local function disarmQTEStop()
    if qteConnection then
        qteConnection:Disconnect()
        qteConnection = nil
    end
end

secQTE:Toggle({
    Title = "Enable Disarm QTE",
    Type = "Checkbox",
    Flag = "disarmQTEEnabled",
    Default = qteConfig.enabled,
    Callback = function(on)
        pcall(function()
            qteConfig.enabled = on
            if on then disarmQTEStart() else disarmQTEStop() end
        end)
    end
})

secQTE:Slider({
    Title = "Click Delay (s)",
    Flag = "qteClickDelay",
    Step = 0.01,
    Value = { Min = 0.01, Max = 0.5, Default = qteConfig.clickDelay },
    Callback = function(v)
        pcall(function()
            qteConfig.clickDelay = v
        end)
    end
})

secQTE:Slider({
    Title = "Debounce Time (s)",
    Flag = "qteDebounceTime",
    Step = 0.01,
    Value = { Min = 0.05, Max = 0.5, Default = qteConfig.debounceTime },
    Callback = function(v)
        pcall(function()
            qteConfig.debounceTime = v
        end)
    end
})

secQTE:Slider({
    Title = "Zone Margin",
    Flag = "qteZoneMargin",
    Step = 0.005,
    Value = { Min = 0.005, Max = 0.1, Default = qteConfig.zoneMargin },
    Callback = function(v)
        pcall(function()
            qteConfig.zoneMargin = v
        end)
    end
})

secQTE:Slider({
    Title = "Spam Click Interval (s)",
    Flag = "qteSpamWaitTime",
    Step = 0.005,
    Value = { Min = 0.005, Max = 0.1, Default = qteConfig.spamWaitTime },
    Callback = function(v)
        pcall(function()
            qteConfig.spamWaitTime = v
        end)
    end
})

secQTE:Slider({
    Title = "Pre-Click Attempts",
    Flag = "qtePreClickAttempts",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = qteConfig.preClickAttempts },
    Callback = function(v)
        pcall(function()
            qteConfig.preClickAttempts = v
        end)
    end
})

secQTE:Slider({
    Title = "Click Offset",
    Flag = "qteClickOffset",
    Step = 0.01,
    Value = { Min = -0.5, Max = 0.5, Default = qteConfig.clickOffset },
    Callback = function(v)
        pcall(function()
            qteConfig.clickOffset = v
        end)
    end
})

-- Interface Settings
local secInterface = tabSettings:Section({ Title = "Interface", Opened = false })

-- Spoof Usernames
spoofActive = false
local spoofText   = "SorsHub"
local spoofCache  = {}
local spoofConns  = {}

local function spoofApply(lbl)
    pcall(function()
        if not (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) then return end
        if lbl.Name ~= "Username" then return end
        if not spoofCache[lbl] then spoofCache[lbl] = lbl.Text end
        if spoofActive then lbl.Text = spoofText end
    end)
end

local function spoofRevert()
    pcall(function()
        for lbl, orig in pairs(spoofCache) do if lbl and lbl.Parent then lbl.Text = orig end end
        spoofCache = {}
    end)
end

local function spoofScan()
    pcall(function()
        local pg = lp:FindFirstChild("PlayerGui"); if not pg then return end
        task.defer(function()
            for _, root in ipairs({ pg:FindFirstChild("MainUI"), pg:FindFirstChild("TemporaryUI") }) do
                if root then for _, obj in ipairs(root:GetDescendants()) do spoofApply(obj) end end
            end
        end)
    end)
end

local function spoofWatch(root)
    pcall(function()
        if not root then return end
        table.insert(spoofConns, root.DescendantAdded:Connect(function(obj)
            if spoofActive then task.defer(spoofApply, obj) end
        end))
    end)
end

function spoofStart()
    pcall(function()
        for _, c in ipairs(spoofConns) do if c.Connected then c:Disconnect() end end
        spoofConns = {}
        local pg = lp:FindFirstChild("PlayerGui"); if not pg then return end
        spoofScan()
        spoofWatch(pg:FindFirstChild("MainUI"))
        spoofWatch(pg:FindFirstChild("TemporaryUI"))
        table.insert(spoofConns, pg.ChildAdded:Connect(function(child)
            if (child.Name == "MainUI" or child.Name == "TemporaryUI") and spoofActive then
                task.delay(0.1, spoofScan); spoofWatch(child)
            end
        end))
    end)
end

function spoofStop()
    pcall(function()
        for _, c in ipairs(spoofConns) do if c.Connected then c:Disconnect() end end
        spoofConns = {}; spoofRevert()
    end)
end

secInterface:Toggle({
    Title = "Spoof Usernames", Type = "Checkbox", Flag = "spoofActive", Default = spoofActive,
    Callback = function(on) pcall(function() spoofActive = on; if on then spoofStart() else spoofStop() end end) end
})

-- Show Chat Logs
chatForceEnabled = false
chatForceConn    = nil

function enforceChatOn()
    pcall(function()
        if not chatForceEnabled then return end
        local cw = svc.TextChat:FindFirstChild("ChatWindowConfiguration")
        local ci = svc.TextChat:FindFirstChild("ChatInputBarConfiguration")
        if cw and not cw.Enabled then cw.Enabled = true end
        if ci and not ci.Enabled then ci.Enabled = true end
    end)
end

secInterface:Toggle({
    Title = "Show Chat Logs", Type = "Checkbox", Flag = "chatForceEnabled", Default = chatForceEnabled,
    Callback = function(on)
        pcall(function()
            chatForceEnabled = on; 
            if chatForceConn then chatForceConn:Disconnect(); chatForceConn = nil end
            if on then
                enforceChatOn()
                chatForceConn = svc.Run.Heartbeat:Connect(enforceChatOn)
                for _, key in ipairs({ "ChatWindowConfiguration", "ChatInputBarConfiguration" }) do
                    local obj = svc.TextChat:FindFirstChild(key)
                    if obj then obj:GetPropertyChangedSignal("Enabled"):Connect(enforceChatOn) end
                end
            end
        end)
    end
})

-- Timer Position
timerSide = "Middle"

function applyTimerPos()
    pcall(function()
        local rt = lp.PlayerGui:FindFirstChild("RoundTimer")
        local m  = rt and rt:FindFirstChild("Main")
        if m then m.Position = UDim2.new(timerSide == "Middle" and 0.5 or 0.9, 0, m.Position.Y.Scale, m.Position.Y.Offset) end
    end)
end

applyTimerPos()

secInterface:Dropdown({
    Title = "Timer Position", Flag = "timerSide", Values = { "Middle", "Right" }, Value = timerSide,
    Callback = function(v) pcall(function() timerSide = v; applyTimerPos() end) end
})

-- Disable Jump Button
local jumpDisabled = false
local jumpBackup = nil

local function toggleJump(enabled)
    pcall(function()
        local gui = lp:FindFirstChild("PlayerGui")
        if not gui then return end
        local touchGui = gui:FindFirstChild("TouchGui")
        if not touchGui then return end
        local frame = touchGui:FindFirstChild("TouchControlFrame")
        if not frame then return end
        
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if enabled then
            local jump = frame:FindFirstChild("JumpButton")
            if jump then
                jumpBackup = jump:Clone()
                jump:Destroy()
                print("[SorsHub] Jump button disabled!")
            end
            if hum then
                hum.JumpPower = 0
                hum.Jump = false
            end
        else
            if jumpBackup then
                local newJump = jumpBackup:Clone()
                newJump.Parent = frame
                print("[SorsHub] Jump button enabled!")
            end
            if hum then
                hum.JumpPower = 50
            end
        end
    end)
end

secInterface:Toggle({
    Title = "Disable Jump", Type = "Checkbox", Flag = "jumpDisabled", Default = jumpDisabled,
    Callback = function(v)
        pcall(function()
            jumpDisabled = v
            toggleJump(v)
        end)
    end
})

lp.CharacterAdded:Connect(function(character)
    task.delay(0.5, function()
        pcall(function()
            if spoofActive then spoofStart() end
            applyTimerPos()
            if jumpDisabled then toggleJump(true) end
            if jumpDisabled then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = 0
                    hum.Jump = false
                end
            end
        end)
    end)
end)

task.delay(0.5, function()
    pcall(function()
        if jumpDisabled then
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = 0
                    hum.Jump = false
                end
            end
        end
    end)
end)

-- Platform Spoofer
local secPlatform = tabSettings:Section({ Title = "Platform Spoofer", Opened = false })
platEnabled = false
platDevice  = "Console"
local platLoop    = nil
local platConn    = nil

local function platPush()
    pcall(function()
        if not platEnabled then return end
        local net = getNetwork()
        if net then pcall(function() net:FireServerConnection("SetDevice", "REMOTE_EVENT", platDevice) end) end
    end)
end

function platStart()
    pcall(function()
        if platLoop then return end; platPush()
        if platConn then platConn:Disconnect() end
        platConn = svc.Input.LastInputTypeChanged:Connect(function() if platEnabled then platPush() end end)
        platLoop = task.spawn(function() while platEnabled do platPush(); task.wait(1) end; platLoop = nil end)
    end)
end

function platStop()
    pcall(function()
        platEnabled = false
        if platLoop then task.cancel(platLoop); platLoop = nil end
        if platConn then platConn:Disconnect(); platConn = nil end
    end)
end

secPlatform:Toggle({ Title = "Enable Spoofer", Type = "Checkbox", Flag = "platEnabled", Default = platEnabled,
    Callback = function(on) pcall(function() platEnabled = on; if on then platStart() else platStop() end end) end })

secPlatform:Dropdown({ Title = "Device", Flag = "platDevice", Values = { "PC", "Mobile", "Console" }, Value = platDevice,
    Callback = function(v) pcall(function() platDevice = v; if platEnabled then platPush() end end) end })

lp.CharacterAdded:Connect(function() task.delay(1, function() pcall(function() if platEnabled then platPush() end end) end) end)

-- EMOTES
local secEmotes = tabSettings:Section({ Title = "Emotes", Opened = false })

do
    local EmFolderPath = findPath(svc.RS, "Assets", "Emotes")

    local emState = {
        emoting = false, track = nil,
        spd = 16, jump = 50,
        rotConn = nil, guiOn = false, sg = nil,
        inputConns = {},
    }

    local function emStop()
        if not emState.emoting then return end
        emState.emoting = false
        if emState.rotConn then emState.rotConn:Disconnect(); emState.rotConn = nil end
        local ch = lp.Character
        if ch then
            local root = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
            local hum  = ch:FindFirstChildOfClass("Humanoid")
            local vfx  = ch:FindFirstChild("PlayerEmoteVFX"); if vfx then vfx:Destroy() end
            if root then
                root.Anchored = false
                local snd = root:FindFirstChild("EmoteSound"); if snd then snd:Destroy() end
                local att = root:FindFirstChild("RootAttachment"); if att then att:Destroy() end
            end
            if hum then hum.WalkSpeed = emState.spd; hum.JumpPower = emState.jump end
        end
        if emState.track then pcall(function() emState.track:Stop() end); emState.track = nil end
    end

    local function emPlay(mod)
        if emState.emoting then emStop(); task.wait(0.1) end
        local ch   = lp.Character; if not ch then return end
        local hum  = ch:FindFirstChildOfClass("Humanoid")
        local root = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
        local anim = hum and hum:WaitForChild("Animator", 2)
        if not hum or not root or not anim then return end
        local ok, data = pcall(require, mod)
        if not ok or not data.AssetID then return end
        emState.emoting = true
        emState.spd = hum.WalkSpeed; emState.jump = hum.JumpPower
        hum.WalkSpeed = 0; hum.JumpPower = 0; root.Anchored = true
        local an = Instance.new("Animation"); an.AnimationId = tostring(data.AssetID)
        emState.track = anim:LoadAnimation(an); emState.track.Looped = true; emState.track:Play()
        if emState.rotConn then emState.rotConn:Disconnect() end
        emState.rotConn = svc.Run.RenderStepped:Connect(function()
            if not emState.emoting then return end
            local cam = workspace.CurrentCamera; if not cam then return end
            if cam.CameraType ~= Enum.CameraType.Custom then return end
            local ch2 = lp.Character; if not ch2 then return end
            local r2  = ch2:FindFirstChild("HumanoidRootPart"); if not r2 then return end
            if lp.CameraMode ~= Enum.CameraMode.LockFirstPerson then return end
            local _, camY, _ = cam.CFrame:ToEulerAnglesYXZ()
            r2.CFrame = CFrame.new(r2.Position) * CFrame.Angles(0, camY, 0)
        end)
        if data.SFX then
            local old2 = root:FindFirstChild("EmoteSound"); if old2 then old2:Destroy() end
            local snd = Instance.new("Sound"); snd.Name = "EmoteSound"
            snd.SoundId = tostring(data.SFX); snd.Volume = 1; snd.Looped = true
            snd.RollOffMode = Enum.RollOffMode.Inverse
            snd.RollOffMaxDistance = 60; snd.RollOffMinDistance = 10
            snd.Parent = root; snd:Play()
        end
        local att = Instance.new("Attachment"); att.Name = "RootAttachment"; att.Parent = root
        local burst = Instance.new("ParticleEmitter"); burst.Name = "EmoteBurst"
        burst.Texture = "rbxassetid://635533604"; burst.Rate = 60
        burst.Speed = NumberRange.new(2,5); burst.Lifetime = NumberRange.new(0.5,1.2)
        burst.Drag = 5; burst.Parent = att
        if string.lower(mod.Name) == "hakaridance" or string.lower(mod.Name) == "hakari" then
            local beamVFX = mod:FindFirstChild("HakariBeamEffect")
            if beamVFX then
                local v3 = beamVFX:Clone(); v3.Name = "PlayerEmoteVFX"
                v3.CFrame = root.CFrame * CFrame.new(0,-1,-0.3)
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = root; weld.Part1 = v3; weld.Parent = v3; v3.Parent = ch
            end
        end
        local remote = svc.RS:FindFirstChild("EmoteHandler") or svc.RS:FindFirstChild("PlayEmote") or svc.RS:FindFirstChild("Emote")
        if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer("PlayEmote", mod.Name) end) end
    end

    -- Optimisation: every rebuild used to leak 3 UserInputService connections.
    local function emBindInput(fn)
        local conn = svc.Input.InputChanged:Connect(fn)
        table.insert(emState.inputConns, conn)
        return conn
    end

    local function emClearInputs()
        for _, conn in ipairs(emState.inputConns) do pcall(function() conn:Disconnect() end) end
        emState.inputConns = {}
    end

    local function buildEmoteGui()
        if emState.sg and emState.sg.Parent then return end
        emClearInputs()
        local PGui2 = lp:WaitForChild("PlayerGui")
        local old3 = PGui2:FindFirstChild("V1PR_EmoteGUI"); if old3 then old3:Destroy() end
        local SG2 = Instance.new("ScreenGui"); SG2.Name = "V1PR_EmoteGUI"
        SG2.ResetOnSpawn = false; SG2.IgnoreGuiInset = true
        SG2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG2.Parent = PGui2
        emState.sg = SG2
        local function rnd2(i,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=i end
        local function tw2(o,t,p) svc.TS:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
        local Tog2=Instance.new("TextButton"); Tog2.Size=UDim2.new(0,50,0,50); Tog2.Position=UDim2.new(1,-70,1,-70)
        Tog2.Text="🎵"; Tog2.TextSize=24; Tog2.BackgroundColor3=Color3.fromRGB(30,30,40)
        Tog2.AutoButtonColor=false; Tog2.BorderSizePixel=0; Tog2.ZIndex=20; Tog2.Parent=SG2; rnd2(Tog2,25)
        local togDragging=false; local togDragStart; local togStartPos; local togMoved=false
        Tog2.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                togDragging=true; togMoved=false
                togDragStart=inp.Position; togStartPos=Tog2.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then togDragging=false end
                end)
            end
        end)
        emBindInput(function(inp)
            if togDragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                local d=inp.Position-togDragStart
                if d.Magnitude > 4 then togMoved=true end
                Tog2.Position=UDim2.new(togStartPos.X.Scale,togStartPos.X.Offset+d.X,togStartPos.Y.Scale,togStartPos.Y.Offset+d.Y)
            end
        end)
        local PW,PH=220,340
        local Panel2=Instance.new("Frame"); Panel2.Size=UDim2.new(0,PW,0,PH)
        Panel2.Position=UDim2.new(0.5,-PW/2,0.5,-PH/2); Panel2.BackgroundColor3=Color3.fromRGB(16,16,22)
        Panel2.BorderSizePixel=0; Panel2.ClipsDescendants=true; Panel2.Visible=false; Panel2.ZIndex=15; Panel2.Parent=SG2; rnd2(Panel2,10)
        local drag2,dInp2,dSt2,sSt2
        Panel2.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                drag2=true; dSt2=inp.Position; sSt2=Panel2.Position
                inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then drag2=false end end)
            end
        end)
        emBindInput(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dInp2=inp end
        end)
        emBindInput(function(inp)
            if inp==dInp2 and drag2 then
                local d=inp.Position-dSt2
                Panel2.Position=UDim2.new(sSt2.X.Scale,sSt2.X.Offset+d.X,sSt2.Y.Scale,sSt2.Y.Offset+d.Y)
            end
        end)
        local Ac2=Instance.new("Frame"); Ac2.Size=UDim2.new(1,0,0,2); Ac2.BackgroundColor3=Color3.fromRGB(80,140,255); Ac2.BorderSizePixel=0; Ac2.Parent=Panel2
        local Hdr2=Instance.new("Frame"); Hdr2.Size=UDim2.new(1,0,0,34); Hdr2.Position=UDim2.new(0,0,0,2); Hdr2.BackgroundTransparency=1; Hdr2.Parent=Panel2
        local HTit2=Instance.new("TextLabel"); HTit2.Size=UDim2.new(1,-36,1,0); HTit2.Position=UDim2.new(0,10,0,0)
        HTit2.Text="Emotes"; HTit2.TextSize=14; HTit2.Font=Enum.Font.GothamBold
        HTit2.TextColor3=Color3.fromRGB(220,220,235); HTit2.BackgroundTransparency=1
        HTit2.TextXAlignment=Enum.TextXAlignment.Left; HTit2.Parent=Hdr2
        local CX2=Instance.new("TextButton"); CX2.Size=UDim2.new(0,26,0,26); CX2.Position=UDim2.new(1,-30,0,4)
        CX2.Text="✕"; CX2.TextSize=12; CX2.Font=Enum.Font.GothamBold
        CX2.TextColor3=Color3.fromRGB(140,140,160); CX2.BackgroundColor3=Color3.fromRGB(30,30,42)
        CX2.AutoButtonColor=false; CX2.BorderSizePixel=0; CX2.Parent=Hdr2; rnd2(CX2,6)
        local Srch2=Instance.new("TextBox"); Srch2.Size=UDim2.new(1,-12,0,28); Srch2.Position=UDim2.new(0,6,0,38)
        Srch2.PlaceholderText="Search..."; Srch2.Text=""
        Srch2.TextColor3=Color3.fromRGB(210,210,225); Srch2.PlaceholderColor3=Color3.fromRGB(90,90,110)
        Srch2.TextSize=12; Srch2.Font=Enum.Font.Gotham; Srch2.BackgroundColor3=Color3.fromRGB(24,24,34)
        Srch2.BorderSizePixel=0; Srch2.ClearTextOnFocus=false; Srch2.Parent=Panel2; rnd2(Srch2,6)
        do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8); p.Parent=Srch2 end
        local Scrl2=Instance.new("ScrollingFrame"); Scrl2.Size=UDim2.new(1,-8,1,-106); Scrl2.Position=UDim2.new(0,4,0,72)
        Scrl2.BackgroundTransparency=1; Scrl2.BorderSizePixel=0; Scrl2.CanvasSize=UDim2.new(0,0,0,0)
        Scrl2.ScrollBarThickness=3; Scrl2.ScrollBarImageColor3=Color3.fromRGB(80,140,255)
        Scrl2.ScrollBarImageTransparency=0.5; Scrl2.ScrollingDirection=Enum.ScrollingDirection.Y; Scrl2.Parent=Panel2
        local LL3=Instance.new("UIListLayout"); LL3.SortOrder=Enum.SortOrder.LayoutOrder; LL3.Padding=UDim.new(0,2); LL3.Parent=Scrl2
        LL3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scrl2.CanvasSize=UDim2.new(0,0,0,LL3.AbsoluteContentSize.Y+6)
        end)
        local Dv2=Instance.new("Frame"); Dv2.Size=UDim2.new(1,0,0,1); Dv2.Position=UDim2.new(0,0,1,-37)
        Dv2.BackgroundColor3=Color3.fromRGB(36,36,50); Dv2.BorderSizePixel=0; Dv2.Parent=Panel2
        local Stp2=Instance.new("TextButton"); Stp2.Size=UDim2.new(1,0,0,36); Stp2.Position=UDim2.new(0,0,1,-36)
        Stp2.Text="■  Stop Emote"; Stp2.TextSize=12; Stp2.Font=Enum.Font.GothamBold
        Stp2.TextColor3=Color3.fromRGB(255,100,100); Stp2.BackgroundColor3=Color3.fromRGB(22,14,14)
        Stp2.AutoButtonColor=false; Stp2.BorderSizePixel=0; Stp2.Parent=Panel2
        Stp2.MouseEnter:Connect(function() tw2(Stp2,0.1,{BackgroundColor3=Color3.fromRGB(40,16,16)}) end)
        Stp2.MouseLeave:Connect(function() tw2(Stp2,0.1,{BackgroundColor3=Color3.fromRGB(22,14,14)}) end)
        Stp2.MouseButton1Click:Connect(function() emStop() end)
        local rows2={}
        local function refreshList2(q)
            for _,r in ipairs(rows2) do pcall(function() r:Destroy() end) end; rows2={}
            q=q and string.lower(q) or ""
            if not EmFolderPath then return end
            local emotes={}
            for _,v in ipairs(EmFolderPath:GetDescendants()) do if v:IsA("ModuleScript") then table.insert(emotes,v) end end
            table.sort(emotes,function(a,b) return a.Name<b.Name end)
            local n=0
            for _,ch in ipairs(emotes) do
                if q=="" or string.find(string.lower(ch.Name),q,1,true) then
                    n+=1
                    local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,28)
                    row.Text=ch.Name; row.TextColor3=Color3.fromRGB(200,200,215)
                    row.TextSize=11; row.Font=Enum.Font.Gotham; row.TextXAlignment=Enum.TextXAlignment.Left
                    row.BackgroundColor3=Color3.fromRGB(22,22,32); row.BackgroundTransparency=0
                    row.AutoButtonColor=false; row.BorderSizePixel=0; row.LayoutOrder=n; row.Parent=Scrl2; rnd2(row,4)
                    do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=row end
                    row.MouseEnter:Connect(function()     tw2(row,0.08,{BackgroundColor3=Color3.fromRGB(38,38,56)}) end)
                    row.MouseLeave:Connect(function()     tw2(row,0.08,{BackgroundColor3=Color3.fromRGB(22,22,32)}) end)
                    row.MouseButton1Down:Connect(function() tw2(row,0.05,{BackgroundColor3=Color3.fromRGB(50,80,160)}) end)
                    row.MouseButton1Click:Connect(function() emPlay(ch) end)
                    table.insert(rows2,row)
                end
            end
            if n==0 then
                local e=Instance.new("TextLabel"); e.Size=UDim2.new(1,0,0,28); e.Text="None found"
                e.TextColor3=Color3.fromRGB(90,90,110); e.TextSize=11; e.Font=Enum.Font.Gotham
                e.BackgroundTransparency=1; e.TextXAlignment=Enum.TextXAlignment.Center; e.Parent=Scrl2
                table.insert(rows2,e)
            end
        end
        Srch2:GetPropertyChangedSignal("Text"):Connect(function() refreshList2(Srch2.Text) end)
        local pOpen2=false
        local function setPanel2(open)
            pOpen2=open; Tog2.Text=open and "✕" or "🎵"; Panel2.Visible=open
            if open then refreshList2(Srch2.Text) end
        end
        Tog2.MouseButton1Click:Connect(function() if not togMoved then setPanel2(not pOpen2) end; togMoved=false end)
        CX2.MouseButton1Click:Connect(function() setPanel2(false) end)
    end

    local function destroyEmoteGui()
        emStop()
        emClearInputs()
        if emState.sg then emState.sg:Destroy(); emState.sg=nil end
    end

    secEmotes:Toggle({
        Title="Show Emotes GUI", Type="Checkbox", Flag="emoteGuiOn", Default=false,
        Callback=function(on) pcall(function()
            emState.guiOn=on
            if on then buildEmoteGui() else destroyEmoteGui() end
        end) end
    })

    lp.CharacterAdded:Connect(function() task.wait(0.5); if emState.emoting then emStop() end end)
    lp.CharacterRemoving:Connect(function() if emState.emoting then emStop() end end)
end

-- UI SETTINGS (ported UI settings section)
local secUISettings = tabSettings:Section({ Title = "UI Settings", Opened = false })

local SORSHUB_FONT_MAP = {
    ["Gotham"]       = "GothamSSm",
    ["Arial"]        = "Arial",
    ["Roboto"]       = "Roboto",
    ["Source Sans"]  = "SourceSansPro",
    ["Accanthis"]    = "AccanthisADFStd",
    ["Montserrat"]   = "Montserrat",
    ["Sarpanch"]     = "Sarpanch",
    ["Builder Sans"] = "BuilderSans",
}

function applySorshubFont(name)
    local family = SORSHUB_FONT_MAP[tostring(name)]
    if family then
        pcall(function() ui:SetFont("rbxasset://fonts/families/" .. family .. ".json") end)
    end
end

secUISettings:Dropdown({
    Title = "UI Font",
    Flag = "uiFont",
    Values = { "Gotham", "Arial", "Roboto", "Source Sans", "Accanthis", "Montserrat", "Sarpanch", "Builder Sans" },
    Value = "Gotham",
    Callback = applySorshubFont,
})

secUISettings:Button({
    Title = "Reset Font to SorsHub Default",
    Icon = "rotate-ccw",
    Callback = function() applySorshubFont("Accanthis") end,
})

function applySorshubMenuKey(name)
    local key = Enum.KeyCode[tostring(name)]
    if key then pcall(function() win:SetToggleKey(key) end) end
end

secUISettings:Keybind({
    Title = "Menu Toggle Keybind",
    Flag = "menuKeybind",
    Value = "L",
    Callback = applySorshubMenuKey,
})

end -- tabSettings

-- ============================================================
-- GLOBAL TAB
-- ============================================================

do -- tabGlobal
tabGlobal  = win:Tab({ Title = "Global", Icon = "globe" })

-- Stamina
local secStamina = tabGlobal:Section({ Title = "Stamina", Opened = true })

stam = {
    on      = false,
    loss    = 10,
    gain    = 20,
    max     = 100,
    current = 100,
    noLoss  = false,
    thread  = nil,
}

local _stamMod = nil
local _stamOrigInit = nil

local function stamModule()
    if _stamMod then return _stamMod end
    local m = safeRequirePath(svc.RS, "Systems", "Character", "Game", "Sprinting")
    if m then _stamMod = m; _stamOrigInit = m.Init end
    return m
end

local function stamIsKiller()
    local ch = lp.Character; if not ch then return false end
    local kf = getTeamFolder("Killers")
    return kf and ch:IsDescendantOf(kf)
end

local function stamPatchInit(m)
    if not m then return end
    m.Init = function(...)
        local res = (_stamOrigInit or function() end)(...)
        m.StaminaLossDisabled = true
        return res
    end
end

local function stamUnpatchInit(m)
    if not m or not _stamOrigInit then return end
    m.Init = _stamOrigInit
end

function stamApply()
    pcall(function()
        local m = stamModule(); if not m then return end
        if not m.DefaultsSet then pcall(function() m.Init() end) end
        local forceNoLoss = stam.noLoss or stamIsKiller()
        m.StaminaLoss = stam.loss; m.StaminaGain = stam.gain
        local abilityCapActive = type(m.StaminaCap) == "number" and m.StaminaCap < (m.MaxStamina or math.huge)
        if not abilityCapActive then
            m.MaxStamina = stam.max
            if type(m.StaminaCap) == "number" then m.StaminaCap = stam.max end
        end
        m.StaminaLossDisabled = forceNoLoss
        if forceNoLoss then stamPatchInit(m) else stamUnpatchInit(m) end
        if m.Stamina and m.Stamina > stam.max then m.Stamina = stam.current end
        pcall(function() if m.__staminaChangedEvent then m.__staminaChangedEvent:Fire() end end)
    end)
end

function stamStart()
    if stam.thread then return end
    stam.thread = task.spawn(function()
        while stam.on do
            pcall(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then stamApply() end
            end)
            task.wait(0.5)
        end; stam.thread = nil
    end)
end

local function stamStop()
    stam.on = false
    if stam.thread then task.cancel(stam.thread); stam.thread = nil end
end

secStamina:Toggle({ Title = "Custom Stamina", Type = "Checkbox", Flag = "stamOn", Default = stam.on,
    Callback = function(on) pcall(function() if stam then stam.on = on; if on then stamStart() else stamStop() end end end) end })

secStamina:Slider({ Title = "Loss Rate",     Flag = "stamLoss", Step = 1, Value = { Min = 0,  Max = 50,  Default = stam.loss    }, Callback = function(v) pcall(function() stam.loss = v end) end })
secStamina:Slider({ Title = "Gain Rate",     Flag = "stamGain", Step = 1, Value = { Min = 0,  Max = 50,  Default = stam.gain    }, Callback = function(v) pcall(function() stam.gain = v end) end })
secStamina:Slider({ Title = "Max Pool",      Flag = "stamMax", Step = 1, Value = { Min = 50, Max = 500, Default = stam.max     }, Callback = function(v) pcall(function() stam.max = v end) end })
secStamina:Slider({ Title = "Current Value", Flag = "stamCurrent", Step = 1, Value = { Min = 0,  Max = 500, Default = stam.current }, Callback = function(v) pcall(function() stam.current = v end) end })
secStamina:Toggle({ Title = "Infinite Stamina", Type = "Checkbox", Flag = "stamNoLoss", Default = stam.noLoss,
    Callback = function(on)
        pcall(function()
            stam.noLoss = on
            local m = stamModule()
            if m then
                m.StaminaLossDisabled = on
                if on then
                    stamPatchInit(m)
                else
                    stamUnpatchInit(m)
                end
            end
            stamApply()
        end)
    end
})

pcall(function()
    local m = stamModule()
    if m then
        m.StaminaLossDisabled = true
        stamPatchInit(m)
    end
end)

if stam.on then stamStart() end

lp.CharacterAdded:Connect(function()
    task.delay(1.5, function()
        pcall(function()
            if stam.on then stamApply(); if not stam.thread then stamStart() end end
        end)
    end)
end)

-- Speed Hack
local secSpeed = tabGlobal:Section({ Title = "Speed Hack", Opened = false })
speedHack = { on=false, speed=30, thread=nil, lastApplied=0 }

local function speedModule()
    return safeRequirePath(svc.RS, "Systems", "Character", "Game", "Sprinting")
end

local function speedApply()
    pcall(function()
        if not speedHack.on then return end
        local m = speedModule(); if not m then return end
        if not m.DefaultsSet then pcall(function() m.Init() end) end
        if speedHack.speed ~= speedHack.lastApplied then
            m.SprintSpeed = speedHack.speed; pcall(function() m.MaxSprintSpeed = speedHack.speed end)
            speedHack.lastApplied = speedHack.speed
        end
    end)
end

function speedStart()
    if speedHack.thread then return end
    speedHack.thread = task.spawn(function()
        while speedHack.on do
            pcall(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then speedApply() end
            end)
            task.wait(0.2)
        end; speedHack.thread = nil
    end)
end

local function speedStop()
    speedHack.on = false
    if speedHack.thread then task.cancel(speedHack.thread); speedHack.thread = nil end
    pcall(function()
        local m = speedModule(); if m then m.SprintSpeed = 26; pcall(function() m.MaxSprintSpeed = 26 end) end
    end)
end

lp.CharacterAdded:Connect(function()
    task.delay(1, function() pcall(function() speedHack.lastApplied=0; if speedHack.on then speedApply(); if not speedHack.thread then speedStart() end end end) end)
end)

if speedHack.on then speedStart() end

secSpeed:Toggle({ Title="Custom Sprint Speed", Type="Checkbox", Flag="speedOn", Default=speedHack.on,
    Callback=function(on) pcall(function() if speedHack then speedHack.on=on; speedHack.lastApplied=0; if on then speedStart() else speedStop() end end end) end })

secSpeed:Input({ Title="Sprint Speed Value", Flag="speedValue", CurrentValue=tostring(speedHack.speed), Placeholder="e.g. 30",
    Callback=function(t) pcall(function() local n=tonumber(t); if n and n>0 and n<=200 then speedHack.speed=n; speedHack.lastApplied=0 end end) end })

-- Status Effects
local secStatus = tabGlobal:Section({ Title = "Status", Opened = false })

local statusGroups = {
    Slowness      = { on = false, paths = { "Modules.Schematics.StatusEffects.Slowness" } },
    Hallucination = { on = false, paths = { "Modules.Schematics.StatusEffects.KillerExclusive.Hallucination" } },
    Visual        = { on = false, paths = {
        "Modules.Schematics.StatusEffects.Blindness",
        "Modules.Schematics.StatusEffects.SurvivorExclusive.Subspaced",
        "Modules.Schematics.StatusEffects.KillerExclusive.Glitched",
    }},
}

local statusBackup = {}

local function statusResolve(path)
    local node = svc.RS
    for seg in path:gmatch("[^%.]+") do node = node:FindFirstChild(seg); if not node then return nil end end
    return node
end

local function statusBlock(path)
    pcall(function()
        if statusBackup[path] then return end
        local mod = statusResolve(path); if not mod then return end
        if mod:IsA("Folder") then
            statusBackup[path] = { clone = mod:Clone(), isFolder = true, parentPath = path:match("^(.-)%.?[^%.]+$") }
            mod:Destroy()
        elseif mod:IsA("ModuleScript") or mod:IsA("LocalScript") then
            statusBackup[path] = { clone = mod:Clone(), src = mod.Source, isFolder = false }
            mod:Destroy()
        end
    end)
end

local function statusRestore(path)
    pcall(function()
        local saved = statusBackup[path]; if not saved then return end
        local existing = statusResolve(path); if existing then existing:Destroy() end
        local parentPath = saved.parentPath or path:match("^(.-)%.?[^%.]+$")
        local parent = statusResolve(parentPath)
        if parent then
            if not saved.isFolder then saved.clone.Source = saved.src end
            saved.clone.Parent = parent
        end
        statusBackup[path] = nil
    end)
end

local statusLoopThread = nil

local function statusTick()
    if statusLoopThread then return end
    statusLoopThread = task.spawn(function()
        while true do
            local any = false
            for _, g in pairs(statusGroups) do
                if g.on then any = true; for _, p in ipairs(g.paths) do local m = statusResolve(p); if m then m:Destroy() end end end
            end
            if not any then break end; task.wait(0.8)
        end; statusLoopThread = nil
    end)
end

local function statusToggle(name)
    pcall(function()
        local g = statusGroups[name]; if not g then return end; g.on = not g.on
        for _, p in ipairs(g.paths) do if g.on then statusBlock(p) else statusRestore(p) end end
        local any = false; for _, sg in pairs(statusGroups) do if sg.on then any = true; break end end
        if any then statusTick() elseif statusLoopThread then task.cancel(statusLoopThread); statusLoopThread = nil end
    end)
end

secStatus:Toggle({ Title = "Disable Slowness",       Default = false, Callback = function(v) if v then statusToggle("Slowness") end end })
secStatus:Toggle({ Title = "Disable Hallucination",  Default = false, Callback = function(v) if v then statusToggle("Hallucination") end end })
secStatus:Toggle({ Title = "Disable Visual Effects", Default = false, Callback = function(v) if v then statusToggle("Visual") end end })

lp.CharacterAdded:Connect(function()
    pcall(function()
        statusBackup = {}; for _, g in pairs(statusGroups) do g.on = false end
        if statusLoopThread then task.cancel(statusLoopThread); statusLoopThread = nil end
    end)
end)

-- Hitbox Expander
local secHitbox = tabGlobal:Section({ Title = "Hitbox", Opened = false })
hb = { on = false, strength = 50, conn = nil, active = {} }

local hbAbilities = {
    Slash=1,Swing=1,Dagger=1,Punch=1,PlasmaBeam=1,Shoot=1,Behead=1,
    GashingWound=1,WalkspeedOverride=1,Stab=1,Nova=1,MassInfection=1,
    Axe=1,["INFERNALCRY"]=1,["Carving Slash"]=1,Carving=1,
}

local function hbReadName(raw)
    if typeof(raw) == "buffer" then
        local s = buffer.tostring(raw)
        local name = s:match("^[%c%z%p]*(.+)$") or s
        name = name:match("^(.-)%s*$") or name
        return name ~= "" and name or nil
    end
    return tostring(raw):gsub("\"","")
end

local function hbPush(dist)
    pcall(function()
        local ch = lp.Character; if not ch then return end
        local r  = ch:FindFirstChild("HumanoidRootPart"); if not r then return end
        local was = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = was + r.CFrame.LookVector * dist
        svc.Run.RenderStepped:Wait()
        if ch and ch.Parent and r and r.Parent then r.AssemblyLinearVelocity = was end
    end)
end

function hbStart()
    pcall(function()
        if hb.conn then return end
        local remote = hbGetRemote()
        if not remote then warn("[SorsHub] hbStart: could not find RemoteEvent for hitbox — feature disabled"); return end
        hb.conn = remote.OnClientEvent:Connect(function(action, data)
            if not hb.on or action ~= "UseActorAbility" then return end
            if typeof(data) ~= "table" or not data[1] then return end
            local name = hbReadName(data[1])
            if not name or not hbAbilities[name] or hb.active[name] then return end
            hb.active[name] = true; local t0 = tick()
            local c; c = svc.Run.Heartbeat:Connect(function()
                if tick() - t0 >= 1 then c:Disconnect(); hb.active[name] = nil; return end
                if hb.on then hbPush(hb.strength) else c:Disconnect(); hb.active[name] = nil end
            end)
        end)
    end)
end

function hbStop()
    pcall(function()
        if hb.conn then hb.conn:Disconnect(); hb.conn = nil end
        for k in pairs(hb.active) do hb.active[k] = nil end
    end)
end

secHitbox:Toggle({ Title = "Hitbox Expander", Type = "Checkbox", Flag = "hbOn", Default = hb.on,
    Callback = function(on) pcall(function() if hb then hb.on = on; if on then hbStart() else hbStop() end end end) end })

secHitbox:Slider({ Title = "Strength", Flag = "hbStrength", Step = 1, Value = { Min = 5, Max = 100, Default = hb.strength },
    Callback = function(v) pcall(function() hb.strength = v end) end })

lp.CharacterAdded:Connect(function()
    pcall(function()
        for k in pairs(hb.active) do hb.active[k] = nil end
        task.delay(1, function() if hb.on then hbStop(); hbStart() end end)
    end)
end)

lp.CharacterRemoving:Connect(function() pcall(function() for k in pairs(hb.active) do hb.active[k] = nil end end) end)

-- Auto Collision
ac = {
    on         = false,
    strength   = 50,
    maxDist    = 100,
    active     = {},
    chaseTarget  = nil,
    damageTarget = nil,
}

local function acGetHRP(model)
    if not model or not model.Parent then return nil end
    local h = model:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    local r = model:FindFirstChild("HumanoidRootPart")
    return r and r.Parent and r or nil
end

local function acFindChaseTarget()
    local sf = getTeamFolder("Survivors"); if not sf then return nil end
    for _, model in ipairs(sf:GetChildren()) do
        if model ~= lp.Character and model:IsA("Model") then
            local chased = model:GetAttribute("IsChased") or model:GetAttribute("InChase")
                        or model:GetAttribute("ChasedBy") or model:GetAttribute("IsBeingChased")
            if chased and chased ~= false and chased ~= "" then
                local r = acGetHRP(model); if r then return r end
            end
        end
    end
    return nil
end

local function acPickTarget()
    if ac.chaseTarget and ac.chaseTarget.Parent then
        local model = ac.chaseTarget.Parent
        local h = model:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then
            local chased = model:GetAttribute("IsChased") or model:GetAttribute("InChase")
                        or model:GetAttribute("ChasedBy") or model:GetAttribute("IsBeingChased")
            if chased and chased ~= false and chased ~= "" then return ac.chaseTarget end
        end
        ac.chaseTarget = nil
    end
    local fresh = acFindChaseTarget()
    if fresh then ac.chaseTarget = fresh; return fresh end
    if ac.damageTarget and ac.damageTarget.Parent then
        local model = ac.damageTarget.Parent
        local h = model:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return ac.damageTarget end
        ac.damageTarget = nil    end
    local sf = getTeamFolder("Survivors"); local myChar = lp.Character
    if not sf or not myChar then return nil end
    local origin = myChar:FindFirstChild("QueryHitbox", true) or myChar:FindFirstChild("HumanoidRootPart")
    if not origin then return nil end
    local myPos = origin.Position
    local best, bd = nil, math.huge
    for _, model in ipairs(sf:GetChildren()) do
        if model ~= myChar and model:IsA("Model") then
            local r = acGetHRP(model)
            if r then local d = (r.Position - myPos).Magnitude; if d < bd and d <= ac.maxDist then bd = d; best = r end end
        end
    end
    return best
end

local function acPickKillerTarget()
    local kf = getTeamFolder("Killers"); local myChar = lp.Character
    if not kf or not myChar then return nil end
    local origin = myChar:FindFirstChild("HumanoidRootPart"); if not origin then return nil end
    local myPos = origin.Position
    local best, bd = nil, math.huge
    for _, model in ipairs(kf:GetChildren()) do
        if model ~= myChar and model:IsA("Model") then
            local r = acGetHRP(model)
            if r then local d = (r.Position - myPos).Magnitude; if d < bd and d <= ac.maxDist then bd = d; best = r end end
        end
    end
    return best
end

local function acPush(targetRoot, facingOverrideCFrame)
    pcall(function()
        if not targetRoot or not targetRoot.Parent then return end
        local myChar = lp.Character; if not myChar then return end
        local hrp = myChar:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local dir = (targetRoot.Position - hrp.Position)
        if dir.Magnitude < 0.1 then return end
        dir = dir.Unit
        local lookDir
        if facingOverrideCFrame then
            lookDir = facingOverrideCFrame.LookVector * Vector3.new(1, 0, 1)
        else
            lookDir = dir * Vector3.new(1, 0, 1)
        end
        if lookDir.Magnitude > 0.01 then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir.Unit)
        end
        local was = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = was + dir * ac.strength
        svc.Run.RenderStepped:Wait()
        if myChar and myChar.Parent and hrp and hrp.Parent then hrp.AssemblyLinearVelocity = was end
    end)
end

local acAttrConns = {}

local function acWatchModel(model)
    pcall(function()
        if acAttrConns[model] then return end
        acAttrConns[model] = model.AttributeChanged:Connect(function(attr)
            if attr ~= "IsChased" and attr ~= "InChase" and attr ~= "ChasedBy" and attr ~= "IsBeingChased" then return end
            local chased = model:GetAttribute(attr)
            if chased and chased ~= false and chased ~= "" then
                local r = acGetHRP(model); if r then ac.chaseTarget = r end
            else
                if ac.chaseTarget and ac.chaseTarget.Parent == model then ac.chaseTarget = nil end
            end
        end)
    end)
end

local function acStopWatchModel(model)
    pcall(function()
        if acAttrConns[model] then pcall(function() acAttrConns[model]:Disconnect() end); acAttrConns[model] = nil end
    end)
end

local function acSetupWatchers()
    pcall(function()
        local sf = getTeamFolder("Survivors"); if not sf then return end
        for _, model in ipairs(sf:GetChildren()) do if model:IsA("Model") then acWatchModel(model) end end
        sf.ChildAdded:Connect(function(child) if child:IsA("Model") then task.wait(0.1); acWatchModel(child) end end)
        sf.ChildRemoved:Connect(function(child)
            acStopWatchModel(child)
            if ac.chaseTarget  and ac.chaseTarget.Parent  == child then ac.chaseTarget  = nil end
            if ac.damageTarget and ac.damageTarget.Parent == child then ac.damageTarget = nil end
        end)
    end)
end

task.spawn(function()
    pcall(function()
        local remote = hbGetRemote()
        if not remote then warn("[SorsHub] AutoCollision: could not find RemoteEvent — feature disabled"); return end
        task.spawn(acSetupWatchers)
        remote.OnClientEvent:Connect(function(action, data)
            if not ac.on then return end
            if action ~= "UseActorAbility" then return end
            if typeof(data) ~= "table" or not data[1] then return end
            local name = hbReadName(data[1])
            if not name or not hbAbilities[name] then return end
            if ac.active[name] then return end
            local myChar = lp.Character
            local killerFolder   = getTeamFolder("Killers")
            local survivorFolder = getTeamFolder("Survivors")
            local amKiller   = killerFolder   and myChar and myChar:IsDescendantOf(killerFolder)
            local amSurvivor = survivorFolder and myChar and myChar:IsDescendantOf(survivorFolder)
            if amKiller and data[2] and typeof(data[2]) == "Instance" then
                local hrpTarget = nil
                if data[2]:IsA("Model") then
                    hrpTarget = data[2]:FindFirstChild("HumanoidRootPart")
                elseif data[2]:IsA("BasePart") then
                    local model = data[2]:FindFirstAncestorOfClass("Model")
                    if model then hrpTarget = model:FindFirstChild("HumanoidRootPart") end
                end
                if hrpTarget and hrpTarget.Parent then
                    local sf = getTeamFolder("Survivors")
                    if sf and hrpTarget.Parent:IsDescendantOf(sf) then
                        local h = hrpTarget.Parent:FindFirstChildOfClass("Humanoid")
                        if h and h.Health > 0 then ac.damageTarget = hrpTarget end
                    end
                end
            end
            ac.active[name] = true
            local t0 = tick()
            local conn; conn = svc.Run.Heartbeat:Connect(function()
                if tick() - t0 >= 1 or not ac.on then conn:Disconnect(); ac.active[name] = nil; return end
                local target
                local facingOverride = nil
                if amKiller then
                    target = acPickTarget()
                elseif amSurvivor then
                    target = acPickKillerTarget()
                    if target and target.Parent and target.Parent.Name == "TwoTime" and name == "Stab" then
                        facingOverride = target.CFrame
                    end
                end
                if target then task.spawn(acPush, target, facingOverride) end
            end)
        end)
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if ac.on then local fresh = acFindChaseTarget(); if fresh then ac.chaseTarget = fresh end end
        end)
    end
end)

lp.CharacterAdded:Connect(function()
    pcall(function()
        for k in pairs(ac.active) do ac.active[k] = nil end
        ac.chaseTarget = nil; ac.damageTarget = nil
    end)
end)

lp.CharacterRemoving:Connect(function()
    pcall(function()
        for k in pairs(ac.active) do ac.active[k] = nil end
        ac.chaseTarget = nil; ac.damageTarget = nil
    end)
end)

local secAutoCollision = tabGlobal:Section({ Title = "Auto Collision", Opened = false })

secAutoCollision:Toggle({
    Title = "Push Hitbox on Ability", Type = "Checkbox", Flag = "acOn", Default = ac.on,
    Callback = function(on)
        pcall(function()
            if ac then ac.on = on; 
            if not on then for k in pairs(ac.active) do ac.active[k] = nil end; ac.chaseTarget = nil; ac.damageTarget = nil end end
        end)
    end
})

secAutoCollision:Slider({ Title = "Push Strength", Flag = "acStrength", Step = 1, Value = { Min = 5,  Max = 100, Default = ac.strength }, Callback = function(v) pcall(function() ac.strength = v end) end })
secAutoCollision:Slider({ Title = "Max Distance",  Flag = "acMaxDist", Step = 5, Value = { Min = 20, Max = 200, Default = ac.maxDist  }, Callback = function(v) pcall(function() ac.maxDist = v end) end })

end -- tabGlobal

-- ============================================================
-- GENERATOR SECTION (GLOBAL)
-- ============================================================

do -- tabGen
local tabGen     = tabGlobal -- Generator controls are grouped under Global
local secGenAuto = tabGen:Section({ Title = "Auto Solve", Opened = false })

flow = { on = false, nodeDelay = 0.04, lineDelay = 0.60 }

local function flowKey(n) return n.row.."-"..n.col end

local function flowNeighbour(r1,c1,r2,c2)
    if r2==r1-1 and c2==c1 then return"up" end; if r2==r1+1 and c2==c1 then return"down" end
    if r2==r1 and c2==c1-1 then return"left" end; if r2==r1 and c2==c1+1 then return"right" end; return false
end

local function flowOrder(path, endpoints)
    if not path or #path == 0 then return path end
    local lookup = {}
    for _, n in ipairs(path) do lookup[flowKey(n)] = n end
    local start
    for _, ep in ipairs(endpoints or {}) do
        for _, n in ipairs(path) do
            if n.row == ep.row and n.col == ep.col then start = { row = ep.row, col = ep.col }; break end
        end
        if start then break end
    end
    if not start then
        for _, n in ipairs(path) do
            local nb = 0
            for _, d in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
                if lookup[(n.row+d[1]).."-"..(n.col+d[2])] then nb += 1 end
            end
            if nb == 1 then start = { row = n.row, col = n.col }; break end
        end
    end
    if not start then start = { row = path[1].row, col = path[1].col } end
    local pool, ordered = {}, {}
    for _, n in ipairs(path) do pool[flowKey(n)] = { row = n.row, col = n.col } end
    local cur = start
    table.insert(ordered, { row = cur.row, col = cur.col }); pool[flowKey(cur)] = nil
    while next(pool) do
        local moved = false
        for k, node in pairs(pool) do
            if flowNeighbour(cur.row, cur.col, node.row, node.col) then
                table.insert(ordered, { row = node.row, col = node.col })
                pool[k] = nil; cur = node; moved = true; break
            end
        end
        if not moved then break end
    end
    return ordered
end

local function flowSolve(puzzle)
    pcall(function()
        if not puzzle or not puzzle.Solution then return end
        local indices = {}
        for i = 1, #puzzle.Solution do indices[i] = i end
        for i = #indices, 2, -1 do local j = math.random(1, i); indices[i], indices[j] = indices[j], indices[i] end
        for _, ci in ipairs(indices) do
            local solution = puzzle.Solution[ci]; if not solution then continue end
            local ordered = flowOrder(solution, puzzle.targetPairs[ci])
            if not ordered or #ordered == 0 then continue end
            puzzle.paths[ci] = {}
            for _, node in ipairs(ordered) do
                table.insert(puzzle.paths[ci], { row = node.row, col = node.col })
                puzzle:updateGui(); task.wait(flow.nodeDelay)
            end
            task.wait(flow.lineDelay); puzzle:checkForWin()
        end
    end)
end

do
    pcall(function()
        local modFolder  = svc.RS:FindFirstChild("Modules")
        local miniFolder = modFolder and modFolder:FindFirstChild("Minigames")
        local fgFolder   = miniFolder and miniFolder:FindFirstChild("FlowGameManager")
        local fgModule   = fgFolder and fgFolder:FindFirstChild("FlowGame")
        if fgModule then
            local ok, FG = pcall(require, fgModule)
            if ok and FG and FG.new then
                local orig = FG.new
                FG.new = function(...)
                    local p = orig(...)
                    if flow.on then task.spawn(function() task.wait(0.3); flowSolve(p) end) end
                    return p
                end
            else warn("[SorsHub] FlowGame: failed to require FlowGame module — auto-solve disabled") end
        else warn("[SorsHub] FlowGame: FlowGame not found — auto-solve disabled") end
    end)
end

secGenAuto:Toggle({ Title = "Auto Solve", Type = "Checkbox", Flag = "flowOn", Default = flow.on, Callback = function(on) pcall(function() if flow then flow.on = on end end) end })
secGenAuto:Slider({ Title = "Node Speed", Flag = "flowNodeDelay", Step = 0.02, Value = { Min = 0.01, Max = 0.50, Default = flow.nodeDelay }, Callback = function(v) pcall(function() flow.nodeDelay = v end) end })
secGenAuto:Slider({ Title = "Line Pause", Flag = "flowLineDelay", Step = 0.10, Value = { Min = 0.00, Max = 1.00, Default = flow.lineDelay }, Callback = function(v) pcall(function() flow.lineDelay = v end) end })

end -- tabGen

-- ============================================================
-- AIMBOT TAB
-- ============================================================

do -- tabAimbot

local aim = {
    enabled    = false,
    slashUnlock = true,
    maxDist    = 80,
    locked     = false,
    target     = nil,
    lockConn   = nil,
    lastAbility = "",
}

-- Notifications disabled per user request

local function aimGetNearest()
    local char = lp.Character; if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local survs = getTeamFolder("Survivors")
    if not survs then return nil end
    local best, bestDist = nil, math.huge
    for _, model in ipairs(survs:GetChildren()) do
        if model ~= char and model:IsA("Model") then
            local r = model:FindFirstChild("HumanoidRootPart")
            local h = model:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - hrp.Position).Magnitude
                if d < bestDist and d <= aim.maxDist then
                    bestDist = d; best = r
                end
            end
        end
    end
    return best
end

local function aimGetHeadPos(targetHRP)
    if not targetHRP or not targetHRP.Parent then return nil end
    local head = targetHRP.Parent:FindFirstChild("Head")
    local pos  = (head and head:IsA("BasePart")) and head.Position or (targetHRP.Position + Vector3.new(0, 2.5, 0))
    if targetHRP.AssemblyLinearVelocity then
        local vel   = targetHRP.AssemblyLinearVelocity
        local speed = vel.Magnitude
        local mult  = speed > 55 and 0.35 or (speed > 30 and 0.22 or 0.12)
        pos = pos + vel * mult
    end
    return pos
end

local function aimDoCamera(headPos)
    local char = lp.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local cam  = svc.WS.CurrentCamera
    if not hrp or not cam then return end

    -- Rotate HRP to face target horizontally (flat, no Y tilt so no upward aim)
    pcall(function()
        local flat = Vector3.new(headPos.X - hrp.Position.X, 0, headPos.Z - hrp.Position.Z)
        if flat.Magnitude > 0.01 then
            local target = CFrame.new(hrp.Position, hrp.Position + flat.Unit)
            hrp.CFrame = hrp.CFrame:Lerp(target, 0.85)
        end
    end)

    -- Move camera to look directly at target head (no Y offset, no mousemoverel fighting it)
    pcall(function()
        local camPos = cam.CFrame.Position
        local targetCF = CFrame.new(camPos, headPos)
        cam.CFrame = cam.CFrame:Lerp(targetCF, 0.85)
    end)
end

local function aimUnlock(silent)
    if aim.lockConn then aim.lockConn:Disconnect(); aim.lockConn = nil end
    if aim.locked and not silent then
        print("[SorsHub] 🔓 Aimbot unlocked")
    end
    aim.locked = false; aim.target = nil
    local cam = svc.WS.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
end

local function aimLock(targetHRP)
    if aim.lockConn then aim.lockConn:Disconnect(); aim.lockConn = nil end
    if not targetHRP or not targetHRP.Parent then return end
    aim.target = targetHRP; aim.locked = true
    local name = targetHRP.Parent.Name or "Unknown"
    print("[SorsHub] 🔒 Locked: " .. name)

    aim.lockConn = svc.Run.RenderStepped:Connect(function()
        if not aim.locked or not aim.target or not aim.target.Parent then aimUnlock(); return end
        local hum = aim.target.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            aimUnlock()
            return
        end
        local hp = aimGetHeadPos(aim.target)
        if hp then aimDoCamera(hp) end
    end)
end

local function aimIsKiller()
    local char = lp.Character
    if not char then return false end
    local killerFolder = getTeamFolder("Killers")
    return killerFolder ~= nil and char:IsDescendantOf(killerFolder)
end

local function tryGetAbilityName(args)
    local data = args[2] and args[2][1]
    if not data then return "" end
    
    local name = ""
    pcall(function()
        if typeof(data) == "buffer" then
            name = buffer.tostring(data)
        elseif typeof(data) == "string" then
            name = data
        end
        name = name:gsub("%z", "")
    end)
    
    return name
end

local aimOldNamecall
if hookmetamethod and getnamecallmethod then
aimOldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and args[1] == "UseActorAbility" then
        if aim.enabled then
            task.spawn(function()
                pcall(function()
                    local abilityName = tryGetAbilityName(args)
                    aim.lastAbility = abilityName

                    if abilityName:lower():find("slash") then
                        if aim.slashUnlock then
                            aimUnlock()
                        end
                        return
                    end

                    -- Only lock if not already locked (lock to ONE forever)
                    if not aim.locked then
                        local t = aimGetNearest()
                        if t then
                            aimLock(t)
                        else
                            print("[SorsHub] Aimbot: no survivors in range")
                        end
                    end
                end)
            end)
        end
    end

    return aimOldNamecall(self, ...)
end)
end
print("[SorsHub] Aimbot __namecall hook installed")

lp.CharacterAdded:Connect(function() aimUnlock(true) end)

local tabAimbot = win:Tab({ Title = "Aimbot", Icon = "crosshair" })

local aimSec = tabAimbot:Section({ Title = "Enstrangle Aimbot", Opened = true })

aimSec:Toggle({
    Title    = "Enable Aimbot",
    Desc     = "Lock onto nearest survivor on ability use",
    Default  = false,
    Callback = function(v)
        pcall(function()
            aim.enabled = v
            if not v then aimUnlock() end
        end)
    end
})

aimSec:Toggle({
    Title    = "Slash Releases Lock",
    Desc     = "ON = slash unlocks target  |  OFF = only survivor death unlocks",
    Default  = true,
    Callback = function(v)
        pcall(function() aim.slashUnlock = v end)
    end
})

aimSec:Slider({
    Title = "Max Distance",
    Step  = 5,
    Value = { Min = 10, Max = 150, Default = aim.maxDist },
    Callback = function(v) pcall(function() aim.maxDist = v end) end
})

aimSec:Button({
    Title    = "🔓 Manual Unlock",
    Desc     = "Force-release current lock",
    Callback = function() aimUnlock() end
})

local aimStatusPara = aimSec:Paragraph({ Title = "Status", Desc = "Waiting..." })
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local s = aim.enabled and "🟢 ON" or "⚪ OFF"
            local l = aim.locked  and "🔒 Locked" or "🔓 Unlocked"
            local t = (aim.target and aim.target.Parent and aim.target.Parent.Name) or "None"
            local sl = aim.slashUnlock and "Slash=Unlock" or "Slash=Keep"
            aimStatusPara:Set({ Title = "Status", Desc = s .. " | " .. l .. "\nTarget: " .. t .. "\nMode: " .. sl })
        end)
    end
end)

end -- tabAimbot

-- ============================================================
-- ESP TAB
-- ============================================================

do -- tabESP
local tabESP = win:Tab({ Title = "ESP", Icon = "eye" })

esp = {
    enabled = true,
    highlights = {}, billboards = {}, connections = {}, healthConnections = {},
    hlMonitorConns = {},
    scanThread = nil,
    showKillers = true, showSurvivors = true, showGenerators = true,
    showItems = true, showStructures = true,
    maxDistance = 200, transparency = 0.5,
    scanRate = 1.0,
    cachedItems = {}, cachedStructures = {},
    itemCacheTime = 0, structCacheTime = 0, cacheLife = 5,
}

-- Keep every world-space ESP label within a small, predictable size.
local function espCompactText(label, maxSize, minSize)
    if not label then return end
    maxSize = maxSize or 9
    minSize = minSize or 7
    label.TextScaled = true
    label.TextSize = maxSize
    label.TextWrapped = false
    label.TextTruncate = Enum.TextTruncate.AtEnd
    local constraint = label:FindFirstChildOfClass("UITextSizeConstraint")
    if not constraint then
        constraint = Instance.new("UITextSizeConstraint")
        constraint.Parent = label
    end
    constraint.MinTextSize = minSize
    constraint.MaxTextSize = maxSize
end

-- Generator label system
local genLabels = {}
local genConns  = {}

local function genGetProgress(obj)
    if not obj or not obj.Parent then return 0 end

    -- Current generator hierarchy:
    -- Generator.Instances.Generator.Progress.BarUI.Bar
    local innerGenerator = findPath(obj, "Instances", "Generator")
    local progressNode = (innerGenerator and innerGenerator:FindFirstChild("Progress"))
        or obj:FindFirstChild("Progress")
    if progressNode and (progressNode:IsA("NumberValue") or progressNode:IsA("IntValue")) then
        return math.clamp(progressNode.Value, 0, 100)
    end

    local bar = findPath(obj, "Instances", "Generator", "Progress", "BarUI", "Bar")
        or findPath(obj, "Progress", "BarUI", "Bar")
    if bar and bar:IsA("GuiObject") then
        return math.clamp(bar.Size.X.Scale * 100, 0, 100)
    end

    local av = obj:GetAttribute("Progress") or obj:GetAttribute("Charge")
        or (progressNode and (progressNode:GetAttribute("Progress") or progressNode:GetAttribute("Charge")))
    if type(av) == "number" then return math.clamp(av, 0, 100) end
    return 0
end

local function genBuildText(progress)
    if progress >= 100 then
        return "Generator  ✓ DONE  (100%)", Color3.fromRGB(100, 255, 100)
    end
    local puzzles = math.floor(progress / 25)
    return string.format("Generator  %d/4  (%d%%)", puzzles, puzzles * 25),
           Color3.fromRGB(255, 200, 50)
end

local function genUpdateLabel(obj)
    if not obj or not obj.Parent then return end
    local label = genLabels[obj]
    if not label then
        local bb = obj:FindFirstChildWhichIsA("BillboardGui")
        if bb then label = bb:FindFirstChildWhichIsA("TextLabel") end
        if label then genLabels[obj] = label else return end
    end
    if not label.Parent then genLabels[obj] = nil; return end
    local txt, col = genBuildText(genGetProgress(obj))
    label.Text = txt; label.TextColor3 = col
    espCompactText(label, 9, 7)
    label.TextStrokeTransparency = 0.35; label.Visible = true
end

local function genDisconnectObj(obj)
    local conns = genConns[obj]
    if conns then
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        genConns[obj] = nil
    end
end

local function genRemoveObj(obj)
    genDisconnectObj(obj)
    genLabels[obj] = nil
end

local function genWatchGenerator(obj)
    if not obj then return end
    genDisconnectObj(obj)
    local conns = {}
    local innerGenerator = findPath(obj, "Instances", "Generator")
    local pv = (innerGenerator and innerGenerator:FindFirstChild("Progress")) or obj:FindFirstChild("Progress")
    if pv and (pv:IsA("NumberValue") or pv:IsA("IntValue")) then
        table.insert(conns, pv:GetPropertyChangedSignal("Value"):Connect(function()
            pcall(genUpdateLabel, obj)
        end))
    end
    local bar = findPath(obj, "Instances", "Generator", "Progress", "BarUI", "Bar")
        or findPath(obj, "Progress", "BarUI", "Bar")
    if bar and bar:IsA("GuiObject") then
        table.insert(conns, bar:GetPropertyChangedSignal("Size"):Connect(function()
            pcall(genUpdateLabel, obj)
        end))
    end
    if pv then
        table.insert(conns, pv.AttributeChanged:Connect(function()
            pcall(genUpdateLabel, obj)
        end))
    end
    table.insert(conns, obj.ChildAdded:Connect(function(child)
        if child.Name == "Progress" and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            table.insert(conns, child:GetPropertyChangedSignal("Value"):Connect(function()
                pcall(genUpdateLabel, obj)
            end))
            pcall(genUpdateLabel, obj)
        end
    end))
    table.insert(conns, obj.AttributeChanged:Connect(function(attr)
        if attr == "Progress" or attr == "Charge" then pcall(genUpdateLabel, obj) end
    end))
    genConns[obj] = conns
    pcall(genUpdateLabel, obj)
end

local function genSetupGenerator(obj, label)
    if not obj or not label then return end
    genLabels[obj] = label
    local bb = label.Parent
    if bb and bb:IsA("BillboardGui") then
        bb.Enabled = true; bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 148, 0, 16); bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.MaxDistance = esp.maxDistance
    end
    local txt, col = genBuildText(genGetProgress(obj))
    label.Text = txt; label.TextColor3 = col
    espCompactText(label, 9, 7)
    label.TextStrokeTransparency = 0.35; label.Visible = true
    genWatchGenerator(obj)
end

local function genClearAll()
    pcall(function()
        for obj in pairs(genConns) do genDisconnectObj(obj) end
        genLabels = {}
        genConns  = {}
    end)
end

local COLORS = {
    Killer = Color3.fromRGB(255,50,50), Survivor = Color3.fromRGB(50,255,50),
    Generator = Color3.fromRGB(255,200,50), Item = Color3.fromRGB(50,200,255),
    Structure = Color3.fromRGB(255,150,50),
}

local function espGetTeamFolder(name)
    return getTeamFolder(name)
end

local function espGetIngame()
    return getIngame()
end

local function espGetMapContent()
    return getMapContent()
end

local function espClearAll()
    pcall(function()
        for obj, hl in pairs(esp.highlights) do pcall(function() hl:Destroy() end) end
        esp.highlights = {}
        for obj, bb in pairs(esp.billboards) do pcall(function() bb:Destroy() end) end
        esp.billboards = {}
        for obj, conn in pairs(esp.healthConnections) do pcall(function() conn:Disconnect() end) end
        esp.healthConnections = {}
        for _, conn in ipairs(esp.connections) do pcall(function() conn:Disconnect() end) end
        esp.connections = {}
        for _, conn in pairs(esp.hlMonitorConns) do pcall(function() conn:Disconnect() end) end
        esp.hlMonitorConns = {}
        genClearAll()
    end)
end

local function espGetAttach(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChild("Torso")
            or obj.PrimaryPart
            or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return obj:FindFirstChild("HumanoidRootPart")
        or obj:FindFirstChild("Torso")
        or obj:FindFirstChildWhichIsA("BasePart", true)
end

local function espMakeHighlight(obj, color, attach)
    local hl = Instance.new("Highlight")
    hl.Name = "V1PR_Highlight"
    hl.FillColor = color
    hl.FillTransparency = esp.transparency
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local target = (obj:IsA("Model") or obj:IsA("BasePart")) and obj or attach or obj
    hl.Adornee = target
    hl.Parent = target
    return hl
end

local function espCreate(obj, color, labelText, isCharacter)
    pcall(function()
        if not obj or not obj.Parent or esp.highlights[obj] then return end
        local attach = espGetAttach(obj)
        if not attach then return end

        local hl = espMakeHighlight(obj, color, attach)
        local bb = Instance.new("BillboardGui")
        bb.Name = "V1PR_ESPLabel"
        bb.Adornee = attach
        bb.Size = UDim2.new(0, 120, 0, 16)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = esp.maxDistance
        bb.LightInfluence = 0
        bb.Parent = obj
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText or obj.Name
        label.TextColor3 = color
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.45
        label.Font = Enum.Font.GothamMedium
        espCompactText(label, 9, 7)
        label.Parent = bb
        
        esp.highlights[obj] = hl
        esp.billboards[obj] = bb

        if esp.hlMonitorConns[obj] then
            pcall(function() esp.hlMonitorConns[obj]:Disconnect() end)
        end
        esp.hlMonitorConns[obj] = obj.ChildRemoved:Connect(function(child)
            if not esp.enabled or not obj.Parent then return end
            if child == esp.highlights[obj] or child.Name == "V1PR_Highlight" or child:IsA("Highlight") then
                task.defer(function()
                    if not esp.enabled or not obj.Parent or not esp.highlights[obj] then return end
                    local existing = obj:FindFirstChild("V1PR_Highlight")
                    if not existing then
                        local newHl = espMakeHighlight(obj, color)
                        esp.highlights[obj] = newHl
                    end
                end)
            end
        end)

        if labelText == "Generator" or (not isCharacter and obj.Name == "Generator") then
            genSetupGenerator(obj, label)
        end

        if isCharacter then
            local function updateLabel()
                if not obj or not obj.Parent then return end
                local name = labelText or obj.Name
                local distText = ""
                local hpText = ""
                local myChar = lp.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local a = espGetAttach(obj)
                    if a then distText = string.format("%.0f", (a.Position - myRoot.Position).Magnitude) end
                end
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then hpText = string.format("%d", math.floor(hum.Health)) end
                if distText ~= "" and hpText ~= "" then label.Text = string.format("%s (%s) %s HP", name, distText, hpText)
                elseif distText ~= "" then label.Text = string.format("%s (%s)", name, distText)
                elseif hpText ~= "" then label.Text = string.format("%s %s HP", name, hpText)
                else label.Text = name end
            end
            updateLabel()
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then esp.healthConnections[obj] = hum.HealthChanged:Connect(updateLabel) end
            table.insert(esp.connections, svc.Run.Heartbeat:Connect(function()
                if esp.enabled and obj and obj.Parent then pcall(updateLabel) end
            end))
        end

        table.insert(esp.connections, obj.AncestryChanged:Connect(function()
            if not obj.Parent then
                pcall(function()
                    if esp.highlights[obj] then esp.highlights[obj]:Destroy() end
                    if esp.billboards[obj] then esp.billboards[obj]:Destroy() end
                    if esp.healthConnections[obj] then esp.healthConnections[obj]:Disconnect() end
                    if esp.hlMonitorConns[obj] then esp.hlMonitorConns[obj]:Disconnect() end
                    genRemoveObj(obj)
                    esp.highlights[obj] = nil
                    esp.billboards[obj] = nil
                    esp.healthConnections[obj] = nil
                    esp.hlMonitorConns[obj] = nil
                end)
            end
        end))
    end)
end

local function espScan()
    pcall(function()
        if not esp.enabled or not lp then return end
        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position or Vector3.new(0,0,0)
        local toRemove = {}
        for obj in pairs(esp.highlights) do if not obj or not obj.Parent then table.insert(toRemove, obj) end end
        for _, obj in ipairs(toRemove) do pcall(function()
            if esp.highlights[obj] then esp.highlights[obj]:Destroy() end
            if esp.billboards[obj] then esp.billboards[obj]:Destroy() end
            if esp.healthConnections[obj] then esp.healthConnections[obj]:Disconnect() end
            esp.highlights[obj] = nil
            esp.billboards[obj] = nil
            esp.healthConnections[obj] = nil
        end) end
        local processed = {}
        local function addESP(obj, objType, color, label)
            if not obj or not obj.Parent or processed[obj] or esp.highlights[obj] then return end
            processed[obj] = true
            local attach = espGetAttach(obj)
            if not attach then return end
            if myRoot and (attach.Position - myPos).Magnitude > esp.maxDistance then return end
            espCreate(obj, color, label, objType == "Character")
        end
        if esp.showKillers then
            local kf = espGetTeamFolder("Killers")
            if kf then for _, m in ipairs(kf:GetChildren()) do if m:IsA("Model") and m ~= myChar then local h = m:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 then addESP(m,"Character",COLORS.Killer,m.Name) end end end end
        end
        if esp.showSurvivors then
            local sf = espGetTeamFolder("Survivors")
            if sf then for _, m in ipairs(sf:GetChildren()) do if m:IsA("Model") and m ~= myChar then local h = m:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 then addESP(m,"Character",COLORS.Survivor,m.Name) end end end end
        end
        if esp.showGenerators then
            local mc = espGetMapContent()
            if mc then
                for _, o in ipairs(mc:GetChildren()) do
                    if o.Name == "Generator" and o.Parent then
                        addESP(o, "Object", COLORS.Generator, "Generator")
                    end
                end
            end
        end
        if esp.showItems then
            local now = tick()
            if now - esp.itemCacheTime > esp.cacheLife then
                esp.itemCacheTime = now
                esp.cachedItems = {}
                pcall(function()
                    -- Live pickups are parented beneath Workspace.Map.Ingame.Map.
                    -- Searching all of Workspace also catches lobby decorations.
                    local mc = espGetMapContent()
                    if mc then
                        for _, o in ipairs(mc:GetChildren()) do
                            if (o.Name == "BloxyCola" or o.Name == "Medkit")
                                and (o:IsA("Tool") or o:IsA("Model") or o:IsA("BasePart")) then
                                table.insert(esp.cachedItems, o)
                            end
                        end
                    end
                end)
            end
            for _, o in ipairs(esp.cachedItems) do addESP(o,"Object",COLORS.Item,o.Name) end
        end
        if esp.showStructures then
            local now = tick()
            if now - esp.structCacheTime > esp.cacheLife then
                esp.structCacheTime = now
                esp.cachedStructures = {}
                pcall(function()
                    -- Structures may be nested under the active Ingame map.
                    local ig = espGetIngame()
                    if ig then
                        for _, o in ipairs(ig:GetDescendants()) do
                            if o.Name == "BuildermanSentry" or o.Name == "SubspaceTripmine" or o.Name == "BuildermanDispenser" then
                                table.insert(esp.cachedStructures, o)
                            end
                        end
                    end
                end)
            end
            for _, o in ipairs(esp.cachedStructures) do addESP(o,"Object",COLORS.Structure,o.Name) end
        end
    end)
end

local espSetupListeners

function espStart()
    pcall(function()
        espClearAll()
        esp.enabled = true
        if espSetupListeners then espSetupListeners() end
        if esp.scanThread then task.cancel(esp.scanThread) end
        esp.scanThread = task.spawn(function() while esp.enabled do pcall(espScan); task.wait(esp.scanRate) end end)
    end)
end

function espStop()
    pcall(function()
        esp.enabled = false
        if esp.scanThread then task.cancel(esp.scanThread) end
        esp.scanThread = nil
        espClearAll()
    end)
end

espSetupListeners = function()
    pcall(function()
        if not lp then return end
        local function onTeamChild(child, team, color)
            task.delay(0.2, function()
                if not esp.enabled or not child or not child.Parent then return end
                if child:IsA("Model") and child ~= lp.Character and esp["show"..team] then
                    local h = child:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then espCreate(child, color, child.Name, true) end
                end
            end)
        end

        -- A single guarded listener handles folders that appear after startup.
        -- It ignores unrelated Workspace descendants and lobby-only decorations.
        table.insert(esp.connections, svc.WS.DescendantAdded:Connect(function(o)
            if not esp.enabled or not o or not o.Parent then return end
            local parent = o.Parent
            local killers = espGetTeamFolder("Killers")
            local survivors = espGetTeamFolder("Survivors")
            if killers and parent == killers and esp.showKillers then
                onTeamChild(o, "Killers", COLORS.Killer)
                return
            elseif survivors and parent == survivors and esp.showSurvivors then
                onTeamChild(o, "Survivors", COLORS.Survivor)
                return
            end

            local isWorldESP = o.Name == "Generator"
                or o.Name == "BloxyCola" or o.Name == "Medkit"
                or o.Name == "BuildermanSentry" or o.Name == "SubspaceTripmine"
                or o.Name == "BuildermanDispenser"
            if not isWorldESP then return end

            task.defer(function()
                if not esp.enabled or not o.Parent then return end
                local ingame = espGetIngame()
                if not ingame or not o:IsDescendantOf(ingame) then return end
                if o.Name == "Generator" and esp.showGenerators then
                    local mapContent = espGetMapContent()
                    if mapContent and o.Parent == mapContent then
                        espCreate(o, COLORS.Generator, "Generator")
                    end
                elseif (o.Name == "BloxyCola" or o.Name == "Medkit") and esp.showItems then
                    local mapContent = espGetMapContent()
                    if mapContent and o:IsDescendantOf(mapContent) then
                        espCreate(o, COLORS.Item, o.Name)
                    end
                elseif esp.showStructures and (o.Name == "BuildermanSentry" or o.Name == "SubspaceTripmine" or o.Name == "BuildermanDispenser") then
                    espCreate(o, COLORS.Structure, o.Name)
                end
            end)
        end))
    end)
end

if lp then lp.CharacterAdded:Connect(function() task.wait(2); if esp.enabled then espStart() end end) end

task.wait(2)
if esp.enabled then espStart() end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            for obj, label in pairs(genLabels) do
                if obj and obj.Parent and label and label.Parent then
                    pcall(genUpdateLabel, obj)
                else
                    genRemoveObj(obj)
                end
            end
        end)
    end
end)

local mainSection = tabESP:Section({ Title = "Main Settings", Opened = true })

mainSection:Toggle({ Title="Enable ESP", Type="Checkbox", Flag="espEnabled", Default=esp.enabled,
    Callback=function(on) pcall(function() esp.enabled=on; if on then espStart() else espStop() end end) end })

local catSection = tabESP:Section({ Title = "Categories", Opened = false })

catSection:Toggle({ Title="Killers", Type="Checkbox", Flag="espKillers", Default=esp.showKillers,
    Callback=function(on) pcall(function() esp.showKillers=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Survivors", Type="Checkbox", Flag="espSurvivors", Default=esp.showSurvivors,
    Callback=function(on) pcall(function() esp.showSurvivors=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Generators", Type="Checkbox", Flag="espGenerators", Default=esp.showGenerators,
    Callback=function(on) pcall(function() esp.showGenerators=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Items", Type="Checkbox", Flag="espItems", Default=esp.showItems,
    Callback=function(on) pcall(function() esp.showItems=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Structures", Type="Checkbox", Flag="espStructures", Default=esp.showStructures,
    Callback=function(on) pcall(function() esp.showStructures=on; if esp.enabled then espClearAll(); espStart() end end) end })

-- ============================================================
-- GROUNDBULB & VINE ESP
-- ============================================================

local secGVEsp = tabESP:Section({ Title = "Groundbulb & Vine Settings", Opened = false })

gvConfig = {
    ShowGroundbulb = true,
    ShowVine = true,
    HighlightColor = Color3.fromRGB(170, 0, 255),
    FillTransparency = 0.4,
    OutlineTransparency = 0.1,
    ScanRate = 0.5,
}

gv = {
    enabled = false,
    tracked = {},
    objects = {},
    thread = nil,
    ticker = 0,
    listenerConn = nil,
    heartbeatConn = nil,
}

local function gvGetTopPart(model)
    local highestPart = model.PrimaryPart
    local highestY = highestPart and highestPart.Position.Y or -math.huge

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            if descendant.Name:find("Flower") or descendant.Position.Y > highestY then
                highestY = descendant.Position.Y
                highestPart = descendant
            end
        end
    end
    return highestPart
end

local function gvHighlightEntity(model, displayName)
    if not model or not model:IsA("Model") then return end
    if gv.tracked[model] then return end

    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") then
            child:Destroy()
        end
    end

    local existingHl = model:FindFirstChild("GvHighlight")
    if existingHl then existingHl:Destroy() end
    local existingBb = model:FindFirstChild("GvTag")
    if existingBb then existingBb:Destroy() end

    local adornPart = gvGetTopPart(model)
    if not adornPart then
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name ~= "Handle" then
                adornPart = descendant
                break
            end
        end
    end

    if not adornPart then return end

    if not model.PrimaryPart then
        model.PrimaryPart = adornPart
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GvHighlight"
    highlight.Adornee = model
    highlight.FillColor = gvConfig.HighlightColor
    highlight.FillTransparency = gvConfig.FillTransparency
    highlight.OutlineColor = gvConfig.HighlightColor
    highlight.OutlineTransparency = gvConfig.OutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GvTag"
    billboard.Size = UDim2.new(0, 140, 0, 16)
    billboard.Adornee = adornPart
    billboard.StudsOffset = Vector3.new(0, 0.5, 0)
    billboard.MaxDistance = 120
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = displayName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.GothamMedium
    espCompactText(label, 9, 7)
    label.Parent = billboard

    gv.tracked[model] = true
    gv.objects[model] = {
        highlight = highlight,
        billboard = billboard,
    }
end

local function gvEvaluateAndHighlight(child)
    if not child:IsA("Model") then return end

    local nameLower = child.Name:lower()

    if nameLower == "groundbulbmodel" then
        if gvConfig.ShowGroundbulb and not gv.tracked[child] then
            gvHighlightEntity(child, "GroundBulb")
        end
    elseif nameLower == "vinemodel" then
        if gvConfig.ShowVine and not gv.tracked[child] then
            gvHighlightEntity(child, "Vine")
        end
    end
end

local function gvScan()
    if not gv.enabled then return end
    
    local ingame = getIngame()
    if not ingame then return end

    for _, obj in ipairs(ingame:GetDescendants()) do
        if obj:IsA("Model") then
            gvEvaluateAndHighlight(obj)
        end
    end
end

local function gvCleanup()
    for model in pairs(gv.tracked) do
        if not model or not model.Parent then
            if gv.objects[model] then
                pcall(function()
                    if gv.objects[model].highlight then
                        gv.objects[model].highlight:Destroy()
                    end
                    if gv.objects[model].billboard then
                        gv.objects[model].billboard:Destroy()
                    end
                end)
                gv.objects[model] = nil
            end
            gv.tracked[model] = nil
        end
    end
end

local function gvUpdateLoop()
    gvCleanup()
    gvScan()
end

function gvStart()
    if gv.thread then return end
    
    task.wait(0.5)
    gvUpdateLoop()
    
    gv.ticker = 0
    gv.heartbeatConn = svc.Run.Heartbeat:Connect(function(dt)
        if not gv.enabled then
            gv.heartbeatConn:Disconnect()
            gv.heartbeatConn = nil
            gv.thread = nil
            return
        end
        
        gv.ticker = gv.ticker + dt
        if gv.ticker >= gvConfig.ScanRate then
            gv.ticker = 0
            pcall(gvUpdateLoop)
        end
    end)
    gv.thread = gv.heartbeatConn
end

function gvStop()
    if gv.heartbeatConn then
        gv.heartbeatConn:Disconnect()
        gv.heartbeatConn = nil
    end
    gv.thread = nil
    
    for model, data in pairs(gv.objects) do
        pcall(function()
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
        end)
    end
    gv.objects = {}
    gv.tracked = {}
end

local function gvSetupListener()
    local ingame = getIngame()
    if ingame then
            if gv.listenerConn then
                gv.listenerConn:Disconnect()
            end
            gv.listenerConn = ingame.DescendantAdded:Connect(function(child)
                if gv.enabled and child:IsA("Model") then
                    task.wait(0.1)
                    gvEvaluateAndHighlight(child)
                end
            end)
    end
end

local function gvKeepListenerAlive()
    task.spawn(function()
        while gv.enabled do
            gvSetupListener()
            task.wait(2)
        end
    end)
end

lp.CharacterAdded:Connect(function()
    task.wait(2)
    if gv.enabled then
        pcall(gvUpdateLoop)
    end
end)

catSection:Toggle({ 
    Title = "Groundbulb & Vine", 
    Type = "Checkbox", 
    Flag = "gvEspOn", 
    Default = gv.enabled,
    Callback = function(on)
        pcall(function()
            gv.enabled = on
            if on then 
                gvStart()
                gvKeepListenerAlive()
            else 
                gvStop() 
            end
        end)
    end 
})

secGVEsp:Toggle({
    Title = "Show Groundbulb",
    Type = "Checkbox",
    Flag = "gvShowGroundbulb",
    Default = gvConfig.ShowGroundbulb,
    Callback = function(on)
        gvConfig.ShowGroundbulb = on
        if gv.enabled then
            pcall(gvUpdateLoop)
        end
    end
})

secGVEsp:Toggle({
    Title = "Show Vine",
    Type = "Checkbox",
    Flag = "gvShowVine",
    Default = gvConfig.ShowVine,
    Callback = function(on)
        gvConfig.ShowVine = on
        if gv.enabled then
            pcall(gvUpdateLoop)
        end
    end
})

secGVEsp:Slider({
    Title = "Scan Rate (seconds)",
    Description = "How often to scan (lower = faster but more lag)",
    Flag = "gvScanRate",
    Step = 0.1,
    Value = { Min = 0.1, Max = 3.0, Default = gvConfig.ScanRate },
    Callback = function(v)
        gvConfig.ScanRate = v
    end
})

secGVEsp:Slider({
    Title = "Highlight Transparency",
    Flag = "gvTransparency",
    Step = 0.05,
    Value = { Min = 0.1, Max = 1.0, Default = gvConfig.FillTransparency },
    Callback = function(v)
        gvConfig.FillTransparency = v
        for model, data in pairs(gv.objects) do
            if data.highlight and data.highlight.Parent then
                data.highlight.FillTransparency = v
            end
        end
    end
})

secGVEsp:Button({
    Title = "Refresh ESP",
    Callback = function()
        if gv.enabled then
            gvStop()
            task.wait(0.1)
            gv.tracked = {}
            gv.objects = {}
            gvStart()
            gvKeepListenerAlive()
        end
    end
})

secGVEsp:Button({
    Title = "Clear All Highlights",
    Callback = function()
        gvStop()
        gv.tracked = {}
        gv.objects = {}
    end
})

local visSection = tabESP:Section({ Title = "Visual Settings", Opened = false })

visSection:Slider({ Title="Max Distance", Flag="espMaxDistance", Step=10, Value={Min=50,Max=500,Default=esp.maxDistance},
    Callback=function(v) pcall(function() esp.maxDistance=v; if esp.enabled then espClearAll(); espStart() end end) end })

visSection:Slider({ Title="Highlight Opacity", Flag="espTransparency", Step=0.05, Value={Min=0.1,Max=1.0,Default=esp.transparency},
    Callback=function(v) pcall(function() esp.transparency=v; if esp.enabled then espClearAll(); espStart() end end) end })

visSection:Slider({ Title="Scan Rate (s)", Flag="espScanRate", Step=0.5, Value={Min=0.5,Max=5.0,Default=esp.scanRate},
    Callback=function(v) pcall(function()
        esp.scanRate=v
        if esp.enabled and esp.scanThread then
            task.cancel(esp.scanThread)
            esp.scanThread = task.spawn(function() while esp.enabled do pcall(espScan); task.wait(esp.scanRate) end end)
        end
    end) end })

visSection:Button({ Title="Refresh ESP", Callback=function() pcall(function() if esp.enabled then espClearAll(); espStart() end end) end })

visSection:Button({ Title="Refresh Generator Labels", Callback=function()
    pcall(function()
        for obj in pairs(genLabels) do
            if obj and obj.Parent then genWatchGenerator(obj)
            else genRemoveObj(obj) end
        end
        local mc = espGetMapContent()
        if mc then
            for _, o in ipairs(mc:GetChildren()) do
                if o.Name == "Generator" and o.Parent then
                    if not genLabels[o] then
                        if esp.enabled and not esp.highlights[o] then
                            espCreate(o, COLORS.Generator, "Generator", false)
                        end
                    else
                        genWatchGenerator(o)
                    end
                end
            end
        end
    end)
end })

-- MINION ESP
local secMinion = tabESP:Section({ Title = "Minion & Ability ESP", Opened = false })

mset = { pizza=false, zombie=false, puddle=false, transparency=0.25 }
local tracked = { pizza={}, zombie={}, puddle={} }

local function isRealPlayer(obj)
    for _, p in ipairs(svc.Players:GetPlayers()) do if p.Character == obj or (p.Character and obj:IsDescendantOf(p.Character)) then return true end end
    return false
end

local function addHighlight(obj, color, tag, label, offset)
    pcall(function()
        if not obj or tracked[tag][obj] or isRealPlayer(obj) then return end
        tracked[tag][obj] = true
        local root = obj
        if obj:IsA("Model") then 
            root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
            if not root then 
                for _, c in ipairs(obj:GetChildren()) do 
                    if c:IsA("BasePart") then 
                        root = c
                        break 
                    end 
                end 
            end
        end
        
        local hl = Instance.new("Highlight")
        hl.Name = tag .. "_HL"
        hl.FillColor = color
        hl.FillTransparency = mset.transparency
        hl.OutlineColor = color
        hl.OutlineTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = obj
        hl.Parent = obj
        
        if root then
            local bb = Instance.new("BillboardGui")
            bb.Name = tag .. "_BB"
            bb.Adornee = root
            bb.Size = UDim2.new(0, 145, 0, 16)
            bb.StudsOffset = Vector3.new(0, offset or 3, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 120
            bb.LightInfluence = 0
            bb.Parent = obj
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = color
            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            lbl.TextStrokeTransparency = 0.4
            lbl.Font = Enum.Font.GothamMedium
            espCompactText(lbl, 9, 7)
            lbl.Parent = bb
        end
        
        obj.AncestryChanged:Connect(function() 
            if obj.Parent then return end
            local h2 = obj:FindFirstChild(tag .. "_HL")
            if h2 then h2:Destroy() end
            local b2 = obj:FindFirstChild(tag .. "_BB")
            if b2 then b2:Destroy() end
            tracked[tag][obj] = nil
        end)
    end)
end

function updateTransparency()
    pcall(function()
        for tag, tbl in pairs(tracked) do for obj in pairs(tbl) do local h=obj:FindFirstChild(tag.."_HL"); if h then h.FillTransparency=mset.transparency end end end
    end)
end

local function clearTag(tag)
    pcall(function()
        for obj in pairs(tracked[tag]) do
            local h=obj:FindFirstChild(tag.."_HL"); if h then h:Destroy() end
            local b=obj:FindFirstChild(tag.."_BB"); if b then b:Destroy() end
            if tag=="puddle" then local h2=obj:FindFirstChild("PuddleHolder"); if h2 then h2:Destroy() end end
        end
        tracked[tag]={}
    end)
end

local function addPuddleHighlight(part, color, tag, label)
    pcall(function()
        if not part or tracked[tag][part] or isRealPlayer(part) then return end
        tracked[tag][part] = true
        local hl = Instance.new("Highlight"); hl.Name=tag.."_HL"; hl.FillColor=color; hl.FillTransparency=mset.transparency
        hl.OutlineColor=color; hl.OutlineTransparency=0.1; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee=part; hl.Parent=part
        task.wait(0.05)
        local radius = math.max(math.max(part.Size.X,part.Size.Z)*0.5,3)
        local holder = Instance.new("Part"); holder.Name="PuddleHolder"; holder.Size=Vector3.new(1,0.1,1)
        holder.Transparency=1; holder.CanCollide=false; holder.Anchored=true
        holder.Position=part.Position+Vector3.new(0,0.05,0); holder.Parent=part
        local bc = Instance.new("CylinderHandleAdornment"); bc.Name="PuddleBlack"; bc.Adornee=holder
        bc.Color3=Color3.fromRGB(0,0,0); bc.Transparency=0.2; bc.Radius=radius; bc.Height=0.02
        bc.CFrame=CFrame.Angles(math.rad(90),0,0); bc.ZIndex=5; bc.AlwaysOnTop=true; bc.Parent=holder
        local ro = Instance.new("CylinderHandleAdornment"); ro.Name="PuddleRed"; ro.Adornee=holder
        ro.Color3=Color3.fromRGB(255,0,0); ro.Transparency=0.4; ro.Radius=radius+0.8; ro.Height=0.02
        ro.CFrame=CFrame.Angles(math.rad(90),0,0); ro.ZIndex=4; ro.AlwaysOnTop=true; ro.Parent=holder
        local bb = Instance.new("BillboardGui"); bb.Name=tag.."_BB"; bb.Adornee=holder
        bb.Size=UDim2.new(0,130,0,16); bb.StudsOffset=Vector3.new(0,1.5,0); bb.AlwaysOnTop=true
        bb.MaxDistance=120; bb.LightInfluence=0; bb.Parent=holder
        local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
        lbl.Text=label; lbl.TextColor3=Color3.fromRGB(255,255,255)
        lbl.TextStrokeColor3=Color3.fromRGB(255,0,0); lbl.TextStrokeTransparency=0.35
        lbl.Font=Enum.Font.GothamMedium; espCompactText(lbl,9,7); lbl.Parent=bb
        part:GetPropertyChangedSignal("Size"):Connect(function()
            if not part.Parent then return end
            local nr = math.max(math.max(part.Size.X,part.Size.Z)*0.5,3)
            bc.Radius=nr; ro.Radius=nr+0.8
        end)
        part.AncestryChanged:Connect(function()
            if part.Parent then return end
            hl:Destroy(); holder:Destroy(); tracked[tag][part]=nil
        end)
    end)
end

local function isJohnDoePuddle(o)
    if not o:IsA("BasePart") or o.Name ~= "Shadow" then return false end
    local p = o.Parent; return p and p.Name:find("Shadows$") ~= nil
end

local function forEachActiveWorldDescendant(callback)
    local roots = {}
    local ingame = getIngame()
    local playersRoot = findPath(svc.WS, "Players")
    if ingame then table.insert(roots, ingame) end
    if playersRoot then table.insert(roots, playersRoot) end
    local seen = {}
    for _, root in ipairs(roots) do
        for _, obj in ipairs(root:GetDescendants()) do
            if not seen[obj] then
                seen[obj] = true
                callback(obj)
            end
        end
    end
end

local function scanPizza()
    pcall(function()
        if not mset.pizza then return end
        forEachActiveWorldDescendant(function(o)
            if o.Name == "PizzaDeliveryRig" and o:IsA("Model") and not isRealPlayer(o) and not tracked.pizza[o] then
                addHighlight(o,Color3.fromRGB(255,100,0),"pizza","C00LKIDD PIZZA DELIVERY",3)
            end
        end)
    end)
end

local function scanZombie()
    pcall(function()
        if not mset.zombie then return end
        forEachActiveWorldDescendant(function(o)
            if o.Name == "1x1x1x1Zombie" and o:IsA("Model") and not isRealPlayer(o) and not tracked.zombie[o] then
                addHighlight(o,Color3.fromRGB(80,255,120),"zombie","1X1X1X1 ZOMBIE",3)
            end
        end)
    end)
end

local function scanPuddles()
    pcall(function()
        if not mset.puddle then return end
        forEachActiveWorldDescendant(function(o)
            if isJohnDoePuddle(o) and not tracked.puddle[o] then
                addPuddleHighlight(o,Color3.fromRGB(255,50,50),"puddle","JOHN DOE PUDDLE")
            end
        end)
    end)
end

task.spawn(function() while true do task.wait(3); scanPizza(); scanZombie(); scanPuddles() end end)

secMinion:Toggle({ Title="c00lkidd Pizza Bots", Type="Checkbox", Flag="espPizza", Default=mset.pizza, Callback=function(on) pcall(function() mset.pizza=on; if on then scanPizza() else clearTag("pizza") end end) end })

secMinion:Toggle({ Title="1x1x1x1 Zombies", Type="Checkbox", Flag="espZombie", Default=mset.zombie, Callback=function(on) pcall(function() mset.zombie=on; if on then scanZombie() else clearTag("zombie") end end) end })

secMinion:Toggle({ Title="JD Digital Footprints", Type="Checkbox", Flag="espPuddle", Default=mset.puddle, Callback=function(on) pcall(function() mset.puddle=on; if on then scanPuddles() else clearTag("puddle") end end) end })

secMinion:Slider({ Title="Highlight Transparency", Flag="espMinionTrans", Step=0.05, Value={Min=0,Max=1,Default=mset.transparency}, Callback=function(v) pcall(function() mset.transparency=v; updateTransparency() end) end })

secMinion:Button({ Title="Force Rescan", Callback=function() pcall(function() clearTag("pizza"); clearTag("zombie"); clearTag("puddle"); task.wait(0.1); scanPizza(); scanZombie(); scanPuddles() end) end })

end -- tabESP



-- ============================================================
-- JANE DOE TAB - WORKING FOREVER HOLD (from noodles_script)
-- ============================================================

local tabJaneDoe = win:Tab({ Title = "Jane Doe", Icon = "gem" })
local jd_Run = svc.Run
local jd_RS = svc.RS
local jd_lp = lp
local jd_Camera = svc.WS.CurrentCamera

local jd_RemoteEvent = nil
local jd_NetworkRF = nil

pcall(function()
    jd_RemoteEvent = jd_RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
end)
pcall(function()
    jd_NetworkRF = jd_RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteFunction",10)
end)

local jd_enabled = false
local jd_aimbotOn = false
local jd_patched = false
local jd_unloaded = false
local jd_AIM_OFFSET = -0.3
local jd_PREDICTION = 0.6
local jd_axeEnabled = false
local jd_AXE_LOCK_DURATION = 1.7
do -- [SorsHub: scope local]
local jd_axeLocked = false
local jd_killerMotionData = {}

-- FOREVER HOLD (MAX SPEED 250) - THIS IS THE 999 PAST INPUT TRICK
local jd_foreverHold = false
local jd_foreverHoldThread = nil

local function jd_overrideCrystalValues()
    pcall(function()
        local actors = safeRequirePath(svc.RS, "Modules", "Gameplay", "Actors")
        if not actors then return end
        
        local janeActor = actors.CurrentActors[svc.Players.LocalPlayer]
        if not janeActor then return end
        
        if janeActor.Config and janeActor.Config.Crystal then
            janeActor.Config.Crystal.MinChargeTime = 0.01
            janeActor.Config.Crystal.MaxChargeTime = 0.05
            janeActor.Config.Crystal.ChannelTime = 0.01
            janeActor.Config.Crystal.ChargeSpeedMult = 100
            janeActor.Config.Crystal.MaxSpeed = 250
            janeActor.Config.Crystal.MinSpeed = 250
            print("[Jane Doe] ⚡ Forever Hold - MAX SPEED 250!")
        end
    end)
end

-- THIS IS THE 999 PAST INPUT TRICK
local function jd_forceMaxCharge()
    pcall(function()
        local actors = safeRequirePath(svc.RS, "Modules", "Gameplay", "Actors")
        if not actors then return end
        
        local janeActor = actors.CurrentActors[svc.Players.LocalPlayer]
        if not janeActor then return end
        
        if janeActor.State then
            -- Set CrystalFullChargeTime to 999 seconds in the past
            -- This tricks the game into thinking we've been holding for 999 seconds
            janeActor.State.CrystalFullChargeTime = os.clock() - 999
        end
    end)
end

local function jd_toggleForeverHold(on)
    jd_foreverHold = on
    
    if on then
        print("[Jane Doe] 🚀 Forever Hold ENABLED - 999 past input trick ACTIVE (Max Speed: 250)")
        jd_overrideCrystalValues()
        
        if jd_foreverHoldThread then
            task.cancel(jd_foreverHoldThread)
            jd_foreverHoldThread = nil
        end
        
        jd_foreverHoldThread = task.spawn(function()
            while jd_foreverHold do
                pcall(function()
                    -- Keep setting the charge time to 999 seconds in the past
                    jd_forceMaxCharge()
                    
                    -- Update GUI to show 100%
                    local playerGui = svc.Players.LocalPlayer.PlayerGui
                    if playerGui then
                        local tempUI = playerGui:FindFirstChild("TemporaryUI")
                        if tempUI then
                            local chargeUI = tempUI:FindFirstChild("ChargeUI")
                            if chargeUI then
                                local bar = chargeUI:FindFirstChild("Bar")
                                if bar then
                                    local percent = bar:FindFirstChild("Percent")
                                    if percent then
                                        percent.Text = "100%"
                                    end
                                    bar.ImageColor3 = Color3.fromRGB(0, 255, 0)
                                end
                            end
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    else
        print("[Jane Doe] ❌ Forever Hold DISABLED")
        if jd_foreverHoldThread then
            task.cancel(jd_foreverHoldThread)
            jd_foreverHoldThread = nil
        end
        
        pcall(function()
            local actors = safeRequirePath(svc.RS, "Modules", "Gameplay", "Actors")
            if not actors then return end
            
            local janeActor = actors.CurrentActors[svc.Players.LocalPlayer]
            if janeActor and janeActor.Config and janeActor.Config.Crystal then
                janeActor.Config.Crystal.MinChargeTime = 0.3
                janeActor.Config.Crystal.MaxChargeTime = 2.5
                janeActor.Config.Crystal.ChannelTime = 0.5
                janeActor.Config.Crystal.ChargeSpeedMult = 1.2
                janeActor.Config.Crystal.MaxSpeed = 250
                janeActor.Config.Crystal.MinSpeed = 60
            end
        end)
    end
end

-- JANE DOE CORE FUNCTIONS
local function jd_axeDoLock()
    local ok = pcall(function()
        if jd_axeLocked then return end
        local char = jd_lp.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not myHRP or not hum then return end
        
        -- Get nearest killer
        local killerFolder = getTeamFolder("Killers")
        if not killerFolder then return end
        
        local best, bestDist = nil, math.huge
        for _, killer in ipairs(killerFolder:GetChildren()) do
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            local h = killer:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d < bestDist then bestDist = d; best = hrp end
            end
        end
        
        if not best then return end
        
        jd_axeLocked = true
        local savedAutoRotate = hum.AutoRotate
        hum.AutoRotate = false
        local deadline = tick() + jd_AXE_LOCK_DURATION
        local conn; conn = jd_Run.RenderStepped:Connect(function()
            local connOk = pcall(function()
                if tick() >= deadline or not jd_axeEnabled or jd_unloaded then
                    conn:Disconnect()
                    pcall(function() hum.AutoRotate = savedAutoRotate end)
                    jd_axeLocked = false
                    return
                end
                if not myHRP.Parent or not best.Parent then
                    conn:Disconnect()
                    pcall(function() hum.AutoRotate = savedAutoRotate end)
                    jd_axeLocked = false
                    return
                end
                local dir = Vector3.new(best.Position.X - myHRP.Position.X, 0, best.Position.Z - myHRP.Position.Z)
                if dir.Magnitude > 0 then
                    myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + dir.Unit)
                end
            end)
            if not connOk then
                pcall(function() conn:Disconnect() end)
                pcall(function() hum.AutoRotate = savedAutoRotate end)
                jd_axeLocked = false
            end
        end)
    end)
    if not ok then warn("Failed to execute axe lock-on"); jd_axeLocked = false end
end

local function jd_getKillerVelocity(hrp)
    if not hrp then return Vector3.zero end
    
    local now = tick()
    local pos = hrp.Position
    local data = jd_killerMotionData[hrp]
    
    if not data then
        jd_killerMotionData[hrp] = {lastPos = pos, lastTime = now, velocity = Vector3.zero}
        return Vector3.zero
    end
    
    local dt = now - data.lastTime
    if dt <= 0 then return data.velocity end
    
    local vel = (pos - data.lastPos) / dt
    data.lastPos = pos
    data.lastTime = now
    data.velocity = vel
    
    return vel
end

local function jd_buildCamCF(myHRP, killerHRP, v0, g)
    local ok, result = pcall(function()
        local hum=myHRP.Parent and myHRP.Parent:FindFirstChildOfClass("Humanoid")
        local hipH=hum and hum.HipHeight or 1.35
        local v238=(hipH+myHRP.Size.Y/2)/2
        local spawnPos=myHRP.CFrame.Position+Vector3.new(0,v238,0)
        local vel=jd_getKillerVelocity(killerHRP)
        local predicted=killerHRP.Position+vel*jd_PREDICTION
        local target=predicted+Vector3.new(0,jd_AIM_OFFSET,0)
        local delta=target-spawnPos
        local flatV=Vector3.new(delta.X,0,delta.Z)
        local dx=flatV.Magnitude; local dy=delta.Y
        if dx<0.01 then
            local d=dy>=0 and Vector3.new(0,1,0) or Vector3.new(0,-1,0)
            return CFrame.new(jd_Camera.CFrame.Position,jd_Camera.CFrame.Position+d)
        end
        local flatDir=flatV.Unit; local v2=v0*v0
        local disc=v2*v2-g*(g*dx*dx+2*dy*v2)
        local theta=disc<0 and math.atan2(dy,dx) or math.atan2(v2-math.sqrt(disc),g*dx)
        local T=math.tan(theta); local denom=3+T
        local alpha=math.abs(denom)<0.0001 and -math.pi/2 or math.atan2(3*T-1,denom)
        local yawCF=CFrame.new(jd_Camera.CFrame.Position,jd_Camera.CFrame.Position+flatDir)
        return yawCF*CFrame.Angles(alpha,0,0)
    end)
    return ok and result or nil
end

local function jd_getLocalActor() 
    return jd_lp.Character
end

local function jd_applyPatch(actor)
    local ok = pcall(function()
        if jd_patched or not actor or not jd_NetworkRF then return end
        
        rfDispatch:install(jd_NetworkRF)
        
        rfDispatch:register("jd", function(reqName, ...)
            local hookOk, result = pcall(function()
                if not (jd_enabled and jd_aimbotOn) then return nil end
                local char = jd_lp.Character
                local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                if not myHRP then return nil end
                
                -- Get nearest killer
                local killerFolder = getTeamFolder("Killers")
                if not killerFolder then return nil end
                
                local best, bestDist = nil, math.huge
                for _, killer in ipairs(killerFolder:GetChildren()) do
                    local hrp = killer:FindFirstChild("HumanoidRootPart")
                    local h = killer:FindFirstChildOfClass("Humanoid")
                    if hrp and h and h.Health > 0 then
                        local d = (hrp.Position - myHRP.Position).Magnitude
                        if d < bestDist then bestDist = d; best = hrp end
                    end
                end
                
                if not best then return nil end
                
                if reqName == "GetMousePosition" then
                    local vel = jd_getKillerVelocity(best)
                    local pos = best.Position + vel * jd_PREDICTION + Vector3.new(0, jd_AIM_OFFSET, 0)
                    return pos
                end
                
                if reqName == "GetCameraCF" then
                    local cf = jd_buildCamCF(myHRP, best, 250, 40)
                    if cf then return cf end
                end
                return nil
            end)
            if hookOk then return result else return nil end
        end)
        jd_patched = true
    end)
    if not ok then warn("Failed to apply patch: " .. tostring(ok)) end
end

local function jd_removePatch()
    local ok = pcall(function()
        if not jd_patched then return end
        rfDispatch:unregister("jd")
        if next(rfDispatch.hooks) == nil then
            rfDispatch:uninstall(jd_NetworkRF)
        end
        jd_patched = false
    end)
    if not ok then warn("Failed to remove patch") end
end

-- Forever Hold hook - forces 999 past input on every crystal use
local jd_foreverHook
task.spawn(function()
    while not jd_RemoteEvent do task.wait(0.5) end

    local crystalInputName = jd_lp.Name .. "CrystalInput"

    jd_foreverHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self == jd_RemoteEvent and jd_enabled and jd_foreverHold then
            local args = {...}
            if args[1] == crystalInputName then
                -- Set the charge time to 999 seconds in the past
                pcall(function()
                    local actors = safeRequirePath(svc.RS, "Modules", "Gameplay", "Actors")
                    if actors then
                        local janeActor = actors.CurrentActors[svc.Players.LocalPlayer]
                        if janeActor and janeActor.State then
                            janeActor.State.CrystalFullChargeTime = os.clock() - 999
                        end
                    end
                end)
            end
        end
        return jd_foreverHook(self, ...)
    end))
end)

-- Axe OnClientEvent handler
task.spawn(function()
    while not jd_RemoteEvent do task.wait(0.5) end

    local connection
    connection = jd_RemoteEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        if not jd_enabled then return end

        if jd_axeEnabled and args[1] == "UseActorAbility" and args[2] and args[2][1] then
            local ok2, bs = pcall(function() return buffer.tostring(args[2][1]) end)
            if ok2 and bs and bs:find("Axe") then
                task.spawn(jd_axeDoLock)
            end
        end
    end)

    getgenv()._jdConnection = connection
end)

task.spawn(function()
    local lastActor=nil
    while not jd_unloaded do
        task.wait(0.5)
        local cur=jd_getLocalActor()
        if cur~=lastActor then
            if lastActor~=nil then 
                jd_patched=false
                jd_killerMotionData={} 
            end
            lastActor=cur
            if cur and jd_enabled then 
                jd_applyPatch(cur) 
            end
        end
    end
end)

-- ============================================================
-- JANE DOE UI
-- ============================================================
local sec_024 = tabJaneDoe:Section({ Title = "Crystal Auto-Fire", Opened = true })

sec_024:Toggle({ 
    Title = "Enable Jane Doe Aimbot", 
    Flag = "jdEnabled", 
    Default = false, 
    Type = "Checkbox",
    Callback = function(on)
        jd_enabled = on
        local actor = jd_getLocalActor()
        if on and not jd_patched and actor then 
            jd_applyPatch(actor) 
        end
    end
})

sec_024:Toggle({ 
    Title = "Aimbot (Silent Aim)", 
    Flag = "jdSilentAim", 
    Default = false, 
    Type = "Checkbox",
    Callback = function(on)
        jd_aimbotOn = on
        local actor = jd_getLocalActor()
        if on and not jd_patched and actor then 
            jd_applyPatch(actor) 
        end
    end
})

local sec_025 = tabJaneDoe:Section({ Title = "Axe Lock-On", Opened = false })

sec_025:Toggle({ 
    Title = "Enable Axe Lock-On", 
    Flag = "jdAxeEnabled", 
    Default = false, 
    Type = "Checkbox",
    Callback = function(on) 
        jd_axeEnabled = on
    end
})

sec_025:Slider({ 
    Title = "Lock Duration (s)", 
    Flag = "jdAxeLockDur", 
    Value = {Min=0.5,Max=3.0,Default=jd_AXE_LOCK_DURATION}, 
    Step = 0.1, 
    Callback = function(v) 
        jd_AXE_LOCK_DURATION = v
    end 
})

sec_024:Slider({ 
    Title = "Aim Offset (Y)", 
    Flag = "jdAimOffset", 
    Value = {Min=-5.0,Max=5.0,Default=jd_AIM_OFFSET}, 
    Step = 0.1, 
    Callback = function(v) jd_AIM_OFFSET = v end 
})

sec_024:Slider({ 
    Title = "Prediction", 
    Flag = "jdPrediction", 
    Value = {Min=0.0,Max=1.0,Default=jd_PREDICTION}, 
    Step = 0.01, 
    Callback = function(v) jd_PREDICTION = v end 
})

local sec_026 = tabJaneDoe:Section({ Title = "Control", Opened = false })

sec_026:Button({ 
    Title = "Unload Jane Doe", 
    Callback = function()
        if jd_unloaded then return end
        jd_unloaded = true
        jd_enabled = false
        jd_aimbotOn = false
        jd_axeEnabled = false
        jd_foreverHold = false
        if jd_foreverHoldThread then
            task.cancel(jd_foreverHoldThread)
            jd_foreverHoldThread = nil
        end
        jd_removePatch()
        if getgenv()._jdConnection then
            pcall(function() getgenv()._jdConnection:Disconnect() end)
            getgenv()._jdConnection = nil
        end
    end
})
end -- [SorsHub: scope local]


tabJaneDoe:Section({ Title = "System" }):Button({
    Title = "Unload Script Completely",
    Callback = function()
        local ok, rf = pcall(function()
            return svc.RS:WaitForChild("Modules", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("RemoteFunction", 2)
        end)
        if ok and rf then
            rfDispatch:uninstall(rf)
        end
        if getgenv()._jdConnection then
            pcall(function() getgenv()._jdConnection:Disconnect() end)
            getgenv()._jdConnection = nil
        end
        tabJaneDoe:Destroy()
    end
})

-- ============================================================
-- ELLIOT AIMBOT TAB
-- ============================================================

local tabElliot = win:Tab({ Title = "Elliot", Icon = "crosshair" })

local elliotEnabled = false
local elliotConnection = nil
local elliotAutoRotBak = nil
local elliotAimType = "Camera + Character"
local elliotThrowDur = 0.6
local elliotIsThrowing = false
local elliotThrowTS = 0
local elliotRequireAnim = true
local elliotShowArc = false
local elliotArcFolder = nil
local elliotArcParts = {}
local elliotArcSegs = 50
local elliotThrowForce = 80
local elliotUpComp = 0.5
local elliotGravity = 196.2
local elliotHum, elliotHRP = nil, nil
local elliotTargetMode = "Low HP"
local elliotLastAimTime = 0
local elliotSmoothness = 0.15
local elliotPredDist = 5
do -- [SorsHub: scope local]
local elliotThrowAnimId = "rbxassetid://114155003741146"

local function elliotSetupChar(char)
    elliotHum = char:WaitForChild("Humanoid", 3)
    elliotHRP = char:WaitForChild("HumanoidRootPart", 3)
    
    if elliotHum then
        local animator = elliotHum:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(animTrack)
                if not animTrack or not animTrack.Animation then return end
                local animId = ""
                pcall(function() animId = tostring(animTrack.Animation.AnimationId) end)
                if animId:find("114155003741146") or animId:find(elliotThrowAnimId) then
                    elliotIsThrowing = true
                    elliotThrowTS = tick()
                end
            end)
        else
            elliotHum.ChildAdded:Connect(function(child)
                if child:IsA("Animator") then
                    child.AnimationPlayed:Connect(function(animTrack)
                        if not animTrack or not animTrack.Animation then return end
                        local animId = ""
                        pcall(function() animId = tostring(animTrack.Animation.AnimationId) end)
                        if animId:find("114155003741146") or animId:find(elliotThrowAnimId) then
                            elliotIsThrowing = true
                            elliotThrowTS = tick()
                        end
                    end)
                end
            end)
        end
    end
end

if lp.Character then elliotSetupChar(lp.Character) end
lp.CharacterAdded:Connect(function(c) elliotSetupChar(c) end)
end -- [SorsHub: scope local]


local function elliotClearArc()
    for _, p in ipairs(elliotArcParts) do if p and p.Parent then p:Destroy() end end
    elliotArcParts = {}
end

local function elliotCreateArcFolder()
    if elliotArcFolder then elliotArcFolder:Destroy() end
    elliotArcFolder = Instance.new("Folder")
    elliotArcFolder.Name = "ElliotArc"
    elliotArcFolder.Parent = svc.WS
end

local function elliotArcCalc(startPos, lookVec)
    local dir = (lookVec + Vector3.new(0, elliotUpComp, 0)).Unit
    local iv = dir * elliotThrowForce
    local maxT = 3
    local pts = {}
    local step = maxT / elliotArcSegs
    local last = startPos
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { lp.Character, elliotArcFolder }
    
    for i = 0, elliotArcSegs do
        local t = i * step
        local pos = startPos + iv*t + Vector3.new(0, -0.5*elliotGravity*t*t, 0)
        if i > 0 then
            local d = pos - last
            local dm = d.Magnitude
            if dm > 0 then
                local res = svc.WS:Raycast(last, d.Unit*dm, rp)
                if res then
                    table.insert(pts, res.Position)
                    break
                end
            end
        end
        if pos.Y < -100 then break end
        table.insert(pts, pos)
        last = pos
    end
    return pts
end

local _elliotLastArcUpdate = 0
local function elliotUpdateArc()
    if not elliotShowArc or not elliotHRP then
        elliotClearArc()
        return
    end
    
    local now = tick()
    if now - _elliotLastArcUpdate < 0.1 then return end
    _elliotLastArcUpdate = now
    
    local char = lp.Character
    local lArm = char and (char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand") or char:FindFirstChild("LeftLowerArm"))
    local startPos = lArm and lArm.Position or (elliotHRP.Position + Vector3.new(-1,1,0) + elliotHRP.CFrame.LookVector*2)
    local pts = elliotArcCalc(startPos, elliotHRP.CFrame.LookVector)
    
    elliotClearArc()
    if not elliotArcFolder then elliotCreateArcFolder() end
    
    for i, p in ipairs(pts) do
        local part = Instance.new("Part")
        part.Name = "ArcSeg"..i
        part.Size = Vector3.new(0.25, 0.25, 0.25)
        part.Position = p
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Shape = Enum.PartType.Ball
        
        if i == #pts and #pts > 1 then
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.Color = Color3.fromRGB(255, 255, 0)
            part.Transparency = 0
        else
            part.Color = Color3.fromRGB(255, 0, 0)
            part.Transparency = 0.15
        end
        
        part.Parent = elliotArcFolder
        table.insert(elliotArcParts, part)
    end
end

local function elliotFindTarget()
    local sf = getTeamFolder("Survivors")
    if not sf or not elliotHRP then return nil end
    
    local best, bestVal = nil, math.huge
    for _, s in ipairs(sf:GetChildren()) do
        if s ~= lp.Character then
            local h = s:FindFirstChildOfClass("Humanoid")
            local r = s:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 then
                local val = elliotTargetMode == "Closest"
                    and (r.Position - elliotHRP.Position).Magnitude
                    or h.Health
                if val < bestVal then
                    best = r
                    bestVal = val
                end
            end
        end
    end
    return best
end

local function elliotAimAt(tgt)
    if not tgt or not tgt.Parent then return end
    
    local now = tick()
    if now - elliotLastAimTime < 0.016 then return end
    elliotLastAimTime = now
    
    local vel = tgt.AssemblyLinearVelocity or Vector3.zero
    local pos = tgt.Position
    local predPos = pos
    
    if vel.Magnitude > 2 then
        local dist = (tgt.Position - elliotHRP.Position).Magnitude
        local predTime = math.min(dist / elliotThrowForce, 1.0)
        predPos = tgt.Position + (vel * predTime * (elliotPredDist / 5))
    end
    
    if elliotAimType == "HRP Aimbot" or elliotAimType == "Camera + Character" then
        if elliotHRP and elliotHum then
            if elliotAutoRotBak == nil then
                elliotAutoRotBak = elliotHum.AutoRotate
                elliotHum.AutoRotate = false
            end
            
            elliotHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            local direction = (predPos - elliotHRP.Position)
            local flatDirection = Vector3.new(direction.X, 0, direction.Z)
            
            if flatDirection.Magnitude > 0.1 then
                local lookAt = CFrame.lookAt(elliotHRP.Position, elliotHRP.Position + flatDirection.Unit)
                local cur = elliotHRP.CFrame
                local nCF = cur:Lerp(CFrame.new(cur.Position) * lookAt.Rotation, elliotSmoothness)
                elliotHRP.CFrame = nCF
            end
        end
    end
    
    if elliotAimType == "Camera Aimbot" or elliotAimType == "Camera + Character" then
        local cam = svc.WS.CurrentCamera
        if cam then
            local targetCF = CFrame.lookAt(cam.CFrame.Position, predPos)
            cam.CFrame = cam.CFrame:Lerp(targetCF, elliotSmoothness * 1.5)
        end
    end
end

local function elliotStartAimbot()
    if elliotConnection then elliotConnection:Disconnect() end
    
    elliotConnection = svc.Run.RenderStepped:Connect(function()
        if not elliotEnabled or not elliotHum or not elliotHRP then
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
            return
        end
        
        if elliotShowArc then elliotUpdateArc() end
        
        local shouldAim = false
        if elliotRequireAnim then
            shouldAim = elliotIsThrowing and (tick() - elliotThrowTS) <= elliotThrowDur
        else
            shouldAim = true
        end
        
        if elliotIsThrowing and (tick() - elliotThrowTS) > elliotThrowDur then
            elliotIsThrowing = false
        end
        
        if not shouldAim then
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
            return
        end
        
        local tgt = elliotFindTarget()
        if tgt then
            elliotAimAt(tgt)
        else
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
        end
    end)
end

do -- [SorsHub: scope local]
local elliotMainTab = tabElliot:Section({ Title = "Aimbot", Opened = true })

elliotMainTab:Toggle({
    Title = "Enable Aimbot",
    Description = "Toggle the aimbot on/off",
    Default = false,
    Flag = "elliotEnabled",
    Callback = function(v)
        elliotEnabled = v
        if v then
            elliotStartAimbot()
            print("[Elliot] ✅ Aimbot enabled")
        else
            if elliotConnection then
                elliotConnection:Disconnect()
                elliotConnection = nil
            end
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
            elliotClearArc()
            elliotIsThrowing = false
            print("[Elliot] ❌ Aimbot disabled")
        end
    end
})

elliotMainTab:Dropdown({
    Title = "Aimbot Type",
    Description = "Choose how the aimbot targets",
    Values = {"HRP Aimbot", "Camera Aimbot", "Camera + Character"},
    Value = "Camera + Character",
    Flag = "elliotAimType",
    Callback = function(v)
        elliotAimType = v
        print("[Elliot] Aimbot type: " .. v)
    end
})

elliotMainTab:Dropdown({
    Title = "Target Mode",
    Description = "How targets are selected",
    Values = {"Low HP", "Closest"},
    Value = "Low HP",
    Flag = "elliotTargetMode",
    Callback = function(v)
        elliotTargetMode = v
        print("[Elliot] Target mode: " .. v)
    end
})

elliotMainTab:Slider({
    Title = "Throw Window (s)",
    Description = "Duration of throw animation window",
    Step = 0.1,
    Value = { Min = 0.1, Max = 2, Default = 0.6 },
    Flag = "elliotThrowDur",
    Callback = function(v)
        elliotThrowDur = v
    end
})

elliotMainTab:Slider({
    Title = "Smoothness",
    Description = "How smooth the aimbot transitions",
    Step = 0.01,
    Value = { Min = 0.05, Max = 0.5, Default = 0.15 },
    Flag = "elliotSmoothness",
    Callback = function(v)
        elliotSmoothness = v
    end
})

elliotMainTab:Slider({
    Title = "Prediction (studs)",
    Description = "How much to predict target movement",
    Step = 1,
    Value = { Min = 0, Max = 50, Default = 5 },
    Flag = "elliotPredDist",
    Callback = function(v)
        elliotPredDist = v
    end
})

elliotMainTab:Slider({
    Title = "Throw Force",
    Description = "Force of the throw",
    Step = 5,
    Value = { Min = 50, Max = 150, Default = 80 },
    Flag = "elliotThrowForce",
    Callback = function(v)
        elliotThrowForce = v
    end
})

elliotMainTab:Slider({
    Title = "Arc Segments",
    Description = "Number of segments in arc visualization",
    Step = 5,
    Value = { Min = 20, Max = 100, Default = 50 },
    Flag = "elliotArcSegs",
    Callback = function(v)
        elliotArcSegs = v
    end
})

elliotMainTab:Toggle({
    Title = "Require Animation",
    Description = "Only aim when throw animation plays",
    Default = true,
    Flag = "elliotRequireAnim",
    Callback = function(v)
        elliotRequireAnim = v
        print("[Elliot] Animation requirement: " .. (v and "ON" or "OFF"))
    end
})

elliotMainTab:Toggle({
    Title = "Show Arc Visualization",
    Description = "Display the throw arc",
    Default = false,
    Flag = "elliotShowArc",
    Callback = function(v)
        elliotShowArc = v
        if v then
            elliotCreateArcFolder()
            print("[Elliot] Arc visualization enabled")
        else
            elliotClearArc()
            if elliotArcFolder then
                elliotArcFolder:Destroy()
                elliotArcFolder = nil
            end
            print("[Elliot] Arc visualization disabled")
        end
    end
})

elliotMainTab:Button({
    Title = "Unload Elliot",
    Callback = function()
        elliotEnabled = false
        if elliotConnection then
            elliotConnection:Disconnect()
            elliotConnection = nil
        end
        if elliotAutoRotBak ~= nil and elliotHum then
            elliotHum.AutoRotate = elliotAutoRotBak
            elliotAutoRotBak = nil
        end
        elliotClearArc()
        if elliotArcFolder then
            elliotArcFolder:Destroy()
            elliotArcFolder = nil
        end
        elliotIsThrowing = false
        tabElliot:Destroy()
    end
})
end -- [SorsHub: scope local]


-- ============================================================
-- CHANCE AIMBOT TAB
-- ============================================================

do -- [SorsHub: scope local]
local tabChance = win:Tab({ Title = "Chance", Icon = "crosshair" })

do
    local sec_chance = tabChance:Section({ Title = "Chance Aimbot", Opened = true })

    chanceAimEnabled  = false
    local chancePredMode    = "Velocity"
    local chancePredValue   = 0.5
    local chanceAimBehavior = "Normal"
    local chanceSpinDur     = 0.5
    local chanceMsgOnAim    = false
    local chanceMsgText     = ""
    local chanceCustomAnim  = false
    local chanceCustomAnimID= ""
    local chanceAntiBait    = true
    local chanceSmoothSpeed = 14
    local chanceHeightAim   = true
    local chanceHoldToAim   = true
    local chanceAimKey      = Enum.KeyCode.Q
    local chanceHoldingKey  = false
    local chanceAiming      = false
    local chanceStartTime   = 0
    local chanceAimDuration = 1.7

    local chanceKillerSpeeds = {
        Slasher={walk=9,run=28}, c00lkidd={walk=7.75,run=28}, JohnDoe={walk=9,run=27.25},
        ["1x1x1x1"]={walk=8.5,run=27}, Noli={walk=7.5,run=27.5}, Guest666={walk=9,run=27},
        Nosferatu={walk=7.25,run=27.5}, Doombringer={walk=8,run=27}, JaneDoe={walk=9,run=27},
        Builderman={walk=8.5,run=27.5}, Dusekkar={walk=8,run=27.5},
    }

    local chanceHum, chanceHRP, chanceBodyGyro, chanceSavedAutoRotate
    local function chanceSetChar(c)
        chanceHum = c:WaitForChild("Humanoid")
        chanceHRP = c:WaitForChild("HumanoidRootPart")
    end
    if lp.Character then chanceSetChar(lp.Character) end
    lp.CharacterAdded:Connect(chanceSetChar)

    local chanceMotion = {}
    local function chanceGetMotion(hrp)
        local now=tick(); local pos=hrp.Position; local data=chanceMotion[hrp]
        if not data then
            chanceMotion[hrp]={lastPos=pos,lastTime=now,velocity=Vector3.zero,accel=Vector3.zero}
            return Vector3.zero, Vector3.zero
        end
        local dt=now-data.lastTime; if dt<=0 then return data.velocity,data.accel end
        local vel=(pos-data.lastPos)/dt; local acc=(vel-data.velocity)/dt
        data.lastPos=pos; data.lastTime=now; data.accel=acc; data.velocity=vel
        return vel, acc
    end

    local chancePingSamples={}
    local _chanceLastPingTime=0
    local _chanceLastPingVal=0.1
    local function chanceGetPing()
        local now=tick()
        if now-_chanceLastPingTime<1 then return _chanceLastPingVal end
        _chanceLastPingTime=now
        local ok,stat=pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        local raw=(ok and stat or 100)/1000
        table.insert(chancePingSamples,raw)
        if #chancePingSamples>5 then table.remove(chancePingSamples,1) end
        local s=0; for _,v in ipairs(chancePingSamples) do s=s+v end
        _chanceLastPingVal=s/#chancePingSamples
        return _chanceLastPingVal
    end

    local function chanceGetNearest()
        if not chanceHRP then return end
        local folder=getTeamFolder("Killers"); if not folder then return end
        local closest,dist=nil,math.huge
        for _,m in ipairs(folder:GetChildren()) do
            local r=m:FindFirstChild("HumanoidRootPart")
            local h=m:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health>0 then
                local d=(r.Position-chanceHRP.Position).Magnitude
                if d<dist then dist=d; closest=r end
            end
        end
        return closest
    end

    local function chancePredict(hrp)
        local vel,accel=chanceGetMotion(hrp); local pos=hrp.Position; local speed=vel.Magnitude
        if chanceAntiBait then
            local model=hrp.Parent
            if model and chanceKillerSpeeds[model.Name] then
                local maxSpd=chanceKillerSpeeds[model.Name].run+2
                if speed>maxSpd then vel=vel.Unit*maxSpd; speed=maxSpd end
            end
        end
        local ping=chanceGetPing()
        local dist=chanceHRP and (hrp.Position-chanceHRP.Position).Magnitude or 0
        local ds=dist*0.003; local lead
        if chancePredMode=="Velocity" then lead=chancePredValue+ds
        elseif chancePredMode=="Ping" then lead=ping*chancePredValue+ds
        elseif chancePredMode=="Look" then return pos+hrp.CFrame.LookVector*(speed*chancePredValue)
        elseif chancePredMode=="LookPing" then return pos+hrp.CFrame.LookVector*(speed*ping)
        else lead=chancePredValue end
        if speed<0.5 then return pos end
        local ac=accel*lead*lead*0.5
        if ac.Magnitude>speed*0.4 then ac=ac.Unit*(speed*0.4) end
        return pos+vel*lead+ac
    end

    local function chanceHookAnimator(char)
        local hum=char:WaitForChild("Humanoid")
        local anim=hum:WaitForChild("Animator")
        local chanceTriggers={
            ["133607163653602"]=true,["133491532453922"]=true,["131189930305001"]=true,
            ["111384272984267"]=true,["103601716322988"]=true,["76649505662612"]=true
        }
        anim.AnimationPlayed:Connect(function(track)
            if not chanceAimEnabled or chanceHoldToAim then return end
            local id=track.Animation.AnimationId:match("%d+")
            if id and chanceTriggers[id] then
                if chanceHum then
                    chanceSavedAutoRotate = chanceHum.AutoRotate
                    chanceHum.AutoRotate = false
                end
                chanceAiming=true; chanceStartTime=tick()
                track.Ended:Connect(function()
                    if chanceHum and chanceSavedAutoRotate ~= nil then
                        chanceHum.AutoRotate = chanceSavedAutoRotate
                    end
                    if chanceBodyGyro and chanceBodyGyro.Parent then
                        chanceBodyGyro:Destroy(); chanceBodyGyro = nil
                    end
                    chanceAiming = false
                end)
            end
        end)
    end
    if lp.Character then chanceHookAnimator(lp.Character) end
    lp.CharacterAdded:Connect(chanceHookAnimator)

    svc.Input.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if chanceHoldToAim and input.KeyCode==chanceAimKey then
            chanceHoldingKey=true; chanceAiming=true; chanceStartTime=tick()
        end
    end)
    svc.Input.InputEnded:Connect(function(input)
        if chanceHoldToAim and input.KeyCode==chanceAimKey then
            chanceHoldingKey=false; chanceAiming=false
        end
    end)

    svc.Run.RenderStepped:Connect(function(dt)
        if not chanceAimEnabled or not chanceHRP then return end
        if chanceHoldToAim then
            if not chanceHoldingKey then return end
        else
            if not chanceAiming then return end
            if tick()-chanceStartTime>chanceAimDuration then chanceAiming=false; return end
        end
        local target=chanceGetNearest(); if not target then return end
        local pos=chancePredict(target); if not pos then return end
        local aimPos=chanceHeightAim and pos or Vector3.new(pos.X,chanceHRP.Position.Y,pos.Z)
        if chanceAimBehavior=="360" then
            local prog=(tick()-chanceStartTime)/chanceSpinDur
            if prog<1 then
                chanceHRP.CFrame=CFrame.new(chanceHRP.Position)*CFrame.Angles(0,math.rad(360*prog),0)
                return
            end
        end
        if not chanceBodyGyro or not chanceBodyGyro.Parent then
            chanceBodyGyro = Instance.new("BodyGyro")
            chanceBodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
            chanceBodyGyro.P = 10000; chanceBodyGyro.D = 500
            chanceBodyGyro.Parent = chanceHRP
        end
        chanceBodyGyro.CFrame = CFrame.lookAt(chanceHRP.Position, aimPos)
    end)

    -- UI
    sec_chance:Toggle({ Title = "Enable Aimbot", Flag = "chanceAimOn", Default = false,
        Callback = function(v)
            chanceAimEnabled = v
            if not v then
                if chanceBodyGyro and chanceBodyGyro.Parent then chanceBodyGyro:Destroy(); chanceBodyGyro=nil end
                if chanceHum and chanceSavedAutoRotate ~= nil then chanceHum.AutoRotate=chanceSavedAutoRotate end
            end
        end, Type = "Checkbox"})

    sec_chance:Dropdown({ Title = "Prediction Mode", Flag = "chancePredMode",
        Values = {"Velocity","Ping","Look","LookPing"}, Value = "Velocity",
        Callback = function(v) chancePredMode=v end })

    sec_chance:Input({ Title = "Prediction Value", Flag = "chancePredVal", Placeholder = "0.5",
        Callback = function(v) local n=tonumber(v); if n then chancePredValue=n end end })

    sec_chance:Slider({ Title = "Smooth Speed", Flag = "chanceSmoothSpd",
        Value = {Min=1,Max=30,Default=14}, Step = 1,
        Callback = function(v) chanceSmoothSpeed=v end })

    sec_chance:Toggle({ Title = "Height-Aware Aim", Flag = "chanceHeightAim", Default = true,
        Callback = function(v) chanceHeightAim=v end, Type = "Checkbox"})

    sec_chance:Dropdown({ Title = "Aim Behavior", Flag = "chanceAimBehav",
        Values = {"Normal","360"}, Value = "Normal",
        Callback = function(v) chanceAimBehavior=v end })

    sec_chance:Input({ Title = "Spin Duration", Flag = "chanceSpinDur", Placeholder = "0.5",
        Callback = function(v) local n=tonumber(v); if n then chanceSpinDur=n end end })

    sec_chance:Toggle({ Title = "Anti Bait", Flag = "chanceAntiBait", Default = true,
        Callback = function(v) chanceAntiBait=v end, Type = "Checkbox"})

    sec_chance:Toggle({ Title = "Hold-to-Aim", Flag = "chanceHoldAim", Default = true,
        Callback = function(v) chanceHoldToAim=v end, Type = "Checkbox"})

    sec_chance:Dropdown({ Title = "Aim Key", Flag = "chanceAimKey",
        Values = {"Q","E","R","T","F","G","X","C","V"}, Value = "Q",
        Callback = function(v) chanceAimKey=Enum.KeyCode[v] end })

    sec_chance:Toggle({ Title = "Message When Aim", Flag = "chanceMsgOnAim", Default = false,
        Callback = function(v) chanceMsgOnAim=v end, Type = "Checkbox"})

    sec_chance:Input({ Title = "Message Text", Flag = "chanceMsgText", Placeholder = "...",
        Callback = function(v) chanceMsgText=v end })

    sec_chance:Button({
        Title = "Ping Aim Preset",
        Callback = function()
            chancePredMode = "Ping"; chancePredValue = 1.5
        end,
    })

    sec_chance:Button({
        Title = "Owner's Setting Opinion",
        Callback = function()
            ui:Notify({
                Title = "Owner's Opinion",
                Content = "0.5 works best for 90-120 ping\nSame for ping 1.5\nIf high ping use 0.4 velocity\nElse 1.3 ping",
                Duration = 10,
                Icon = "info",
            })
        end,
    })

    sec_chance:Button({
        Title = "Unload Chance",
        Callback = function()
            chanceAimEnabled = false
            if chanceBodyGyro and chanceBodyGyro.Parent then chanceBodyGyro:Destroy(); chanceBodyGyro=nil end
            if chanceHum and chanceSavedAutoRotate ~= nil then chanceHum.AutoRotate=chanceSavedAutoRotate end
            tabChance:Destroy()
        end,
    })
end
end -- [SorsHub: scope local]


-- ============================================================
-- DUSEKKAR TAB
-- ============================================================

local tabDusekkar = win:Tab({ Title = "Dusekkar", Icon = "zap" })

local plasma_enabled = false
local plasma_aimOffset = 0.0
local plasma_prediction = 0.12
do -- [SorsHub: scope local]
local plasma_rf = nil
local plasma_motionData = {}

local function plasmaGetNearestKiller()
    local char = lp.Character; if not char then return nil end
    local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
    local kf = getTeamFolder("Killers")
    if not kf then return nil end
    local best, bestDist = nil, math.huge
    for _, model in ipairs(kf:GetChildren()) do
        if model ~= char then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d < bestDist then bestDist = d; best = hrp end
            end
        end
    end
    return best
end

local function plasmaGetVelocity(hrp)
    local now = tick(); local pos = hrp.Position
    local data = plasma_motionData[hrp]
    if not data then
        plasma_motionData[hrp] = { lastPos = pos, lastTime = now, vel = Vector3.zero }
        return Vector3.zero
    end
    local dt = now - data.lastTime
    if dt > 0 then
        data.vel = (pos - data.lastPos) / dt
        data.lastPos = pos
        data.lastTime = now
    end
    return data.vel
end

local function plasmaUnpatch()
    if plasma_rf then
        rfDispatch:uninstall(plasma_rf)
    end
    plasma_rf = nil
end

lp.CharacterAdded:Connect(function() plasma_motionData = {} end)

local sec_027 = tabDusekkar:Section({ Title = "PlasmaBeam Silent Aim", Opened = true })

sec_027:Toggle({
    Title = "Enable PlasmaBeam Aim", Default = plasma_enabled, Type = "Checkbox", Flag = "plasmaEnabled",
    Callback = function(on) plasma_enabled = on end
})

sec_027:Slider({
    Title = "Prediction (s)", Flag = "plasmaPrediction", Value = {Min=0.0, Max=0.5, Default=plasma_prediction}, Step = 0.01,
    Callback = function(v) plasma_prediction = v end
})

sec_027:Slider({
    Title = "Aim Height Offset", Flag = "plasmaAimOffset", Value = {Min=-5.0, Max=5.0, Default=plasma_aimOffset}, Step = 0.1,
    Callback = function(v) plasma_aimOffset = v end
})

local sec_028 = tabDusekkar:Section({ Title = "Control", Opened = false })
sec_028:Button({
    Title = "Unload PlasmaBeam Hook", Callback = function()
        plasma_enabled = false; plasmaUnpatch()
    end
})

local function plasmaPatch()
    local ok, rf = pcall(function()
        return svc.RS:WaitForChild("Modules", 10)
            :WaitForChild("Network", 10)
            :WaitForChild("Network", 10)
            :WaitForChild("RemoteFunction", 10)
    end)
    if not ok or not rf then warn("[SorsHub] Shared RF not found"); return end
    
    plasma_rf = rf
    rfDispatch:install(rf)
    
    rfDispatch:register("plasma", function(reqName, ...)
        if reqName ~= "GetMousePosition" or not plasma_enabled then return nil end
        local hrp = plasmaGetNearestKiller()
        if not hrp then return nil end
        local vel = plasmaGetVelocity(hrp)
        return hrp.Position + vel * plasma_prediction + Vector3.new(0, plasma_aimOffset, 0)
    end)
end

task.spawn(plasmaPatch)
end -- [SorsHub: scope local]


tabDusekkar:Section({ Title = "System" }):Button({
    Title = "Unload Script Completely",
    Callback = function()
        local ok, rf = pcall(function()
            return svc.RS:WaitForChild("Modules", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("RemoteFunction", 2)
        end)
        if ok and rf then
            rfDispatch:uninstall(rf)
        end
        tabDusekkar:Destroy()
    end
})

-- ============================================================
-- GUEST 1337 - COMBINED TAB (CORE / HDT / DETECTION / LINE / MOBILITY)
-- ============================================================

do -- [SorsHub: scope local]
local tabGuest1337 = win:Tab({ Title = "Guest1337", Icon = "shield" })

do -- tabGuestCore
local tabGuestCore = tabGuest1337

local guestCfg = {
    autoBlockOn = false, blockDelay = 0, detectionRange = 20,
    verifyFacingCheck = true, visionRange = 13.5, visionAngle = 85,
    showVisionCone = false, noHDTCooldown = false, hdtCooldownChecker = false,
    blockCooldown = 0.35, autoPunchDelay = 0.3,
    reverseEnabled = false, legacyFacingEnabled = false,
    legacyVisionRange = 13.5, legacyVisionAngle = 85, legacyShowVisionRange = false,
    pingCheckerEnabled = false, noclipEnabled = false,
    noclipOnlyWhenBlockReady = false, fpsCounterEnabled = false,
    smartDelayEnabled = false, manualDragEnabled = false,
    autoPunchOn = false, aimPunchActive = false,
    punchPrediction = 2.3, customPunchSoundId = 0, aimPunchDuration = 0.5,
    cinematicTextEnabled = false, cinematicText = "PARRY!",
    -- FIXED: Added soundBlockEnabled flag
    soundBlockEnabled = false,
}

local g = {
    humanoid = nil, hrp = nil, lastBlockTime = 0,
    soundBlockedUntil = {}, soundHooks = {}, killerState = {},
    punchAiming = false, punchLastTriggerTime = 0,
    originalWS = nil, originalJP = nil, originalAutoRotate = nil, aimConnection = nil,
    centerPart = nil, leftPart = nil, rightPart = nil,
    leftToKillerPart = nil, rightToKillerPart = nil,
    leftToCenterPart = nil, centerToRightPart = nil,
    pingLabel = nil, hdtCooldownGui = nil, hdtCooldownLabel = nil,
    fpsGui = nil, fpsLabel = nil, cinematicGui = nil,
    lastFpsUpdate = 0, frameCount = 0, fps = 0,
    noclipConn = nil,
    visionCleanupConn = nil,
    mapConns = {},
    ingameConns = {},
    roundActive = false,
}

local g_remote = nil
pcall(function()
    g_remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
end)

local function g_cleanupVision()
    if g.centerPart then pcall(function() g.centerPart:Destroy() end); g.centerPart = nil end
    if g.leftPart then pcall(function() g.leftPart:Destroy() end); g.leftPart = nil end
    if g.rightPart then pcall(function() g.rightPart:Destroy() end); g.rightPart = nil end
    if g.leftToKillerPart then pcall(function() g.leftToKillerPart:Destroy() end); g.leftToKillerPart = nil end
    if g.rightToKillerPart then pcall(function() g.rightToKillerPart:Destroy() end); g.rightToKillerPart = nil end
    if g.leftToCenterPart then pcall(function() g.leftToCenterPart:Destroy() end); g.leftToCenterPart = nil end
    if g.centerToRightPart then pcall(function() g.centerToRightPart:Destroy() end); g.centerToRightPart = nil end
end

local function g_cleanupRoundWatcher()
    if g.visionCleanupConn then
        pcall(function() g.visionCleanupConn:Disconnect() end)
        g.visionCleanupConn = nil
    end
    for _, conn in ipairs(g.mapConns) do
        pcall(function() conn:Disconnect() end)
    end
    g.mapConns = {}
    for _, conn in ipairs(g.ingameConns) do
        pcall(function() conn:Disconnect() end)
    end
    g.ingameConns = {}
end

local function g_setupRoundWatcher()
    g_cleanupRoundWatcher()
    
    local map = findPath(svc.WS, "Map")
    if map then
        g.visionCleanupConn = map.AncestryChanged:Connect(function()
            if not map.Parent then
                print("[Guest Block] Map removed - cleaning vision")
                g_cleanupVision()
                g.roundActive = false
                task.wait(0.5)
                g_setupRoundWatcher()
            end
        end)
    end
    
    local function onIngameCreated(ingame)
        print("[Guest Block] New round detected - vision will restore")
        g.roundActive = true
        task.wait(0.1)
        pcall(g_updateVision)
    end
    
    local function watchForIngame()
        local map2 = findPath(svc.WS, "Map")
        if map2 then
            local ingame = getIngame()
            if ingame then
                g.roundActive = true
                task.wait(0.1)
                pcall(g_updateVision)
            end
            
            local conn = map2.ChildAdded:Connect(function(child)
                if child.Name == "Ingame" then
                    onIngameCreated(child)
                end
            end)
            table.insert(g.mapConns, conn)
        end
    end
    
    watchForIngame()
    
    local wsConn = svc.WS.ChildAdded:Connect(function(child)
        if child.Name == "Map" then
            task.wait(0.5)
            g_setupRoundWatcher()
        end
    end)
    table.insert(g.mapConns, wsConn)
end

task.spawn(function()
    task.wait(0.5)
    g_setupRoundWatcher()
end)

local function g_fireBlock()
    if g_remote then pcall(function() g_remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Block")}) end) end
end

local function g_firePunch()
    if not g_remote then return end
    pcall(function()
        if guestCfg.customPunchSoundId and guestCfg.customPunchSoundId ~= 0 then
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://"..tostring(guestCfg.customPunchSoundId)
            s.Volume = 1; s.Parent = svc.SoundService; s:Play(); svc.Debris:AddItem(s,3)
        end
        g_remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")})
    end)
end

local function g_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function g_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end
local function g_getTeam(n) return getTeamFolder(n) end

local function g_isBlockReady()
    if guestCfg.noHDTCooldown then return true end
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        local num = ct.Text:match("[%d%.]+")
                        if num then
                            local v = tonumber(num)
                            return not v or v <= 0
                        end
                        return true
                    end
                end
            end
        end
    end
    return tick() - g.lastBlockTime >= guestCfg.blockCooldown
end

local function g_extractId(s)
    if not s then return nil end
    local sid = tostring(s.SoundId)
    local num = sid:match("%d+")
    if num then return num end
    local h = sid:match("[&%?]hash=([^&]+)")
    if h then return "&hash="..h end
    local p = sid:match("rbxasset://sounds/.+")
    if p then return p end
    return nil
end

local function g_getSoundPos(s)
    if not s then return nil end
    if s.Parent and s.Parent:IsA("BasePart") then return s.Parent.Position, s.Parent end
    if s.Parent and s.Parent:IsA("Attachment") and s.Parent.Parent and s.Parent.Parent:IsA("BasePart") then
        return s.Parent.Parent.Position, s.Parent.Parent
    end
    local f = s.Parent and s.Parent:FindFirstChildWhichIsA("BasePart", true)
    if f then return f.Position, f end
    return nil, nil
end

local function g_getCharFromDesc(inst)
    if not inst then return nil end
    local m = inst:FindFirstAncestorOfClass("Model")
    if m and m:FindFirstChildOfClass("Humanoid") then
        local kf = g_getTeam("Killers")
        if kf and m:IsDescendantOf(kf) then return m end
    end
    return nil
end

local function g_getQueryHitbox(m)
    if not m then return nil end
    local q = m:FindFirstChild("QueryHitbox")
    if q and q:IsA("BasePart") then return q end
    for _, c in ipairs(m:GetChildren()) do
        local n = c:FindFirstChild("QueryHitbox")
        if n and n:IsA("BasePart") then return n end
    end
    return nil
end

local function g_getKillerPos(m)
    if not m then return nil end
    local q = g_getQueryHitbox(m)
    if q then return q.Position, q end
    local h = m:FindFirstChild("HumanoidRootPart")
    if h then return h.Position, h end
    return nil, nil
end

local g_triggerSounds = {
    ["140242176732868"]=true,["136323728355613"]=true,
    ["115026634746636"]=true,["84116622032112"]=true, ["108907358619313"]=true,["127793641088496"]=true,
    ["86174610237192"]=true, ["95079963655241"]=true, ["101199185291628"]=true,["119942598489800"]=true,
    ["84307400688050"]=true, ["105200830849301"]=true,["75330693422988"]=true,
    ["82221759983649"]=true, ["81702359653578"]=true, ["85853080745515"]=true,
    ["108610718831698"]=true,["112395455254818"]=true,["109431876587852"]=true,["12222216"]=true,
    ["79980897195554"]=true, ["119583605486352"]=true,["71834552297085"]=true, ["116581754553533"]=true,
    ["86833981571073"]=true, ["110372418055226"]=true,["105840448036441"]=true,["86494585504534"]=true,
    ["80516583309685"]=true, ["131406927389838"]=true,["89004992452376"]=true, ["117231507259853"]=true,
    ["101698569375359"]=true,["101553872555606"]=true,["140412278320643"]=true,["106300477136129"]=true,
    ["117173212095661"]=true,["104910828105172"]=true,["140194172008986"]=true,["85544168523099"]=true,
    ["114506382930939"]=true,["99829427721752"]=true, ["120059928759346"]=true,["104625283622511"]=true,
    ["105316545074913"]=true,["126131675979001"]=true,["82336352305186"]=true, ["93366464803829"]=true,
    ["84069821282466"]=true, ["128856426573270"]=true,["121954639447247"]=true,["128195973631079"]=true,
    ["124903763333174"]=true,["94317217837143"]=true, ["98111231282218"]=true, ["119089145505438"]=true,
    ["136728245733659"]=true,["107444859834748"]=true,["76959687420003"]=true,
    ["72425554233832"]=true, ["96594507550917"]=true, ["139996647355899"]=true,["107345261604889"]=true,
    ["127557531826290"]=true,["108651070773439"]=true,["74842815979546"]=true, ["124397369810639"]=true,
    ["76467993976301"]=true, ["118493324723683"]=true,["78298577002481"]=true, ["116527305931161"]=true,
    ["5148302439"]=true,     ["98675142200448"]=true, ["128367348686124"]=true,["71805956520207"]=true,
    ["125213046326879"]=true,["103684883268194"]=true,["109246041199659"]=true,
    ["80540530406270"]=true, ["139523195429581"]=true,["105204810054381"]=true,["114742322778642"]=true,
    ["116468089135195"]=true,["112809109188560"]=true,["109348678063422"]=true,
    ["133709029886490"]=true,
}

local g_trackedPunchAnims = {
    ["87259391926321"]=true,["140703210927645"]=true,["136007065400978"]=true,["129843313690921"]=true,
    ["86709774283672"]=true, ["108807732150251"]=true,["138040001965654"]=true,["86096387000557"]=true,
    ["81905101227053"]=true, ["127777649118195"]=true,["99100240941590"]=true, ["92831180929659"]=true,
    ["112081768119093"]=true,["117587689359268"]=true,["91830732867282"]=true, ["91730605416216"]=true,
    ["100184164753080"]=true,
}

-- FIXED: g_attemptBlockForSound now properly checks soundBlockEnabled
local function g_attemptBlockForSound(sound, preId)
    if not guestCfg.soundBlockEnabled then return end
    
    local id = preId or g_extractId(sound)
    if not id or not g_triggerSounds[id] then return end
    if not g_isBlockReady() then return end
    if g.soundBlockedUntil[sound] and tick() < g.soundBlockedUntil[sound] then return end
    
    local root = g_getRoot()
    if not root then return end
    local _, soundPart = g_getSoundPos(sound)
    if not soundPart then return end
    local killer = g_getCharFromDesc(soundPart)
    if not killer then return end
    local hrp = killer:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local pos = g_getKillerPos(killer) or hrp.Position
    local distSq = (pos - root.Position).Magnitude ^ 2
    local effRange = guestCfg.detectionRange + 0.2 * guestCfg.detectionRange
    if distSq > effRange * effRange then return end
    
    if guestCfg.verifyFacingCheck then
        local dir = (root.Position - hrp.Position)
        if dir.Magnitude > 0.01 then
            local dot = hrp.CFrame.LookVector:Dot(dir.Unit)
            local cosA = math.cos(math.rad(guestCfg.visionAngle / 2))
            if distSq >= 25 and dot < cosA then return end
        end
    end
    
    if guestCfg.blockDelay and guestCfg.blockDelay > 0 then
        task.wait(guestCfg.blockDelay)
    end
    
    g_fireBlock()
    g.lastBlockTime = tick()
    if guestCfg.autoPunchOn then task.delay(guestCfg.autoPunchDelay, g_firePunch) end
    g.soundBlockedUntil[sound] = tick() + 0.5
end

local g_autoBlockLastCheck = {}

-- FIXED: g_hookSound now properly checks soundBlockEnabled
function g_hookSound(sound)
    if not sound or not sound:IsA("Sound") or g.soundHooks[sound] then return end
    local preId = g_extractId(sound)
    if not preId then return end
    
    local pc = sound.Played:Connect(function()
        if guestCfg.soundBlockEnabled then
            local now = tick()
            if not g_autoBlockLastCheck[preId] or (now - g_autoBlockLastCheck[preId]) > 0.05 then
                g_autoBlockLastCheck[preId] = now
                task.spawn(g_attemptBlockForSound, sound, preId)
            end
        end
    end)
    local pp = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if sound.IsPlaying and guestCfg.soundBlockEnabled then
            local now = tick()
            if not g_autoBlockLastCheck[preId] or (now - g_autoBlockLastCheck[preId]) > 0.05 then
                g_autoBlockLastCheck[preId] = now
                task.spawn(g_attemptBlockForSound, sound, preId)
            end
        end
    end)
    local dc
    dc = sound.Destroying:Connect(function()
        pcall(function() pc:Disconnect(); pp:Disconnect(); dc:Disconnect() end)
        g.soundHooks[sound] = nil
        g.soundBlockedUntil[sound] = nil
    end)
    g.soundHooks[sound] = {pc, pp, dc, id = preId}
    if sound.IsPlaying and guestCfg.soundBlockEnabled then
        local now = tick()
        if not g_autoBlockLastCheck[preId] or (now - g_autoBlockLastCheck[preId]) > 0.05 then
            g_autoBlockLastCheck[preId] = now
            task.spawn(g_attemptBlockForSound, sound, preId)
        end
    end
end

local function g_hookExistingSounds()
    local kf = g_getTeam("Killers")
    if kf then
        for _, killer in pairs(kf:GetChildren()) do
            for _, d in pairs(killer:GetDescendants()) do
                if d:IsA("Sound") then pcall(g_hookSound, d) end
            end
        end
    end
end

local function g_setupSoundHooks()
    task.spawn(function()
        local pf = svc.WS:FindFirstChild("Players")
        if not pf then pf = svc.WS:WaitForChild("Players", 30) end
        if not pf then return end
        local kf = pf:FindFirstChild("Killers")
        if not kf then kf = pf:WaitForChild("Killers", 30) end
        if not kf then return end
        g_hookExistingSounds()
        kf.DescendantAdded:Connect(function(d)
            if d:IsA("Sound") then pcall(g_hookSound, d) end
        end)
        kf.ChildAdded:Connect(function(k)
            task.wait(0.1)
            for _, d in pairs(k:GetDescendants()) do
                if d:IsA("Sound") then pcall(g_hookSound, d) end
            end
        end)
    end)
end

local function g_createVisionPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(1,1,1); p.Shape = Enum.PartType.Ball
    p.Anchored = true; p.CanCollide = false
    p.Transparency = 0.5; p.Color = Color3.fromRGB(255,0,0)
    p.Parent = svc.WS
    return p
end

local function g_createConnPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.1,0.1,1)
    p.Anchored = true; p.CanCollide = false
    p.Transparency = 0.3; p.Color = Color3.fromRGB(255,0,0)
    p.Parent = svc.WS
    return p
end

function g_updateVision()
    local show = guestCfg.showVisionCone or guestCfg.legacyShowVisionRange
    if not show then
        if g.centerPart then g_cleanupVision() end
        return
    end
    
    if g.centerPart and not g.centerPart.Parent then
        g_cleanupVision()
    end
    
    local root = g_getRoot()
    if not root then return end
    
    local origin
    if guestCfg.reverseEnabled or guestCfg.legacyFacingEnabled then
        origin = root
    else
        local kf = g_getTeam("Killers")
        if not kf then return end
        local targets = {"Slasher","c00lkidd","JohnDoe","1x1x1x1","Noli","Sixer","Nosferatu","Azure"}
        for _, name in ipairs(targets) do
            local t = kf:FindFirstChild(name)
            if t and t:FindFirstChild("HumanoidRootPart") then
                origin = t.HumanoidRootPart
                break
            end
        end
        if not origin then return end
    end
    
    local range = guestCfg.legacyShowVisionRange and guestCfg.legacyVisionRange or guestCfg.visionRange
    local angle = guestCfg.legacyShowVisionRange and guestCfg.legacyVisionAngle or guestCfg.visionAngle
    local fwd = origin.CFrame.LookVector
    local half = math.rad(angle / 2)
    local right = Vector3.new(-fwd.Z,0,fwd.X).Unit
    local lDir = (fwd * math.cos(half) + right * math.sin(half)).Unit
    local rDir = (fwd * math.cos(half) - right * math.sin(half)).Unit
    local cPos = origin.Position + fwd * range
    local lPos = origin.Position + lDir * range
    local rPos = origin.Position + rDir * range
    
    if not g.centerPart or not g.centerPart.Parent then 
        g.centerPart = g_createVisionPart() 
    end
    if not g.leftPart or not g.leftPart.Parent then 
        g.leftPart = g_createVisionPart() 
    end
    if not g.rightPart or not g.rightPart.Parent then 
        g.rightPart = g_createVisionPart() 
    end
    if not g.leftToKillerPart or not g.leftToKillerPart.Parent then 
        g.leftToKillerPart = g_createConnPart() 
    end
    if not g.rightToKillerPart or not g.rightToKillerPart.Parent then 
        g.rightToKillerPart = g_createConnPart() 
    end
    if not g.leftToCenterPart or not g.leftToCenterPart.Parent then 
        g.leftToCenterPart = g_createConnPart() 
    end
    if not g.centerToRightPart or not g.centerToRightPart.Parent then 
        g.centerToRightPart = g_createConnPart() 
    end
    
    g.centerPart.Position = cPos
    g.leftPart.Position = lPos
    g.rightPart.Position = rPos
    
    local function updateLine(part, p1, p2)
        if not part or not part.Parent then return end
        local mid = (p1+p2)/2
        local dist = (p2-p1).Magnitude
        part.Size = Vector3.new(0.1,0.1,dist)
        part.CFrame = CFrame.new(mid, p2)
    end
    updateLine(g.leftToKillerPart, origin.Position, lPos)
    updateLine(g.rightToKillerPart, origin.Position, rPos)
    updateLine(g.leftToCenterPart, lPos, cPos)
    updateLine(g.centerToRightPart, cPos, rPos)
end

local function g_showCinematicText()
    if not guestCfg.cinematicTextEnabled then return end
    if g.cinematicGui then g.cinematicGui:Destroy(); g.cinematicGui = nil end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "GuestCinematic"
    gui.Parent = lp:FindFirstChild("PlayerGui")
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 10000
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 100)
    lbl.Position = UDim2.new(0, 0, 0.4, -50)
    lbl.BackgroundTransparency = 1
    lbl.Text = guestCfg.cinematicText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.3
    lbl.TextSize = 60
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.RichText = true
    lbl.Parent = gui
    
    g.cinematicGui = gui
    task.delay(1.5, function()
        if g.cinematicGui then g.cinematicGui:Destroy(); g.cinematicGui = nil end
    end)
end

local function g_updatePing()
    if not guestCfg.pingCheckerEnabled then
        if g.pingLabel then g.pingLabel.Parent.Parent:Destroy(); g.pingLabel = nil end
        return
    end
    if not g.pingLabel then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GuestPing"; sg.Parent = lp:FindFirstChild("PlayerGui")
        sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 9998
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0,150,0,40); fr.Position = UDim2.new(0,10,1,-50)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BackgroundTransparency = 0.5
        fr.BorderSizePixel = 0; fr.Parent = sg
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,-10,1,-10); tl.Position = UDim2.new(0,5,0,5)
        tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Text = "Ping: 0ms"; tl.Font = Enum.Font.GothamBold; tl.TextSize = 18; tl.Parent = fr
        g.pingLabel = tl
    end
    local ping = svc.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    g.pingLabel.Text = "Ping: " .. math.floor(ping) .. "ms"
end

local function g_updateHDTCooldown()
    if not guestCfg.hdtCooldownChecker then
        if g.hdtCooldownGui then g.hdtCooldownGui:Destroy(); g.hdtCooldownGui = nil; g.hdtCooldownLabel = nil end
        return
    end
    if not g.hdtCooldownGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GuestHDTCD"; sg.Parent = lp:FindFirstChild("PlayerGui")
        sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 9998
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0,150,0,40); fr.Position = UDim2.new(0,10,0,100)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BackgroundTransparency = 0.5
        fr.BorderSizePixel = 0; fr.Parent = sg
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,-10,1,-10); tl.Position = UDim2.new(0,5,0,5)
        tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Text = "Block CD: ?"; tl.Font = Enum.Font.GothamBold; tl.TextSize = 18; tl.Parent = fr
        g.hdtCooldownGui = sg; g.hdtCooldownLabel = tl
    end
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        g.hdtCooldownLabel.Text = "Block CD: " .. ct.Text
                        return
                    end
                end
            end
        end
    end
    g.hdtCooldownLabel.Text = "Block CD: ?"
end

local function g_updateFPS()
    if not guestCfg.fpsCounterEnabled then
        if g.fpsGui then g.fpsGui:Destroy(); g.fpsGui = nil; g.fpsLabel = nil end
        return
    end
    if not g.fpsGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GuestFPS"; sg.Parent = lp:FindFirstChild("PlayerGui")
        sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 9999
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0,100,0,30); fr.Position = UDim2.new(0,10,0,150)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BackgroundTransparency = 0.5
        fr.BorderSizePixel = 0; fr.Parent = sg
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,-10,1,-10); tl.Position = UDim2.new(0,5,0,5)
        tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Text = "FPS: 0"; tl.Font = Enum.Font.GothamBold; tl.TextSize = 16; tl.Parent = fr
        g.fpsGui = sg; g.fpsLabel = tl
        g.lastFpsUpdate = tick(); g.frameCount = 0; g.fps = 0
    end
    g.frameCount = g.frameCount + 1
    local now = tick()
    if now - g.lastFpsUpdate >= 1 then
        g.fps = g.frameCount; g.frameCount = 0; g.lastFpsUpdate = now
        g.fpsLabel.Text = "FPS: " .. g.fps
    end
end

local function g_setupChar(char)
    g.humanoid = char:FindFirstChild("Humanoid")
    g.hrp = char:FindFirstChild("HumanoidRootPart")
    if g.aimConnection then g.aimConnection:Disconnect(); g.aimConnection = nil end
    
    if guestCfg.aimPunchActive and g.humanoid then
        local animator = g.humanoid:FindFirstChildOfClass("Animator")
        if animator then
            g.aimConnection = animator.AnimationPlayed:Connect(function(track)
                local animId = track.Animation.AnimationId:match("%d+")
                if g_trackedPunchAnims[animId] then
                    if not g.punchAiming then
                        local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
                        if h then g.originalAutoRotate = h.AutoRotate end
                    end
                    g.punchLastTriggerTime = tick()
                    g.punchAiming = true
                end
            end)
        end
    end
end

local function g_enableNoclip()
    if not lp.Character then return end
    if g.noclipConn then g.noclipConn:Disconnect(); g.noclipConn = nil end
    g.noclipConn = svc.Run.Stepped:Connect(function()
        if not guestCfg.noclipEnabled then g.noclipConn:Disconnect(); g.noclipConn = nil; return end
        if guestCfg.noclipOnlyWhenBlockReady and not g_isBlockReady() then return end
        if not lp.Character then return end
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

local function g_disableNoclip()
    if g.noclipConn then g.noclipConn:Disconnect(); g.noclipConn = nil end
    local c = lp.Character
    if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

local g_stateAccum = 0
svc.Run.RenderStepped:Connect(function(dt)
    -- Optimisation: killer tracking only needs ~30 Hz, not every rendered frame.
    g_stateAccum = g_stateAccum + dt
    if g_stateAccum < 0.033 then return end
    dt = g_stateAccum; g_stateAccum = 0
    for k in pairs(g.killerState) do if not k.Parent then g.killerState[k] = nil end end
    local kf = g_getTeam("Killers")
    if not kf then return end
    for _, killer in ipairs(kf:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp then
            local s = g.killerState[killer] or {prevPos=hrp.Position, prevLook=hrp.CFrame.LookVector, vel=Vector3.new(), angVel=0}
            local nv = (hrp.Position - s.prevPos) / math.max(dt, 1e-6)
            s.vel = s.vel:Lerp(nv, 0.22)
            local look = hrp.CFrame.LookVector
            local dot = math.clamp(s.prevLook:Dot(look), -1, 1)
            local ang = math.acos(dot)
            local sign = (s.prevLook:Cross(look).Y >= 0) and 1 or -1
            local na = (ang / math.max(dt, 1e-6)) * sign
            s.angVel = s.angVel * (1 - 0.22) + na * 0.22
            s.prevPos = hrp.Position; s.prevLook = look
            g.killerState[killer] = s
        end
    end
end)

local g_hudAccum = 0
svc.Run.RenderStepped:Connect(function(dt)
    if not guestCfg.aimPunchActive then
        if g.punchAiming then
            g.punchAiming = false
            local hum = g.humanoid
            if hum then
                -- FORCE restore AutoRotate to true
                hum.AutoRotate = true
                if g.originalWS ~= nil then hum.WalkSpeed = g.originalWS end
                if g.originalJP ~= nil then hum.JumpPower = g.originalJP end
            end
            g.originalWS = nil; g.originalJP = nil; g.originalAutoRotate = nil
        end
    elseif g.humanoid and g.hrp and g.punchAiming then
        local elapsed = tick() - g.punchLastTriggerTime

        local autoPunchFired = false
        if guestCfg.autoPunchOn then
            local lastBlock = g.lastBlockTime or 0
            if tick() - lastBlock < 0.2 then
                autoPunchFired = true
            end
        end

        if elapsed > guestCfg.aimPunchDuration or autoPunchFired then
            g.punchAiming = false
            local hum = g.humanoid
            if hum then
                -- FORCE restore AutoRotate to true
                hum.AutoRotate = true
                if g.originalWS ~= nil then hum.WalkSpeed = g.originalWS end
                if g.originalJP ~= nil then hum.JumpPower = g.originalJP end
            end
            g.originalWS = nil; g.originalJP = nil; g.originalAutoRotate = nil
        else
            if g.originalWS == nil then
                g.originalWS = g.humanoid.WalkSpeed
                g.originalJP = g.humanoid.JumpPower
            end
            g.humanoid.AutoRotate = false
            g.hrp.AssemblyAngularVelocity = Vector3.zero
            local kf = g_getTeam("Killers")
            if kf and g.hrp then
                local bestDist, targetHRP = math.huge, nil
                for _, killer in ipairs(kf:GetChildren()) do
                    local hrp = killer:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - g.hrp.Position).Magnitude
                        if d < bestDist then bestDist = d; targetHRP = hrp end
                    end
                end
                if targetHRP then
                    local pred = guestCfg.punchPrediction
                    local vel = targetHRP.AssemblyLinearVelocity
                    local predictPos = vel.Magnitude > 0.5 and (targetHRP.Position + vel * (pred / 60)) or targetHRP.Position
                    local dir = (predictPos - g.hrp.Position) * Vector3.new(1, 0, 1)
                    if dir.Magnitude > 0.01 then
                        g.hrp.CFrame = CFrame.new(g.hrp.Position, g.hrp.Position + dir.Unit)
                    end
                end
            end
        end
    end
    
    -- Optimisation: HUD overlays only need ~10 updates/sec, not one per frame.
    g_hudAccum = g_hudAccum + (dt or 0.016)
    if g_hudAccum >= 0.1 then
        g_hudAccum = 0
        pcall(g_updateVision)
        pcall(g_updatePing)
        pcall(g_updateHDTCooldown)
        pcall(g_updateFPS)
    end
end)

g_setupSoundHooks()
lp.CharacterAdded:Connect(function(c) 
    task.delay(0.5, function() 
        g_setupChar(c); 
        if guestCfg.noclipEnabled then g_enableNoclip() end
        task.wait(0.1)
        pcall(g_updateVision)
    end) 
end)
if lp.Character then 
    g_setupChar(lp.Character) 
    task.wait(0.5)
    pcall(g_updateVision)
end
if guestCfg.noclipEnabled then g_enableNoclip() end

-- ============================================================
-- AUTO BLOCK HELPER FUNCTIONS & VARIABLES
-- ============================================================
local blockLastTime = 0
local BLOCK_CD = 0.1
local cachedHRP = nil
local animBlockConn = nil
local hitboxConn = nil
local hitboxHeartbeat = nil

-- Tracked animation IDs for auto-block
local TRIGGER_ANIMS = {
    ["126830014841198"]=true,["126355327951215"]=true,["121086746534198"]=true,
    ["18885909645"]=true,    ["98456918873918"]=true, ["105458270463374"]=true,
    ["83829782357897"]=true, ["125403313786645"]=true,["118298475669935"]=true,
    ["82113744478546"]=true, ["70371667919898"]=true, ["99135633258223"]=true,
    ["97167027849946"]=true, ["109230267448394"]=true,["139835501033932"]=true,
    ["126896426760253"]=true,["109667959938617"]=true,["126681776859538"]=true,
    ["129976080405072"]=true,["121293883585738"]=true,["81639435858902"]=true,
    ["137314737492715"]=true,["92173139187970"]=true, ["122709416391"]=true,
    ["879895330952"]=true,
    ["98031287364865"]=true, ["105614318732282"]=true,
    ["127324570265084"]=true,
    ["86710781315432"]=true, ["100725497418533"]=true,["106538427162796"]=true,
    ["133398613783505"]=true,["87259391926321"]=true,
    ["88451353906104"]=true,
    ["135853087227453"]=true,
    ["123172382755876"]=true,
}

local function getKillersFolder()
    return getTeamFolder("Killers")
end

local function fireAbility(abilityType)
    local rem = hbGetRemote()
    if not rem then return end
    
    local buf
    if abilityType == "Block" then
        buf = buffer.fromstring("\x03\x05\x00\x00\x00Block")
    elseif abilityType == "Punch" then
        buf = buffer.fromstring("\x03\x05\x00\x00\x00Punch")
    elseif abilityType == "Charge" then
        buf = buffer.fromstring("\x03\x06\x00\x00\x00Charge")
    elseif abilityType == "Clone" then
        buf = buffer.fromstring("\x03\x05\x00\x00\x00Clone")
    else
        buf = buffer.fromstring("\x03\x05\x00\x00\x00Block")
    end
    
    pcall(function() rem:FireServer("UseActorAbility", {[1] = buf}) end)
    pcall(function() rem:FireServer(abilityType) end)
end

local function isFacing(myRoot, targetRoot, killerName)
    if not guestCfg.verifyFacingCheck then return true end
    if not myRoot or not targetRoot then return false end

    local dir = (myRoot.Position - targetRoot.Position)
    local distSq = dir.Magnitude ^ 2
    if distSq < 0.0001 then return true end

    local ok, res = pcall(function()
        local dot = targetRoot.CFrame.LookVector:Dot(dir.Unit)
        local cosA = math.cos(math.rad(guestCfg.visionAngle / 2))
        return distSq < 25 or dot >= cosA
    end)
    return ok and res
end

local function cacheHRP(char)
    cachedHRP = char and char:FindFirstChild("HumanoidRootPart")
end

if lp.Character then cacheHRP(lp.Character) end
lp.CharacterAdded:Connect(cacheHRP)

-- ============================================================
-- ANIMATION AUTO-BLOCK FUNCTION
-- ============================================================
function setupAnimBlock()
    if animBlockConn then
        animBlockConn:Disconnect()
        animBlockConn = nil
    end

    if not guestCfg.animEnabled then return end

    animBlockConn = svc.Run.Heartbeat:Connect(function()
        if not guestCfg.animEnabled then return end

        local myRoot = cachedHRP
        if not myRoot then return end

        local kf = getKillersFolder()
        if not kf then return end

        for _, killer in ipairs(kf:GetChildren()) do
            local khrp = killer:FindFirstChild("HumanoidRootPart")
            local khum = killer:FindFirstChildOfClass("Humanoid")
            if not khrp or not khum then continue end

            local dist = (khrp.Position - myRoot.Position).Magnitude
            if dist > guestCfg.detectionRange then continue end

            if not isFacing(myRoot, khrp, killer.Name) then continue end

            local animator = khum:FindFirstChildOfClass("Animator")
            if not animator then continue end

            local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
            if not ok or not tracks then continue end

            local triggered = false
            for _, track in ipairs(tracks) do
                if triggered then break end
                local animId
                pcall(function()
                    animId = tostring(
                        track.Animation and track.Animation.AnimationId or ""
                    ):match("%d+")
                end)
                if animId and TRIGGER_ANIMS[animId] then
                    local now = tick()
                    if now - blockLastTime >= BLOCK_CD then
                        blockLastTime = now
                        triggered = true
                        local function doBlock()
                            fireAbility(guestCfg.blockType)
                            if guestCfg.doubleBlock then
                                task.wait(0.05)
                                fireAbility("Punch")
                            end
                        end
                        if guestCfg.blockDelay > 0 then
                            task.delay(guestCfg.blockDelay, doBlock)
                        else
                            doBlock()
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- HITBOX AUTO-BLOCK FUNCTION
-- ============================================================
local function tryBlockFromHitbox(hb)
    if not guestCfg.hitboxEnabled then return end
    if not hb or not hb:IsA("BasePart") then return end

    local sz = hb.Size
    if math.abs(sz.X - guestCfg.hitboxSize.X) > guestCfg.hitboxMargin
    or math.abs(sz.Y - guestCfg.hitboxSize.Y) > guestCfg.hitboxMargin
    or math.abs(sz.Z - guestCfg.hitboxSize.Z) > guestCfg.hitboxMargin then 
        return 
    end

    local kf = getKillersFolder()
    if not kf then return end

    local killerModel = nil
    for _, km in ipairs(kf:GetChildren()) do
        if hb.Name == km.Name or hb.Name:sub(1, #km.Name) == km.Name then
            killerModel = km
            break
        end
    end

    if not killerModel then return end

    local myRoot = cachedHRP
    if not myRoot then return end
    
    local dist = (hb.Position - myRoot.Position).Magnitude
    if dist > guestCfg.detectionRange then return end

    local hrp = killerModel:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not isFacing(myRoot, hrp, killerModel.Name) then return end

    local now = tick()
    if now - blockLastTime < BLOCK_CD then return end
    blockLastTime = now

    local function doBlock()
        fireAbility(guestCfg.blockType)
        if guestCfg.doubleBlock then 
            task.wait(0.05)
            fireAbility("Punch") 
        end
    end

    if guestCfg.blockDelay > 0 then
        task.delay(guestCfg.blockDelay, doBlock)
    else
        doBlock()
    end
end

function setupHitboxBlock()
    if hitboxConn then hitboxConn:Disconnect(); hitboxConn = nil end
    if hitboxHeartbeat then hitboxHeartbeat:Disconnect(); hitboxHeartbeat = nil end
    
    if not guestCfg.hitboxEnabled then return end

    local folder = svc.WS:FindFirstChild("Hitboxes")
    if not folder then 
        folder = svc.WS:WaitForChild("Hitboxes", 10)
        if not folder then return end
    end

    for _, hb in ipairs(folder:GetChildren()) do
        task.spawn(tryBlockFromHitbox, hb)
    end

    hitboxConn = folder.ChildAdded:Connect(function(hb)
        tryBlockFromHitbox(hb)
    end)

    hitboxHeartbeat = svc.Run.Heartbeat:Connect(function()
        if not guestCfg.hitboxEnabled then return end
        if not folder or not folder.Parent then return end
        
        local myRoot = cachedHRP
        if not myRoot then return end
        
        local radius = guestCfg.detectionRange
        
        for _, hb in ipairs(folder:GetChildren()) do
            if hb:IsA("BasePart") then
                local sz = hb.Size
                if math.abs(sz.X - guestCfg.hitboxSize.X) <= guestCfg.hitboxMargin
                and math.abs(sz.Y - guestCfg.hitboxSize.Y) <= guestCfg.hitboxMargin
                and math.abs(sz.Z - guestCfg.hitboxSize.Z) <= guestCfg.hitboxMargin then
                    
                    local dist = (hb.Position - myRoot.Position).Magnitude
                    if dist <= radius then
                        local now = tick()
                        if now - blockLastTime >= BLOCK_CD then
                            blockLastTime = now
                            
                            local function doBlock()
                                fireAbility(guestCfg.blockType)
                                if guestCfg.doubleBlock then 
                                    task.wait(0.05)
                                    fireAbility("Punch") 
                                end
                            end
                            
                            if guestCfg.blockDelay > 0 then
                                task.delay(guestCfg.blockDelay, doBlock)
                            else
                                doBlock()
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- GUEST CORE UI
local secCore = tabGuestCore:Section({ Title = "Core Block", Opened = true })

secCore:Toggle({ Title="Auto Block", Type="Checkbox", Flag="guestAutoBlockOn", Default=guestCfg.autoBlockOn,
    Callback=function(v) guestCfg.autoBlockOn=v end })

secCore:Slider({ Title="Block Delay", Flag="guestBlockDelay", Step=0.05, Value={Min=0,Max=2,Default=guestCfg.blockDelay},
    Callback=function(v) guestCfg.blockDelay=v end })

secCore:Slider({ Title="Auto Block Radius", Flag="guestDetectionRange", Step=1, Value={Min=1,Max=50,Default=guestCfg.detectionRange},
    Callback=function(v) guestCfg.detectionRange=v end })

secCore:Toggle({ Title="Verify Facing Check", Type="Checkbox", Flag="guestVerifyFacingCheck", Default=guestCfg.verifyFacingCheck,
    Callback=function(v) guestCfg.verifyFacingCheck=v end })

secCore:Slider({ Title="Vision Range", Flag="guestVisionRange", Step=0.5, Value={Min=1,Max=20,Default=guestCfg.visionRange},
    Callback=function(v) guestCfg.visionRange=v end })

secCore:Slider({ Title="Vision Angle", Flag="guestVisionAngle", Step=1, Value={Min=1,Max=200,Default=guestCfg.visionAngle},
    Callback=function(v) guestCfg.visionAngle=v end })

secCore:Toggle({ Title="Show Vision Cone", Type="Checkbox", Flag="guestShowVisionCone", Default=guestCfg.showVisionCone,
    Callback=function(v) 
        guestCfg.showVisionCone=v
        if not v then 
            g_cleanupVision() 
        else
            task.wait(0.1)
            pcall(g_updateVision)
        end
    end })

secCore:Toggle({ Title="No HDT Cooldown", Type="Checkbox", Flag="guestNoHDTCooldown", Default=guestCfg.noHDTCooldown,
    Callback=function(v) guestCfg.noHDTCooldown=v end })

secCore:Toggle({ Title="Block Cooldown Checker", Type="Checkbox", Flag="guestHdtCooldownChecker", Default=guestCfg.hdtCooldownChecker,
    Callback=function(v) guestCfg.hdtCooldownChecker=v; if not v and g.hdtCooldownGui then g.hdtCooldownGui:Destroy(); g.hdtCooldownGui=nil; g.hdtCooldownLabel=nil end end })

secCore:Slider({ Title="Block Cooldown (s)", Flag="guestBlockCooldown", Step=0.05, Value={Min=0.05,Max=2,Default=guestCfg.blockCooldown},
    Callback=function(v) guestCfg.blockCooldown=v end })

secCore:Slider({ Title="Auto Punch Delay (s)", Flag="guestAutoPunchDelay", Step=0.05, Value={Min=0,Max=2,Default=guestCfg.autoPunchDelay},
    Callback=function(v) guestCfg.autoPunchDelay=v end })

secCore:Toggle({ Title="Auto Punch", Type="Checkbox", Flag="guestAutoPunchOn", Default=guestCfg.autoPunchOn,
    Callback=function(v) guestCfg.autoPunchOn=v end })

secCore:Toggle({ Title="Aim Punch", Type="Checkbox", Flag="guestAimPunchActive", Default=guestCfg.aimPunchActive,
    Callback=function(v) guestCfg.aimPunchActive=v; if v and lp.Character then g_setupChar(lp.Character) end end })

secCore:Slider({ Title="Punch Prediction", Flag="guestPunchPrediction", Step=0.1, Value={Min=0,Max=10,Default=guestCfg.punchPrediction},
    Callback=function(v) guestCfg.punchPrediction=v end })

secCore:Input({ Title="Custom Punch Sound ID", Flag="guestCustomPunchSoundId", Placeholder=tostring(guestCfg.customPunchSoundId),
    Callback=function(v) local n=tonumber(v); guestCfg.customPunchSoundId=n or 0 end })

secCore:Slider({ Title="Aim Lock Duration (s)", Flag="guestAimPunchDuration", Step=0.05, Value={Min=0.1,Max=2,Default=guestCfg.aimPunchDuration},
    Callback=function(v) guestCfg.aimPunchDuration=v end })

-- ============================================================
-- AUTO BLOCK FEATURES (Animation & Hitbox)
-- ============================================================

-- Add hitbox and animation auto-block toggles to main guestCfg
if not guestCfg.hitboxEnabled then guestCfg.hitboxEnabled = false end
if not guestCfg.animEnabled then guestCfg.animEnabled = false end
if not guestCfg.hitboxSize then guestCfg.hitboxSize = Vector3.new(4.50, 6.00, 7.50) end
if not guestCfg.hitboxMargin then guestCfg.hitboxMargin = 0.05 end
if not guestCfg.doubleBlock then guestCfg.doubleBlock = true end
if not guestCfg.blockType then guestCfg.blockType = "Block" end

-- FIXED: Sound Block toggle now properly sets the flag and hooks sounds
secCore:Toggle({ 
    Title="Sound Block", 
    Type="Checkbox", 
    Flag="guestSoundBlockEnabled", 
    Default=false,
    Callback=function(v) 
        guestCfg.soundBlockEnabled = v
        guestCfg.autoBlockOn = v
        
        if v then
            print("[Guest Block] 🔊 Sound Block ENABLED - Listening for attack sounds...")
            
            -- Force re-hook all existing sounds
            pcall(function()
                local kf = getTeamFolder("Killers")
                if kf then
                    for _, killer in pairs(kf:GetChildren()) do
                        for _, d in pairs(killer:GetDescendants()) do
                            if d:IsA("Sound") then
                                -- Clear any existing hooks for this sound
                                if g.soundHooks[d] then
                                    for _, conn in ipairs(g.soundHooks[d]) do
                                        if type(conn) ~= "string" and conn and conn.Disconnect then
                                            pcall(function() conn:Disconnect() end)
                                        end
                                    end
                                    g.soundHooks[d] = nil
                                    g.soundBlockedUntil[d] = nil
                                end
                                pcall(g_hookSound, d)
                            end
                        end
                    end
                end
                print("[Guest Block] ✅ Sound hooks refreshed")
            end)
        else
            print("[Guest Block] 🔇 Sound Block DISABLED")
            -- Clean up sound hooks
            pcall(function()
                for sound in pairs(g.soundHooks) do
                    pcall(function()
                        if g.soundHooks[sound] then
                            for _, conn in ipairs(g.soundHooks[sound]) do
                                if type(conn) ~= "string" and conn and conn.Disconnect then
                                    pcall(function() conn:Disconnect() end)
                                end
                            end
                        end
                    end)
                    g.soundHooks[sound] = nil
                    g.soundBlockedUntil[sound] = nil
                end
            end)
        end
    end 
})

-- Test button to debug sound detection
secCore:Button({ 
    Title = "🔊 Test Sound Detection", 
    Callback = function()
        print("[Sound Block] 🔍 Scanning for sounds...")
        local count = 0
        local hooked = 0
        local kf = getTeamFolder("Killers")
        if kf then
            for _, killer in pairs(kf:GetChildren()) do
                for _, d in pairs(killer:GetDescendants()) do
                    if d:IsA("Sound") then
                        count = count + 1
                        local id = g_extractId(d)
                        local isTriggered = id and g_triggerSounds[id]
                        print("  Sound:", d.Name, "ID:", id or "unknown", 
                              "Triggered:", isTriggered and "✅ YES" or "❌ NO",
                              "Hooked:", g.soundHooks[d] and "✅" or "❌")
                        if g.soundHooks[d] then hooked = hooked + 1 end
                    end
                end
            end
        end
        print("[Sound Block] Found " .. count .. " sounds, " .. hooked .. " hooked")
        ui:Notify({
            Title = "Sound Scan Complete",
            Content = "Found " .. count .. " sounds, " .. hooked .. " hooked",
            Duration = 3
        })
    end 
})

secCore:Toggle({ 
    Title = "Enable Hitbox Auto-Block", 
    Type = "Checkbox",
    Flag = "guestHitboxEnabled", 
    Default = false,
    Callback = function(on)
        guestCfg.hitboxEnabled = on
        if on then 
            setupHitboxBlock()
        else
            if hitboxConn then hitboxConn:Disconnect(); hitboxConn = nil end
            if hitboxHeartbeat then hitboxHeartbeat:Disconnect(); hitboxHeartbeat = nil end
        end
    end
})

secCore:Toggle({ 
    Title = "Enable Animation Auto-Block", 
    Type = "Checkbox",
    Flag = "guestAnimEnabled", 
    Default = false,
    Callback = function(on)
        guestCfg.animEnabled = on
        if on then 
            setupAnimBlock()
        else
            if animBlockConn then animBlockConn:Disconnect(); animBlockConn = nil end
        end
    end
})

secCore:Slider({ 
    Title = "Hitbox Size X", 
    Flag = "guestHitboxX", 
    Step = 0.25,
    Value = { Min = 1, Max = 20, Default = guestCfg.hitboxSize.X },
    Callback = function(v) 
        guestCfg.hitboxSize = Vector3.new(v, guestCfg.hitboxSize.Y, guestCfg.hitboxSize.Z) 
    end
})

secCore:Slider({ 
    Title = "Hitbox Size Y", 
    Flag = "guestHitboxY", 
    Step = 0.25,
    Value = { Min = 1, Max = 20, Default = guestCfg.hitboxSize.Y },
    Callback = function(v) 
        guestCfg.hitboxSize = Vector3.new(guestCfg.hitboxSize.X, v, guestCfg.hitboxSize.Z) 
    end
})

secCore:Slider({ 
    Title = "Hitbox Size Z", 
    Flag = "guestHitboxZ", 
    Step = 0.25,
    Value = { Min = 1, Max = 20, Default = guestCfg.hitboxSize.Z },
    Callback = function(v) 
        guestCfg.hitboxSize = Vector3.new(guestCfg.hitboxSize.X, guestCfg.hitboxSize.Y, v) 
    end
})

secCore:Dropdown({ 
    Title = "Auto Block Type", 
    Flag = "guestAutoBlockType",
    Values = {"Block", "Charge", "Clone"},
    Value = guestCfg.blockType,
    Callback = function(v) guestCfg.blockType = v end
})

secCore:Toggle({ 
    Title = "Double Block (Block + Punch)", 
    Type = "Checkbox",
    Flag = "guestAutoDouble", 
    Default = guestCfg.doubleBlock,
    Callback = function(on) guestCfg.doubleBlock = on end
})

secCore:Button({ 
    Title = "Refresh Auto-Block Connections", 
    Callback = function()
        if guestCfg.hitboxEnabled then
            setupHitboxBlock()
        end
        if guestCfg.animEnabled then
            setupAnimBlock()
        end
        ui:Notify({ Title = "Refreshed", Content = "Auto-block connections rebuilt", Duration = 2 })
    end
})

local secCine = tabGuestCore:Section({ Title = "Cinematic Text", Opened = false })
secCine:Toggle({ Title="Enable Cinematic Text", Type="Checkbox", Flag="guestCinematicTextEnabled", Default=guestCfg.cinematicTextEnabled,
    Callback=function(v) guestCfg.cinematicTextEnabled=v end })
secCine:Input({ Title="Text Content", Flag="guestCinematicText", Placeholder=guestCfg.cinematicText,
    Callback=function(v) if v ~= "" then guestCfg.cinematicText=v end end })

local secReverse = tabGuestCore:Section({ Title = "Reverse", Opened = false })
secReverse:Toggle({ Title="Enable Reverse", Type="Checkbox", Flag="guestReverseEnabled", Default=guestCfg.reverseEnabled,
    Callback=function(v) guestCfg.reverseEnabled=v end })
secReverse:Paragraph({ Title="Info", Content="When enabled, the block zone is centered on YOU instead of the killer." })

local secLegacy = tabGuestCore:Section({ Title = "Legacy Facing", Opened = false })
secLegacy:Toggle({ Title="Enable Legacy Facing", Type="Checkbox", Flag="guestLegacyFacingEnabled", Default=guestCfg.legacyFacingEnabled,
    Callback=function(v) guestCfg.legacyFacingEnabled=v end })
secLegacy:Slider({ Title="Vision Range", Flag="guestLegacyVisionRange", Step=0.5, Value={Min=1,Max=20,Default=guestCfg.legacyVisionRange},
    Callback=function(v) guestCfg.legacyVisionRange=v end })
secLegacy:Slider({ Title="Vision Angle", Flag="guestLegacyVisionAngle", Step=1, Value={Min=1,Max=200,Default=guestCfg.legacyVisionAngle},
    Callback=function(v) guestCfg.legacyVisionAngle=v end })
secLegacy:Toggle({ Title="Show Vision Range", Type="Checkbox", Flag="guestLegacyShowVisionRange", Default=guestCfg.legacyShowVisionRange,
    Callback=function(v) 
        guestCfg.legacyShowVisionRange=v
        if not v then 
            g_cleanupVision() 
        else
            task.wait(0.1)
            pcall(g_updateVision)
        end
    end })

local secMisc = tabGuestCore:Section({ Title = "Misc", Opened = false })
secMisc:Toggle({ Title="Smart Delay", Type="Checkbox", Flag="guestSmartDelayEnabled", Default=guestCfg.smartDelayEnabled,
    Callback=function(v) guestCfg.smartDelayEnabled=v end })
secMisc:Toggle({ Title="Manual Drag", Type="Checkbox", Flag="guestManualDragEnabled", Default=guestCfg.manualDragEnabled,
    Callback=function(v) guestCfg.manualDragEnabled=v end })
secMisc:Toggle({ Title="Noclip", Type="Checkbox", Flag="guestNoclipEnabled", Default=guestCfg.noclipEnabled,
    Callback=function(v) guestCfg.noclipEnabled=v; if v then g_enableNoclip() else g_disableNoclip() end end })
secMisc:Toggle({ Title="Noclip Only When Block Ready", Type="Checkbox", Flag="guestNoclipOnlyWhenBlockReady", Default=guestCfg.noclipOnlyWhenBlockReady,
    Callback=function(v) guestCfg.noclipOnlyWhenBlockReady=v end })
secMisc:Toggle({ Title="FPS Counter", Type="Checkbox", Flag="guestFpsCounterEnabled", Default=guestCfg.fpsCounterEnabled,
    Callback=function(v) guestCfg.fpsCounterEnabled=v; if not v and g.fpsGui then g.fpsGui:Destroy(); g.fpsGui=nil; g.fpsLabel=nil end end })
secMisc:Toggle({ Title="Ping Checker", Type="Checkbox", Flag="guestPingCheckerEnabled", Default=guestCfg.pingCheckerEnabled,
    Callback=function(v) guestCfg.pingCheckerEnabled=v; if not v and g.pingLabel then g.pingLabel.Parent.Parent:Destroy(); g.pingLabel=nil end end })

local secCtrl = tabGuestCore:Section({ Title = "Control", Opened = false })
secCtrl:Button({ Title="Unload Guest Block", Callback=function()
    pcall(function()
        if g.aimConnection then g.aimConnection:Disconnect() end
        if g.noclipConn then g.noclipConn:Disconnect() end
        g_cleanupVision()
        g_cleanupRoundWatcher()
        if g.cinematicGui then g.cinematicGui:Destroy() end
        if g.hdtCooldownGui then g.hdtCooldownGui:Destroy() end
        if g.fpsGui then g.fpsGui:Destroy() end
        if g.pingLabel then g.pingLabel.Parent.Parent:Destroy() end
        for sound in pairs(g.soundHooks) do
            pcall(function()
                if g.soundHooks[sound] then
                    for _, conn in ipairs(g.soundHooks[sound]) do
                        if type(conn) ~= "string" and conn and conn.Disconnect then
                            pcall(function() conn:Disconnect() end)
                        end
                    end
                end
            end)
            g.soundHooks[sound] = nil
            g.soundBlockedUntil[sound] = nil
        end
        g.killerState = {}
    end)
    ui:Notify({Title="Guest Block Unloaded", Content="All features disabled", Duration=2})
end })

end -- tabGuestCore

-- ============================================================
-- GUEST 1337 - HDT TAB
-- ============================================================

do -- tabGuestHDT
local tabGuestHDT = tabGuest1337

local guestCfg = {
    hdtEnabled = false,
    hdtSpeed = 5.6,
    hdtDuration = 1.4,
    hdtRange = 6,
    hdtDelay = 0,
    hdtShowRange = false,
    hdtFaceKiller = true,
    hdtRespectCooldown = true,
}

local hdt = {
    active = false,
    target = nil,
    targetHRP = nil,
    connection = nil,
    rangePart = nil,
    origWalkSpeed = nil,
    origJumpPower = nil,
    origPlatformStand = nil,
    origAutoRotate = nil,
    debounce = false,
    remote = nil,
    lastBlockTime = 0,
    blockCooldownDuration = 27,
    blockReadyCache = true,
    blockReadyTime = 0,
}

local function hdt_getRemote()
    if hdt.remote then return hdt.remote end
    pcall(function()
        hdt.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
    end)
    return hdt.remote
end

local function hdt_isBlockReady()
    local now = tick()
    if now - hdt.blockReadyTime < 0.2 then
        return hdt.blockReadyCache
    end
    hdt.blockReadyTime = now
    
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        local num = ct.Text:match("[%d%.]+")
                        if num then
                            local v = tonumber(num)
                            if v and v > 0 then
                                hdt.blockReadyCache = false
                                return false
                            end
                        end
                        hdt.blockReadyCache = true
                        return true
                    end
                end
            end
        end
    end
    
    local timeSinceBlock = now - hdt.lastBlockTime
    hdt.blockReadyCache = timeSinceBlock >= hdt.blockCooldownDuration
    return hdt.blockReadyCache
end

local function hdt_getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hdt_getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function hdt_getTeam(name)
    return getTeamFolder(name)
end

local function hdt_findTarget()
    local root = hdt_getRoot()
    if not root then return nil, nil end
    
    local kf = hdt_getTeam("Killers")
    if not kf then return nil, nil end
    
    local best, bestDist = nil, math.huge
    local myPos = root.Position
    local range = guestCfg.hdtRange
    
    for _, killer in ipairs(kf:GetChildren()) do
        if killer ~= lp.Character then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hum = killer:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (hrp.Position - myPos).Magnitude
                    if dist < bestDist and dist <= range then
                        bestDist = dist
                        best = killer
                    end
                end
            end
        end
    end
    
    if best then
        local hrp = best:FindFirstChild("HumanoidRootPart")
        return best, hrp
    end
    return nil, nil
end

local function hdt_execute(killer, killerHRP)
    if hdt.debounce then return end
    if not killer or not killerHRP or not killerHRP.Parent then return end
    
    if guestCfg.hdtRespectCooldown and not hdt_isBlockReady() then
        return
    end
    
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    hdt.debounce = true
    hdt.target = killer
    hdt.targetHRP = killerHRP
    
    hdt.origWalkSpeed = hum.WalkSpeed
    hdt.origJumpPower = hum.JumpPower
    hdt.origPlatformStand = hum.PlatformStand
    hdt.origAutoRotate = hum.AutoRotate
    
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = false
    hum.AutoRotate = false
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    
    local startTime = tick()
    local duration = guestCfg.hdtDuration
    local speed = guestCfg.hdtSpeed
    local faceKiller = guestCfg.hdtFaceKiller
    
    hdt.connection = svc.Run.Heartbeat:Connect(function(dt)
        local elapsed = tick() - startTime
        
        if elapsed >= duration or 
           not guestCfg.hdtEnabled or 
           not killer.Parent or
           not killerHRP.Parent or
           not root.Parent or
           not hum.Parent then
            hdt.cleanup()
            return
        end
        
        local toTarget = (killerHRP.Position - root.Position)
        local dist = toTarget.Magnitude
        
        if dist > 1 then
            local horiz = Vector3.new(toTarget.X, 0, toTarget.Z)
            if horiz.Magnitude > 0.01 then
                local dir = horiz.Unit
                bv.Velocity = Vector3.new(dir.X * speed, bv.Velocity.Y, dir.Z * speed)
            end
            
            if faceKiller then
                local faceDir = Vector3.new(
                    killerHRP.Position.X - root.Position.X,
                    0,
                    killerHRP.Position.Z - root.Position.Z
                )
                if faceDir.Magnitude > 0.1 then
                    faceDir = faceDir.Unit
                    root.CFrame = CFrame.new(root.Position, root.Position + faceDir)
                end
            end
        else
            bv.Velocity = Vector3.new(0, bv.Velocity.Y, 0)
            if faceKiller then
                local faceDir = Vector3.new(
                    killerHRP.Position.X - root.Position.X,
                    0,
                    killerHRP.Position.Z - root.Position.Z
                )
                if faceDir.Magnitude > 0.1 then
                    faceDir = faceDir.Unit
                    root.CFrame = CFrame.new(root.Position, root.Position + faceDir)
                end
            end
        end
    end)
    
    task.delay(duration + 0.5, function()
        if hdt.debounce then
            hdt.cleanup()
        end
    end)
end

function hdt.cleanup()
    if hdt.connection then
        hdt.connection:Disconnect()
        hdt.connection = nil
    end
    
    local char = lp.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if root then
            local bv = root:FindFirstChildWhichIsA("BodyVelocity")
            if bv then bv:Destroy() end
            root.AssemblyLinearVelocity = Vector3.zero
        end
        
        if hum then
            if hdt.origWalkSpeed then
                hum.WalkSpeed = hdt.origWalkSpeed
            end
            if hdt.origJumpPower then
                hum.JumpPower = hdt.origJumpPower
            end
            if hdt.origPlatformStand ~= nil then
                hum.PlatformStand = hdt.origPlatformStand
            end
            if hdt.origAutoRotate ~= nil then
                hum.AutoRotate = hdt.origAutoRotate
            end
        end
    end
    
    hdt.debounce = false
    hdt.target = nil
    hdt.targetHRP = nil
    hdt.origWalkSpeed = nil
    hdt.origJumpPower = nil
    hdt.origPlatformStand = nil
    hdt.origAutoRotate = nil
end

local function hdt_setupRemoteDetection()
    local remote = hdt_getRemote()
    if not remote then return end
    
    remote.OnClientEvent:Connect(function(action, data)
        if not guestCfg.hdtEnabled then return end
        if action ~= "UseActorAbility" then return end
        if typeof(data) ~= "table" or not data[1] then return end
        
        local name = ""
        pcall(function() name = buffer.tostring(data[1]) end)
        if not name or not name:find("Block") then return end
        
        if guestCfg.hdtRespectCooldown and not hdt_isBlockReady() then
            return
        end
        
        local killer, killerHRP = hdt_findTarget()
        if killer and killerHRP then
            if guestCfg.hdtDelay > 0 then
                task.wait(guestCfg.hdtDelay)
            end
            task.spawn(hdt_execute, killer, killerHRP)
        end
    end)
end

local hdt_rangeTimer = 0
local function hdt_updateRange()
    if not guestCfg.hdtShowRange then
        if hdt.rangePart then
            hdt.rangePart:Destroy()
            hdt.rangePart = nil
        end
        return
    end
    
    local root = hdt_getRoot()
    if not root then return end
    
    if not hdt.rangePart then
        hdt.rangePart = Instance.new("Part")
        hdt.rangePart.Name = "HDTRange"
        hdt.rangePart.Anchored = true
        hdt.rangePart.CanCollide = false
        hdt.rangePart.Shape = Enum.PartType.Ball
        hdt.rangePart.Transparency = 0.6
        hdt.rangePart.Color = Color3.fromRGB(0, 255, 100)
        hdt.rangePart.Material = Enum.Material.ForceField
        hdt.rangePart.Parent = svc.WS
    end
    
    local r = guestCfg.hdtRange
    hdt.rangePart.Size = Vector3.new(r * 2, r * 2, r * 2)
    hdt.rangePart.CFrame = CFrame.new(root.Position)
end

svc.Run.RenderStepped:Connect(function(dt)
    hdt_rangeTimer = hdt_rangeTimer + dt
    if hdt_rangeTimer >= 0.2 then
        hdt_rangeTimer = 0
        pcall(hdt_updateRange)
    end
end)

task.spawn(hdt_setupRemoteDetection)

lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if hdt.debounce then hdt.cleanup() end
end)

-- HDT UI
local secHDT = tabGuestHDT:Section({ Title = "Hitbox Dragging (HDT)", Opened = false })

secHDT:Toggle({
    Title = "Enable HDT",
    Description = "Activates when you use block (respects 27s cooldown)",
    Type = "Checkbox",
    Flag = "hdtEnabled",
    Default = guestCfg.hdtEnabled,
    Callback = function(v)
        guestCfg.hdtEnabled = v
        if not v and hdt.debounce then hdt.cleanup() end
    end
})

secHDT:Toggle({
    Title = "Respect 27s Cooldown",
    Description = "Only activate HDT when block is off cooldown",
    Type = "Checkbox",
    Flag = "hdtRespectCooldown",
    Default = guestCfg.hdtRespectCooldown,
    Callback = function(v)
        guestCfg.hdtRespectCooldown = v
    end
})

secHDT:Slider({
    Title = "Pull Speed",
    Description = "How fast you get pulled",
    Flag = "hdtSpeed",
    Step = 0.1,
    Value = { Min = 1, Max = 20, Default = guestCfg.hdtSpeed },
    Callback = function(v)
        guestCfg.hdtSpeed = v
    end
})

secHDT:Slider({
    Title = "Pull Duration (s)",
    Description = "How long the pull lasts",
    Flag = "hdtDuration",
    Step = 0.1,
    Value = { Min = 0.5, Max = 3.0, Default = guestCfg.hdtDuration },
    Callback = function(v)
        guestCfg.hdtDuration = v
    end
})

secHDT:Slider({
    Title = "Detection Range",
    Description = "How far to look for killers",
    Flag = "hdtRange",
    Step = 1,
    Value = { Min = 3, Max = 20, Default = guestCfg.hdtRange },
    Callback = function(v)
        guestCfg.hdtRange = v
    end
})

secHDT:Slider({
    Title = "Delay Before Pull (s)",
    Description = "Delay before starting the pull",
    Flag = "hdtDelay",
    Step = 0.05,
    Value = { Min = 0, Max = 0.5, Default = guestCfg.hdtDelay },
    Callback = function(v)
        guestCfg.hdtDelay = v
    end
})

secHDT:Toggle({
    Title = "Face Killer",
    Description = "Automatically face the killer while pulling",
    Type = "Checkbox",
    Flag = "hdtFaceKiller",
    Default = guestCfg.hdtFaceKiller,
    Callback = function(v)
        guestCfg.hdtFaceKiller = v
    end
})

secHDT:Toggle({
    Title = "Show Detection Range",
    Description = "Visual indicator of your HDT range",
    Type = "Checkbox",
    Flag = "hdtShowRange",
    Default = guestCfg.hdtShowRange,
    Callback = function(v)
        guestCfg.hdtShowRange = v
        if not v and hdt.rangePart then
            hdt.rangePart:Destroy()
            hdt.rangePart = nil
        end
    end
})

secHDT:Button({
    Title = "🧪 Test HDT (Force Pull)",
    Callback = function()
        if not guestCfg.hdtEnabled then
            ui:Notify({ Title = "HDT Disabled", Content = "Enable HDT first!", Duration = 2 })
            return
        end
        
        if guestCfg.hdtRespectCooldown and not hdt_isBlockReady() then
            ui:Notify({ Title = "Block on Cooldown", Content = "Wait " .. math.ceil(hdt.blockCooldownDuration - (tick() - hdt.lastBlockTime)) .. "s", Duration = 2 })
            return
        end
        
        local killer, killerHRP = hdt_findTarget()
        if killer and killerHRP then
            task.spawn(hdt_execute, killer, killerHRP)
            ui:Notify({ Title = "HDT Test", Content = "Pulling to " .. killer.Name, Duration = 2 })
        else
            ui:Notify({ Title = "No Target", Content = "No killers within " .. guestCfg.hdtRange .. " studs", Duration = 2 })
        end
    end
})

secHDT:Button({
    Title = "⏹️ Stop HDT",
    Callback = function()
        if hdt.debounce then
            hdt.cleanup()
            ui:Notify({ Title = "HDT Stopped", Content = "Pull canceled", Duration = 1 })
        end
    end
})

secHDT:Button({
    Title = "Unload HDT",
    Callback = function()
        guestCfg.hdtEnabled = false
        if hdt.debounce then hdt.cleanup() end
        if hdt.rangePart then
            hdt.rangePart:Destroy()
            hdt.rangePart = nil
        end
        ui:Notify({ Title = "HDT Unloaded", Content = "All features disabled", Duration = 2 })
    end
})

end -- tabGuestHDT

-- ============================================================
-- GUEST 1337 - BETTER DETECTION TAB
-- ============================================================

do -- tabGuestBetter
local tabGuestBetter = tabGuest1337

local guestCfg = {
    betterDetectionEnabled = false,
    betterDetectionX = 3,
    betterDetectionY = 2.5,
    betterDetectionZ = 4,
    betterDetectionMultiplier = 2.4,
    betterDetectionSegments = 14,
    betterStartDist = 2.2,
    betterStepDist = 0.05,
    betterPreDelay = 0.15,
    betterStagger = 0.03,
    betterPredForward = 1.1,
    betterPredTurn = 1.2,
    blockDelay = 0,
    autoPunchOn = false,
    autoPunchDelay = 0.3,
}

local bd = { remote = nil, killerState = {} }

local function bd_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function bd_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end
local function bd_getTeam(n) return getTeamFolder(n) end
local function bd_getQueryHitbox(m)
    if not m then return nil end
    local q = m:FindFirstChild("QueryHitbox")
    if q and q:IsA("BasePart") then return q end
    for _, c in ipairs(m:GetChildren()) do
        local n = c:FindFirstChild("QueryHitbox")
        if n and n:IsA("BasePart") then return n end
    end
    return nil
end

local function bd_fireBlock()
    if not bd.remote then
        pcall(function()
            bd.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if bd.remote then pcall(function() bd.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Block")}) end) end
end

local function bd_firePunch()
    if not bd.remote then
        pcall(function()
            bd.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if bd.remote then pcall(function() bd.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")}) end) end
end

local function bd_isPointInsidePart(part, point)
    if not part or not point then return false end
    local rel = part.CFrame:PointToObjectSpace(point)
    local half = part.Size * 0.5
    return math.abs(rel.X) <= half.X + 0.001
        and math.abs(rel.Y) <= half.Y + 0.001
        and math.abs(rel.Z) <= half.Z + 0.001
end

local function bd_spawnDetection(killer)
    if not guestCfg.betterDetectionEnabled or not killer then return end
    local hrp = killer:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local state = bd.killerState[killer]
    if not state then return end
    
    local size = Vector3.new(
        guestCfg.betterDetectionX,
        guestCfg.betterDetectionY,
        guestCfg.betterDetectionZ
    ) * guestCfg.betterDetectionMultiplier
    
    local count = math.max(1, guestCfg.betterDetectionSegments)
    local qh = bd_getQueryHitbox(killer)
    local origin = qh or hrp
    
    local vel = state.vel or Vector3.zero
    local angVel = state.angVel or 0
    local snapPos = origin.Position
    local snapCF = origin.CFrame
    
    local PRED_SECONDS_FORWARD = 0.25
    local PRED_SECONDS_LATERAL = 0.18
    local PRED_MAX_FORWARD = 6
    local PRED_MAX_LATERAL = 4
    local ANG_TURN_MULTIPLIER = 0.6
    
    local fwdSpd = vel:Dot(snapCF.LookVector)
    local latSpd = vel:Dot(snapCF.RightVector)
    local trnLat = angVel * ANG_TURN_MULTIPLIER * guestCfg.betterPredTurn
    
    local fwdPred = math.clamp(
        fwdSpd * PRED_SECONDS_FORWARD * guestCfg.betterPredForward,
        -PRED_MAX_FORWARD, PRED_MAX_FORWARD)
    local latPred = math.clamp(
        (latSpd * PRED_SECONDS_LATERAL + trnLat) * guestCfg.betterPredForward,
        -PRED_MAX_LATERAL, PRED_MAX_LATERAL)
    
    task.spawn(function()
        if guestCfg.betterPreDelay > 0 then task.wait(guestCfg.betterPreDelay) end
        
        for i = 1, count do
            if not origin or not origin.Parent then break end
            local t = (i - 1) / math.max(count - 1, 1)
            local dist = guestCfg.betterStartDist + (i - 1) * guestCfg.betterStepDist + fwdPred
            local lerpPos = snapPos:Lerp(origin.Position, t * 0.4)
            local spawnPos = lerpPos
                + snapCF.LookVector * dist
                + snapCF.RightVector * latPred
            
            local part = Instance.new("Part")
            part.Name = "BetterDetection"
            part.Size = size
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = true
            part.Transparency = 0.75
            part.Color = Color3.fromRGB(0, 150, 255)
            part.Material = Enum.Material.ForceField
            part.CFrame = CFrame.lookAt(spawnPos, lerpPos)
            part.Parent = svc.WS
            svc.Debris:AddItem(part, 0.15)
            
            local root = bd_getRoot()
            if root and bd_isPointInsidePart(part, root.Position) then
                if guestCfg.blockDelay and guestCfg.blockDelay > 0 then
                    task.wait(guestCfg.blockDelay)
                end
                bd_fireBlock()
                if guestCfg.autoPunchOn then
                    task.delay(guestCfg.autoPunchDelay, bd_firePunch)
                end
                break
            end
            
            if i < count and guestCfg.betterStagger > 0 then
                task.wait(guestCfg.betterStagger)
            end
        end
    end)
end

local bd_stateAccum = 0
svc.Run.RenderStepped:Connect(function(dt)
    -- Optimisation: same 30 Hz cap for Better Detection tracking.
    bd_stateAccum = bd_stateAccum + dt
    if bd_stateAccum < 0.033 then return end
    dt = bd_stateAccum; bd_stateAccum = 0
    for k in pairs(bd.killerState) do if not k.Parent then bd.killerState[k] = nil end end
    local kf = bd_getTeam("Killers")
    if not kf then return end
    for _, killer in ipairs(kf:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp then
            local s = bd.killerState[killer] or {prevPos=hrp.Position, prevLook=hrp.CFrame.LookVector, vel=Vector3.new(), angVel=0}
            local nv = (hrp.Position - s.prevPos) / math.max(dt, 1e-6)
            s.vel = s.vel:Lerp(nv, 0.22)
            local look = hrp.CFrame.LookVector
            local dot = math.clamp(s.prevLook:Dot(look), -1, 1)
            local ang = math.acos(dot)
            local sign = (s.prevLook:Cross(look).Y >= 0) and 1 or -1
            local na = (ang / math.max(dt, 1e-6)) * sign
            s.angVel = s.angVel * (1 - 0.22) + na * 0.22
            s.prevPos = hrp.Position; s.prevLook = look
            bd.killerState[killer] = s
        end
    end
end)

local function bd_setupHook()
    local remote = nil
    pcall(function()
        remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
    end)
    if not remote then return end
    
    remote.OnClientEvent:Connect(function(action, data)
        if not guestCfg.betterDetectionEnabled or action ~= "UseActorAbility" then return end
        if typeof(data) ~= "table" or not data[1] then return end
        
        local name = ""
        pcall(function() name = buffer.tostring(data[1]) end)
        if not name or not name:find("Punch") then return end
        
        local root = bd_getRoot()
        if not root then return end
        
        local kf = bd_getTeam("Killers")
        if not kf then return end
        
        local best, bd2 = nil, math.huge
        for _, killer in ipairs(kf:GetChildren()) do
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - root.Position).Magnitude
                if d < bd2 and d <= 20 then
                    bd2 = d; best = killer
                end
            end
        end
        
        if best then task.spawn(bd_spawnDetection, best) end
    end)
end

task.spawn(bd_setupHook)

-- Better Detection UI
local secBetter = tabGuestBetter:Section({ Title = "Better Detection", Opened = false })

secBetter:Toggle({ Title="Enable Better Detection", Type="Checkbox", Flag="betterDetectionEnabled", Default=guestCfg.betterDetectionEnabled,
    Callback=function(v) guestCfg.betterDetectionEnabled=v end })

secBetter:Input({ Title="Hitbox X", Flag="betterDetectionX", Placeholder=tostring(guestCfg.betterDetectionX),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionX=n end end })

secBetter:Input({ Title="Hitbox Y", Flag="betterDetectionY", Placeholder=tostring(guestCfg.betterDetectionY),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionY=n end end })

secBetter:Input({ Title="Hitbox Z (forward)", Flag="betterDetectionZ", Placeholder=tostring(guestCfg.betterDetectionZ),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionZ=n end end })

secBetter:Input({ Title="Multiplier", Flag="betterDetectionMultiplier", Placeholder=tostring(guestCfg.betterDetectionMultiplier),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionMultiplier=n end end })

secBetter:Input({ Title="Segments", Flag="betterDetectionSegments", Placeholder=tostring(guestCfg.betterDetectionSegments),
    Callback=function(v) local n=tonumber(v); if n then n=math.max(1,math.floor(n)); guestCfg.betterDetectionSegments=n end end })

secBetter:Input({ Title="Start Distance", Flag="betterStartDist", Placeholder=tostring(guestCfg.betterStartDist),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterStartDist=n end end })

secBetter:Input({ Title="Step Distance", Flag="betterStepDist", Placeholder=tostring(guestCfg.betterStepDist),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterStepDist=n end end })

secBetter:Input({ Title="Pre-Delay (s)", Flag="betterPreDelay", Placeholder=tostring(guestCfg.betterPreDelay),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterPreDelay=n end end })

secBetter:Input({ Title="Stagger (s)", Flag="betterStagger", Placeholder=tostring(guestCfg.betterStagger),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterStagger=n end end })

secBetter:Input({ Title="Prediction Forward", Flag="betterPredForward", Placeholder=tostring(guestCfg.betterPredForward),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterPredForward=n end end })

secBetter:Input({ Title="Prediction Turn", Flag="betterPredTurn", Placeholder=tostring(guestCfg.betterPredTurn),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterPredTurn=n end end })

secBetter:Button({ Title="Unload Better Detection", Callback=function()
    guestCfg.betterDetectionEnabled = false
    bd.killerState = {}
    ui:Notify({Title="Better Detection Unloaded", Content="Features disabled", Duration=2})
end })

end -- tabGuestBetter

-- ============================================================
-- GUEST 1337 - LINE BLOCK TAB
-- ============================================================

do -- tabGuestLine
local tabGuestLine = tabGuest1337

local guestCfg = {
    lineBlockEnabled = false,
    lineBlockLength = 15,
    lineBlockRadius = 1.5,
    lineBlockDelay = 0.05,
    lineBlockFacingDuration = 0.1,
    lineBlockMinDot = 0.5,
    blockCooldown = 0.35,
    autoPunchOn = false,
    autoPunchDelay = 0.3,
}

local line = {
    parts = {},
    facingSince = {},
    pendingKillers = {},
    animConns = {},
    soundKillers = {},
    lastBlockTime = 0,
    remote = nil,
}

local function line_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function line_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end
local function line_getTeam(n) return getTeamFolder(n) end
local function line_getQueryHitbox(m)
    if not m then return nil end
    local q = m:FindFirstChild("QueryHitbox")
    if q and q:IsA("BasePart") then return q end
    for _, c in ipairs(m:GetChildren()) do
        local n = c:FindFirstChild("QueryHitbox")
        if n and n:IsA("BasePart") then return n end
    end
    return nil
end

local g_trackedPunchAnims = {
    ["87259391926321"]=true,["140703210927645"]=true,["136007065400978"]=true,["129843313690921"]=true,
    ["86709774283672"]=true, ["108807732150251"]=true,["138040001965654"]=true,["86096387000557"]=true,
    ["81905101227053"]=true, ["127777649118195"]=true,["99100240941590"]=true, ["92831180929659"]=true,
    ["112081768119093"]=true,["117587689359268"]=true,["91830732867282"]=true, ["91730605416216"]=true,
    ["100184164753080"]=true,
}

local function line_fireBlock()
    if not line.remote then
        pcall(function()
            line.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if line.remote then pcall(function() line.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Block")}) end) end
end

local function line_firePunch()
    if not line.remote then
        pcall(function()
            line.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if line.remote then pcall(function() line.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")}) end) end
end

local function line_isBlockReady()
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        local num = ct.Text:match("[%d%.]+")
                        if num then
                            local v = tonumber(num)
                            return not v or v <= 0
                        end
                        return true
                    end
                end
            end
        end
    end
    return tick() - line.lastBlockTime >= guestCfg.blockCooldown
end

local function line_pointInCylinder(origin, look, length, radius, point)
    local offset = point - origin
    local depth = offset:Dot(look)
    if depth < 0 or depth > length then return false end
    local perp = (offset - look * depth).Magnitude
    return perp <= radius
end

local function line_cleanKiller(killer)
    if line.parts[killer] then
        pcall(function() line.parts[killer]:Destroy() end)
        line.parts[killer] = nil
    end
    line.facingSince[killer] = nil
    line.pendingKillers[killer] = nil
    line.soundKillers[killer] = nil
    if line.animConns[killer] then
        pcall(function() line.animConns[killer]:Disconnect() end)
        line.animConns[killer] = nil
    end
end

local function line_hookKillerAnim(killer)
    if line.animConns[killer] then return end
    local hum = killer:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then return end
    
    line.animConns[killer] = anim.AnimationPlayed:Connect(function(track)
        local id = track.Animation.AnimationId:match("%d+")
        if id and g_trackedPunchAnims[id] then
            line.pendingKillers[killer] = true
            task.delay(0.6, function()
                line.pendingKillers[killer] = nil
            end)
        end
    end)
end

local function line_update()
    -- Optimisation: skip all work while line block is off and nothing is left to clean.
    if not guestCfg.lineBlockEnabled and next(line.parts) == nil then return end
    local root = line_getRoot()
    local now = tick()
    
    for killer in pairs(line.parts) do
        if not killer.Parent then line_cleanKiller(killer) end
    end
    
    if not guestCfg.lineBlockEnabled then
        for killer in pairs(line.parts) do line_cleanKiller(killer) end
        for killer in pairs(line.animConns) do line_cleanKiller(killer) end
        return
    end
    
    if not root then return end
    
    local kf = line_getTeam("Killers")
    if not kf then return end
    
    for _, killer in ipairs(kf:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if not hrp then
            line_cleanKiller(killer)
        else
            line_hookKillerAnim(killer)
            
            local part = line.parts[killer]
            if not part or not part.Parent then
                part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Transparency = 0.45
                part.Parent = svc.WS
                line.parts[killer] = part
            end
            
            local qh = line_getQueryHitbox(killer)
            local origin = qh or hrp
            local look = origin.CFrame.LookVector
            local halfLen = guestCfg.lineBlockLength / 2
            local midPt = origin.Position + look * halfLen
            local diam = guestCfg.lineBlockRadius * 2
            
            part.Size = Vector3.new(diam, diam, guestCfg.lineBlockLength)
            part.CFrame = CFrame.new(midPt, midPt + look)
            
            local onLine = line_pointInCylinder(
                origin.Position, look,
                guestCfg.lineBlockLength, guestCfg.lineBlockRadius,
                root.Position
            )
            
            local toGuest = root.Position - origin.Position
            local dist = toGuest.Magnitude
            local facingDot = dist > 0.1 and look:Dot(toGuest.Unit) or 0
            
            if facingDot >= guestCfg.lineBlockMinDot then
                if not line.facingSince[killer] then
                    line.facingSince[killer] = now
                end
            else
                line.facingSince[killer] = nil
            end
            
            local facedFor = line.facingSince[killer] and (now - line.facingSince[killer]) or 0
            local soundActive = line.soundKillers[killer] and (now - line.soundKillers[killer]) <= 0.35
            
            if onLine then
                part.Color = Color3.fromRGB(255, 40, 40)
            elseif line.pendingKillers[killer] or soundActive then
                part.Color = Color3.fromRGB(255, 215, 0)
            else
                part.Color = Color3.fromRGB(235, 235, 255)
            end
            
            if onLine and (line.pendingKillers[killer] or soundActive)
                and facedFor >= guestCfg.lineBlockFacingDuration
                and (now - line.lastBlockTime) >= guestCfg.blockCooldown
                and line_isBlockReady()
            then
                line.lastBlockTime = now
                if guestCfg.lineBlockDelay and guestCfg.lineBlockDelay > 0 then
                    task.wait(guestCfg.lineBlockDelay)
                end
                line_fireBlock()
                if guestCfg.autoPunchOn then
                    task.delay(guestCfg.autoPunchDelay, line_firePunch)
                end
            end
        end
    end
end

svc.Run.RenderStepped:Connect(line_update)

-- Line Block UI
local secLine = tabGuestLine:Section({ Title = "Line Block", Opened = false })

secLine:Toggle({ Title="Enable Lineblock", Type="Checkbox", Flag="lineBlockEnabled", Default=guestCfg.lineBlockEnabled,
    Callback=function(v) guestCfg.lineBlockEnabled=v end })

secLine:Slider({ Title="Line Length", Flag="lineBlockLength", Step=1, Value={Min=2,Max=40,Default=guestCfg.lineBlockLength},
    Callback=function(v) guestCfg.lineBlockLength=v end })

secLine:Slider({ Title="Line Radius", Flag="lineBlockRadius", Step=0.5, Value={Min=0.5,Max=10,Default=guestCfg.lineBlockRadius},
    Callback=function(v) guestCfg.lineBlockRadius=v end })

secLine:Slider({ Title="Block Delay (x0.05s)", Flag="lineBlockDelay", Step=1, Value={Min=0,Max=20,Default=math.floor(guestCfg.lineBlockDelay/0.05+0.5)},
    Callback=function(v) guestCfg.lineBlockDelay=v*0.05 end })

secLine:Slider({ Title="Anti-Bait Hold (x0.01s)", Flag="lineBlockFacingDuration", Step=1, Value={Min=0,Max=50,Default=math.floor(guestCfg.lineBlockFacingDuration/0.01+0.5)},
    Callback=function(v) guestCfg.lineBlockFacingDuration=v*0.01 end })

secLine:Slider({ Title="Facing Sensitivity", Flag="lineBlockMinDot", Step=1, Value={Min=1,Max=10,Default=math.floor(guestCfg.lineBlockMinDot*10+0.5)},
    Callback=function(v) guestCfg.lineBlockMinDot=v/10 end })

secLine:Paragraph({ Title="Color Guide",
    Content="White = idle  |  Yellow = punch anim or sound detected  |  Red = you're on the line (block fires)" })

secLine:Button({ Title="Unload Line Block", Callback=function()
    guestCfg.lineBlockEnabled = false
    for killer in pairs(line.parts) do line_cleanKiller(killer) end
    for killer in pairs(line.animConns) do line_cleanKiller(killer) end
    line.killerState = {}
    ui:Notify({Title="Line Block Unloaded", Content="Features disabled", Duration=2})
end })

end -- tabGuestLine

-- ============================================================
-- GUEST 1337 - PUNCH MOBILITY TAB
-- ============================================================

do -- tabGuestMobility
local tabGuestMobility = tabGuest1337

local guestCfg = {
    punchMobilityEnabled = false,
    lungeBoostEnabled = false,
    lungeMultiplier = 1.0,
    chargeControlEnabled = false,
    chargeSpeedLimit = 12,
    chargeSpeedCapEnabled = false,
}

local mob = {
    isCharging = false,
    lungeActive = false,
    lungeThread = nil,
    pinnedConns = {},
    chargePinnedConns = {},
    chargeCapConn = nil,
    chargeWatcher = nil,
    descendantConn = nil,
    remote = nil,
}

local BASE_SPEED = 12
local BASE_PUNCH_FORCE = 40
local PUNCH_WINDUP = 0.7
local PARRY_WINDUP = 0.4

local function mob_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function mob_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end

local function mob_isParryMode() return false end

local function mob_firePunch()
    if not mob.remote then
        pcall(function()
            mob.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if mob.remote then pcall(function() mob.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")}) end) end
end

local function mob_pinValue(v)
    if not v or not v:IsA("NumberValue") then return end
    if v.Value > 1.01 then return end
    pcall(function() v.Value = 1 end)
    local conn
    conn = v:GetPropertyChangedSignal("Value"):Connect(function()
        if not guestCfg.punchMobilityEnabled then
            pcall(function() conn:Disconnect() end)
            return
        end
        if v.Value < 1 then pcall(function() v.Value = 1 end) end
    end)
    table.insert(mob.pinnedConns, conn)
end

local function mob_applyLunge()
    if not guestCfg.lungeBoostEnabled then return end
    if mob.lungeActive then return end
    local root = mob_getRoot()
    if not root then return end
    local lv = root.CFrame.LookVector
    local dir = Vector3.new(lv.X, 0, lv.Z)
    if dir.Magnitude == 0 then return end
    dir = dir.Unit
    mob.lungeActive = true
    local speed = BASE_PUNCH_FORCE * guestCfg.lungeMultiplier
    local DURATION = 0.3
    local elapsed = 0
    pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end)
    svc.Run:BindToRenderStep("GuestLungeBoost", Enum.RenderPriority.Character.Value + 20, function(dt)
        elapsed = elapsed + dt
        local rp = mob_getRoot()
        if not rp or elapsed >= DURATION then
            pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end)
            mob.lungeActive = false
            return
        end
        local t = 1 - (elapsed / DURATION)
        local currentY = rp.AssemblyLinearVelocity.Y
        rp.AssemblyLinearVelocity = dir * (speed * t) + Vector3.new(0, currentY, 0)
    end)
end

local function mob_startPunchOverride()
    mob_stopPunchOverride()
    local char = lp.Character
    if not char then return end
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("NumberValue") then mob_pinValue(desc) end
    end
    mob.descendantConn = char.DescendantAdded:Connect(function(desc)
        if not guestCfg.punchMobilityEnabled then return end
        if desc:IsA("NumberValue") then
            task.defer(function()
                if desc.Name == "PunchAbility" then
                    if guestCfg.lungeBoostEnabled then
                        if mob.lungeThread then task.cancel(mob.lungeThread) end
                        local delay = mob_isParryMode() and PARRY_WINDUP or PUNCH_WINDUP
                        mob.lungeThread = task.delay(delay, function()
                            mob.lungeThread = nil
                            mob_applyLunge()
                        end)
                    end
                end
                mob_pinValue(desc)
            end)
        end
    end)
    svc.Run:BindToRenderStep("GuestPunchMobility", Enum.RenderPriority.Character.Value + 10, function()
        if mob.lungeActive then return end
        local hum = mob_getHum()
        if not hum then return end
        if hum.WalkSpeed < BASE_SPEED then hum.WalkSpeed = BASE_SPEED end
    end)
end

function mob_stopPunchOverride()
    pcall(function() svc.Run:UnbindFromRenderStep("GuestPunchMobility") end)
    pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end)
    mob.lungeActive = false
    for _, conn in pairs(mob.pinnedConns) do pcall(function() conn:Disconnect() end) end
    mob.pinnedConns = {}
    if mob.descendantConn then
        mob.descendantConn:Disconnect()
        mob.descendantConn = nil
    end
    if mob.lungeThread then
        task.cancel(mob.lungeThread)
        mob.lungeThread = nil
    end
end

local function mob_pinChargeValue(v)
    if not v or not v:IsA("NumberValue") then return end
    if v.Value <= 1.01 then return end
    pcall(function() v.Value = 1 end)
    local conn
    conn = v:GetPropertyChangedSignal("Value"):Connect(function()
        if not mob.isCharging or not guestCfg.chargeSpeedCapEnabled then
            pcall(function() conn:Disconnect() end)
            return
        end
        if v.Value > 1 then pcall(function() v.Value = 1 end) end
    end)
    table.insert(mob.chargePinnedConns, conn)
end

local function mob_stopChargeCap()
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeCap") end)
    if mob.chargeCapConn then
        mob.chargeCapConn:Disconnect()
        mob.chargeCapConn = nil
    end
    for _, c in pairs(mob.chargePinnedConns) do pcall(function() c:Disconnect() end) end
    mob.chargePinnedConns = {}
end

local function mob_startChargeCap()
    mob_stopChargeCap()
    local char = lp.Character
    if not char then return end
    for _, desc in ipairs(char:GetDescendants()) do mob_pinChargeValue(desc) end
    mob.chargeCapConn = char.DescendantAdded:Connect(function(desc)
        if not mob.isCharging or not guestCfg.chargeSpeedCapEnabled then return end
        if desc:IsA("NumberValue") then task.defer(function() mob_pinChargeValue(desc) end) end
    end)
    svc.Run:BindToRenderStep("GuestChargeCap", Enum.RenderPriority.Character.Value + 20, function()
        if not mob.isCharging or not guestCfg.chargeSpeedCapEnabled then
            pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeCap") end)
            return
        end
        local hum = mob_getHum()
        if hum and hum.WalkSpeed > BASE_SPEED then hum.WalkSpeed = BASE_SPEED end
    end)
end

local function mob_stopLock()
    mob.isCharging = false
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeLock") end)
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeSpeedLimit") end)
    mob_stopChargeCap()
end

local function mob_startLock()
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeLock") end)
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeSpeedLimit") end)
    mob.isCharging = true
    svc.Run:BindToRenderStep("GuestChargeLock", Enum.RenderPriority.Character.Value + 2, function()
        local hum = mob_getHum()
        if not hum then return end
        local cam = svc.WS.CurrentCamera.CFrame.LookVector
        local dir = Vector3.new(cam.X, 0, cam.Z)
        if dir.Magnitude > 0 then hum:Move(dir.Unit) end
    end)
    svc.Run:BindToRenderStep("GuestChargeSpeedLimit", Enum.RenderPriority.Character.Value + 20, function()
        if not mob.isCharging then
            pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeSpeedLimit") end)
            return
        end
        local hum = mob_getHum()
        if hum and hum.WalkSpeed ~= guestCfg.chargeSpeedLimit then hum.WalkSpeed = guestCfg.chargeSpeedLimit end
    end)
    if guestCfg.chargeSpeedCapEnabled then mob_startChargeCap() end
end

local function mob_setupChargeWatcher(character)
    if mob.chargeWatcher then
        mob.chargeWatcher:Disconnect()
        mob.chargeWatcher = nil
    end
    mob_stopLock()
    mob_stopPunchOverride()
    mob.chargeWatcher = character:GetAttributeChangedSignal("GuestCharging"):Connect(function()
        if not guestCfg.chargeControlEnabled then return end
        if character:GetAttribute("GuestCharging") then
            mob_startLock()
        else
            mob_stopLock()
        end
    end)
end

lp.CharacterAdded:Connect(function(char)
    task.delay(0.5, function()
        mob_setupChargeWatcher(char)
        if guestCfg.punchMobilityEnabled then mob_startPunchOverride() end
    end)
end)

if lp.Character then
    mob_setupChargeWatcher(lp.Character)
end

if guestCfg.punchMobilityEnabled then mob_startPunchOverride() end

-- Punch Mobility UI
local secMob = tabGuestMobility:Section({ Title = "Punch Mobility", Opened = false })

secMob:Toggle({ Title="Enable Punch Mobility", Type="Checkbox", Flag="punchMobilityEnabled", Default=guestCfg.punchMobilityEnabled,
    Callback=function(v) guestCfg.punchMobilityEnabled=v; if v then mob_startPunchOverride() else mob_stopPunchOverride() end end })

secMob:Toggle({ Title="Lunge Boost", Type="Checkbox", Flag="lungeBoostEnabled", Default=guestCfg.lungeBoostEnabled,
    Callback=function(v) guestCfg.lungeBoostEnabled=v; if not v then if mob.lungeThread then task.cancel(mob.lungeThread); mob.lungeThread=nil end; pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end); mob.lungeActive=false end end })

secMob:Slider({ Title="Lunge Multiplier", Flag="lungeMultiplier", Step=0.1, Value={Min=0.5,Max=5,Default=guestCfg.lungeMultiplier},
    Callback=function(v) guestCfg.lungeMultiplier=v end })

secMob:Toggle({ Title="Charge Control", Type="Checkbox", Flag="chargeControlEnabled", Default=guestCfg.chargeControlEnabled,
    Callback=function(v) guestCfg.chargeControlEnabled=v; if not v then mob_stopLock() end end })

secMob:Slider({ Title="Charge Speed Limit", Flag="chargeSpeedLimit", Step=1, Value={Min=1,Max=50,Default=guestCfg.chargeSpeedLimit},
    Callback=function(v) guestCfg.chargeSpeedLimit=v end })

secMob:Toggle({ Title="Charge Speed Cap", Type="Checkbox", Flag="chargeSpeedCapEnabled", Default=guestCfg.chargeSpeedCapEnabled,
    Callback=function(v) guestCfg.chargeSpeedCapEnabled=v; if mob.isCharging and v then mob_startChargeCap() elseif not v then mob_stopChargeCap() end end })

secMob:Button({ Title="Unload Punch Mobility", Callback=function()
    guestCfg.punchMobilityEnabled = false
    mob_stopPunchOverride()
    mob_stopLock()
    mob_stopChargeCap()
    ui:Notify({Title="Punch Mobility Unloaded", Content="Features disabled", Duration=2})
end })

end
end -- [SorsHub: scope local]
 -- tabGuestMobility

-- ============================================================
-- VEERONICA TAB
-- ============================================================

do -- tabVeeronica
local tabVeeronica = win:Tab({ Title = "Veeronica", Icon = "zap" })

-- ============================================================
-- AUTO TRICK
-- ============================================================
local secAutoTrick = tabVeeronica:Section({ Title = "Auto Trick", Opened = true })

atEnabled = false
local atActiveMonitors = {}
local atDescendantAddedConn = nil
local atBehaviorFolder = nil

local function atGetBehaviorFolder()
    return findPath(svc.RS, "Assets", "Survivors", "Veeronica", "Behavior")
end

local function atGetSprintingButton()
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local mainUI = pg:FindFirstChild("MainUI")
    if not mainUI then return nil end
    return mainUI:FindFirstChild("SprintingButton")
end

task.spawn(function()
    local ok, f = pcall(atGetBehaviorFolder)
    if ok and f then atBehaviorFolder = f end
end)

local function atMonitorHighlight(h)
    if not h or atActiveMonitors[h] then return end
    
    local connections = {}
    local prevState = false
    
    local function cleanup()
        for _, conn in ipairs(connections) do 
            if conn and conn.Connected then conn:Disconnect() end 
        end
        atActiveMonitors[h] = nil
    end
    
    local function adorneeIsPlayer(hh)
        if not hh then return false end
        local adornee = hh.Adornee
        local char = lp.Character
        if not adornee or not char then return false end
        return adornee == char or adornee:IsDescendantOf(char)
    end
    
    local function onChanged()
        if not atEnabled then return end
        if not h or not h.Parent then cleanup(); return end
        
        local currState = adorneeIsPlayer(h)
        if prevState ~= currState then
            if currState then
                local btn = atGetSprintingButton()
                if btn then
                    for _, v in ipairs(getconnections(btn.MouseButton1Down)) do
                        pcall(function() v:Fire() end)
                    end
                end
            end
        end
        prevState = currState
    end
    
    local c = h:GetPropertyChangedSignal("Adornee"):Connect(onChanged)
    if c then table.insert(connections, c) end
    
    table.insert(connections, h.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() else onChanged() end
    end))
    
    atActiveMonitors[h] = cleanup
    task.spawn(onChanged)
end

local function atFireAbility()
    -- Auto fire Veeronica trick ability
    local rem = hbGetRemote()
    if not rem then return end
    
    local buf = buffer.fromstring("\x03\x01\x00\x00\x00")
    pcall(function() rem:FireServer("UseActorAbility", {[1] = buf}) end)
end

function atStartManager()
    if atDescendantAddedConn or not atBehaviorFolder then return end
    for _, desc in ipairs(atBehaviorFolder:GetDescendants()) do
        if desc:IsA("Highlight") then atMonitorHighlight(desc) end
    end
    atDescendantAddedConn = atBehaviorFolder.DescendantAdded:Connect(function(child)
        if child:IsA("Highlight") then atMonitorHighlight(child) end
    end)
    
    -- Auto fire trick on activation
    task.spawn(function()
        while atEnabled do
            task.wait(0.1)
            if atEnabled then
                atFireAbility()
            end
        end
    end)
end

function atStopManager()
    if atDescendantAddedConn and atDescendantAddedConn.Connected then 
        atDescendantAddedConn:Disconnect() 
    end
    atDescendantAddedConn = nil
    for _, cleanup in pairs(atActiveMonitors) do 
        if type(cleanup) == "function" then pcall(cleanup) end 
    end
    atActiveMonitors = {}
end

secAutoTrick:Toggle({
    Title = "Auto Trick",
    Type = "Checkbox",
    Flag = "veeeAutoTrick",
    Default = false,
    Callback = function(on)
        atEnabled = on
        if on then
            if not atBehaviorFolder then 
                local ok, f = pcall(atGetBehaviorFolder)
                if ok and f then atBehaviorFolder = f end
            end
            atStartManager()
        else
            atStopManager()
        end
    end
})

-- ============================================================
-- SK8 CONTROL
-- ============================================================
local secSK8 = tabVeeronica:Section({ Title = "SK8 Control", Opened = false })

local sk8_camera = svc.WS.CurrentCamera
local sk8_shiftlockEnabled = false
local sk8_shiftConn = nil
sk8_controlEnabled = false
sk8_controlActive = false
local sk8_overrideConn = nil
local sk8_savedHumState = {}
local sk8_DASH_SPEED = 60

local function sk8_setShiftlock(state)
    sk8_shiftlockEnabled = state
    if sk8_shiftConn then sk8_shiftConn:Disconnect(); sk8_shiftConn = nil end
    if sk8_shiftlockEnabled then
        svc.Input.MouseBehavior = Enum.MouseBehavior.LockCenter
        sk8_shiftConn = svc.Run.RenderStepped:Connect(function()
            local character = lp.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local camCF = sk8_camera.CFrame
                root.CFrame = CFrame.new(root.Position, Vector3.new(camCF.LookVector.X + root.Position.X, root.Position.Y, camCF.LookVector.Z + root.Position.Z))
            end
        end)
    else
        svc.Input.MouseBehavior = Enum.MouseBehavior.Default
    end
end

local sk8_chargeAnimIds = { "117058860640843" }

local function sk8_getHumanoid()
    if not lp or not lp.Character then return nil end
    return lp.Character:FindFirstChildOfClass("Humanoid")
end

local function sk8_saveHumState(hum)
    if not hum or sk8_savedHumState[hum] then return end
    local s = {}
    pcall(function()
        s.WalkSpeed = hum.WalkSpeed
        local ok, ar = pcall(function() return hum.AutoRotate end)
        if ok then s.AutoRotate = ar end
    end)
    sk8_savedHumState[hum] = s
end

local function sk8_restoreHumState(hum)
    if not hum then return end
    local s = sk8_savedHumState[hum]
    if not s then return end
    pcall(function()
        if s.WalkSpeed ~= nil then hum.WalkSpeed = s.WalkSpeed end
        if s.AutoRotate ~= nil then pcall(function() hum.AutoRotate = s.AutoRotate end) end
    end)
    sk8_savedHumState[hum] = nil
end

local function sk8_startOverride()
    if sk8_controlActive then return end
    local hum = sk8_getHumanoid()
    if not hum then return end
    sk8_controlActive = true
    sk8_saveHumState(hum)
    pcall(function() hum.WalkSpeed = sk8_DASH_SPEED; hum.AutoRotate = false end)
    sk8_setShiftlock(true)
    sk8_overrideConn = svc.Run.RenderStepped:Connect(function()
        local humanoid = sk8_getHumanoid()
        local rootPart = humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        pcall(function() humanoid.WalkSpeed = sk8_DASH_SPEED; humanoid.AutoRotate = false end)
        local direction = rootPart.CFrame.LookVector
        local horizontal = Vector3.new(direction.X, 0, direction.Z)
        if horizontal.Magnitude > 0 then humanoid:Move(horizontal.Unit) end
    end)
end

function sk8_stopOverride()
    if not sk8_controlActive then return end
    sk8_controlActive = false
    if sk8_overrideConn then pcall(function() sk8_overrideConn:Disconnect() end); sk8_overrideConn = nil end
    sk8_setShiftlock(false)
    local hum = sk8_getHumanoid()
    if hum then
        pcall(function()
            sk8_restoreHumState(hum)
            hum.AutoRotate = true
            hum:Move(Vector3.new(0,0,0))
        end)
    end
end

local function sk8_detectChargeAnim()
    local hum = sk8_getHumanoid()
    if not hum then return false end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local ok, animId = pcall(function()
            return tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
        end)
        if ok and animId and animId ~= "" then
            if table.find(sk8_chargeAnimIds, animId) then return true end
        end
    end
    return false
end

svc.Run.RenderStepped:Connect(function()
    if not sk8_controlEnabled then 
        if sk8_controlActive then sk8_stopOverride() end
        return 
    end
    local hum = sk8_getHumanoid()
    if not hum then 
        if sk8_controlActive then sk8_stopOverride() end
        return 
    end
    if sk8_detectChargeAnim() then 
        if not sk8_controlActive then sk8_startOverride() end
    else 
        if sk8_controlActive then sk8_stopOverride() end 
    end
end)

lp.CharacterAdded:Connect(function()
    if sk8_shiftConn then sk8_shiftConn:Disconnect(); sk8_shiftConn = nil end
    sk8_savedHumState = {}
end)

secSK8:Toggle({
    Title = "Enable SK8 Control",
    Type = "Checkbox",
    Flag = "sk8ControlEnabled",
    Default = false,
    Callback = function(on)
        sk8_controlEnabled = on
        if not on and sk8_controlActive then sk8_stopOverride() end
    end
})

-- ============================================================
-- FAST SPRAY
-- ============================================================
local secFastSpray = tabVeeronica:Section({ Title = "Fast Spray", Opened = false })

local SPRAY_ANIM_ID = "96618767275101"
vee_fastSpray = false
sprayPhase = 0
sprayBaseCF = nil

local function isSprayPainting()
    local char = lp.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local ok, id = pcall(function()
            return tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
        end)
        if ok and id == SPRAY_ANIM_ID then return true end
    end
    return false
end

svc.Run.RenderStepped:Connect(function(dt)
    if not vee_fastSpray then
        sprayPhase = 0
        sprayBaseCF = nil
        return
    end
    if not isSprayPainting() then
        sprayPhase = 0
        sprayBaseCF = nil
        return
    end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not sprayBaseCF or math.abs(math.sin(sprayPhase)) < 0.05 then
        sprayBaseCF = hrp.CFrame
    end

    sprayPhase = sprayPhase + dt * (math.pi * 4.5)
    local offset = math.sin(sprayPhase) * 2
    hrp.CFrame = sprayBaseCF + (sprayBaseCF.LookVector * (-offset))
end)

lp.CharacterAdded:Connect(function()
    sprayPhase = 0
    sprayBaseCF = nil
end)

secFastSpray:Toggle({
    Title = "Enable Fast Spray",
    Type = "Checkbox",
    Flag = "veeeFastSpray",
    Default = false,
    Callback = function(on)
        vee_fastSpray = on
        if not on then sprayPhase = 0; sprayBaseCF = nil end
    end
})

end -- tabVeeronica

-- ============================================================
-- TWO TIME TAB
-- ============================================================
do -- tabTwoTime
local tabTwoTime = win:Tab({ Title = "TwoTime", Icon = "sword" })
local secTwoTime = tabTwoTime:Section({ Title = "Settings", Opened = true })

-- ── Config ──────────────────────────────────────────────────
local tt_DEFAULT_PROXIMITY   = 8
local tt_DEFAULT_DURATION    = 0.45
local tt_BEHIND_DISTANCE     = 3.5
local tt_CHECK_INTERVAL      = 0.05
local tt_COOLDOWN            = 5
local tt_LERP_SPEED          = 0.55
local tt_BEHIND_CONE_DEGREES = 70
local tt_REMOTE_FIRE_DELAY   = 0.0
local tt_AIM_SNAP_DELAY      = 0.25
local tt_DEBUG_LINE          = true

-- ── Mutable state ───────────────────────────────────────────
local tt_isRunning     = true
tt_enabled       = false
tt_daggerEnabled = false
tt_rangeMode     = "Behind"
tt_backstabType  = "Lerp"
local tt_proximity     = tt_DEFAULT_PROXIMITY
local tt_lastTrigger   = 0
local tt_aimRefCount   = 0
local tt_debugBeam     = nil

-- ── Debug line ──────────────────────────────────────────────
local function tt_removeDebugLine()
    if tt_debugBeam then
        pcall(function() tt_debugBeam:Destroy() end)
        tt_debugBeam = nil
    end
end

local function tt_drawDebugLine(hrp, khrp, isValid)
    if not tt_DEBUG_LINE then tt_removeDebugLine(); return end
    pcall(function()
        local att0 = hrp:FindFirstChild("__TTAtt0") or Instance.new("Attachment", hrp)
        att0.Name = "__TTAtt0"; att0.Position = Vector3.zero

        local att1 = khrp:FindFirstChild("__TTAtt1") or Instance.new("Attachment", khrp)
        att1.Name = "__TTAtt1"; att1.Position = Vector3.zero

        if not tt_debugBeam then
            local b = Instance.new("Beam")
            b.Name = "__TTBeam"; b.Attachment0 = att0; b.Attachment1 = att1
            b.FaceCamera = true; b.Width0 = 0.08; b.Width1 = 0.08
            b.Segments = 1; b.LightEmission = 1; b.LightInfluence = 0
            b.Parent = hrp
            tt_debugBeam = b
        end
        tt_debugBeam.Attachment0 = att0
        tt_debugBeam.Attachment1 = att1
        tt_debugBeam.Color = isValid
            and ColorSequence.new(Color3.fromRGB(50, 220, 100))
            or  ColorSequence.new(Color3.fromRGB(220, 80, 60))
    end)
end

-- ── Helpers ─────────────────────────────────────────────────
local function tt_getCharacter()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function tt_getDaggerButton()
    local pg = lp:FindFirstChild("PlayerGui"); if not pg then return nil end
    local mainUI = pg:FindFirstChild("MainUI"); if not mainUI then return nil end
    local container = mainUI:FindFirstChild("AbilityContainer"); if not container then return nil end
    return container:FindFirstChild("Dagger")
end

local function tt_getDaggerCooldown()
    local btn = tt_getDaggerButton(); if not btn then return nil end
    return btn:FindFirstChild("CooldownTime")
        or btn:FindFirstChild("Cooldown")
        or btn:FindFirstChildWhichIsA("NumberValue")
        or btn:FindFirstChildWhichIsA("StringValue")
        or btn:FindFirstChild("CooldownLabel")
        or btn:FindFirstChild("Timer")
        or btn:FindFirstChild("CD")
end

local function tt_readCooldownValue(cdObj)
    if not cdObj then return nil end
    if cdObj:IsA("NumberValue") then return cdObj.Value end
    if cdObj:IsA("StringValue") then return tonumber(cdObj.Value) end
    if cdObj:IsA("TextLabel") or cdObj:IsA("TextBox") then return tonumber(cdObj.Text) end
    if type(cdObj.Value) == "number" then return cdObj.Value end
    if type(cdObj.Value) == "string" then return tonumber(cdObj.Value) end
    if cdObj.Text ~= nil then return tonumber(cdObj.Text) end
    return nil
end

local function tt_getKillersFolder()
    return getTeamFolder("Killers")
end

local function tt_isValidKillerModel(model)
    if not model then return false end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildWhichIsA("Humanoid")
    return hrp and hum and hum.Health and hum.Health > 0
end

local function tt_tryActivateButton(btn)
    if not btn then return false end
    pcall(function() if btn.Activate then btn:Activate() end end)
    local ok, conns = pcall(function()
        if type(getconnections) == "function" and btn.MouseButton1Click then
            return getconnections(btn.MouseButton1Click)
        end
        return nil
    end)
    if ok and conns then
        for _, conn in ipairs(conns) do
            pcall(function()
                if conn.Function then conn.Function()
                elseif conn.func  then conn.func()
                elseif conn.Fire  then conn.Fire() end
            end)
        end
    end
    pcall(function() if btn.Activated then btn.Activated:Fire() end end)
    return true
end

local function tt_setAutoRotate(value)
    local char = lp.Character; if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then pcall(function() hum.AutoRotate = value end) end
end

-- ── Detection ────────────────────────────────────────────────
local function tt_isPlayerBehindKiller(hrp, khrp, dist)
    if dist > tt_proximity or dist < 0.01 then return false end
    local toPlayer  = (hrp.Position - khrp.Position).Unit
    local killerBack = -khrp.CFrame.LookVector
    local dot        = toPlayer:Dot(killerBack)
    local threshold  = math.cos(math.rad(tt_BEHIND_CONE_DEGREES))
    return dot >= threshold
end

-- ── Activate (lerp / teleport / aim) ────────────────────────
local function tt_activateForKiller(killerModel, duration)
    if not killerModel or not tt_isRunning then return end
    local char     = tt_getCharacter()
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    local hrp      = char and char:FindFirstChild("HumanoidRootPart")
    local khrp     = killerModel:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp or not khrp then return end

    tt_aimRefCount += 1
    if tt_aimRefCount == 1 then pcall(function() humanoid.AutoRotate = false end) end

    local function finishAiming()
        tt_aimRefCount = math.max(0, tt_aimRefCount - 1)
        if tt_aimRefCount == 0 then tt_setAutoRotate(true) end
    end

    local function computeBehindCFrame()
        local kCF      = khrp.CFrame
        local behindPos = kCF.Position - (kCF.LookVector.Unit * tt_BEHIND_DISTANCE)
        behindPos = Vector3.new(behindPos.X, kCF.Position.Y, behindPos.Z)
        return CFrame.new(behindPos, behindPos + kCF.LookVector.Unit)
    end

    if tt_backstabType == "Lerp" then
        local t0 = os.clock(); local conn
        conn = svc.Run.Heartbeat:Connect(function()
            if not tt_isRunning or os.clock() - t0 >= duration then
                conn:Disconnect(); finishAiming(); return
            end
            if khrp and hrp then
                hrp.CFrame = hrp.CFrame:Lerp(computeBehindCFrame(), tt_LERP_SPEED)
            end
        end)

    elseif tt_backstabType == "Teleport" then
        pcall(function() hrp.CFrame = computeBehindCFrame() end)
        task.delay(duration, finishAiming)

    elseif tt_backstabType == "Aim" then
        local t0 = os.clock(); local conn
        conn = svc.Run.Heartbeat:Connect(function()
            if not tt_isRunning or os.clock() - t0 >= duration then
                conn:Disconnect(); finishAiming(); return
            end
            if khrp and hrp then
                local stabTarget = khrp.Position + khrp.CFrame.LookVector * 2
                local aimPos     = Vector3.new(stabTarget.X, hrp.Position.Y, stabTarget.Z)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(hrp.Position, aimPos), tt_LERP_SPEED * 1.8)
            end
        end)
    end
end

-- ── Main watcher ─────────────────────────────────────────────
task.spawn(function()
    while tt_isRunning do
        task.wait(tt_CHECK_INTERVAL)
        if not tt_enabled or not tt_isRunning then continue end

        local killersFolder = tt_getKillersFolder()
        if not killersFolder then continue end

        local char = tt_getCharacter()
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local triggered = false

        for _, killer in pairs(killersFolder:GetChildren()) do
            if triggered then break end
            if not tt_isValidKillerModel(killer) then continue end

            local khrp = killer:FindFirstChild("HumanoidRootPart")
            local dist = (khrp.Position - hrp.Position).Magnitude

            if dist <= tt_proximity then
                local valid = tt_isPlayerBehindKiller(hrp, khrp, dist)
                tt_drawDebugLine(hrp, khrp, valid)

                if valid
                and tt_rangeMode ~= "Around"
                and os.clock() - tt_lastTrigger >= tt_COOLDOWN then

                    local cdNum = tt_readCooldownValue(tt_getDaggerCooldown())
                    if not (cdNum and cdNum > 0.1) then
                        tt_lastTrigger = os.clock()
                        triggered = true

                        task.spawn(function()
                            tt_activateForKiller(killer, tt_DEFAULT_DURATION)

                            if tt_REMOTE_FIRE_DELAY > 0 then task.wait(tt_REMOTE_FIRE_DELAY) end
                            if tt_daggerEnabled then tt_tryActivateButton(tt_getDaggerButton()) end

                            if tt_AIM_SNAP_DELAY > 0 then
                                task.wait(tt_AIM_SNAP_DELAY)
                                if not tt_isRunning then return end
                                local khrp2 = killer:FindFirstChild("HumanoidRootPart")
                                local char2 = tt_getCharacter()
                                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                                if khrp2 and hrp2 then
                                    local behindPos = khrp2.CFrame.Position
                                        - (khrp2.CFrame.LookVector.Unit * tt_BEHIND_DISTANCE)
                                    behindPos = Vector3.new(behindPos.X, hrp2.Position.Y, behindPos.Z)
                                    hrp2.CFrame = CFrame.new(
                                        behindPos,
                                        behindPos + khrp2.CFrame.LookVector.Unit
                                    )
                                end
                            end
                        end)
                    end
                end
            elseif tt_DEBUG_LINE then
                tt_removeDebugLine()
            end

            -- "Around" mode: proximity only, no angle check
            if tt_rangeMode == "Around"
            and dist <= tt_proximity
            and os.clock() - tt_lastTrigger >= tt_COOLDOWN
            and not triggered then
                local cdNum = tt_readCooldownValue(tt_getDaggerCooldown())
                if not (cdNum and cdNum > 0.1) then
                    tt_lastTrigger = os.clock()
                    triggered = true
                    task.spawn(function()
                        tt_activateForKiller(killer, tt_DEFAULT_DURATION)
                        if tt_REMOTE_FIRE_DELAY > 0 then task.wait(tt_REMOTE_FIRE_DELAY) end
                        if tt_daggerEnabled then tt_tryActivateButton(tt_getDaggerButton()) end
                        if tt_AIM_SNAP_DELAY > 0 then
                            task.wait(tt_AIM_SNAP_DELAY)
                            if not tt_isRunning then return end
                            local khrp2 = killer:FindFirstChild("HumanoidRootPart")
                            local char2 = tt_getCharacter()
                            local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                            if khrp2 and hrp2 then
                                local tp = Vector3.new(khrp2.Position.X, hrp2.Position.Y, khrp2.Position.Z)
                                hrp2.CFrame = CFrame.new(hrp2.Position, tp)
                            end
                        end
                    end)
                end
            end
        end

        if not triggered then tt_removeDebugLine() end
    end
end)

-- ── UI Controls ──────────────────────────────────────────────
secTwoTime:Toggle({ Title = "Auto Backstab", Type = "Checkbox", Default = false,
    Callback = function(v) tt_enabled = v end })

secTwoTime:Toggle({ Title = "Auto Stab on Backstab", Type = "Checkbox", Default = false,
    Callback = function(v) tt_daggerEnabled = v end })

secTwoTime:Toggle({ Title = "Debug Line", Type = "Checkbox", Default = true,
    Callback = function(v)
        tt_DEBUG_LINE = v
        if not v then tt_removeDebugLine() end
    end })

secTwoTime:Dropdown({ Title = "Backstab Type", Values = {"Lerp", "Teleport", "Aim"}, Value = "Lerp",
    Callback = function(v) tt_backstabType = v end })

secTwoTime:Dropdown({ Title = "Range Mode", Values = {"Around", "Behind"}, Value = "Behind",
    Callback = function(v) tt_rangeMode = v end })

secTwoTime:Slider({ Title = "Detection Range", Step = 1,
    Value = { Min = 1, Max = 30, Default = tt_DEFAULT_PROXIMITY },
    Callback = function(v) tt_proximity = v end })

secTwoTime:Slider({ Title = "Behind Distance", Step = 0.5,
    Value = { Min = 0.5, Max = 10, Default = tt_BEHIND_DISTANCE },
    Callback = function(v) tt_BEHIND_DISTANCE = v end })

secTwoTime:Slider({ Title = "Behind Cone Angle (°)", Step = 5,
    Value = { Min = 10, Max = 180, Default = tt_BEHIND_CONE_DEGREES },
    Callback = function(v) tt_BEHIND_CONE_DEGREES = v end })

secTwoTime:Slider({ Title = "Remote Fire Delay (s)", Step = 0.01,
    Value = { Min = 0.00, Max = 0.50, Default = tt_REMOTE_FIRE_DELAY },
    Callback = function(v) tt_REMOTE_FIRE_DELAY = v end })

secTwoTime:Slider({ Title = "Aim Snap Delay (s)", Step = 0.01,
    Value = { Min = 0.00, Max = 0.30, Default = tt_AIM_SNAP_DELAY },
    Callback = function(v) tt_AIM_SNAP_DELAY = v end })


secTwoTime:Button({ Title = "Unload TwoTime",
    Callback = function()
        tt_isRunning = false
        tt_enabled   = false
        tt_setAutoRotate(true)
        tt_removeDebugLine()
        tabTwoTime:Destroy()
    end })

end -- tabTwoTime

-- ============================================================
-- EXTRAS TAB
-- Ported and adapted to SorsHub / WindUI.
-- Music + LMS features are intentionally NOT ported.
-- ============================================================

local tabExtras = win:Tab({ Title = "Extras", Icon = "wrench" })

local SORSHUB_DISCORD = "https://discord.gg/hgwBfRpgRP"

-- Central registry: every new feature registers the function that applies its
-- value, so a config load can restore the features without duplicating logic.
local extrasFlags = {}

local function extrasBind(flag, fn)
    extrasFlags[flag] = fn
end

function applyExtrasFromFlags(flags)
    if type(flags) ~= "table" then return end
    for flag, fn in pairs(extrasFlags) do
        local value = flags[flag]
        if value ~= nil then pcall(fn, value) end
    end
end

-- Lightweight throttled loop (much cheaper than a Heartbeat connection).
local function extrasLoop(interval, fn)
    local running = true
    task.spawn(function()
        while running do
            pcall(fn)
            task.wait(interval)
        end
    end)
    return function() running = false end
end

local function extrasSprintModule()
    local m = safeRequirePath(svc.RS, "Systems", "Character", "Game", "Sprinting")
    if type(m) == "table" then return m end
    return nil
end

local function extrasGetRoot()
    local ch = lp.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- STAMINA PLUS
-- ============================================================

local secStamPlus = tabExtras:Section({ Title = "Stamina Plus", Opened = true })

do -- [SorsHub: scope local]
local exAutoUnsprint = false
local exUnsprintAt = 10
local exUnsprintLoop = nil

local function exReadStamina()
    local pg = lp:FindFirstChild("PlayerGui")
    local temp = pg and pg:FindFirstChild("TemporaryUI")
    local info = temp and temp:FindFirstChild("PlayerInfo")
    local bars = info and info:FindFirstChild("Bars")
    local bar = bars and bars:FindFirstChild("Stamina")
    local amount = bar and bar:FindFirstChild("Amount")
    if not amount or not amount:IsA("TextLabel") then return nil end
    local cur, max = amount.Text:match("(%d+)%s*/%s*(%d+)")
    return tonumber(cur), tonumber(max)
end

local function exStopSprint()
    local m = extrasSprintModule()
    if not m then return end
    pcall(function()
        m.IsSprinting = false
        if m.__sprintedEvent then m.__sprintedEvent:Fire(false) end
    end)
    -- Preserve the recovery behavior from the feature-pack implementation.
    task.delay(2, function()
        local current = extrasSprintModule()
        if current then pcall(function() current.CanSprint = true end) end
    end)
end

local function exStartUnsprint()
    if exUnsprintLoop then exUnsprintLoop(); exUnsprintLoop = nil end
    if not exAutoUnsprint then return end
    exUnsprintLoop = extrasLoop(0.1, function()
        if not exAutoUnsprint then return end
        local cur = exReadStamina()
        if cur and cur <= exUnsprintAt then
            local m = extrasSprintModule()
            if m and m.IsSprinting then exStopSprint() end
        end
    end)
end

secStamPlus:Toggle({ Title = "Auto Unsprint", Type = "Checkbox", Flag = "exAutoUnsprint", Default = false,
    Callback = function(v) exAutoUnsprint = v; exStartUnsprint() end })
extrasBind("exAutoUnsprint", function(v) exAutoUnsprint = v; exStartUnsprint() end)

secStamPlus:Slider({ Title = "Unsprint at Stamina", Flag = "exUnsprintAt", Step = 1,
    Value = { Min = 0, Max = 50, Default = 10 },
    Callback = function(v) exUnsprintAt = v end })
extrasBind("exUnsprintAt", function(v) if type(v) == "number" then exUnsprintAt = v end end)
end -- [SorsHub: scope local]


do -- [SorsHub: scope local]
local exNoPenaltyLoop = nil
local function exApplyNoPenalty(on)
    if exNoPenaltyLoop then exNoPenaltyLoop(); exNoPenaltyLoop = nil end
    if not on then return end
    exNoPenaltyLoop = extrasLoop(0.1, function()
        local ch = lp.Character
        local m = extrasSprintModule()
        if m then pcall(function() m.timeUntilStaminaRecovers = 0 end) end
        if ch and ch:GetAttribute("StaminaPenaltyActive") then
            pcall(function() ch:SetAttribute("StaminaPenaltyActive", nil) end)
        end
    end)
end

secStamPlus:Toggle({ Title = "No Stamina Penalty", Type = "Checkbox", Flag = "exNoStamPenalty", Default = false,
    Callback = exApplyNoPenalty })
extrasBind("exNoStamPenalty", function(v) exApplyNoPenalty(v == true) end)
end -- [SorsHub: scope local]


-- Stamina Checker: estimation model based on movement.
do -- [SorsHub: scope local]
local exStaminaChecker = false
local exScConns = {}
local exScStates = {}

local function exScCleanupPlayer(player)
    if player and player.Character then
        local bb = player.Character:FindFirstChild("SorsHubStaminaBillboard")
        if bb then bb:Destroy() end
        player.Character:SetAttribute("SorsHubStaminaActive", nil)
    end
    exScStates[player] = nil
end

local function exScStop()
    for _, c in ipairs(exScConns) do pcall(function() c:Disconnect() end) end
    exScConns = {}
    for _, p in ipairs(svc.Players:GetPlayers()) do exScCleanupPlayer(p) end
    exScStates = {}
end

local function exScBuildLabel(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    local existing = char:FindFirstChild("SorsHubStaminaBillboard")
    if existing then return existing:FindFirstChild("StaminaText") end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SorsHubStaminaBillboard"
    bb.Adornee = head
    bb.Size = UDim2.new(4, 0, 1, 0)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.ResetOnSpawn = false
    bb.Parent = char
    local text = Instance.new("TextLabel")
    text.Name = "StaminaText"
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(0, 255, 100)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Text = "100"
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = bb
    return text
end

local function exScGetRates(character)
    local defaults = { MaxStamina = 100, StaminaLossPerSec = 10, StaminaGainPerSec = 20 }
    local ok, module = pcall(function()
        local assets = svc.RS:FindFirstChild("Assets")
        local teamName = character and character.Parent and character.Parent.Name
        local teamFolder = assets and assets:FindFirstChild(teamName or "")
        local characterAsset = teamFolder and teamFolder:FindFirstChild(character.Name)
        local config = characterAsset and characterAsset:FindFirstChild("Config")
        return config and require(config)
    end)
    if ok and type(module) == "table" then
        local maxStamina = tonumber(module.MaxStamina) or defaults.MaxStamina
        local staminaLoss = tonumber(module.StaminaLoss) or tonumber(module.StaminaDrain) or defaults.StaminaLossPerSec
        local staminaGain = tonumber(module.StaminaGain) or defaults.StaminaGainPerSec
        if maxStamina > 0 then defaults.MaxStamina = maxStamina end
        if staminaLoss >= 0 then defaults.StaminaLossPerSec = staminaLoss end
        if staminaGain >= 0 then defaults.StaminaGainPerSec = staminaGain end
    end
    return defaults
end

local function exScTrackPlayer(player)
    local function track(ch)
        if not exStaminaChecker or not ch or ch:GetAttribute("SorsHubStaminaActive") then return end
        ch:SetAttribute("SorsHubStaminaActive", true)
        task.spawn(function()
            local hum = ch:WaitForChild("Humanoid", 8)
            ch:WaitForChild("Head", 5)
            if not exStaminaChecker then
                pcall(function() ch:SetAttribute("SorsHubStaminaActive", nil) end)
                return
            end
            local label = exScBuildLabel(ch)
            if not hum or not label then
                pcall(function() ch:SetAttribute("SorsHubStaminaActive", nil) end)
                return
            end

            local rates = exScGetRates(ch)
            local maxStamina = rates.MaxStamina
            local state = {
                stamina = maxStamina,
                lastPos = nil,
                lastTime = os.clock(),
                speedHistory = {},
                smoothedSpeed = 0,
            }
            local recoveringAfterSprint = 0
            local exhausted = false
            local exhaustionDelay = 0

            while exStaminaChecker and ch.Parent and hum.Health > 0 and label.Parent do
                local dt = task.wait(0.01)
                if not dt or dt <= 0 then dt = 0.01 end
                dt = math.clamp(dt, 0.005, 0.05)

                local root = ch:FindFirstChild("HumanoidRootPart")
                if not root then break end
                local now = os.clock()
                local pos = Vector3.new(root.Position.X, 0, root.Position.Z)
                local elapsed = now - state.lastTime
                if state.lastPos and elapsed > 0.01 then
                    table.insert(state.speedHistory, (pos - state.lastPos).Magnitude / elapsed)
                    while #state.speedHistory > 5 do table.remove(state.speedHistory, 1) end
                    local total = 0
                    for _, speed in ipairs(state.speedHistory) do total = total + speed end
                    state.smoothedSpeed = #state.speedHistory > 0 and (total / #state.speedHistory) or 0
                    state.lastPos = pos
                    state.lastTime = now
                elseif not state.lastPos then
                    state.lastPos = pos
                    state.lastTime = now
                end

                if state.smoothedSpeed >= 20 then
                    recoveringAfterSprint = 0.1
                    state.stamina = state.stamina - rates.StaminaLossPerSec * dt
                    if state.stamina <= 0 then
                        state.stamina = 0
                        exhausted = true
                        exhaustionDelay = 2
                    end
                elseif recoveringAfterSprint > 0 then
                    recoveringAfterSprint = math.max(0, recoveringAfterSprint - dt)
                elseif exhausted then
                    exhaustionDelay = exhaustionDelay - dt
                    if exhaustionDelay <= 0 then exhausted = false end
                else
                    state.stamina = state.stamina + rates.StaminaGainPerSec * dt
                end

                state.stamina = math.clamp(state.stamina, 0, maxStamina)
                label.Text = string.format("%d", math.floor(state.stamina))
                if exhausted then
                    label.TextColor3 = math.sin(os.clock() * 10) > 0
                        and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(150, 0, 0)
                else
                    local pct = state.stamina / maxStamina
                    if pct > 0.63 then
                        label.TextColor3 = Color3.fromRGB(100, 255, 150)
                    elseif pct > 0.27 then
                        label.TextColor3 = Color3.fromRGB(255, 220, 100)
                    else
                        label.TextColor3 = Color3.fromRGB(255, 80, 80)
                    end
                end
            end

            pcall(function() ch:SetAttribute("SorsHubStaminaActive", nil) end)
            local bb = ch:FindFirstChild("SorsHubStaminaBillboard")
            if bb then pcall(function() bb:Destroy() end) end
        end)
    end
    if player.Character then track(player.Character) end
    table.insert(exScConns, player.CharacterAdded:Connect(function(ch)
        task.wait(0.4)
        if exStaminaChecker then track(ch) end
    end))
end

local function exScApply(on)
    exStaminaChecker = on == true
    exScStop()
    if not exStaminaChecker then return end
    for _, p in ipairs(svc.Players:GetPlayers()) do exScTrackPlayer(p) end
    table.insert(exScConns, svc.Players.PlayerAdded:Connect(function(p)
        if exStaminaChecker then exScTrackPlayer(p) end
    end))
end

secStamPlus:Toggle({ Title = "Stamina Checker", Type = "Checkbox", Flag = "exStamChecker", Default = false,
    Callback = exScApply })
extrasBind("exStamChecker", function(v) exScApply(v == true) end)
end -- [SorsHub: scope local]


-- Keep Directional Speed
do -- [SorsHub: scope local]
local exKeepDirStop = nil
local function exKeepDirApply(on)
    if exKeepDirStop then exKeepDirStop(); exKeepDirStop = nil end
    if not on then return end
    exKeepDirStop = extrasLoop(0.25, function()
        local sm = svc.WS:FindFirstChild("SpeedMultipliers", true)
        local dm = sm and sm:FindFirstChild("DirectionalMovement")
        if dm and dm:IsA("NumberValue") and dm.Value ~= 1 then dm.Value = 1 end
    end)
end

secStamPlus:Toggle({ Title = "Keep Directional Speed", Type = "Checkbox", Flag = "exKeepDirSpeed", Default = false,
    Callback = exKeepDirApply })
extrasBind("exKeepDirSpeed", function(v) exKeepDirApply(v == true) end)
end -- [SorsHub: scope local]


-- Remove Movement Lock
do -- [SorsHub: scope local]
local exRmlConns = {}
local function exRmlSweep()
    local sm = svc.WS:FindFirstChild("SpeedMultipliers", true)
    local dm = sm and sm:FindFirstChild("DirectionalMovement")
    if dm then pcall(function() dm:Destroy() end) end
end

local function exRmlApply(on)
    for _, c in ipairs(exRmlConns) do pcall(function() c:Disconnect() end) end
    exRmlConns = {}
    if not on then return end
    exRmlSweep()
    local sm = svc.WS:FindFirstChild("SpeedMultipliers", true)
    if sm then
        table.insert(exRmlConns, sm.ChildAdded:Connect(function(child)
            if child.Name == "DirectionalMovement" then pcall(function() child:Destroy() end) end
        end))
    end
    table.insert(exRmlConns, svc.WS.DescendantAdded:Connect(function(d)
        if d.Name == "SpeedMultipliers" then task.defer(exRmlSweep) end
    end))
end

secStamPlus:Toggle({ Title = "Remove Movement Lock", Type = "Checkbox", Flag = "exRemoveMoveLock", Default = false,
    Callback = exRmlApply })
extrasBind("exRemoveMoveLock", function(v) exRmlApply(v == true) end)
end -- [SorsHub: scope local]


-- Walkspeed Multiplier
do -- [SorsHub: scope local]
local exWalkMultOn = false
local exWalkMult = 1
local exWalkMultLoop = nil

local function exApplyWalkMult()
    local ch = lp.Character
    local m = extrasSprintModule()
    if not ch or not m then return end
    local mults = ch:FindFirstChild("SpeedMultipliers")
    local sprint = mults and mults:FindFirstChild("Sprinting")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local base = hum and (hum:GetAttribute("BaseSpeed") or hum.WalkSpeed) or 16
    if type(base) ~= "number" or base <= 0 then base = 16 end
    if sprint and sprint:IsA("NumberValue") then
        local sprintSpeed = tonumber(m.SprintSpeed) or base
        local target = m.IsSprinting and (exWalkMult * sprintSpeed / base) or 1
        if math.abs(sprint.Value - target) > 0.001 then sprint.Value = target end
    end
end

local function exStartWalkMult(on)
    exWalkMultOn = on == true
    if exWalkMultLoop then exWalkMultLoop(); exWalkMultLoop = nil end
    if not exWalkMultOn then
        pcall(exApplyWalkMult)
        return
    end
    exWalkMultLoop = extrasLoop(0.1, exApplyWalkMult)
end

secStamPlus:Toggle({ Title = "Walkspeed Multiplier", Type = "Checkbox", Flag = "exWalkMultOn", Default = false,
    Callback = exStartWalkMult })
extrasBind("exWalkMultOn", function(v) exStartWalkMult(v == true) end)

secStamPlus:Slider({ Title = "Multiplier", Flag = "exWalkMult", Step = 0.05,
    Value = { Min = 0.5, Max = 5, Default = 1 },
    Callback = function(v) exWalkMult = v end })
extrasBind("exWalkMult", function(v) if type(v) == "number" then exWalkMult = v end end)
end -- [SorsHub: scope local]


-- Survivor / Killer sprint speed
do -- [SorsHub: scope local]
local exSurvOn = false
local exSurvSpeed = 26
local exSurvLoop = nil

local function exApplySurv()
    local ch = lp.Character
    local m = extrasSprintModule()
    if not ch or not m or not ch.Parent or ch.Parent.Name ~= "Survivors" then return end
    local mults = ch:FindFirstChild("SpeedMultipliers")
    local sprint = mults and mults:FindFirstChild("Sprinting")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local base = hum and (hum:GetAttribute("BaseSpeed") or 16) or 16
    if base <= 0 then base = 16 end
    if m.IsSprinting and sprint and sprint:IsA("NumberValue") then
        local target = exSurvSpeed / base
        if math.abs(sprint.Value - target) > 0.001 then sprint.Value = target end
    end
    if tonumber(m.SprintSpeed) ~= exSurvSpeed then pcall(function() m.SprintSpeed = exSurvSpeed end) end
end

local function exStartSurv(on)
    exSurvOn = on == true
    if exSurvLoop then exSurvLoop(); exSurvLoop = nil end
    if not exSurvOn then return end
    exSurvLoop = extrasLoop(0.2, exApplySurv)
end

secStamPlus:Toggle({ Title = "Enable Survivor Sprint Speed", Type = "Checkbox", Flag = "exSurvSprintOn", Default = false,
    Callback = exStartSurv })
extrasBind("exSurvSprintOn", function(v) exStartSurv(v == true) end)

secStamPlus:Slider({ Title = "Survivor Sprint Speed", Flag = "exSurvSprint", Step = 1,
    Value = { Min = 10, Max = 60, Default = 26 },
    Callback = function(v) exSurvSpeed = v end })
extrasBind("exSurvSprint", function(v) if type(v) == "number" then exSurvSpeed = v end end)
end -- [SorsHub: scope local]


do -- [SorsHub: scope local]
local exKillerOn = false
local exKillerSpeed = 27
local exKillerLoop = nil

local function exApplyKiller()
    local kf = getTeamFolder("Killers")
    if not kf then return end
    for _, killer in ipairs(kf:GetChildren()) do
        local mults = killer:FindFirstChild("SpeedMultipliers")
        local sprint = mults and mults:FindFirstChild("Sprinting")
        local hum = killer:FindFirstChildOfClass("Humanoid")
        local base = hum and (hum:GetAttribute("BaseSpeed") or 16) or 16
        if base <= 0 then base = 16 end
        if sprint and sprint:IsA("NumberValue") and sprint.Value > 1 then
            local target = exKillerSpeed / base
            if math.abs(sprint.Value - target) > 0.001 then sprint.Value = target end
        end
    end
end

local function exStartKiller(on)
    exKillerOn = on == true
    if exKillerLoop then exKillerLoop(); exKillerLoop = nil end
    if not exKillerOn then return end
    exKillerLoop = extrasLoop(0.25, exApplyKiller)
end

secStamPlus:Toggle({ Title = "Enable Killer Sprint Speed", Type = "Checkbox", Flag = "exKillerSprintOn", Default = false,
    Callback = exStartKiller })
extrasBind("exKillerSprintOn", function(v) exStartKiller(v == true) end)

secStamPlus:Slider({ Title = "Killer Sprint Speed", Flag = "exKillerSprint", Step = 1,
    Value = { Min = 10, Max = 60, Default = 27 },
    Callback = function(v) exKillerSpeed = v end })
extrasBind("exKillerSprint", function(v) if type(v) == "number" then exKillerSpeed = v end end)
end -- [SorsHub: scope local]


-- ============================================================
-- CAMERA & VISUAL
-- ============================================================

do -- [SorsHub: scope local]
local secVisual = tabExtras:Section({ Title = "Camera & Visual", Opened = false })

local exFovValue = 70
local exFovLoop = nil

local function exApplyFov(force)
    local cam = svc.WS.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = exFovValue end) end
end

local function exStartFov(value)
    if type(value) == "number" then exFovValue = value end
    if exFovLoop then exFovLoop(); exFovLoop = nil end
    exApplyFov(true)
    if math.abs(exFovValue - 70) < 0.01 then return end
    -- Some game scripts reset FOV, so keep it pinned while it differs.
    exFovLoop = extrasLoop(1, function() exApplyFov(false) end)
end

secVisual:Slider({ Title = "Camera FOV", Flag = "exFov", Step = 1,
    Value = { Min = 50, Max = 130, Default = 70 },
    Callback = function(v) exStartFov(v) end })
extrasBind("exFov", function(v) exStartFov(tonumber(v)) end)

local exCamSaved = nil
local function exApplyInfCamera(on)
    if on then
        if not exCamSaved then
            exCamSaved = { max = lp.CameraMaxZoomDistance, min = lp.CameraMinZoomDistance }
        end
        pcall(function() lp.CameraMaxZoomDistance = 1000000000 end)
        -- Some clients clamp the property; fall back to the maximum sane zoom.
        if lp.CameraMaxZoomDistance < 1000 then
            pcall(function() lp.CameraMaxZoomDistance = 400 end)
        end
        pcall(function() lp.CameraMinZoomDistance = 0.5 end)
    elseif exCamSaved then
        pcall(function() lp.CameraMaxZoomDistance = exCamSaved.max end)
        pcall(function() lp.CameraMinZoomDistance = exCamSaved.min end)
        exCamSaved = nil
    end
end

secVisual:Toggle({ Title = "Infinite Camera Distance", Type = "Checkbox", Flag = "exInfCamera", Default = false,
    Callback = exApplyInfCamera })
extrasBind("exInfCamera", function(v) exApplyInfCamera(v == true) end)

local function exApplyCamNoclip(on)
    pcall(function()
        lp.DevCameraOcclusionMode = on and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
    end)
end

secVisual:Toggle({ Title = "Camera Noclip", Type = "Checkbox", Flag = "exCamNoclip", Default = false,
    Callback = exApplyCamNoclip })
extrasBind("exCamNoclip", function(v) exApplyCamNoclip(v == true) end)

local exLighting = nil
local exBrightLoop = nil

local function exApplyBright(on)
    local lighting = game:GetService("Lighting")
    if exBrightLoop then exBrightLoop(); exBrightLoop = nil end
    if not on then
        if exLighting then
            pcall(function()
                lighting.Brightness = exLighting.brightness
                lighting.Ambient = exLighting.ambient
                lighting.OutdoorAmbient = exLighting.outdoor
                lighting.ClockTime = exLighting.clock
                lighting.FogEnd = exLighting.fog
            end)
            exLighting = nil
        end
        return
    end
    if not exLighting then
        exLighting = {
            brightness = lighting.Brightness,
            ambient = lighting.Ambient,
            outdoor = lighting.OutdoorAmbient,
            clock = lighting.ClockTime,
            fog = lighting.FogEnd,
        }
    end
    exBrightLoop = extrasLoop(1, function()
        pcall(function()
            lighting.Brightness = 2
            lighting.Ambient = Color3.fromRGB(178, 178, 178)
            lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            lighting.ClockTime = 12
            lighting.FogEnd = 100000
        end)
    end)
end

secVisual:Toggle({ Title = "Full Bright", Type = "Checkbox", Flag = "exFullBright", Default = false,
    Callback = exApplyBright })
extrasBind("exFullBright", function(v) exApplyBright(v == true) end)

-- Anti Lag: hides effects, remembers originals, also catches new effects.
local exLagEntries = {}
local exLagOrder = {}
local exLagConn = nil

local function exLagRemember(obj, data)
    if exLagEntries[obj] then return end
    exLagEntries[obj] = data
    table.insert(exLagOrder, obj)
end

local function exLagApplyObject(obj)
    if not obj or not obj.Parent then return end
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        exLagRemember(obj, { enabled = obj.Enabled })
        pcall(function() obj.Enabled = false end)
    elseif obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        exLagRemember(obj, { parent = obj.Parent })
        pcall(function() obj.Parent = nil end)
    end
end

local exLagOn = false
local function exLagApply(on)
    on = on == true
    if on == exLagOn then return end
    exLagOn = on
    if exLagConn then exLagConn:Disconnect(); exLagConn = nil end
    if not on then
        for _, obj in ipairs(exLagOrder) do
            local data = exLagEntries[obj]
            if data then
                pcall(function()
                    if data.enabled ~= nil then
                        if obj.Parent then obj.Enabled = data.enabled end
                    elseif data.parent and data.parent.Parent then
                        obj.Parent = data.parent
                    end
                end)
            end
        end
        exLagEntries = {}
        exLagOrder = {}
        return
    end
    for _, obj in ipairs(svc.WS:GetDescendants()) do exLagApplyObject(obj) end
    exLagConn = svc.WS.DescendantAdded:Connect(function(obj) task.defer(exLagApplyObject, obj) end)
end

secVisual:Toggle({ Title = "Anti Lag", Type = "Checkbox", Flag = "exAntiLag", Default = false,
    Callback = exLagApply })
extrasBind("exAntiLag", function(v) exLagApply(v == true) end)

local exChatLoop = nil
local exChatOriginal = nil

local function exApplyChat(on)
    local config = svc.TextChat:FindFirstChild("ChatWindowConfiguration")
    if exChatLoop then exChatLoop(); exChatLoop = nil end
    if on then
        if config and exChatOriginal == nil then exChatOriginal = config.Enabled end
        exChatLoop = extrasLoop(1, function()
            local c = svc.TextChat:FindFirstChild("ChatWindowConfiguration")
            if c and not c.Enabled then pcall(function() c.Enabled = true end) end
        end)
    elseif config and exChatOriginal ~= nil then
        pcall(function() config.Enabled = exChatOriginal end)
        exChatOriginal = nil
    end
end

secVisual:Toggle({ Title = "Show Chat Window", Type = "Checkbox", Flag = "exChatWindow", Default = false,
    Callback = exApplyChat })
extrasBind("exChatWindow", function(v) exApplyChat(v == true) end)
end -- [SorsHub: scope local]


-- ============================================================
-- PROTECTION
-- ============================================================

do -- [SorsHub: scope local]
local secProtect = tabExtras:Section({ Title = "Protection", Opened = false })

local exNetModule = nil
local function exNetwork()
    if exNetModule then return exNetModule end
    local m = safeRequirePath(svc.RS, "Modules", "Network", "Network")
    if type(m) == "table" then exNetModule = m; return m end
    return nil
end

local exPullStop = nil
local function exPullGuard(on)
    if exPullStop then exPullStop(); exPullStop = nil end
    if not on then return end
    exPullStop = extrasLoop(0.1, function()
        local hrp = extrasGetRoot()
        if not hrp then return end
        for _, child in ipairs(hrp:GetChildren()) do
            if child:IsA("BodyMover") and not child:GetAttribute("Perm") then
                pcall(function() child:Destroy() end)
            end
        end
        if hrp.AssemblyLinearVelocity.Magnitude > 60 then
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
        end
    end)
end

local exBloodOrig = nil
local function exApplyBloodHook(on)
    local net = exNetwork()
    exPullGuard(on)
    if on then
        if net and not exBloodOrig and type(net.FireServerConnection) == "function" then
            exBloodOrig = net.FireServerConnection
            net.FireServerConnection = function(self, name, ...)
                if type(name) == "string" and name:match("NosHookQTE") then
                    return exBloodOrig(self, name, false)
                end
                return exBloodOrig(self, name, ...)
            end
        end
    elseif net and exBloodOrig then
        net.FireServerConnection = exBloodOrig
        exBloodOrig = nil
    end
end

secProtect:Toggle({ Title = "Anti BloodHook", Type = "Checkbox", Flag = "exAntiBloodHook", Default = false,
    Callback = exApplyBloodHook })
extrasBind("exAntiBloodHook", function(v) exApplyBloodHook(v == true) end)

local exPlantsLoop = nil
local function exApplyPlants(on)
    if exPlantsLoop then exPlantsLoop(); exPlantsLoop = nil end
    if not on then return end
    exPlantsLoop = extrasLoop(0.1, function()
        local hrp = extrasGetRoot()
        if not hrp then return end
        for _, child in ipairs(hrp:GetChildren()) do
            if child:IsA("BodyMover") and not child:GetAttribute("Perm") then
                pcall(function() child:Destroy() end)
            end
        end
        if hrp.AssemblyLinearVelocity.Magnitude > 60 then
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
        end
    end)
end

secProtect:Toggle({ Title = "Anti Plants and Nova", Type = "Checkbox", Flag = "exAntiPlantsNova", Default = false,
    Callback = exApplyPlants })
extrasBind("exAntiPlantsNova", function(v) exApplyPlants(v == true) end)

local exNoliLoop = nil
local function exApplyFakeNoli(on)
    if exNoliLoop then exNoliLoop(); exNoliLoop = nil end
    if not on then return end
    exNoliLoop = extrasLoop(0.35, function()
        local kf = getTeamFolder("Killers")
        if not kf then return end
        local found = {}
        for _, child in ipairs(kf:GetChildren()) do
            if child.Name == "Noli" and child:IsA("Model") then table.insert(found, child) end
        end
        if #found > 1 then
            for i = 2, #found do pcall(function() found[i]:Destroy() end) end
        end
        local first = found[1]
        if first then
            for _, child in ipairs(first:GetChildren()) do
                if child.Name == "Hallucination" then pcall(function() child:Destroy() end) end
            end
        end
    end)
end

secProtect:Toggle({ Title = "Anti Fake Noli", Type = "Checkbox", Flag = "exAntiFakeNoli", Default = false,
    Callback = exApplyFakeNoli })
extrasBind("exAntiFakeNoli", function(v) exApplyFakeNoli(v == true) end)

local exFakeGenLoop = nil
local function exApplyFakeGen(on)
    if exFakeGenLoop then exFakeGenLoop(); exFakeGenLoop = nil end
    if not on then return end
    exFakeGenLoop = extrasLoop(1, function()
        local ingame = getIngame()
        if not ingame then return end
        local expectedName = "FakeGenerator"
        pcall(function()
            local configuredName = getgenv().FakeGeneratorName
            if type(configuredName) == "string" and configuredName ~= "" then
                expectedName = configuredName
            end
        end)
        for _, child in ipairs(ingame:GetChildren()) do
            if child.Name == expectedName then pcall(function() child:Destroy() end) end
        end
    end)
end

secProtect:Toggle({ Title = "Anti Fake Generator", Type = "Checkbox", Flag = "exAntiFakeGen", Default = false,
    Callback = exApplyFakeGen })
extrasBind("exAntiFakeGen", function(v) exApplyFakeGen(v == true) end)

local exSlowFallConn = nil
local function exApplySlowFall(on)
    if exSlowFallConn then exSlowFallConn:Disconnect(); exSlowFallConn = nil end
    local ch = lp.Character
    if ch then pcall(function() ch:SetAttribute("NoFallSlow", on == true or nil) end) end
    if on then
        exSlowFallConn = lp.CharacterAdded:Connect(function(newChar)
            task.wait(0.2)
            pcall(function() newChar:SetAttribute("NoFallSlow", true) end)
        end)
    end
end

secProtect:Toggle({ Title = "Anti Slow Fall", Type = "Checkbox", Flag = "exAntiSlowFall", Default = false,
    Callback = exApplySlowFall })
extrasBind("exAntiSlowFall", function(v) exApplySlowFall(v == true) end)

-- Anti Stun (removes the Stunned schematic)
local exStunLoop = nil
local function exApplyStun(on)
    if exStunLoop then exStunLoop(); exStunLoop = nil end
    if not on then return end
    exStunLoop = extrasLoop(0.5, function()
        local modules = svc.RS:FindFirstChild("Modules")
        local schematics = modules and modules:FindFirstChild("Schematics")
        local stun = schematics and schematics:FindFirstChild("Stunned", true)
        if stun then pcall(function() stun:Destroy() end) end
    end)
end

secProtect:Toggle({ Title = "Anti Stun", Type = "Checkbox", Flag = "exAntiStun", Default = false,
    Callback = exApplyStun })
extrasBind("exAntiStun", function(v) exApplyStun(v == true) end)

local exStatusOrig = nil
local function exApplySentrySlow(on)
    local statuses = safeRequirePath(svc.RS, "Modules", "Gameplay", "Statuses")
    if type(statuses) ~= "table" then return end
    if on then
        if not exStatusOrig and type(statuses.ApplyStatus) == "function" then
            exStatusOrig = statuses.ApplyStatus
            statuses.ApplyStatus = function(self, character, status, ...)
                if status == "Slowness" and character == lp.Character then
                    local root = character and character.PrimaryPart
                    local ingame = getIngame()
                    if root and ingame then
                        for _, obj in ipairs(ingame:GetChildren()) do
                            if obj.Name == "BuildermanSentry" and not obj:GetAttribute("Destroyed") then
                                local sentryRoot = obj.PrimaryPart
                                if sentryRoot then
                                    local radius = obj:GetAttribute("EffectRadiusSize") or 30
                                    if (root.Position - sentryRoot.Position).Magnitude <= radius then
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
                return exStatusOrig(self, character, status, ...)
            end
        end
    elseif exStatusOrig then
        statuses.ApplyStatus = exStatusOrig
        exStatusOrig = nil
    end
end

secProtect:Toggle({ Title = "Anti Sentry Slow", Type = "Checkbox", Flag = "exAntiSentrySlow", Default = false,
    Callback = exApplySentrySlow })
extrasBind("exAntiSentrySlow", function(v) exApplySentrySlow(v == true) end)

-- See Hidden Stats
local exHiddenCache = {}
local exHiddenLoop = nil
local function exApplyHidden(on)
    if exHiddenLoop then exHiddenLoop(); exHiddenLoop = nil end
    if on then
        exHiddenLoop = extrasLoop(2, function()
            for _, player in ipairs(svc.Players:GetPlayers()) do
                local data = player:FindFirstChild("PlayerData")
                local settings = data and data:FindFirstChild("Settings")
                local privacy = settings and settings:FindFirstChild("Privacy")
                if privacy and not exHiddenCache[player] then
                    local saved = {}
                    for _, name in ipairs({ "HideSurvivorWins", "HidePlaytime", "HideKillerWins" }) do
                        local flag = privacy:FindFirstChild(name)
                        if flag and flag:IsA("BoolValue") then
                            saved[name] = flag.Value
                            pcall(function() flag.Value = false end)
                        end
                    end
                    exHiddenCache[player] = { privacy = privacy, saved = saved }
                end
            end
        end)
        return
    end
    for player, entry in pairs(exHiddenCache) do
        if entry.privacy and entry.privacy.Parent then
            for name, value in pairs(entry.saved) do
                local flag = entry.privacy:FindFirstChild(name)
                if flag and flag:IsA("BoolValue") then pcall(function() flag.Value = value end) end
            end
        end
        exHiddenCache[player] = nil
    end
end

secProtect:Toggle({ Title = "See Hidden Stats", Type = "Checkbox", Flag = "exHiddenStats", Default = false,
    Callback = exApplyHidden })
extrasBind("exHiddenStats", function(v) exApplyHidden(v == true) end)

-- Streamer Mode (hide your name in GUIs)
local exStreamSaved = {}
local exStreamLoop = nil
local exStreamNames = { Username = true, PlayerName = true, PlayerUsername = true }

local function exApplyStreamer(on)
    if exStreamLoop then exStreamLoop(); exStreamLoop = nil end
    if on then
        exStreamLoop = extrasLoop(0.5, function()
            local pg = lp:FindFirstChild("PlayerGui")
            if not pg then return end
            for _, obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("TextLabel") and exStreamNames[obj.Name] then
                    if exStreamSaved[obj] == nil then exStreamSaved[obj] = obj.Text end
                    if obj.Text ~= "SorsHub" then obj.Text = "SorsHub" end
                end
            end
        end)
        return
    end
    for obj, text in pairs(exStreamSaved) do
        if obj and obj.Parent then pcall(function() obj.Text = text end) end
    end
    exStreamSaved = {}
end

secProtect:Toggle({ Title = "Streamer Mode (hide username)", Type = "Checkbox", Flag = "exStreamerMode", Default = false,
    Callback = exApplyStreamer })
extrasBind("exStreamerMode", function(v) exApplyStreamer(v == true) end)
end -- [SorsHub: scope local]


-- ============================================================
-- MOVEMENT
-- ============================================================

do -- [SorsHub: scope local]
local secMove = tabExtras:Section({ Title = "Movement", Opened = false })

local exNoclipLoop = nil
local exNoclipSaved = {}
local function exApplyNoclipWalls(on)
    if exNoclipLoop then exNoclipLoop(); exNoclipLoop = nil end
    if on then
        exNoclipLoop = extrasLoop(0.2, function()
            local ch = lp.Character
            if not ch then return end
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    exNoclipSaved[part] = true
                    part.CanCollide = false
                end
            end
        end)
        return
    end
    for part in pairs(exNoclipSaved) do
        if part and part.Parent then pcall(function() part.CanCollide = true end) end
    end
    exNoclipSaved = {}
end

secMove:Toggle({ Title = "Noclip Walls", Type = "Checkbox", Flag = "exNoclipWalls", Default = false,
    Callback = exApplyNoclipWalls })
extrasBind("exNoclipWalls", function(v) exApplyNoclipWalls(v == true) end)

local exJumpLoop = nil
local function exApplyAllowJump(on)
    if exJumpLoop then exJumpLoop(); exJumpLoop = nil end
    if not on then return end
    exJumpLoop = extrasLoop(0.2, function()
        local ch = lp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = 50
        end
    end)
end

secMove:Toggle({ Title = "Allow Jump", Type = "Checkbox", Flag = "exAllowJump", Default = false,
    Callback = exApplyAllowJump })
extrasBind("exAllowJump", function(v) exApplyAllowJump(v == true) end)

local exDoorsLoop = nil
local exDoorsSaved = {}
local function exApplyDoors(on)
    if exDoorsLoop then exDoorsLoop(); exDoorsLoop = nil end
    if on then
        exDoorsLoop = extrasLoop(1, function()
            local content = getMapContent()
            local boundaries = content and content:FindFirstChild("MapBoundaries")
            local doors = boundaries and boundaries:FindFirstChild("KillerDoors")
            if not doors then return end
            for _, part in ipairs(doors:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    exDoorsSaved[part] = true
                    part.CanCollide = false
                end
            end
        end)
        return
    end
    for part in pairs(exDoorsSaved) do
        if part and part.Parent then pcall(function() part.CanCollide = true end) end
    end
    exDoorsSaved = {}
end

secMove:Toggle({ Title = "Disable Killer Doors Collision", Type = "Checkbox", Flag = "exKillerDoors", Default = false,
    Callback = exApplyDoors })
extrasBind("exKillerDoors", function(v) exApplyDoors(v == true) end)

local exPuddleLoop = nil
local exPuddleSaved = {}
local function exApplyPuddles(on)
    if exPuddleLoop then exPuddleLoop(); exPuddleLoop = nil end
    if on then
        exPuddleLoop = extrasLoop(0.5, function()
            local ingame = getIngame()
            if not ingame then return end
            local function touchOff(obj)
                if obj:IsA("BasePart") and obj.CanTouch then
                    exPuddleSaved[obj] = true
                    obj.CanTouch = false
                end
            end
            for _, child in ipairs(ingame:GetChildren()) do
                local name = string.lower(child.Name)
                if name:find("shadow") or name:find("puddle") then
                    if child:IsA("BasePart") then
                        touchOff(child)
                    else
                        for _, part in ipairs(child:GetDescendants()) do touchOff(part) end
                    end
                end
            end
        end)
        return
    end
    for part in pairs(exPuddleSaved) do
        if part and part.Parent then pcall(function() part.CanTouch = true end) end
    end
    exPuddleSaved = {}
end

secMove:Toggle({ Title = "Walkable Puddles (JD / Nos)", Type = "Checkbox", Flag = "exPuddles", Default = false,
    Callback = exApplyPuddles })
extrasBind("exPuddles", function(v) exApplyPuddles(v == true) end)
end -- [SorsHub: scope local]


-- ============================================================
-- GENERATOR HELPER
-- ============================================================

do -- [SorsHub: scope local]
local secGenHelper = tabExtras:Section({ Title = "Generator Helper", Opened = false })

local exAutoEnterLoop = nil
local function exApplyAutoEnter(on)
    if exAutoEnterLoop then exAutoEnterLoop(); exAutoEnterLoop = nil end
    if not on then return end
    exAutoEnterLoop = extrasLoop(0.2, function()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("PuzzleUI") then return end
        local content = getMapContent()
        local root = extrasGetRoot()
        if not content or not root then return end
        local pos = root.Position
        for _, gen in ipairs(content:GetChildren()) do
            if gen.Name == "Generator" then
                local positions = gen:FindFirstChild("Positions")
                local main = gen:FindFirstChild("Main")
                local prompt = main and main:FindFirstChild("Prompt")
                local near = false
                if positions then
                    for _, spotName in ipairs({ "Center", "Right", "Left" }) do
                        local spot = positions:FindFirstChild(spotName)
                        if spot and spot:IsA("BasePart") and (pos - spot.Position).Magnitude <= 4 then
                            near = true
                            break
                        end
                    end
                end
                if near and prompt and prompt:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(prompt) end)
                    task.wait(1)
                    return
                end
            end
        end
    end)
end

secGenHelper:Toggle({ Title = "Auto Enter Generator", Type = "Checkbox", Flag = "exAutoEnterGen", Default = false,
    Callback = exApplyAutoEnter })
extrasBind("exAutoEnterGen", function(v) exApplyAutoEnter(v == true) end)
end -- [SorsHub: scope local]


-- ============================================================
-- INTERFACE TAB
-- ============================================================

local tabInterface = win:Tab({ Title = "Interface", Icon = "scan" })
do -- [SorsHub: scope local]
local secUIFunctions = tabInterface:Section({ Title = "UI Functions", Opened = true })

secUIFunctions:Button({ Title = "Close UI", Callback = function()
    pcall(function()
        local ok = pcall(function() win:Destroy() end)
        if not ok then pcall(function() win:Close() end) end
    end)
end })
end -- [SorsHub: scope local]


-- CONFIG (renamed from "Config Share")
local secConfig = tabInterface:Section({ Title = "Config", Opened = false })

local CONFIG_PREFIX = "present:"
local CONFIG_LEGACY_PREFIX = "srs_full:"

secConfig:Paragraph({
    Title = "Share your settings",
    Desc = "Copy Config gives you a " .. CONFIG_PREFIX .. "... string. Paste it in Load Config on any account.",
})

local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64Encode(str)
    local result = {}
    local bytes = {string.byte(str, 1, #str)}
    for i = 1, #bytes, 3 do
        local b1,b2,b3 = bytes[i] or 0, bytes[i+1] or 0, bytes[i+2] or 0
        local n = b1*65536 + b2*256 + b3
        result[#result+1] = B64CHARS:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
        result[#result+1] = B64CHARS:sub(math.floor(n/4096)%64+1, math.floor(n/4096)%64+1)
        result[#result+1] = bytes[i+1] and B64CHARS:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1) or "="
        result[#result+1] = bytes[i+2] and B64CHARS:sub(n%64+1, n%64+1) or "="
    end
    return table.concat(result)
end

local function b64Decode(str)
    local lookup = {}; for i=1,#B64CHARS do lookup[B64CHARS:sub(i,i)] = i-1 end
    local bytes = {}
    for i = 1, #str, 4 do
        local c1 = lookup[str:sub(i,i)] or 0; local c2 = lookup[str:sub(i+1,i+1)] or 0
        local c3 = lookup[str:sub(i+2,i+2)]; local c4 = lookup[str:sub(i+3,i+3)]
        local n = c1*262144 + c2*4096 + (c3 or 0)*64 + (c4 or 0)
        bytes[#bytes+1] = string.char(math.floor(n/65536)%256)
        if c3 then bytes[#bytes+1] = string.char(math.floor(n/256)%256) end
        if c4 then bytes[#bytes+1] = string.char(n%256) end
    end
    return table.concat(bytes)
end

local CONFIG_PATH = "WindUI/SorsHub/config/SorsHub.json"

local function safeLoadV1Config()
    -- WindUI's config parser may load Toggle values asynchronously. Repair
    -- non-boolean values in old JSON before invoking its loader.
    pcall(function()
        if not fs.hasFile(CONFIG_PATH) then return end
        local raw = fs.read(CONFIG_PATH)
        if type(raw) ~= "string" or raw == "" then return end
        local decoded = svc.Http:JSONDecode(raw)
        if type(decoded) ~= "table" then return end
        local elements = decoded.__elements or decoded
        if type(elements) ~= "table" then return end
        local changed = false
        for _, item in pairs(elements) do
            if type(item) == "table" and item.__type == "Toggle" and type(item.value) ~= "boolean" then
                local rawValue = item.value
                item.value = (rawValue == "true" or rawValue == 1 or rawValue == "1")
                changed = true
            end
        end
        if changed then
            fs.write(CONFIG_PATH, svc.Http:JSONEncode(decoded))
            warn("[SorsHub] repaired non-boolean Toggle values in saved config")
        end
    end)
    return v1prConfig:Load()
end

local function configNotify(title, content, icon)
    pcall(function()
        ui:Notify({ Title = title, Content = content, Duration = 4, Icon = icon or "info" })
    end)
end

-- Strips whitespace / quotes that chat apps love to add around copied strings.
local function cleanConfigString(raw)
    if type(raw) ~= "string" then return "" end
    local s = raw:gsub("^%s+", ""):gsub("%s+$", "")
    s = s:gsub("^[\"'`]+", ""):gsub("[\"'`]+$", "")
    s = s:gsub("%s+", "")
    return s
end

secConfig:Button({
    Title = "📋 Copy Config",
    Icon = "copy",
    Callback = function()
        pcall(function()
            local ok, e = pcall(function()
                local raw = readfile(CONFIG_PATH)
                if type(raw) ~= "string" or #raw == 0 then error("config file is empty") end
                setclipboard(CONFIG_PREFIX .. b64Encode(raw))
                print("[SorsHub] Config copied (" .. #raw .. " bytes)")
                configNotify("Config Copied", "String starts with " .. CONFIG_PREFIX .. " - share it freely.", "copy")
            end)
            if not ok then
                print("[SorsHub] Copy failed: " .. tostring(e))
                configNotify("Copy failed", tostring(e), "alert-triangle")
            end
        end)
    end,
})

local importStr = ""

secConfig:Input({
    Title = "Paste Config String",
    Icon = "clipboard",
    Flag = "configImport",
    Placeholder = CONFIG_PREFIX .. "...",
    Callback = function(v) pcall(function() importStr = cleanConfigString(v) end) end,
})

secConfig:Button({
    Title = "🔄 Load Config",
    Icon = "download",
    Callback = function()
        pcall(function()
            local payload = cleanConfigString(importStr)
            if payload == "" then
                configNotify("Load failed", "Paste a " .. CONFIG_PREFIX .. "... string first.", "alert-triangle")
                return
            end
            local body
            if payload:sub(1, #CONFIG_PREFIX) == CONFIG_PREFIX then
                body = payload:sub(#CONFIG_PREFIX + 1)
            elseif payload:sub(1, #CONFIG_LEGACY_PREFIX) == CONFIG_LEGACY_PREFIX then
                -- Backwards compatibility with old SorsHub "srs_full:" strings.
                body = payload:sub(#CONFIG_LEGACY_PREFIX + 1)
            else
                configNotify("Load failed", "String must start with " .. CONFIG_PREFIX, "alert-triangle")
                return
            end
            local decoded = b64Decode(body)
            if type(decoded) ~= "string" or #decoded == 0 or not decoded:match("^%s*{") then
                configNotify("Load failed", "That string is empty or corrupted.", "alert-triangle")
                return
            end
            writefile(CONFIG_PATH, decoded)
            safeLoadV1Config()
            applyConfigFromFlags()
            print("[SorsHub] Config loaded from " .. CONFIG_PREFIX .. " string")
            configNotify("Config Loaded", "Your settings were applied.", "check")
        end)
    end,
})

secConfig:Button({
    Title = "💾 Save Config",
    Icon = "save",
    Callback = function()
        pcall(function()
            v1prConfig:Save()
            print("[SorsHub] Config saved")
            configNotify("Config Saved", "Saved to " .. CONFIG_PATH, "save")
        end)
    end,
})

secConfig:Button({
    Title = "🗑️ Reset Config",
    Icon = "trash-2",
    Callback = function()
        pcall(function()
            writefile(CONFIG_PATH, "{}")
            safeLoadV1Config()
            configNotify("Config Reset", "Settings were reset to defaults.", "rotate-ccw")
        end)
    end,
})

-- ============================================================
-- REPORT TAB
-- Support / bug reports + the Discord invite used by the key system.
-- ============================================================

local SORSHUB_VERSION = "1.2"
local tabReport = win:Tab({ Title = "Report", Icon = "flag" })
local secReport = tabReport:Section({ Title = "Discord Support", Opened = true })

secReport:Paragraph({
    Title = "SorsHub Discord",
    Desc = "Need help, found a bug, or want to share a config? Join the server: " .. SORSHUB_DISCORD,
})

secReport:Button({
    Title = "📋 Copy Discord Invite",
    Icon = "copy",
    Callback = function()
        pcall(function() setclipboard(SORSHUB_DISCORD) end)
        pcall(function()
            ui:Notify({ Title = "Invite Copied", Content = SORSHUB_DISCORD, Duration = 5, Icon = "link" })
        end)
    end,
})

local reportDraft = ""

secReport:Input({
    Title = "Describe the bug",
    Icon = "pencil",
    Flag = "reportDraft",
    Placeholder = "What happened, and what did you expect?",
    Callback = function(v) reportDraft = tostring(v or "") end,
})

secReport:Button({
    Title = "📤 Copy Bug Report",
    Icon = "clipboard-check",
    Callback = function()
        local executor = "unknown"
        pcall(function()
            if type(identifyexecutor) == "function" then
                local ok, name = pcall(identifyexecutor)
                if ok and name then executor = tostring(name) end
            end
        end)
        local stamp = "unknown"
        pcall(function() stamp = os.date("%Y-%m-%d %H:%M:%S") end)
        local template = table.concat({
            "**SorsHub " .. SORSHUB_VERSION .. " - Bug Report**",
            "- Player: " .. lp.Name .. " (" .. lp.DisplayName .. ")",
            "- UserId: " .. tostring(lp.UserId),
            "- Place: " .. tostring(game.PlaceId) .. " | Job: " .. tostring(game.JobId),
            "- Executor: " .. executor,
            "- Time: " .. stamp,
            "",
            "**Issue:**",
            reportDraft ~= "" and reportDraft or "(write what happened here)",
            "",
            "Discord: " .. SORSHUB_DISCORD,
        }, "\n")
        pcall(function() setclipboard(template) end)
        pcall(function()
            ui:Notify({ Title = "Report Copied", Content = "Paste it in " .. SORSHUB_DISCORD, Duration = 6, Icon = "clipboard-check" })
        end)
    end,
})

secReport:Paragraph({
    Title = "Credits",
    Desc = "SorsHub " .. SORSHUB_VERSION .. " by G1-menh. Seluruh fitur tambahan sudah di-merge ke SorsHub. Music / LMS modules are not included.",
})

-- ============================================================
-- MERGED FEATURE PACK (Obsidian -> WindUI adapter)
-- Every ported tab / dialog is recreated inside this window.
-- ============================================================

pcall(function()
    if type(getgenv) ~= "function" then
        getgenv = function() return _G end
    end
end)

Options = Options or {}
Options.MenuKeybind = Options.MenuKeybind or { Value = "L" }

local MergeProto = {}
local MergeRoot = {}
local vxElement

local MergeLib = { ScreenGui = Instance.new("ScreenGui") }
local MergeNoop = setmetatable({}, {
    __index = function()
        return function() return true end
    end,
})

do -- [SorsHub: scope local]
local vxCount = 0

local function vxFlagName(flag)
    vxCount = vxCount + 1
    if type(flag) == "string" and flag ~= "" then
        return "vx_" .. (flag:gsub("[^%w_]", "_"))
    end
    return "vx_auto_" .. vxCount
end

local function vxNum(value, fallback)
    local parsed = tonumber(value)
    if parsed == nil then return fallback end
    return parsed
end

local function vxStep(rounding)
    local r = vxNum(rounding, 0)
    if r <= 0 then return 1 end
    if r == 1 then return 0.1 end
    return 0.01
end

local function vxFirstValue(values, default)
    if type(default) == "table" then default = default[1] end
    if type(default) == "number" then return values[default] end
    if default == nil then return values[1] end
    return default
end

vxElement = function(section, flag, value, parent)
    return setmetatable({
        __section = section,
        __parent = parent,
        __tab = parent and parent.__tab or nil,
        Value = value,
    }, { __index = MergeProto })
end

function MergeProto:__getSection()
    if self.__section then return self.__section end
    if self.__parent then
        local inherited = self.__parent:__getSection()
        self.__section = inherited
        return inherited
    end
    if self.__tab then
        local created
        pcall(function() created = self.__tab:Section({ Title = "General", Opened = true, Box = true }) end)
        self.__section = created
        return created
    end
    return nil
end

function MergeProto:AddLeftGroupbox(name, icon)
    local section
    local tab = self.__tab or (self.__parent and self.__parent.__tab)
    if self.__charMode then tab = MergeRoot.__charTab(name) end
    if tab then
        -- [SorsHub fix V20.5] Opened=true: section pack dulu selalu collapsed,
        -- membuat tab karakter (Azure/Noli/Nosferatu) tampak "kosong" di mobile
        -- karena hanya menampilkan header tipis tanpa kontrol terlihat.
        pcall(function() section = tab:Section({ Title = tostring(name or "Group"), Opened = true, Box = true }) end)
        MergeRoot.__uiSections = MergeRoot.__uiSections or {}
        table.insert(MergeRoot.__uiSections, { tab = tostring(name or "Group"), section = section })
    end
    return vxElement(section or self:__getSection(), nil, nil, self)
end

function MergeProto:AddRightGroupbox(name, icon)
    return self:AddLeftGroupbox(name, icon)
end

function MergeProto:AddLeftTabbox(name)
    local proxy = vxElement(nil, nil, nil, self)
    proxy.__tab = self.__tab or (self.__parent and self.__parent.__tab)
    proxy.__charMode = self.__charMode
    return proxy
end

function MergeProto:AddRightTabbox(name)
    return self:AddLeftTabbox(name)
end

-- Tabboxes become stacked WindUI sections inside the same page.
function MergeProto:AddTab(name, icon)
    local section
    local tab = self.__tab or (self.__parent and self.__parent.__tab)
    local title = tostring(name or "Tab")
    local titleKey = string.lower(title):gsub("[^%w]", "")
    -- Do not render the empty Stamina > Walkspeed section. Its only controls
    -- (Walkspeed Multiplier and Multiplier) are already represented by the
    -- native Extras controls. Keep returning a proxy so pack callbacks remain safe.
    if titleKey == "walkspeed" and tab and tab == vxTabRegistry["stamina"] then
        return vxElement(nil, nil, nil, self)
    end
    if self.__charMode then
        if string.lower(title) == "settings" and self.__charTabObj then
            tab = self.__charTabObj
            title = tostring(self.__charName or "") .. " Settings"
        else
            tab = MergeRoot.__charTab(title)
            self.__charTabObj = tab
            self.__charName = title
        end
    end
    if tab then
        -- [SorsHub fix V20.5] Opened=true agar fitur langsung terlihat (lihat AddLeftGroupbox).
        pcall(function() section = tab:Section({ Title = title, Opened = true, Box = true }) end)
        MergeRoot.__uiSections = MergeRoot.__uiSections or {}
        table.insert(MergeRoot.__uiSections, { tab = title, section = section })
    end
    return vxElement(section or self:__getSection(), nil, nil, self)
end

-- Duplicate feature controls already implemented in the main SorsHub UI.
-- Only controls with equivalent behavior are suppressed; similarly named but
-- behaviorally distinct features (e.g. the two Hitbox Expander variants) stay.
local MERGED_DUPLICATE_CHECKBOXES = {
    ["anti lag"] = true,
    ["auto enter generator"] = true,
    ["anti bloodhook"] = true,
    ["anti plants and nova"] = true,
    ["anti fake noli"] = true,
    ["anti fake generator"] = true,
    ["anti slow fall"] = true,
    ["anti sentry slow"] = true,
    ["disable killer doors collision"] = true,
    ["allow jump"] = true,
    ["noclip walls"] = true,
    ["auto unsprint"] = true,
    ["camera noclip"] = true,
    ["full bright"] = true,
    ["infinite camera distance"] = true,
    ["keep directional speed"] = true,
    ["no stamina penalty"] = true,
    ["see hidden stats"] = true,
    ["show chat window"] = true,
    ["stamina checker"] = true,
    ["walkspeed multiplier"] = true,
}

-- These labels are merged into equivalent native WindUI controls as well.
local MERGED_DUPLICATE_INPUTS = {
    ["unsprint at stamina"] = true,
}
local MERGED_DUPLICATE_SLIDERS = {
    ["multiplier"] = true,
}
local MERGED_DUPLICATE_BUTTONS = {
}

function MergeProto:AddCheckbox(flag, cfg)
    cfg = cfg or {}
    local controlTitle = tostring(cfg.Text or cfg.Title or "Toggle")
    local duplicateKey = string.lower(controlTitle):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if MERGED_DUPLICATE_CHECKBOXES[duplicateKey] then
        -- Keep the pack's Lua flow intact while preventing a second UI control
        -- and a second independent callback/loop for the same feature.
        return vxElement(nil, flag, (cfg.Default == true), self)
    end
    local section = self:__getSection()
    local default = cfg.Default
    default = (default == nil) and false or (not not default)
    local proxy = vxElement(section, flag, default, self)
    if type(flag) == "string" then Options[flag] = { Value = default } end
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1
        local windFlag = vxFlagName(flag)
        pcall(function()
            section:Toggle({
                Title = tostring(cfg.Text or "Toggle"),
                Type = "Checkbox",
                Value = default,
                Default = default,
                Flag = windFlag,
                Callback = function(value)
                    proxy.Value = value
                    if type(flag) == "string" then Options[flag] = { Value = value } end
                    if type(cfg.Callback) == "function" and not (MergeRoot.__loading and value == default) then pcall(cfg.Callback, value) end
                end,
            })
        end)
    end
    return proxy
end

function MergeProto:AddToggle(flag, cfg)
    return self:AddCheckbox(flag, cfg)
end

function MergeProto:AddSlider(flag, cfg)
    cfg = cfg or {}
    local min = vxNum(cfg.Min, 0)
    local max = vxNum(cfg.Max, 100)
    if max <= min then max = min + 1 end
    local default = vxNum(cfg.Default, min)
    if default < min then default = min end
    if default > max then default = max end
    local controlTitle = tostring(cfg.Text or cfg.Title or "Slider")
    local duplicateKey = string.lower(controlTitle):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if MERGED_DUPLICATE_SLIDERS[duplicateKey] then
        return vxElement(nil, flag, default, self)
    end
    local section = self:__getSection()
    local proxy = vxElement(section, flag, default, self)
    if type(flag) == "string" then Options[flag] = { Value = default } end
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1
        local windFlag = vxFlagName(flag)
        pcall(function()
            section:Slider({
                Title = tostring(cfg.Text or "Slider"),
                Value = { Min = min, Max = max, Default = default },
                Step = vxStep(cfg.Rounding),
                Suffix = cfg.Suffix,
                Flag = windFlag,
                Callback = function(value)
                    local parsed = tonumber(value) or default
                    proxy.Value = parsed
                    if type(flag) == "string" then Options[flag] = { Value = parsed } end
                    if type(cfg.Callback) == "function" and not (MergeRoot.__loading and parsed == default) then pcall(cfg.Callback, parsed) end
                end,
            })
        end)
    end
    return proxy
end

function MergeProto:AddDropdown(flag, cfg)
    cfg = cfg or {}
    local section = self:__getSection()
    local values = cfg.Values
    if type(values) ~= "table" then values = {} end
    local multi = cfg.Multi == true
    local default
    if multi then
        if type(cfg.Default) == "table" then
            default = cfg.Default
        elseif cfg.Default ~= nil then
            default = { cfg.Default }
        else
            default = {}
        end
    else
        default = vxFirstValue(values, cfg.Default)
    end
    local proxy = vxElement(section, flag, default, self)
    if type(flag) == "string" then Options[flag] = { Value = default } end
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1
        local windFlag = vxFlagName(flag)
        pcall(function()
            section:Dropdown({
                Title = tostring(cfg.Text or "Dropdown"),
                Values = values,
                Value = default,
                Multi = multi,
                Flag = windFlag,
                Callback = function(value)
                    proxy.Value = value
                    if type(flag) == "string" then Options[flag] = { Value = value } end
                    if type(cfg.Callback) == "function" and not (MergeRoot.__loading and value == default) then pcall(cfg.Callback, value) end
                    if type(proxy.__onChanged) == "function" then pcall(proxy.__onChanged, value) end
                end,
            })
        end)
    end
    return proxy
end

function MergeProto:AddInput(flag, cfg)
    if type(flag) == "table" and cfg == nil then
        cfg = flag
        flag = nil
    end
    cfg = cfg or {}
    local default = cfg.Default
    if default == nil then default = "" end
    default = tostring(default)
    local controlTitle = tostring(cfg.Text or cfg.Title or "Input")
    local duplicateKey = string.lower(controlTitle):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if MERGED_DUPLICATE_INPUTS[duplicateKey] then
        return vxElement(nil, flag, default, self)
    end
    local section = self:__getSection()
    local proxy = vxElement(section, flag, default, self)
    if type(flag) == "string" then Options[flag] = { Value = default } end
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1
        local windFlag = vxFlagName(flag)
        pcall(function()
            section:Input({
                Title = tostring(cfg.Text or "Input"),
                Placeholder = tostring(cfg.Placeholder or ""),
                Value = default,
                CurrentValue = default,
                Flag = windFlag,
                Callback = function(value)
                    proxy.Value = value
                    if type(flag) == "string" then Options[flag] = { Value = value } end
                    if type(cfg.Callback) == "function" and not (MergeRoot.__loading and value == default) then pcall(cfg.Callback, value) end
                end,
            })
        end)
    end
    return proxy
end

function MergeProto:AddButton(flag, cfg)
    if type(flag) == "table" and cfg == nil then
        cfg = flag
        flag = nil
    end
    cfg = cfg or {}
    local controlTitle = tostring(cfg.Text or cfg.Title or "Button")
    local duplicateKey = string.lower(controlTitle):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if MERGED_DUPLICATE_BUTTONS[duplicateKey] then
        return vxElement(nil, flag, nil, self)
    end
    local section = self:__getSection()
    local proxy = vxElement(section, flag, nil, self)
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1 -- [SorsHub fix V20.7] button ikut dihitung
        pcall(function()
            section:Button({
                Title = tostring(cfg.Text or "Button"),
                Callback = function()
                    if type(cfg.Func) == "function" then
                        local ok, err = pcall(cfg.Func)
                        if not ok then warn("[SorsHub] Feature button error: " .. tostring(err)) end
                    end
                end,
            })
        end)
    end
    return proxy
end

function MergeProto:AddKeyPicker(flag, cfg)
    if type(flag) == "table" and cfg == nil then
        cfg = flag
        flag = nil
    end
    cfg = cfg or {}
    local section = self:__getSection()
    local default = cfg.Default
    if type(default) ~= "string" then default = "F" end
    local proxy = vxElement(section, flag, default, self)
    if type(flag) == "string" then Options[flag] = { Value = default } end
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1
        local windFlag = vxFlagName(flag)
        pcall(function()
            section:Keybind({
                Title = tostring(cfg.Text or "Keybind"),
                Value = default,
                Flag = windFlag,
                Callback = function(key)
                    proxy.Value = key
                    if type(flag) == "string" then Options[flag] = { Value = key } end
                    if flag == "MenuKeybind" then
                        pcall(function()
                            local keyCode = Enum.KeyCode[key]
                            if keyCode then win:SetToggleKey(keyCode) end
                        end)
                    end
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, key) end
                end,
            })
        end)
    end
    return proxy
end

function MergeProto:AddColorPicker(flag, cfg)
    if type(flag) == "table" and cfg == nil then
        cfg = flag
        flag = nil
    end
    cfg = cfg or {}
    local section = self:__getSection()
    local default = cfg.Default
    if typeof(default) ~= "Color3" then default = Color3.fromRGB(255, 255, 255) end
    local proxy = vxElement(section, flag, default, self)
    if type(flag) == "string" then Options[flag] = { Value = default } end
    if section then
        section.__vxCount = (section.__vxCount or 0) + 1
        local windFlag = vxFlagName(flag)
        pcall(function()
            section:Colorpicker({
                Title = tostring(cfg.Title or cfg.Text or "Color"),
                Default = default,
                Value = default,
                Transparency = vxNum(cfg.Transparency, 0),
                Flag = windFlag,
                Callback = function(color)
                    proxy.Value = color
                    if type(flag) == "string" then Options[flag] = { Value = color } end
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, color) end
                end,
            })
        end)
    end
    return proxy
end
end -- [SorsHub: scope local]


function MergeProto:AddLabel(text, cfg)
    local section = self:__getSection()
    if section then
        -- [SorsHub fix V20.7] Label (Paragraph) ikut dihitung agar section yang
        -- hanya berisi label tidak salah dianggap kosong lalu dibersihkan.
        section.__vxCount = (section.__vxCount or 0) + 1
        local desc = nil
        if type(cfg) == "table" then desc = cfg.Desc or cfg.Description end
        pcall(function()
            section:Paragraph({ Title = tostring(text or ""), Desc = desc })
        end)
    end
    return self
end

function MergeProto:AddDivider(cfg)
    local section = self:__getSection()
    if section then
        pcall(function() section:Divider() end)
    end
    return self
end

function MergeProto:AddViewport(name, cfg)
    -- WindUI has no 3D viewport element; the 3D preview is skipped.
    return self
end

function MergeProto:GetValue()
    return self.Value
end

function MergeProto:GetActiveValues()
    if type(self.Value) == "table" then return self.Value end
    return { self.Value }
end

function MergeProto:OnChanged(fn)
    self.__onChanged = fn
    return self
end

function MergeProto:SetVisible() end
function MergeProto:Dismiss() end

function MergeRoot:AddTab(name, icon)
    local nm = tostring(name or "Tab")
    local key = (string.lower(nm):gsub("[^%w]", ""))

    -- Auto Block tetap diarahkan ke halaman Guest1337.
    if key == "autoblock" then
        local guestTab = vxTabRegistry["guest1337"]
        if not guestTab then
            pcall(function()
                guestTab = win:Tab({ Title = "Guest1337", Icon = "shield" })
            end)
            if guestTab then vxTabRegistry["guest1337"] = guestTab end
        end
        local proxy = vxElement(nil, nil, nil, nil)
        proxy.__tab = guestTab
        return proxy
    end

    -- Killers / Survivors hanya menjadi wadah logis. Tidak dibuatkan tab UI;
    -- setiap groupbox/tab karakter tetap dialihkan ke halaman karakternya.
    if key == "killers" or key == "survivors" then
        local charProxy = vxElement(nil, nil, nil, nil)
        charProxy.__charMode = true
        return charProxy
    end

    -- Preserve every non-character feature-pack tab by its own name. Existing
    -- native tabs are reused only when their normalized names are identical.
    local tab = vxTabRegistry[key]
    if not tab then
        pcall(function()
            tab = win:Tab({
                Title = nm,
                Icon = (type(icon) == "string" and icon ~= "") and icon or "package",
            })
        end)
    end
    local proxy = vxElement(nil, nil, nil, nil)
    proxy.__tab = tab
    return proxy
end

-- tab per karakter: pakai tab SorsHub dengan nama sama (Chance, Jane Doe, ...), kalau tidak ada buat baru
MergeRoot.__charTab = function(name, icon)
    local nm = tostring(name or "Character")
    local key = (string.lower(nm):gsub("[^%w]", ""))
    MergeRoot.__chars = MergeRoot.__chars or {}
    if MergeRoot.__chars[key] then return MergeRoot.__chars[key] end
    -- nama sama dengan tab SorsHub (Two Time, Chance, ...) -> pakai tab itu; kalau belum ada (Azure, ...) -> buat tab baru
    local tab = vxTabRegistry[key]
    if not tab then
        pcall(function()
            tab = win:Tab({ Title = nm, Icon = (type(icon) == "string" and icon ~= "") and icon or "user" })
        end)
    end
    MergeRoot.__chars[key] = tab
    return tab
end

do -- [SorsHub: scope local]
function MergeRoot:AddDialog(name, cfg)
    cfg = cfg or {}
    local dialogTitle = tostring(cfg.Title or name or "Aimbot Config")
    -- Config panels are kept inside the Aimbot page instead of creating a new
    -- sidebar tab every time a character config is opened.
    local tab = vxTabRegistry["aimbot"]
    local section
    if tab then
        pcall(function()
            section = tab:Section({
                Title = dialogTitle,
                Opened = true,
                Box = true,
            })
        end)
    end

    local proxy = vxElement(section, nil, nil, nil)
    proxy.__tab = tab
    proxy.__section = section
    proxy.Dismiss = function()
        if section then
            pcall(function()
                if type(section.Destroy) == "function" then
                    section:Destroy()
                end
            end)
        end
    end
    proxy.Show = function()
        if tab then pcall(function() tab:Select() end) end
    end

    if section then
        if cfg.Description then
            pcall(function() section:Paragraph({ Title = tostring(cfg.Description) }) end)
        end
        for _, item in pairs(cfg.FooterButtons or {}) do
            if type(item) == "table" then
                pcall(function()
                    section:Button({
                        Title = tostring(item.Title or "Apply"),
                        Callback = function()
                            if type(item.Callback) == "function" then pcall(item.Callback) end
                        end,
                    })
                end)
            end
        end
    end
    return proxy
end
end -- [SorsHub: scope local]


function MergeLib:Notify(cfg)
    cfg = cfg or {}
    pcall(function()
        ui:Notify({
            Title = tostring(cfg.Title or "SorsHub"),
            Content = tostring(cfg.Description or cfg.Content or ""),
            Duration = tonumber(cfg.Duration or cfg.Time) or 3,
            Icon = "info",
        })
    end)
end

do -- [SorsHub: scope local]
local MERGED_FONT_MAP = {
    Gotham = "GothamSSm",
    GothamMedium = "GothamSSm",
    GothamBold = "GothamSSm",
    GothamBlack = "GothamSSm",
    Arial = "Arial",
    ArialBold = "Arial",
    Roboto = "Roboto",
    SourceSans = "SourceSansPro",
    SourceSansBold = "SourceSansPro",
    Code = "RobotoMono",
}

function MergeLib:SetDPIScale() end

function MergeLib:SetFont(font)
    local name = (typeof(font) == "EnumItem" and font.Name) or tostring(font)
    local family = MERGED_FONT_MAP[name] or "GothamSSm"
    pcall(function() ui:SetFont("rbxasset://fonts/families/" .. family .. ".json") end)
end
end -- [SorsHub: scope local]


function MergeLib:SetNotifySide() end
function MergeLib:SetTheme() end
function MergeLib:AddIcons() end

-- The stamina / mouse helper modules are loaded by their own threads.
-- The waits for them below are time-limited so a missing module can never
-- stall the rest of the feature pack.

-- ============================================================
-- FEATURE PACK LOADER (dipecah jadi beberapa file kecil supaya executor
-- mobile seperti Delta tidak gagal compile file 1 MB)
-- Part dibaca dari workspace: SorsHub/parts/pack_XX.lua
-- atau diunduh dari PACK_BASE_URL (isi dengan folder raw GitHub, akhiri "/")
-- ============================================================
do -- [SorsHub: scope local]
local function loadMergedFeaturePack()
    local PACK_BASE_URL = ""
    local PACK_DIR = WIND_DIR .. "/parts"
    local PACK_FILES = {
        "pack_01.lua",
        "pack_02.lua",
        "pack_03.lua",
        "pack_04.lua",
        "pack_05.lua",
        "pack_06.lua",
        "pack_07.lua",
        "pack_08.lua",
        "pack_09.lua",
        "pack_10.lua",
    }

    local function readPackPart(name)
        local path = PACK_DIR .. "/" .. name
        local okR, cached = pcall(function()
            if fs.hasFile(path) then return fs.read(path) end
        end)
        if okR and type(cached) == "string" and #cached > 50 then return cached end
        if PACK_BASE_URL ~= "" then
            local src = httpGet(PACK_BASE_URL .. name)
            if type(src) == "string" and #src > 50 then
                pcall(function()
                    if not fs.hasFolder(WIND_DIR) then fs.makeFolder(WIND_DIR) end
                    if not fs.hasFolder(PACK_DIR) then fs.makeFolder(PACK_DIR) end
                    fs.write(path, src)
                end)
                return src
            end
        end
        return nil, "file tidak ditemukan: " .. path
    end

    local P = {
        MergeLib = MergeLib, MergeNoop = MergeNoop, MergeRoot = MergeRoot,
        svc = svc, lp = lp, SORSHUB_VERSION = SORSHUB_VERSION,
    }
    local failed = {}
    MergeRoot.__loading = true
    for i, name in ipairs(PACK_FILES) do
        local src, rerr = readPackPart(name)
        if not src then
            warn("[SorsHub] " .. tostring(rerr))
            table.insert(failed, name)
        else
            local factory, cerr = compileScript(src)
            if not factory then
                warn("[SorsHub] compile error di " .. name .. ": " .. tostring(cerr))
                table.insert(failed, name)
            else
                local okRun, runErr = xpcall(function() return factory()(P) end, sorsHubTraceback)
                if not okRun then
                    warn("[SorsHub] error di " .. name .. ": " .. tostring(runErr))
                    table.insert(failed, name)
                end
            end
        end
    end
    task.delay(2, function() MergeRoot.__loading = false end)
    if #failed > 0 then
        error("part gagal: " .. table.concat(failed, ", "))
    end
end


task.spawn(function()
    local ok, err = pcall(loadMergedFeaturePack)
    if ok then
        print("[SorsHub] feature pack merged")
        -- [SorsHub fix V20.5] Diagnostik: laporkan jumlah kontrol per section pack
        -- supaya tab yang tampak kosong bisa dipastikan penyebabnya dari console.
        pcall(function()
            local parts = {}
            for _, rec in ipairs(MergeRoot.__uiSections or {}) do
                local n = rec.section and rec.section.__vxCount or 0
                parts[#parts + 1] = rec.tab .. "=" .. n .. (rec.section and "" or " (section GAGAL)")
            end
            if #parts > 0 then
                print("[SorsHub] UI pack sections: " .. table.concat(parts, ", "))
            end
        end)
        -- [SorsHub fix V20.6] Akar masalah tab karakter (Azure/Noli/Nosferatu)
        -- tampak kosong: Section WindUI hanya bisa dibuka (Open) setelah punya
        -- anak (Expandable). Section pack dibuat kosong lalu diisi setelah
        -- yield antar-pack; pada sebagian versi WindUI frame section tetap
        -- setinggi header dengan ClipsDescendants=true, sehingga kontrol yang
        -- ditambahkan belakangan ter-clip dan tidak terlihat. Buka eksplisit
        -- semua section pack yang sudah terisi, berulang sebentar agar kontrol
        -- dari task.spawn yang telat ikut tertangkap.
        task.spawn(function()
            for _ = 1, 8 do
                task.wait(0.25)
                for _, rec in ipairs(MergeRoot.__uiSections or {}) do
                    local s = rec.section
                    if s and (s.__vxCount or 0) > 0 then
                        pcall(function()
                            s.Opened = true
                            if type(s.Open) == "function" then s:Open(true) end
                        end)
                    end
                end
            end
            -- [SorsHub fix V20.7] Setelah jendela 2 detik selesai, hapus section
            -- pack yang TETAP kosong (0 kontrol): mis. section yang hanya berisi
            -- Viewport (tidak didukung WindUI) atau semua kontrolnya duplikat
            -- native. Section berisi label/button kini ikut terhitung, jadi
            -- tidak akan salah terhapus.
            local removed = {}
            for _, rec in ipairs(MergeRoot.__uiSections or {}) do
                local s = rec.section
                if s and (s.__vxCount or 0) == 0 then
                    pcall(function()
                        if type(s.Destroy) == "function" then s:Destroy() end
                    end)
                    table.insert(removed, tostring(rec.tab))
                end
            end
            if #removed > 0 then
                print("[SorsHub] section kosong dihapus: " .. table.concat(removed, ", "))
            end
        end)
    else
        warn("[SorsHub] merge error: " .. tostring(err))
        pcall(function()
            ui:Notify({
                Title = "Merge error",
                Content = "Sebagian tab gagal dimuat: " .. tostring(err):sub(1, 140),
                Duration = 8,
                Icon = "alert-triangle",
            })
        end)
    end
end)
end -- [SorsHub: scope local]



-- ============================================================
-- CONFIG APPLY
-- ============================================================

function applyConfigFromFlags()
    pcall(function()
        task.wait(0.5)
        if not (win and win.Flags) then return end
        print("[SorsHub] Applying config flags...")

        if win.Flags.spoofActive ~= nil then spoofActive=win.Flags.spoofActive; if spoofActive then spoofStart() else spoofStop() end end
        if win.Flags.chatForceEnabled ~= nil then chatForceEnabled=win.Flags.chatForceEnabled; if chatForceConn then chatForceConn:Disconnect(); chatForceConn=nil end; if chatForceEnabled then enforceChatOn(); chatForceConn=svc.Run.Heartbeat:Connect(enforceChatOn) end end
        if win.Flags.timerSide ~= nil then timerSide=type(win.Flags.timerSide)=="table" and win.Flags.timerSide[1] or win.Flags.timerSide; applyTimerPos() end
        if win.Flags.platEnabled ~= nil then platEnabled=win.Flags.platEnabled; if platEnabled then platStart() else platStop() end end
        if win.Flags.platDevice ~= nil then platDevice=win.Flags.platDevice end
        if win.Flags.stamOn ~= nil then stam.on=win.Flags.stamOn end
        if win.Flags.stamNoLoss ~= nil then stam.noLoss=win.Flags.stamNoLoss end
        if type(win.Flags.stamLoss)=="number" then stam.loss=win.Flags.stamLoss end
        if type(win.Flags.stamGain)=="number" then stam.gain=win.Flags.stamGain end
        if type(win.Flags.stamMax)=="number" then stam.max=win.Flags.stamMax end
        if type(win.Flags.stamCurrent)=="number" then stam.current=win.Flags.stamCurrent end
        if stam.on or stam.noLoss then stamStart() end; if stam.noLoss then stamApply() end
        if win.Flags.speedOn ~= nil then speedHack.on=win.Flags.speedOn; if speedHack.on then speedStart() end end
        if type(win.Flags.speedValue)=="number" then speedHack.speed=win.Flags.speedValue; speedHack.lastApplied=0 end
        if win.Flags.hbOn ~= nil then hb.on=win.Flags.hbOn; if hb.on then hbStart() else hbStop() end end
        if type(win.Flags.hbStrength)=="number" then hb.strength=win.Flags.hbStrength end
        if win.Flags.acOn ~= nil then ac.on=win.Flags.acOn; if not ac.on then for k in pairs(ac.active) do ac.active[k]=nil end; ac.chaseTarget=nil; ac.damageTarget=nil end end
        if type(win.Flags.acStrength)=="number" then ac.strength=win.Flags.acStrength end
        if type(win.Flags.acMaxDist)=="number" then ac.maxDist=win.Flags.acMaxDist end
        if win.Flags.flowOn ~= nil then flow.on=win.Flags.flowOn end
        if type(win.Flags.flowNodeDelay)=="number" then flow.nodeDelay=win.Flags.flowNodeDelay end
        if type(win.Flags.flowLineDelay)=="number" then flow.lineDelay=win.Flags.flowLineDelay end
        if win.Flags.espEnabled ~= nil then esp.enabled=win.Flags.espEnabled; if esp.enabled then espStart() else espStop() end end
        if win.Flags.espKillers ~= nil then esp.showKillers=win.Flags.espKillers end
        if win.Flags.espSurvivors ~= nil then esp.showSurvivors=win.Flags.espSurvivors end
        if win.Flags.espGenerators ~= nil then esp.showGenerators=win.Flags.espGenerators end
        if win.Flags.espItems ~= nil then esp.showItems=win.Flags.espItems end
        if win.Flags.espStructures ~= nil then esp.showStructures=win.Flags.espStructures end
        if win.Flags.gvEspOn ~= nil then gv.enabled=win.Flags.gvEspOn; if gv.enabled then gvStart() else gvStop() end end
        if win.Flags.gvShowGroundbulb ~= nil then gv.showGroundbulb=win.Flags.gvShowGroundbulb end
        if win.Flags.gvShowVine ~= nil then gv.showVine=win.Flags.gvShowVine end
        if type(win.Flags.gvScanRate)=="number" then gvConfig.ScanRate=win.Flags.gvScanRate end
        if win.Flags.espPizza ~= nil then mset.pizza=win.Flags.espPizza end
        if win.Flags.espZombie ~= nil then mset.zombie=win.Flags.espZombie end
        if win.Flags.espPuddle ~= nil then mset.puddle=win.Flags.espPuddle end
        if type(win.Flags.espMaxDistance)=="number" then esp.maxDistance=win.Flags.espMaxDistance end
        if type(win.Flags.espTransparency)=="number" then esp.transparency=win.Flags.espTransparency end
        if type(win.Flags.espScanRate)=="number" then esp.scanRate=win.Flags.espScanRate end
        if type(win.Flags.espMinionTrans)=="number" then mset.transparency=win.Flags.espMinionTrans; updateTransparency() end
        if win.Flags.jdEnabled ~= nil then jd_enabled=win.Flags.jdEnabled end
        if win.Flags.jdSilentAim ~= nil then jd_aimbotOn=win.Flags.jdSilentAim end
        if type(win.Flags.jdAimOffset)=="number" then jd_AIM_OFFSET=win.Flags.jdAimOffset end
        if type(win.Flags.jdPrediction)=="number" then jd_PREDICTION=win.Flags.jdPrediction end
        if win.Flags.jdAxeEnabled ~= nil then jd_axeEnabled=win.Flags.jdAxeEnabled end
        if type(win.Flags.jdAxeLockDur)=="number" then jd_AXE_LOCK_DURATION=win.Flags.jdAxeLockDur end
        if win.Flags.elliotEnabled ~= nil then elliotEnabled=win.Flags.elliotEnabled; if elliotEnabled then elliotStartAimbot() end end
        if win.Flags.elliotRequireAnim ~= nil then elliotRequireAnim=win.Flags.elliotRequireAnim end
        if win.Flags.elliotShowArc ~= nil then elliotShowArc=win.Flags.elliotShowArc end
        if type(win.Flags.elliotThrowDur)=="number" then elliotThrowDur=win.Flags.elliotThrowDur end
        if type(win.Flags.elliotSmoothness)=="number" then elliotSmoothness=win.Flags.elliotSmoothness end
        if type(win.Flags.elliotPredDist)=="number" then elliotPredDist=win.Flags.elliotPredDist end
        if type(win.Flags.elliotThrowForce)=="number" then elliotThrowForce=win.Flags.elliotThrowForce end
        if win.Flags.chanceAimEnabled ~= nil then chanceAimEnabled=win.Flags.chanceAimEnabled end
        if win.Flags.holdToAim ~= nil then holdToAim=win.Flags.holdToAim end
        if win.Flags.plasmaEnabled ~= nil then plasma_enabled=win.Flags.plasmaEnabled end
        if type(win.Flags.plasmaPrediction)=="number" then plasma_prediction=win.Flags.plasmaPrediction end
        if type(win.Flags.plasmaAimOffset)=="number" then plasma_aimOffset=win.Flags.plasmaAimOffset end
        if win.Flags.hdtEnabled ~= nil then guestCfg.hdtEnabled=win.Flags.hdtEnabled end
        if type(win.Flags.hdtSpeed)=="number" then guestCfg.hdtSpeed=win.Flags.hdtSpeed end
        if type(win.Flags.hdtDuration)=="number" then guestCfg.hdtDuration=win.Flags.hdtDuration end
        if type(win.Flags.hdtRange)=="number" then guestCfg.hdtRange=win.Flags.hdtRange end
        if type(win.Flags.hdtDelay)=="number" then guestCfg.hdtDelay=win.Flags.hdtDelay end
        if win.Flags.hdtFaceKiller ~= nil then guestCfg.hdtFaceKiller=win.Flags.hdtFaceKiller end
        if win.Flags.hdtShowRange ~= nil then guestCfg.hdtShowRange=win.Flags.hdtShowRange end
        if win.Flags.guestAutoBlockOn ~= nil then guestCfg.autoBlockOn=win.Flags.guestAutoBlockOn end
        if type(win.Flags.guestBlockDelay)=="number" then guestCfg.blockDelay=win.Flags.guestBlockDelay end
        if type(win.Flags.guestDetectionRange)=="number" then guestCfg.detectionRange=win.Flags.guestDetectionRange end
        if win.Flags.guestVerifyFacingCheck ~= nil then guestCfg.verifyFacingCheck=win.Flags.guestVerifyFacingCheck end
        if type(win.Flags.guestVisionRange)=="number" then guestCfg.visionRange=win.Flags.guestVisionRange end
        if type(win.Flags.guestVisionAngle)=="number" then guestCfg.visionAngle=win.Flags.guestVisionAngle end
        if win.Flags.guestShowVisionCone ~= nil then guestCfg.showVisionCone=win.Flags.guestShowVisionCone end
        if win.Flags.guestNoHDTCooldown ~= nil then guestCfg.noHDTCooldown=win.Flags.guestNoHDTCooldown end
        if win.Flags.guestHdtCooldownChecker ~= nil then guestCfg.hdtCooldownChecker=win.Flags.guestHdtCooldownChecker end
        if type(win.Flags.guestBlockCooldown)=="number" then guestCfg.blockCooldown=win.Flags.guestBlockCooldown end
        if type(win.Flags.guestAutoPunchDelay)=="number" then guestCfg.autoPunchDelay=win.Flags.guestAutoPunchDelay end
        if win.Flags.guestAutoPunchOn ~= nil then guestCfg.autoPunchOn=win.Flags.guestAutoPunchOn end
        if win.Flags.guestAimPunchActive ~= nil then guestCfg.aimPunchActive=win.Flags.guestAimPunchActive end
        if type(win.Flags.guestPunchPrediction)=="number" then guestCfg.punchPrediction=win.Flags.guestPunchPrediction end
        if type(win.Flags.guestAimPunchDuration)=="number" then guestCfg.aimPunchDuration=win.Flags.guestAimPunchDuration end
        if win.Flags.guestCinematicTextEnabled ~= nil then guestCfg.cinematicTextEnabled=win.Flags.guestCinematicTextEnabled end
        if win.Flags.guestCinematicText ~= nil then guestCfg.cinematicText=win.Flags.guestCinematicText end
        if win.Flags.guestReverseEnabled ~= nil then guestCfg.reverseEnabled=win.Flags.guestReverseEnabled end
        if win.Flags.guestLegacyFacingEnabled ~= nil then guestCfg.legacyFacingEnabled=win.Flags.guestLegacyFacingEnabled end
        if type(win.Flags.guestLegacyVisionRange)=="number" then guestCfg.legacyVisionRange=win.Flags.guestLegacyVisionRange end
        if type(win.Flags.guestLegacyVisionAngle)=="number" then guestCfg.legacyVisionAngle=win.Flags.guestLegacyVisionAngle end
        if win.Flags.guestLegacyShowVisionRange ~= nil then guestCfg.legacyShowVisionRange=win.Flags.guestLegacyShowVisionRange end
        if win.Flags.guestNoclipEnabled ~= nil then guestCfg.noclipEnabled=win.Flags.guestNoclipEnabled end
        if win.Flags.guestNoclipOnlyWhenBlockReady ~= nil then guestCfg.noclipOnlyWhenBlockReady=win.Flags.guestNoclipOnlyWhenBlockReady end
        if win.Flags.guestFpsCounterEnabled ~= nil then guestCfg.fpsCounterEnabled=win.Flags.guestFpsCounterEnabled end
        if win.Flags.guestPingCheckerEnabled ~= nil then guestCfg.pingCheckerEnabled=win.Flags.guestPingCheckerEnabled end
        if win.Flags.guestSoundBlockEnabled ~= nil then 
            guestCfg.soundBlockEnabled=win.Flags.guestSoundBlockEnabled
            if guestCfg.soundBlockEnabled then
                guestCfg.autoBlockOn = true
                pcall(function()
                    local kf = getTeamFolder("Killers")
                    if kf then
                        for _, killer in pairs(kf:GetChildren()) do
                            for _, d in pairs(killer:GetDescendants()) do
                                if d:IsA("Sound") then pcall(g_hookSound, d) end
                            end
                        end
                    end
                end)
            end
        end
        if win.Flags.guestHitboxEnabled ~= nil then guestCfg.hitboxEnabled=win.Flags.guestHitboxEnabled; if guestCfg.hitboxEnabled then setupHitboxBlock() end end
        if win.Flags.guestAnimEnabled ~= nil then guestCfg.animEnabled=win.Flags.guestAnimEnabled; if guestCfg.animEnabled then setupAnimBlock() end end
        if type(win.Flags.guestHitboxX)=="number" then guestCfg.hitboxSize=Vector3.new(win.Flags.guestHitboxX, guestCfg.hitboxSize.Y, guestCfg.hitboxSize.Z) end
        if type(win.Flags.guestHitboxY)=="number" then guestCfg.hitboxSize=Vector3.new(guestCfg.hitboxSize.X, win.Flags.guestHitboxY, guestCfg.hitboxSize.Z) end
        if type(win.Flags.guestHitboxZ)=="number" then guestCfg.hitboxSize=Vector3.new(guestCfg.hitboxSize.X, guestCfg.hitboxSize.Y, win.Flags.guestHitboxZ) end
        if type(win.Flags.guestAutoRange)=="number" then guestCfg.detectionRange=win.Flags.guestAutoRange end
        if type(win.Flags.guestAutoDelay)=="number" then guestCfg.blockDelay=win.Flags.guestAutoDelay end
        if win.Flags.guestAutoBlockType ~= nil then guestCfg.blockType=win.Flags.guestAutoBlockType end
        if win.Flags.guestAutoDouble ~= nil then guestCfg.doubleBlock=win.Flags.guestAutoDouble end
        if win.Flags.veeeAutoTrick ~= nil then atEnabled=win.Flags.veeeAutoTrick; if atEnabled then atStartManager() else atStopManager() end end
        if win.Flags.sk8ControlEnabled ~= nil then sk8_controlEnabled=win.Flags.sk8ControlEnabled; if not sk8_controlEnabled and sk8_controlActive then sk8_stopOverride() end end
        if win.Flags.veeeFastSpray ~= nil then vee_fastSpray=win.Flags.veeeFastSpray; if not vee_fastSpray then sprayPhase=0; sprayBaseCF=nil end end
        if win.Flags.ttEnabled ~= nil then tt_enabled=win.Flags.ttEnabled end
        if win.Flags.ttDaggerEnabled ~= nil then tt_daggerEnabled=win.Flags.ttDaggerEnabled end
        if win.Flags.ttBackstabType ~= nil then tt_backstabType=win.Flags.ttBackstabType end
        if win.Flags.ttRangeMode ~= nil then tt_rangeMode=win.Flags.ttRangeMode end
        
        -- Extras tab (ported features) + UI settings
        pcall(function() if applyExtrasFromFlags then applyExtrasFromFlags(win.Flags) end end)
        if type(win.Flags.uiFont) == "string" then pcall(applySorshubFont, win.Flags.uiFont) end
        if type(win.Flags.menuKeybind) == "string" then pcall(applySorshubMenuKey, win.Flags.menuKeybind) end
        if type(win.Flags.configImport) == "string" then importStr = cleanConfigString(win.Flags.configImport) end
        if type(win.Flags.reportDraft) == "string" then reportDraft = win.Flags.reportDraft end

        print("[SorsHub] All features restored from config!")
    end)
end

-- Optimisation: the old loop wrote the config file every 2 seconds (up to
-- 1800 disk writes/hour). 15s is plenty for a settings file and cuts I/O ~7x.
task.spawn(function()
    while true do
        task.wait(15)
        pcall(function() if v1prConfig then v1prConfig:Save() end end)
    end
end)

task.spawn(function()
    pcall(function()
        task.wait(1.5)
        pcall(function() safeLoadV1Config() end)
        task.defer(function()
            print("[SorsHub] Syncing flags...")
            if win and win.Flags then applyConfigFromFlags() else print("[SorsHub] win.Flags not yet available") end
        end)
    end)
end)

bootStatus("loaded")
bootDone()
print("[SorsHub] 1.2 loaded successfully")

end, sorsHubTraceback) -- End of main xpcall

-- Error handling
if not success then
    local errMsg = tostring(err)
    bootStatus("ERROR: " .. errMsg:sub(1, 90))
    warn("SorsHub failed to load: " .. errMsg)
    print("SorsHub encountered an error: " .. errMsg)
    flashError(errMsg)
end
