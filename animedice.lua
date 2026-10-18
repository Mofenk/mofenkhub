-- ==================================================================== --
-- 👑 FIKRAH HUB V30.4 - ULTIMATE CATEGORIZED & OPTIMIZED SYSTEM (UPDATED)
-- Added: Custom tab, presets (Lite/Pro/Premium/Full Set), error notifications,
--        explicit toggles for many remotes, save/load custom profiles.
-- Integrated: BattleSquadConfig (UI + auto-upgrade) and DungeonConfig (map info + teleport)
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
-- TRY REQUIRE: BattleSquadConfig & DungeonConfig (runtime modules)
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
-- KATEGORI 1: ROLL & GACHA --
-- ------------------------------------------------------- --
TabRoll:CreateSection("🎲 Sistem Roll Utama")
TabRoll:CreateToggle({
    Name = "⚡ Auto Roll / Gacha",
    Flag = "T_Roll",
    Callback = function(v)
        _G.AutoRoll = v
        safeFire("AutoRollState", v)
    end
})
TabRoll:CreateToggle({Name = "🚀 Auto Instant Roll Speed", Flag = "T_InstRoll", Callback = function(v) _G.InstantRoll = v end})

TabRoll:CreateSection("✨ Reroll Grade & Trait")
TabRoll:CreateToggle({Name = "✨ Auto Reroll Grade", Flag = "T_Grade", Callback = function(v) _G.AutoRerollGrade = v end})
TabRoll:CreateToggle({Name = "🌀 Auto Reroll Trait", Flag = "T_Trait", Callback = function(v) _G.AutoRerollTrait = v end})

-- ------------------------------------------------------- --
-- KATEGORI 2: MANAJEMEN UNIT & UANG --
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

-- ------------------------------------------------------- --
-- KATEGORI 3: LEVEL & UPGRADE (PILIHAN 1 - MAX) --
-- ------------------------------------------------------- --
TabUpgrade:CreateSection("📈 Auto Level Up Brainrot (Unit)")
TabUpgrade:CreateToggle({
    Name = "📈 Aktifkan Auto Level Up Brainrot",
    Flag = "T_LvlBrain",
    Callback = function(v) _G.AutoUpgradeBrainrot = v end
})
TabUpgrade:CreateDropdown({
    Name = "🎯 Pilih Target Level Brainrot",
    Options = {"Level 1 (Awal)", "Level 10 (Sedang)", "Level 25 (Tinggi)", "Max (38+/Limit)"},
    CurrentOption = "Max (38+/Limit)",
    Flag = "D_BrainrotLvl",
    Callback = function(option)
        _G.BrainrotTargetLevel = option
    end
})

TabUpgrade:CreateSection("📈 Auto Level Up Dadu (Dice)")
TabUpgrade:CreateToggle({
    Name = "📈 Aktifkan Auto Level Up Dadu",
    Flag = "T_LvlDice",
    Callback = function(v) _G.AutoUpgradeDice = v end
})
TabUpgrade:CreateDropdown({
    Name = "🎯 Pilih Target Level Dadu",
    Options = {"Level 1 (Awal)", "Level 10 (Sedang)", "Level 25 (Tinggi)", "Max (38+/Limit)"},
    CurrentOption = "Max (38+/Limit)",
    Flag = "D_DiceLvl",
    Callback = function(option)
        _G.DiceTargetLevel = option
    end
})

TabUpgrade:CreateSection("🎲 Toko & Rebirth")
TabUpgrade:CreateToggle({Name = "🎲 Auto Buy Dice", Flag = "T_Buy", Callback = function(v) _G.AutoBuyDice = v end})
TabUpgrade:CreateToggle({Name = "🔄 Auto Rebirth", Flag = "T_Reb", Callback = function(v) _G.AutoRebirth = v end})

-- ======================================================= --
-- Battle Squad Integration (uses ReplicatedStorage.Shared.BattleSquadConfig)
-- ======================================================= --
if BattleSquadConfig then
    local maxLevel = BattleSquadConfig.MaxLevel or 0
    local tiers = BattleSquadConfig.Tiers or {}

    TabUpgrade:CreateSection("🛡️ Battle Squad")
    TabUpgrade:CreateButton({
        Name = "🔍 Show Squad Config (Console)",
        Callback = function()
            pcall(function()
                print(HttpService:JSONEncode({MaxLevel = maxLevel, Tiers = tiers}))
                notifyUI("Printed", "BattleSquadConfig dicetak di console.", 2)
            end)
        end
    })

    TabUpgrade:CreateToggle({
        Name = "⚙️ Auto Upgrade Battle Squad",
        Flag = "T_AutoBattleSquad",
        Callback = function(v)
            _G.AutoUpgradeBattleSquad = v
            if v then
                task.spawn(function()
                    while _G.AutoUpgradeBattleSquad do
                        -- attempt to get current tier via server state if available
                        local state = safeInvoke and safeInvoke("RequestBattleSquadUpgradeState")
                        local currentTier = 0
                        if type(state) == "table" and state.CurrentTier then
                            currentTier = state.CurrentTier
                        end
                        local nextTier = (currentTier or 0) + 1
                        if nextTier <= (BattleSquadConfig.MaxLevel or 0) then
                            local cost
                            if BattleSquadConfig.GetUpgradeCost then
                                pcall(function()
                                    cost = BattleSquadConfig.GetUpgradeCost(nextTier)
                                end)
                            else
                                cost = tiers[nextTier] and tiers[nextTier].UpgradeCost
                            end

                            local money = getPlayerMoney()
                            if cost and money and tonumber(money) and tonumber(cost) then
                                if tonumber(money) >= tonumber(cost) then
                                    safeFire("UpgradeBattleSquadRequest")
                                    notifyUI("🔼 Squad Upgrade", "Mencoba upgrade ke tier " .. tostring(nextTier), 2)
                                else
                                    -- not enough money
                                    notifyUI("❌ Squad Upgrade", "Uang tidak cukup untuk upgrade ("..tostring(cost)..")", 2.5)
                                end
                            else
                                -- unknown cost or money: attempt upgrade anyway
                                safeFire("UpgradeBattleSquadRequest")
                                notifyUI("🔼 Squad Upgrade", "Mencoba upgrade (cek server).", 2)
                            end
                        else
                            notifyUI("✅ Squad Max", "Battle squad sudah di max tier.", 2.5)
                            _G.AutoUpgradeBattleSquad = false
                        end
                        task.wait(5)
                    end
                end)
            end
        end
    })

    TabUpgrade:CreateButton({
        Name = "⬆️ Upgrade to Next Tier",
        Callback = function()
            safeFire("UpgradeBattleSquadRequest")
        end
    })

else
    TabUpgrade:CreateSection("🛡️ Battle Squad")
    TabUpgrade:CreateButton({Name = "🔍 Show Squad Config (Not Found)", Callback = function() notifyUI("⚠️ Not Found", "BattleSquadConfig module tidak ditemukan.", 3) end})
end

-- ------------------------------------------------------- --
-- KATEGORI 4: TOWER & DUNGEON (AUTO JOIN & OTOMATIS) --
-- ------------------------------------------------------- --
TabTower:CreateSection("🗼 Otomatisasi Tower")
TabTower:CreateToggle({
    Name = "🚀 Auto Join Tower (Masuk Matchmaking Otomatis)",
    Flag = "T_JoinTower",
    Callback = function(v) _G.AutoJoinTower = v end
})
TabTower:CreateToggle({
    Name = "🗼 Auto Place & Upgrade Tower (Otomatis)",
    Flag = "T_AutoTower",
    Callback = function(v) _G.AutoTower = v end
})
TabTower:CreateToggle({
    Name = "🌀 Auto Mix / Combine Tower (Otomatis)",
    Flag = "T_MixTower",
    Callback = function(v) _G.AutoMixTower = v end
})
TabTower:CreateButton({
    Name = "🗼 Spawn / Place Tower Sekali Klik",
    Callback = function()
        safeFire("PlaceBrainrot")
        safeFire("PlaceTowerRequest")
        safeFire("SpawnTowerRequest")
    end
})

TabTower:CreateSection("👹 Pertarungan Boss")
TabTower:CreateToggle({Name = "⚔️ Auto Fight Boss State", Flag = "T_FightBoss", Callback = function(v) _G.AutoFightBoss = v safeFire("SetAutoFightBoss", v) end})
TabTower:CreateToggle({Name = "💥 Auto Boss Attack Loop", Flag = "T_BossAtk", Callback = function(v) _G.AutoBossAttack = v end})

-- ======================================================= --
-- DungeonConfig Integration (ReplicatedStorage.Shared.DungeonConfig)
-- ======================================================= --
if DungeonConfig then
    local maps = DungeonConfig.Maps or {}
    local mapOptions = {}
    for id, info in pairs(maps) do
        table.insert(mapOptions, id)
    end
    table.sort(mapOptions)

    TabTower:CreateSection("🗺️ Dungeon Config")
    local selectedMap = mapOptions[1] or ""
    TabTower:CreateDropdown({
        Name = "📍 Pilih Map/Dungeon",
        Options = mapOptions,
        CurrentOption = selectedMap,
        Flag = "D_SelectedDungeon",
        Callback = function(option)
            selectedMap = option
        end
    })

    TabTower:CreateButton({
        Name = "🔎 Show Map Info (Console)",
        Callback = function()
            if selectedMap == "" then notifyUI("⚠️ No Map", "Tidak ada map ditemukan.", 2) return end
            local info = DungeonConfig.Maps[selectedMap]
            if info then
                pcall(function()
                    print(HttpService:JSONEncode(info))
                    notifyUI("Printed", "Dungeon info dicetak di console.", 2)
                end)
            else
                notifyUI("⚠️ Not Found", "Map info tidak ditemukan.", 2.5)
            end
        end
    })

    TabTower:CreateButton({
        Name = "🚪 Teleport To Dungeon",
        Callback = function()
            if selectedMap == "" then notifyUI("⚠️ No Map", "Pilih map terlebih dahulu.", 2) return end
            safeFire("RequestDungeonTeleport", selectedMap)
            notifyUI("🔁 Teleport", "Meminta teleport ke " .. tostring(selectedMap), 2)
        end
    })

    TabTower:CreateToggle({
        Name = "🤖 Auto Farm Dungeon (Simple)",
        Flag = "T_AutoFarmDungeon",
        Callback = function(v)
            _G.AutoFarmDungeon = v
            if v then
                task.spawn(function()
                    while _G.AutoFarmDungeon do
                        if selectedMap ~= "" then
                            safeFire("RequestDungeonTeleport", selectedMap)
                            -- optional: start fights / claim rewards (best-effort)
                            safeFire("ClaimAllQuests")
                        end
                        task.wait(10)
                    end
                end)
            end
        end
    })

else
    TabTower:CreateSection("🗺️ Dungeon Config")
    TabTower:CreateButton({Name = "🔎 DungeonConfig Not Found", Callback = function() notifyUI("⚠️ Not Found", "DungeonConfig module tidak ditemukan.", 3) end})
end

-- ------------------------------------------------------- --
-- KATEGORI 5: BOOST & EVENT (TERDETEKSI OTOMATIS) --
-- ------------------------------------------------------- --
TabBoost:CreateSection("🧪 Sistem Boost Item & Potion Terdeteksi")
TabBoost:CreateToggle({
    Name = "🧪 Auto Detect & Use Boost Item / Potion",
    Flag = "T_AutoBoost",
    Callback = function(v)
        _G.AutoDetectBoosts = v
        if v then
            task.spawn(function()
                while _G.AutoDetectBoosts do
                    handleBoostItemsDetection()
                    task.wait(5.0)
                end
            end)
        end
    end
})
TabBoost:CreateDropdown({
    Name = "📦 Pilih Kategori Item Boost",
    Options = {"Semua Item / Potion", "Luck Potion (Keberuntungan)", "Speed Potion (Kecepatan)", "Damage Boost"},
    CurrentOption = "Semua Item / Potion",
    Flag = "D_BoostItem",
    Callback = function(option)
        _G.SelectedBoostItem = option
    end
})
TabBoost:CreateButton({Name = "🧪 Gunakan Boost Sekarang (Manual)", Callback = function() handleBoostItemsDetection() end})

TabBoost:CreateSection("🎁 Misi & Hadiah Event")
TabBoost:CreateToggle({Name = "🎁 Auto Claim All Quests & Rewards", Flag = "T_ClaimAll", Callback = function(v) _G.AutoClaimAllRewards = v end})
TabBoost:CreateToggle({Name = "☄️ Auto Claim Meteor", Flag = "T_Met", Callback = function(v) _G.AutoMeteor = v end})
TabBoost:CreateToggle({Name = "📦 Auto Open Lucky Blocks", Flag = "T_LuckB", Callback = function(v) _G.AutoLuckyBlock = v end})

-- ------------------------------------------------------- --
-- KATEGORI 6: SISTEM & TELEPORT --
-- ------------------------------------------------------- --
TabSystem:CreateSection("📍 Area Teleportasi")
TabSystem:CreateButton({Name = "🏠 Teleport ke Base Saya", Callback = function() safeFire("RequestMyBaseSpawn") end})
TabSystem:CreateButton({Name = "🏙️ Teleport ke Hub Center", Callback = function() safeFire("RequestHubSpawn") end})
TabSystem:CreateButton({Name = "🏪 Teleport ke Market", Callback = function() safeFire("RequestMarketSpawn") end})

TabSystem:CreateSection("⚙️ Alat & Keamanan")
TabSystem:CreateToggle({
    Name = "🛡️ Anti-AFK (Pencegah Disconnect)",
    CurrentValue = true,
    Flag = "T_AntiAFK",
    Callback = function(v)
        _G.AntiAFK = v
        if v then
            local VirtualUser = game:GetService("VirtualUser")
            game.Players.LocalPlayer.Idled:Connect(function()
                if _G.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end
})
TabSystem:CreateToggle({Name = "👁️ Aktifkan Ultra Deep Spy (Cek F9)", CurrentValue = false, Flag = "T_Spy", Callback = function(v) _G.SpyEnabled = v end})

-- ======================================================= --
-- TAB: CUSTOM / PRESETS / EXPLICIT OPTIONS / ERROR MONITOR
-- ======================================================= --
-- Helper: build/apply/save/load custom profile
local function buildCustomProfile()
    return {
        -- roll/gacha
        AutoRoll = _G.AutoRoll or false,
        InstantRoll = _G.InstantRoll or false,
        AutoRerollGrade = _G.AutoRerollGrade or false,
        AutoRerollTrait = _G.AutoRerollTrait or false,
        -- sell/inventory
        AutoSellUnder = _G.AutoSellUnder or false,
        AutoSellAllJunk = _G.AutoSellAllJunk or false,
        AutoEquipBest = _G.AutoEquipBest or false,
        AutoLockBestUnits = _G.AutoLockBestUnits or false,
        -- money / collect
        AutoCollectMoney = _G.AutoCollectMoney or false,
        CollectDelay = _G.CollectDelay or 2.0,
        -- upgrade/shop
        AutoUpgradeBrainrot = _G.AutoUpgradeBrainrot or false,
        BrainrotTargetLevel = _G.BrainrotTargetLevel or "Max (38+/Limit)",
        AutoUpgradeDice = _G.AutoUpgradeDice or false,
        DiceTargetLevel = _G.DiceTargetLevel or "Max (38+/Limit)",
        AutoBuyDice = _G.AutoBuyDice or false,
        AutoRebirth = _G.AutoRebirth or false,
        -- tower / boss
        AutoJoinTower = _G.AutoJoinTower or false,
        AutoTower = _G.AutoTower or false,
        AutoMixTower = _G.AutoMixTower or false,
        AutoFightBoss = _G.AutoFightBoss or false,
        AutoBossAttack = _G.AutoBossAttack or false,
        -- boosts / events
        AutoDetectBoosts = _G.AutoDetectBoosts or false,
        SelectedBoostItem = _G.SelectedBoostItem or "Semua Item / Potion",
        AutoClaimAllRewards = _G.AutoClaimAllRewards or false,
        AutoMeteor = _G.AutoMeteor or false,
        AutoLuckyBlock = _G.AutoLuckyBlock or false,
        -- system
        AntiAFK = _G.AntiAFK or true,
        SpyEnabled = _G.SpyEnabled or false,
        -- misc
        SetMusicEnabled = _G.SetMusicEnabled or true,
        SetPerformanceAuto = _G.SetPerformanceAuto or false,
        SetPerformanceMode = _G.SetPerformanceMode or "Default"
    }
end

local function applyCustomProfile(profile)
    if type(profile) ~= "table" then
        safeWarn("Custom profile invalid.")
        notifyUI("❌ Error", "Custom profile invalid.", 3)
        return false
    end

    -- apply values (with safe defaults)
    _G.AutoRoll = profile.AutoRoll or false
    _G.InstantRoll = profile.InstantRoll or false
    _G.AutoRerollGrade = profile.AutoRerollGrade or false
    _G.AutoRerollTrait = profile.AutoRerollTrait or false

    _G.AutoSellUnder = profile.AutoSellUnder or false
    _G.AutoSellAllJunk = profile.AutoSellAllJunk or false
    _G.AutoEquipBest = profile.AutoEquipBest or false
    _G.AutoLockBestUnits = profile.AutoLockBestUnits or false

    _G.AutoCollectMoney = profile.AutoCollectMoney or false
    _G.CollectDelay = profile.CollectDelay or 2.0

    _G.AutoUpgradeBrainrot = profile.AutoUpgradeBrainrot or false
    _G.BrainrotTargetLevel = profile.BrainrotTargetLevel or "Max (38+/Limit)"
    _G.AutoUpgradeDice = profile.AutoUpgradeDice or false
    _G.DiceTargetLevel = profile.DiceTargetLevel or "Max (38+/Limit)"
    _G.AutoBuyDice = profile.AutoBuyDice or false
    _G.AutoRebirth = profile.AutoRebirth or false

    _G.AutoJoinTower = profile.AutoJoinTower or false
    _G.AutoTower = profile.AutoTower or false
    _G.AutoMixTower = profile.AutoMixTower or false
    _G.AutoFightBoss = profile.AutoFightBoss or false
    _G.AutoBossAttack = profile.AutoBossAttack or false

    _G.AutoDetectBoosts = profile.AutoDetectBoosts or false
    _G.SelectedBoostItem = profile.SelectedBoostItem or "Semua Item / Potion"
    _G.AutoClaimAllRewards = profile.AutoClaimAllRewards or false
    _G.AutoMeteor = profile.AutoMeteor or false
    _G.AutoLuckyBlock = profile.AutoLuckyBlock or false

    _G.AntiAFK = profile.AntiAFK ~= false
    _G.SpyEnabled = profile.SpyEnabled or false
    _G.SetMusicEnabled = profile.SetMusicEnabled or true
    _G.SetPerformanceAuto = profile.SetPerformanceAuto or false
    _G.SetPerformanceMode = profile.SetPerformanceMode or "Default"

    -- Attempt to push some quick remote state updates where relevant
    if _G.SetMusicEnabled ~= nil then
        safeFire("SetMusicEnabled", _G.SetMusicEnabled)
    end
    if _G.SetPerformanceAuto ~= nil then
        safeFire("SetPerformanceAuto", _G.SetPerformanceAuto)
    end
    if _G.SetPerformanceMode then
        safeFire("SetPerformanceMode", _G.SetPerformanceMode)
    end

    notifyUI("✅ Applied", "Custom profile diterapkan.", 2.2)
    return true
end

local function getActiveCustomCount()
    local profile = buildCustomProfile()
    local total = 0
    for _, value in pairs(profile) do
        if value == true then
            total = total + 1
        end
    end
    return total
end

local function saveCustomProfile(profile)
    if not profile then
        profile = buildCustomProfile()
    end
    local saveKey = "FikrahHub_CustomSet_" .. tostring(LocalPlayer.Name) .. ".json"
    local ok, err = pcall(function()
        writefile(saveKey, HttpService:JSONEncode({
            saved = true,
            profile = profile,
            updatedAt = os.date("%Y-%m-%d %H:%M:%S")
        }))
    end)
    if not ok then
        safeWarn("Gagal menyimpan custom profile: " .. tostring(err))
        notifyUI("❌ Error Save", "Gagal menyimpan custom profile.", 4)
        return false
    end
    notifyUI("✅ Saved", "Custom profile berhasil disimpan.", 2.5)
    return true
end

local function loadCustomProfile()
    local saveKey = "FikrahHub_CustomSet_" .. tostring(LocalPlayer.Name) .. ".json"
    if not isfile_wrapper(saveKey) then
        return nil
    end
    local ok, raw = pcall(function() return readfile(saveKey) end)
    if not ok or not raw then
        safeWarn("Gagal membaca file profile custom.")
        notifyUI("❌ Error Load", "Gagal membaca file profile custom.", 3)
        return nil
    end
    local suc, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not suc or type(data) ~= "table" then
        safeWarn("Profile custom corrupt atau invalid JSON.")
        notifyUI("❌ Error Load", "Profile custom corrupt.", 3)
        return nil
    end
    return data.profile or nil
end

local function setCustomPreset(name)
    local preset = {
        Lite = {
            AutoRoll = true,
            InstantRoll = false,
            AutoRerollGrade = false,
            AutoRerollTrait = false,
            AutoSellUnder = false,
            AutoSellAllJunk = true,
            AutoEquipBest = true,
            AutoLockBestUnits = true,
            AutoCollectMoney = true,
            CollectDelay = 2.0,
            AutoUpgradeBrainrot = true,
            AutoUpgradeDice = false,
            AutoBuyDice = false,
            AutoRebirth = false,
            AutoJoinTower = false,
            AutoTower = false,
            AutoMixTower = false,
            AutoFightBoss = false,
            AutoBossAttack = true,
            AutoDetectBoosts = true,
            SelectedBoostItem = "Semua Item / Potion",
            AutoClaimAllRewards = false,
            AutoMeteor = false,
            AutoLuckyBlock = false,
            AntiAFK = true,
            SpyEnabled = false,
            SetMusicEnabled = true
        },
        Pro = {
            AutoRoll = true,
            InstantRoll = true,
            AutoRerollGrade = true,
            AutoRerollTrait = true,
            AutoSellUnder = true,
            AutoSellAllJunk = true,
            AutoEquipBest = true,
            AutoLockBestUnits = true,
            AutoCollectMoney = true,
            CollectDelay = 1.5,
            AutoUpgradeBrainrot = true,
            AutoUpgradeDice = true,
            AutoBuyDice = true,
            AutoRebirth = false,
            AutoJoinTower = true,
            AutoTower = true,
            AutoMixTower = true,
            AutoFightBoss = true,
            AutoBossAttack = true,
            AutoDetectBoosts = true,
            SelectedBoostItem = "Semua Item / Potion",
            AutoClaimAllRewards = true,
            AutoMeteor = true,
            AutoLuckyBlock = true,
            AntiAFK = true,
            SpyEnabled = false,
            SetMusicEnabled = false,
            SetPerformanceAuto = true
        },
        Premium = {
            AutoRoll = true,
            InstantRoll = true,
            AutoRerollGrade = true,
            AutoRerollTrait = true,
            AutoSellUnder = true,
            AutoSellAllJunk = true,
            AutoEquipBest = true,
            AutoLockBestUnits = true,
            AutoCollectMoney = true,
            CollectDelay = 1.0,
            AutoUpgradeBrainrot = true,
            AutoUpgradeDice = true,
            AutoBuyDice = true,
            AutoRebirth = true,
            AutoJoinTower = true,
            AutoTower = true,
            AutoMixTower = true,
            AutoFightBoss = true,
            AutoBossAttack = true,
            AutoDetectBoosts = true,
            SelectedBoostItem = "Semua Item / Potion",
            AutoClaimAllRewards = true,
            AutoMeteor = true,
            AutoLuckyBlock = true,
            AntiAFK = true,
            SpyEnabled = false,
            SetMusicEnabled = false,
            SetPerformanceAuto = true
        },
        ["Full Set"] = {
            AutoRoll = true,
            InstantRoll = true,
            AutoRerollGrade = true,
            AutoRerollTrait = true,
            AutoSellUnder = true,
            AutoSellAllJunk = true,
            AutoEquipBest = true,
            AutoLockBestUnits = true,
            AutoCollectMoney = true,
            CollectDelay = 0.6,
            AutoUpgradeBrainrot = true,
            AutoUpgradeDice = true,
            AutoBuyDice = true,
            AutoRebirth = true,
            AutoJoinTower = true,
            AutoTower = true,
            AutoMixTower = true,
            AutoFightBoss = true,
            AutoBossAttack = true,
            AutoDetectBoosts = true,
            SelectedBoostItem = "Semua Item / Potion",
            AutoClaimAllRewards = true,
            AutoMeteor = true,
            AutoLuckyBlock = true,
            AntiAFK = true,
            SpyEnabled = true,
            SetMusicEnabled = false,
            SetPerformanceAuto = true
        }
    }
    return preset[name]
end

local TabCustom = Window:CreateTab("💎 Custom", 4483345998)

-- Presets
TabCustom:CreateSection("🧩 Custom Preset")
TabCustom:CreateDropdown({
    Name = "🎯 Pilih Preset",
    Options = {"Lite", "Pro", "Premium", "Full Set"},
    CurrentOption = "Lite",
    Flag = "CustomPreset",
    Callback = function(option)
        local preset = setCustomPreset(option)
        if preset then
            applyCustomProfile(preset)
            notifyUI("✅ Preset Applied", "Preset " .. option .. " berhasil diterapkan.", 2.5)
        else
            notifyUI("❌ Error", "Preset tidak ditemukan.", 2.5)
        end
    end
})

TabCustom:CreateButton({
    Name = "⚡ Apply Full Set",
    Callback = function()
        local full = setCustomPreset("Full Set")
        if full and applyCustomProfile(full) then
            notifyUI("✅ Full Set Activated", "Semua fitur custom full set aktif.", 2.5)
        end
    end
})

TabCustom:CreateButton({
    Name = "🧹 Reset All Custom",
    Callback = function()
        local profile = {
            AutoRoll = false, InstantRoll = false, AutoRerollGrade = false, AutoRerollTrait = false,
            AutoSellUnder = false, AutoSellAllJunk = false, AutoEquipBest = false, AutoLockBestUnits = false,
            AutoCollectMoney = false, CollectDelay = 2.0,
            AutoUpgradeBrainrot = false, BrainrotTargetLevel = "Max (38+/Limit)",
            AutoUpgradeDice = false, DiceTargetLevel = "Max (38+/Limit)",
            AutoBuyDice = false, AutoRebirth = false,
            AutoJoinTower = false, AutoTower = false, AutoMixTower = false,
            AutoFightBoss = false, AutoBossAttack = false,
            AutoDetectBoosts = false, SelectedBoostItem = "Semua Item / Potion",
            AutoClaimAllRewards = false, AutoMeteor = false, AutoLuckyBlock = false,
            AntiAFK = true, SpyEnabled = false, SetMusicEnabled = true, SetPerformanceAuto = false
        }
        applyCustomProfile(profile)
        notifyUI("✅ Reset", "Semua custom set di-reset.", 2.5)
    end
})

TabCustom:CreateButton({
    Name = "💾 Save Profile",
    Callback = function()
        local profile = buildCustomProfile()
        saveCustomProfile(profile)
    end
})

TabCustom:CreateButton({
    Name = "📂 Load Profile",
    Callback = function()
        local loaded = loadCustomProfile()
        if loaded then
            applyCustomProfile(loaded)
            notifyUI("✅ Loaded", "Custom profile berhasil dimuat.", 2.5)
        else
            notifyUI("⚠️ No Saved Profile", "Belum ada saved custom profile.", 3)
        end
    end
})

-- Status & monitor
TabCustom:CreateSection("📊 Status & Error Monitor")
TabCustom:CreateButton({
    Name = "🔎 Check Active Count",
    Callback = function()
        local active = getActiveCustomCount()
        notifyUI("📊 Status", "Aktif: " .. active .. " fitur.", 2.2)
    end
})

TabCustom:CreateButton({
    Name = "⚠️ Test Error Notification",
    Callback = function()
        safeWarn("Simulasi notifikasi error untuk custom UI.")
        notifyUI("⚠️ Error", "Contoh error: remote tidak ditemukan atau custom set gagal.", 3)
    end
})

-- Explicit category toggles inside Custom tab for quick control
TabCustom:CreateSection("🎲 Roll & Gacha (Custom)")
TabCustom:CreateToggle({Name = "⚡ Auto Roll", Flag = "C_AutoRoll", Callback = function(v) _G.AutoRoll = v safeFire("AutoRollState", v) end})
TabCustom:CreateToggle({Name = "🚀 Instant Roll", Flag = "C_Instant", Callback = function(v) _G.InstantRoll = v end})
TabCustom:CreateToggle({Name = "✨ Reroll Grade", Flag = "C_RerollGrade", Callback = function(v) _G.AutoRerollGrade = v end})
TabCustom:CreateToggle({Name = "🌀 Reroll Trait", Flag = "C_RerollTrait", Callback = function(v) _G.AutoRerollTrait = v end})

TabCustom:CreateSection("🗃️ Sell / Inventory (Custom)")
TabCustom:CreateToggle({Name = "🗑️ Auto Sell Under Threshold", Flag = "C_SellUnder", Callback = function(v) _G.AutoSellUnder = v safeFire("SetAutoSellUnderRequest", _G.SellThreshold, v) end})
TabCustom:CreateToggle({Name = "🗑️ Auto Sell All Junk", Flag = "C_SellJunk", Callback = function(v) _G.AutoSellAllJunk = v end})
TabCustom:CreateToggle({Name = "👕 Auto Equip Best", Flag = "C_EquipBest", Callback = function(v) _G.AutoEquipBest = v if v then safeFire("EquipBest") end end})
TabCustom:CreateToggle({Name = "🔒 Auto Lock Best", Flag = "C_Lock", Callback = function(v) _G.AutoLockBestUnits = v if v then safeFire("ToggleLockRequest") end end})

TabCustom:CreateSection("📈 Upgrade & Shop")
TabCustom:CreateToggle({Name = "📈 Auto Upgrade Brainrot", Flag = "C_UpBrain", Callback = function(v) _G.AutoUpgradeBrainrot = v end})
TabCustom:CreateToggle({Name = "📈 Auto Upgrade Dice", Flag = "C_UpDice", Callback = function(v) _G.AutoUpgradeDice = v end})
TabCustom:CreateToggle({Name = "🎲 Auto Buy Dice", Flag = "C_BuyDice", Callback = function(v) _G.AutoBuyDice = v end})
TabCustom:CreateToggle({Name = "🔄 Auto Rebirth", Flag = "C_Rebirth", Callback = function(v) _G.AutoRebirth = v end})

TabCustom:CreateSection("🗼 Tower & Boss")
TabCustom:CreateToggle({Name = "🚀 Auto Join Tower", Flag = "C_JoinTower", Callback = function(v) _G.AutoJoinTower = v end})
TabCustom:CreateToggle({Name = "🗼 Auto Tower Ops", Flag = "C_TowerOps", Callback = function(v) _G.AutoTower = v end})
TabCustom:CreateToggle({Name = "👹 Auto Fight Boss", Flag = "C_AutoFightBoss", Callback = function(v) _G.AutoFightBoss = v safeFire("SetAutoFightBoss", v) end})
TabCustom:CreateToggle({Name = "💥 Auto Boss Attack", Flag = "C_BossAtk", Callback = function(v) _G.AutoBossAttack = v end})

TabCustom:CreateSection("🧪 Boost & Events")
TabCustom:CreateToggle({Name = "🧪 Auto Detect Boosts", Flag = "C_DetectBoost", Callback = function(v) _G.AutoDetectBoosts = v if v then task.spawn(function() while _G.AutoDetectBoosts do handleBoostItemsDetection() task.wait(5) end end) end end})
TabCustom:CreateDropdown({Name = "📦 Boost Item", Options = {"Semua Item / Potion", "Luck Potion (Keberuntungan)", "Speed Potion (Kecepatan)", "Damage Boost"}, CurrentOption = _G.SelectedBoostItem, Flag = "C_BoostSelect", Callback = function(option) _G.SelectedBoostItem = option end})
TabCustom:CreateToggle({Name = "🎁 Auto Claim Events", Flag = "C_ClaimAllEvents", Callback = function(v) _G.AutoClaimAllRewards = v end})

TabCustom:CreateSection("⚙️ System & Telemetry")
TabCustom:CreateToggle({Name = "🛡️ AntiAFK", Flag = "C_AntiAFK", Callback = function(v) _G.AntiAFK = v end})
TabCustom:CreateToggle({Name = "🔔 Enable Notifications For Errors", Flag = "C_ErrorNotif", Callback = function(v) _G.EnableErrorNotif = v end})
TabCustom:CreateToggle({Name = "🔇 Music Enabled", Flag = "C_Music", CurrentValue = _G.SetMusicEnabled, Callback = function(v) _G.SetMusicEnabled = v safeFire("SetMusicEnabled", v) end})
TabCustom:CreateToggle({Name = "⚡ Performance Auto", Flag = "C_PerfAuto", CurrentValue = _G.SetPerformanceAuto, Callback = function(v) _G.SetPerformanceAuto = v safeFire("SetPerformanceAuto", v) end})

TabCustom:CreateSection("🧩 Quick Actions & Debug")
TabCustom:CreateButton({Name = "🔁 Apply Current Profile", Callback = function() applyCustomProfile(buildCustomProfile()) end})
TabCustom:CreateButton({Name = "🧾 Print Current Profile (Console)", Callback = function() print(HttpService:JSONEncode(buildCustomProfile())) notifyUI("Printed", "Profile dicetak di console.", 2) end})
TabCustom:CreateButton({Name = "🛠️ Run Quick Remote Check", Callback = function()
    -- quick check for important remotes and report missing ones
    local checkList = {"RollRequest","AutoRollState","SetAutoSellUnderRequest","EquipBest","ClaimAllQuests","SetMusicEnabled","SetPerformanceAuto"}
    local missing = {}
    for _, name in pairs(checkList) do
        if not getRemote(name) then table.insert(missing, name) end
    end
    if #missing > 0 then
        notifyUI("⚠️ Missing Remotes", table.concat(missing, ", "), 4)
        warn("[FikrahHub] Missing remotes: " .. table.concat(missing, ", "))
    else
        notifyUI("✅ Remotes OK", "Semua remote penting terdeteksi.", 2.5)
    end
end})

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
        if _G.AutoSellUnder or _G.AutoSellAllJunk then performAutoSell() end
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

        if _G.AutoUpgradeBrainrot then safeFire("UpgradeBrainrotRequest", targetBrainLevel) end
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
local savedCustom = loadCustomProfile()
if savedCustom then
    pcall(function()
        applyCustomProfile(savedCustom)
    end)
end

-- End of file
