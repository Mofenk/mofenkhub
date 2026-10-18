-- ==================================================================== --
-- 👑 FIKRAH HUB V30.0 - RESTRUCTURED & CLEAN UI SYSTEM 👑 --
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

local namaGameBeneran = "Brainrot Dice"
pcall(function() 
    namaGameBeneran = MarketplaceService:GetProductInfo(game.PlaceId).Name 
end)

local Window = Rayfield:CreateWindow({
    Name = "👑 Fikrah Hub Pro | " .. namaGameBeneran,
    LoadingTitle = "Memuat Fikrah Hub V30.0...",
    LoadingSubtitle = "By Fikrah - Clean UI & Well Organized",
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

-- DATABASE & STATE CONFIG
_G.AutoRoll = false
_G.InstantRoll = false
_G.AutoRerollGrade = false
_G.AutoRerollTrait = false
_G.AutoSellUnder = false
_G.SellThreshold = 1e+50
_G.AutoCollectMoney = false
_G.CollectDelay = 3.0
_G.AutoBuyDice = false
_G.AutoRebirth = false
_G.AutoUpgradeDice = false
_G.AutoUpgradeBrainrot = false
_G.AutoEquipBest = false
_G.AutoLockBestUnits = false
_G.AntiAFK = true
_G.AutoHop = false
_G.AutoBoost = false
_G.AutoClaimAllRewards = false
_G.AutoMeteor = false
_G.AutoLuckyBlock = false
_G.SpyEnabled = false
_G.AutoTower = false
_G.AutoMixTower = false
_G.AutoFightBoss = false
_G.AutoBossAttack = false
_G.AutoUpgradeLuck = false
_G.AutoUpgradeDamage = false
_G.AutoUpgradeInventory = false
_G.AutoUpgradeRollSpeed = false
_G.AutoUpgradeWalkSpeed = false

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

local function safeFire(remoteName, ...)
    if RemotesFolder then
        local remote = RemotesFolder:FindFirstChild(remoteName)
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
end

-- PURE LUA SPY SYSTEM
local function serializeTable(tbl, maxDepth)
    maxDepth = maxDepth or 3
    local function recurse(t, depth)
        if type(t) ~= "table" then return tostring(t) end
        if depth > maxDepth then return "{...}" end
        local res = "{"
        local first = true
        for k, v in pairs(t) do
            if not first then res = res .. ", " end
            first = false
            local key = type(k) == "string" and '"'..k..'"' or tostring(k)
            local val = type(v) == "string" and '"'..v..'"' or (type(v) == "table" and recurse(v, depth + 1)) or tostring(v)
            res = res .. "[" .. key .. "] = " .. val
        end
        return res .. "}"
    end
    return recurse(tbl, 1)
end

local function dumpArgs(...)
    local args = {...}
    if #args == 0 then return " (Tanpa Parameter / Kosong)" end
    local str = ""
    for i, arg in ipairs(args) do
        local argType = typeof(arg)
        if argType == "table" then
            local ok, res = pcall(function() return serializeTable(arg) end)
            str = str .. string.format("\n └─ [Param %d] (Table): %s", i, ok and res or "{Gagal Baca Table}")
        elseif argType == "Instance" then
            str = str .. string.format("\n └─ [Param %d] (Instance): %s", i, arg:GetFullName())
        elseif argType == "Vector3" then
            str = str .. string.format("\n └─ [Param %d] (Vector3): (X:%.1f, Y:%.1f, Z:%.1f)", i, arg.X, arg.Y, arg.Z)
        elseif argType == "CFrame" then
            local p = arg.Position
            str = str .. string.format("\n └─ [Param %d] (CFrame Pos): (X:%.1f, Y:%.1f, Z:%.1f)", i, p.X, p.Y, p.Z)
        else
            str = str .. string.format("\n └─ [Param %d] (%s): %s", i, argType, tostring(arg))
        end
    end
    return str
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.SpyEnabled and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local rName = tostring(self.Name)
        if rName ~= "MouseTarget" and rName ~= "UpdateMouse" and rName ~= "Move" and rName ~= "GetMouse" then
            local isiData = dumpArgs(...)
            print(string.format("🚨 [DEEP SPY]\n📌 Remote: %s\n🛠️ Method: %s%s\n-----------------------------------", rName, method, isiData))
        end
    end
    return oldNamecall(self, ...)
end))

-- LOGIKA Aksi Game
local function handleTowerSystem()
    pcall(function()
        if _G.AutoMixTower then
            safeFire("MixTowerRequest")
            safeFire("MergeTowerUnits")
            safeFire("CombineTower")
        end
        if _G.AutoTower then
            safeFire("PlaceBrainrot")
            safeFire("UpgradeTowerRequest")
        end
    end)
end

local function performMoneyCollect()
    pcall(function()
        safeFire("MoneyCollected")
        safeFire("RequestMoneyBuffState")
        safeFire("ClaimCash")
        safeFire("CollectMoney")
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local searchFolders = {Workspace:FindFirstChild("Bases"), Workspace:FindFirstChild("Plots"), Workspace}
            for _, folder in pairs(searchFolders) do
                if folder then
                    for _, obj in pairs(folder:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            local n = obj.Name:lower()
                            if n:find("cash") or n:find("money") or n:find("drop") or n:find("coin") then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if targetPart then
                                    firetouchinterest(root, targetPart, 0)
                                    firetouchinterest(root, targetPart, 1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function hopServer()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local body = HttpService:JSONDecode(req)
        if body and body.data then
            for _, s in pairs(body.data) do
                if type(s) == "table" and s.playing < s.maxPlayers and s.id ~= game.JobId then
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

-- ======================================================= --
-- STRUKTUR TAB & SECTION UI RAPI --
-- ======================================================= --
local TabAuto = Window:CreateTab("⚡ Otomatisasi", 4483345998)
local TabUpgrades = Window:CreateTab("📈 Peningkatan", 4483345998)
local TabBattle = Window:CreateTab("⚔️ Menara & Boss", 4483345998)
local TabTeleport = Window:CreateTab("🚀 Teleport & Toko", 4483345998)
local TabSystem = Window:CreateTab("👑 Sistem & Spy", 4483345998)

-- ------------------------------------------------------- --
-- TAB 1: OTOMATISASI (AUTO FARM & ROLL) --
-- ------------------------------------------------------- --
TabAuto:CreateSection("🎲 Sistem Roll & Gacha")
TabAuto:CreateToggle({
    Name = "⚡ Auto Roll / Gacha",
    Flag = "T_Roll",
    Callback = function(v)
        _G.AutoRoll = v
        safeFire("AutoRollState", v)
    end
})

TabAuto:CreateToggle({Name = "🚀 Auto Instant Roll Speed", Flag = "T_InstRoll", Callback = function(v) _G.InstantRoll = v end})
TabAuto:CreateToggle({Name = "✨ Auto Reroll Grade", Flag = "T_Grade", Callback = function(v) _G.AutoRerollGrade = v end})
TabAuto:CreateToggle({Name = "🌀 Auto Reroll Trait", Flag = "T_Trait", Callback = function(v) _G.AutoRerollTrait = v end})

TabAuto:CreateSection("🎒 Manajemen Unit & Penjualan")
TabAuto:CreateToggle({
    Name = "👕 Auto Equip Best Unit / Squad",
    Flag = "T_Equip",
    Callback = function(v)
        _G.AutoEquipBest = v
        if v then
            safeFire("EquipBest")
            safeFire("EquipBestBattleSquadRequest")
        end
    end
})

TabAuto:CreateToggle({
    Name = "🔒 Auto Lock / Kunci Unit Terbaik",
    Flag = "T_LockUnit",
    Callback = function(v)
        _G.AutoLockBestUnits = v
        if v then
            safeFire("ToggleLockRequest")
        end
    end
})

TabAuto:CreateToggle({
    Name = "🗑️ Auto Sell Under Limit",
    Flag = "T_SellUnder",
    Callback = function(v)
        _G.AutoSellUnder = v
        safeFire("SetAutoSellUnderRequest", _G.SellThreshold, v)
    end
})

TabAuto:CreateDropdown({
    Name = "📌 Batas Harga Auto Sell",
    Options = {"1e+09 (1 Miliar)", "1e+25 (Sedang)", "1e+50 (Tinggi)", "1e+58 (Super Tinggi)"},
    CurrentOption = "1e+50 (Tinggi)",
    Flag = "D_SellLimit",
    Callback = function(option)
        if option:find("1e+09") then _G.SellThreshold = 1e+09
        elseif option:find("1e+25") then _G.SellThreshold = 1e+25
        elseif option:find("1e+50") then _G.SellThreshold = 1e+50
        elseif option:find("1e+58") then _G.SellThreshold = 1e+58 end
        if _G.AutoSellUnder then
            safeFire("SetAutoSellUnderRequest", _G.SellThreshold, true)
        end
    end
})

TabAuto:CreateSection("💰 Pengumpulan Uang & Balance")
TabAuto:CreateToggle({
    Name = "💰 Auto Collect Balance & Cash Data",
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

TabAuto:CreateButton({Name = "💵 Collect Sekarang (Manual)", Callback = function() performMoneyCollect() end})
TabAuto:CreateSlider({
    Name = "⏱️ Interval Collect (Detik)",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 3.0,
    Flag = "S_CollectDelay",
    Callback = function(v) _G.CollectDelay = v end
})

-- ------------------------------------------------------- --
-- TAB 2: PENINGKATAN (UPGRADES) --
-- ------------------------------------------------------- --
TabUpgrades:CreateSection("📊 Status & Buff Karakter")
TabUpgrades:CreateToggle({Name = "🍀 Auto Upgrade Luck Buff", Flag = "T_UpLuck", Callback = function(v) _G.AutoUpgradeLuck = v end})
TabUpgrades:CreateToggle({Name = "⚔️ Auto Upgrade Damage Buff", Flag = "T_UpDmg", Callback = function(v) _G.AutoUpgradeDamage = v end})
TabUpgrades:CreateToggle({Name = "🎒 Auto Upgrade Inventory Space", Flag = "T_UpInv", Callback = function(v) _G.AutoUpgradeInventory = v end})
TabUpgrades:CreateToggle({Name = "⚡ Auto Upgrade Roll Speed", Flag = "T_UpRSpd", Callback = function(v) _G.AutoUpgradeRollSpeed = v end})
TabUpgrades:CreateToggle({Name = "👟 Auto Upgrade Walk Speed", Flag = "T_UpWSpd", Callback = function(v) _G.AutoUpgradeWalkSpeed = v end})

TabUpgrades:CreateSection("🎲 Upgrade Unit, Dadu & Rebirth")
TabUpgrades:CreateToggle({Name = "📈 Auto Level Up Units", Flag = "T_LvlBrain", Callback = function(v) _G.AutoUpgradeBrainrot = v end})
TabUpgrades:CreateToggle({Name = "📈 Auto Level Up Dice", Flag = "T_LvlDice", Callback = function(v) _G.AutoUpgradeDice = v end})
TabUpgrades:CreateToggle({Name = "🎲 Auto Buy Dice", Flag = "T_Buy", Callback = function(v) _G.AutoBuyDice = v end})
TabUpgrades:CreateToggle({Name = "🔄 Auto Rebirth", Flag = "T_Reb", Callback = function(v) _G.AutoRebirth = v end})

-- ------------------------------------------------------- --
-- TAB 3: MENARA & BOSS --
-- ------------------------------------------------------- --
TabBattle:CreateSection("👹 Pertarungan Boss & Dungeon")
TabBattle:CreateToggle({
    Name = "⚔️ Auto Fight Boss State",
    Flag = "T_FightBoss",
    Callback = function(v)
        _G.AutoFightBoss = v
        safeFire("SetAutoFightBoss", v)
    end
})
TabBattle:CreateToggle({Name = "💥 Auto Boss Attack Loop", Flag = "T_BossAtk", Callback = function(v) _G.AutoBossAttack = v end})

TabBattle:CreateSection("🗼 Struktur Menara Dadu")
TabBattle:CreateToggle({Name = "🗼 Auto Place Brainrot / Menara", Flag = "T_AutoTower", Callback = function(v) _G.AutoTower = v end})
TabBattle:CreateToggle({Name = "🌀 Auto Mix / Combine Dadu Menara", Flag = "T_MixTower", Callback = function(v) _G.AutoMixTower = v end})

TabBattle:CreateSection("🎁 Misi & Hadiah Event")
TabBattle:CreateToggle({Name = "🎁 Auto Claim All Quests", Flag = "T_ClaimAll", Callback = function(v) _G.AutoClaimAllRewards = v end})
TabBattle:CreateButton({Name = "📜 Request Status Quest", Callback = function() safeFire("RequestQuestState") end})
TabBattle:CreateToggle({Name = "☄️ Auto Claim Meteor", Flag = "T_Met", Callback = function(v) _G.AutoMeteor = v end})
TabBattle:CreateToggle({Name = "📦 Auto Lucky Block", Flag = "T_LuckB", Callback = function(v) _G.AutoLuckyBlock = v end})

-- ------------------------------------------------------- --
-- TAB 4: TELEPORT & TOKO --
-- ------------------------------------------------------- --
TabTeleport:CreateSection("📍 Area Teleportasi")
TabTeleport:CreateButton({Name = "🏠 Teleport Base Saya", Callback = function() safeFire("RequestMyBaseSpawn") end})
TabTeleport:CreateButton({Name = "🏙️ Teleport Hub Center", Callback = function() safeFire("RequestHubSpawn") end})
TabTeleport:CreateButton({Name = "🏪 Teleport Pasar / Market", Callback = function() safeFire("RequestMarketSpawn") end})
TabTeleport:CreateButton({Name = "🏰 Teleport Dungeon Battle 1", Callback = function() safeFire("RequestDungeonTeleport", "Battle1") end})

TabTeleport:CreateSection("🛒 Potion & Toko Game")
TabTeleport:CreateToggle({Name = "🧪 Auto Boost / Potion", Flag = "T_Boost", Callback = function(v) _G.AutoBoost = v end})
TabTeleport:CreateButton({Name = "🛒 Buka Shop Dungeon", Callback = function() safeFire("DungeonShopState") end})
TabTeleport:CreateButton({Name = "🎒 Refresh Data Inventaris", Callback = function() safeFire("RequestInventorySnapshot") end})

-- ------------------------------------------------------- --
-- TAB 5: SISTEM & SPY --
-- ------------------------------------------------------- --
TabSystem:CreateSection("🔍 Alat Analisis & Debug")
TabSystem:CreateToggle({
    Name = "👁️ Aktifkan Ultra Deep Spy (Cek F9)",
    CurrentValue = false,
    Callback = function(v) _G.SpyEnabled = v end
})

TabSystem:CreateSection("🌐 Jaringan & Keamanan")
TabSystem:CreateButton({Name = "🌐 Server Hop Manual", Callback = function() hopServer() end})
TabSystem:CreateToggle({
    Name = "🌐 Auto Hop Server (Tiap 5 Menit)",
    CurrentValue = false,
    Callback = function(v)
        _G.AutoHop = v
        if v then
            task.spawn(function()
                task.wait(300)
                if _G.AutoHop then hopServer() end
            end)
        end
    end
})

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

-- ======================================================= --
-- LOOPS EKSEKUSI UTAMA --
-- ======================================================= --
task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoBossAttack then safeFire("BossAttack") end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoRoll then safeFire("RollRequest") end
        if _G.InstantRoll and _G.AutoRoll then
            safeFire("RollRequest")
        end
        if _G.AutoRerollGrade then safeFire("RerollGradeRequest") end
        if _G.AutoRerollTrait then safeFire("SpinTraitRequest") end
        if _G.AutoBoost then safeFire("UseItemRequest", "LuckPotion_I") end
    end
end)

task.spawn(function()
    while task.wait(0.8) do
        handleTowerSystem()
    end
end)

task.spawn(function()
    while task.wait(2.5) do
        if _G.AutoUpgradeLuck then safeFire("UpgradeLuckBuffRequest") end
        if _G.AutoUpgradeDamage then safeFire("UpgradeDamageBuffRequest") end
        if _G.AutoUpgradeInventory then safeFire("UpgradeInventorySpaceRequest") end
        if _G.AutoUpgradeRollSpeed then safeFire("UpgradeRollSpeedRequest") end
        if _G.AutoUpgradeWalkSpeed then
            safeFire("UpgradeWalkSpeedRequest")
            safeFire("RequestWalkSpeedState")
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if _G.AutoUpgradeBrainrot then safeFire("UpgradeBrainrotRequest", 40) end
        if _G.AutoUpgradeDice then safeFire("UpgradeDiceRequest", 36) end
        if _G.AutoBuyDice then safeFire("BuyDiceRequest") end
        if _G.AutoRebirth then safeFire("RebirthRequest") end
        if _G.AutoEquipBest then
            safeFire("EquipBest")
            safeFire("EquipBestBattleSquadRequest")
        end
        if _G.AutoClaimAllRewards then
            safeFire("ClaimAllQuests")
            safeFire("RequestQuestState")
        end
        if _G.AutoMeteor then safeFire("MeteorClaimed") end
        if _G.AutoLuckyBlock then safeFire("OpenLuckyBlocks") end
    end
end)

Rayfield:LoadConfiguration()
