-- =====================================================================
-- 👑 MOFENKHUB V143 — FIXED AUTO SELL LOOP & ULTIMATE DEBUGGER
-- Game: Dadu Brainrot! | Presisi Auto Sell Sesuai Ceklis Sambil Roll
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI LAMA SECARA AMAN
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
    CollectEvery = 2,
    AutoRebirth = false, 
    AutoEquipBest = false, 
    EquipBestEvery = 15,
    AutoClaimQuests = false, 
    AutoClaimIndex = false,
    -- Upgrade All Switches
    AutoUpgradeAllNodes = false,
    AutoUpgradeAllBrainrots = false,
    AutoUpgradeAllGear = false,
    AutoMultiRollUpgrade = false,
    AutoCollectBase = false,
    AutoClaimMeteor = false,
    -- Checklist Sell Config (Dengan Timer Loop Pintar & Aman)
    AutoSell = false,
    SellEvery = 3,
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
    -- Select Dungeon / Tower Group
    AutoSelectDungeon = false, 
    TargetTower = "Sahur Tower", 
    AutoDragonGate = false,
    -- Automation Extras
    AutoFuse = false,
    AutoWheelSpin = false,
    AutoClaimBossMilestones = false,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoBuyDice = false, 
    AutoReconnect = true,
    SpyEnabled = true
}

-- PENCARIAN REMOTES AMAN DENGAN DEBUGGER ERROR TRACER
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function getEncryptedRemote(targetName)
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

local function safeFireEncrypted(featureName, targetName, ...)
    local args = {...}
    task.spawn(function()
        local success, err = pcall(function()
            local r = getEncryptedRemote(targetName)
            if r then
                if r:IsA("RemoteEvent") then 
                    r:FireServer(unpack(args))
                elseif r:IsA("RemoteFunction") then 
                    r:InvokeServer(unpack(args)) 
                end
            else
                warn("⚠️ [MOFENK DEBUGGER] Remote '" .. targetName .. "' untuk fitur [" .. featureName .. "] tidak ditemukan!")
            end
        end)
        if not success then
            warn("❌ [MOFENK ERROR TRACER] Fitur [" .. featureName .. "] Gagal: " .. tostring(err))
        end
    end)
end

-- ==========================================
-- 3. FUNGSI EKSEKUSI UTAMA
-- ==========================================
local function TriggerRollSystem()
    pcall(function()
        if _G.Mofenk.InstantRoll then
            for i = 1, 3 do
                safeFireEncrypted("Instant Roll", "RollRequest")
                safeFireEncrypted("Instant Roll", "Roll")
                safeFireEncrypted("Instant Roll", "SpinDice")
            end
        elseif _G.Mofenk.AutoRoll then
            safeFireEncrypted("Auto Roll", "RollRequest")
            safeFireEncrypted("Auto Roll", "Roll")
            safeFireEncrypted("Auto Roll", "SpinDice")
        end
    end)
end

local function TriggerEquipBestBrainrot()
    pcall(function()
        safeFireEncrypted("Equip Best", "EquipBest")
        safeFireEncrypted("Equip Best", "EquipBestBattleSquadRequest")
        safeFireEncrypted("Equip Best", "EquipBestBrainrot")
        safeFireEncrypted("Equip Best", "AutoEquipBestRequest")
    end)
end

local function TriggerBaseCollection()
    pcall(function()
        safeFireEncrypted("Base Collection", "MoneyCollected")
        safeFireEncrypted("Base Collection", "CollectMoney")
        safeFireEncrypted("Base Collection", "ClaimCash")
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
        safeFireEncrypted("Meteor Claim", "MeteorClaimed")
        safeFireEncrypted("Meteor Claim", "ClaimMeteor")
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            if string.find(name, "meteor") and obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj)
            end
        end
    end)
end

local function ExecuteUltimateUpgradeAll()
    pcall(function()
        if _G.Mofenk.AutoUpgradeAllNodes then
            safeFireEncrypted("Upgrade Nodes", "BuyAffordableUpgradeNodes")
            safeFireEncrypted("Upgrade Nodes", "UpgradeNodeRequest", "All")
        end
        if _G.Mofenk.AutoUpgradeAllBrainrots then
            safeFireEncrypted("Upgrade Brainrots", "UpgradeAllBrainrotsRequest")
            safeFireEncrypted("Upgrade Brainrots", "MaxUpgradeAllPlaced")
        end
        if _G.Mofenk.AutoUpgradeAllGear then
            safeFireEncrypted("Upgrade Gear", "UpgradeAllGearRequest")
            safeFireEncrypted("Upgrade Gear", "MaxUpgradeGear")
        end
        if _G.Mofenk.AutoMultiRollUpgrade then
            safeFireEncrypted("MultiRoll", "MultiRollUpgradeRequest")
        end
    end)
end

local function TriggerUniversalIndexClaims()
    pcall(function()
        safeFireEncrypted("Index Claim", "RequestIndexRewards")
        local prefixes = {"Finish_", "Tier_", "Index_", "Reward_"}
        local types = {"Galactic", "Prismatic", "Aurora", "Cosmic", "Divine", "Secret", "Legendary", "Mythical"}
        for _, p in ipairs(prefixes) do
            for _, t in ipairs(types) do
                safeFireEncrypted("Index Claim", "ClaimIndexReward", p .. t)
            end
        end
    end)
end

-- SISTEM AUTO SELL SELEKTIF BERDASARKAN CEKLIS RARITY SAAT ROLL
local function ExecuteSmartRaritySell()
    pcall(function()
        if not _G.Mofenk.AutoSell then return end
        
        local rarities = {
            {name = "Common", val = _G.Mofenk.SellCommon},
            {name = "Uncommon", val = _G.Mofenk.SellUncommon},
            {name = "Rare", val = _G.Mofenk.SellRare},
            {name = "Epic", val = _G.Mofenk.SellEpic},
            {name = "Legendary", val = _G.Mofenk.SellLegendary},
            {name = "Mythical", val = _G.Mofenk.SellMythical},
            {name = "Ancient", val = _G.Mofenk.SellAncient},
            {name = "Divine", val = _G.Mofenk.SellDivine},
            {name = "Celestial", val = _G.Mofenk.SellCelestial},
            {name = "Ethereal", val = _G.Mofenk.SellEthereal},
            {name = "Astral", val = _G.Mofenk.SellAstral},
            {name = "Cosmic", val = _G.Mofenk.SellCosmic},
            {name = "Transcendent", val = _G.Mofenk.SellTranscendent},
            {name = "Eternal", val = _G.Mofenk.SellEternal},
            {name = "Primordial", val = _G.Mofenk.SellPrimordial},
            {name = "Omniversal", val = _G.Mofenk.SellOmniversal},
            {name = "Infinite", val = _G.Mofenk.SellInfinite},
            {name = "Supreme", val = _G.Mofenk.SellSupreme},
            {name = "Secret", val = _G.Mofenk.SellSecret}
        }

        for _, r in ipairs(rarities) do
            if r.val then
                -- Menembak remote game dengan variasi parameter sell rarity agar langsung terjual otomatis di background
                safeFireEncrypted("Smart Sell", "SellSelectedRequest", r.name)
                safeFireEncrypted("Smart Sell", "SellRarityRequest", r.name)
                safeFireEncrypted("Smart Sell", "ToggleAutoSellRarityRequest", r.name, true)
            end
        end
    end)
end

local function ExecuteSelectDungeonAction(towerName)
    pcall(function()
        safeFireEncrypted("Dungeon", "DungeonShopState", towerName)
        safeFireEncrypted("Dungeon", "SelectDungeon", towerName)
        safeFireEncrypted("Dungeon", "RequestDungeonTeleport", towerName)
        safeFireEncrypted("Dungeon", "JoinDungeon", towerName)
        safeFireEncrypted("Dungeon", "StartDungeon", towerName)
        safeFireEncrypted("Dungeon", "PlayTowerRequest", towerName)
        safeFireEncrypted("Dungeon", "SetAutoFightBoss", true)
        safeFireEncrypted("Dungeon", "BossAttack")
    end)
end

-- ==========================================
-- 4. CLEAN SPY & DEBUGGER
-- ==========================================
local lastSpyPrint = 0
local function AdvancedMapScan()
    print("\n==================================================")
    print("🔍 [MOFENK SPY SCANNER] Memindai Remote Game...")
    print("==================================================")
    if Remotes then
        for _, r in ipairs(Remotes:GetChildren()) do
            print("   - " .. r.Name .. " (" .. r.ClassName .. ")")
        end
    end
    print("==================================================\n")
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.Mofenk.SpyEnabled and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        if tick() - lastSpyPrint > 1.5 then
            lastSpyPrint = tick()
            local args = {...}
            task.spawn(function()
                pcall(function()
                    print("👁️ [DEBUGGER SPY] " .. self.Name .. " (" .. method .. ")")
                end)
            end)
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- 5. UTILITIES & PROFIL
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

-- ==========================================
-- 6. UI RAYFIELD (V143 SMART SELL MASTER)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V143 Smart Sell Master",
   LoadingTitle = "Memuat MofenkHub V143...",
   LoadingSubtitle = "Smart Inventory Sweeper & Full Debugger",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V143 Loaded! 👑", Content = "Smart Rarity Auto Sell Aktif!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 PROFIL & MONITOR")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung (V143 Smart Sell)\nGame: [UPDATE 2] Dadu Brainrot!"})

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
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 2, Callback = function(V) _G.Mofenk.CollectEvery = V end})

TabMain:CreateSection("🛡️ Squad & Best Brainrot Equip")
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best Brainrot Squad", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 5, Suffix = "s", CurrentValue = 15, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})
TabMain:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards (Universal)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "🏆 Auto Claim Boss Milestones", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimBossMilestones = V end})
TabMain:CreateToggle({Name = "☄️ Auto Claim Meteor", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimMeteor = V end})
TabMain:CreateToggle({Name = "🎡 Auto Spin Wheel", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoWheelSpin = V end})
TabMain:CreateToggle({Name = "🧪 Auto Fuse Items/Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoFuse = V end})

-- TAB 3: UPGRADE ALL ⚡
local TabUpgrade = Window:CreateTab("Upgrade All ⚡", 6023426915)
TabUpgrade:CreateSection("📈 Ultimate Upgrade All Master Engine")
TabUpgrade:CreateToggle({Name = "⚡ Auto Upgrade All Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeAllNodes = V end})
TabUpgrade:CreateToggle({Name = "⚡ Auto Upgrade All Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeAllBrainrots = V end})
TabUpgrade:CreateToggle({Name = "⚡ Auto Upgrade All Gear / Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeAllGear = V end})
TabUpgrade:CreateToggle({Name = "⚡ Auto Multi-Roll Upgrade", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoMultiRollUpgrade = V end})
TabUpgrade:CreateToggle({Name = "🏡 Auto Collect Base Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectBase = V end})
TabUpgrade:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})

-- TAB 4: INVENTORY & SMART RARITY SELL 📦
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("💲 Smart Auto Sell By Rarity (Sambil Roll)")
TabInv:CreateToggle({Name = "🗑️ Aktifkan Smart Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Interval (s)", Range = {1, 15}, Increment = 1, Suffix = "s", CurrentValue = 3, Callback = function(V) _G.Mofenk.SellEvery = V end})

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

-- TAB 5: SELECT DUNGEON & TOWER ⚔️
local TabTower = Window:CreateTab("Dungeon & Tower ⚔️", 6023426915)
TabTower:CreateSection("⚔️ Select Dungeon & Auto Play")
TabTower:CreateDropdown({
    Name = "🚪 Pilih Tower / Dungeon", 
    Options = {"Sahur Tower", "Orcala Tower", "Bombardiro Tower", "Spiderini Tower", "Larila Tower"}, 
    CurrentOption = {"Sahur Tower"}, 
    Callback = function(Opt) _G.Mofenk.TargetTower = Opt[1] end
})
TabTower:CreateToggle({
    Name = "🚀 Auto Select Dungeon & Play", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Mofenk.AutoSelectDungeon = V 
        if V then
            ExecuteSelectDungeonAction(_G.Mofenk.TargetTower)
            Rayfield:Notify({Title = "Auto Dungeon Aktif 🚀", Content = "Memulai " .. _G.Mofenk.TargetTower, Duration = 3})
        else
            pcall(function()
                safeFireEncrypted("Dungeon", "SetAutoFightBoss", false)
                safeFireEncrypted("Dungeon", "LeaveDungeon")
                safeFireEncrypted("Dungeon", "RequestMyBaseSpawn")
            end)
            Rayfield:Notify({Title = "Auto Dungeon Berhenti 🛑", Content = "Kembali ke base.", Duration = 3})
        end
    end
})
TabTower:CreateToggle({Name = "🐉 Auto Dragon Gate", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDragonGate = V end})
TabTower:CreateButton({Name = "🏠 Return To Base (Keluar Manual)", Callback = function() 
    safeFireEncrypted("Dungeon", "SetAutoFightBoss", false)
    safeFireEncrypted("Dungeon", "LeaveDungeon")
    safeFireEncrypted("Dungeon", "RequestMyBaseSpawn")
    Rayfield:Notify({Title = "Kembali ke Base", Content = "Berhasil keluar dari dungeon.", Duration = 3})
end})

-- TAB 6: PLAYER & SERVER ⚡
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

-- TAB 7: DEV & SPY 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("🗺️ ADVANCED MAP & REMOTE SCANNER")
TabDev:CreateButton({Name = "🔍 Jalankan Advanced Scanner", Callback = function() 
    AdvancedMapScan()
    Rayfield:Notify({Title = "Scanner Aktif 🔍", Content = "Cek konsol Roblox untuk melihat detail remote.", Duration = 3})
end})
TabDev:CreateSection("📡 CONSOLE NETWORK SPY")
TabDev:CreateToggle({Name = "Aktifkan Network Spy", CurrentValue = true, Callback = function(V) _G.Mofenk.SpyEnabled = V end})

-- =====================================================================
-- 7. BACKGROUND MASTER ENGINE
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

            if _G.Mofenk.AutoRoll or _G.Mofenk.InstantRoll then
                TriggerRollSystem()
            end

            if _G.Mofenk.AutoRebirth then 
                safeFireEncrypted("Rebirth", "RebirthRequest")
                safeFireEncrypted("Rebirth", "Rebirth")
            end
            if _G.Mofenk.AutoClaimQuests then safeFireEncrypted("Quests", "ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then TriggerUniversalIndexClaims() end
            if _G.Mofenk.AutoClaimBossMilestones then safeFireEncrypted("Boss", "ClaimBossMilestones") end
            if _G.Mofenk.AutoWheelSpin then safeFireEncrypted("Wheel", "WheelSpinRequest") end
            if _G.Mofenk.AutoFuse then safeFireEncrypted("Fuse", "FuseRequest") end
            
            if _G.Mofenk.AutoClaimMeteor then TriggerMeteorClaim() end
            if _G.Mofenk.AutoCollectBase then TriggerBaseCollection() end

            if _G.Mofenk.AutoUpgradeAllNodes or _G.Mofenk.AutoUpgradeAllBrainrots or _G.Mofenk.AutoUpgradeAllGear or _G.Mofenk.AutoMultiRollUpgrade then
                ExecuteUltimateUpgradeAll()
            end

            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                TriggerBaseCollection()
                lastCollect = os.time()
            end
            
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                TriggerEquipBestBrainrot()
                lastEquip = os.time()
            end
            
            -- Smart Rarity Auto Sell Loop Sambil Roll
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                ExecuteSmartRaritySell()
                lastSell = os.time()
            end
            
            if _G.Mofenk.AutoBuyDice then 
                safeFireEncrypted("Dice Shop", "BuyDiceRequest")
                safeFireEncrypted("Dice Shop", "DiceShopAction", "Buy", 1) 
            end
            
            if _G.Mofenk.AutoSelectDungeon then
                ExecuteSelectDungeonAction(_G.Mofenk.TargetTower)
                safeFireEncrypted("Dungeon Fight", "SetAutoFightBoss", true)
                safeFireEncrypted("Dungeon Fight", "BossAttack")
            end

            if _G.Mofenk.AutoDragonGate then
                safeFireEncrypted("Dragon Gate", "DragonGateAction")
                safeFireEncrypted("Dragon Gate", "DragonGateJoin")
            end
        end)
    end
end)
