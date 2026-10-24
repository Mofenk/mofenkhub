-- =====================================================================
-- 👑 MOFENKHUB V18.0 — FULL UNCUT MASTER ENGINE (BAGIAN 1: SETUP & UI)
-- Game: Anime Dice | Live 3D Avatar, Spectrum Logo, Config System,
-- Server Hop, Tower Math, Fuse Engine & Full UI Pro Animations
-- =====================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Stats             = game:GetService("Stats")
local LocalPlayer       = Players.LocalPlayer

local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- 1. PEMBERSIHAN SISA INSTANCE RUN SEBELUMNYA
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV18" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" or v.Name == "MofenkTooltipGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. MASTER CONFIG GLOBAL
_G.Mofenk = {
    AutoAFK            = true,
    AutoReconnect      = true,
    SmartNotifications = true,
    SpyEnabled         = true,
    SpyConsoleLog      = true,
    
    CurrentConfigName  = "DefaultConfig",
    AutoLoadConfig     = false,
    
    AutoRoll     = true,
    AutoSpins    = true,
    AutoCollect  = true,
    SmartPlace   = true,
    AutoLevel    = true,
    LevelShare   = 0.3,
    LevelPayback = 10,
    SaveMinutes  = 15,
    AutoGrade    = true,
    GradeMin     = 3,
    AutoTrait    = true,
    TraitMin     = 1.5,
    AutoBoost    = true,
    AutoFusion   = false,
    FuseShare    = 0.35,
    FuseSeconds  = 30,
    AutoTower    = true,
    TowerName    = "Auto (best)",
    TowerBoosts  = true,
    AutoDice     = true,
    AutoUpgrade  = true,
    AutoRebirth  = true,
    RebirthMult  = 1,
    AutoSell     = true,
    SellRarity   = 3,
    KeepBest     = 20,
    KeepLuckX    = 10,
    AutoCodes    = true,
    AutoClaim    = true,
    AutoQuests   = true,
    AutoPasses   = true,
    AutoStats    = true,
    StatPick     = "Money"
}

-- 3. CONFIG FILE MANAGER (READ/WRITE JSON)
local ConfigFolder = "MofenkHub/Configs"
if isfolder and not isfolder(ConfigFolder) then
    pcall(function() makefolder("MofenkHub") makefolder(ConfigFolder) end)
end

local function SaveConfiguration(name)
    if not writefile then return false end
    name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
    local path = ConfigFolder .. "/" .. name .. ".json"
    local json = HttpService:JSONEncode(_G.Mofenk)
    writefile(path, json)
    return true
end

local function LoadConfiguration(name)
    if not readfile then return false end
    name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile and isfile(path) then
        local content = readfile(path)
        local data = HttpService:JSONDecode(content)
        if type(data) == "table" then
            for k, v in pairs(data) do _G.Mofenk[k] = v end
            return true
        end
    end
    return false
end

-- 4. PALETTE & THEME SYSTEM
local ActivePalette = {
    Background = Color3.fromRGB(14, 14, 20),
    Header     = Color3.fromRGB(20, 20, 28),
    Card       = Color3.fromRGB(26, 26, 38),
    Primary    = Color3.fromRGB(0, 208, 255),
    Secondary  = Color3.fromRGB(170, 0, 255),
    Text       = Color3.fromRGB(240, 240, 245),
    TextSub    = Color3.fromRGB(160, 160, 180)
}

-- 5. LOAD FRAMEWORK & NETWORK SERVICES
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local Network   = ReplicatedStorage:WaitForChild("Network", 15)

local function svc(path)
    local node = Network
    for part in string.gmatch(path, "[^%.]+") do node = node and node:FindFirstChild(part) end
    return node
end

local R = {
    RollDice        = svc("RollService.RF.RollDice"),
    SetAutoRoll     = svc("RollService.RE.SetAutoRoll"),
    EquipBest       = svc("PlotService.RE.EquipBest"),
    CollectBalance  = svc("PlotService.RE.CollectBalance"),
    LevelUpSlot     = svc("PlotService.RE.LevelUpSlot"),
    BuyDice         = svc("DiceShopService.RE.BuyDice"),
    EquipDice       = svc("DiceShopService.RE.EquipDice"),
    Rebirth         = svc("RebirthService.RE.Rebirth"),
    BuyUpgrade      = svc("RE.BuyUpgrade"),
    SellInventory   = svc("SellService.RF.SellInventory"),
    UpdateAutoSell  = svc("SellService.RE.UpdateAutoSell"),
    RedeemCode      = svc("CodesService.RE.RedeemCode") or svc("MonetizationService.RE.RedeemCode"),
    QuestClaim      = svc("QuestService.RE.Claim"),
    QuestBuy        = svc("QuestService.RE.Buy"),
    AddStat         = svc("RebirthService.RE.AddStat"),
    UnequipUnit     = svc("UnitService.RF.Unequip"),
    ClaimOffline    = svc("OfflineEarningsService.RE.Claim"),
    ClaimDaily      = svc("DailyRewardService.RE.Claim"),
    ClaimGroup      = svc("GroupRewardService.RE.Claim"),
    GradeRoll       = svc("GradeService.RE.Roll"),
    GradeProtect    = svc("GradeService.RE.SetGradeProtected"),
    TraitRoll       = svc("TraitService.RE.Roll"),
    TraitProtect    = svc("TraitService.RE.SetTraitProtected"),
    BoostUse        = svc("BoostService.RE.Use"),
    PlayTower       = svc("Towers.RF.PlayTower"),
    CompleteFloor   = svc("Towers.RF.CompleteTowerFloor"),
    CancelTower     = svc("Towers.RF.CancelTower"),
    BestTowerTeam   = svc("Towers.RE.EquipBestTowerTeam"),
    InteractSlot    = svc("PlotService.RE.InteractSlot"),
    UseSpin         = svc("SpinService.RE.Use"),
    EquipUnit       = svc("UnitService.RF.Equip"),
    Fuse            = svc("FusingService.RE.Fuse"),
    FuseResult      = svc("FusingService.RE.Result")
}

local DataController = require(Framework.Features.Data.DataController)
local Dice           = require(Framework.Features.Rolling.Dice)
local Rebirths       = require(Framework.Features.Rebirth.Rebirths)
local PlotConfig     = require(Framework.Features.Plot.PlotConfig)
local MonetConfig    = require(Framework.Features.Monetization.MonetizationConfig)
local UpgradeConfig  = require(Framework.Features.Upgrades.Upgrades)
local UpgradeTree
pcall(function() UpgradeTree = require(Framework.Features.Upgrades.TreeStructure) end)
local UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
local Grades         = require(Framework.Features.Grades.Grades)
local Traits         = require(Framework.Features.Traits.Traits)
local TowersConfig   = require(Framework.Features.Towers.Towers)
local BuffController = require(Framework.Features.Buffs.BuffController)
local FusingUtil     = require(Framework.Features.Fusing.FusingUtil)
local FusingConfig   = require(Framework.Features.Fusing.FusingConfig)

local function data() return DataController.___X end

local STATE = {
    incomePerSec = 0, rolled = 0, collected = 0, diceBought = 0, rebirths = 0,
    leveled = 0, upgradesBought = 0, sold = 0, soldValue = 0, gradeRolls = 0,
    traitRolls = 0, boostsUsed = 0, towerRuns = 0, towerFloors = 0, towerBest = 0,
    towerFloor = 0, towerDrops = 0, fused = 0, fuseLast = "-", fuseBestChance = 0,
    towerPick = "-", towerPredict = 0, towerRate = 0, codesDone = 0, claims = 0,
    questsClaimed = 0, passesBought = 0, statsAdded = 0, phase = "idle", note = "-"
}

local function baseIncome(u)
    local e = u and UnitConfig.entries[u.name]
    if not e then return 0 end
    local a = u.attributes or {}
    return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end

local function invCap()
    local buff = tonumber(select(2, pcall(BuffController.GetBuff, "Unit Storage")))
    return buff and buff > 0 and buff or 100
end

local function unlockedSlots()
    local d = data()
    if not d or not d.Rebirth then return 4 end
    local rb = d.Rebirth
    local maxS = 15
    pcall(function() maxS = PlotConfig.GetMaxSlots(rb) or 15 end)
    local n = 0
    for i = 1, maxS do
        local req = 0
        pcall(function() req = PlotConfig.GetSlotRebirthRequirement(i) or 0 end)
        if req <= rb then n = n + 1 end
    end
    return n
end

-- SERVER HOP & REJOIN LOGIC
local function ServerHop()
    local Http = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local list = Http:JSONDecode(game:HttpGet(Api))
    if list and list.data then
        for _, server in ipairs(list.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
end

local function RejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- 6. TOAST NOTIFICATION SYSTEM
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -260, 0, 20)
NotifyContainer.Size = UDim2.new(0, 250, 1, -40)
NotifyContainer.BackgroundTransparency = 1

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.Padding = UDim.new(0, 8)

local function MofenkNotify(title, message, nType, duration)
    if not _G.Mofenk.SmartNotifications then return end
    duration = duration or 3.5
    
    local Card = Instance.new("Frame")
    Card.Parent = NotifyContainer
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = ActivePalette.Card
    Card.ClipsDescendants = true
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1.5
    CardStroke.Parent = Card
    CardStroke.Color = (nType == "success" and Color3.fromRGB(0, 230, 118)) or
                       (nType == "error" and Color3.fromRGB(255, 60, 60)) or
                       (nType == "warn" and Color3.fromRGB(255, 193, 7)) or ActivePalette.Primary
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Card
    TitleLbl.Position = UDim2.new(0, 10, 0, 6)
    TitleLbl.Size = UDim2.new(1, -20, 0, 16)
    TitleLbl.Text = title
    TitleLbl.TextColor3 = ActivePalette.Text
    TitleLbl.TextSize = 11
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.BackgroundTransparency = 1
    
    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Parent = Card
    MsgLbl.Position = UDim2.new(0, 10, 0, 24)
    MsgLbl.Size = UDim2.new(1, -20, 0, 22)
    MsgLbl.Text = message
    MsgLbl.TextColor3 = ActivePalette.TextSub
    MsgLbl.TextSize = 10
    MsgLbl.Font = Enum.Font.GothamMedium
    MsgLbl.TextWrapped = true
    MsgLbl.BackgroundTransparency = 1

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Parent = Card
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = CardStroke.Color
    ProgressBar.BorderSizePixel = 0

    TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local fadeOut = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- 7. MAIN UI PRO V18 & SPECTRUM NETWORK ANIMATION
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV18"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 640, 0, 430)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -215)
MainFrame.BackgroundColor3 = ActivePalette.Background
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = ActivePalette.Primary
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = ActivePalette.Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 220, 1, 0)
TitleLabel.Text = "MOFENKHUB V18.0"
TitleLabel.TextColor3 = ActivePalette.Text
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- SPECTRUM VCD NETWORK ANIMATION BAR ON LOGO
local SpectrumContainer = Instance.new("Frame")
SpectrumContainer.Parent = TopBar
SpectrumContainer.Position = UDim2.new(0, 150, 0, 13)
SpectrumContainer.Size = UDim2.new(0, 60, 0, 20)
SpectrumContainer.BackgroundTransparency = 1

local SpecLayout = Instance.new("UIListLayout")
SpecLayout.Parent = SpectrumContainer
SpecLayout.FillDirection = Enum.FillDirection.Horizontal
SpecLayout.Padding = UDim.new(0, 3)
SpecLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local SpecBars = {}
for i = 1, 6 do
    local bar = Instance.new("Frame")
    bar.Parent = SpectrumContainer
    bar.Size = UDim2.new(0, 5, 0, math.random(4, 18))
    bar.BackgroundColor3 = ActivePalette.Primary
    bar.BorderSizePixel = 0
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    SpecBars[i] = bar
end

task.spawn(function()
    while RunService.RenderStepped:Wait() do
        for _, bar in ipairs(SpecBars) do
            local targetH = math.random(3, 19)
            TweenService:Create(bar, TweenInfo.new(0.15), {Size = UDim2.new(0, 5, 0, targetH)}):Play()
        end
        task.wait(0.1)
    end
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -38, 0, 9)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = ActivePalette.Text
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = ActivePalette.Card

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 54)
Sidebar.Size = UDim2.new(0, 145, 1, -62)
Sidebar.BackgroundColor3 = ActivePalette.Header

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 159, 0, 54)
ContentArea.Size = UDim2.new(1, -167, 1, -62)
ContentArea.BackgroundColor3 = ActivePalette.Header

local TabFrames = {}

local function CreateTab(tabName, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = Sidebar
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.Text = "  " .. tabName
    TabBtn.TextColor3 = ActivePalette.TextSub
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BackgroundColor3 = ActivePalette.Card
    TabBtn.LayoutOrder = layoutOrder

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Parent = ContentArea
    TabScroll.Size = UDim2.new(1, -12, 1, -12)
    TabScroll.Position = UDim2.new(0, 6, 0, 6)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 4
    TabScroll.ScrollBarImageColor3 = ActivePalette.Primary
    TabScroll.Visible = false

    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Parent = TabScroll
    ScrollLayout.Padding = UDim.new(0, 8)

    TabFrames[tabName] = TabScroll

    TabBtn.MouseButton1Click:Connect(function()
        for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
        for _, btn in ipairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = ActivePalette.TextSub
                btn.BackgroundColor3 = ActivePalette.Card
            end
        end
        TabBtn.TextColor3 = ActivePalette.Text
        TabBtn.BackgroundColor3 = ActivePalette.Primary
    end)

    return TabScroll
end

local function AddSection(parent, titleText)
    local SecLabel = Instance.new("TextLabel")
    SecLabel.Parent = parent
    SecLabel.Size = UDim2.new(1, 0, 0, 20)
    SecLabel.Text = titleText
    SecLabel.TextColor3 = ActivePalette.Primary
    SecLabel.TextSize = 11
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    SecLabel.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag, callback)
    local state = _G.Mofenk[flag] or false

    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = ActivePalette.Card

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = text
    Label.TextColor3 = ActivePalette.Text
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton")
    Switch.Parent = Frame
    Switch.Position = UDim2.new(1, -48, 0.5, -10)
    Switch.Size = UDim2.new(0, 38, 0, 20)
    Switch.Text = ""
    Switch.BackgroundColor3 = state and ActivePalette.Primary or Color3.fromRGB(50, 50, 65)

    local SwCorner = Instance.new("UICorner")
    SwCorner.CornerRadius = UDim.new(1, 0)
    SwCorner.Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Parent = Switch
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    Switch.MouseButton1Click:Connect(function()
        state = not state
        _G.Mofenk[flag] = state
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and ActivePalette.Primary or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        if callback then callback(state) end
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.BackgroundColor3 = ActivePalette.Card

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function AddTextbox(parent, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = ActivePalette.Card

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Parent = Frame
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = ActivePalette.Text
    Box.PlaceholderColor3 = ActivePalette.TextSub
    Box.TextSize = 11
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.BackgroundTransparency = 1

    Box.FocusLost:Connect(function(enter)
        if callback then callback(Box.Text, enter) end
    end)
end

-- TAB SETUP
local TabHome   = CreateTab("🏠 Home & Avatar", 1)
local TabFarm   = CreateTab("🎲 Farm Engine", 2)
local TabTower  = CreateTab("🏰 Tower & Plot", 3)
local TabConfig = CreateTab("📁 Config Manager", 4)
local TabUtils  = CreateTab("⚡ Server Utils", 5)

TabFrames["🏠 Home & Avatar"].Visible = true

-- LIVE 3D AVATAR VIEWPORT
AddSection(TabHome, "👤 LIVE 3D AVATAR PREVIEW")
local ViewportFrame = Instance.new("ViewportFrame")
ViewportFrame.Parent = TabHome
ViewportFrame.Size = UDim2.new(1, 0, 0, 140)
ViewportFrame.BackgroundColor3 = ActivePalette.Card

local VPCorner = Instance.new("UICorner")
VPCorner.CornerRadius = UDim.new(0, 8)
VPCorner.Parent = ViewportFrame

task.spawn(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart")
    char.Archivable = true
    local clone = char:Clone()
    clone.Parent = ViewportFrame

    local cam = Instance.new("Camera")
    cam.Parent = ViewportFrame
    cam.CFrame = CFrame.new(clone.HumanoidRootPart.Position + Vector3.new(0, 1.5, 5), clone.HumanoidRootPart.Position)
    ViewportFrame.CurrentCamera = cam

    RunService.RenderStepped:Connect(function()
        if clone and clone:FindFirstChild("HumanoidRootPart") then
            clone.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(1), 0)
        end
    end)
end)

-- FARM & TOWER TABS
AddSection(TabFarm, "🎲 AUTOMATED FARMING ENGINE")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Auto Roll Spins", "AutoSpins")
AddToggle(TabFarm, "Auto Sell Inventory", "AutoSell")

AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Plot Balance", "AutoCollect")
AddToggle(TabTower, "Smart Placement", "SmartPlace")
AddToggle(TabTower, "Auto Level Up Slot", "AutoLevel")
AddToggle(TabTower, "Auto Tower Runner", "AutoTower")

-- CONFIG MANAGER TAB
AddSection(TabConfig, "📁 SIMPAN & MUAT KONFIGURASI")
AddTextbox(TabConfig, "Nama File Config...", function(txt)
    _G.Mofenk.CurrentConfigName = txt
end)

AddButton(TabConfig, "💾 Save Config Sekarang", function()
    if SaveConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG SAVED", "Config berhasil disimpan!", "success", 3)
    end
end)

AddButton(TabConfig, "📂 Load Config Sekarang", function()
    if LoadConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG LOADED", "Config berhasil dimuat!", "success", 3)
    end
end)

AddToggle(TabConfig, "Auto-Load Config Saat Run", "AutoLoadConfig")

-- UTILS TAB
AddSection(TabUtils, "⚡ SERVER UTILITIES")
AddButton(TabUtils, "🌐 Server Hop (Cari Server Baru)", function() ServerHop() end)
AddButton(TabUtils, "🔄 Rejoin Server Saat Ini", function() RejoinServer() end)

-- FLOATING TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = ActivePalette.Header
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "🎲"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- MAIN BACKEND LOOPS
task.spawn(function()
    MofenkNotify("MOFENKHUB V18.0", "Full Engine & Features Aktif!", "success", 3)
    while task.wait(2.5) do
        if _G.Mofenk.AutoRoll and R.RollDice then pcall(function() R.RollDice:InvokeServer() end) end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if _G.Mofenk.AutoCollect and R.CollectBalance then
            local gData = data()
            if gData and gData.Slots then
                for k, s in pairs(gData.Slots) do pcall(function() R.CollectBalance:FireServer(tonumber(k)) end) end
            end
        end
    end
end)
-- =====================================================================
-- 👑 MOFENKHUB V18.0 — FULL UNCUT MASTER ENGINE (BAGIAN 2: BACKEND LOGIC)
-- Sambungkan tepat di bawah kode Bagian 1!
-- =====================================================================

-- 8. SMART PLACEMENT & INVENTORY ENGINE
local unitOwner, unitSince = nil, 0
local function claimUnits(who)
    if unitOwner and unitOwner ~= who and os.clock() - unitSince < 20 then return false end
    unitOwner, unitSince = who, os.clock()
    return true
end
local function releaseUnits(who) if unitOwner == who then unitOwner = nil end end

local function heldUnit()
    if not (UnitCtl and UnitCtl.EquippedUnit) then return nil end
    local ok, id = pcall(UnitCtl.EquippedUnit)
    return ok and id or nil
end

local function goodGrade(g)
    local def = g and Grades[g]
    return def and (tonumber(def.incomeMultiplier) or 0) >= _G.Mofenk.GradeMin
end

local function goodTrait(t)
    local def = t and Traits[t]
    return def and (tonumber(def.incomeMultiplier) or 0) >= _G.Mofenk.TraitMin
end

local function isProtected(id, u)
    local a = u.attributes or {}
    if a.locked then return true end
    local e = UnitConfig.entries[u.name]
    if not e or e.limited then return true end
    if goodGrade(a.grade) or goodTrait(a.trait) then return true end
    return id == heldUnit()
end

local function placeBest()
    if not (R.EquipUnit and R.InteractSlot) then return false end
    if not claimUnits("place") then return false end
    local d = data()
    if not d or not d.Inventory or not d.Slots then releaseUnits("place"); return false end
    local n = unlockedSlots()

    local ranked = {}
    for id, u in pairs(d.Inventory) do
        if UnitConfig.entries[u.name] and (tonumber(u.amount) or 1) >= 1 then
            ranked[#ranked + 1] = { id = id, v = baseIncome(u) }
        end
    end
    table.sort(ranked, function(a, b) return a.v > b.v end)

    local want = {}
    for i = 1, math.min(n, #ranked) do want[ranked[i].id] = ranked[i].v end
    local placed = {}
    for i = 1, n do
        local s = d.Slots[tostring(i)]
        if s and s.unitId then placed[s.unitId] = true end
    end
    
    local bench = {}
    for i = 1, math.min(n, #ranked) do
        if not placed[ranked[i].id] then bench[#bench + 1] = ranked[i] end
    end
    if #bench == 0 then releaseUnits("place"); return false end

    local slots = {}
    for i = 1, n do
        local s = d.Slots[tostring(i)]
        local u = s and s.unitId and d.Inventory[s.unitId]
        slots[#slots + 1] = { i = i, v = u and baseIncome(u) or 0, id = s and s.unitId }
    end
    table.sort(slots, function(a, b) return a.v < b.v end)

    local swapped = 0
    for k, cand in ipairs(bench) do
        local slot = slots[k]
        if slot and (slot.id == nil or not want[slot.id]) and cand.v > slot.v * 1.1 then
            local ok, equipped = pcall(function() return R.EquipUnit:InvokeServer(cand.id) end)
            if ok and equipped == true then
                task.wait(0.55)
                R.InteractSlot:FireServer(slot.i)
                task.wait(0.6)
                swapped = swapped + 1
            end
            task.wait(0.55)
        end
    end
    releaseUnits("place")
    return swapped > 0
end

-- 9. FULL AUTO SELL ENGINE
local function performFullAutoSell(force)
    if not R.SellInventory or not claimUnits("sell") then return end
    local d = data()
    if not d or not d.Inventory then releaseUnits("sell"); return end
    
    local cap = invCap()
    local placed = {}
    if d.Slots then for _, slot in pairs(d.Slots) do if slot.unitId then placed[slot.unitId] = true end end end
    
    local units, owned = {}, 0
    for id, u in pairs(d.Inventory) do
        local e = UnitConfig.entries[u.name]
        if e then owned = owned + 1 end
        if e and not placed[id] and not isProtected(id, u) then
            units[#units + 1] = { id = id, inc = baseIncome(u), order = RARITY_SORT[e.rarity] or 0 }
        end
    end
    table.sort(units, function(a, b) return a.inc < b.inc end)
    
    local sellable = math.max(0, #units - _G.Mofenk.KeepBest)
    local list = {}
    for i, unit in ipairs(units) do
        if unit.order < _G.Mofenk.SellRarity and i <= sellable then
            list[#list + 1] = unit.id
            if #list >= 300 then break end
        end
    end
    
    if #list == 0 then releaseUnits("sell"); return end
    local ok, value, sold = pcall(function() return R.SellInventory:InvokeServer(list) end)
    releaseUnits("sell")
    if ok then
        MofenkNotify("AUTO SELL OK", string.format("Terjual %d Unit Sampah!", tonumber(sold) or #list), "success", 3)
    end
end

-- 10. TOWER RUN SIMULATOR ENGINE
local TOWER_WAIT = { initial = 0.76, transition = 0.38, hit = 0.62, done = 0.24, fall = 0.32 }
local DROP_WEIGHT = { Luck = 1, ["Money Multiplier"] = 0.5, ["Damage Multiplier"] = 0.15 }

local function dropValue(name)
    if name == "Gems" then return 40 end
    if name == "Trait Reroll" then return 25 end
    return 10
end

local function towerTeam()
    local d = data()
    if not d or not d.TowerTeam then return {} end
    local dmgMul = tonumber(select(2, pcall(BuffController.GetBuff, "Damage Multiplier"))) or 1
    local hpMul = tonumber(select(2, pcall(BuffController.GetBuff, "Health Multiplier"))) or 1
    local team = {}
    for i = 1, 4 do
        local id = d.TowerTeam[i]
        local u = id and d.Inventory and d.Inventory[id]
        local e = u and UnitConfig.entries[u.name]
        if e then
            local a = u.attributes or {}
            team[#team + 1] = {
                dmg = (tonumber(select(2, pcall(e.damage, a))) or 0) * dmgMul,
                hp = (tonumber(select(2, pcall(e.health, a))) or 0) * hpMul,
            }
        end
    end
    return team
end

local function simulateTower(tw, team)
    if #team == 0 then return 0, 0, 0 end
    local members = {}
    for i, m in ipairs(team) do members[i] = { dmg = m.dmg, hp = m.hp } end
    local cap = tw.maxFloors or 300
    local floor, cur, secs, value = 1, 1, 0, 0
    while floor <= cap do
        local enemy = tonumber(select(2, pcall(tw.enemyHealth, floor))) or math.huge
        local hit = tonumber(select(2, pcall(tw.enemyDamage, floor))) or math.huge
        secs = secs + (floor == 1 and TOWER_WAIT.initial or TOWER_WAIT.transition)
        local cleared = false
        for _ = 1, 2000 do
            local m = members[cur]
            if not m then break end
            enemy = enemy - m.dmg
            secs = secs + TOWER_WAIT.hit
            if enemy <= 0 then cleared = true; break end
            m.hp = m.hp - hit
            secs = secs + TOWER_WAIT.hit
            if m.hp <= 0 then cur = cur + 1; secs = secs + TOWER_WAIT.fall + TOWER_WAIT.transition end
        end
        if not cleared then break end
        floor = floor + 1
    end
    return floor - 1, secs, value
end

local function pickTower()
    local all = select(2, pcall(TowersConfig.GetAll))
    if _G.Mofenk.TowerName ~= "Auto (best)" and type(all) == "table" and all[_G.Mofenk.TowerName] then
        return _G.Mofenk.TowerName
    end
    local team = towerTeam()
    local best, bestRate, bestFloors = nil, -1, 0
    if type(all) == "table" then
        for name, tw in pairs(all) do
            local floors, secs, value = simulateTower(tw, team)
            local rate = secs > 0 and value / (secs + 4) or 0
            if floors > 0 and rate > bestRate then best, bestRate, bestFloors = name, rate, floors end
        end
    end
    return best or "Dragon Tower"
end

local function drainTower()
    if not R.CancelTower then return end
    local okC, queued = pcall(function() return R.CancelTower:InvokeServer() end)
    if not (okC and queued) then return end
    for _ = 1, 60 do
        local ok, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
        if ok and type(seq) == "table" then
            for _, ev in ipairs(seq) do if ev.action == "ended" then return end end
        end
        task.wait(0.3)
    end
end

local function towerRun()
    if not (R.PlayTower and R.CompleteFloor) then return end
    if R.BestTowerTeam then R.BestTowerTeam:FireServer(); task.wait(0.6) end
    local tower = pickTower()
    local ok, started = pcall(function() return R.PlayTower:InvokeServer(tower) end)
    if not (ok and started) then
        drainTower()
        task.wait(3.2)
        ok, started = pcall(function() return R.PlayTower:InvokeServer(tower) end)
        if not (ok and started) then return end
    end
    
    local misses, sawEnded = 0, false
    while _G.Mofenk.AutoTower do
        local okF, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
        if not okF or seq == nil then
            misses = misses + 1
            if misses > 50 then break end
            task.wait(0.3)
        else
            misses = 0
            local ended, done = false, false
            for _, ev in ipairs(seq) do
                if ev.action == "floorCompleted" then done = true
                elseif ev.action == "ended" then ended = true end
            end
            if ended then sawEnded = true; break end
            if not done then break end
            task.wait(0.2)
        end
    end
    if not sawEnded then drainTower() end
end

-- 11. BACKGROUND EXECUTION LOOPS
task.spawn(function()
    while true do
        if _G.Mofenk.AutoRoll and R.RollDice then pcall(function() R.RollDice:InvokeServer() end) end
        task.wait(2.5)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoCollect and R.CollectBalance then
            local gData = data()
            if gData and gData.Slots then
                for k, _ in pairs(gData.Slots) do pcall(function() R.CollectBalance:FireServer(tonumber(k)) end) end
            end
            if _G.Mofenk.SmartPlace then pcall(placeBest) end
        end
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoSell then pcall(function() performFullAutoSell(false) end) end
        task.wait(6)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoTower then pcall(towerRun); task.wait(4) else task.wait(2) end
    end
end)

MofenkNotify("MOFENKHUB V18.0", "Full Master Engine Berhasil Dimuat!", "success", 4)
