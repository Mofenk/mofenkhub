-- =====================================================================
-- MOFENKHUB — DADU BRAINROT! RAYFIELD UI + REMOTE SPY EDITION
-- Dilengkapi Rayfield Library, Remote Spy Scanner, & Seluruh Fitur Bot
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    localPlayer = Players.PlayerAdded:Wait()
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Load Rayfield Library secara aman
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MofenkHub — Dadu Brainrot! [Rayfield Edition]",
    LoadingTitle = "MofenkHub Loading...",
    LoadingSubtitle = "by Mofenk",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "MofenkHub",
        FileName = "DaduBrainrotConfig"
    },
    KeySystem = false,
})

-- =====================================================================
-- 1. TAB: UTAMA (Auto Roll & Base Farm)
-- =====================================================================
local MainTab = Window:CreateTab("🎲 Utama & Roll", 4483362458)

MainTab:CreateToggle({
    Name = "Auto Instant Roll Dice",
    CurrentValue = false,
    Flag = "AutoRoll",
    Callback = function(Value)
        getgenv().AutoRoll = Value
        task.spawn(function()
            while getgenv().AutoRoll do
                pcall(function()
                    if Remotes:FindFirstChild("RollRequest") then
                        Remotes.RollRequest:FireServer()
                    end
                end)
                task.wait(0.2)
            end
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Collect Money (Base | Delay 30s)",
    CurrentValue = false,
    Flag = "AutoCollectMoney",
    Callback = function(Value)
        getgenv().AutoCollectMoney = Value
        task.spawn(function()
            while getgenv().AutoCollectMoney do
                pcall(function()
                    if Remotes:FindFirstChild("MoneyCollected") then
                        Remotes.MoneyCollected:FireServer()
                    end
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("money") or obj.Name:lower():find("cash") then
                            if obj:IsA("BasePart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                firetouchinterest(localPlayer.Character.HumanoidRootPart, obj, 0)
                                firetouchinterest(localPlayer.Character.HumanoidRootPart, obj, 1)
                            end
                        end
                    end
                end)
                task.wait(30) -- Delay 30 detik sesuai permintaan
            end
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Claim Rewards & Quests",
    CurrentValue = false,
    Flag = "AutoRewards",
    Callback = function(Value)
        getgenv().AutoRewards = Value
        task.spawn(function()
            while getgenv().AutoRewards do
                pcall(function()
                    if Remotes:FindFirstChild("ClaimAllQuests") then
                        Remotes.ClaimAllQuests:InvokeServer()
                    end
                    if Remotes:FindFirstChild("ClaimPlaytimeGift") then
                        Remotes.ClaimPlaytimeGift:InvokeServer()
                    end
                end)
                task.wait(10)
            end
        end)
    end,
})

-- =====================================================================
-- 2. TAB: DUNGEON & SHOP
-- =====================================================================
local DungeonTab = Window:CreateTab("⚔️ Dungeon & Shop", 4483362458)

DungeonTab:CreateToggle({
    Name = "Auto Farm Dungeon Tower (Map: Sahur)",
    CurrentValue = false,
    Flag = "AutoDungeon",
    Callback = function(Value)
        getgenv().AutoDungeon = Value
        task.spawn(function()
            while getgenv().AutoDungeon do
                pcall(function()
                    if Remotes:FindFirstChild("RequestDungeonTeleport") then
                        Remotes.RequestDungeonTeleport:InvokeServer("Sahur")
                    end
                end)
                task.wait(2)
            end
        end)
    end,
})

DungeonTab:CreateToggle({
    Name = "Auto Buy Dungeon Shop (All Items)",
    CurrentValue = false,
    Flag = "AutoShop",
    Callback = function(Value)
        getgenv().AutoShop = Value
        task.spawn(function()
            while getgenv().AutoShop do
                pcall(function()
                    if Remotes:FindFirstChild("DungeonShopAutoBuy") then
                        Remotes.DungeonShopAutoBuy:InvokeServer()
                    end
                end)
                task.wait(5)
            end
        end)
    end,
})

-- =====================================================================
-- 3. TAB: MANAGE & SELL (Sell by Rarity)
-- =====================================================================
local ManageTab = Window:CreateTab("📦 Sell & Inventory", 4483362458)

local selectedRarity = "Common"
ManageTab:CreateDropdown({
    Name = "Pilih Filter Rarity Brainrot",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial"},
    CurrentOption = "Common",
    Flag = "RarityDropdown",
    Callback = function(Option)
        selectedRarity = Option
    end,
})

ManageTab:CreateToggle({
    Name = "Auto Sell Berdasarkan Rarity Terpilih",
    CurrentValue = false,
    Flag = "AutoSellRarity",
    Callback = function(Value)
        getgenv().AutoSellRarity = Value
        task.spawn(function()
            while getgenv().AutoSellRarity do
                pcall(function()
                    if Remotes:FindFirstChild("SellAllRequest") then
                        Remotes.SellAllRequest:FireServer(selectedRarity)
                    end
                end)
                task.wait(4)
            end
        end)
    end,
})

-- =====================================================================
-- 4. TAB: REMOTE SPY SCANNER (Fitur Scanner Spy)
-- =====================================================================
local SpyTab = Window:CreateTab("🔍 Remote Spy", 4483362458)

local spyActive = false
local spyLogs = "Log Remote Spy:\n"

SpyTab:CreateToggle({
    Name = "Aktifkan Remote Spy Scanner",
    CurrentValue = false,
    Flag = "RemoteSpyToggle",
    Callback = function(Value)
        spyActive = Value
        Rayfield:Notify({
            Title = "Remote Spy",
            Content = Value ? "Scanner Spy Aktif!" : "Scanner Spy Dimatikan.",
            Duration = 3,
        })
    end,
})

-- Hooking metatables untuk mendeteksi Remote Events/Functions yang dipanggil game
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if spyActive and (method == "FireServer" or method == "InvokeServer") then
        local logMsg = string.format("[%s] Remote: %s | Args: %s\n", method, tostring(self.Name), table.concat(args, ", "))
        print("MofenkHub Spy: " .. logMsg)
    end
    return oldNamecall(self, ...)
end)

SpyTab:CreateParagraph({Title = "Informasi Spy", Content = "Fitur ini merekam seluruh aktivitas RemoteEvent / RemoteFunction yang dipanggil oleh game ke Konsol Delta (F9 / Console)."})

-- =====================================================================
-- 5. TAB: WORLD & AFK BOT
-- =====================================================================
local WorldTab = Window:CreateTab("🌍 World & AFK", 4483362458)

WorldTab:CreateToggle({
    Name = "Auto Claim Meteor & Open Lucky Blocks",
    CurrentValue = false,
    Flag = "AutoMeteor",
    Callback = function(Value)
        getgenv().AutoMeteor = Value
        task.spawn(function()
            while getgenv().AutoMeteor do
                pcall(function()
                    if Remotes:FindFirstChild("MeteorClaimed") then
                        Remotes.MeteorClaimed:FireServer()
                    end
                    if Remotes:FindFirstChild("OpenLuckyBlocks") then
                        Remotes.OpenLuckyBlocks:InvokeServer(1)
                    end
                end)
                task.wait(3)
            end
        end)
    end,
})

WorldTab:CreateToggle({
    Name = "Anti-AFK (Cegah Terkick Server)",
    CurrentValue = false,
    Flag = "AntiAfk",
    Callback = function(Value)
        getgenv().AntiAfk = Value
        local vu = game:GetService("VirtualUser")
        if Value then
            localPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end,
})

WorldTab:CreateToggle({
    Name = "Toggle Render 3D (Anti-Lag / HP Dingin)",
    CurrentValue = false,
    Flag = "ToggleRender",
    Callback = function(Value)
        RunService:Set3dRenderingEnabled(not Value)
    end,
})

WorldTab:CreateButton({
    Name = "Server Hop (Pindah Server Lain)",
    Callback = function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, localPlayer)
                    break
                end
            end
        end)
    end,
})

-- =====================================================================
-- 6. TAB: PROFIL, INVENTORY DATA & MUSIK INDO
-- =====================================================================
local MusicTab = Window:CreateTab("🎧 Profil & Musik", 4483362458)

MusicTab:CreateParagraph({Title = "Status Akun Bot", Content = "Player: " .. localPlayer.Name})

local invStatusLabel = MusicTab:CreateParagraph({Title = "Data Inventory", Content = "Memuat data slot & item..."})

task.spawn(function()
    while true do
        pcall(function()
            if Remotes:FindFirstChild("RequestInventorySnapshot") then
                local snap = Remotes.RequestInventorySnapshot:InvokeServer()
                if snap then
                    local count = 0
                    for _, _ in pairs(snap) do count = count + 1 end
                    invStatusLabel:Set({Title = "Data Inventory", Content = "Total Item Tersedia: " .. count .. " / 100 Slot"})
                end
            end
        end)
        task.wait(5)
    end
end)

-- Pemutar Musik Indo
local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "HubMusicFolder"
SoundFolder.Parent = CoreGui

local BackgroundMusic = Instance.new("Sound")
BackgroundMusic.Name = "BGM_Player"
BackgroundMusic.SoundId = "rbxassetid://1845773120" -- Sialan - Mahalini
BackgroundMusic.Looped = true
BackgroundMusic.Volume = 0.5
BackgroundMusic.Parent = SoundFolder
BackgroundMusic:Play()

MusicTab:CreateButton({
    Name = "Play / Pause Musik Indo (Mahalini - Sialan)",
    Callback = function()
        if BackgroundMusic.IsPlaying then
            BackgroundMusic:Pause()
        else
            BackgroundMusic:Resume()
        end
    end,
})

MusicTab:CreateButton({
    Name = "Stop Musik",
    Callback = function()
        BackgroundMusic:Stop()
    end,
})

Rayfield:LoadConfiguration()
print("[MofenkHub Rayfield + Spy]: Berhasil dimuat dengan sukses!")
