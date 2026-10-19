-- =====================================================================
-- 👑 MOFENKHUB V98 — FULL INDEX & MUTATION DEEP INSPECTOR
-- Game: Dadu Brainrot! | Tarik Data Seluruh Mutasi & Brainrot Utuh
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

-- 2. KONFIGURASI GLOBAL
_G.Mofenk = {
    AutoRoll = false, AutoCollectMoney = false, CollectEvery = 1,
    AutoRebirth = false, AutoEquipBest = false, EquipBestEvery = 15,
    AutoClaimQuests = false, AutoClaimIndex = false,
    AutoUpgradeBrainrot = false, MaxLevelBrainrot = 40,
    AutoCollectBase = false,
    AutoSell = false, SellEvery = 3, SelectedRarity = "Common, Uncommon",
    KeepMutated = false, KeepTraited = false, KeepFinishes = false, KeepVariants = false,
    AutoTraitRoll = false, StopOnTraits = "None",
    AutoDungeon = false, TargetFloor = "Battle1", AutoBuyDungeonShop = false,
    WalkSpeedVal = 16, EnableWalkSpeed = false,
    AutoBuyDice = false, AutoUpgradeNodes = false,
    AutoReconnect = true,
    SpyEnabled = false
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

-- ==========================================
-- 3. DEEP INSPECTOR: TARIK SEMUA MUTASI & INDEX
-- ==========================================
local function DeepInspectMutationsAndIndex()
    print("\n==================================================")
    print("🧬 [MOFENK DEEP INSPECTOR] Memindai Seluruh Mutasi & Brainrot...")
    print("==================================================")
    
    local foundModules = 0
    
    -- Jelajahi seluruh ReplicatedStorage untuk mencari modul data game (Index, Mutations, Brainrots, Rarities)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "index") or string.find(nameLower, "mutation") or string.find(nameLower, "brainrot") or string.find(nameLower, "config") or string.find(nameLower, "item") then
                foundModules = foundModules + 1
                pcall(function()
                    local data = require(obj)
                    if type(data) == "table" then
                        print("\n📦 Modul Ditemukan: " .. obj.FullName)
                        for k, v in pairs(data) do
                            if type(v) == "table" then
                                print("   🔹 [" .. tostring(k) .. "] (Tabel data berisi sub-item)")
                                for subK, subV in pairs(v) do
                                    print("      - " .. tostring(subK) .." = " .. tostring(subV))
                                end
                            else
                                print("   🔹 " .. tostring(k) .. " = " .. tostring(v))
                            end
                        end
                    end
                end)
            end
        end
    end

    print("\n==================================================")
    print("✅ Pemindaian Mendalam Selesai! Modul diproses: " .. foundModules)
    print("==================================================\n")
end

-- ==========================================
-- 4. SISTEM AUTO RECONNECT & ANTI-AFK
-- ==========================================
local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true)
if PromptOverlay then
    PromptOverlay.ChildAdded:Connect(function(child)
        if _G.Mofenk.AutoReconnect and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
            print("🔄 [MOFENK RECONNECT] Terdeteksi DC! Menyambung ulang...")
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
-- 5. FUNGSI PENYEDOT UANG & MAP SCANNER
-- ==========================================
local function CollectMoneyAndBase()
    pcall(function()
        safeFire("MoneyCollected")
        safeFire("CollectMoney")
        safeFire("ClaimCash")
        safeFire("ClaimMoney")

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function()
                        if obj.Parent and (obj.Parent.Position - hrp.Position).Magnitude <= 30 then
                            fireproximityprompt(obj)
                        end
                    end)
                end
            end
        end
    end)
end

local function FullMapScan()
    print("\n==================================================")
    print("🗺️ [MOFENK MAP SCANNER] Memindai Objek Workspace...")
    print("==================================================")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "base") or string.find(nameLower, "market") or string.find(nameLower, "dungeon") or string.find(nameLower, "brainrot") then
                count = count + 1
                print("📍 [" .. obj.ClassName .. "] " .. obj.Name)
            end
        end
    end
    print("==================================================")
    print("✅ Selesai! Objek ditemukan: " .. count)
    print("==================================================\n")
end

-- ==========================================
-- 6. CONSOLE SPY & UTILITIES
-- ==========================================
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
                if argStr == "" then argStr = "Tidak ada argumen" end
                print("👁️ [MOFENK SPY] " .. self.Name .. " (" .. method .. ") -> " .. argStr)
            end)
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function CopyServerID() pcall(function() if setclipboard then setclipboard(game.JobId) end end) end
local function ServerHop()
    pcall(function()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in ipairs(req.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end
            end
        end
        if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    end)
end

-- 7. RAYFIELD UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V98 Deep Inspector",
   LoadingTitle = "Memuat MofenkHub V98...",
   LoadingSubtitle = "Full Index & Mutation Extractor",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({ Title = "MofenkHub V98 Loaded! 👑", Content = "Deep Inspector Mutasi & Index siap!", Duration = 5, Image = 6023426915 })

-- TAB 1: HOME 🏠
local TabHome = Window:CreateTab("Home 🏠", 6023426915)
TabHome:CreateSection("👋 WELCOME BACK")
TabHome:CreateParagraph({Title = LocalPlayer.Name, Content = "Status: Terhubung ke MofenkHub V98\nGame: [UPDATE 2] Dadu Brainrot!\nMode: Deep Index & Mutation Inspector"})

-- TAB 2: MAIN 🎮
local TabMain = Window:CreateTab("Main 🎮", 6023426915)
TabMain:CreateSection("🔄 Farm & Roll Utama")
TabMain:CreateToggle({Name = "🎲 Auto Roll", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "💰 Auto Collect Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "⏱️ Collect Every (s)", Range = {1, 10}, Increment = 1, Suffix = "s", CurrentValue = 1, Callback = function(V) _G.Mofenk.CollectEvery = V end})
TabMain:CreateToggle({Name = "🔄 Auto Rebirth", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRebirth = V end})
TabMain:CreateToggle({Name = "🛡️ Auto Equip Best", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoEquipBest = V end})
TabMain:CreateSlider({Name = "⏱️ Equip Best Every (s)", Range = {5, 60}, Increment = 1, Suffix = "s", CurrentValue = 15, Callback = function(V) _G.Mofenk.EquipBestEvery = V end})

TabMain:CreateSection("🎁 Claims & Base")
TabMain:CreateToggle({Name = "📜 Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "📖 Auto Claim Index Rewards", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimIndex = V end})
TabMain:CreateToggle({Name = "🏡 Auto Collect Base Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectBase = V end})
TabMain:CreateToggle({Name = "⚡ Auto Upgrade Placed Brainrots", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoUpgradeBrainrot = V end})

-- TAB 3: INVENTORY & DEEP INSPECTOR 📦
local TabInv = Window:CreateTab("Inventory 📦", 6023426915)
TabInv:CreateSection("🧬 Deep Inspector Mutasi & Index")
TabInv:CreateButton({
    Name = "🔍 Tarik Semua Mutasi & Brainrot ke Konsol",
    Callback = function()
        DeepInspectMutationsAndIndex()
        Rayfield:Notify({Title = "Inspeksi Selesai", Content = "Cek Konsol Delta untuk daftar lengkap mutasi!", Duration = 5})
    end
})

TabInv:CreateSection("💲 Auto Sell Management")
TabInv:CreateToggle({Name = "🗑️ Auto Sell", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateSlider({Name = "⏱️ Sell Every (s)", Range = {1, 30}, Increment = 1, Suffix = "s", CurrentValue = 3, Callback = function(V) _G.Mofenk.SellEvery = V end})
TabInv:CreateDropdown({
    Name = "📌 Sell Rarities",
    Options = {"Common, Uncommon", "Rare, Epic", "Legendary, Mythical", "Divine, Secret", "All Rarities"},
    CurrentOption = {"Common, Uncommon"},
    Callback = function(Opt) _G.Mofenk.SelectedRarity = Opt[1] end
})
TabInv:CreateToggle({Name = "🔒 Keep Mutated", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepMutated = V end})
TabInv:CreateToggle({Name = "🔒 Keep Traited", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepTraited = V end})
TabInv:CreateToggle({Name = "🔒 Keep Finishes", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepFinishes = V end})
TabInv:CreateToggle({Name = "🔒 Keep Variants", CurrentValue = false, Callback = function(V) _G.Mofenk.KeepVariants = V end})

-- TAB 4: DUNGEON ⚔️
local TabDungeon = Window:CreateTab("Dungeon ⚔️", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon Automation")
TabDungeon:CreateDropdown({
    Name = "🚪 Floor Selection", 
    Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, 
    CurrentOption = {"Battle1"}, 
    Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end
})
TabDungeon:CreateToggle({Name = "⚔️ Auto Dungeon & Boss Fight", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDungeon = V end})
TabDungeon:CreateButton({Name = "🏠 Return To Base", Callback = function() safeFire("RequestMyBaseSpawn") end})

-- TAB 5: PLAYER & AFK ⚡
local TabPlayer = Window:CreateTab("Player & AFK ⚡", 6023426915)
TabPlayer:CreateSection("🛡️ AFK & Reconnect Protection")
TabPlayer:CreateToggle({Name = "🔄 Auto Reconnect (Anti-DC)", CurrentValue = true, Callback = function(V) _G.Mofenk.AutoReconnect = V end})
TabPlayer:CreateSection("🏃 WalkSpeed")
TabPlayer:CreateToggle({Name = "⚡ Aktifkan Custom WalkSpeed", CurrentValue = false, Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end})
TabPlayer:CreateSlider({Name = "🏃 Kecepatan Jalan", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) _G.Mofenk.WalkSpeedVal = V end})
TabPlayer:CreateSection("🌐 Server Utilities")
TabPlayer:CreateButton({Name = "📋 Copy Server JobID", Callback = function() CopyServerID(); Rayfield:Notify({Title = "Berhasil", Content = "JobID disalin!", Duration = 3}) end})
TabPlayer:CreateButton({Name = "🔀 Server Hop", Callback = function() ServerHop() end})

-- TAB 6: DEV, SPY & SCANNER 🛠️
local TabDev = Window:CreateTab("Dev & Spy 🛠️", 6023426915)
TabDev:CreateSection("🗺️ MAP SCANNER")
TabDev:CreateButton({Name = "🔍 Jalankan Map Scanner", Callback = function() FullMapScan() end})
TabDev:CreateSection("📡 CONSOLE SPY")
TabDev:CreateToggle({Name = "Aktifkan Spy", CurrentValue = false, Callback = function(V) _G.Mofenk.SpyEnabled = V end})

-- =====================================================================
-- 8. BACKGROUND ENGINE
-- =====================================================================
local lastCollect, lastSell, lastEquip = os.time(), os.time(), os.time()

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoClaimIndex then safeFire("RequestIndexRewards") end
            if _G.Mofenk.AutoUpgradeBrainrot then safeFire("UpgradeBrainrotRequest", 1) end
            
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                CollectMoneyAndBase()
                lastCollect = os.time()
            end
            
            if _G.Mofenk.AutoEquipBest and (os.time() - lastEquip >= _G.Mofenk.EquipBestEvery) then
                safeFire("EquipBest")
                safeFire("EquipBestBattleSquadRequest")
                lastEquip = os.time()
            end
            
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                safeFire("SellAllRequest", _G.Mofenk.SelectedRarity)
                lastSell = os.time()
            end
            if _G.Mofenk.AutoTraitRoll then safeFire("SpinTraitRequest") end
            
            if _G.Mofenk.AutoDungeon then
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("SetAutoFightBoss", true)
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end
        end)
    end
end)
