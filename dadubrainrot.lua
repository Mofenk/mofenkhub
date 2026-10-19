-- =====================================================================
-- 👑 MOFENKHUB V151 — CUSTOM FEATURE EDITION (FULL SCRIPT)
-- Game: Dadu Brainrot! | Cleaned In-Game Features + Fly & Utilities
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
    -- Cleaned Farm List
    AutoRoll = false,
    AutoCollectMoney = false, CollectEvery = 2,
    AutoEquipBest = false, EquipBestEvery = 15,
    AutoRebirth = false,
    AutoBuyDice = false,
    AutoUpgradeNodes = false,
    AutoUpgradeBrainrots = false,
    AutoClaimQuests = false,
    AutoClaimIndex = false,
    AutoRollTraits = false,
    AutoDungeon = false, TargetTower = "Sahur Tower",
    AutoBuyDungeonShop = false,
    
    -- Filtered Sell
    AutoSell = false, SellEvery = 2,
    SellCommon = false, SellUncommon = false, SellRare = false,
    SellEpic = false, SellLegendary = false, SellMythical = false,
    SellAncient = false, SellDivine = false, SellCelestial = false,
    SellEthereal = false, SellAstral = false, SellCosmic = false,
    SellTranscendent = false, SellEternal = false, SellPrimordial = false,
    SellOmniversal = false, SellInfinite = false, SellSupreme = false,
    SellSecret = false, KeepMutated = false,

    -- Non-Farm & Utilities
    EnableFly = false, FlySpeed = 50,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoReconnect = true, SpyEnabled = true
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==========================================
-- 3. DEEP DEBUGGER & REMOTE EXECUTOR
-- ==========================================
local function DebugLog(feature, details)
    if _G.Mofenk.SpyEnabled then
        Rayfield:Notify({
            Title = "🛠️ DEBUG: " .. feature,
            Content = details,
            Duration = 3,
            Image = 4483362458
        })
        print("[MofenkHub V151 DEBUG] " .. feature .. " | " .. details)
    end
end

local function safeFireEncrypted(featureName, targetName, ...)
    local args = {...}
    if _G.Mofenk.SpyEnabled then
        local argStr = ""
        for _, v in ipairs(args) do argStr = argStr .. tostring(v) .. ", " end
        print("[NETWORK SPY] " .. featureName .. " -> Firing: " .. targetName .. " | Args: [" .. argStr .. "]")
    end
    
    task.spawn(function()
        pcall(function()
            if Remotes then
                local r = Remotes:FindFirstChild(targetName, true)
                if r then
                    if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                    elseif r:IsA("RemoteFunction") then r:InvokeServer(unpack(args)) end
                end
            end
        end)
    end)
end

-- ==========================================
-- 4. FUNGSI EKSEKUSI UTAMA (STRICT LIST)
-- ==========================================
local function TriggerRollSystem()
    pcall(function()
        if _G.Mofenk.AutoRoll then
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

local function TriggerUpgrades()
    pcall(function()
        if _G.Mofenk.AutoUpgradeNodes then
            safeFireEncrypted("Upgrade Nodes", "BuyAffordableUpgradeNodes")
            safeFireEncrypted("Upgrade Nodes", "UpgradeNodeRequest", "All")
        end
        if _G.Mofenk.AutoUpgradeBrainrots then
            safeFireEncrypted("Upgrade Brainrots", "UpgradeAllBrainrotsRequest")
            safeFireEncrypted("Upgrade Brainrots", "MaxUpgradeAllPlaced")
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

local function ExecuteRemoteSell()
    pcall(function()
        if not _G.Mofenk.AutoSell then return end
        safeFireEncrypted("Auto Sell System", "SellSelectedRequest")
        safeFireEncrypted("Auto Sell System", "AutoSellStateChanged", true)
    end)
end

local function ExecuteDungeonActions(towerName)
    pcall(function()
        safeFireEncrypted("Dungeon", "SelectDungeon", towerName)
        safeFireEncrypted("Dungeon", "JoinDungeon", towerName)
        safeFireEncrypted("Dungeon", "StartDungeon", towerName)
        safeFireEncrypted("Dungeon", "SetAutoFightBoss", true)
        safeFireEncrypted("Dungeon", "BossAttack")
    end)
end

-- ==========================================
-- 5. UTILITIES, FLY & PROFIL
-- ==========================================
local function ToggleFlySystem(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if state then
        if not hrp:FindFirstChild("MofenkFlyBV") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "MofenkFlyBV"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            task.spawn(function()
                while _G.Mofenk.EnableFly and hrp:FindFirstChild("MofenkFlyBV") do
                    local cam = workspace.CurrentCamera
                    bv.Velocity = cam.CFrame.LookVector * _G.Mofenk.FlySpeed
                    task.wait(0.05)
                end
                if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
            end)
        end
    else
        if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
    end
end

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
            info = info .. "--- Stats ---\n"
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
        return "Aktif"
    end)
    return success and val or "Memuat..."
end

-- Anti-DC & Anti-AFK
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
-- 6. UI RAYFIELD (STRICT FEATURE SETUP)
-- ==========================================
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V151 👑",
   LoadingTitle = "Memuat MofenkHub V151...",
   LoadingSubtitle = "Custom Features Only",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V151 Ready! 👑", Content = "Daftar Fitur Telah Disesuaikan!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 PROFIL & MONITOR")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung\nGame: Dadu Brainrot!"})

local ProfileParagraph = TabHome:CreateParagraph({Title = "📋 Profil Karakter", Content = "Memuat data..."})
task.spawn(function()
    while task.wait(3) do pcall(function() ProfileParagraph:Set({Title = "📋 Profil Karakter (" .. LocalPlayer.Name .. ")", Content = GetCharacterProfileInfo()}) end) end
end)

local MoneyParagraph = TabHome:CreateParagraph({Title = "Uang / Cash In-Game", Content = "Memuat..."})
task.spawn(function()
    while task.wait(1) do pcall(function() MoneyParagraph:Set({Title = "Uang / Cash In-Game", Content = "Status: " .. getRealTimeMoney()}) end) end
end)

-- TAB 2: MAIN & FARM 🎮
local TabMain = Window:CreateTab("Main & Farm 🎮", 6023426915)
TabMain:CreateSection("🎲 Farm Utilities")
TabMain:CreateToggle({Name = "🎲 Auto Roll", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoRoll = V 
    DebugLog("Auto Roll", "Status: " .. tostring(V)) 
end})
TabMain:CreateToggle({Name = "💰 Auto Collect Money", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoCollectMoney = V 
    DebugLog("Auto Collect Money", "Status: " .. tostring(V)) 
end})
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 2, Callback = function(V) _G.Mofenk.CollectEvery = V end})

TabMain:CreateSection("🛡️ Squad & Upgrades")
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoEquipBest = V 
    DebugLog("Auto Equip Best", "Status: " .. tostring(V)) 
end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 5, Suffix = "s", CurrentValue = 15, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})
TabMain:CreateToggle({Name = "🔄 Auto Rebirth", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoRebirth = V 
    DebugLog("Auto Rebirth", "Status: " .. tostring(V)) 
end})
TabMain:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoBuyDice = V 
    DebugLog("Auto Buy Dice", "Status: " .. tostring(V)) 
end})
TabMain:CreateToggle({Name = "🌀 Auto Roll Traits", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoRollTraits = V 
    DebugLog("Auto Roll Traits", "Status: " .. tostring(V)) 
end})

-- TAB 3: UPGRADES & QUESTS ⚡
local TabUpgrades = Window:CreateTab("Upgrades & Quests ⚡", 6023426915)
TabUpgrades:CreateSection("⚡ Node & Brainrot Upgrades")
TabUpgrades:CreateToggle({Name = "⚡ Auto Buy Affordable Upgrade Nodes", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoUpgradeNodes = V 
    DebugLog("Auto Upgrade Nodes", "Status: " .. tostring(V)) 
end})
TabUpgrades:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoUpgradeBrainrots = V 
    DebugLog("Auto Upgrade Brainrots", "Status: " .. tostring(V)) 
end})

TabUpgrades:CreateSection("📜 Rewards & Quests")
TabUpgrades:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoClaimQuests = V 
    DebugLog("Auto Claim Quests", "Status: " .. tostring(V)) 
end})
TabUpgrades:CreateToggle({Name = "📖 Auto Claim Index Rewards", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoClaimIndex = V 
    DebugLog("Auto Claim Index Rewards", "Status: " .. tostring(V)) 
end})

-- TAB 4: INVENTORY & SELL 📦
local TabInv = Window:CreateTab("Inventory & Sell 📦", 6023426915)
TabInv:CreateSection("💲 Auto Sell (Filtered Remote)")
TabInv:CreateToggle({Name = "🗑️ Auto Sell", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoSell = V 
    DebugLog("Auto Sell", "Status: " .. tostring(V)) 
end})
TabInv:CreateSlider({Name = "⏱️ Sell Interval (s)", Range = {1, 15}, Increment = 1, Suffix = "s", CurrentValue = 2, Callback = function(V) _G.Mofenk.SellEvery = V end})

local function CreateRarityToggle(name, variableName, rarityID)
    TabInv:CreateToggle({Name = "Jual " .. name, CurrentValue = false, Callback = function(V) 
        _G.Mofenk[variableName] = V 
        safeFireEncrypted("Sell Filter", "ToggleAutoSellRarityRequest", rarityID, V)
        safeFireEncrypted("Sell Filter", "SetAutoSellUnderRequest", rarityID, V)
        DebugLog("Filter Rarity", "Rarity [" .. rarityID .. "] -> " .. tostring(V))
    end})
end

TabInv:CreateSection("☑️ Tier 1")
CreateRarityToggle("Common", "SellCommon", "Common")
CreateRarityToggle("Uncommon", "SellUncommon", "Uncommon")
CreateRarityToggle("Rare", "SellRare", "Rare")
CreateRarityToggle("Epic", "SellEpic", "Epic")
CreateRarityToggle("Legendary", "SellLegendary", "Legendary")
CreateRarityToggle("Mythical", "SellMythical", "Mythical")

TabInv:CreateSection("☑️ Tier 2 & 3")
CreateRarityToggle("Ancient", "SellAncient", "Ancient")
CreateRarityToggle("Divine", "SellDivine", "Divine")
CreateRarityToggle("Celestial", "SellCelestial", "Celestial")
CreateRarityToggle("Ethereal", "SellEthereal", "Ethereal")
CreateRarityToggle("Astral", "SellAstral", "Astral")
CreateRarityToggle("Cosmic", "SellCosmic", "Cosmic")
CreateRarityToggle("Transcendent", "SellTranscendent", "Transcendent")
CreateRarityToggle("Eternal", "SellEternal", "Eternal")
CreateRarityToggle("Primordial", "SellPrimordial", "Primordial")
CreateRarityToggle("Omniversal", "SellOmniversal", "Omniversal")
CreateRarityToggle("Infinite", "SellInfinite", "Infinite")
CreateRarityToggle("Supreme", "SellSupreme", "Supreme")
CreateRarityToggle("Secret", "SellSecret", "Secret")

-- TAB 5: DUNGEON ⚔️
local TabTower = Window:CreateTab("Dungeon ⚔️", 6023426915)
TabTower:CreateSection("⚔️ Dungeon Automation")
TabTower:CreateDropdown({
    Name = "🚪 Pilih Tower / Dungeon", 
    Options = {"Sahur Tower", "Orcala Tower", "Bombardiro Tower", "Spiderini Tower", "Larila Tower"}, 
    CurrentOption = {"Sahur Tower"}, 
    Callback = function(Opt) _G.Mofenk.TargetTower = Opt[1] end
})
TabTower:CreateToggle({
    Name = "🚀 Auto Dungeon", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Mofenk.AutoDungeon = V 
        if V then
            ExecuteDungeonActions(_G.Mofenk.TargetTower)
            DebugLog("Auto Dungeon", "Start: " .. _G.Mofenk.TargetTower)
        else
            pcall(function()
                safeFireEncrypted("Dungeon", "LeaveDungeon")
                safeFireEncrypted("Dungeon", "RequestMyBaseSpawn")
            end)
            DebugLog("Auto Dungeon", "Stopped & Returned to Base")
        end
    end
})
TabTower:CreateToggle({Name = "🛒 Auto Buy Dungeon Shop", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.AutoBuyDungeonShop = V 
    DebugLog("Auto Buy Dungeon Shop", "Status: " .. tostring(V)) 
end})
TabTower:CreateButton({Name = "🏠 Return To Base", Callback = function() 
    safeFireEncrypted("Dungeon", "LeaveDungeon")
    safeFireEncrypted("Dungeon", "RequestMyBaseSpawn")
    Rayfield:Notify({Title = "Return To Base", Content = "Berhasil kembali ke base.", Duration = 3})
end})

-- TAB 6: PLAYER & UTILITIES ⚡
local TabPlayer = Window:CreateTab("Player & Utilities ⚡", 6023426915)
TabPlayer:CreateSection("🕊️ Movement & Fly")
TabPlayer:CreateToggle({Name = "🕊️ Aktifkan Fly", CurrentValue = false, Callback = function(V) 
    _G.Mofenk.EnableFly = V 
    ToggleFlySystem(V)
    DebugLog("Fly Feature", "Status: " .. tostring(V))
end})
TabPlayer:CreateSlider({Name = "🚀 Kecepatan Terbang (Fly Speed)", Range = {20, 200}, Increment = 5, CurrentValue = 50, Callback = function(V) _G.Mofenk.FlySpeed = V end})

TabPlayer:CreateSection("🏃 Speed & Reconnect")
TabPlayer:CreateToggle({Name = "⚡ Aktifkan Custom WalkSpeed", CurrentValue = false, Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end})
TabPlayer:CreateSlider({Name = "🏃 Kecepatan Jalan", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) _G.Mofenk.WalkSpeedVal = V end})
TabPlayer:CreateToggle({Name = "🔄 Auto Reconnect (Anti-DC)", CurrentValue = true, Callback = function(V) _G.Mofenk.AutoReconnect = V end})

TabPlayer:CreateSection("🌐 Server Utilities")
TabPlayer:CreateButton({Name = "📋 Copy Server JobID", Callback = function() 
    CopyServerID()
    Rayfield:Notify({Title = "Berhasil Disalin! ✅", Content = "Job ID disalin ke clipboard.", Duration = 3})
end})
TabPlayer:CreateButton({Name = "🔀 Server Hop", Callback = function() 
    Rayfield:Notify({Title = "Pindah Server...", Content = "Mencari server publik baru...", Duration = 3})
    ServerHop() 
end})

-- TAB 7: DEV & SPY 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("📡 CONSOLE NETWORK SPY")
TabDev:CreateToggle({Name = "Aktifkan Deep Debugger (Notifikasi UI)", CurrentValue = true, Callback = function(V) 
    _G.Mofenk.SpyEnabled = V 
    if V then Rayfield:Notify({Title = "Spy Debugger Aktif", Content = "Menampilkan semua eksekusi remote di layar.", Duration = 3}) end
end})

-- =====================================================================
-- 7. BACKGROUND MASTER ENGINE
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            -- WalkSpeed Loop
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            -- Cleaned In-Game Features Loop
            if _G.Mofenk.AutoRoll then TriggerRollSystem() end

            if _G.Mofenk.AutoRebirth then 
                safeFireEncrypted("Rebirth", "RebirthRequest")
                safeFireEncrypted("Rebirth", "Rebirth")
            end
            
            if _G.Mofenk.AutoClaimQuests then safeFireEncrypted("Quests", "ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then TriggerUniversalIndexClaims() end
            
            if _G.Mofenk.AutoRollTraits then
                safeFireEncrypted("Traits", "RollTraitRequest")
                safeFireEncrypted("Traits", "SpinTrait")
            end

            if _G.Mofenk.AutoUpgradeNodes or _G.Mofenk.AutoUpgradeBrainrots then
                TriggerUpgrades()
            end

            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                TriggerBaseCollection()
                lastCollect = os.time()
            end
            
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                TriggerEquipBestBrainrot()
                lastEquip = os.time()
            end
            
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                ExecuteRemoteSell()
                lastSell = os.time()
            end
            
            if _G.Mofenk.AutoBuyDice then 
                safeFireEncrypted("Dice Shop", "BuyDiceRequest")
                safeFireEncrypted("Dice Shop", "DiceShopAction", "Buy", 1) 
            end
            
            if _G.Mofenk.AutoDungeon then
                ExecuteDungeonActions(_G.Mofenk.TargetTower)
            end

            if _G.Mofenk.AutoBuyDungeonShop then
                safeFireEncrypted("Dungeon Shop", "BuyDungeonShopRequest")
                safeFireEncrypted("Dungeon Shop", "BuyAllDungeonShop")
            end
        end)
    end
end)
