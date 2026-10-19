-- =====================================================================
-- 👑 MOFENKHUB V130 — ULTIMATE COMPLETE & INSTANT MASTERPIECE
-- Game: Dadu Brainrot! | Instant Roll, Best Brainrot Equip & All Features
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
    CollectEvery = 1,
    AutoRebirth = false, 
    AutoEquipBest = false, 
    EquipBestEvery = 10,
    AutoClaimQuests = false, 
    AutoClaimIndex = false,
    AutoUpgradeBrainrot = false, 
    AutoCollectBase = false,
    AutoClaimMeteor = false,
    -- Full 19 Rarities Checklist Sell Config
    AutoSell = false, 
    SellEvery = 4, 
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
    KeepTraited = false,
    -- Unified Dungeon & Gateway Group
    AutoDungeonGroup = false, 
    TargetFloor = "Battle1", 
    AutoDragonGate = false,
    -- Automation Extras
    AutoFuse = false,
    AutoWheelSpin = false,
    AutoClaimBossMilestones = false,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoBuyDice = false, 
    AutoUpgradeNodes = false,
    AutoReconnect = true,
    SpyEnabled = true
}

-- PENCARIAN REMOTES AMAN DENGAN ENCRYPTED RESOLVER
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
        
        for _, child in ipairs(Remotes:GetChildren()) do
            if (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) and #child.Name > 20 then
                return child
            end
        end
    end
    return nil
end

local function safeFireEncrypted(featureName, targetName, ...)
    local args = {...}
    task.spawn(function()
        pcall(function()
            local r = getEncryptedRemote(targetName)
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
-- 3. FUNGSI EKSEKUSI UTAMA (LENGKAP & PRESISI)
-- ==========================================
local function TriggerRollSystem()
    pcall(function()
        if _G.Mofenk.InstantRoll then
            -- Spam fire remote roll untuk hasil instan tanpa delay animasi
            for i = 1, 5 do
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
        -- Eksekusi menyeluruh untuk equip best brainrot / squad / team
        safeFireEncrypted("Auto Equip Best", "EquipBest")
        safeFireEncrypted("Auto Equip Best", "EquipBestBattleSquadRequest")
        safeFireEncrypted("Auto Equip Best", "EquipBestBrainrot")
        safeFireEncrypted("Auto Equip Best", "AutoEquipBestRequest")
    end)
end

local function TriggerBaseCollection()
    pcall(function()
        safeFireEncrypted("Auto Collect Base", "MoneyCollected")
        safeFireEncrypted("Auto Collect Base", "CollectMoney")
        safeFireEncrypted("Auto Collect Base", "ClaimCash")
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
        safeFireEncrypted("Auto Claim Meteor", "MeteorClaimed")
        safeFireEncrypted("Auto Claim Meteor", "ClaimMeteor")
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            if string.find(name, "meteor") and obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj)
            end
        end
    end)
end

local function TriggerBrainrotUpgrades()
    pcall(function()
        for i = 1, 25 do
            safeFireEncrypted("Auto Upgrade Brainrot", "UpgradeBrainrotRequest", i)
            safeFireEncrypted("Auto Upgrade Brainrot", "UpgradePlacedBrainrot", i)
            safeFireEncrypted("Auto Upgrade Brainrot", "MultiRollUpgradeRequest")
        end
    end)
end

local function TriggerUniversalIndexClaims()
    pcall(function()
        safeFireEncrypted("Auto Claim Index", "RequestIndexRewards")
        local prefixes = {"Finish_", "Tier_", "Index_", "Reward_"}
        local types = {"Galactic", "Prismatic", "Aurora", "Cosmic", "Divine", "Secret", "Legendary", "Mythical"}
        for _, p in ipairs(prefixes) do
            for _, t in ipairs(types) do
                safeFireEncrypted("Auto Claim Index", "ClaimIndexReward", p .. t)
            end
        end
    end)
end

local function ExecuteAccurateSell()
    pcall(function()
        safeFireEncrypted("Auto Sell", "RequestInventorySnapshot")
        safeFireEncrypted("Auto Sell", "RequestItemsSnapshot")
        
        local raritiesToSell = {}
        if _G.Mofenk.SellCommon then table.insert(raritiesToSell, "Common") end
        if _G.Mofenk.SellUncommon then table.insert(raritiesToSell, "Uncommon") end
        if _G.Mofenk.SellRare then table.insert(raritiesToSell, "Rare") end
        if _G.Mofenk.SellEpic then table.insert(raritiesToSell, "Epic") end
        if _G.Mofenk.SellLegendary then table.insert(raritiesToSell, "Legendary") end
        if _G.Mofenk.SellMythical then table.insert(raritiesToSell, "Mythical") end
        if _G.Mofenk.SellAncient then table.insert(raritiesToSell, "Ancient") end
        if _G.Mofenk.SellDivine then table.insert(raritiesToSell, "Divine") end
        if _G.Mofenk.SellCelestial then table.insert(raritiesToSell, "Celestial") end
        if _G.Mofenk.SellEthereal then table.insert(raritiesToSell, "Ethereal") end
        if _G.Mofenk.SellAstral then table.insert(raritiesToSell, "Astral") end
        if _G.Mofenk.SellCosmic then table.insert(raritiesToSell, "Cosmic") end
        if _G.Mofenk.SellTranscendent then table.insert(raritiesToSell, "Transcendent") end
        if _G.Mofenk.SellEternal then table.insert(raritiesToSell, "Eternal") end
        if _G.Mofenk.SellPrimordial then table.insert(raritiesToSell, "Primordial") end
        if _G.Mofenk.SellOmniversal then table.insert(raritiesToSell, "Omniversal") end
        if _G.Mofenk.SellInfinite then table.insert(raritiesToSell, "Infinite") end
        if _G.Mofenk.SellSupreme then table.insert(raritiesToSell, "Supreme") end
        if _G.Mofenk.SellSecret then table.insert(raritiesToSell, "Secret") end

        if #raritiesToSell > 0 then
            for _, rarity in ipairs(raritiesToSell) do
                safeFireEncrypted("Auto Sell", "SellAllRequest", rarity)
                safeFireEncrypted("Auto Sell", "SellSelectedRequest", rarity)
                safeFireEncrypted("Auto Sell", "SellItemRequest", rarity)
            end
        end
        safeFireEncrypted("Auto Sell", "SetAutoSellUnderRequest", true, _G.Mofenk.KeepMutated)
    end)
end

local function ForcePhysicalDungeonTeleport(floorName)
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Part") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "dungeon") or string.find(name, "gateway") or string.find(name, string.lower(floorName)) then
                        if obj:IsA("Model") and obj.PrimaryPart then
                            char.HumanoidRootPart.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                            break
                        elseif obj:IsA("Part") then
                            char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 4. CONSOLE NETWORK SPY & MAP SCANNER
-- ==========================================
local function AdvancedMapScan()
    print("\n==================================================")
    print("🔍 [MOFENK SPY SCANNER] Memindai Semua Remote Game...")
    print("==================================================")
    if Remotes then
        for _, r in ipairs(Remotes:GetChildren()) do
            print("   - " .. r.Name .. " (" .. r.ClassName .. ")")
        end
    end
    print("==================================================\n")
end

local function dumpData(o, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end
    if type(o) == 'table' then
        local s = '{' for k,v in pairs(o) do s = s .. tostring(k) .. '=' .. dumpData(v, depth+1) .. ', ' end return s .. '}'
    elseif typeof(o) == "Instance" then return "<" .. o.Name .. ">"
    elseif type(o) == 'string' then return '"' .. o .. '"' else return tostring(o) end
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.Mofenk.SpyEnabled and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function()
            pcall(function()
                local argStr = ""
                for i, v in ipairs(args) do argStr = argStr .. "Arg["..i.."]: " .. dumpData(v) .. " | " end
                print("👁️ [MOFENK SPY] " .. self.Name .. " (" .. method .. ") -> " .. argStr)
            end)
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- 5. UTILITY SERVER & PROFIL
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
-- 6. ANTI-DC & ANTI-AFK
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
-- 7. UI RAYFIELD (V130 ULTIMATE COMPLETE)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V130 Complete",
   LoadingTitle = "Memuat MofenkHub V130...",
   LoadingSubtitle = "Instant Roll & Best Brainrot Equip Master",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V130 Loaded! 👑", Content = "Instant Roll & Equip Best Aktif!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 PROFIL & MONITOR")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung (V130 Complete)\nGame: [UPDATE 2] Dadu Brainrot!"})

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
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 1, Callback = function(V) _G.Mofenk.CollectEvery = V end})

TabMain:CreateSection("🛡️ Squad & Best Brainrot Equip")
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best Brainrot Squad", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 5, Suffix = "s", CurrentValue = 10, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})
TabMain:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards (Universal)", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "🏆 Auto Claim Boss Milestones", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimBossMilestones = V end})
TabMain:CreateToggle({Name = "☄️ Auto Claim Meteor", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimMeteor = V end})
TabMain:CreateToggle({Name = "🎡 Auto Spin Wheel", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoWheelSpin = V end})
TabMain:CreateToggle({Name = "🧪 Auto Fuse Items/Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoFuse = V end})

TabMain:CreateSection("🏡 Base & Brainrot Upgrades")
TabMain:CreateToggle({Name = "🏡 Auto Collect Base Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectBase = V end})
TabMain:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeBrainrot = V end})

-- TAB 3: INVENTORY & 19-RARITY CHECKLIST SELL 📦
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("💲 Smart Auto Sell (Full 19 Rarities)")
TabInv:CreateToggle({Name = "🗑️ Aktifkan Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 4, Callback = function(V) _G.Mofenk.SellEvery = V end})

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

TabInv:CreateSection("🎲 Toko & Upgrades")
TabInv:CreateToggle({Name = "🎲 Auto Buy Dice", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoBuyDice = V end})
TabInv:CreateToggle({Name = "📈 Auto Buy Upgrade Nodes", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeNodes = V end})

-- TAB 4: DUNGEON & GATES ⚔️ (COMPLETE MASTER)
local TabDungeon = Window:CreateTab("Dungeon & Gates ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon State & Physical Teleport")
TabDungeon:CreateDropdown({
    Name = "🚪 Pilih Floor Dungeon", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabDungeon:CreateToggle({
    Name = "🚀 Auto Unified Dungeon", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Mofenk.AutoDungeonGroup = V 
        if V then
            ForcePhysicalDungeonTeleport(_G.Mofenk.TargetFloor)
        else
            pcall(function()
                safeFireEncrypted("Auto Dungeon Exit", "DungeonShopState", false)
                safeFireEncrypted("Auto Dungeon Exit", "SetAutoFightBoss", false)
                safeFireEncrypted("Auto Dungeon Exit", "LeaveDungeon")
                safeFireEncrypted("Auto Dungeon Exit", "RequestMyBaseSpawn")
            end)
        end
    end
})
TabDungeon:CreateToggle({Name = "🐉 Auto Dragon Gate", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDragonGate = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base (Keluar Manual)", Callback = function() 
    safeFireEncrypted("Return To Base", "DungeonShopState", false)
    safeFireEncrypted("Return To Base", "SetAutoFightBoss", false)
    safeFireEncrypted("Return To Base", "LeaveDungeon")
    safeFireEncrypted("Return To Base", "RequestMyBaseSpawn") 
end})

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

-- TAB 6: DEV & SPY 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("🗺️ ADVANCED MAP & REMOTE SCANNER")
TabDev:CreateButton({Name = "🔍 Jalankan Advanced Scanner", Callback = function() 
    AdvancedMapScan()
    Rayfield:Notify({Title = "Scanner Aktif", Content = "Cek konsol untuk melihat detail remote.", Duration = 3})
end})
TabDev:CreateSection("📡 CONSOLE NETWORK SPY")
TabDev:CreateToggle({Name = "Aktifkan Network Spy", CurrentValue = true, Callback = function(V) _G.Mofenk.SpyEnabled = V end})

-- =====================================================================
-- 8. BACKGROUND MASTER ENGINE (SYNCHRONIZED LOOPS)
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            -- Main Loops (Instant Roll & Roll)
            TriggerRollSystem()

            if _G.Mofenk.AutoRebirth then 
                safeFireEncrypted("Auto Rebirth", "RebirthRequest")
                safeFireEncrypted("Auto Rebirth", "Rebirth")
            end
            if _G.Mofenk.AutoClaimQuests then safeFireEncrypted("Auto Claim Quests", "ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then TriggerUniversalIndexClaims() end
            if _G.Mofenk.AutoClaimBossMilestones then safeFireEncrypted("Auto Claim Boss Milestones", "ClaimBossMilestones") end
            if _G.Mofenk.AutoWheelSpin then safeFireEncrypted("Auto Spin Wheel", "WheelSpinRequest") end
            if _G.Mofenk.AutoFuse then safeFireEncrypted("Auto Fuse", "FuseRequest") end
            
            -- Meteor, Base & Upgrades
            if _G.Mofenk.AutoClaimMeteor then TriggerMeteorClaim() end
            if _G.Mofenk.AutoCollectBase then TriggerBaseCollection() end
            if _G.Mofenk.AutoUpgradeBrainrot then TriggerBrainrotUpgrades() end

            -- Global Collect Money
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFireEncrypted("Auto Collect Money", "MoneyCollected")
                safeFireEncrypted("Auto Collect Money", "CollectMoney")
                safeFireEncrypted("Auto Collect Money", "ClaimCash")
                lastCollect = os.time()
            end
            
            -- Equip Best Squad / Brainrot
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                TriggerEquipBestBrainrot()
                lastEquip = os.time()
            end
            
            -- 19-Rarity Checklist Auto Sell
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                ExecuteAccurateSell()
                lastSell = os.time()
            end
            
            -- Shop & Nodes
            if _G.Mofenk.AutoBuyDice then 
                safeFireEncrypted("Auto Buy Dice", "BuyDiceRequest")
                safeFireEncrypted("Auto Buy Dice", "DiceShopAction", "Buy", 1) 
            end
            if _G.Mofenk.AutoUpgradeNodes then 
                safeFireEncrypted("Auto Upgrade Nodes", "BuyAffordableUpgradeNodes")
                safeFireEncrypted("Auto Upgrade Nodes", "UpgradeNodeRequest") 
            end
            
            -- Unified Dungeon Group
            if _G.Mofenk.AutoDungeonGroup then
                ForcePhysicalDungeonTeleport(_G.Mofenk.TargetFloor)
                safeFireEncrypted("Auto Dungeon", "DungeonShopState", _G.Mofenk.TargetFloor)
                safeFireEncrypted("Auto Dungeon", "SetAutoFightBoss", true)
                safeFireEncrypted("Auto Dungeon", "BossAttack")
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end

            if _G.Mofenk.AutoDragonGate then
                safeFireEncrypted("Auto Dragon Gate", "DragonGateAction")
                safeFireEncrypted("Auto Dragon Gate", "DragonGateJoin")
            end
        end)
    end
end)
