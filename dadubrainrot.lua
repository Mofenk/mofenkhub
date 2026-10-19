-- =====================================================================
-- 👑 MOFENKHUB V80 — THE TRUE OUROBOROS (194 DATA SYNCED)
-- Game: Dadu Brainrot! | UI Premium Rayfield + Full Hidden Remotes
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. KONFIGURASI GLOBAL (SESUAI OUROBOROS)
-- ==========================================
_G.Mofenk = {
    -- Main 
    AutoRoll = false, AutoCollectMoney = false, CollectEvery = 5,
    AutoEquipBest = false, EquipBestEvery = 15, AutoRebirth = false,
    AutoClaimQuests = false, AutoClaimIndex = false, AutoPlaytime = false, AutoWheel = false,
    AutoUpgradePlaced = false, MaxLevel = 40, KeepCash = 0,
    AutoBuyDice = false, AutoBuyAffordable = false, SkipBranches = "None",
    
    -- Inventory
    AutoSell = false, SellEvery = 20, 
    KeepMutated = true, KeepTraited = true, KeepFinishes = false, KeepVariants = false,
    SelectedRarities = {}, NeverSell = {}, AutoRollTraits = false, StopOnTraits = {},
    AutoMutate = false,
    
    -- Live Notif
    LiveNotif = true, NotifRarities = {"Mythical", "Divine", "Radiant", "Celestial", "Fortuna Suprema"},
    
    -- Dungeon
    AutoDungeon = false, TargetFloor = "Battle1", 
    AutoBuyDungeonShop = false, ShopItems = {}
}

-- ==========================================
-- 2. ENGINE REMOTES (ANTI-FREEZE TASK.SPAWN)
-- ==========================================
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

-- ==========================================
-- 3. MEMUAT RAYFIELD UI (TEMA OUROBOROS)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Ouroboros | Dadu Brainrot",
   LoadingTitle = "Memuat Ouroboros...",
   LoadingSubtitle = "V80 - Ultimate Data Synced",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({Title = "Ouroboros Loaded", Content = "UI Modern + 194 Data Game aktif!", Duration = 4, Image = 13047715178})

-- ==========================================
-- TAB 1: HOME (LIVE DASHBOARD)
-- ==========================================
local TabHome = Window:CreateTab("Home", 4483362458)
TabHome:CreateLabel("WELCOME BACK, " .. LocalPlayer.DisplayName)
local DashOverview = TabHome:CreateParagraph({Title = "📊 Overview", Content = "Memuat..."})
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            local cash = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Cash") and LocalPlayer.leaderstats.Cash.Value or "0"
            DashOverview:Set({Title = "📊 Overview (Live)", Content = "Ping Server: " .. ping .. " ms\nCash (Uang): " .. tostring(cash)})
        end)
    end
end)

-- ==========================================
-- TAB 2: MAIN (Sesuai Screenshot Ouroboros)
-- ==========================================
local TabMain = Window:CreateTab("Main", 7733658504)

local SecFarm = TabMain:CreateSection("🔄 Farm")
TabMain:CreateToggle({Name = "Auto Roll", CurrentValue = false, Flag = "AutoRoll", Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "Auto Collect Money", CurrentValue = false, Flag = "AutoCollectMoney", Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "Collect Every (s)", Range = {1, 60}, Increment = 1, Suffix = "s", CurrentValue = 5, Flag = "CollectEvery", Callback = function(V) _G.Mofenk.CollectEvery = V end})
TabMain:CreateToggle({Name = "Auto Equip Best", CurrentValue = false, Flag = "AutoEquipBest", Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "Equip Best Every (s)", Range = {1, 60}, Increment = 1, Suffix = "s", CurrentValue = 15, Flag = "EquipEvery", Callback = function(V) _G.Mofenk.EquipBestEvery = V end})
TabMain:CreateToggle({Name = "Auto Rebirth", CurrentValue = false, Flag = "AutoRebirth", Callback = function(V) _G.Mofenk.AutoRebirth = V end})

local SecClaims = TabMain:CreateSection("🎁 Claims (Hidden Data Synced)")
TabMain:CreateToggle({Name = "Auto Claim Quests", CurrentValue = false, Flag = "AutoClaimQuests", Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "Auto Claim Index Rewards", CurrentValue = false, Flag = "AutoClaimIndex", Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "Auto Claim Playtime Gifts", CurrentValue = false, Flag = "AutoPlaytime", Callback = function(V) _G.Mofenk.AutoPlaytime = V end})
TabMain:CreateToggle({Name = "Auto Spin Wheel (Roda Putar)", CurrentValue = false, Flag = "AutoWheel", Callback = function(V) _G.Mofenk.AutoWheel = V end})

local SecUpgrades = TabMain:CreateSection("📈 Upgrades (Massive Sync)")
TabMain:CreateToggle({Name = "Auto Upgrade Placed Brainrots", CurrentValue = false, Flag = "AutoUpgradePlaced", Callback = function(V) _G.Mofenk.AutoUpgradePlaced = V end})
TabMain:CreateSlider({Name = "Max Level", Range = {1, 100}, Increment = 1, CurrentValue = 40, Flag = "MaxLevel", Callback = function(V) _G.Mofenk.MaxLevel = V end})
TabMain:CreateSlider({Name = "Keep Cash (%)", Range = {0, 100}, Increment = 1, Suffix = "%", CurrentValue = 0, Flag = "KeepCash", Callback = function(V) _G.Mofenk.KeepCash = V end})
TabMain:CreateToggle({Name = "Auto Buy Dice", CurrentValue = false, Flag = "AutoBuyDice", Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabMain:CreateToggle({Name = "Auto Buy Affordable Upgrade Nodes", CurrentValue = false, Flag = "AutoBuyAffordable", Callback = function(V) _G.Mofenk.AutoBuyAffordable = V end})
TabMain:CreateDropdown({Name = "Skip Branches", Options = {"None", "Branch A", "Branch B"}, CurrentOption = {"None"}, MultipleOptions = false, Flag = "SkipBranches", Callback = function(Opt) _G.Mofenk.SkipBranches = Opt[1] end})

-- ==========================================
-- TAB 3: INVENTORY (Sesuai Screenshot)
-- ==========================================
local TabInv = Window:CreateTab("Inventory", 13047715178)

local SecSell = TabInv:CreateSection("💲 Auto Sell")
TabInv:CreateToggle({Name = "Auto Sell", CurrentValue = false, Flag = "AutoSell", Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateDropdown({Name = "Sell Rarities", Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine", "Radiant", "Celestial", "Fortuna Suprema"}, CurrentOption = {}, MultipleOptions = true, Flag = "SellRarities", Callback = function(Opt) _G.Mofenk.SelectedRarities = Opt end})
TabInv:CreateDropdown({Name = "Never Sell", Options = {"None", "Divine", "Radiant", "Celestial", "Fortuna Suprema"}, CurrentOption = {"None"}, MultipleOptions = true, Flag = "NeverSell", Callback = function(Opt) _G.Mofenk.NeverSell = Opt end})
TabInv:CreateToggle({Name = "Keep Finishes (Iron/Bronze...)", CurrentValue = false, Flag = "KeepFinishes", Callback = function(V) _G.Mofenk.KeepFinishes = V end})
TabInv:CreateToggle({Name = "Keep Variants (Giant/Titan...)", CurrentValue = false, Flag = "KeepVariants", Callback = function(V) _G.Mofenk.KeepVariants = V end})
TabInv:CreateToggle({Name = "Keep Mutated", CurrentValue = true, Flag = "KeepMutated", Callback = function(V) _G.Mofenk.KeepMutated = V end})
TabInv:CreateToggle({Name = "Keep Traited", CurrentValue = true, Flag = "KeepTraited", Callback = function(V) _G.Mofenk.KeepTraited = V end})
TabInv:CreateSlider({Name = "Sell Every (s)", Range = {1, 60}, Increment = 1, Suffix = "s", CurrentValue = 20, Flag = "SellEvery", Callback = function(V) _G.Mofenk.SellEvery = V end})

local SecTrait = TabInv:CreateSection("🧬 Trait & Mutation Roll")
TabInv:CreateDropdown({Name = "Stop On Traits", Options = {"None", "Super Luck", "God Speed", "Wealth"}, CurrentOption = {"None"}, MultipleOptions = true, Flag = "StopOnTraits", Callback = function(Opt) _G.Mofenk.StopOnTraits = Opt end})
TabInv:CreateToggle({Name = "Auto Roll Traits", CurrentValue = false, Flag = "AutoRollTraits", Callback = function(V) _G.Mofenk.AutoRollTraits = V end})
TabInv:CreateToggle({Name = "Auto Apply Mutation", CurrentValue = false, Flag = "AutoMutate", Callback = function(V) _G.Mofenk.AutoMutate = V end})

-- ==========================================
-- TAB 4: DUNGEON (Sesuai Screenshot)
-- ==========================================
local TabDungeon = Window:CreateTab("Dungeon", 11311029191)

TabDungeon:CreateSection("⚔️ Auto Dungeon")
TabDungeon:CreateDropdown({Name = "Floor", Options = {"Floor 1 - NIL", "Floor 2 - NIL", "Floor 3 - NIL", "Floor 4 - NIL", "Floor 5 - NIL"}, CurrentOption = {"Floor 1 - NIL"}, MultipleOptions = false, Flag = "DungeonFloor", Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end})
TabDungeon:CreateToggle({Name = "Auto Dungeon", CurrentValue = false, Flag = "AutoDungeon", Callback = function(V) _G.Mofenk.AutoDungeon = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base", Callback = function() safeFire("RequestMyBaseSpawn") end})

TabDungeon:CreateSection("🛍️ Dungeon Shop")
TabDungeon:CreateDropdown({Name = "Items", Options = {"None", "Luck Potion", "Damage Boost", "Exp Boost"}, CurrentOption = {"None"}, MultipleOptions = true, Flag = "DungShopItems", Callback = function(Opt) _G.Mofenk.ShopItems = Opt end})
TabDungeon:CreateToggle({Name = "Auto Buy Dungeon Shop", CurrentValue = false, Flag = "AutoBuyDungeonShop", Callback = function(V) _G.Mofenk.AutoBuyDungeonShop = V end})

-- ==========================================
-- TAB 5: PLAYER & TELEPORT (Hidden Features)
-- ==========================================
local TabPlayer = Window:CreateTab("Player", 6031280882)
TabPlayer:CreateSection("🚀 Local Mods & Teleport")
TabPlayer:CreateButton({Name = "🌐 Teleport ke Hub Utama", Callback = function() safeFire("RequestHubSpawn") end})
TabPlayer:CreateToggle({Name = "Auto Open Lucky Blocks", CurrentValue = false, Flag = "LuckyBlocks", Callback = function(V) _G.Mofenk.AutoLuckyBlock = V end})
TabPlayer:CreateButton({Name = "🎁 Claim Group Chest", Callback = function() safeFire("ClaimGroupChest") end})

-- ==========================================
-- LIVE NOTIF LOGIC
-- ==========================================
local trackedItems = {}
LocalPlayer.PlayerGui.DescendantAdded:Connect(function(descendant)
    if _G.Mofenk.LiveNotif and descendant:IsA("TextLabel") then
        task.wait(0.2)
        local text = descendant.Text
        if text and text ~= "" and not trackedItems[text] then
            for _, rarity in ipairs(_G.Mofenk.NotifRarities) do
                if string.find(string.lower(text), string.lower(rarity)) then
                    trackedItems[text] = true
                    Rayfield:Notify({Title = "🎉 HOKI PARAH!", Content = "Mendapatkan: " .. rarity, Duration = 5, Image = 13047715178})
                    task.delay(10, function() trackedItems[text] = nil end)
                    break
                end
            end
        end
    end
end)

-- ==========================================
-- BACKGROUND FARMING LOOP (SYNCED W/ SLIDERS)
-- ==========================================
local lastCollect = os.time()
local lastEquip = os.time()
local lastSell = os.time()

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Eksekusi Cepat
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then safeFire("ClaimIndexReward") end
            if _G.Mofenk.AutoPlaytime then safeFire("ClaimPlaytimeGift") end
            if _G.Mofenk.AutoWheel then safeFire("WheelSpinRequest") end
            if _G.Mofenk.AutoBuyDungeonShop then safeFire("DungeonShopAutoBuy") end
            if _G.Mofenk.AutoRollTraits then safeFire("SpinTraitRequest") end
            if _G.Mofenk.AutoMutate then safeFire("ApplyMutationRequest") end
            if _G.Mofenk.AutoLuckyBlock then safeFire("OpenLuckyBlocks") end
            if _G.Mofenk.AutoBuyDice then safeFire("BuyDiceRequest") end
            
            -- Eksekusi Massive Upgrades
            if _G.Mofenk.AutoBuyAffordable then
                safeFire("UpgradeWalkSpeedRequest")
                safeFire("UpgradeMoneyBuffRequest")
                safeFire("UpgradeLuckBuffRequest")
                safeFire("UpgradeDamageBuffRequest")
                safeFire("UpgradeMultiRollRequest")
                safeFire("UpgradeRollSpeedRequest")
            end
            
            -- Eksekusi Berdasarkan Waktu (Slider)
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFire("MoneyCollected")
                lastCollect = os.time()
            end
            
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                safeFire("EquipBest")
                safeFire("EquipBestBattleSquadRequest")
                lastEquip = os.time()
            end
            
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                if #_G.Mofenk.SelectedRarities > 0 then
                    for _, rarity in ipairs(_G.Mofenk.SelectedRarities) do
                        safeFire("SellRarity", rarity, _G.Mofenk.KeepMutated, _G.Mofenk.KeepTraited, _G.Mofenk.KeepFinishes, _G.Mofenk.KeepVariants)
                    end
                end
                lastSell = os.time()
            end
            
            -- Eksekusi Dungeon
            if _G.Mofenk.AutoDungeon then
                local tFloor = "Battle1"
                if _G.Mofenk.TargetFloor:find("Floor 2") then tFloor = "Battle2"
                elseif _G.Mofenk.TargetFloor:find("Floor 3") then tFloor = "Battle3"
                elseif _G.Mofenk.TargetFloor:find("Floor 4") then tFloor = "Battle4"
                elseif _G.Mofenk.TargetFloor:find("Floor 5") then tFloor = "Battle5" end
                safeFire("RequestDungeonTeleport", tFloor)
                safeFire("SetAutoFightBoss")
                
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end
        end)
    end
end)

-- Anti AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)
