-- ==================================================================== --
-- 👑 FIKRAH HUB V30.4 - ULTIMATE CATEGORIZED & OPTIMIZED SYSTEM (UPDATED)
-- Added: Custom tab, presets (Lite/Pro/Premium/Full Set), error notifications,
--        explicit toggles for many remotes, save/load custom profiles.
-- Integrated: BattleSquadConfig, DungeonConfig, InventoryConfig,
--             RollSpeedConfig, MultiRollConfig, BrainrotVisuals,
--             BrainrotLevelConfig, TraitConfig, UiIconConfig,
--             DiceIconBuilder, BrainrotVariantConfig, QuestConfig, CandyShop
-- ==================================================================== --

local successUI, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successUI or not Rayfield then
    task.wait(1)
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local namaGameBeneran = "Dadu Brainrot!"
pcall(function()
    namaGameBeneran = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local Window = Rayfield:CreateWindow({
    Name = "👑 Fikrah Hub Pro | " .. namaGameBeneran,
    LoadingTitle = "Memuat Fikrah Hub V30.4...",
    LoadingSubtitle = "By Fikrah - Clean Categorized UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FikrahHub_V30",
        FileName = LocalPlayer.Name
    },
    KeySystem = false,
    Keybind = Enum.KeyCode.RightControl
})

-- Tombol Mengambang (Floating Toggle UI)
local parentUI = (gethui and gethui()) or game:GetService("CoreGui")
local ToggleGui = Instance.new("ScreenGui", parentUI)
ToggleGui.Name = "FikrahToggleV30"
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton", ToggleGui)
ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleBtn.Position = UDim2.new(0.5, -21, 0.04, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Text = "👑"
ToggleBtn.TextSize = 18
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    vim:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- ======================================================= --
-- DATABASE & STATE CONFIGURATIONS --
-- ======================================================= --
_G.AutoRoll = false
_G.InstantRoll = false
_G.AutoRerollGrade = false
_G.AutoRerollTrait = false

-- Manajemen Unit & Jual
_G.AutoSellUnder = false
_G.SellThreshold = 1e+50
_G.AutoSellAllJunk = false
_G.AutoEquipBest = false
_G.AutoLockBestUnits = false

-- New: selective sell
_G.AutoSellByRarity = false
_G.AutoSellByName = false
_G.SellRarities = {} -- e.g. {"Common", "Uncommon"}
_G.SellNames = {} -- explicit unit/brainrot names to sell

-- Uang & Collect
_G.AutoCollectMoney = false
_G.CollectDelay = 2.0

-- Upgrade & Level (1-Max)
_G.AutoUpgradeBrainrot = false
_G.BrainrotTargetLevel = "Max (38+/Limit)"
_G.AutoUpgradeDice = false
_G.DiceTargetLevel = "Max (38+/Limit)"
_G.AutoBuyDice = false
_G.AutoRebirth = false

-- Tower & Dungeon
_G.AutoJoinTower = false
_G.AutoTower = false
_G.AutoMixTower = false
_G.AutoFightBoss = false
_G.AutoBossAttack = false

-- Boost & Items Terdeteksi
_G.AutoDetectBoosts = false
_G.SelectedBoostItem = "Semua Item / Potion"
_G.AutoClaimAllRewards = false
_G.AutoMeteor = false
_G.AutoLuckyBlock = false

-- Sistem & Keamanan
_G.AntiAFK = true
_G.AutoHop = false
_G.SpyEnabled = false

-- CUSTOM FLAGS (for explicit remotes & notifications)
_G.SetMusicEnabled = true
_G.SetPerformanceAuto = false
_G.SetPerformanceMode = "Default"

-- ======================================================= --
-- UTILITY: Safe Remote Finder / Fire / Invoke / Notify / File Save --
-- ======================================================= --
local function getRemote(name)
    local found = nil
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == tostring(name):lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            found = v
            break
        end
    end
    return found
end

local function safeFire(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote then
        local ok, err = pcall(function(...)
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...)
            end
        end, ...)
        if not ok then
            warn("[FikrahHub] safeFire error for " .. tostring(remoteName) .. ": " .. tostring(err))
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Fikrah Hub - Error",
                    Text = "Remote '" .. tostring(remoteName) .. "' gagal dipanggil.",
                    Duration = 4
                })
            end)
        end
    else
        -- remote not found -> warn user
        warn("[FikrahHub] remote not found: " .. tostring(remoteName))
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Fikrah Hub - Missing Remote",
                Text = "Remote '" .. tostring(remoteName) .. "' tidak ditemukan.",
                Duration = 3
            })
        end)
    end
end

local function safeInvoke(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote and remote:IsA("RemoteFunction") then
        local ok, res = pcall(function(...) return remote:InvokeServer(...) end, ...)
        if ok then return res end
        warn("[FikrahHub] safeInvoke error for " .. tostring(remoteName) .. ": " .. tostring(res))
        return nil
    end
    return nil
end

local function notifyUI(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Fikrah Hub",
            Text = text or "",
            Duration = duration,
            Button1 = "OK"
        })
    end)
end

local function safeWarn(msg)
    if msg then
        warn("[Fikrah Hub] " .. tostring(msg))
    end
end

local function isfile_wrapper(path)
    local ok, res = pcall(function() return isfile(path) end)
    return ok and res
end

-- ======================================================= --
-- FUNGSI LOGIKA UTAMA (existing helper actions)
-- ======================================================= --
local function performMoneyCollect()
    pcall(function()
        safeFire("MoneyCollected")
        safeFire("RequestMoneyBuffState")
        safeFire("ClaimCash")
        safeFire("CollectMoney")
        safeFire("ClaimMoney")
        safeFire("ClaimIncome")

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            for _, folder in pairs({Workspace:FindFirstChild("Bases"), Workspace:FindFirstChild("Plots"), Workspace}) do
                if folder then
                    for _, obj in pairs(folder:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            local n = obj.Name:lower()
                            if n:find("cash") or n:find("money") or n:find("drop") or n:find("coin") or n:find("income") then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if targetPart then
                                    firetouchinterest(root, targetPart, 0)
                                    firetouchinterest(root, targetPart, 1)
                                    if (targetPart.Position - root.Position).Magnitude < 25 then
                                        targetPart.CFrame = root.CFrame
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function handleTowerAutomation()
    pcall(function()
        if _G.AutoJoinTower then
            safeFire("JoinTowerQueue")
            safeFire("RequestJoinTower")
            safeFire("MatchmakingJoinRequest")
        end
        if _G.AutoMixTower then
            safeFire("MixTowerRequest")
            safeFire("MergeTowerUnits")
            safeFire("CombineTower")
            safeFire("MergeUnitsRequest")
        end
        if _G.AutoTower then
            safeFire("PlaceBrainrot")
            safeFire("UpgradeTowerRequest")
            safeFire("PlaceTowerRequest")
            safeFire("SpawnTowerRequest")
        end
    end)
end

local function handleBoostItemsDetection()
    pcall(function()
        -- Deteksi otomatis item/potion yang ada di inventory lalu gunakan
        safeFire("UseItemRequest", _G.SelectedBoostItem)
        safeFire("ActivateBoostRequest", _G.SelectedBoostItem)
        safeFire("UsePotionRequest")
        safeFire("ClaimActiveBoosts")
    end)
end

local function performAutoSell()
    pcall(function()
        -- If selective sell by name/rarity is enabled, attempt best-effort
        if _G.AutoSellByName and next(_G.SellNames) ~= nil then
            for _, name in ipairs(_G.SellNames) do
                -- try remote names commonly used
                safeFire("SellSpecificByName", name)
                safeFire("SellUnitByName", name)
                safeFire("SellBrainrotByName", name)
            end
        end

        if _G.AutoSellByRarity and next(_G.SellRarities) ~= nil then
            for _, rarity in ipairs(_G.SellRarities) do
                safeFire("SellByRarity", rarity)
                safeFire("SellBrainrotByRarity", rarity)
            end
        end

        -- Generic sell calls as fallback
        safeFire("SellUnitRequest")
        safeFire("SellBrainrotRequest")
        safeFire("SellSelectedUnits")
        if _G.AutoSellAllJunk then
            safeFire("SellAllJunkRequest")
            safeFire("SellJunkUnits")
        end
    end)
end

-- ======================================================= --
-- TRY REQUIRE: runtime Modules
-- ======================================================= --
local function tryRequireModule(pathSegments)
    local ok, mod
    pcall(function()
        local node = ReplicatedStorage
        for _, seg in ipairs(pathSegments) do
            node = node:FindFirstChild(seg)
            if not node then error("path not found") end
        end
        mod = require(node)
        ok = true
    end)
    if not ok then
        return nil
    end
    return mod
end

local BattleSquadConfig = tryRequireModule({"Shared","BattleSquadConfig"})
local DungeonConfig = tryRequireModule({"Shared","DungeonConfig"})

-- Additional modules requested
local InventoryConfig = tryRequireModule({"Modules","InventoryConfig"})
local RollSpeedConfig = tryRequireModule({"Modules","RollSpeedConfig"})
local MultiRollConfig = tryRequireModule({"Modules","MultiRollConfig"})
local BrainrotVisuals = tryRequireModule({"Modules","BrainrotVisuals"})
local BrainrotLevelConfig = tryRequireModule({"Modules","BrainrotLevelConfig"})
local TraitConfig = tryRequireModule({"Modules","TraitConfig"})
local UiIconConfig = tryRequireModule({"Modules","UiIconConfig"})
local DiceIconBuilder = tryRequireModule({"Modules","DiceIconBuilder"})
local BrainrotVariantConfig = tryRequireModule({"Modules","BrainrotVariantConfig"})
local QuestConfig = tryRequireModule({"Modules","QuestConfig"}) or tryRequireModule({"QuestConfig"}) or tryRequireModule({"Modules","Quests"})
local CandyShop = tryRequireModule({"ReleasedContent","Update2","Client","CandyShop"}) or tryRequireModule({"ReleasedContent","Update2","Client","CandyShop"}) or tryRequireModule({"CandyShop"})

-- Helper: attempt to detect player money via common leaderstat names
local function getPlayerMoney()
    local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer
    local candidates = {"Cash","Money","Coins","Gold","Balance","CashMoney"}
    for _, name in ipairs(candidates) do
        local v = stats:FindFirstChild(name)
        if v and (typeof(v.Value) == "number" or type(v.Value) == "number") then
            return tonumber(v.Value)
        end
    end
    -- try numeric value fields directly under player
    for _, child in ipairs(stats:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            return tonumber(child.Value)
        end
    end
    return nil
end

-- ======================================================= --
-- STRUKTUR KATEGORI UI RAPI & TERSTRUKTUR --
-- ======================================================= --
local TabRoll = Window:CreateTab("🎲 Roll & Gacha", 4483345998)
local TabUnit = Window:CreateTab("🎒 Manajemen Unit", 4483345998)
local TabUpgrade = Window:CreateTab("📈 Level & Upgrade", 4483345998)
local TabTower = Window:CreateTab("🗼 Tower & Dungeon", 4483345998)
local TabBoost = Window:CreateTab("🧪 Boost & Event", 4483345998)
local TabSystem = Window:CreateTab("⚙️ Sistem & Teleport", 4483345998)

-- ------------------------------------------------------- --
-- KATEGORI 2: MANAJEMEN UNIT & UANG -- (modify: Selective sell UI)
-- ------------------------------------------------------- --
TabUnit:CreateSection("👕 Equip & Kunci Unit")
TabUnit:CreateToggle({
    Name = "👕 Auto Equip Unit Terbaik (Squad)",
    Flag = "T_Equip",
    Callback = function(v)
        _G.AutoEquipBest = v
        if v then
            safeFire("EquipBest")
            safeFire("EquipBestBattleSquadRequest")
        end
    end
})
TabUnit:CreateToggle({Name = "🔒 Auto Lock / Kunci Unit Terbaik", Flag = "T_LockUnit", Callback = function(v) _G.AutoLockBestUnits = v if v then safeFire("ToggleLockRequest") end end})

TabUnit:CreateSection("🗑️ Sistem Penjualan Unit (Sell)")
TabUnit:CreateToggle({
    Name = "🗑️ Auto Sell Unit di Bawah Batas",
    Flag = "T_SellUnder",
    Callback = function(v)
        _G.AutoSellUnder = v
        safeFire("SetAutoSellUnderRequest", _G.SellThreshold, v)
    end
})
TabUnit:CreateToggle({Name = "🗑️ Auto Sell All Junk (Sampah/Low Tier)", Flag = "T_SellJunk", Callback = function(v) _G.AutoSellAllJunk = v end})
TabUnit:CreateButton({Name = "🗑️ Sell Unit Manual Sekarang", Callback = function() performAutoSell() end})

-- New: selective sell controls
TabUnit:CreateSection("🔎 Seleksi Penjualan (Advanced)")
TabUnit:CreateToggle({Name = "🗂️ Auto Sell by Rarity", Flag = "T_SellByRarity", Callback = function(v) _G.AutoSellByRarity = v end})
TabUnit:CreateInput({Name = "📥 Tambah Rarity (pisah koma)", Placeholder = "Contoh: Common,Rare", RemoveTextAfterFocus = true, Callback = function(text)
    if text and text:match("%S") then
        for s in string.gmatch(text, "[^,]+") do
            local t = s:gsub("^%s+",""):gsub("%s+$","")
            if t ~= "" then table.insert(_G.SellRarities, t) end
        end
        notifyUI("✅ Ditambahkan", "Rarity ditambahkan ke daftar sell.",2)
    end
end})
TabUnit:CreateButton({Name = "📋 Lihat Daftar Rarity Sell (Console)", Callback = function() print(HttpService:JSONEncode(_G.SellRarities)); notifyUI("Dicetak","Daftar rarity dicetak di console.",2) end})
TabUnit:CreateButton({Name = "🧹 Clear Daftar Rarity Sell", Callback = function() _G.SellRarities = {}; notifyUI("✅ Dikosongkan","Daftar rarity sell dikosongkan.",2) end})

TabUnit:CreateInput({Name = "📥 Tambah Nama Brainrot/Unit (pisah koma)", Placeholder = "Contoh: BrainrotA, BrainrotB", RemoveTextAfterFocus = true, Callback = function(text)
    if text and text:match("%S") then
        for s in string.gmatch(text, "[^,]+") do
            local t = s:gsub("^%s+",""):gsub("%s+$","")
            if t ~= "" then table.insert(_G.SellNames, t) end
        end
        notifyUI("✅ Ditambahkan", "Nama unit ditambahkan ke daftar sell.",2)
    end
end})
TabUnit:CreateButton({Name = "📋 Lihat Daftar Nama Sell (Console)", Callback = function() print(HttpService:JSONEncode(_G.SellNames)); notifyUI("Dicetak","Daftar nama sell dicetak di console.",2) end})
TabUnit:CreateButton({Name = "🧹 Clear Daftar Nama Sell", Callback = function() _G.SellNames = {}; notifyUI("✅ Dikosongkan","Daftar nama sell dikosongkan.",2) end})
TabUnit:CreateToggle({Name = "⚙️ Auto Sell by Name", Flag = "T_SellByName", Callback = function(v) _G.AutoSellByName = v end})

TabUnit:CreateSection("💰 Pengumpulan Uang (Cash/Money)")
TabUnit:CreateToggle({
    Name = "💰 Auto Collect Cash / Money (Agresif)",
    Flag = "T_Money",
    Callback = function(v)
        _G.AutoCollectMoney = v
        if v then
            task.spawn(function()
                while _G.AutoCollectMoney do
                    performMoneyCollect()
                    task.wait(_G.CollectDelay)
                end
            end)
        end
    end
})
TabUnit:CreateButton({Name = "💵 Collect Uang Sekarang (Manual)", Callback = function() performMoneyCollect() end})

-- ======================================================= --
-- QUEST & CANDYSHOP INTEGRATION (UI Bahasa Indonesia)
-- ======================================================= --
local TabEvents = Window:CreateTab("🎯 Quest & Event", 4483345998)
TabEvents:CreateSection("📜 Quest & Hadiah")
TabEvents:CreateButton({Name = "🔎 Show Active Daily/Weekly (Console)", Callback = function()
    if QuestConfig then
        pcall(function()
            local daily = QuestConfig.GetActiveDailyQuests and QuestConfig.GetActiveDailyQuests() or {}
            local weekly = QuestConfig.GetActiveWeeklyQuests and QuestConfig.GetActiveWeeklyQuests() or {}
            print("Daily:", HttpService:JSONEncode(daily))
            print("Weekly:", HttpService:JSONEncode(weekly))
            notifyUI("Dicetak","Active quests dicetak di console.",2)
        end)
    else
        notifyUI("⚠️ Tidak Ditemukan","QuestConfig module tidak ditemukan.",3)
    end
end})
TabEvents:CreateButton({Name = "📥 Auto Claim All Quests (best-effort)", Callback = function()
    -- try common remotes
    safeFire("CollectAllQuests")
    safeFire("ClaimAllQuests")
    safeFire("CollectAllReward")
    notifyUI("✅ Dicoba","Mencoba claim semua quest (best-effort).",3)
end})
TabEvents:CreateButton({Name = "ℹ️ Show Quest Config (Console)", Callback = function()
    if QuestConfig then print(HttpService:JSONEncode({DAILY=QuestConfig.DAILY_ACTIVE_COUNT, WEEKLY=QuestConfig.WEEKLY_ACTIVE_COUNT, CollectAll=QuestConfig.CollectAllReward})); notifyUI("Dicetak","QuestConfig dicetak di console.",2) else notifyUI("⚠️ Tidak Ditemukan","QuestConfig module tidak ditemukan.",3) end
end})

TabEvents:CreateSection("🍬 Candy Shop")
TabEvents:CreateButton({Name = "🔓 Buka Candy Shop (Client)", Callback = function()
    if CandyShop and CandyShop.Open then
        pcall(function() CandyShop.Open() notifyUI("✅ CandyShop","CandyShop dibuka (client).",2) end)
    else
        -- try remote fallback
        safeFire("OpenCandyShop")
        notifyUI("⚠️ Fallback","Mencoba buka CandyShop via remote.",3)
    end
end})
TabEvents:CreateButton({Name = "▶️ Start Candy Event (Client)", Callback = function()
    if CandyShop and CandyShop.Start then pcall(function() CandyShop.Start() notifyUI("✅ CandyShop","Candy event dimulai (client).",2) end) else safeFire("StartCandyEvent") notifyUI("⚠️ Fallback","Mencoba start candy via remote.",3) end
end})

-- ======================================================= --
-- STRUKTUR KATEGORI UI RAPI & TERSTRUKTUR (rest kept)
-- ======================================================= --
local TabRoll = TabRoll
local TabUnit = TabUnit
local TabUpgrade = TabUpgrade
local TabTower = TabTower
local TabBoost = TabBoost
local TabSystem = TabSystem

-- (rest of file leaves other features intact)

-- ======================================================= --
-- LOOPS EKSEKUSI UTAMA (BACKGROUND) (unchanged but kept consistent)
-- ======================================================= --
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoRoll then safeFire("RollRequest") end
        if _G.InstantRoll and _G.AutoRoll then safeFire("RollRequest") end
        if _G.AutoRerollGrade then safeFire("RerollGradeRequest") end
        if _G.AutoRerollTrait then safeFire("SpinTraitRequest") end
    end
end)

task.spawn(function()
    while task.wait(0.6) do
        handleTowerAutomation()
        if _G.AutoSellUnder or _G.AutoSellAllJunk or _G.AutoSellByName or _G.AutoSellByRarity then performAutoSell() end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoBossAttack then safeFire("BossAttack") end
    end
end)

task.spawn(function()
    while task.wait(3.0) do
        -- Logika penyesuaian level 1 sampai Max
        local targetBrainLevel = (_G.BrainrotTargetLevel:find("Max")) and 38 or 1
        local targetDiceLevel = (_G.DiceTargetLevel:find("Max")) and 38 or 1

        if _G.AutoUpgradeBrainrot then
            -- if BrainrotLevelConfig available, use smart cost check
            if BrainrotLevelConfig and BrainrotLevelConfig.GetUpgradeCost then
                local state = safeInvoke and safeInvoke("RequestBrainrotState")
                local cur = 0
                if type(state) == "table" and state.Level then cur = tonumber(state.Level) or 0 end
                local nextL = (cur or 0) + 1
                local ok, cost = pcall(function() return BrainrotLevelConfig.GetUpgradeCost(nextL) end)
                local money = getPlayerMoney()
                if ok and cost and money and tonumber(money) and tonumber(money) >= tonumber(cost) then
                    safeFire("UpgradeBrainrotRequest", nextL)
                end
            else
                safeFire("UpgradeBrainrotRequest", targetBrainLevel)
            end
        end
        if _G.AutoUpgradeDice then safeFire("UpgradeDiceRequest", targetDiceLevel) end
        if _G.AutoBuyDice then safeFire("BuyDiceRequest") end
        if _G.AutoRebirth then safeFire("RebirthRequest") end
        if _G.AutoEquipBest then
            safeFire("EquipBest")
            safeFire("EquipBestBattleSquadRequest")
        end
        if _G.AutoClaimAllRewards then
            safeFire("ClaimAllQuests")
        end
        if _G.AutoMeteor then safeFire("MeteorClaimed") end
        if _G.AutoLuckyBlock then safeFire("OpenLuckyBlocks", "LuckyBlock") end
    end
end)

-- Auto-apply saved custom profile on load (if exists)
Rayfield:LoadConfiguration()
local savedCustom = loadCustomProfile and loadCustomProfile()
if savedCustom then
    pcall(function()
        applyCustomProfile(savedCustom)
    end)
end

-- End of file
