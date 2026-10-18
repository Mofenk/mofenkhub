-- ==========================================================
-- 👑 FIKRAH HUB V26.0 (ULTIMATE COMPLETE + SPY) 👑
-- ==========================================================

local successUI, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successUI or not Rayfield then
    task.wait(1)
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local namaGameBeneran = "Anime Dice / Brainrot Game"
pcall(function() namaGameBeneran = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

local Window = Rayfield:CreateWindow({
   Name = "👑 Fikrah Hub Pro | " .. namaGameBeneran,
   LoadingTitle = "Memuat Sistem V26.0...",
   LoadingSubtitle = "By Fikrah - Full Fitur & Live Spy Active",
   ConfigurationSaving = { Enabled = true, FolderName = "FikrahHub_V26", FileName = LocalPlayer.Name },
   KeySystem = false,
   Keybind = Enum.KeyCode.RightControl 
})

-- Tombol Mengambang (Floating Toggle) Rapi & Responsif
local parentUI = (gethui and gethui()) or game:GetService("CoreGui")
local ToggleGui = Instance.new("ScreenGui", parentUI)
ToggleGui.Name = "FikrahToggleV26"
ToggleGui.ResetOnSpawn = false
local ToggleBtn = Instance.new("TextButton", ToggleGui)
ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleBtn.Position = UDim2.new(0.5, -21, 0.04, 0) 
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Text = "👑"
ToggleBtn.TextSize = 18
ToggleBtn.Draggable = true 
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0) 

ToggleBtn.MouseButton1Click:Connect(function()
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    vim:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- ==========================================
-- DATABASE & STATE CONFIG
-- ==========================================
_G.AutoRoll = false; _G.InstantRoll = false
_G.AutoSellRarity = false; _G.SelectedRarity = "Umum"
_G.AutoCollectMoney = false; _G.CollectDelay = 3.0
_G.AutoBuyDice = false; _G.AutoRebirth = false
_G.AutoUpgradeDice = false; _G.AutoUpgradeBrainrot = false
_G.AutoEquipBest = false
_G.AntiAFK = true; _G.AutoHop = false; _G.AutoBoost = false
_G.AutoClaimAllRewards = false; _G.AutoMeteor = false; _G.AutoLuckyBlock = false
_G.SpyEnabled = false

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

local function safeFire(remoteName, ...)
    if RemotesFolder then
        local remote = RemotesFolder:FindFirstChild(remoteName)
        if remote then
            pcall(function(...)
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(...)
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(...)
                end
            end, ...)
        end
    end
end

-- ==========================================
-- SPY & LIVE PACKET SNIFFER
-- ==========================================
LogService.MessageOut:Connect(function(message, messageType)
    if _G.SpyEnabled then
        if messageType == Enum.MessageType.MessageError or messageType == Enum.MessageType.MessageWarning then
            warn("❌ [SPY ERROR ALERT] >> " .. message)
        end
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.SpyEnabled and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local success, rName = pcall(function() return self.Name end)
        if success and type(rName) == "string" then
            if rName ~= "MouseTarget" and rName ~= "UpdateMouse" and rName ~= "Move" then
                print("🔍 [LIVE SPY] Method: " .. method .. " | Remote: " .. rName)
                local args = {...}
                for i, v in ipairs(args) do
                    print("     ↳ Arg ["..i.."] = " .. tostring(v) .. " ("..typeof(v)..")")
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- ==========================================
-- SERVER HOP SYSTEM (MANUAL & AUTO)
-- ==========================================
local function hopServer()
    pcall(function()
        print("🌐 [SERVER HOP] Mencari server publik alternatif...")
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local body = HttpService:JSONDecode(req)
        if body and body.data then
            for _, s in pairs(body.data) do
                if type(s) == "table" and s.playing < s.maxPlayers and s.id ~= game.JobId then
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

-- ==========================================
-- TAB KATEGORI UI (TERSTRUKTUR & RAPI)
-- ==========================================
local TabAutomatic = Window:CreateTab("⚙️ Automatic", 4483345998)
local TabUpgrades  = Window:CreateTab("📈 Upgrades & Base", 4483345998)
local TabGacha     = Window:CreateTab("🎲 Roll & Misc", 4483345998)
local TabClaim     = Window:CreateTab("🎁 Hadiah & Event", 4483345998)
local TabSystem    = Window:CreateTab("👑 Sistem & Spy", 4483345998)

-- TAB 1: AUTOMATIC
TabAutomatic:CreateToggle({Name = "⚡ Auto Roll / Gacha", Flag = "T_Roll", Callback = function(v) _G.AutoRoll = v end})
TabAutomatic:CreateToggle({Name = "🚀 Auto Instant Roll Speed", Flag = "T_InstRoll", Callback = function(v) _G.InstantRoll = v end})
TabAutomatic:CreateToggle({Name = "👕 Auto Equip Best Item", Flag = "T_Equip", Callback = function(v) _G.AutoEquipBest = v end})

TabAutomatic:CreateToggle({
    Name = "🗑️ Auto Sell Rarity (Penjualan Otomatis)", 
    Flag = "T_SellRarity", 
    Callback = function(v) 
        _G.AutoSellRarity = v 
        if v then
            task.spawn(function()
                while _G.AutoSellRarity do
                    safeFire("ToggleAutoSellRarityRequest", true)
                    safeFire("SellSelectedRequest", _G.SelectedRarity)
                    safeFire("SellAllRequest")
                    task.wait(2.5)
                end
            end)
        end
    end
})

TabAutomatic:CreateDropdown({
    Name = "📌 Pilih Rarity untuk Dijual",
    Options = {"Umum", "Tidak Umum", "Langka", "Epik", "Legendaris", "Mitos"},
    CurrentOption = "Umum",
    Flag = "D_Rarity",
    Callback = function(option)
        _G.SelectedRarity = option
    end
})

TabAutomatic:CreateToggle({
    Name = "💰 Auto Collect Money (Base Income)", 
    Flag = "T_Money", 
    Callback = function(v) 
        _G.AutoCollectMoney = v 
        if v then
            task.spawn(function()
                while _G.AutoCollectMoney do
                    pcall(function()
                        safeFire("MoneyCollected")
                        safeFire("RequestMoneyBuffState")
                        
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            for _, obj in pairs(Workspace:GetChildren()) do
                                if obj:IsA("Model") then
                                    local n = obj.Name:lower()
                                    if n:find("cash") or n:find("money") or n:find("drop") or n:find("brainrot") then
                                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                        if part then
                                            firetouchinterest(char.HumanoidRootPart, part, 0)
                                            firetouchinterest(char.HumanoidRootPart, part, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(_G.CollectDelay)
                end
            end)
        end
    end
})

TabAutomatic:CreateSlider({
    Name = "⏱️ Interval Collect Money (Detik)",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 3.0,
    Flag = "S_CollectDelay",
    Callback = function(v) _G.CollectDelay = v end
})

-- TAB 2: UPGRADES & BASE
TabUpgrades:CreateToggle({Name = "📈 Auto Level Up Units (Max 40)", Flag = "T_LvlBrain", Callback = function(v) _G.AutoUpgradeBrainrot = v end})
TabUpgrades:CreateToggle({Name = "📈 Auto Level Up Dice (Max 36)", Flag = "T_LvlDice", Callback = function(v) _G.AutoUpgradeDice = v end})
TabUpgrades:CreateToggle({Name = "🎲 Auto Buy Dice", Flag = "T_Buy", Callback = function(v) _G.AutoBuyDice = v end})
TabUpgrades:CreateToggle({Name = "🔄 Auto Rebirth (Max 16 Podiums)", Flag = "T_Reb", Callback = function(v) _G.AutoRebirth = v end})
TabUpgrades:CreateButton({Name = "🏠 Spawn / Teleport Base Saya", Callback = function() safeFire("RequestMyBaseSpawn") safeFire("BaseLiked") end})

-- TAB 3: ROLL & MISC
TabGacha:CreateToggle({Name = "🧪 Auto Boost / Potion", Flag = "T_Boost", Callback = function(v) _G.AutoBoost = v end})
TabGacha:CreateButton({Name = "🏰 Teleport Dungeon Manual", Callback = function() safeFire("RequestDungeonTeleport") end})

-- TAB 4: HADIAH & EVENT
TabClaim:CreateToggle({Name = "🎁 Auto Claim Quests & Playtime", Flag = "T_ClaimAll", Callback = function(v) _G.AutoClaimAllRewards = v end})
TabClaim:CreateToggle({Name = "☄️ Auto Claim Meteor", Flag = "T_Met", Callback = function(v) _G.AutoMeteor = v end})
TabClaim:CreateToggle({Name = "📦 Auto Lucky Block", Flag = "T_LuckB", Callback = function(v) _G.AutoLuckyBlock = v end})

-- TAB 5: SISTEM, SERVER & SPY
TabSystem:CreateToggle({
    Name = "👁️ Aktifkan Spy & Error Watcher",
    CurrentValue = false,
    Callback = function(v)
        _G.SpyEnabled = v
        if v then print("👁️ [SPY] Live Inspector aktif. Silakan lihat Console (F9) untuk memantau paket game.") end
    end
})

TabSystem:CreateButton({
    Name = "🌐 Server Hop Manual (Pindah Server Sekarang)",
    Callback = function()
        hopServer()
    end
})

TabSystem:CreateToggle({
    Name = "🌐 Auto Hop Server (Pindah Otomatis tiap 5 Menit)",
    CurrentValue = false,
    Callback = function(v)
        _G.AutoHop = v
        if v then
            task.spawn(function()
                task.wait(300) 
                if _G.AutoHop then hopServer() end
            end)
        end
    end
})

TabSystem:CreateToggle({
   Name = "🛡️ Anti-AFK (Aman untuk ditinggal)", 
   CurrentValue = true, 
   Flag = "T_AntiAFK",
   Callback = function(v)
        _G.AntiAFK = v
        if v then
            local VirtualUser = game:GetService("VirtualUser")
            game.Players.LocalPlayer.Idled:Connect(function()
                if _G.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
   end
})

-- ==========================================
-- MESIN EKSEKUTOR UTAMA (STABIL & ANTI-LAG)
-- ==========================================
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoRoll then safeFire("RollRequest") end
        if _G.InstantRoll then
            safeFire("RollRequest")
            safeFire("MultiRollRequest")
        end
        if _G.AutoBoost then
            safeFire("UseBoostRequest")
            safeFire("ActivatePotionRequest")
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if _G.AutoUpgradeBrainrot then
            safeFire("UpgradeBrainrotRequest", 40)
            safeFire("UpgradeMoneyBuffRequest")
            safeFire("UpgradeSellBuffRequest")
        end
        if _G.AutoUpgradeDice then
            safeFire("UpgradeDiceRequest", 36)
        end
        if _G.AutoBuyDice then 
            safeFire("BuyDiceRequest") 
        end
        if _G.AutoRebirth then 
            safeFire("RebirthRequest") 
        end
        if _G.AutoEquipBest then 
            safeFire("EquipBest")
            safeFire("EquipBestBattlesquadRequest")
        end
        if _G.AutoClaimAllRewards then 
            safeFire("ClaimAllQuests")
            safeFire("ClaimPlaytimeGift")
            safeFire("ClaimStreakReward")
        end
        if _G.AutoMeteor then
            safeFire("MeteorClaimed")
            safeFire("MeteorIncoming")
        end
        if _G.AutoLuckyBlock then
            safeFire("OpenLuckyBlock")
            safeFire("OpenLuckyBlocks")
        end
    end
end)

Rayfield:LoadConfiguration()
