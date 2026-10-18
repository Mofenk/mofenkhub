-- ==================================================================== --
-- 👑 FIKRAH HUB V36 - MASTERPIECE ULTIMATE EDITION (FULL UNCOMPRESSED)
-- Game: Dadu Brainrot! | Fitur: 100% Data Synced, Spy, Auto Reconnect
-- ==================================================================== --

local successUI, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successUI or not Rayfield then
    task.wait(1)
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ======================================================= --
-- 1. FUNGSI UTILITAS LENGKAP (KEMBALI KE V30.4 ASLI)
-- ======================================================= --
local function notifyUI(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "👑 Fikrah Hub",
            Text = text or "",
            Duration = duration or 3,
            Button1 = "OK"
        })
    end)
end

local function tryRequireModule(pathSegments)
    local ok, mod
    pcall(function()
        local node = ReplicatedStorage
        for _, seg in ipairs(pathSegments) do
            node = node:FindFirstChild(seg)
            if not node then return end
        end
        mod = require(node)
        ok = true
    end)
    return ok and mod or nil
end

local function getRemote(name)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == tostring(name):lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

local function safeFire(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote then
        if _G.Fikrah.SpyEnabled then
            warn("[Fikrah Spy] Remote Fired: " .. tostring(remoteName))
        end
        pcall(function(...)
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end, ...)
    end
end

local function safeInvoke(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote and remote:IsA("RemoteFunction") then
        local ok, res = pcall(function(...) return remote:InvokeServer(...) end, ...)
        return ok and res or nil
    end
    return nil
end

-- ======================================================= --
-- 2. SINKRONISASI 100% SEMUA MODUL GAME
-- ======================================================= --
local GameData = {
    BattleSquad = tryRequireModule({"Shared", "BattleSquadConfig"}),
    Dungeon = tryRequireModule({"Shared", "DungeonConfig"}),
    Inventory = tryRequireModule({"Modules", "InventoryConfig"}),
    BrainrotLevel = tryRequireModule({"Modules", "BrainrotLevelConfig"}),
    Trait = tryRequireModule({"Modules", "TraitConfig"}),
    Quest = tryRequireModule({"Modules", "QuestConfig"}) or tryRequireModule({"QuestConfig"}),
    CandyShop = tryRequireModule({"ReleasedContent", "Update2", "Client", "CandyShop"}) or tryRequireModule({"CandyShop"})
}

-- ======================================================= --
-- 3. DATABASE STATE UTAMA
-- ======================================================= --
_G.Fikrah = {
    -- Uang & Gacha
    AutoCollect = false, CollectDelay = 1.0,
    AutoRoll = false, InstantRoll = false, AutoTrait = false, AutoGrade = false,
    
    -- Manajemen Unit
    AutoEquipBest = false, AutoLock = false,
    
    -- Auto Sell
    AutoSellUnder = false, SellThreshold = 100000, AutoSellJunk = false,
    AutoSellByRarity = false, SellRarities = {},
    AutoSellByName = false, SellNames = {},
    
    -- Level & Rebirth
    AutoUpBrainrot = false, BrainrotMax = 38,
    AutoUpDice = false, DiceMax = 38, AutoBuyDice = false, AutoRebirth = false,
    
    -- Tower & Boss
    AutoJoinTower = false, AutoMixTower = false, AutoPlaceTower = false, AutoBoss = false,
    
    -- Event & Boost
    AutoQuest = false, AutoCandy = false, AutoMeteor = false, AutoLuckyBlock = false, AutoBoost = false,
    
    -- Keamanan & Sistem
    AutoReconnect = true, ReduceCPU = false, SpyEnabled = false, AutoHop = false
}

-- ======================================================= --
-- 4. ANTARMUKA RAYFIELD (FULL BANYAK KATEGORI)
-- ======================================================= --
local Window = Rayfield:CreateWindow({
    Name = "👑 Fikrah Hub V36 | Dadu Brainrot",
    LoadingTitle = "Memuat Full Masterpiece Edition...",
    LoadingSubtitle = "Menyinkronkan semua data remote...",
    ConfigurationSaving = { Enabled = true, FolderName = "FikrahV36", FileName = LocalPlayer.Name },
    KeySystem = false
})

local TabInfo = Window:CreateTab("🏠 Beranda", 4483345998)
local TabFarm = Window:CreateTab("💰 Farm & Gacha", 4483345998)
local TabUnit = Window:CreateTab("🎒 Unit & Equip", 4483345998)
local TabSell = Window:CreateTab("🗑️ Auto Sell Cerdas", 4483345998)
local TabUp = Window:CreateTab("📈 Level & Upgrade", 4483345998)
local TabTower = Window:CreateTab("🗼 Tower & Arena", 4483345998)
local TabEvent = Window:CreateTab("🎯 Event & Hadiah", 4483345998)
local TabSys = Window:CreateTab("⚙️ System & Optimasi", 4483345998)

-- --- TAB: BERANDA ---
TabInfo:CreateSection("Status Sinkronisasi Game Data")
TabInfo:CreateLabel("Battle Squad Module: " .. (GameData.BattleSquad and "✅ Aktif" or "❌ Gagal"))
TabInfo:CreateLabel("Brainrot Level Module: " .. (GameData.BrainrotLevel and "✅ Aktif" or "❌ Gagal"))
TabInfo:CreateLabel("Quest Module: " .. (GameData.Quest and "✅ Aktif" or "❌ Gagal"))
TabInfo:CreateLabel("Candy Shop Module: " .. (GameData.CandyShop and "✅ Aktif" or "❌ Gagal"))

-- --- TAB: FARM & GACHA ---
TabFarm:CreateSection("💸 Ekstraktor Uang")
TabFarm:CreateToggle({Name = "Auto Collect Cash & Item (Magnet Extreme)", Flag = "T_Collect", Callback = function(v) _G.Fikrah.AutoCollect = v end})
TabFarm:CreateSlider({Name = "Kecepatan Collect (Detik)", Range = {0.5, 5.0}, Increment = 0.5, CurrentValue = 1.0, Flag = "S_Delay", Callback = function(v) _G.Fikrah.CollectDelay = v end})

TabFarm:CreateSection("🎲 Automasi Gacha")
TabFarm:CreateToggle({Name = "Auto Roll Dadu", Flag = "T_Roll", Callback = function(v) _G.Fikrah.AutoRoll = v end})
TabFarm:CreateToggle({Name = "Instant Roll (Skip Animasi)", Flag = "T_InstaRoll", Callback = function(v) _G.Fikrah.InstantRoll = v end})
TabFarm:CreateToggle({Name = "Auto Reroll Grade", Flag = "T_Grade", Callback = function(v) _G.Fikrah.AutoGrade = v end})
TabFarm:CreateToggle({Name = "Auto Reroll Trait", Flag = "T_Trait", Callback = function(v) _G.Fikrah.AutoTrait = v end})

-- --- TAB: UNIT & EQUIP ---
TabUnit:CreateSection("Manajemen Pasukan Tempur")
TabUnit:CreateToggle({Name = "Auto Equip Unit Terbaik (Best Squad)", Flag = "T_Equip", Callback = function(v) _G.Fikrah.AutoEquipBest = v end})
TabUnit:CreateToggle({Name = "Auto Lock / Kunci Unit Terbaik", Flag = "T_Lock", Callback = function(v) _G.Fikrah.AutoLock = v end})

-- --- TAB: AUTO SELL CERDAS ---
TabSell:CreateSection("Sapu Bersih Otomatis")
TabSell:CreateToggle({Name = "Auto Sell Semua Sampah (Junk)", Flag = "T_SellJunk", Callback = function(v) _G.Fikrah.AutoSellJunk = v end})
TabSell:CreateToggle({Name = "Auto Sell di Bawah Threshold", Flag = "T_SellUnder", Callback = function(v) _G.Fikrah.AutoSellUnder = v end})
TabSell:CreateSlider({Name = "Batas Threshold", Range = {1000, 10000000}, Increment = 5000, CurrentValue = 100000, Flag = "S_Thresh", Callback = function(v) _G.Fikrah.SellThreshold = v end})

TabSell:CreateSection("Filter Rarity Otomatis (Tanpa Ketik)")
TabSell:CreateDropdown({
    Name = "Pilih Rarity yang Dijual",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Prismatic"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "D_Rarity",
    Callback = function(Options) _G.Fikrah.SellRarities = Options end,
})
TabSell:CreateToggle({Name = "Enable Auto Sell by Rarity", Flag = "T_SellRarity", Callback = function(v) _G.Fikrah.AutoSellByRarity = v end})

TabSell:CreateSection("Input Manual (Grup Khusus)")
TabSell:CreateInput({Name = "Ketik Nama Unit Spesifik (Pisah Koma)", PlaceholderText = "Contoh: Mewing,Skibidi", RemoveTextAfterFocus = true, Callback = function(txt)
    _G.Fikrah.SellNames = {}
    for s in string.gmatch(txt, "[^,]+") do table.insert(_G.Fikrah.SellNames, s:gsub("^%s+",""):gsub("%s+$","")) end
    notifyUI("Tersimpan", "Nama spesifik berhasil diatur.")
end})
TabSell:CreateToggle({Name = "Enable Auto Sell By Name", Flag = "T_SellName", Callback = function(v) _G.Fikrah.AutoSellByName = v end})

-- --- TAB: LEVEL & UPGRADE ---
TabUp:CreateSection("Sistem Leveling Maksimal")
TabUp:CreateToggle({Name = "Auto Upgrade Brainrot", Flag = "T_UpBrainrot", Callback = function(v) _G.Fikrah.AutoUpBrainrot = v end})
TabUp:CreateToggle({Name = "Auto Upgrade Dadu (Dice)", Flag = "T_UpDice", Callback = function(v) _G.Fikrah.AutoUpDice = v end})
TabUp:CreateToggle({Name = "Auto Beli Dadu", Flag = "T_BuyDice", Callback = function(v) _G.Fikrah.AutoBuyDice = v end})
TabUp:CreateToggle({Name = "Auto Rebirth (Siklus Ulang)", Flag = "T_Rebirth", Callback = function(v) _G.Fikrah.AutoRebirth = v end})

-- --- TAB: TOWER & ARENA ---
TabTower:CreateSection("Otomatisasi Medan Tempur")
TabTower:CreateToggle({Name = "Auto Join Tower Queue", Flag = "T_JoinTower", Callback = function(v) _G.Fikrah.AutoJoinTower = v end})
TabTower:CreateToggle({Name = "Auto Mix/Merge Unit di Arena", Flag = "T_MixTower", Callback = function(v) _G.Fikrah.AutoMixTower = v end})
TabTower:CreateToggle({Name = "Auto Place Unit (Tebar Pasukan)", Flag = "T_PlaceTower", Callback = function(v) _G.Fikrah.AutoPlaceTower = v end})
TabTower:CreateToggle({Name = "Auto Serang Boss (Boss Attack)", Flag = "T_Boss", Callback = function(v) _G.Fikrah.AutoBoss = v end})

-- --- TAB: EVENT & HADIAH ---
TabEvent:CreateSection("Klaim Hadiah Massal")
TabEvent:CreateToggle({Name = "Auto Claim All Quests (Terkait Modul)", Flag = "T_Quest", Callback = function(v) _G.Fikrah.AutoQuest = v end})
TabEvent:CreateToggle({Name = "Auto Farming Candy Shop Event", Flag = "T_Candy", Callback = function(v) _G.Fikrah.AutoCandy = v end})
TabEvent:CreateToggle({Name = "Auto Klaim Meteor Drop", Flag = "T_Meteor", Callback = function(v) _G.Fikrah.AutoMeteor = v end})
TabEvent:CreateToggle({Name = "Auto Buka Lucky Block", Flag = "T_Lucky", Callback = function(v) _G.Fikrah.AutoLuckyBlock = v end})
TabEvent:CreateToggle({Name = "Auto Gunakan Potion / Boost Item", Flag = "T_Boost", Callback = function(v) _G.Fikrah.AutoBoost = v end})

-- --- TAB: SISTEM & OPTIMASI ---
TabSys:CreateSection("Keamanan & Debugging (Khusus Dev)")
TabSys:CreateToggle({Name = "🕵️ Enable Remote Spy (Cetak di F9/Console)", Flag = "T_Spy", Callback = function(v) _G.Fikrah.SpyEnabled = v end})

TabSys:CreateSection("Stabilitas Bot & Cloud Phone")
TabSys:CreateToggle({
    Name = "📉 Reduce CPU Extreme (Hapus Render 3D)",
    Flag = "T_CPU",
    Callback = function(v)
        _G.Fikrah.ReduceCPU = v
        RunService:Set3dRenderingEnabled(not v)
        if v then
            settings().Rendering.QualityLevel = "Level01"
            game.Lighting.GlobalShadows = false
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                    obj.Material = Enum.Material.SmoothPlastic
                elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then
                    obj:Destroy()
                end
            end
        end
    end
})
TabSys:CreateToggle({Name = "🔄 Auto Reconnect (Tahan Bypass Error DC)", CurrentValue = true, Flag = "T_Reconnect", Callback = function(v) _G.Fikrah.AutoReconnect = v end})
TabSys:CreateButton({Name = "🌐 Server Hop (Cari Server Sepi)", Callback = function()
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, server in ipairs(Servers) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
        end
    end
end})

-- ======================================================= --
-- 5. BACKGROUND LOOPS (INTI MESIN GAME)
-- ======================================================= --

-- Anti-AFK Original
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Auto Reconnect Trigger
game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if _G.Fikrah.AutoReconnect and child.Name == "ErrorPrompt" then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Loop Cepat: Collect & Gacha
task.spawn(function()
    while task.wait(_G.Fikrah.CollectDelay) do
        if _G.Fikrah.AutoCollect then
            -- Panggil semua remote terkait uang seperti V30.4
            safeFire("MoneyCollected") safeFire("RequestMoneyBuffState")
            safeFire("ClaimCash") safeFire("CollectMoney") 
            safeFire("ClaimMoney") safeFire("ClaimIncome")
            
            -- Magnet CFrame Detail
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local dropFolders = {Workspace:FindFirstChild("Bases"), Workspace:FindFirstChild("Plots"), Workspace:FindFirstChild("Drops"), Workspace}
                    
                    for _, folder in pairs(dropFolders) do
                        if folder then
                            for _, obj in pairs(folder:GetDescendants()) do
                                if obj:IsA("BasePart") or obj:IsA("Model") then
                                    local n = obj.Name:lower()
                                    if n:find("cash") or n:find("money") or n:find("drop") or n:find("coin") or n:find("candy") then
                                        local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                        if targetPart then
                                            targetPart.CFrame = root.CFrame
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
        
        if _G.Fikrah.AutoRoll then safeFire("RollRequest") end
        if _G.Fikrah.InstantRoll and _G.Fikrah.AutoRoll then safeFire("RollRequest") end
        if _G.Fikrah.AutoGrade then safeFire("RerollGradeRequest") end
        if _G.Fikrah.AutoTrait then safeFire("SpinTraitRequest") end
        if _G.Fikrah.AutoBoss then safeFire("BossAttack") end
    end
end)

-- Loop Menengah: Manajemen, Sell, Tower
task.spawn(function()
    while task.wait(1.5) do
        if _G.Fikrah.AutoEquipBest then safeFire("EquipBest") safeFire("EquipBestBattleSquadRequest") end
        if _G.Fikrah.AutoLock then safeFire("ToggleLockRequest") end
        
        if _G.Fikrah.AutoSellUnder then safeFire("SetAutoSellUnderRequest", _G.Fikrah.SellThreshold, true) end
        if _G.Fikrah.AutoSellJunk then safeFire("SellAllJunkRequest") safeFire("SellJunkUnits") end
        
        if _G.Fikrah.AutoSellByRarity and #_G.Fikrah.SellRarities > 0 then
            for _, r in ipairs(_G.Fikrah.SellRarities) do 
                safeFire("SellByRarity", r)
                safeFire("SellBrainrotByRarity", r)
            end
        end
        if _G.Fikrah.AutoSellByName and #_G.Fikrah.SellNames > 0 then
            for _, n in ipairs(_G.Fikrah.SellNames) do 
                safeFire("SellSpecificByName", n)
                safeFire("SellUnitByName", n)
            end
        end

        if _G.Fikrah.AutoJoinTower then safeFire("JoinTowerQueue") safeFire("RequestJoinTower") end
        if _G.Fikrah.AutoMixTower then safeFire("MixTowerRequest") safeFire("MergeTowerUnits") end
        if _G.Fikrah.AutoPlaceTower then safeFire("PlaceBrainrot") safeFire("SpawnTowerRequest") end
    end
end)

-- Loop Lambat: Upgrade, Event, Item
task.spawn(function()
    while task.wait(3.0) do
        if _G.Fikrah.AutoUpBrainrot then safeFire("UpgradeBrainrotRequest", _G.Fikrah.BrainrotMax) end
        if _G.Fikrah.AutoUpDice then safeFire("UpgradeDiceRequest", _G.Fikrah.DiceMax) end
        if _G.Fikrah.AutoBuyDice then safeFire("BuyDiceRequest") end
        if _G.Fikrah.AutoRebirth then safeFire("RebirthRequest") end
        
        if _G.Fikrah.AutoMeteor then safeFire("MeteorClaimed") end
        if _G.Fikrah.AutoLuckyBlock then safeFire("OpenLuckyBlocks", "LuckyBlock") end
        if _G.Fikrah.AutoBoost then 
            safeFire("UsePotionRequest") 
            safeFire("ActivateBoostRequest", "Semua Item / Potion")
            safeFire("ClaimActiveBoosts") 
        end
        
        if _G.Fikrah.AutoQuest then 
            safeFire("CollectAllQuests") 
            safeFire("ClaimAllQuests") 
            safeFire("CollectAllReward")
            if GameData.Quest and type(GameData.Quest.GetActiveDailyQuests) == "function" then
                pcall(function() for id, _ in pairs(GameData.Quest.GetActiveDailyQuests()) do safeFire("ClaimQuest", id) end end)
            end
        end

        if _G.Fikrah.AutoCandy then 
            if GameData.CandyShop and GameData.CandyShop.Start then pcall(function() GameData.CandyShop.Start() end) end
            safeFire("StartCandyEvent") 
            safeFire("ClaimCandyRewards") 
        end
    end
end)

Rayfield:LoadConfiguration()
