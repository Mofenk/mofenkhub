-- ====================================================================
-- 👑 FIKRAH HUB V28.1 - FULL FEATURES, FIXED TOWER & DETAILED SPY 👑
-- ====================================================================

local successUI, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successUI or not Rayfield then
    task.wait(1)
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService    = game:GetService("TeleportService")
local Players            = game:GetService("Players")
local LocalPlayer        = Players.LocalPlayer
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local HttpService        = game:GetService("HttpService")

local namaGameBeneran = "Brainrot Dice"
pcall(function() namaGameBeneran = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

local Window = Rayfield:CreateWindow({
   Name = "👑 Fikrah Hub Pro | " .. namaGameBeneran,
   LoadingTitle = "Memuat Fikrah Hub V28.1...",
   LoadingSubtitle = "By Fikrah - Full Features & Detailed Spy",
   ConfigurationSaving = { Enabled = true, FolderName = "FikrahHub_V28", FileName = LocalPlayer.Name },
   KeySystem = false,
   Keybind = Enum.KeyCode.RightControl 
})

-- Tombol Mengambang (Floating Toggle UI)
local parentUI = (gethui and gethui()) or game:GetService("CoreGui")
local ToggleGui = Instance.new("ScreenGui", parentUI)
ToggleGui.Name = "FikrahToggleV28"
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

-- DATABASE & STATE CONFIG
_G.AutoRoll = false; _G.InstantRoll = false
_G.AutoRerollGrade = false; _G.AutoRerollTrait = false
_G.AutoSellRarity = false; _G.SelectedRarity = "Umum"
_G.AutoCollectMoney = false; _G.CollectDelay = 3.0
_G.AutoBuyDice = false; _G.AutoRebirth = false
_G.AutoUpgradeDice = false; _G.AutoUpgradeBrainrot = false
_G.AutoEquipBest = false
_G.AntiAFK = true; _G.AutoHop = false; _G.AutoBoost = false
_G.AutoClaimAllRewards = false; _G.AutoMeteor = false; _G.AutoLuckyBlock = false
_G.SpyEnabled = false

_G.AutoTower = false
_G.AutoMixTower = false
_G.AutoJoinRandomTower = false

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

-- DETAILED SPY SYSTEM (BACA PARAMETER & ISI TABLE)
local function dumpArgs(...)
    local args = {...}
    if #args == 0 then return " (Tanpa Parameter / Kosong)" end
    local str = ""
    for i, arg in ipairs(args) do
        local argType = type(arg)
        if argType == "table" then
            local ok, json = pcall(function() return HttpService:JSONEncode(arg) end)
            if ok then
                str = str .. string.format("\n  └─ [Param %d] (Table): %s", i, json)
            else
                str = str .. string.format("\n  └─ [Param %d] (Table): {Gagal Serialisasi}", i)
            end
        elseif argType == "userdata" or typeof(arg) == "Instance" then
            str = str .. string.format("\n  └─ [Param %d] (Instance): %s", i, tostring(arg))
        else
            str = str .. string.format("\n  └─ [Param %d] (%s): %s", i, argType, tostring(arg))
        end
    end
    return str
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.SpyEnabled and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local rName = tostring(self.Name)
        if rName ~= "MouseTarget" and rName ~= "UpdateMouse" and rName ~= "Move" and rName ~= "GetMouse" then
            local isiData = dumpArgs(...)
            print(string.format("🚨 [SPY CLICK]\n📌 Remote: %s\n🛠️ Method: %s%s\n-----------------------------------", rName, method, isiData))
        end
    end
    return oldNamecall(self, ...)
end))

-- LOGIKA TOWER DADU
local function handleTowerSystem()
    pcall(function()
        if _G.AutoMixTower then
            safeFire("MixTowerRequest")
            safeFire("MergeTowerUnits")
            safeFire("CombineTower")
        end
        if _G.AutoTower then
            safeFire("UpgradeTowerRequest")
            safeFire("PlaceTowerRequest")
        end
        if _G.AutoJoinRandomTower then
            safeFire("JoinRandomTowerRequest")
            safeFire("JoinTowerLobby")
        end
    end)
end

-- COLLECT BALANCE
local function performMoneyCollect()
    pcall(function()
        safeFire("MoneyCollected")
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local searchFolders = {Workspace:FindFirstChild("Bases"), Workspace:FindFirstChild("Plots"), Workspace}
            for _, folder in pairs(searchFolders) do
                if folder then
                    for _, obj in pairs(folder:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            local n = obj.Name:lower()
                            if n:find("cash") or n:find("money") or n:find("drop") or n:find("coin") then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if targetPart then
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

-- SERVER HOP
local function hopServer()
    pcall(function()
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

-- TAB UI
local TabAutomatic = Window:CreateTab("⚙️ Automatic", 4483345998)
local TabTower     = Window:CreateTab("🗼 Menara & Event", 4483345998)
local TabUpgrades  = Window:CreateTab("📈 Upgrades & Base", 4483345998)
local TabGacha     = Window:CreateTab("🎲 Roll & Misc", 4483345998)
local TabSystem    = Window:CreateTab("👑 Sistem & Spy", 4483345998)

-- TAB AUTOMATIC
TabAutomatic:CreateToggle({Name = "⚡ Auto Roll / Gacha", Flag = "T_Roll", Callback = function(v) _G.AutoRoll = v end})
TabAutomatic:CreateToggle({Name = "🚀 Auto Instant Roll Speed", Flag = "T_InstRoll", Callback = function(v) _G.InstantRoll = v end})
TabAutomatic:CreateToggle({Name = "✨ Auto Reroll Grade", Flag = "T_Grade", Callback = function(v) _G.AutoRerollGrade = v end})
TabAutomatic:CreateToggle({Name = "🌀 Auto Reroll Trait", Flag = "T_Trait", Callback = function(v) _G.AutoRerollTrait = v end})
TabAutomatic:CreateToggle({Name = "👕 Auto Equip Best Item", Flag = "T_Equip", Callback = function(v) _G.AutoEquipBest = v end})

TabAutomatic:CreateToggle({
    Name = "🗑️ Auto Sell Rarity", 
    Flag = "T_SellRarity", 
    Callback = function(v) 
        _G.AutoSellRarity = v 
        if v then
            task.spawn(function()
                while _G.AutoSellRarity do
                    safeFire("ToggleAutoSellRarityRequest", true)
                    safeFire("SellSelectedRequest", _G.SelectedRarity)
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
    Callback = function(option) _G.SelectedRarity = option end
})

TabAutomatic:CreateToggle({
    Name = "💰 Auto Collect Balance", 
    Flag = "T_Money", 
    Callback = function(v) 
        _G.AutoCollectMoney = v 
        if v then
            task.spawn(function()
                while _G.AutoCollectMoney do
                    performMoneyCollect()
                    task.wait(_G.CollectDelay)
                end
            end)
        end
    end
})

TabAutomatic:CreateButton({Name = "💵 Collect Sekarang (Manual)", Callback = function() performMoneyCollect() end})
TabAutomatic:CreateSlider({
    Name = "⏱️ Interval Collect (Detik)",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 3.0,
    Flag = "S_CollectDelay",
    Callback = function(v) _G.CollectDelay = v end
})

-- TAB TOWER & EVENT
TabTower:CreateToggle({
    Name = "🗼 Auto Place/Upgrade Menara",
    Flag = "T_AutoTower",
    Callback = function(v) _G.AutoTower = v end
})

TabTower:CreateToggle({
    Name = "🌀 Auto Mix / Combine Dadu Menara",
    Flag = "T_MixTower",
    Callback = function(v) _G.AutoMixTower = v end
})

TabTower:CreateToggle({
    Name = "🎲 Auto Join Menara Random",
    Flag = "T_JoinRandomTower",
    Callback = function(v) _G.AutoJoinRandomTower = v end
})

TabTower:CreateToggle({Name = "🎁 Auto Claim Quests & Playtime", Flag = "T_ClaimAll", Callback = function(v) _G.AutoClaimAllRewards = v end})
TabTower:CreateToggle({Name = "☄️ Auto Claim Meteor", Flag = "T_Met", Callback = function(v) _G.AutoMeteor = v end})
TabTower:CreateToggle({Name = "📦 Auto Lucky Block", Flag = "T_LuckB", Callback = function(v) _G.AutoLuckyBlock = v end})

-- TAB UPGRADES
TabUpgrades:CreateToggle({Name = "📈 Auto Level Up Units", Flag = "T_LvlBrain", Callback = function(v) _G.AutoUpgradeBrainrot = v end})
TabUpgrades:CreateToggle({Name = "📈 Auto Level Up Dice", Flag = "T_LvlDice", Callback = function(v) _G.AutoUpgradeDice = v end})
TabUpgrades:CreateToggle({Name = "🎲 Auto Buy Dice", Flag = "T_Buy", Callback = function(v) _G.AutoBuyDice = v end})
TabUpgrades:CreateToggle({Name = "🔄 Auto Rebirth", Flag = "T_Reb", Callback = function(v) _G.AutoRebirth = v end})
TabUpgrades:CreateButton({Name = "🏠 Spawn Base Saya", Callback = function() safeFire("RequestMyBaseSpawn") end})

-- TAB GACHA & MISC
TabGacha:CreateToggle({Name = "🧪 Auto Boost / Potion", Flag = "T_Boost", Callback = function(v) _G.AutoBoost = v end})
TabGacha:CreateButton({Name = "🏰 Teleport Dungeon Manual", Callback = function() safeFire("RequestDungeonTeleport") end})

-- TAB SISTEM
TabSystem:CreateToggle({
    Name = "👁️ Aktifkan Spy Detail (Cek F9)",
    CurrentValue = false,
    Callback = function(v) _G.SpyEnabled = v end
})

TabSystem:CreateButton({Name = "🌐 Server Hop Manual", Callback = function() hopServer() end})

TabSystem:CreateToggle({
    Name = "🌐 Auto Hop Server (Tiap 5 Menit)",
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
   Name = "🛡️ Anti-AFK", 
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

-- LOOPS EKSEKUSI
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoRoll then safeFire("RollRequest") end
        if _G.InstantRoll then
            safeFire("RollRequest")
            safeFire("MultiRollRequest")
        end
        if _G.AutoRerollGrade then safeFire("RerollGradeRequest") end
        if _G.AutoRerollTrait then safeFire("RerollTraitRequest") end
        if _G.AutoBoost then safeFire("UseBoostRequest") end
    end
end)

task.spawn(function()
    while task.wait(0.8) do
        handleTowerSystem()
    end
end)

task.spawn(function()
    while task.wait(3) do
        if _G.AutoUpgradeBrainrot then safeFire("UpgradeBrainrotRequest", 40) end
        if _G.AutoUpgradeDice then safeFire("UpgradeDiceRequest", 36) end
        if _G.AutoBuyDice then safeFire("BuyDiceRequest") end
        if _G.AutoRebirth then safeFire("RebirthRequest") end
        if _G.AutoEquipBest then safeFire("EquipBest") end
        if _G.AutoClaimAllRewards then safeFire("ClaimAllQuests") end
        if _G.AutoMeteor then safeFire("MeteorClaimed") end
        if _G.AutoLuckyBlock then safeFire("OpenLuckyBlock") end
    end
end)

Rayfield:LoadConfiguration()
