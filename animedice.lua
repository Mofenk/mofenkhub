-- =====================================================================
-- 👑 MOFENKHUB V36 / V9.0 — MASTERPIECE ULTIMATE EDITION (FULL INDONESIA)
-- Game: Dadu Brainrot! | Fitur: 100% Data Synced, Spy TXT, & Notifikasi
-- =====================================================================

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
local LocalPlayer = Players.LocalPlayer

-- ======================================================= --
-- 1. FUNGSI UTILITAS & PENCARIAN MODUL
-- ======================================================= --
local function notifyUI(judul, pesan, durasi)
    pcall(function()
        Rayfield:Notify({
            Title = judul or "👑 MofenkHub",
            Content = pesan or "",
            Duration = durasi or 3,
            Image = 4483345998,
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

local spyLogsText = "=== LOG REMOTE SPY MOFENKHUB ===\n\n"

local function saveSpyToFile()
    pcall(function()
        if writefile then
            writefile("MofenkHub_RemoteSpy_Logs.txt", spyLogsText)
        end
    end)
end

local function safeFire(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote then
        if _G.Mofenk.SpyEnabled then
            local logEntry = string.format("[SPY FIRED] Remote: %s | Waktu: %s\n", tostring(remoteName), os.date("%X"))
            spyLogsText = spyLogsText .. logEntry
            saveSpyToFile()
            notifyUI("🔍 Remote Spy Terdeteksi", "Remote: " .. tostring(remoteName), 2)
        end
        pcall(function(...)
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end, ...)
    end
end

-- ======================================================= --
-- 2. SINKRONISASI MODUL GAME & STATE
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

_G.Mofenk = {
    AutoCollect = false, CollectDelay = 1.0,
    AutoRoll = false, InstantRoll = false, AutoTrait = false, AutoGrade = false,
    AutoEquipBest = false, AutoLock = false,
    AutoSellRarity = false, SellRarities = {},
    AutoUpBrainrot = false, AutoUpDice = false, AutoBuyDice = false, AutoRebirth = false,
    AutoDungeon = false, AutoShop = false,
    AutoQuest = false, AutoCandy = false, AutoMeteor = false, AutoLuckyBlock = false, AutoBoost = false,
    AutoReconnect = true, ReduceCPU = false, SpyEnabled = false
}

-- ======================================================= --
-- 3. ANTARMUKA RAYFIELD (BAHASA INDONESIA RAPI)
-- ======================================================= --
local Window = Rayfield:CreateWindow({
    Name = "👑 MofenkHub V36 | Dadu Brainrot [Ultimate Edition]",
    LoadingTitle = "Memuat Masterpiece Edition...",
    LoadingSubtitle = "Menyinkronkan data remote & modul...",
    ConfigurationSaving = { Enabled = true, FolderName = "MofenkHubV36", FileName = LocalPlayer.Name },
    KeySystem = false
})

local TabProfil = Window:CreateTab("👤 Profil & Tas", 4483345998)
local TabFarm = Window:CreateTab("🎲 Farm & Gacha", 4483345998)
local TabUnit = Window:CreateTab("🎒 Unit & Equip", 4483345998)
local TabSell = Window:CreateTab("🗑️ Auto Jual Rarity", 4483345998)
local TabUp = Window:CreateTab("📈 Level & Upgrade", 4483345998)
local TabTower = Window:CreateTab("🗼 Dungeon & Toko", 4483345998)
local TabEvent = Window:CreateTab("🎯 Event & Hadiah", 4483345998)
local TabSpy = Window:CreateTab("🔍 Scanner Spy TXT", 4483345998)
local TabSys = Window:CreateTab("⚙️ Sistem & Dunia", 4483345998)

-- --- TAB: PROFIL & TAS ---
TabProfil:CreateSection("📋 Informasi Akun & Tas Pemain")
local LabelNama = TabProfil:CreateLabel("👤 Nama Pemain: " .. LocalPlayer.Name)
local LabelId = TabProfil:CreateLabel("🆔 ID Akun: " .. LocalPlayer.UserId)
local LabelPing = TabProfil:CreateLabel("📶 Ping Server: Memuat...")
local LabelInv = TabProfil:CreateLabel("🎒 Total Item di Tas: Memuat...")

TabProfil:CreateButton({
    Name = "📋 Salin ID Akun ke Clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(LocalPlayer.UserId))
            notifyUI("Berhasil", "ID Akun berhasil disalin ke clipboard!", 3)
        end
    end,
})

-- --- TAB: FARM & GACHA ---
TabFarm:CreateSection("💸 Ekstraktor Uang & Magnet")
TabFarm:CreateToggle({Name = "🧲 Auto Ambil Uang & Item (Magnet Base)", CurrentValue = false, Flag = "T_Collect", Callback = function(v) _G.Mofenk.AutoCollect = v end})
TabFarm:CreateSlider({Name = "⏱️ Jeda Waktu Pengambilan (Detik)", Range = {0.5, 5.0}, Increment = 0.5, CurrentValue = 1.0, Flag = "S_Delay", Callback = function(v) _G.Mofenk.CollectDelay = v end})

TabFarm:CreateSection("🎲 Automasi Lempar Dadu & Gacha")
TabFarm:CreateToggle({Name = "🎲 Auto Lempar Dadu (Roll)", CurrentValue = false, Flag = "T_Roll", Callback = function(v) _G.Mofenk.AutoRoll = v end})
TabFarm:CreateToggle({Name = "⚡ Lempar Dadu Instan (Tanpa Animasi)", CurrentValue = false, Flag = "T_InstaRoll", Callback = function(v) _G.Mofenk.InstantRoll = v end})
TabFarm:CreateToggle({Name = "✨ Auto Putar Sifat (Trait Spin)", CurrentValue = false, Flag = "T_Trait", Callback = function(v) _G.Mofenk.AutoTrait = v end})
TabFarm:CreateToggle({Name = "🔄 Auto Reroll Grade", CurrentValue = false, Flag = "T_Grade", Callback = function(v) _G.Mofenk.AutoGrade = v end})

-- --- TAB: UNIT & EQUIP ---
TabUnit:CreateSection("Pasukan Tempur & Kunci Unit")
TabUnit:CreateToggle({Name = "🎒 Auto Equip Unit Terbaik (Best Squad)", CurrentValue = false, Flag = "T_Equip", Callback = function(v) _G.Mofenk.AutoEquipBest = v end})
TabUnit:CreateToggle({Name = "🔒 Auto Lock Unit Terbaik", CurrentValue = false, Flag = "T_Lock", Callback = function(v) _G.Mofenk.AutoLock = v end})

-- --- TAB: AUTO JUAL RARITY ---
TabSell:CreateSection("🗑️ Jual Berdasarkan Kelangkaan (Rarity)")
TabSell:CreateDropdown({
    Name = "🎯 Pilih Tingkat Kelangkaan (Rarity)",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Prismatic"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "D_Rarity",
    Callback = function(Options) _G.Mofenk.SellRarities = Options end,
})
TabSell:CreateToggle({Name = "🗑️ Aktifkan Auto Jual Berdasarkan Rarity", CurrentValue = false, Flag = "T_SellRarity", Callback = function(v) _G.Mofenk.AutoSellRarity = v end})

-- --- TAB: LEVEL & UPGRADE ---
TabUp:CreateSection("📈 Peningkatan Karakter & Dadu")
TabUp:CreateToggle({Name = "⬆️ Auto Upgrade Brainrot", CurrentValue = false, Flag = "T_UpBrainrot", Callback = function(v) _G.Mofenk.AutoUpBrainrot = v end})
TabUp:CreateToggle({Name = "🎲 Auto Upgrade Tingkatan Dadu", CurrentValue = false, Flag = "T_UpDice", Callback = function(v) _G.Mofenk.AutoUpDice = v end})
TabUp:CreateToggle({Name = "🛍️ Auto Beli Dadu", CurrentValue = false, Flag = "T_BuyDice", Callback = function(v) _G.Mofenk.AutoBuyDice = v end})
TabUp:CreateToggle({Name = "🔄 Auto Rebirth Otomatis", CurrentValue = false, Flag = "T_Rebirth", Callback = function(v) _G.Mofenk.AutoRebirth = v end})

-- --- TAB: DUNGEON & TOKO ---
TabTower:CreateSection("🗼 Dungeon Tower Otomatis")
TabTower:CreateToggle({Name = "⚔️ Auto Masuk Dungeon (Map: Sahur)", CurrentValue = false, Flag = "T_Dungeon", Callback = function(v) _G.Mofenk.AutoDungeon = v end})

TabTower:CreateSection("🛒 Toko Dungeon")
TabTower:CreateToggle({Name = "🛍️ Auto Beli Semua Item Toko Dungeon", CurrentValue = false, Flag = "T_Shop", Callback = function(v) _G.Mofenk.AutoShop = v end})

-- --- TAB: EVENT & HADIAH ---
TabEvent:CreateSection("Klaim Hadiah & Quest")
TabEvent:CreateToggle({Name = "🎁 Auto Klaim Semua Quest", CurrentValue = false, Flag = "T_Quest", Callback = function(v) _G.Mofenk.AutoQuest = v end})
TabEvent:CreateToggle({Name = "🍬 Auto Farming Event Candy Shop", CurrentValue = false, Flag = "T_Candy", Callback = function(v) _G.Mofenk.AutoCandy = v end})
TabEvent:CreateToggle({Name = "☄️ Auto Klaim Meteor Drop", CurrentValue = false, Flag = "T_Meteor", Callback = function(v) _G.Mofenk.AutoMeteor = v end})
TabEvent:CreateToggle({Name = "📦 Auto Buka Lucky Block", CurrentValue = false, Flag = "T_Lucky", Callback = function(v) _G.Mofenk.AutoLuckyBlock = v end})
TabEvent:CreateToggle({Name = "🧪 Auto Gunakan Potion / Boost Item", CurrentValue = false, Flag = "T_Boost", Callback = function(v) _G.Mofenk.AutoBoost = v end})

-- --- TAB: SCANNER SPY TXT ---
TabSpy:CreateSection("🔍 Scanner Remote & Brainrot Spy")
TabSpy:CreateParagraph({
    Title = "📁 Informasi File Log Spy",
    Content = "Setiap remote game atau event yang aktif akan otomatis tercatat, dimunculkan notifikasinya di layar, dan disimpan ke dalam file teks dengan nama: 'MofenkHub_RemoteSpy_Logs.txt' di folder workspace executor Anda."
})
TabSpy:CreateToggle({
    Name = "🔍 Aktifkan Scanner Spy & Simpan ke TXT",
    CurrentValue = false,
    Flag = "T_Spy",
    Callback = function(v)
        _G.Mofenk.SpyEnabled = v
        if v then
            notifyUI("Scanner Spy", "Spy aktif! Log aktivitas direkam ke file teks.", 3)
        else
            notifyUI("Scanner Spy", "Spy dimatikan.", 3)
        end
    end
})
TabSpy:CreateButton({
    Name = "💾 Simpan Manual Log ke File TXT Sekarang",
    Callback = function()
        saveSpyToFile()
        notifyUI("Berhasil", "File 'MofenkHub_RemoteSpy_Logs.txt' berhasil diperbarui!", 3)
    end
})

-- --- TAB: SISTEM & DUNIA ---
TabSys:CreateSection("⚡ Optimasi & Performa")
TabSys:CreateToggle({
    Name = "📉 Mode Hemat CPU / Anti Lag (Hapus Render 3D)",
    CurrentValue = false,
    Flag = "T_CPU",
    Callback = function(v)
        _G.Mofenk.ReduceCPU = v
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
TabSys:CreateToggle({Name = "🔄 Auto Reconnect (Otomatis Masuk Jika DC)", CurrentValue = true, Flag = "T_Reconnect", Callback = function(v) _G.Mofenk.AutoReconnect = v end})

TabSys:CreateSection("🌐 Perpindahan Server")
TabSys:CreateButton({
    Name = "🌐 Cari Server Lain (Server Hop)",
    Callback = function()
        pcall(function()
            local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
            for _, server in ipairs(Servers) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end
})

-- ======================================================= --
-- 4. BACKGROUND LOOPS & SCRIPT UTAMA
-- ======================================================= --

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Auto Reconnect Trigger
game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if _G.Mofenk.AutoReconnect and child.Name == "ErrorPrompt" then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Realtime Updater Profil & Ping
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local pingVal = math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            LabelPing:Set("📶 Ping Server: " .. pingVal .. " ms (Aman)")
            
            local remoteInv = getRemote("RequestInventorySnapshot")
            if remoteInv then
                local snap = remoteInv:InvokeServer()
                if snap then
                    local total = 0
                    for _, _ in pairs(snap) do total = total + 1 end
                    LabelInv:Set("🎒 Total Item di Tas: " .. total .. " / 100 Slot")
                end
            end
        end)
    end
end)

-- Hooking Metatables untuk Scanner Spy Otomatis
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
        local logMsg = string.format("[SPY DETECTED] %s -> Remote: %s | Args Count: %d\n", method, tostring(self.Name), #args)
        spyLogsText = spyLogsText .. logMsg
        saveSpyToFile()
        notifyUI("🔍 Spy Terdeteksi", "Remote: " .. tostring(self.Name), 1.5)
    end
    return oldNamecall(self, ...)
end)

-- Loop Utama: Ambil Uang & Gacha
task.spawn(function()
    while task.wait(_G.Mofenk.CollectDelay) do
        if _G.Mofenk.AutoCollect then
            safeFire("MoneyCollected") 
            safeFire("RequestMoneyBuffState")
            safeFire("ClaimCash") 
            safeFire("CollectMoney") 
            safeFire("ClaimMoney") 
            safeFire("ClaimIncome")
            
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
        
        if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
        if _G.Mofenk.InstantRoll and _G.Mofenk.AutoRoll then safeFire("RollRequest") end
        if _G.Mofenk.AutoGrade then safeFire("RerollGradeRequest") end
        if _G.Mofenk.AutoTrait then safeFire("SpinTraitRequest") end
    end
end)

-- Loop Menengah: Manajemen & Dungeon
task.spawn(function()
    while task.wait(1.5) do
        if _G.Mofenk.AutoEquipBest then safeFire("EquipBest") safeFire("EquipBestBattleSquadRequest") end
        if _G.Mofenk.AutoLock then safeFire("ToggleLockRequest") end
        
        if _G.Mofenk.AutoSellRarity and #_G.Mofenk.SellRarities > 0 then
            for _, r in ipairs(_G.Mofenk.SellRarities) do 
                safeFire("SellAllRequest", r)
                safeFire("SellBrainrotByRarity", r)
            end
        end

        if _G.Mofenk.AutoDungeon then safeFire("RequestDungeonTeleport", "Sahur") end
        if _G.Mofenk.AutoShop then safeFire("DungeonShopAutoBuy") end
    end
end)

-- Loop Lambat: Upgrade, Event & Quest
task.spawn(function()
    while task.wait(3.0) do
        if _G.Mofenk.AutoUpBrainrot then safeFire("UpgradeBrainrotRequest") end
        if _G.Mofenk.AutoUpDice then safeFire("UpgradeDiceRequest") end
        if _G.Mofenk.AutoBuyDice then safeFire("BuyDiceRequest") end
        if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
        
        if _G.Mofenk.AutoMeteor then safeFire("MeteorClaimed") end
        if _G.Mofenk.AutoLuckyBlock then safeFire("OpenLuckyBlocks", "LuckyBlock") end
        if _G.Mofenk.AutoBoost then 
            safeFire("UsePotionRequest") 
            safeFire("ActivateBoostRequest")
            safeFire("ClaimActiveBoosts") 
        end
        
        if _G.Mofenk.AutoQuest then 
            safeFire("CollectAllQuests") 
            safeFire("ClaimAllQuests") 
            safeFire("CollectAllReward")
            if GameData.Quest and type(GameData.Quest.GetActiveDailyQuests) == "function" then
                pcall(function() for id, _ in pairs(GameData.Quest.GetActiveDailyQuests()) do safeFire("ClaimQuest", id) end end)
            end
        end

        if _G.Mofenk.AutoCandy then 
            if GameData.CandyShop and GameData.CandyShop.Start then pcall(function() GameData.CandyShop.Start() end) end
            safeFire("StartCandyEvent") 
            safeFire("ClaimCandyRewards") 
        end
    end
end)

Rayfield:LoadConfiguration()
notifyUI("👑 MofenkHub Berhasil", "Script Masterpiece V36 berhasil dimuat dengan sempurna!", 4)
