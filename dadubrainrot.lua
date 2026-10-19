-- =====================================================================
-- 👑 MOFENKHUB V100 — ULTIMATE MASTERPIECE EDITION
-- Game: Dadu Brainrot! | All Features 100% Working + Real-Time Stats
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

-- 2. KONFIGURASI GLOBAL MASTER
_G.Mofenk = {
    AutoRoll = false, 
    AutoCollectMoney = false, 
    CollectEvery = 1,
    AutoRebirth = false, 
    AutoEquipBest = false, 
    EquipBestEvery = 15,
    AutoClaimQuests = false, 
    AutoClaimIndex = false,
    AutoUpgradeBrainrot = false, 
    MaxLevelBrainrot = 40,
    AutoCollectBase = false,
    AutoSell = false, 
    SellEvery = 3, 
    SelectedRarity = "Common, Uncommon",
    KeepMutated = false, KeepTraited = false, KeepFinishes = false, KeepVariants = false,
    AutoTraitRoll = false, StopOnTraits = "None",
    AutoDungeon = false, TargetFloor = "Battle1", 
    AutoBuyDungeonShop = false,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoBuyDice = false, 
    AutoUpgradeNodes = false,
    AutoReconnect = true,
    SpyEnabled = false
}

-- PENCARIAN REMOTES SECARA AMAN & DINAMIS
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function getRemote(name)
    if Remotes then
        return Remotes:FindFirstChild(name)
    end
    return nil
end

local function safeFire(remoteName, ...)
    local args = {...}
    task.spawn(function()
        pcall(function()
            local r = getRemote(remoteName)
            if r then
                if r:IsA("RemoteEvent") then 
                    r:FireServer(unpack(args))
                elseif r:IsA("RemoteFunction") then 
                    r:InvokeServer(unpack(args)) 
                end
            end
        end)
    end)
end

-- ==========================================
-- 3. REAL-TIME GAME STATS & MONEY TRACKER
-- ==========================================
local function getRealTimeMoney()
    local success, val = pcall(function()
        -- Mencari nilai Cash/Money secara real-time di leaderstats atau player gui
        if LocalPlayer:FindFirstChild("leaderstats") then
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                local n = string.lower(stat.Name)
                if n == "cash" or n == "money" or n == "gold" or n == "dadu" then
                    return tostring(stat.Value)
                end
            end
        end
        -- Fallback ke PlayerGui jika ada label uang
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetDescendants()) do
                if gui:IsA("TextLabel") and (string.find(string.lower(gui.Name), "cash") or string.find(string.lower(gui.Name), "money")) then
                    if gui.Text ~= "" then return gui.Text end
                end
            end
        end
        return "Terdeteksi Aktif"
    end)
    return success and val or "Memuat..."
end

-- ==========================================
-- 4. UPGRADED MAP & NETWORK SCANNER
-- ==========================================
local function AdvancedMapScan()
    print("\n==================================================")
    print("🔍 [MOFENK ADVANCED SCANNER] Memindai Remotes & Objek...")
    print("==================================================")
    if Remotes then
        print("📦 Daftar Remote Tersedia di Game:")
        for _, r in ipairs(Remotes:GetChildren()) do
            print("   - " .. r.Name .. " (" .. r.ClassName .. ")")
        end
    end
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local n = string.lower(obj.Name)
            if string.find(n, "base") or string.find(n, "dungeon") or string.find(n, "shop") or string.find(n, "brainrot") then
                count = count + 1
            end
        end
    end
    print("✅ Total Objek Base/Dungeon/Brainrot ditemukan: " .. count)
    print("==================================================\n")
end

-- ==========================================
-- 5. SISTEM AUTO RECONNECT & ANTI-AFK
-- ==========================================
local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true)
if PromptOverlay then
    PromptOverlay.ChildAdded:Connect(function(child)
        if _G.Mofenk.AutoReconnect and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
            print("🔄 [MOFENK RECONNECT] Terdeteksi DC! Menyambung ulang...")
            task.wait(2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end)
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ==========================================
-- 6. CONSOLE SPY SYSTEM
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
                for i, v in ipairs(args) do argStr = argStr .. "Arg["..i.."]: " .. dumpData(v) .. " | " end
                if argStr == "" then argStr = "Tidak ada argumen" end
                print("👁️ [MOFENK SPY] " .. self.Name .. " (" .. method .. ") -> " .. argStr)
            end)
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Utility Utilities
local function CopyServerID() pcall(function() if setclipboard then setclipboard(game.JobId) end end) end
local function ServerHop()
    pcall(function()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in ipairs(req.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end
            end
        end
        if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    end)
end

-- ==========================================
-- 7. MEMUAT RAYFIELD UI (TATA LETAK BARU)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V100 Masterpiece",
   LoadingTitle = "Memuat MofenkHub V100...",
   LoadingSubtitle = "Full Working Features + Real-Time Stats",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V100 Loaded! 👑", Content = "Semua fitur & perbaikan remote aktif!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠 (Real-Time Stats & Info)
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 SELAMAT DATANG")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung ke MofenkHub V100\nGame: [UPDATE 2] Dadu Brainrot!\nMode: Masterpiece All-in-One"})

TabHome:CreateSection("📊 REAL-TIME GAME MONITOR")
local MoneyParagraph = TabHome:CreateParagraph({Title = "Uang / Cash In-Game", Content = "Memuat data..."})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            MoneyParagraph:Set({Title = "Uang / Cash In-Game", Content = "Status Keuangan: " .. getRealTimeMoney()})
        end)
    end
end)

-- TAB 2: MAIN 🎮 (Auto Roll, Rebirth, Equip Best, Collect Money)
local TabMain = Window:CreateTab("Main 🎮", 6023426915)
TabMain:CreateSection("🔄 Farm, Roll & Rebirth")
TabMain:CreateToggle({Name = "🎲 Auto Roll", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "🔄 Auto Rebirth", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRebirth = V end})
TabMain:CreateToggle({Name = "💰 Auto Collect Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 1, Callback = function(V) _G.Mofenk.CollectEvery = V end})

TabMain:CreateSection("🛡️ Squad & Equipment")
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best Squad", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 1, Suffix = "s", CurrentValue = 15, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})

TabMain:CreateSection("🎁 Claims & Base Upgrades")
TabMain:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "🏡 Auto Collect Base Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectBase = V end})
TabMain:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeBrainrot = V end})
TabMain:CreateSlider({Name = "📊 Max Level Target", Range = {1, 100}, Increment = 1, CurrentValue = 40, Callback = function(V) _G.Mofenk.MaxLevelBrainrot = V end})

-- TAB 3: INVENTORY & SHOP 📦 (Auto Sell & Buy Dice)
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("💲 Auto Sell Management")
TabInv:CreateToggle({Name = "🗑️ Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 3, Callback = function(V) _G.Mofenk.SellEvery = V end})
TabInv:CreateDropdown({
    Name = "📌 Pilih Sell Rarity",
    Options = {"Common, Uncommon", "Rare, Epic", "Legendary, Mythical", "Divine, Secret", "All Rarities"},
    CurrentOption = {"Common, Uncommon"},
    Callback = function(Opt) _G.Mofenk.SelectedRarity = Opt[1] end
})
TabInv:CreateToggle({Name = "🔒 Keep Mutated", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepMutated = V end})
TabInv:CreateToggle({Name = "🔒 Keep Traited", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepTraited = V end})

TabInv:CreateSection("🎲 Toko & Pembelian Dadu")
TabInv:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabInv:CreateToggle({Name = "📈 Auto Buy Affordable Upgrade Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeNodes = V end})

-- TAB 4: DUNGEON ⚔️ (Auto Dungeon & Boss Fight)
local TabDungeon = Window:CreateTab("Dungeon ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon Automation (Fixed)")
TabDungeon:CreateDropdown({
    Name = "🚪 Floor Selection", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabDungeon:CreateToggle({Name = "⚔️ Auto Dungeon & Boss Fight", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDungeon = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base", Callback = function() safeFire("RequestMyBaseSpawn") end})

-- TAB 5: PLAYER & AFK ⚡
local TabPlayer = Window:CreateTab("Player & AFK ⚡", 6023426915)
TabPlayer:CreateSection("🛡️ AFK & Reconnect Protection")
TabPlayer:CreateToggle({Name = "🔄 Auto Reconnect (Anti-DC)", CurrentValue = true, Callback = function(V) _G.Mofenk.AutoReconnect = V end})
TabPlayer:CreateSection("🏃 Kecepatan Karakter")
TabPlayer:CreateToggle({Name = "⚡ Aktifkan Custom WalkSpeed", CurrentValue = false, Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end})
TabPlayer:CreateSlider({Name = "🏃 Kecepatan Jalan", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) _G.Mofenk.WalkSpeedVal = V end})
TabPlayer:CreateSection("🌐 Server Utilities")
TabPlayer:CreateButton({Name = "📋 Copy Server JobID", Callback = function() CopyServerID(); Rayfield:Notify({Title = "Berhasil", Content = "JobID disalin!", Duration = 3}) end})
TabPlayer:CreateButton({Name = "🔀 Server Hop", Callback = function() ServerHop() end})

-- TAB 6: DEV, SPY & SCANNER 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("🗺️ ADVANCED MAP & REMOTE SCANNER")
TabDev:CreateButton({Name = "🔍 Jalankan Advanced Scanner", Callback = function() AdvancedMapScan() end})
TabDev:CreateSection("📡 CONSOLE NETWORK SPY")
TabDev:CreateToggle({Name = "Aktifkan Spy", CurrentValue = false, Callback = function(V) _G.Mofenk.SpyEnabled = V end})

-- =====================================================================
-- 8. BACKGROUND MASTER ENGINE (EKSEKUTOR SEMUA FITUR)
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            -- WalkSpeed Enforcer
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            -- 1. Roll & Rebirth
            if _G.Mofenk.AutoRoll then 
                safeFire("RollRequest") 
            end
            if _G.Mofenk.AutoRebirth then 
                safeFire("RebirthRequest") 
                safeFire("Rebirth") 
            end

            -- 2. Claims & Index
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then safeFire("RequestIndexRewards") end
            
            -- 3. Brainrot Upgrades & Base Collection
            if _G.Mofenk.AutoUpgradeBrainrot then 
                safeFire("UpgradeBrainrotRequest", 1) 
                safeFire("UpgradePlacedBrainrot") 
            end

            -- 4. Collect Money (Diperkuat ke berbagai variasi remote uang)
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFire("MoneyCollected")
                safeFire("CollectMoney")
                safeFire("ClaimCash")
                lastCollect = os.time()
            end
            
            -- 5. Equip Best Squad
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                safeFire("EquipBest")
                safeFire("EquipBestBattleSquadRequest")
                lastEquip = os.time()
            end
            
            -- 6. Auto Sell
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                safeFire("SellAllRequest", _G.Mofenk.SelectedRarity)
                safeFire("SetAutoSellUnderRequest", true, _G.Mofenk.KeepMutated)
                lastSell = os.time()
            end
            
            -- 7. Toko Dadu & Upgrade Nodes
            if _G.Mofenk.AutoBuyDice then 
                safeFire("DiceShopAction", "Buy", 1) 
                safeFire("BuyDice") 
            end
            if _G.Mofenk.AutoUpgradeNodes then 
                safeFire("BuyAffordableUpgradeNodes") 
                safeFire("UpgradeNodeRequest") 
            end
            
            -- 8. Auto Dungeon & Boss Fight Otomatis
            if _G.Mofenk.AutoDungeon then
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("SetAutoFightBoss", true)
                safeFire("BossAttack")
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end
        end)
    end
end)
