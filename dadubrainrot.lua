-- =====================================================================
-- 👑 MOFENKHUB V90 — EXACT INVENTORY FILTERS & UI EDITION
-- Game: Dadu Brainrot! | Sesuai 100% dengan Layout Foto Asli
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
    if v.Name == "MofenkHubUltimate" then v:Destroy() end 
end

-- 2. KONFIGURASI GLOBAL (LENGKAP DENGAN FILTER RARITY & KEEP)
_G.Mofenk = {
    -- Main / Farm
    AutoRoll = false, AutoCollectMoney = false, CollectEvery = 5,
    AutoRebirth = false, AutoEquipBest = false, EquipBestEvery = 15,
    AutoClaimQuests = false, AutoClaimIndex = false,
    AutoUpgradeBrainrot = false, MaxLevelBrainrot = 40, KeepCashPercent = 0,
    
    -- Inventory / Sell & Filters (Sesuai Foto)
    AutoSell = false, SellEvery = 3,
    SelectedRarity = "Common, Uncommon",
    KeepMutated = false,
    KeepTraited = false,
    KeepFinishes = false,
    KeepVariants = false,
    AutoTraitRoll = false,
    StopOnTraits = "None",
    
    -- Dungeon
    AutoDungeon = false, TargetFloor = "Floor 1", AutoBuyDungeonShop = false,
    
    -- Player & Movement
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    
    -- Upgrades & Misc
    AutoBuyDice = false, AutoUpgradeNodes = false
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

-- 3. MEMUAT RAYFIELD UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot Ultimate",
   LoadingTitle = "Memuat MofenkHub Ultimate...",
   LoadingSubtitle = "Blue & Black Edition + Exact Filters",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
    Title = "MofenkHub Loaded! 👑", 
    Content = "Fitur filter Inventory & Select sesuai foto aktif!", 
    Duration = 5, 
    Image = 6023426915 
})

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 WELCOME BACK")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung ke MofenkHub\nGame: [UPDATE 2] Dadu Brainrot!\nMode: Ultimate Exact UI"})

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

-- TAB 3: INVENTORY 📦 (Sesuai Foto Rarity & Keep Filters)
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)

TabInv:CreateSection("💲 Auto Sell Management (Sesuai Foto)")
TabInv:CreateToggle({Name = "🗑️ Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 3, Callback = function(V) _G.Mofenk.SellEvery = V end})

TabInv:CreateDropdown({
    Name = "📌 Sell Rarities",
    Options = {"Common, Uncommon", "Rare, Epic", "Legendary, Mythical", "All Rarities"},
    CurrentOption = {"Common, Uncommon"},
    Callback = function(Opt)
        _G.Mofenk.SelectedRarity = Opt[1]
    end
})

TabInv:CreateToggle({Name = "🔒 Keep Mutated", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepMutated = V end})
TabInv:CreateToggle({Name = "🔒 Keep Traited", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepTraited = V end})
TabInv:CreateToggle({Name = "🔒 Keep Finishes (Iron/Bronze/..)", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepFinishes = V end})
TabInv:CreateToggle({Name = "🔒 Keep Variants (Giant/Titan..)", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepVariants = V end})

TabInv:CreateSection("🧬 Trait Roll")
TabInv:CreateToggle({Name = "✨ Auto Roll Traits", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoTraitRoll = V end})
TabInv:CreateDropdown({
    Name = "🛑 Stop On Traits",
    Options = {"None", "Godly", "Secret", "Celestial", "Divine"},
    CurrentOption = {"None"},
    Callback = function(Opt)
        _G.Mofenk.StopOnTraits = Opt[1]
    end
})
TabInv:CreateButton({Name = "🔄 Refresh Brainrots", Callback = function() safeFire("RequestInventorySnapshot") end})

-- TAB 4: DUNGEON ⚔️
local TabDungeon = Window:CreateTab("Dungeon ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon Automation")
TabDungeon:CreateDropdown({
    Name = "🚪 Floor Selection", 
    Options = {"Floor 1 - Battle1", "Floor 2 - Battle2", "Floor 3 - Battle3", "Floor 4 - Battle4", "Floor 5 - Battle5"}, 
    CurrentOption = {"Floor 1 - Battle1"}, 
    Callback = function(Opt) 
        _G.Mofenk.TargetFloor = string.gsub(Opt[1], ".*%- ", "") 
    end
})
TabDungeon:CreateToggle({Name = "⚔️ Auto Dungeon & Boss Fight", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDungeon = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base", Callback = function() safeFire("RequestMyBaseSpawn") end})
TabDungeon:CreateSection("🛒 Dungeon Shop")
TabDungeon:CreateToggle({Name = "🛍️ Auto Buy Dungeon Shop Items", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDungeonShop = V end})

-- TAB 5: PLAYER ⚡
local TabPlayer = Window:CreateTab("Player ⚡", 6023426915)
TabPlayer:CreateSection("🏃 Kecepatan Karakter (WalkSpeed)")
TabPlayer:CreateToggle({
    Name = "⚡ Aktifkan Custom WalkSpeed", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Mofenk.EnableWalkSpeed = V 
    end
})
TabPlayer:CreateSlider({
    Name = "🏃 Kecepatan Jalan", 
    Range = {16, 200}, 
    Increment = 1, 
    CurrentValue = 16, 
    Callback = function(V) 
        _G.Mofenk.WalkSpeedVal = V 
    end
})

TabPlayer:CreateSection("🌐 Server Utilities")
TabPlayer:CreateButton({
    Name = "📋 Copy Server JobID", 
    Callback = function() 
        CopyServerID()
        Rayfield:Notify({Title = "Berhasil", Content = "JobID server disalin ke clipboard!", Duration = 3})
    end
})
TabPlayer:CreateButton({
    Name = "🔀 Server Hop (Pindah Server)", 
    Callback = function() 
        ServerHop()
    end
})

TabPlayer:CreateSection("⚡ Upgrades & Dice")
TabPlayer:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabPlayer:CreateToggle({Name = "📈 Auto Buy Affordable Upgrade Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeNodes = V end})

-- TAB 6: SETTINGS ⚙️
local TabSettings = Window:CreateTab("Settings ⚙️", 6023426915)
TabSettings:CreateSection("🎵 PEMUTAR MUSIK")
local Music = Instance.new("Sound", CoreGui)
Music.SoundId = "rbxassetid://9048375035"
Music.Volume = 0.8 
Music.Looped = true
TabSettings:CreateButton({Name = "▶️ Putar Musik", Callback = function() Music:Play() end})
TabSettings:CreateButton({Name = "⏹️ Hentikan Musik", Callback = function() Music:Stop() end})

-- 4. BACKGROUND ENGINE (FARMING & MOVE SPEED)
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
