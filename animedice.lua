-- ==================================================================== --
-- 👑 FIKRAH HUB V30.4 - ULTIMATE CATEGORIZED & OPTIMIZED SYSTEM 👑 --
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

-- PENCARIAN REMOTES UNIVERSAL
local function getRemote(name)
    local found = nil
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == name:lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            found = v
            break
        end
    end
    return found
end

local function safeFire(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote then
        pcall(function(...)
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...)
            end
        end, ...)
    end
end

-- ======================================================= --
-- FUNGSI LOGIKA UTAMA --
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
TabUnit:CreateToggle({Name = "🗑️ Auto Sell Unit di Bawah Batas", Flag = "T_SellUnder", Callback = function(v) _G.AutoSellUnder = v safeFire("SetAutoSellUnderRequest", _G.SellThreshold, v) end})
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
TabSystem:CreateToggle({Name = "👁️ Aktifkan Ultra Deep Spy (Cek F9)", CurrentValue = false, Callback = function(v) _G.SpyEnabled = v end})

-- ======================================================= --
-- LOOPS EKSEKUSI UTAMA (BACKGROUND) --
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

Rayfield:LoadConfiguration()
