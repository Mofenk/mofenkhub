-- Grow A Garden (GAG) - Base Architecture & UI by Venxz
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Auto Exec Link Setup
local AUTOEXEC_CODE = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/gag.lua"))()]]

-- Game Load & Client Boot Check
if not game:IsLoaded() then
    local t0 = os.clock()
    while not game:IsLoaded() and os.clock() - t0 < 30 do
        task.wait(0.2)
    end
end

if LocalPlayer == nil then
    local t0 = os.clock()
    while LocalPlayer == nil and os.clock() - t0 < 30 do
        task.wait(0.2)
        pcall(function() LocalPlayer = Players.LocalPlayer end)
    end
end

if LocalPlayer == nil then
    error("[GAG Hub] Client still booting (no LocalPlayer yet). Re-execute in a moment.", 0)
end

-- Double-Run Guard (Heartbeat System)
do
    local blocked = false
    pcall(function()
        if typeof(getgenv) == "function" then
            local h = getgenv().GAG_Heartbeat
            if type(h) == "table" then
                local dt = os.clock() - (tonumber(h.t) or 0)
                if dt >= 0 and dt < 6 and (h.job == nil or h.job == game.JobId) then
                    blocked = true
                end
            end
        end
    end)
    if blocked then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = "GAG Hub", Text = "Already running.", Duration = 4 })
        end)
        warn("[GAG Hub] Already running.")
        return
    end
end

pcall(function()
    if typeof(getgenv) == "function" then
        getgenv().GAG_Heartbeat = { t = os.clock(), job = game.JobId }
    end
end)

local Alive = true
task.spawn(function()
    if typeof(getgenv) ~= "function" then return end
    while Alive do
        pcall(function() getgenv().GAG_Heartbeat = { t = os.clock(), job = game.JobId } end)
        task.wait(2)
    end
    pcall(function()
        if typeof(getgenv) == "function" then getgenv().GAG_Heartbeat = nil end
    end)
end)

-- Robust Rayfield Loader (4 Retries Loop)
local Rayfield
do
    local lastErr
    for attempt = 1, 4 do
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
        end)
        if ok and type(lib) == "table" and type(lib.CreateWindow) == "function" then
            Rayfield = lib
            break
        end
        lastErr = lib
        if attempt < 4 then task.wait(2) end
    end
    if not Rayfield then
        error("[GAG Hub] Rayfield failed to load after 4 tries. Re-execute. Last error: " .. tostring(lastErr))
    end
end

-- Create Window (Preserved Original Icon & Style)
local window = Rayfield:CreateWindow({
    Name = "Grow A Garden | Hub",
    Icon = 106073659711836, -- Logo Interaktif Topbar
    LoadingTitle = "Grow A Garden",
    LoadingSubtitle = "v2.0 | Venxz Base",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "GAG Hub",
        FileName = "GAG Hub",
    },
    KeySystem = false,
})

-- Feature State Flags
local F = {
    afk = true,
    autoReconnect = true,
    autoHop40 = false,
    hopInterval = 2400,
    saveSettings = true,
    autoMinimize = false,
    wsOn = false,
    wsValue = 16,
    flyOn = false,
    flySpeed = 50,
    noclip = false,
    reexec = true,
    fpsOn = false,
    spyHook = false,
}

local U = {}
local CFG_FOLDER = "GAG_Hub"
local CFG_FOLDER_OLD = "GAG_Hub_Old"

local function notify(title, content)
    pcall(function() Rayfield:Notify({ Title = title, Content = content, Duration = 4 }) end)
end

local function existingPath(newPath, oldPath)
    local okE, has = pcall(function() return isfile(newPath) end)
    if okE and has then return newPath end
    local okO, hasO = pcall(function() return isfile(oldPath) end)
    if okO and hasO then return oldPath end
    return nil
end

local function cfgPath() return CFG_FOLDER .. "/config_" .. tostring(LocalPlayer.UserId) .. ".json" end

local function saveNow()
    if typeof(writefile) ~= "function" or typeof(makefolder) ~= "function" then return false end
    pcall(function() makefolder(CFG_FOLDER) end)
    local ok, txt = pcall(function()
        return HttpService:JSONEncode({ v = 1, F = F })
    end)
    if not ok then return false end
    return pcall(function() writefile(cfgPath(), txt) end)
end

-- Custom UI Helpers (makeStat & makeConsole)
local CONSOLE_VIEW_LINES = 12

local function makeStat(tab, cfg)
    local handle = {}
    handle.name = cfg.Name or "Stat"
    handle.icon = tonumber(cfg.Icon) or nil
    handle.value = tonumber(cfg.Value) or 0
    local label = tab:CreateLabel(handle.name .. ": " .. tostring(handle.value), handle.icon)

    function handle:Set(v)
        handle.value = v
        pcall(function() label:Set(handle.name .. ": " .. tostring(handle.value), handle.icon) end)
    end
    return handle
end

local function makeConsole(tab, cfg)
    local handle = {}
    handle.name = cfg.Name or ""
    handle.maxLines = tonumber(cfg.MaxLines) or 60
    handle.lines = {}
    local para = tab:CreateParagraph({ Title = handle.name, Content = tostring(cfg.Text or "") })

    function handle:Append(text)
        table.insert(handle.lines, tostring(text))
        while #handle.lines > handle.maxLines do table.remove(handle.lines, 1) end
        local view, first = {}, math.max(1, #handle.lines - CONSOLE_VIEW_LINES + 1)
        for i = first, #handle.lines do table.insert(view, handle.lines[i]) end
        pcall(function() para:Set({ Title = handle.name, Content = table.concat(view, "\n") }) end)
    end
    return handle
end

-- TAB SETUP
local tDash = window:CreateTab("Dashboard", 93129522258096)
local tSpy = window:CreateTab("Spy Scanner", 137296756955034)
local tServer = window:CreateTab("Server Hop", 72821498911763)
local tSettings = window:CreateTab("Settings", 103326255092488)

-- 1. DASHBOARD TAB
tDash:CreateSection("Profile Dashboard")
tDash:CreateParagraph({
    Title = "Player Info",
    Content = "User: " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")\nUserId: " .. tostring(LocalPlayer.UserId) .. "\nPlaceId: " .. tostring(game.PlaceId)
})

local hopTimerPara = tDash:CreateParagraph({
    Title = "40-Min Auto Hop Status",
    Content = "Status: Disabled"
})

local console = makeConsole(tDash, { Name = "Console Log", MaxLines = 100 })
local function clog(m)
    print("[GAG Hub]", m)
    pcall(function() console:Append(m) end)
end

-- 2. SPY SCANNER TAB
tSpy:CreateSection("Remote Service Scanner")

local function scanAndPrintRemotes()
    clog("--- [ SPY SCANNER STARTED ] ---")
    local count = 0
    local targetServices = { RS, workspace, Players, game:GetService("Lighting") }
    
    for _, svc in ipairs(targetServices) do
        clog("Scanning Service: " .. svc.Name)
        for _, obj in ipairs(svc:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                count = count + 1
                local info = string.format("[%s] -> %s", obj.ClassName, obj:GetFullName())
                print("[DELTA SPY] " .. info)
                clog(info)
            end
        end
    end
    clog("--- [ SCAN FINISHED: " .. count .. " REMOTES FOUND ] ---")
    notify("Spy Scanner", "Found " .. count .. " remotes! Printed to Delta Console.")
end

tSpy:CreateButton({
    Name = "Scan All Services & Print to Delta Console",
    Callback = function() task.spawn(scanAndPrintRemotes) end,
})

tSpy:CreateSection("Hook Remote Calls")
tSpy:CreateToggle({
    Name = "Hook FireServer / InvokeServer",
    CurrentValue = false,
    Callback = function(v)
        F.spyHook = v
        if v then notify("Spy Hook", "Listening to remote calls... Check Delta Console!") end
    end,
})

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if F.spyHook and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            print(string.format("[DELTA SPY CALL] %s:%s() | Args: %s", self:GetFullName(), method, HttpService:JSONEncode(args)))
        end
        return oldNamecall(self, ...)
    end)
end

-- 3. SERVER HOP TAB (LIST & VISITED SYSTEM)
tServer:CreateSection("Server Hop System")

local VISIT_TTL = 1800
local function visitedPath() return CFG_FOLDER .. "/visited_" .. tostring(LocalPlayer.UserId) .. ".json" end

local function loadVisited()
    local t = {}
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return t end
    local path = existingPath(visitedPath(), CFG_FOLDER_OLD .. "/visited_" .. tostring(LocalPlayer.UserId) .. ".json")
    if not path then return t end
    local okR, txt = pcall(readfile, path)
    if not okR then return t end
    local okD, d = pcall(function() return HttpService:JSONDecode(txt) end)
    if not (okD and type(d) == "table") then return t end
    local now = os.time()
    for job, ts in pairs(d) do
        ts = tonumber(ts)
        if type(job) == "string" and ts and now - ts < VISIT_TTL then t[job] = ts end
    end
    return t
end

local function saveVisited(t)
    if typeof(writefile) ~= "function" then return end
    pcall(function() makefolder(CFG_FOLDER) end)
    pcall(function() writefile(visitedPath(), HttpService:JSONEncode(t)) end)
end

local function armReexec()
    if not F.reexec then return end
    local q = queue_on_teleport or queueonteleport
    if typeof(q) == "function" then
        pcall(q, AUTOEXEC_CODE)
    end
end

local function doHop(lowPop)
    task.spawn(function()
        armReexec()
        notify("Server Hop", "Searching public servers list...")
        local visited = loadVisited()
        local cands, cursor, pages = {}, nil, 0
        local order = lowPop and "Asc" or "Desc"

        while pages < 3 do
            local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=" .. order .. "&limit=100&excludeFullGames=true"
            if cursor then url = url .. "&cursor=" .. cursor end
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if not ok then break end
            local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
            if not (ok2 and data and data.data) then break end
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and not visited[s.id] and (tonumber(s.playing) or 0) < (tonumber(s.maxPlayers) or 99) then
                    table.insert(cands, s)
                end
            end
            cursor = data.nextPageCursor
            pages += 1
            if not cursor then break end
        end

        if #cands == 0 then
            notify("Server Hop", "No unvisited server found, hopping random...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
            return
        end

        local target = cands[1]
        visited[target.id] = os.time()
        saveVisited(visited)
        notify("Server Hop", "Teleporting to " .. target.id .. " (" .. target.playing .. " players)...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
    end)
end

tServer:CreateToggle({
    Name = "Auto Server Hop Every 40 Minutes",
    CurrentValue = false,
    Callback = function(v)
        F.autoHop40 = v
        if v then
            F.hopInterval = 2400
            clog("Auto Hop 40-min enabled.")
        else
            hopTimerPara:Set({ Title = "40-Min Auto Hop Status", Content = "Status: Disabled" })
        end
    end,
})

tServer:CreateButton({ Name = "Hop Server Now", Callback = function() doHop(false) end })
tServer:CreateButton({ Name = "Hop Low Player Server", Callback = function() doHop(true) end })
tServer:CreateButton({ Name = "Rejoin Same Server", Callback = function()
    armReexec()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end })

-- Timer Thread 40 Mins
task.spawn(function()
    while Alive do
        task.wait(1)
        if F.autoHop40 then
            F.hopInterval = F.hopInterval - 1
            local m = math.floor(F.hopInterval / 60)
            local s = F.hopInterval % 60
            hopTimerPara:Set({
                Title = "40-Min Auto Hop Status",
                Content = string.format("Next Server Hop in: %02d:%02d", m, s)
            })
            if F.hopInterval <= 0 then
                F.hopInterval = 2400
                doHop(false)
            end
        end
    end
end)

-- 4. ANTI-AFK & AUTO RECONNECT
LocalPlayer.Idled:Connect(function()
    if F.afk then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            clog("Anti-AFK active.")
        end)
    end
end)

GuiService.ErrorMessageChanged:Connect(function()
    if F.autoReconnect then
        local err = GuiService:GetErrorMessage()
        if err and err ~= "" then
            clog("Disconnected (" .. tostring(err) .. "). Auto reconnecting...")
            task.wait(2)
            armReexec()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
end)

-- 5. SETTINGS & CHARACTER TAB
tSettings:CreateSection("Character & Movement")

local function applyWS()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = (F.wsOn and F.wsValue) or 16 end
end

tSettings:CreateToggle({ Name = "WalkSpeed", CurrentValue = false, Callback = function(v) F.wsOn = v applyWS() end })
tSettings:CreateSlider({
    Name = "WalkSpeed Value",
    Range = { 16, 250 },
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) F.wsValue = math.floor(v) applyWS() end,
})

-- Fly Mechanics
local flyGyro, flyVel, flyMoveConn, flyKeys = nil, nil, nil, {}
local function flyStop()
    if flyMoveConn then pcall(function() flyMoveConn:Disconnect() end) flyMoveConn = nil end
    if flyGyro then pcall(function() flyGyro:Destroy() end) flyGyro = nil end
    if flyVel then pcall(function() flyVel:Destroy() end) flyVel = nil end
    table.clear(flyKeys)
end

local function flyStart()
    flyStop()
    local ch = LocalPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyGyro = Instance.new("BodyGyro")
    flyGyro.P = 9000
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp
    flyVel = Instance.new("BodyVelocity")
    flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVel.Velocity = Vector3.zero
    flyVel.Parent = hrp
    flyMoveConn = RunService.RenderStepped:Connect(function()
        if not F.flyOn then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local dir = Vector3.zero
        if flyKeys[Enum.KeyCode.W] then dir += cam.CFrame.LookVector end
        if flyKeys[Enum.KeyCode.S] then dir -= cam.CFrame.LookVector end
        if flyKeys[Enum.KeyCode.A] then dir -= cam.CFrame.RightVector end
        if flyKeys[Enum.KeyCode.D] then dir += cam.CFrame.RightVector end
        if flyKeys[Enum.KeyCode.Space] then dir += Vector3.new(0, 1, 0) end
        if flyKeys[Enum.KeyCode.LeftShift] then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit * F.flySpeed end
        pcall(function()
            flyVel.Velocity = dir
            flyGyro.CFrame = cam.CFrame
        end)
    end)
end

UIS.InputBegan:Connect(function(i, g)
    if g or not F.flyOn then return end
    flyKeys[i.KeyCode] = true
end)
UIS.InputEnded:Connect(function(i) flyKeys[i.KeyCode] = nil end)

tSettings:CreateToggle({
    Name = "Fly (WASD + Space/Shift)",
    CurrentValue = false,
    Callback = function(v)
        F.flyOn = v
        if not v then
            flyStop()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        else
            flyStart()
        end
    end,
})

tSettings:CreateSlider({
    Name = "Fly Speed",
    Range = { 10, 200 },
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) F.flySpeed = v end,
})

-- Noclip & FPS Boost
RunService.Stepped:Connect(function()
    if not F.noclip then return end
    local ch = LocalPlayer.Character
    if ch then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

tSettings:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) F.noclip = v end })
tSettings:CreateToggle({ Name = "Anti-AFK", CurrentValue = true, Callback = function(v) F.afk = v end })
tSettings:CreateToggle({ Name = "Auto Reconnect", CurrentValue = true, Callback = function(v) F.autoReconnect = v end })

-- FPS Boost Toggle
local fpsRestore = {}
local function applyFpsBoost(on)
    if on then
        pcall(function()
            local L = game:GetService("Lighting")
            table.insert(fpsRestore, { o = L, p = "GlobalShadows", v = L.GlobalShadows })
            L.GlobalShadows = false
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
                    table.insert(fpsRestore, { o = o, p = "Enabled", v = o.Enabled })
                    o.Enabled = false
                end
            end
        end)
        notify("Performance", "FPS Boost Activated.")
    else
        for _, r in ipairs(fpsRestore) do pcall(function() r.o[r.p] = r.v end) end
        table.clear(fpsRestore)
        notify("Performance", "FPS Boost Deactivated.")
    end
end

tSettings:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Callback = function(v) F.fpsOn = v applyFpsBoost(v) end,
})

-- 6. RAYFIELD CONFIG PROFILE MANAGER
tSettings:CreateSection("Config Presets System")

local PROFILE_FOLDER = CFG_FOLDER .. "/profiles"
local function profilePath(nm) return PROFILE_FOLDER .. "/" .. nm .. ".json" end

local function saveProfile(nm)
    if typeof(writefile) ~= "function" or typeof(makefolder) ~= "function" then return false end
    pcall(function() makefolder(CFG_FOLDER) end)
    pcall(function() makefolder(PROFILE_FOLDER) end)
    return pcall(function() writefile(profilePath(nm), HttpService:JSONEncode({ v = 1, F = F })) end)
end

local function listProfiles()
    local out = {}
    if typeof(listfiles) ~= "function" or typeof(isfile) ~= "function" then return out end
    local ok, files = pcall(function() return listfiles(PROFILE_FOLDER) end)
    if not (ok and type(files) == "table") then return out end
    for _, f in ipairs(files) do
        local nm = tostring(f):gsub("^.*[/\\]", ""):gsub("%.json$", "")
        if nm ~= "" then table.insert(out, nm) end
    end
    return out
end

local cfgDrop
local cfgSelName = ""
local cfgNameInput = tSettings:CreateInput({
    Name = "Config Name",
    CurrentValue = "",
    PlaceholderText = "e.g. gag-main",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

local function refreshCfgList()
    if not cfgDrop then return end
    local list = listProfiles()
    table.sort(list)
    pcall(function() cfgDrop:Refresh(list) end)
end

cfgDrop = tSettings:CreateDropdown({
    Name = "Saved Configs",
    Options = listProfiles(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(sel)
        cfgSelName = (type(sel) == "table") and (sel[1] or "") or (sel or "")
    end,
})

tSettings:CreateButton({
    Name = "Save New Config",
    Callback = function()
        local nm = cfgNameInput and cfgNameInput.CurrentValue or ""
        if nm == "" then notify("Config", "Enter config name first.") return end
        if saveProfile(nm) then
            notify("Config", "Saved: " .. nm)
            refreshCfgList()
        end
    end,
})

tSettings:CreateButton({
    Name = "Delete Selected Config",
    Callback = function()
        if cfgSelName == "" then return end
        pcall(function() delfile(profilePath(cfgSelName)) end)
        cfgSelName = ""
        refreshCfgList()
        notify("Config", "Deleted config.")
    end,
})

-- Auto-Save Thread
task.spawn(function()
    while Alive do
        task.wait(5)
        if F.saveSettings then pcall(saveNow) end
    end
end)

clog("Grow A Garden Hub Loaded Successfully!")
notify("Grow A Garden", "Hub Started! All original Rayfield UI components restored.")
