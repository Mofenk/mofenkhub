-- =====================================================================
-- 👑 MOFENKHUB V1.0 — ANIME DICE EDITION (FLUENT UI FRAMEWORK)
-- Game: Anime Dice | Fluent UI, Deep Network Spy & Data Scanner Setup
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI LAMA
local uiTarget = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(uiTarget:GetChildren()) do 
    if v.Name == "MofenkHubAnimeDice" or v.Name == "Fluent" or v.Name == "WindUI" or v.Name == "Rayfield" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI GLOBAL MASTER
_G.Mofenk = {
    AutoAFK = true,
    AutoExecute = true,
    AutoReconnect = true,
    
    SpyEnabled = true,
    SpyConsoleLog = true,
    
    AutoRoll = false,
    AutoEquipBest = false,
    AutoRebirth = false,
    AutoSell = false,
    
    EnableFly = false, FlySpeed = 50,
    EnableWalkSpeed = false, WalkSpeedVal = 16
}

-- 3. LOAD FLUENT UI LIBRARY (LINK RILIS RESMI STABIL)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 4. AUTO EXECUTE (QUEUE ON TELEPORT)
local function ApplyQueueOnTeleport()
    if _G.Mofenk.AutoExecute then
        local queueFunc = queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (queue_on_teleport)
        if queueFunc then
            pcall(function()
                queueFunc([[
                    repeat task.wait(1) until game:IsLoaded()
                    print("[MofenkHub] Auto Execute Triggered After Teleport!")
                ]])
            end)
        end
    end
end

-- 5. DATA SCANNER ENGINE 🔍
local function ScanGameRemotes()
    print("\n==========================================")
    print("📡 [ANIME DICE SCANNER] REPLICATEDSTORAGE & GAME REMOTES")
    print("==========================================")
    local count = 0
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            count = count + 1
            print(string.format("[%d] %s (%s) -> Path: %s", count, v.Name, v.ClassName, v:GetFullName()))
        end
    end
    print("==========================================\n")
    Fluent:Notify({
        Title = "Remote Scan Selesai! 📡",
        Content = "Ditemukan " .. count .. " Remote. Hasil lengkap dicetak ke F9 Console!",
        Duration = 5
    })
end

local function ScanInventoryAndStats()
    print("\n==========================================")
    print("📦 [ANIME DICE SCANNER] PLAYER STATS & INVENTORY DATA")
    print("==========================================")
    
    if LocalPlayer:FindFirstChild("leaderstats") then
        print("--- LEADERSTATS ---")
        for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
            print(stat.Name .. " (" .. stat.ClassName .. "): " .. tostring(stat.Value))
        end
    end

    print("--- BACKPACK / TOOLS ---")
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        print("- Tool: " .. item.Name)
    end

    print("--- PLAYERGUI OBJECTS & DATA HOLDERS ---")
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        print("GUI Layer: " .. gui.Name)
    end
    print("==========================================\n")
    Fluent:Notify({
        Title = "Inventory Scan Selesai! 📦",
        Content = "Data Stats & GUI dicetak ke F9 Console!",
        Duration = 5
    })
end

local function ScanWorkspacePrompts()
    print("\n==========================================")
    print("🏗️ [ANIME DICE SCANNER] WORKSPACE PROXIMITY PROMPTS")
    print("==========================================")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
            count = count + 1
            print(string.format("[%d] %s | Parent: %s | Path: %s", count, obj.ClassName, obj.Parent.Name, obj:GetFullName()))
        end
    end
    print("==========================================\n")
    Fluent:Notify({
        Title = "Prompt Scan Selesai! 🏗️",
        Content = "Ditemukan " .. count .. " Interactive Object di Workspace (Cek F9)!",
        Duration = 5
    })
end

-- 6. REAL-TIME NETWORK SPY HOOK (__NAMECALL) 🕵️
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                local argStr = ""
                for i, arg in ipairs(args) do
                    argStr = argStr .. string.format("[%d]: %s (%s) | ", i, tostring(arg), typeof(arg))
                end
                
                local logMessage = string.format("[SPY DETECTED] Remote: %s | Method: %s | Args: %s", self.Name, method, argStr)
                
                if _G.Mofenk.SpyConsoleLog then
                    print(logMessage)
                end
                
                Fluent:Notify({
                    Title = "📡 Remote: " .. self.Name,
                    Content = "Method: " .. method .. "\nArgs: " .. (argStr ~= "" and argStr or "Tanpa Argument"),
                    Duration = 3
                })
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 7. UTILITIES & PLAYER CONTROL
local function ToggleFlySystem(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if state then
        if not hrp:FindFirstChild("MofenkFlyBV") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "MofenkFlyBV"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            task.spawn(function()
                while _G.Mofenk.EnableFly and hrp:FindFirstChild("MofenkFlyBV") do
                    local cam = workspace.CurrentCamera
                    bv.Velocity = cam.CFrame.LookVector * _G.Mofenk.FlySpeed
                    task.wait(0.05)
                end
                if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
            end)
        end
    else
        if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
    end
end

local function CopyServerID()
    pcall(function() if setclipboard then setclipboard(tostring(game.JobId)) end end)
end

local function ServerHop()
    pcall(function()
        ApplyQueueOnTeleport()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in ipairs(req.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then 
                    table.insert(servers, s.id) 
                end
            end
        end
        if #servers > 0 then 
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else 
            TeleportService:Teleport(game.PlaceId, LocalPlayer) 
        end
    end)
end

-- Anti-Disconnect Reconnect
local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true)
if PromptOverlay then
    PromptOverlay.ChildAdded:Connect(function(child)
        if _G.Mofenk.AutoReconnect and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
            ApplyQueueOnTeleport()
            task.wait(2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.Mofenk.AutoAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- 8. FLUENT UI WINDOW & TABS SETUP
local Window = Fluent:CreateWindow({
    Title = "MofenkHub | Anime Dice 🎲",
    SubTitle = "by Mofenk",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Spy = Window:AddTab({ Title = "Spy & Scanner", Icon = "search" }),
    Main = Window:AddTab({ Title = "Main & Farm", Icon = "gamepad-2" }),
    Player = Window:AddTab({ Title = "Player & Utilities", Icon = "user" })
}

-- TAB 1: HOME
Tabs.Home:AddParagraph({
    Title = "Akun & Monitor",
    Content = "Player: " .. LocalPlayer.Name .. "\nGame: Anime Dice\nStatus: Online & Scanning"
})

-- TAB 2: SPY & SCANNER
Tabs.Spy:AddSection("Real-Time Network Spy")
Tabs.Spy:AddToggle("SpyToggle", {
    Title = "Real-Time Remote Spy (Notifikasi Screen)",
    Default = true,
    Callback = function(V) _G.Mofenk.SpyEnabled = V end
})
Tabs.Spy:AddToggle("ConsoleLogToggle", {
    Title = "Cetak Detail Remote ke F9 Console",
    Default = true,
    Callback = function(V) _G.Mofenk.SpyConsoleLog = V end
})

Tabs.Spy:AddSection("Manual Data Scanner")
Tabs.Spy:AddButton({
    Title = "Scan Semua Remote Event & Function",
    Callback = function() ScanGameRemotes() end
})
Tabs.Spy:AddButton({
    Title = "Scan Inventory, Backpack & Stats",
    Callback = function() ScanInventoryAndStats() end
})
Tabs.Spy:AddButton({
    Title = "Scan Interactive ProximityPrompts",
    Callback = function() ScanWorkspacePrompts() end
})

-- TAB 3: MAIN & FARM (FITUR KOSONG)
Tabs.Main:AddSection("Roll Automation")
Tabs.Main:AddToggle("AutoRollToggle", {
    Title = "Auto Roll (Butuh Remote)",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoRoll = V end
})

Tabs.Main:AddSection("Inventory Automation")
Tabs.Main:AddToggle("AutoEquipToggle", {
    Title = "Auto Equip Best (Butuh Remote)",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoEquipBest = V end
})
Tabs.Main:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth (Butuh Remote)",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoRebirth = V end
})
Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell (Butuh Remote)",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoSell = V end
})

-- TAB 4: PLAYER & UTILITIES
Tabs.Player:AddSection("Protection & Automation")
Tabs.Player:AddToggle("AutoAFKToggle", {
    Title = "Auto AFK (Anti Idle Disconnect)",
    Default = true,
    Callback = function(V) _G.Mofenk.AutoAFK = V end
})
Tabs.Player:AddToggle("AutoExecToggle", {
    Title = "Auto Execute (Queue On Teleport)",
    Default = true,
    Callback = function(V) _G.Mofenk.AutoExecute = V end
})
Tabs.Player:AddToggle("AutoReconnToggle", {
    Title = "Auto Reconnect (Anti DC)",
    Default = true,
    Callback = function(V) _G.Mofenk.AutoReconnect = V end
})

Tabs.Player:AddSection("Movement")
Tabs.Player:AddToggle("FlyToggle", {
    Title = "Aktifkan Fly",
    Default = false,
    Callback = function(V) 
        _G.Mofenk.EnableFly = V 
        ToggleFlySystem(V)
    end
})
Tabs.Player:AddSlider("FlySpeedSlider", {
    Title = "Kecepatan Fly",
    Min = 20,
    Max = 200,
    Default = 50,
    Rounding = 0,
    Callback = function(V) _G.Mofenk.FlySpeed = V end
})
Tabs.Player:AddToggle("WalkSpeedToggle", {
    Title = "Aktifkan Custom WalkSpeed",
    Default = false,
    Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end
})
Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0,
    Callback = function(V) _G.Mofenk.WalkSpeedVal = V end
})

Tabs.Player:AddSection("Server Utilities")
Tabs.Player:AddButton({
    Title = "Copy Server JobID",
    Callback = function() 
        CopyServerID()
        Fluent:Notify({ Title = "Berhasil Disalin! ✅", Content = "Job ID disalin ke clipboard.", Duration = 3 })
    end
})
Tabs.Player:AddButton({
    Title = "Server Hop",
    Callback = function() ServerHop() end
})

-- 9. BACKGROUND MAIN LOOP ENGINE
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            if _G.Mofenk.AutoRoll then
                -- Isi fungsi FireServer Auto Roll di sini nanti
            end
            
            if _G.Mofenk.AutoEquipBest then
                -- Isi fungsi FireServer Equip Best di sini nanti
            end
            
            if _G.Mofenk.AutoRebirth then
                -- Isi fungsi FireServer Rebirth di sini nanti
            end
        end)
    end
end)
