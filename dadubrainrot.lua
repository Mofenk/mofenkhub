-- =====================================================================
-- 👑 MOFENKHUB V107 — ULTIMATE CLEAN MASTERPIECE EDITION
-- Game: Dadu Brainrot! | Auto Claim Meteor, Base Collect & All Upgrades Fixed
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
    if v.Name == "MofenkHubUltimate" or v.Name == "MofenkSpyTerminal" then v:Destroy() end 
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
    MaxLevelBrainrot = 40,
    AutoCollectBase = false,
    AutoClaimMeteor = false, -- Fitur Baru Auto Claim Meteor
    AutoSell = false, 
    SellEvery = 3, 
    SelectedRarity = "Common, Uncommon",
    KeepMutated = false, KeepTraited = false,
    -- Dungeon & Gates
    AutoDungeon = false, 
    AutoJoinDungeon = false, 
    TargetFloor = "Battle1", 
    AutoBuyDungeonShop = false,
    AutoDragonGate = false,
    -- Automation
    AutoFuse = false,
    AutoWheelSpin = false,
    AutoClaimBossMilestones = false,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoBuyDice = false, 
    AutoUpgradeNodes = false,
    AutoReconnect = true,
    SpyEnabled = false
}

-- PENCARIAN REMOTES SECARA AMAN & DINAMIS
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function getRemote(name)
    if Remotes then
        return Remotes:FindFirstChild(name)
    end
    return nil
end

local function safeFire(remoteName, ...)
    local args = {...}
    task.spawn(function()
        pcall(function()
            local r = getRemote(remoteName)
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
-- 3. FUNGSI EKSEKUSI SPESIFIK & UPGRADE SEMUA
-- ==========================================
local function TriggerBaseCollection()
    pcall(function()
        -- Eksekusi Remote asli game untuk panen uang base
        safeFire("MoneyCollected")
        safeFire("CollectMoney")
        safeFire("ClaimCash")
        
        -- Interaksi otomatis dengan objek base / proximity / touch di workspace
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
            if string.find(name, "meteor") then
                if obj:IsA("ProximityPrompt") then
                    fireproximityprompt(obj)
                elseif obj:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                end
            end
        end
    end)
end

local function TriggerBrainrotUpgrades()
    pcall(function()
        for i = 1, 20 do
            safeFire("UpgradeBrainrotRequest", i)
        end
    end)
end

local function ExecuteAutoSell()
    pcall(function()
        safeFire("SellAllRequest", _G.Mofenk.SelectedRarity)
        safeFire("SetAutoSellUnderRequest", true, _G.Mofenk.KeepMutated)
    end)
end

-- ==========================================
-- 4. UTILITY SERVER & PROFIL
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
-- 5. ANTI-DC & ANTI-AFK
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
-- 6. UI RAYFIELD (CLEAN & ORGANIZED)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V107 Clean Masterpiece",
   LoadingTitle = "Memuat MofenkHub V107...",
   LoadingSubtitle = "Auto Meteor, Base Collect & All Upgrades Fixed",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V107 Loaded! 👑", Content = "Semua fitur berjalan dengan stabil!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 PROFIL & MONITOR")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung (V107 Clean)\nGame: [UPDATE 2] Dadu Brainrot!"})

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
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "🏆 Auto Claim Boss Milestones", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimBossMilestones = V end})
TabMain:CreateToggle({Name = "☄️ Auto Claim Meteor (Baru)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimMeteor = V end})
TabMain:CreateToggle({Name = "🎡 Auto Spin Wheel", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoWheelSpin = V end})
TabMain:CreateToggle({Name = "🧪 Auto Fuse Items/Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoFuse = V end})

TabMain:CreateSection("🏡 Base & Brainrot Upgrades (Fixed)")
TabMain:CreateToggle({Name = "🏡 Auto Collect Base Money (Fixed)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectBase = V end})
TabMain:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeBrainrot = V end})

-- TAB 3: INVENTORY & SHOP 📦
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("💲 Auto Sell Management")
TabInv:CreateToggle({Name = "🗑️ Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 3, Callback = function(V) _G.Mofenk.SellEvery = V end})
TabInv:CreateDropdown({
    Name = "📌 Pilih Sell Rarity",
    Options = {"Common, Uncommon", "Rare, Epic", "Legendary, Mythical", "Divine, Secret", "All Rarities"},
    CurrentOption = {"Common, Uncommon"},
    Callback = function(Opt) _G.Mofenk.SelectedRarity = Opt[1] end
})
TabInv:CreateToggle({Name = "🔒 Keep Mutated", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepMutated = V end})

TabInv:CreateSection("🎲 Toko & Upgrades")
TabInv:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabInv:CreateToggle({Name = "📈 Auto Buy Upgrade Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeNodes = V end})

-- TAB 4: DUNGEON & GATES ⚔️
local TabDungeon = Window:CreateTab("Dungeon & Gates ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon Automation")
TabDungeon:CreateDropdown({
    Name = "🚪 Pilih Floor Dungeon", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabDungeon:CreateToggle({Name = "🚪 Auto Join Dungeon (Gateway)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoJoinDungeon = V end})
TabDungeon:CreateToggle({Name = "⚔️ Auto Dungeon & Boss Fight", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDungeon = V end})
TabDungeon:CreateToggle({Name = "🐉 Auto Dragon Gate", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDragonGate = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base", Callback = function() safeFire("RequestMyBaseSpawn") end})

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

            -- Main Automated Loops
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest"); safeFire("Rebirth") end
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then safeFire("RequestIndexRewards") end
            if _G.Mofenk.AutoClaimBossMilestones then safeFire("ClaimBossMilestones") end
            if _G.Mofenk.AutoWheelSpin then safeFire("WheelSpinRequest") end
            if _G.Mofenk.AutoFuse then safeFire("FuseRequest") end
            
            -- Meteor & Base Collection
            if _G.Mofenk.AutoClaimMeteor then TriggerMeteorClaim() end
            if _G.Mofenk.AutoCollectBase then TriggerBaseCollection() end
            if _G.Mofenk.AutoUpgradeBrainrot then TriggerBrainrotUpgrades() end

            -- Global Collect Money
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFire("MoneyCollected"); safeFire("CollectMoney"); safeFire("ClaimCash")
                lastCollect = os.time()
            end
            
            -- Equip Best Squad
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                safeFire("EquipBest"); safeFire("EquipBestBattleSquadRequest")
                lastEquip = os.time()
            end
            
            -- Auto Sell
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                ExecuteAutoSell()
                lastSell = os.time()
            end
            
            -- Shop & Nodes
            if _G.Mofenk.AutoBuyDice then safeFire("BuyDiceRequest"); safeFire("DiceShopAction", "Buy", 1) end
            if _G.Mofenk.AutoUpgradeNodes then safeFire("BuyAffordableUpgradeNodes"); safeFire("UpgradeNodeRequest") end
            
            -- Dungeon & Gates
            if _G.Mofenk.AutoJoinDungeon then
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("RequestGatewayTeleport", _G.Mofenk.TargetFloor)
                safeFire("JoinDungeon")
                safeFire("StartDungeon")
            end

            if _G.Mofenk.AutoDungeon then
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("RequestGatewayTeleport", _G.Mofenk.TargetFloor)
                safeFire("SetAutoFightBoss", true)
                safeFire("BossAttack")
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end

            if _G.Mofenk.AutoDragonGate then
                safeFire("DragonGateAction")
                safeFire("DragonGateJoin")
            end
        end)
    end
end)
