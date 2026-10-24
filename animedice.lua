-- =====================================================================
-- 👑 MOFENKHUB V1.0 — ANIME DICE EDITION (WINDUI FRAMEWORK)
-- Game: Anime Dice | WindUI, Deep Network Spy, Remote Scanner & Clean Setup
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
    if v.Name == "MofenkHubAnimeDice" or v.Name == "WindUI" or v.Name == "MofenkSpyTerminal" or v.Name == "Rayfield" then 
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

-- LOAD WINDUI LIBRARY (AUTO FALLBACK LINK)
local WindUI
local success = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/FootGes/WindUI/main/Source.lua"))()
end)

if not success or not WindUI then
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/FootGes/WindUI/main/main.lua"))()
end

-- ==========================================
-- 3. AUTO EXECUTE (QUEUE ON TELEPORT)
-- ==========================================
local function ApplyQueueOnTeleport()
    if _G.Mofenk.AutoExecute then
        local queueFunc = queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (queue_on_teleport)
        if queueFunc then
            pcall(function()
                queueFunc([[
                    repeat task.wait(1) until game:IsLoaded()
                    print("[MofenkHub] Auto Execute Triggered After Teleport (WindUI Anime Dice)!")
                ]])
            end)
        end
    end
end

-- ==========================================
-- 4. ALL-IN-ONE DATA SCANNER ENGINE 🔍
-- ==========================================
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
    WindUI:Notify({
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
    WindUI:Notify({
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
    WindUI:Notify({
        Title = "Prompt Scan Selesai! 🏗️",
        Content = "Ditemukan " .. count .. " Interactive Object di Workspace (Cek F9)!",
        Duration = 5
    })
end

-- ==========================================
-- 5. REAL-TIME NETWORK SPY HOOK (__NAMECALL) 🕵️
-- ==========================================
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
                
                WindUI:Notify({
                    Title = "📡 Remote: " .. self.Name,
                    Content = "Method: " .. method .. "\nArgs: " .. (argStr ~= "" and argStr or "Tanpa Argument"),
                    Duration = 3
                })
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- ==========================================
-- 6. UTILITIES & PLAYER CONTROL
-- ==========================================
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

-- ==========================================
-- 7. WINDUI SETUP
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "MofenkHub | Anime Dice 🎲",
    Icon = "dice",
    Author = "Mofenk",
    Folder = "MofenkAnimeDice",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark"
})

WindUI:Notify({ 
    Title = "MofenkHub Ready! 🎲", 
    Content = "WindUI & Modul Spy Scanner Siap Digunakan!", 
    Duration = 5 
})

-- TAB 1: HOME
local TabHome = Window:Tab({ Title = "Home", Icon = "house" })
TabHome:Section({ Title = "Akun & Monitor" })
TabHome:Paragraph({
    Title = LocalPlayer.Name, 
    Desc = "Game: Anime Dice\nStatus: Online & Scanning"
})

-- TAB 2: SPY & SCANNER
local TabSpy = Window:Tab({ Title = "Spy & Scanner", Icon = "search" })
TabSpy:Section({ Title = "Real-Time Network Spy" })
TabSpy:Toggle({
    Title = "Real-Time Remote Spy (Notifikasi Screen)", 
    Value = true, 
    Callback = function(V) _G.Mofenk.SpyEnabled = V end
})
TabSpy:Toggle({
    Title = "Cetak Detail Remote ke F9 Console", 
    Value = true, 
    Callback = function(V) _G.Mofenk.SpyConsoleLog = V end
})

TabSpy:Section({ Title = "Manual Data Scanner" })
TabSpy:Button({
    Title = "Scan Semua Remote Event & Function", 
    Callback = function() ScanGameRemotes() end
})
TabSpy:Button({
    Title = "Scan Inventory, Backpack & Stats", 
    Callback = function() ScanInventoryAndStats() end
})
TabSpy:Button({
    Title = "Scan Interactive ProximityPrompts", 
    Callback = function() ScanWorkspacePrompts() end
})

-- TAB 3: MAIN & FARM (FITUR KOSONG)
local TabMain = Window:Tab({ Title = "Main & Farm", Icon = "gamepad-2" })
TabMain:Section({ Title = "Roll Automation" })
TabMain:Toggle({
    Title = "Auto Roll (Butuh Remote)", 
    Value = false, 
    Callback = function(V) _G.Mofenk.AutoRoll = V end
})

TabMain:Section({ Title = "Inventory Automation" })
TabMain:Toggle({
    Title = "Auto Equip Best (Butuh Remote)", 
    Value = false, 
    Callback = function(V) _G.Mofenk.AutoEquipBest = V end
})
TabMain:Toggle({
    Title = "Auto Rebirth (Butuh Remote)", 
    Value = false, 
    Callback = function(V) _G.Mofenk.AutoRebirth = V end
})
TabMain:Toggle({
    Title = "Auto Sell (Butuh Remote)", 
    Value = false, 
    Callback = function(V) _G.Mofenk.AutoSell = V end
})

-- TAB 4: PLAYER & UTILITIES
local TabPlayer = Window:Tab({ Title = "Player & Utilities", Icon = "user" })
TabPlayer:Section({ Title = "Protection & Automation" })
TabPlayer:Toggle({
    Title = "Auto AFK (Anti Idle Disconnect)", 
    Value = true, 
    Callback = function(V) _G.Mofenk.AutoAFK = V end
})
TabPlayer:Toggle({
    Title = "Auto Execute (Queue On Teleport)", 
    Value = true, 
    Callback = function(V) _G.Mofenk.AutoExecute = V end
})
TabPlayer:Toggle({
    Title = "Auto Reconnect (Anti DC)", 
    Value = true, 
    Callback = function(V) _G.Mofenk.AutoReconnect = V end
})

TabPlayer:Section({ Title = "Movement" })
TabPlayer:Toggle({
    Title = "Aktifkan Fly", 
    Value = false, 
    Callback = function(V) 
        _G.Mofenk.EnableFly = V 
        ToggleFlySystem(V)
    end
})
TabPlayer:Slider({
    Title = "Kecepatan Fly", 
    Min = 20, 
    Max = 200, 
    Default = 50, 
    Callback = function(V) _G.Mofenk.FlySpeed = V end
})
TabPlayer:Toggle({
    Title = "Aktifkan Custom WalkSpeed", 
    Value = false, 
    Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end
})
TabPlayer:Slider({
    Title = "WalkSpeed", 
    Min = 16, 
    Max = 200, 
    Default = 16, 
    Callback = function(V) _G.Mofenk.WalkSpeedVal = V end
})

TabPlayer:Section({ Title = "Server Utilities" })
TabPlayer:Button({
    Title = "Copy Server JobID", 
    Callback = function() 
        CopyServerID()
        WindUI:Notify({ Title = "Berhasil Disalin! ✅", Content = "Job ID disalin ke clipboard.", Duration = 3 })
    end
})
TabPlayer:Button({
    Title = "Server Hop", 
    Callback = function() 
        ServerHop() 
    end
})

-- ==========================================
-- 8. BACKGROUND MAIN LOOP ENGINE
-- ==========================================
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
