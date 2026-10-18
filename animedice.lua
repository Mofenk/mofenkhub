-- ==================================================================== --
-- 👑 FIKRAH HUB V33 - PURE CUSTOM UI & FULL DATA SYNC
-- Target Game: Dadu Brainrot! (No External Libraries)
-- ==================================================================== --

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ======================================================= --
-- 1. SINKRONISASI DATA GAME (MODULES) & REMOTES
-- ======================================================= --
local function getModule(pathArray)
    local current = ReplicatedStorage
    for _, name in ipairs(pathArray) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return require(current)
end

local GameData = {
    BattleSquad = getModule({"Shared", "BattleSquadConfig"}),
    Dungeon = getModule({"Shared", "DungeonConfig"}),
    Inventory = getModule({"Modules", "InventoryConfig"}),
    BrainrotLevel = getModule({"Modules", "BrainrotLevelConfig"}),
    Quest = getModule({"Modules", "QuestConfig"}) or getModule({"QuestConfig"}),
    CandyShop = getModule({"ReleasedContent", "Update2", "Client", "CandyShop"}) or getModule({"CandyShop"})
}

local function safeFire(remoteName, ...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local remote = remotes:FindFirstChild(remoteName)
        if remote then
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end
    end
end

-- ======================================================= --
-- 2. STATE & KONFIGURASI BOT
-- ======================================================= --
_G.Fikrah = {
    -- Farm & Gacha
    AutoCollect = false, CollectDelay = 1.5,
    AutoRoll = false, AutoTrait = false, AutoGrade = false,
    -- Units
    AutoEquipBest = false, AutoLock = false, AutoSellJunk = false, AutoSellByRarity = false,
    SellRarities = {},
    -- Upgrade
    AutoUpgradeUnit = false, AutoUpgradeDice = false, AutoRebirth = false,
    -- Tower & Event
    AutoTowerJoin = false, AutoTowerMix = false, AutoTowerPlace = false, AutoBoss = false,
    AutoQuest = false, AutoCandy = false,
    -- System
    AutoReconnect = true, ReduceCPU = false
}

-- ======================================================= --
-- 3. FRAMEWORK CUSTOM UI (RINGAN & ANTI-LAG)
-- ======================================================= --
local UI = Instance.new("ScreenGui")
UI.Name = "FikrahHub_V33"
UI.ResetOnSpawn = false
UI.Parent = (gethui and gethui()) or CoreGui

-- Tombol Buka/Tutup (Mengambang)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Text = "👑"
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Draggable = true
ToggleBtn.Parent = UI
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 550, 0, 380)
Main.Position = UDim2.new(0.5, -275, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Draggable = true
Main.Active = true
Main.Parent = UI
Instance.new("UICorner", Main)
Main.Visible = false

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "  FIKRAH HUB V33 | Dadu Brainrot (Custom Core)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main
Instance.new("UICorner", Title)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = Main
local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 2)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -45)
ContentArea.Position = UDim2.new(0, 145, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local Tabs = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.Parent = ContentArea
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Tabs) do p.Page.Visible = false p.Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    end)

    table.insert(Tabs, {Page = Page, Btn = TabBtn})
    return Page
end

local function CreateToggle(page, text, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    Btn.Text = "❌ " .. text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = page
    Instance.new("UICorner", Btn)
    local UIPadding = Instance.new("UIPadding", Btn)
    UIPadding.PaddingLeft = UDim.new(0, 10)

    Btn.MouseButton1Click:Connect(function()
        _G.Fikrah[flag] = not _G.Fikrah[flag]
        if _G.Fikrah[flag] then
            Btn.TextColor3 = Color3.fromRGB(80, 255, 80)
            Btn.Text = "✅ " .. text
            Btn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
        else
            Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
            Btn.Text = "❌ " .. text
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end)
end

local function CreateButton(page, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 100, 160)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = "⚡ " .. text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = page
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateInput(page, placeholder, callback)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderText = placeholder
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 13
    Box.ClearTextOnFocus = false
    Box.Parent = page
    Instance.new("UICorner", Box)
    Box.FocusLost:Connect(function()
        callback(Box.Text)
        Box.Text = ""
    end)
end

-- ======================================================= --
-- 4. PENGISIAN MENU UI
-- ======================================================= --
local TabFarm = CreateTab("💰 Farm & Gacha")
local TabUnit = CreateTab("🎒 Unit & Jual")
local TabUp = CreateTab("📈 Level & Tower")
local TabEvent = CreateTab("🎯 Event & System")

Tabs[1].Page.Visible = true -- Default Tab
Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)

-- Tab Farm & Gacha
CreateToggle(TabFarm, "Auto Collect Money (Magnet Mode)", "AutoCollect")
CreateToggle(TabFarm, "Auto Roll Dadu", "AutoRoll")
CreateToggle(TabFarm, "Auto Reroll Trait", "AutoTrait")
CreateToggle(TabFarm, "Auto Reroll Grade", "AutoGrade")

-- Tab Unit
CreateToggle(TabUnit, "Auto Equip Squad Terbaik", "AutoEquipBest")
CreateToggle(TabUnit, "Auto Lock Unit Terbaik", "AutoLock")
CreateToggle(TabUnit, "Auto Sell Sampah (Junk)", "AutoSellJunk")
CreateToggle(TabUnit, "Enable Sell By Rarity", "AutoSellByRarity")
CreateInput(TabUnit, "Ketik Rarity Sell (Contoh: Common,Rare) lalu Enter", function(txt)
    for s in string.gmatch(txt, "[^,]+") do
        local r = s:gsub("^%s+",""):gsub("%s+$","")
        if r ~= "" then table.insert(_G.Fikrah.SellRarities, r) end
    end
end)
CreateButton(TabUnit, "Bersihkan Daftar Rarity", function() _G.Fikrah.SellRarities = {} end)

-- Tab Upgrades & Tower
CreateToggle(TabUp, "Auto Upgrade Brainrot (Max)", "AutoUpgradeUnit")
CreateToggle(TabUp, "Auto Upgrade Dadu (Max)", "AutoUpgradeDice")
CreateToggle(TabUp, "Auto Rebirth", "AutoRebirth")
CreateToggle(TabUp, "Auto Join Tower Queue", "AutoTowerJoin")
CreateToggle(TabUp, "Auto Mix/Merge Unit", "AutoTowerMix")
CreateToggle(TabUp, "Auto Place Unit Tower", "AutoTowerPlace")
CreateToggle(TabUp, "Auto Attack Boss", "AutoBoss")

-- Tab Event & System
CreateToggle(TabEvent, "Auto Claim Quest (Daily/Weekly)", "AutoQuest")
CreateToggle(TabEvent, "Auto Candy Shop Event", "AutoCandy")
CreateToggle(TabEvent, "Auto Reconnect (Anti-DC)", "AutoReconnect")

CreateToggle(TabEvent, "📉 Reduce CPU / Hapus Render 3D", "ReduceCPU")
task.spawn(function()
    while task.wait(1) do
        if _G.Fikrah.ReduceCPU then
            RunService:Set3dRenderingEnabled(false)
            settings().Rendering.QualityLevel = "Level01"
            game.Lighting.GlobalShadows = false
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                    obj.Material = Enum.Material.SmoothPlastic
                elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then
                    obj:Destroy()
                end
            end
        else
            RunService:Set3dRenderingEnabled(true)
        end
    end
end)


-- ======================================================= --
-- 5. BACKGROUND LOOP (INTI LOGIKA GAME)
-- ======================================================= --

-- Anti-AFK Bawaan & Reconnect
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if _G.Fikrah.AutoReconnect and child.Name == "ErrorPrompt" then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- 1. Loop Cepat (Farm, Gacha, Reaksi Cepat)
task.spawn(function()
    while task.wait(1) do
        if _G.Fikrah.AutoCollect then
            safeFire("ClaimCash") safeFire("CollectMoney") safeFire("ClaimIncome")
            -- Magnet CFrame
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                for _, folder in pairs({Workspace:FindFirstChild("Drops"), Workspace:FindFirstChild("Bases"), Workspace}) do
                    if folder then
                        for _, obj in pairs(folder:GetChildren()) do
                            if obj:IsA("BasePart") and (obj.Name:find("Coin") or obj.Name:find("Candy") or obj.Name:find("Money")) then
                                obj.CFrame = root.CFrame
                                firetouchinterest(root, obj, 0)
                                firetouchinterest(root, obj, 1)
                            end
                        end
                    end
                end
            end
        end
        if _G.Fikrah.AutoRoll then safeFire("RollRequest") end
        if _G.Fikrah.AutoTrait then safeFire("SpinTraitRequest") end
        if _G.Fikrah.AutoGrade then safeFire("RerollGradeRequest") end
        if _G.Fikrah.AutoBoss then safeFire("BossAttack") end
    end
end)

-- 2. Loop Sedang (Manajemen, Tower, Upgrade)
task.spawn(function()
    while task.wait(3) do
        if _G.Fikrah.AutoEquipBest then safeFire("EquipBest") safeFire("EquipBestBattleSquadRequest") end
        if _G.Fikrah.AutoLock then safeFire("ToggleLockRequest") end
        if _G.Fikrah.AutoSellJunk then safeFire("SellAllJunkRequest") end
        if _G.Fikrah.AutoSellByRarity and #_G.Fikrah.SellRarities > 0 then
            for _, rarity in ipairs(_G.Fikrah.SellRarities) do safeFire("SellByRarity", rarity) end
        end
        
        if _G.Fikrah.AutoUpgradeUnit then safeFire("UpgradeBrainrotRequest", 38) end
        if _G.Fikrah.AutoUpgradeDice then safeFire("UpgradeDiceRequest", 38) end
        if _G.Fikrah.AutoRebirth then safeFire("RebirthRequest") end
        
        if _G.Fikrah.AutoTowerJoin then safeFire("JoinTowerQueue") safeFire("RequestJoinTower") end
        if _G.Fikrah.AutoTowerMix then safeFire("MixTowerRequest") safeFire("MergeTowerUnits") end
        if _G.Fikrah.AutoTowerPlace then safeFire("PlaceBrainrot") safeFire("SpawnTowerRequest") end
    end
end)

-- 3. Loop Event (Quest & CandyShop Synced)
task.spawn(function()
    while task.wait(5) do
        if _G.Fikrah.AutoQuest then
            safeFire("CollectAllQuests") safeFire("ClaimAllReward")
            if GameData.Quest and type(GameData.Quest.GetActiveDailyQuests) == "function" then
                pcall(function()
                    for id, _ in pairs(GameData.Quest.GetActiveDailyQuests()) do safeFire("ClaimQuest", id) end
                end)
            end
        end
        if _G.Fikrah.AutoCandy then
            if GameData.CandyShop and GameData.CandyShop.Start then pcall(function() GameData.CandyShop.Start() end) end
            safeFire("StartCandyEvent") safeFire("ClaimCandyRewards")
        end
    end
end)
