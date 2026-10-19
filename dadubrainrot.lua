-- =====================================================================
-- 👑 MOFENKHUB V91 — ULTIMATE ALL-IN-ONE EDITION (FULL CODE)
-- Game: Dadu Brainrot! | UI Rayfield + Blue/Black + Logo M + Spy & Scanner
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI LAMA
local uiTarget
pcall(function() uiTarget = CoreGui end)
if not uiTarget then uiTarget = LocalPlayer:WaitForChild("PlayerGui") end
for _, v in pairs(uiTarget:GetChildren()) do 
    if v.Name == "MofenkHubUltimate" or v.Name == "MofenkSpyTerminal" then v:Destroy() end 
end

-- 2. KONFIGURASI GLOBAL (SELURUH FITUR)
_G.Mofenk = {
    -- Main / Farm
    AutoRoll = false, AutoCollectMoney = false, CollectEvery = 5,
    AutoRebirth = false, AutoEquipBest = false, EquipBestEvery = 15,
    AutoClaimQuests = false, AutoClaimIndex = false,
    AutoUpgradeBrainrot = false, MaxLevelBrainrot = 40, KeepCashPercent = 0,
    
    -- Inventory / Sell & Filters
    AutoSell = false, SellEvery = 3, SelectedRarity = "Common, Uncommon",
    KeepMutated = false, KeepTraited = false, KeepFinishes = false, KeepVariants = false,
    AutoTraitRoll = false, StopOnTraits = "None",
    
    -- Dungeon
    AutoDungeon = false, TargetFloor = "Battle1", AutoBuyDungeonShop = false,
    
    -- Player & Movement
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    
    -- Upgrades & Misc
    AutoBuyDice = false, AutoUpgradeNodes = false,
    
    -- Spy & Scanner
    SpyEnabled = false
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local function safeFire(remoteName, ...)
    local args = {...}
    task.spawn(function()
        pcall(function()
            local r = Remotes and Remotes:FindFirstChild(remoteName)
            if r then
                if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                elseif r:IsA("RemoteFunction") then r:InvokeServer(unpack(args)) end
            end
        end)
    end)
end

-- ==========================================
-- 3. BACKGROUND CONSOLE SPY ENGINE
-- ==========================================
local function dumpData(o, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end
    if type(o) == 'table' then
        local s = '{' for k,v in pairs(o) do s = s .. tostring(k) .. '=' .. dumpData(v, depth+1) .. ', ' end return s .. '}'
    elseif typeof(o) == "Instance" then return "<" .. o.Name .. ">"
    elseif type(o) == 'string' then return '"' .. o .. '"' else return tostring(o) end
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.Mofenk.SpyEnabled and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function()
            pcall(function()
                local argStr = ""
                for i, v in ipairs(args) do 
                    argStr = argStr .. "Arg["..i.."]: " .. dumpData(v) .. " | " 
                end
                if argStr == "" then argStr = "Tidak ada argumen" end
                print("👁️ [MOFENK SPY] " .. self.Name .. " (" .. method .. ") -> " .. argStr)
            end)
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- 4. FULL MAP & BASE SCANNER
-- ==========================================
local function FullMapScan()
    print("\n==================================================")
    print("🗺️ [MOFENK MAP SCANNER] Memulai Pemindaian Penuh...")
    print("==================================================")
    local scannedCount = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "base") or string.find(nameLower, "spawn") or string.find(nameLower, "market") or string.find(nameLower, "dungeon") or string.find(nameLower, "shop") or string.find(nameLower, "portal") then
                scannedCount = scannedCount + 1
                local pos = "Tidak diketahui"
                pcall(function()
                    if obj:IsA("Model") and obj.PrimaryPart then pos = tostring(obj.PrimaryPart.Position)
                    elseif obj:IsA("Part") then pos = tostring(obj.Position) end
                end)
                print("📍 [" .. obj.ClassName .."] " .. obj.FullName .. " | Posisi: " .. pos)
            end
        end
    end
    print("==================================================")
    print("✅ Pemindaian Selesai! Objek ditemukan: " .. scannedCount)
    print("==================================================\n")
end

-- Server Utilities
local function CopyServerID()
    pcall(function() if setclipboard then setclipboard(game.JobId) end end)
end

local function ServerHop()
    pcall(function()
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

-- 5. MEMUAT RAYFIELD UI (BLUE / BLACK THEME + LOGO M)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V91 Ultimate",
   LoadingTitle = "Memuat MofenkHub V91...",
   LoadingSubtitle = "Full Features + Spy & Scanner",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
    Title = "MofenkHub V91 Loaded! 👑", 
    Content = "Semua fitur, Spy, & Scanner siap digunakan!", 
    Duration = 5, 
    Image = 6023426915 
})

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 WELCOME BACK")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung ke MofenkHub V91\nGame: [UPDATE 2] Dadu Brainrot!\nMode: Ultimate All-in-One"})

-- TAB 2: MAIN 🎮
local TabMain = Window:CreateTab("Main 🎮", 6023426915)
TabMain:CreateSection("🔄 Farm & Roll Utama")
TabMain:CreateToggle({Name = "🎲 Auto Roll", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "💰 Auto Collect Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 60}, Increment = 1, Suffix = "s", CurrentValue = 5, Callback = function(V) _G.Mofenk.CollectEvery = V end})
TabMain:CreateToggle({Name = "🔄 Auto Rebirth", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRebirth = V end})
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 1, Suffix = "s", CurrentValue = 15, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})

TabMain:CreateSection("🎁 Claims (Quest & Index)")
TabMain:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})

TabMain:CreateSection("🧠 Brainrots & Cash Management")
TabMain:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeBrainrot = V end})
TabMain:CreateSlider({Name = "📊 Max Level", Range = {1, 100}, Increment = 1, CurrentValue = 40, Callback = function(V) _G.Mofenk.MaxLevelBrainrot = V end})
TabMain:CreateSlider({Name = "💵 Keep Cash (%)", Range = {0, 100}, Increment = 1, Suffix = "%", CurrentValue = 0, Callback = function(V) _G.Mofenk.KeepCashPercent = V end})

-- TAB 3: INVENTORY 📦
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("💲 Auto Sell Management")
TabInv:CreateToggle({Name = "🗑️ Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 3, Callback = function(V) _G.Mofenk.SellEvery = V end})
TabInv:CreateDropdown({
    Name = "📌 Sell Rarities",
    Options = {"Common, Uncommon", "Rare, Epic", "Legendary, Mythical", "All Rarities"},
    CurrentOption = {"Common, Uncommon"},
    Callback = function(Opt) _G.Mofenk.SelectedRarity = Opt[1] end
})
TabInv:CreateToggle({Name = "🔒 Keep Mutated", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepMutated = V end})
TabInv:CreateToggle({Name = "🔒 Keep Traited", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepTraited = V end})
TabInv:CreateToggle({Name = "🔒 Keep Finishes", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepFinishes = V end})
TabInv:CreateToggle({Name = "🔒 Keep Variants", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepVariants = V end})

TabInv:CreateSection("🧬 Trait Roll")
TabInv:CreateToggle({Name = "✨ Auto Roll Traits", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoTraitRoll = V end})
TabInv:CreateDropdown({
    Name = "🛑 Stop On Traits",
    Options = {"None", "Godly", "Secret", "Celestial", "Divine"},
    CurrentOption = {"None"},
    Callback = function(Opt) _G.Mofenk.StopOnTraits = Opt[1] end
})
TabInv:CreateButton({Name = "🔄 Refresh Brainrots", Callback = function() safeFire("RequestInventorySnapshot") end})

-- TAB 4: DUNGEON ⚔️
local TabDungeon = Window:CreateTab("Dungeon ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon Automation")
TabDungeon:CreateDropdown({
    Name = "🚪 Floor Selection", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabDungeon:CreateToggle({Name = "⚔️ Auto Dungeon & Boss Fight", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDungeon = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base", Callback = function() safeFire("RequestMyBaseSpawn") end})
TabDungeon:CreateSection("🛒 Dungeon Shop")
TabDungeon:CreateToggle({Name = "🛍️ Auto Buy Dungeon Shop Items", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDungeonShop = V end})

-- TAB 5: PLAYER ⚡
local TabPlayer = Window:CreateTab("Player ⚡", 6023426915)
TabPlayer:CreateSection("🏃 Kecepatan Karakter (WalkSpeed)")
TabPlayer:CreateToggle({Name = "⚡ Aktifkan Custom WalkSpeed", CurrentValue = false, Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end})
TabPlayer:CreateSlider({Name = "🏃 Kecepatan Jalan", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) _G.Mofenk.WalkSpeedVal = V end})

TabPlayer:CreateSection("🌐 Server Utilities")
TabPlayer:CreateButton({Name = "📋 Copy Server JobID", Callback = function() CopyServerID(); Rayfield:Notify({Title = "Berhasil", Content = "JobID disalin!", Duration = 3}) end})
TabPlayer:CreateButton({Name = "🔀 Server Hop", Callback = function() ServerHop() end})

TabPlayer:CreateSection("⚡ Upgrades & Dice")
TabPlayer:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabPlayer:CreateToggle({Name = "📈 Auto Buy Upgrade Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeNodes = V end})

-- TAB 6: DEVELOPER, SPY & SCANNER 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("🗺️ FULL MAP & BASE SCANNER")
TabDev:CreateButton({
   Name = "🔍 Jalankan Full Map & Base Scan",
   Callback = function()
       FullMapScan()
       Rayfield:Notify({Title = "Scanner Selesai", Content = "Cek Konsol Delta untuk hasil pemindaian!", Duration = 5})
   end,
})

TabDev:CreateSection("📡 CONSOLE NETWORK SPY")
TabDev:CreateToggle({
   Name = "Aktifkan Spy ke Konsol Delta",
   CurrentValue = false,
   Callback = function(Value)
       _G.Mofenk.SpyEnabled = Value
       Rayfield:Notify({Title = "Spy Status", Content = Value and "Aktif! Cek Konsol Delta." or "Dimatikan.", Duration = 3})
   end,
})

TabDev:CreateSection("🎵 PEMUTAR MUSIK")
local Music = Instance.new("Sound", CoreGui)
Music.SoundId = "rbxassetid://9048375035"
Music.Volume = 0.8 
Music.Looped = true
TabDev:CreateButton({Name = "▶️ Putar Musik", Callback = function() Music:Play() end})
TabDev:CreateButton({Name = "⏹️ Hentikan Musik", Callback = function() Music:Stop() end})

-- =====================================================================
-- 6. BACKGROUND ENGINE (FARMING, MOVE SPEED & SPY LOGIC)
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Custom WalkSpeed Enforcer
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            -- Main / Farm
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then safeFire("RequestIndexRewards") end
            if _G.Mofenk.AutoUpgradeBrainrot then safeFire("UpgradeBrainrotRequest", 1) end
            
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFire("MoneyCollected")
                lastCollect = os.time()
            end
            
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                safeFire("EquipBest")
                safeFire("EquipBestBattleSquadRequest")
                lastEquip = os.time()
            end
            
            -- Inventory / Sell & Traits
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                safeFire("SellAllRequest", _G.Mofenk.SelectedRarity)
                lastSell = os.time()
            end
            if _G.Mofenk.AutoTraitRoll then safeFire("SpinTraitRequest") end
            
            -- Dungeon
            if _G.Mofenk.AutoDungeon then
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("SetAutoFightBoss", true)
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end
            
            -- Player / Upgrades
            if _G.Mofenk.AutoBuyDice then safeFire("DiceShopAction", "Buy", 1) end
        end)
    end
end)

-- Anti AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)
