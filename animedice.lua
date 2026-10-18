-- =====================================================================
-- 👑 MOFENKHUB V38 — ULTIMATE MASTERPIECE (FULL FIX & PRECISION)
-- Game: Dadu Brainrot! | Fitur: Teleport Presisi, Map Dungeon, Inventory Detail
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
-- 1. FUNGSI UTILITAS & SINKRONISASI MODUL GAME
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

local GameData = {
    Inventory = tryRequireModule({"Modules", "InventoryConfig"}),
    BrainrotLevel = tryRequireModule({"Modules", "BrainrotLevelConfig"}),
    Trait = tryRequireModule({"Modules", "TraitConfig"}),
}

local function getRemote(name)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == tostring(name):lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

local spyLogsText = "=== LOG REMOTE SPY MOFENKHUB (ADVANCED) ===\n\n"
local function saveSpyToFile()
    pcall(function()
        if writefile then writefile("MofenkHub_RemoteSpy_Logs.txt", spyLogsText) end
    end)
end

local function safeFire(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote then
        pcall(function(...)
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end, ...)
    end
end

-- ======================================================= --
-- 2. STATE UTAMA BOT
-- ======================================================= --
_G.Mofenk = {
    AutoCollect = false, CollectDelay = 1.0,
    AutoRoll = false, InstantRoll = false, AutoTrait = false,
    AutoSellRarity = false, SellRarities = {},
    AutoUpBrainrot = false, AutoUpDice = false, AutoRebirth = false,
    AutoDungeon = false, SelectedMap = "Sahur", AutoShop = false,
    AutoMeteor = false, AutoLuckyBlock = false,
    AutoReconnect = true, ReduceCPU = false, SpyEnabled = false
}

-- ======================================================= --
-- 3. ANTARMUKA RAYFIELD (UI RAPI & BAHASA INDONESIA)
-- ======================================================= --
local Window = Rayfield:CreateWindow({
    Name = "👑 MofenkHub V38 | Dadu Brainrot [Precision Edition]",
    LoadingTitle = "Memuat MofenkHub V38...",
    LoadingSubtitle = "Menyelaraskan modul presisi & inventory...",
    ConfigurationSaving = { Enabled = true, FolderName = "MofenkHubV38", FileName = LocalPlayer.Name },
    KeySystem = false
})

local TabProfil = Window:CreateTab("👤 Profil & Tas", 4483345998)
local TabFarm = Window:CreateTab("🎲 Farm & Roll", 4483345998)
local TabSell = Window:CreateTab("🗑️ Jual Rarity", 4483345998)
local TabUp = Window:CreateTab("📈 Level & Upgrade", 4483345998)
local TabTower = Window:CreateTab("🗼 Dungeon & Toko", 4483345998)
local TabEvent = Window:CreateTab("🎯 Event & Hadiah", 4483345998)
local TabSpy = Window:CreateTab("🔍 Scanner Spy", 4483345998)
local TabSys = Window:CreateTab("⚙️ Sistem", 4483345998)

-- --- TAB: PROFIL & TAS (DENGAN AVATAR & RINCIAN ITEM) ---
TabProfil:CreateSection("📋 Informasi Karakter & Statistik Tas")
local AvatarImg = "rbxassetid://0"
pcall(function()
    AvatarImg = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)

local LabelNama = TabProfil:CreateLabel("👤 Nama Pemain: " .. LocalPlayer.Name)
local LabelId = TabProfil:CreateLabel("🆔 ID Akun: " .. LocalPlayer.UserId)
local LabelPing = TabProfil:CreateLabel("📶 Ping Server: Memuat...")
local LabelInvSlot = TabProfil:CreateLabel("🎒 Slot Tas: Memuat...")
local LabelDetailItem = TabProfil:CreateLabel("📦 Rincian Item: Memuat...")

TabProfil:CreateButton({
    Name = "📋 Salin ID Akun ke Clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(LocalPlayer.UserId))
            notifyUI("Berhasil", "ID Akun disalin ke clipboard!", 3)
        end
    end,
})

-- --- TAB: FARM & ROLL ---
TabFarm:CreateSection("💸 Ekstraktor Uang Presisi (Depan Brainrot)")
TabFarm:CreateToggle({Name = "🧲 Auto Ambil Uang (Teleport ke Depan Podium)", CurrentValue = false, Flag = "T_Collect", Callback = function(v) _G.Mofenk.AutoCollect = v end})
TabFarm:CreateSlider({Name = "⏱️ Jeda Waktu Collect (Detik)", Range = {0.5, 5.0}, Increment = 0.5, CurrentValue = 1.0, Flag = "S_Delay", Callback = function(v) _G.Mofenk.CollectDelay = v end})

TabFarm:CreateSection("🎲 Automasi Lempar Dadu")
TabFarm:CreateToggle({Name = "🎲 Auto Lempar Dadu (Roll)", CurrentValue = false, Flag = "T_Roll", Callback = function(v) _G.Mofenk.AutoRoll = v end})
TabFarm:CreateToggle({Name = "⚡ Lempar Dadu Instan", CurrentValue = false, Flag = "T_InstaRoll", Callback = function(v) _G.Mofenk.InstantRoll = v end})
TabFarm:CreateToggle({Name = "✨ Auto Putar Sifat (Trait Spin)", CurrentValue = false, Flag = "T_Trait", Callback = function(v) _G.Mofenk.AutoTrait = v end})

-- --- TAB: JUAL RARITY ---
TabSell:CreateSection("🗑️ Kelola Jual Brainrot")
TabSell:CreateDropdown({
    Name = "🎯 Pilih Rarity yang Dijual",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Prismatic"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "D_Rarity",
    Callback = function(Options) _G.Mofenk.SellRarities = Options end,
})
TabSell:CreateToggle({Name = "🗑️ Aktifkan Auto Jual Rarity", CurrentValue = false, Flag = "T_SellRarity", Callback = function(v) _G.Mofenk.AutoSellRarity = v end})

-- --- TAB: LEVEL & UPGRADE ---
TabUp:CreateSection("📈 Peningkatan Sesuai Modul Game (Max Level 20)")
TabUp:CreateToggle({Name = "⬆️ Auto Upgrade Brainrot (1 - 20)", CurrentValue = false, Flag = "T_UpBrainrot", Callback = function(v) _G.Mofenk.AutoUpBrainrot = v end})
TabUp:CreateToggle({Name = "🎲 Auto Upgrade Tingkatan Dadu", CurrentValue = false, Flag = "T_UpDice", Callback = function(v) _G.Mofenk.AutoUpDice = v end})
TabUp:CreateToggle({Name = "🔄 Auto Rebirth Otomatis", CurrentValue = false, Flag = "T_Rebirth", Callback = function(v) _G.Mofenk.AutoRebirth = v end})

-- --- TAB: DUNGEON & TOKO ---
TabTower:CreateSection("🗼 Pilih Map Dungeon & Teleport")
TabTower:CreateDropdown({
    Name = "🗺️ Pilih Map Dungeon",
    Options = {"Sahur", "Orcala", "Bombardiro", "Void", "Inferno"},
    CurrentOption = "Sahur",
    Flag = "D_Map",
    Callback = function(Option) _G.Mofenk.SelectedMap = Option end,
})
TabTower:CreateToggle({Name = "⚔️ Auto Masuk Dungeon Sesuai Map", CurrentValue = false, Flag = "T_Dungeon", Callback = function(v) _G.Mofenk.AutoDungeon = v end})

TabTower:CreateSection("🛒 Toko Dungeon")
TabTower:CreateToggle({Name = "🛍️ Auto Beli Toko Dungeon", CurrentValue = false, Flag = "T_Shop", Callback = function(v) _G.Mofenk.AutoShop = v end})

-- --- TAB: EVENT & HADIAH ---
TabEvent:CreateSection("Klaim Hadiah In-Game")
TabEvent:CreateToggle({Name = "☄️ Auto Klaim Meteor Drop", CurrentValue = false, Flag = "T_Meteor", Callback = function(v) _G.Mofenk.AutoMeteor = v end})
TabEvent:CreateToggle({Name = "📦 Auto Buka Lucky Block", CurrentValue = false, Flag = "T_Lucky", Callback = function(v) _G.Mofenk.AutoLuckyBlock = v end})

-- --- TAB: SCANNER SPY ---
TabSpy:CreateSection("🔍 Scanner Remote Spy Terperinci")
TabSpy:CreateParagraph({
    Title = "Informasi Spy",
    Content = "Merekam semua interaksi Remote Event/Function secara akurat dan menyimpannya ke file 'MofenkHub_RemoteSpy_Logs.txt'."
})
TabSpy:CreateToggle({
    Name = "🔍 Aktifkan Scanner Spy",
    CurrentValue = false,
    Flag = "T_Spy",
    Callback = function(v)
        _G.Mofenk.SpyEnabled = v
        notifyUI("Scanner Spy", v ? "Spy diaktifkan." : "Spy dimatikan.", 2)
    end
})
TabSpy:CreateButton({
    Name = "💾 Simpan Log Spy ke File TXT",
    Callback = function()
        saveSpyToFile()
        notifyUI("Berhasil", "File teks log spy diperbarui!", 2)
    end
})

-- --- TAB: SISTEM ---
TabSys:CreateSection("Optimasi Performa")
TabSys:CreateToggle({
    Name = "📉 Mode Hemat CPU / Anti Lag",
    CurrentValue = false,
    Flag = "T_CPU",
    Callback = function(v)
        _G.Mofenk.ReduceCPU = v
        RunService:Set3dRenderingEnabled(not v)
    end
})
TabSys:CreateToggle({Name = "🔄 Auto Reconnect (Anti DC)", CurrentValue = true, Flag = "T_Reconnect", Callback = function(v) _G.Mofenk.AutoReconnect = v end})
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
-- 4. BACKGROUND LOOPS & LOGIKA UTAMA
-- ======================================================= --

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Auto Reconnect
game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if _G.Mofenk.AutoReconnect and child.Name == "ErrorPrompt" then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Realtime Profil & Data Tas Akurat (Max 100 Slot)
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local pingVal = math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            LabelPing:Set("📶 Ping Server: " .. pingVal .. " ms")
            
            local remoteInv = getRemote("RequestInventorySnapshot")
            if remoteInv then
                local snap = remoteInv:InvokeServer()
                if snap then
                    local totalItems = 0
                    local countJackpot, countBoostA, countBoostB, countBoostC, countBrainrots = 0, 0, 0, 0, 0
                    
                    for _, item in pairs(snap) do
                        totalItems = totalItems + 1
                        local nameLower = string.lower(tostring(item.Name or ""))
                        if nameLower:find("jackpot") then countJackpot = countJackpot + 1
                        elseif nameLower:find("boost_1") or nameLower:find("boost_luck") then countBoostA = countBoostA + 1
                        elseif nameLower:find("boost_2") or nameLower:find("boost_cash") then countBoostB = countBoostB + 1
                        elseif nameLower:find("boost_3") or nameLower:find("boost_damage") then countBoostC = countBoostC + 1
                        else countBrainrots = countBrainrots + 1 end
                    end
                    
                    LabelInvSlot:Set("🎒 Total Item di Tas: " .. totalItems .. " / 100 Slot")
                    LabelDetailItem:Set(string.format("📦 Brainrot: %d | Jackpot: %d | Boost A:%d B:%d C:%d", countBrainrots, countJackpot, countBoostA, countBoostB, countBoostC))
                end
            end
        end)
    end
end)

-- Hooking Spy Terperinci
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
        local argStr = ""
        for i, arg in ipairs(args) do argStr = argStr .. tostring(arg) .. (i < #args and ", " or "") end
        local logMsg = string.format("[SPY] %s -> Remote: %s | Args: [%s] | Jam: %s\n", method, tostring(self.Name), argStr, os.date("%X"))
        spyLogsText = spyLogsText .. logMsg
        saveSpyToFile()
        notifyUI("🔍 Spy Terdeteksi", tostring(self.Name), 1)
    end
    return oldNamecall(self, ...)
end)

-- Loop Utama: Teleport Presisi di Depan Brainrot/Base untuk Collect Uang
task.spawn(function()
    while task.wait(_G.Mofenk.CollectDelay) do
        if _G.Mofenk.AutoCollect then
            safeFire("MoneyCollected")
            safeFire("ClaimCash")
            safeFire("CollectMoney")
            
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    -- Cari base atau podium pemain agar berdiri pas di depan brainrot
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n:find("cash") or n:find("money") or n:find("drop") or n:find("podium") then
                                root.CFrame = obj.CFrame + Vector3.new(0, 3, 0) -- Berdiri tepat di atas/depan podium
                                task.wait(0.1)
                                break
                            end
                        end
                    end
                end
            end)
        end
        
        if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
        if _G.Mofenk.InstantRoll and _G.Mofenk.AutoRoll then safeFire("RollRequest") end
        if _G.Mofenk.AutoTrait then safeFire("SpinTraitRequest") end
    end
end)

-- Loop Menengah: Dungeon & Upgrade Level Brainrot (Max 20)
task.spawn(function()
    while task.wait(2.0) do
        if _G.Mofenk.AutoDungeon then safeFire("RequestDungeonTeleport", _G.Mofenk.SelectedMap) end
        if _G.Mofenk.AutoShop then safeFire("DungeonShopAutoBuy") end
        
        if _G.Mofenk.AutoSellRarity and #_G.Mofenk.SellRarities > 0 then
            for _, r in ipairs(_G.Mofenk.SellRarities) do safeFire("SellAllRequest", r) end
        end
        
        if _G.Mofenk.AutoUpBrainrot then
            for lvl = 1, 20 do safeFire("UpgradeBrainrotRequest", lvl) end
        end
        if _G.Mofenk.AutoUpDice then safeFire("UpgradeDiceRequest") end
        if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
    end
end)

Rayfield:LoadConfiguration()
notifyUI("👑 MofenkHub Berhasil", "Script V38 Presisi & Inventory Fix dimuat!", 4)
