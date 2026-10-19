-- =====================================================================
-- 👑 MOFENKHUB V132 — TOWER FIGHT & UNFROZEN MOVEMENT MASTER
-- Game: Dadu Brainrot! | Fixed Movement Lock & Tower Fight System
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
    InstantRoll = false,
    AutoCollectMoney = false, 
    CollectEvery = 1,
    AutoRebirth = false, 
    AutoEquipBest = false, 
    EquipBestEvery = 10,
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
    -- Tower & Battle Group
    AutoTowerFight = false, 
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
    SpyEnabled = true
}

-- PENCARIAN REMOTES AMAN
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function getRemoteClean(targetName)
    if Remotes then
        local exact = Remotes:FindFirstChild(targetName)
        if exact then return exact end
        
        for _, child in ipairs(Remotes:GetChildren()) do
            local cName = string.lower(child.Name)
            if string.find(cName, string.lower(targetName)) then
                return child
            end
        end
    end
    return nil
end

local function safeFire(targetName, ...)
    local args = {...}
    task.spawn(function()
        pcall(function()
            local r = getRemoteClean(targetName)
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
-- 3. FUNGSI EKSEKUSI UTAMA
-- ==========================================
local function TriggerRollSystem()
    pcall(function()
        if _G.Mofenk.InstantRoll then
            for i = 1, 5 do
                safeFire("RollRequest")
                safeFire("Roll")
                safeFire("SpinDice")
            end
        elseif _G.Mofenk.AutoRoll then
            safeFire("RollRequest")
            safeFire("Roll")
            safeFire("SpinDice")
        end
    end)
end

local function TriggerEquipBestBrainrot()
    pcall(function()
        safeFire("EquipBest")
        safeFire("EquipBestBattleSquadRequest")
        safeFire("EquipBestBrainrot")
        safeFire("AutoEquipBestRequest")
    end)
end

local function TriggerBaseCollection()
    pcall(function()
        safeFire("MoneyCollected")
        safeFire("CollectMoney")
        safeFire("ClaimCash")
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local pName = string.lower(obj.Parent.Name)
                if string.find(pName, "base") or string.find(pName, "cash") or string.find(pName, "money") or string.find(pName, "collect") then
                    fireproximityprompt(obj)
                end
            end
        end
    end)
end

local function TriggerMeteorClaim()
    pcall(function()
        safeFire("MeteorClaimed")
        safeFire("ClaimMeteor")
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
            safeFire("UpgradeBrainrotRequest", i)
            safeFire("UpgradePlacedBrainrot", i)
            safeFire("MultiRollUpgradeRequest")
        end
    end)
end

local function TriggerUniversalIndexClaims()
    pcall(function()
        safeFire("RequestIndexRewards")
        local prefixes = {"Finish_", "Tier_", "Index_", "Reward_"}
        local types = {"Galactic", "Prismatic", "Aurora", "Cosmic", "Divine", "Secret", "Legendary", "Mythical"}
        for _, p in ipairs(prefixes) do
            for _, t in ipairs(types) do
                safeFire("ClaimIndexReward", p .. t)
            end
        end
    end)
end

local function ExecuteAccurateSell()
    pcall(function()
        safeFire("RequestInventorySnapshot")
        safeFire("RequestItemsSnapshot")
        
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
                safeFire("SellAllRequest", rarity)
                safeFire("SellSelectedRequest", rarity)
                safeFire("SellItemRequest", rarity)
            end
        end
        safeFire("SetAutoSellUnderRequest", true, _G.Mofenk.KeepMutated)
    end)
end

-- Teleport fisik sekali jalan (tidak nge-lock karakter)
local function OneTimeTowerTeleport(floorName)
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Part") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "tower") or string.find(name, "menara") or string.find(name, "battle") or string.find(name, string.lower(floorName)) then
                        if obj:IsA("Model") and obj.PrimaryPart then
                            char.HumanoidRootPart.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                            break
                        elseif obj:IsA("Part") then
                            char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 4. UTILITIES & UI RAYFIELD (V132)
-- ==========================================
local function CopyServerID()
    pcall(function() if setclipboard then setclipboard(tostring(game.JobId)) end end)
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

-- Anti-DC & AFK
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

-- UI RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V132 Tower Fix",
   LoadingTitle = "Memuat MofenkHub V132...",
   LoadingSubtitle = "Tower Fight & Unfrozen Movement Master",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V132 Loaded! 👑", Content = "Tower Fight & Movement Fix Aktif!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 PROFIL & MONITOR")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung (V132 Tower Fix)\nGame: [UPDATE 2] Dadu Brainrot!"})

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
TabMain:CreateSection("🔄 Farm & Instant Roll Utama")
TabMain:CreateToggle({Name = "🎲 Auto Roll (Normal)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "⚡ INSTANT ROLL (Super Cepat)", CurrentValue = false, Callback = function(V) _G.Mofenk.InstantRoll = V end})
TabMain:CreateToggle({Name = "🔄 Auto Rebirth", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRebirth = V end})
TabMain:CreateToggle({Name = "💰 Auto Collect Money (Global)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 1, Callback = function(V) _G.Mofenk.CollectEvery = V end})

TabMain:CreateSection("🛡️ Squad & Best Brainrot Equip")
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best Brainrot Squad", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 5, Suffix = "s", CurrentValue = 10, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})
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

-- TAB 4: TOWER & GATES ⚔️ (TOWER FIGHT MASTER)
local TabTower = Window:CreateTab("Tower & Gates ⚔️", 6023426915)
TabTower:CreateSection("⚔️ Tower Fight & Unfrozen Movement")
TabTower:CreateDropdown({
    Name = "🚪 Pilih Floor Menara (Tower)", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabTower:CreateToggle({
    Name = "🚀 Auto Tower Fight (One-Time Teleport & Auto Attack)", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Mofenk.AutoTowerFight = V 
        if V then
            -- Teleport fisik dipanggil SEKALI SAJA saat dinyalakan agar karakter tidak ke-lock/freeze
            OneTimeTowerTeleport(_G.Mofenk.TargetFloor)
            safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
            safeFire("JoinDungeon", _G.Mofenk.TargetFloor)
            safeFire("StartDungeon", _G.Mofenk.TargetFloor)
            safeFire("SetAutoFightBoss", true)
        else
            pcall(function()
                safeFire("SetAutoFightBoss", false)
                safeFire("LeaveDungeon")
                safeFire("RequestMyBaseSpawn")
            end)
        end
    end
})
TabTower:CreateToggle({Name = "🐉 Auto Dragon Gate", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDragonGate = V end})
TabTower:CreateButton({Name = "🏠 Return To Base (Keluar Manual)", Callback = function() 
    safeFire("SetAutoFightBoss", false)
    safeFire("LeaveDungeon")
    safeFire("RequestMyBaseSpawn") 
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
-- 8. BACKGROUND MASTER ENGINE (STABLE & UNLOCKED)
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            -- Roll Systems
            TriggerRollSystem()

            if _G.Mofenk.AutoRebirth then 
                safeFire("RebirthRequest")
                safeFire("Rebirth")
            end
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then TriggerUniversalIndexClaims() end
            if _G.Mofenk.AutoClaimBossMilestones then safeFire("ClaimBossMilestones") end
            if _G.Mofenk.AutoWheelSpin then safeFire("WheelSpinRequest") end
            if _G.Mofenk.AutoFuse then safeFire("FuseRequest") end
            
            -- Meteor, Base & Upgrades
            if _G.Mofenk.AutoClaimMeteor then TriggerMeteorClaim() end
            if _G.Mofenk.AutoCollectBase then TriggerBaseCollection() end
            if _G.Mofenk.AutoUpgradeBrainrot then TriggerBrainrotUpgrades() end

            -- Global Collect Money
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFire("MoneyCollected")
                safeFire("CollectMoney")
                safeFire("ClaimCash")
                lastCollect = os.time()
            end
            
            -- Equip Best Squad / Brainrot
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                TriggerEquipBestBrainrot()
                lastEquip = os.time()
            end
            
            -- Auto Sell
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                ExecuteAccurateSell()
                lastSell = os.time()
            end
            
            -- Shop & Nodes
            if _G.Mofenk.AutoBuyDice then 
                safeFire("BuyDiceRequest")
                safeFire("DiceShopAction", "Buy", 1) 
            end
            if _G.Mofenk.AutoUpgradeNodes then 
                safeFire("BuyAffordableUpgradeNodes")
                safeFire("UpgradeNodeRequest") 
            end
            
            -- Tower Fight Loop (Safe & Unlocked)
            if _G.Mofenk.AutoTowerFight then
                safeFire("SetAutoFightBoss", true)
                safeFire("BossAttack")
            end

            if _G.Mofenk.AutoDragonGate then
                safeFire("DragonGateAction")
                safeFire("DragonGateJoin")
            end
        end)
    end
end)
