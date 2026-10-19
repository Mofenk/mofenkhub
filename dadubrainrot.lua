-- =====================================================================
-- 👑 MOFENKHUB V122 — FULL DEBUG & ERROR CONSOLE INSPECTOR EDITION
-- Game: Dadu Brainrot! | Smart Error Logging & Feature Inspector
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
    if v.Name == "MofenkHubUltimate" or v.Name == "MofenkSpyTerminal" or v.Name == "Rayfield" then 
        pcall(function() v:Destroy() end) 
    end 
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
    AutoCollectBase = false,
    AutoClaimMeteor = false,
    -- Full 19 Rarities Checklist Sell Config
    AutoSell = false, 
    SellEvery = 4, 
    SellCommon = false,
    SellUncommon = false,
    SellRare = false,
    SellEpic = false,
    SellLegendary = false,
    SellMythical = false,
    SellAncient = false,
    SellDivine = false,
    SellCelestial = false,
    SellEthereal = false,
    SellAstral = false,
    SellCosmic = false,
    SellTranscendent = false,
    SellEternal = false,
    SellPrimordial = false,
    SellOmniversal = false,
    SellInfinite = false,
    SellSupreme = false,
    SellSecret = false,
    KeepMutated = false,
    KeepTraited = false,
    -- Unified Dungeon & Gateway Group
    AutoDungeonGroup = false, 
    TargetFloor = "Battle1", 
    AutoDragonGate = false,
    -- Automation Extras
    AutoFuse = false,
    AutoWheelSpin = false,
    AutoClaimBossMilestones = false,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoBuyDice = false, 
    AutoUpgradeNodes = false,
    AutoReconnect = true,
    SpyEnabled = true -- Default aktif untuk menangkap error
}

-- PENCARIAN REMOTES AMAN DENGAN DEBUGGER ERROR
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function getRemote(name)
    if Remotes then
        return Remotes:FindFirstChild(name)
    end
    return nil
end

local function safeFireDebug(featureName, remoteName, ...)
    local args = {...}
    task.spawn(function()
        local success, err = pcall(function()
            local r = getRemote(remoteName)
            if not r then
                error("Remote '" .. remoteName .. "' TIDAK DITEMUKAN di ReplicatedStorage.Remotes!")
            end
            if r:IsA("RemoteEvent") then 
                r:FireServer(unpack(args))
            elseif r:IsA("RemoteFunction") then 
                r:InvokeServer(unpack(args)) 
            else
                error("Objek '" .. remoteName .. "' bukan RemoteEvent atau RemoteFunction!")
            end
        end)
        
        if not success and _G.Mofenk.SpyEnabled then
            warn("❌ [MOFENK ERROR DEBUG] Fitur [" .. featureName .. "] Gagal pada Remote '" .. tostring(remoteName) .. "'!")
            warn("   -> Alasan Error: " .. tostring(err))
        end
    end)
end

-- ==========================================
-- 3. FUNGSI EKSEKUSI UTAMA DENGAN DEBUG LOG
-- ==========================================
local function TriggerBaseCollection()
    pcall(function()
        safeFireDebug("Auto Collect Base", "MoneyCollected")
        safeFireDebug("Auto Collect Base", "CollectMoney")
        safeFireDebug("Auto Collect Base", "ClaimCash")
        local foundPrompt = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "base") or string.find(pName, "cash") or string.find(pName, "money") or string.find(pName, "collect") then
                    fireproximityprompt(obj)
                    foundPrompt = true
                end
            end
        end
        if not foundPrompt and _G.Mofenk.AutoCollectBase then
            -- Tidak perlu warning berlebih untuk prompt fisik jika tidak ada di dekat player
        end
    end)
end

local function TriggerMeteorClaim()
    pcall(function()
        safeFireDebug("Auto Claim Meteor", "MeteorClaimed")
        safeFireDebug("Auto Claim Meteor", "ClaimMeteor")
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            if string.find(name, "meteor") and obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj)
            end
        end
    end)
end

local function TriggerBrainrotUpgrades()
    pcall(function()
        for i = 1, 25 do
            safeFireDebug("Auto Upgrade Brainrot", "UpgradeBrainrotRequest", i)
            safeFireDebug("Auto Upgrade Brainrot", "UpgradePlacedBrainrot", i)
            safeFireDebug("Auto Upgrade Brainrot", "MultiRollUpgradeRequest")
        end
    end)
end

local function TriggerUniversalIndexClaims()
    pcall(function()
        safeFireDebug("Auto Claim Index", "RequestIndexRewards")
        local prefixes = {"Finish_", "Tier_", "Index_", "Reward_"}
        local types = {"Galactic", "Prismatic", "Aurora", "Cosmic", "Divine", "Secret", "Legendary", "Mythical"}
        for _, p in ipairs(prefixes) do
            for _, t in ipairs(types) do
                safeFireDebug("Auto Claim Index", "ClaimIndexReward", p .. t)
            end
        end
    end)
end

local function ExecuteAccurateSell()
    pcall(function()
        safeFireDebug("Auto Sell", "RequestInventorySnapshot")
        safeFireDebug("Auto Sell", "RequestItemsSnapshot")
        
        local raritiesToSell = {}
        if _G.Mofenk.SellCommon then table.insert(raritiesToSell, "Common") end
        if _G.Mofenk.SellUncommon then table.insert(raritiesToSell, "Uncommon") end
        if _G.Mofenk.SellRare then table.insert(raritiesToSell, "Rare") end
        if _G.Mofenk.SellEpic then table.insert(raritiesToSell, "Epic") end
        if _G.Mofenk.SellLegendary then table.insert(raritiesToSell, "Legendary") end
        if _G.Mofenk.SellMythical then table.insert(raritiesToSell, "Mythical") end
        if _G.Mofenk.SellAncient then table.insert(raritiesToSell, "Ancient") end
        if _G.Mofenk.SellDivine then table.insert(raritiesToSell, "Divine") end
        if _G.Mofenk.SellCelestial then table.insert(raritiesToSell, "Celestial") end
        if _G.Mofenk.SellEthereal then table.insert(raritiesToSell, "Ethereal") end
        if _G.Mofenk.SellAstral then table.insert(raritiesToSell, "Astral") end
        if _G.Mofenk.SellCosmic then table.insert(raritiesToSell, "Cosmic") end
        if _G.Mofenk.SellTranscendent then table.insert(raritiesToSell, "Transcendent") end
        if _G.Mofenk.SellEternal then table.insert(raritiesToSell, "Eternal") end
        if _G.Mofenk.SellPrimordial then table.insert(raritiesToSell, "Primordial") end
        if _G.Mofenk.SellOmniversal then table.insert(raritiesToSell, "Omniversal") end
        if _G.Mofenk.SellInfinite then table.insert(raritiesToSell, "Infinite") end
        if _G.Mofenk.SellSupreme then table.insert(raritiesToSell, "Supreme") end
        if _G.Mofenk.SellSecret then table.insert(raritiesToSell, "Secret") end

        if #raritiesToSell > 0 then
            for _, rarity in ipairs(raritiesToSell) do
                safeFireDebug("Auto Sell", "SellAllRequest", rarity)
                safeFireDebug("Auto Sell", "SellSelectedRequest", rarity)
                safeFireDebug("Auto Sell", "SellItemRequest", rarity)
            end
        end
        safeFireDebug("Auto Sell", "SetAutoSellUnderRequest", true, _G.Mofenk.KeepMutated)
    end)
end

-- ==========================================
-- 4. CONSOLE NETWORK SPY & MAP SCANNER
-- ==========================================
local function AdvancedMapScan()
    print("\n==================================================")
    print("🔍 [MOFENK SPY SCANNER] Memindai Semua Remote Game...")
    print("==================================================")
    if Remotes then
        for _, r in ipairs(Remotes:GetChildren()) do
            print("   - " .. r.Name .. " (" .. r.ClassName .. ")")
        end
    end
    print("==================================================\n")
end

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
                print("👁️ [MOFENK SPY] " .. self.Name .. " (" .. method .. ") -> " .. argStr)
            end)
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- 5. UTILITY SERVER & PROFIL
-- ==========================================
local function CopyServerID()
    pcall(function()
        if setclipboard then setclipboard(tostring(game.JobId)) end
    end)
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

local function GetCharacterProfileInfo()
    local info = "Akun: " .. LocalPlayer.Name .. " (ID: " .. tostring(LocalPlayer.UserId) .. ")\n"
    pcall(function()
        if LocalPlayer:FindFirstChild("leaderstats") then
            info = info + "--- Stats ---\n"
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                info = info .. stat.Name .. ": " .. tostring(stat.Value) .. "\n"
            end
        end
    end)
    return info
end

local function getRealTimeMoney()
    local success, val = pcall(function()
        if LocalPlayer:FindFirstChild("leaderstats") then
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                local n = string.lower(stat.Name)
                if n == "cash" or n == "money" or n == "gold" or n == "dadu" then
                    return tostring(stat.Value)
                end
            end
        end
        return "Terdeteksi Aktif"
    end)
    return success and val or "Memuat..."
end

-- ==========================================
-- 6. ANTI-DC & ANTI-AFK
-- ==========================================
local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true)
if PromptOverlay then
    PromptOverlay.ChildAdded:Connect(function(child)
        if _G.Mofenk.AutoReconnect and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
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
-- 7. UI RAYFIELD (V122 DEBUG & ERROR INSPECTOR)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V122 Debug Inspector",
   LoadingTitle = "Memuat MofenkHub V122...",
   LoadingSubtitle = "Error Console Inspector & Debug Synced",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V122 Loaded! 👑", Content = "Error Debugger Console Aktif!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 PROFIL & MONITOR")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung (V122 Debugger)\nGame: [UPDATE 2] Dadu Brainrot!"})

local ProfileParagraph = TabHome:CreateParagraph({Title = "📋 Profil Karakter", Content = "Memuat data..."})
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            ProfileParagraph:Set({Title = "📋 Profil Karakter (" .. LocalPlayer.Name .. ")", Content = GetCharacterProfileInfo()})
        end)
    end
end)

local MoneyParagraph = TabHome:CreateParagraph({Title = "Uang / Cash In-Game", Content = "Memuat..."})
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            MoneyParagraph:Set({Title = "Uang / Cash In-Game", Content = "Status: " .. getRealTimeMoney()})
        end)
    end
end)

-- TAB 2: MAIN 🎮
local TabMain = Window:CreateTab("Main 🎮", 6023426915)
TabMain:CreateSection("🔄 Farm & Roll Utama")
TabMain:CreateToggle({Name = "🎲 Auto Roll", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "🔄 Auto Rebirth", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRebirth = V end})
TabMain:CreateToggle({Name = "💰 Auto Collect Money (Global)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 1, Callback = function(V) _G.Mofenk.CollectEvery = V end})

TabMain:CreateSection("🛡️ Squad & Klaim Otomatis")
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best Squad", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards (Universal)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "🏆 Auto Claim Boss Milestones", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimBossMilestones = V end})
TabMain:CreateToggle({Name = "☄️ Auto Claim Meteor", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimMeteor = V end})
TabMain:CreateToggle({Name = "🎡 Auto Spin Wheel", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoWheelSpin = V end})
TabMain:CreateToggle({Name = "🧪 Auto Fuse Items/Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoFuse = V end})

TabMain:CreateSection("🏡 Base & Brainrot Upgrades")
TabMain:CreateToggle({Name = "🏡 Auto Collect Base Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectBase = V end})
TabMain:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeBrainrot = V end})

-- TAB 3: INVENTORY & 19-RARITY CHECKLIST SELL 📦
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("💲 Smart Auto Sell (Full 19 Rarities)")
TabInv:CreateToggle({Name = "🗑️ Aktifkan Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 4, Callback = function(V) _G.Mofenk.SellEvery = V end})

TabInv:CreateSection("☑️ Ceklis Rarity (Tier 1)")
TabInv:CreateToggle({Name = "Jual Common", CurrentValue = false, Callback = function(V) _G.Mofenk.SellCommon = V end})
TabInv:CreateToggle({Name = "Jual Uncommon", CurrentValue = false, Callback = function(V) _G.Mofenk.SellUncommon = V end})
TabInv:CreateToggle({Name = "Jual Rare", CurrentValue = false, Callback = function(V) _G.Mofenk.SellRare = V end})
TabInv:CreateToggle({Name = "Jual Epic", CurrentValue = false, Callback = function(V) _G.Mofenk.SellEpic = V end})
TabInv:CreateToggle({Name = "Jual Legendary", CurrentValue = false, Callback = function(V) _G.Mofenk.SellLegendary = V end})
TabInv:CreateToggle({Name = "Jual Mythical", CurrentValue = false, Callback = function(V) _G.Mofenk.SellMythical = V end})

TabInv:CreateSection("☑️ Ceklis Rarity (Tier 2)")
TabInv:CreateToggle({Name = "Jual Ancient", CurrentValue = false, Callback = function(V) _G.Mofenk.SellAncient = V end})
TabInv:CreateToggle({Name = "Jual Divine", CurrentValue = false, Callback = function(V) _G.Mofenk.SellDivine = V end})
TabInv:CreateToggle({Name = "Jual Celestial", CurrentValue = false, Callback = function(V) _G.Mofenk.SellCelestial = V end})
TabInv:CreateToggle({Name = "Jual Ethereal", CurrentValue = false, Callback = function(V) _G.Mofenk.SellEthereal = V end})
TabInv:CreateToggle({Name = "Jual Astral", CurrentValue = false, Callback = function(V) _G.Mofenk.SellAstral = V end})
TabInv:CreateToggle({Name = "Jual Cosmic", CurrentValue = false, Callback = function(V) _G.Mofenk.SellCosmic = V end})

TabInv:CreateSection("☑️ Ceklis Rarity (Tier 3 - Godly/Secret)")
TabInv:CreateToggle({Name = "Jual Transcendent", CurrentValue = false, Callback = function(V) _G.Mofenk.SellTranscendent = V end})
TabInv:CreateToggle({Name = "Jual Eternal", CurrentValue = false, Callback = function(V) _G.Mofenk.SellEternal = V end})
TabInv:CreateToggle({Name = "Jual Primordial", CurrentValue = false, Callback = function(V) _G.Mofenk.SellPrimordial = V end})
TabInv:CreateToggle({Name = "Jual Omniversal", CurrentValue = false, Callback = function(V) _G.Mofenk.SellOmniversal = V end})
TabInv:CreateToggle({Name = "Jual Infinite", CurrentValue = false, Callback = function(V) _G.Mofenk.SellInfinite = V end})
TabInv:CreateToggle({Name = "Jual Supreme", CurrentValue = false, Callback = function(V) _G.Mofenk.SellSupreme = V end})
TabInv:CreateToggle({Name = "Jual Secret", CurrentValue = false, Callback = function(V) _G.Mofenk.SellSecret = V end})

TabInv:CreateSection("🔒 Proteksi Item")
TabInv:CreateToggle({Name = "🔒 Keep Mutated (Jangan Jual Mutasi)", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepMutated = V end})

TabInv:CreateSection("🎲 Toko & Upgrades")
TabInv:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabInv:CreateToggle({Name = "📈 Auto Buy Upgrade Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeNodes = V end})

-- TAB 4: DUNGEON & GATES ⚔️ (DEBUGGED DUNGEON & EXIT)
local TabDungeon = Window:CreateTab("Dungeon & Gates ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Smart Dungeon & Auto Exit Combat")
TabDungeon:CreateDropdown({
    Name = "🚪 Pilih Floor Dungeon", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabDungeon:CreateToggle({
    Name = "🚀 Auto Unified Dungeon (Teleport -> Join -> Fight)", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Mofenk.AutoDungeonGroup = V 
        if not V then
            pcall(function()
                safeFireDebug("Auto Dungeon Exit", "SetAutoFightBoss", false)
                safeFireDebug("Auto Dungeon Exit", "LeaveDungeon")
                safeFireDebug("Auto Dungeon Exit", "RequestMyBaseSpawn")
            end)
        end
    end
})
TabDungeon:CreateToggle({Name = "🐉 Auto Dragon Gate", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDragonGate = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base (Keluar Manual)", Callback = function() 
    safeFireDebug("Return To Base", "SetAutoFightBoss", false)
    safeFireDebug("Return To Base", "LeaveDungeon")
    safeFireDebug("Return To Base", "RequestMyBaseSpawn") 
end})

-- TAB 5: PLAYER & SERVER ⚡
local TabPlayer = Window:CreateTab("Player & Server ⚡", 6023426915)
TabPlayer:CreateSection("🛡️ Proteksi & Kecepatan")
TabPlayer:CreateToggle({Name = "🔄 Auto Reconnect (Anti-DC)", CurrentValue = true, Callback = function(V) _G.Mofenk.AutoReconnect = V end})
TabPlayer:CreateToggle({Name = "⚡ Aktifkan Custom WalkSpeed", CurrentValue = false, Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end})
TabPlayer:CreateSlider({Name = "🏃 Kecepatan Jalan", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) _G.Mofenk.WalkSpeedVal = V end})

TabPlayer:CreateSection("🌐 Server Utilities")
TabPlayer:CreateButton({Name = "📋 Copy Server JobID", Callback = function() 
    CopyServerID()
    Rayfield:Notify({Title = "Berhasil Disalin! ✅", Content = "Job ID berhasil disalin.", Duration = 3})
end})
TabPlayer:CreateButton({Name = "🔀 Server Hop (Pindah Server)", Callback = function() 
    Rayfield:Notify({Title = "Memproses...", Content = "Pindah ke server baru...", Duration = 3})
    ServerHop() 
end})

-- TAB 6: DEV & SPY 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("🗺️ ADVANCED MAP & REMOTE SCANNER")
TabDev:CreateButton({Name = "🔍 Jalankan Advanced Scanner", Callback = function() 
    AdvancedMapScan()
    Rayfield:Notify({Title = "Scanner Aktif", Content = "Cek konsol untuk melihat detail remote.", Duration = 3})
end})
TabDev:CreateSection("📡 CONSOLE NETWORK SPY")
TabDev:CreateToggle({Name = "Aktifkan Network Spy", CurrentValue = true, Callback = function(V) _G.Mofenk.SpyEnabled = V end})

-- =====================================================================
-- 8. BACKGROUND MASTER ENGINE (SYNCHRONIZED LOOPS)
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            -- Main Loops dengan Debugger Error
            if _G.Mofenk.AutoRoll then safeFireDebug("Auto Roll", "RollRequest") end
            if _G.Mofenk.AutoRebirth then 
                safeFireDebug("Auto Rebirth", "RebirthRequest")
                safeFireDebug("Auto Rebirth", "Rebirth")
            end
            if _G.Mofenk.AutoClaimQuests then safeFireDebug("Auto Claim Quests", "ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then TriggerUniversalIndexClaims() end
            if _G.Mofenk.AutoClaimBossMilestones then safeFireDebug("Auto Claim Boss Milestones", "ClaimBossMilestones") end
            if _G.Mofenk.AutoWheelSpin then safeFireDebug("Auto Spin Wheel", "WheelSpinRequest") end
            if _G.Mofenk.AutoFuse then safeFireDebug("Auto Fuse", "FuseRequest") end
            
            -- Meteor, Base & Upgrades
            if _G.Mofenk.AutoClaimMeteor then TriggerMeteorClaim() end
            if _G.Mofenk.AutoCollectBase then TriggerBaseCollection() end
            if _G.Mofenk.AutoUpgradeBrainrot then TriggerBrainrotUpgrades() end

            -- Global Collect Money
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFireDebug("Auto Collect Money", "MoneyCollected")
                safeFireDebug("Auto Collect Money", "CollectMoney")
                safeFireDebug("Auto Collect Money", "ClaimCash")
                lastCollect = os.time()
            end
            
            -- Equip Best Squad
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                safeFireDebug("Auto Equip Best", "EquipBest")
                safeFireDebug("Auto Equip Best", "EquipBestBattleSquadRequest")
                lastEquip = os.time()
            end
            
            -- 19-Rarity Checklist Auto Sell
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                ExecuteAccurateSell()
                lastSell = os.time()
            end
            
            -- Shop & Nodes
            if _G.Mofenk.AutoBuyDice then 
                safeFireDebug("Auto Buy Dice", "BuyDiceRequest")
                safeFireDebug("Auto Buy Dice", "DiceShopAction", "Buy", 1) 
            end
            if _G.Mofenk.AutoUpgradeNodes then 
                safeFireDebug("Auto Upgrade Nodes", "BuyAffordableUpgradeNodes")
                safeFireDebug("Auto Upgrade Nodes", "UpgradeNodeRequest") 
            end
            
            -- Unified Dungeon Group & Debugged Sequence
            if _G.Mofenk.AutoDungeonGroup then
                safeFireDebug("Auto Dungeon", "RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                task.wait(0.2)
                safeFireDebug("Auto Dungeon", "RequestGatewayTeleport", _G.Mofenk.TargetFloor)
                task.wait(0.2)
                safeFireDebug("Auto Dungeon", "JoinDungeon", _G.Mofenk.TargetFloor)
                safeFireDebug("Auto Dungeon", "StartDungeon", _G.Mofenk.TargetFloor)
                safeFireDebug("Auto Dungeon", "SetAutoFightBoss", true)
                safeFireDebug("Auto Dungeon", "BossAttack")
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end

            if _G.Mofenk.AutoDragonGate then
                safeFireDebug("Auto Dragon Gate", "DragonGateAction")
                safeFireDebug("Auto Dragon Gate", "DragonGateJoin")
            end
        end)
    end
end)
