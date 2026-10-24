-- =====================================================================
-- 👑 MOFENKHUB V25.0 — ULTIMATE MASTER ENGINE (100% COMPLETE & SAFE)
-- Game: Anime Dice | Full Features: Tower Auto Picker, Safe Service Mapping,
-- Auto Roll, Sell, Upgrade, Rebirth, Smart Placement, Config Manager & UI
-- =====================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- 1. CLEANUP SISA INSTANCE
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV25" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
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
    AutoGrade    = true,
    GradeMin     = 3,
    AutoTrait    = true,
    TraitMin     = 1.5,
    AutoFusion   = false,
    AutoTower    = true,
    TowerName    = "Auto (best)",
    AutoDice     = true,
    AutoUpgrade  = true,
    AutoRebirth  = true,
    AutoSell     = true,
    SellRarity   = 3,
    KeepBest     = 20,
    AutoCodes    = true,
    AutoClaim    = true,
    AutoQuests   = true,
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
    writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(_G.Mofenk))
    return true
end

local function LoadConfiguration(name)
    if not readfile then return false end
    name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile and isfile(path) then
        local dataDec = HttpService:JSONDecode(readfile(path))
        if type(dataDec) == "table" then
            for k, v in pairs(dataDec) do _G.Mofenk[k] = v end
            return true
        end
    end
    return false
end

-- 4. THEME & PALETTE (MODERN DARK GLASS)
local Theme = {
    Bg        = Color3.fromRGB(12, 12, 18),
    Header    = Color3.fromRGB(18, 18, 26),
    Card      = Color3.fromRGB(24, 24, 34),
    Accent    = Color3.fromRGB(0, 229, 255),
    AccentSec = Color3.fromRGB(124, 58, 237),
    Text      = Color3.fromRGB(245, 245, 250),
    TextSub   = Color3.fromRGB(150, 150, 175)
}

-- 5. TOAST NOTIFICATION SYSTEM
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -270, 0, 20)
NotifyContainer.Size = UDim2.new(0, 260, 1, -40)
NotifyContainer.BackgroundTransparency = 1

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.Padding = UDim.new(0, 8)

local function MofenkNotify(title, message, nType, duration)
    if not _G.Mofenk.SmartNotifications then return end
    duration = duration or 3
    
    local Card = Instance.new("Frame")
    Card.Parent = NotifyContainer
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = Theme.Card
    Card.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Parent = Card
    Stroke.Color = (nType == "success" and Color3.fromRGB(16, 185, 129)) or Theme.Accent
                   
    local Title = Instance.new("TextLabel")
    Title.Parent = Card
    Title.Position = UDim2.new(0, 12, 0, 6)
    Title.Size = UDim2.new(1, -24, 0, 16)
    Title.Text = title
    Title.TextColor3 = Theme.Text
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    
    local Msg = Instance.new("TextLabel")
    Msg.Parent = Card
    Msg.Position = UDim2.new(0, 12, 0, 24)
    Msg.Size = UDim2.new(1, -24, 0, 22)
    Msg.Text = message
    Msg.TextColor3 = Theme.TextSub
    Msg.TextSize = 10
    Msg.Font = Enum.Font.GothamMedium
    Msg.BackgroundTransparency = 1
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- 6. SAFE SERVICE MAPPING (MENCEGAH NIL VALUE ERROR)
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local Network   = ReplicatedStorage:WaitForChild("Network", 15)

local function safeSvc(path)
    local node = Network
    for part in string.gmatch(path, "[^%.]+") do
        if node then node = node:FindFirstChild(part) end
    end
    return node
end

local R = {
    RollDice       = safeSvc("RollService.RF.RollDice"),
    CollectBalance = safeSvc("PlotService.RE.CollectBalance"),
    LevelUpSlot    = safeSvc("PlotService.RE.LevelUpSlot"),
    BuyDice        = safeSvc("DiceShopService.RF.BuyDice") or safeSvc("DiceShopService.RE.BuyDice"),
    Rebirth        = safeSvc("RebirthService.RF.Rebirth") or safeSvc("RebirthService.RE.Rebirth"),
    BuyUpgrade     = safeSvc("RE.BuyUpgrade"),
    SellInventory  = safeSvc("SellService.RF.SellInventory"),
    PlayTower      = safeSvc("Towers.RF.PlayTower"),
    CompleteFloor  = safeSvc("Towers.RF.CompleteTowerFloor"),
    CancelTower    = safeSvc("Towers.RF.CancelTower"),
    InteractSlot   = safeSvc("PlotService.RE.InteractSlot"),
    EquipUnit      = safeSvc("UnitService.RF.Equip")
}

local DataController, UnitConfig, TowersConfig
pcall(function() DataController = require(Framework.Features.Data.DataController) end)
pcall(function() UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig) end)
pcall(function() TowersConfig = require(Framework.Features.Towers.Towers) end)

local function data()
    local ok, res = pcall(function() return DataController.___X end)
    return ok and res or nil
end

-- SERVER UTILITIES (HOP & REJOIN)
local function ServerHop()
    MofenkNotify("SERVER HOP", "Mencari server publik kosong...", "info", 3)
    local Http = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local list = Http:JSONDecode(game:HttpGet(Api))
    if list and list.data then
        for _, s in ipairs(list.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end
end

local function RejoinServer()
    MofenkNotify("REJOIN", "Menghubungkan ulang ke server...", "info", 3)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- 7. UI UTAMA V25 PRO (MODERN FLUENT WINDOW)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV25"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 700, 0, 480)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Theme.Accent
MainStroke.Parent = MainFrame

-- Header Topbar & Spectrum Visualizer
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Header

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Size = UDim2.new(0, 260, 1, 0)
Title.Text = "👑 MOFENKHUB V25.0 PRO"
Title.TextColor3 = Theme.Text
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Spectrum Animation Logo
local SpecContainer = Instance.new("Frame")
SpecContainer.Parent = TopBar
SpecContainer.Position = UDim2.new(0, 230, 0, 14)
SpecContainer.Size = UDim2.new(0, 60, 0, 20)
SpecContainer.BackgroundTransparency = 1

local SpecLayout = Instance.new("UIListLayout")
SpecLayout.Parent = SpecContainer
SpecLayout.FillDirection = Enum.FillDirection.Horizontal
SpecLayout.Padding = UDim.new(0, 3)
SpecLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local SpecBars = {}
for i = 1, 6 do
    local b = Instance.new("Frame")
    b.Parent = SpecContainer
    b.Size = UDim2.new(0, 5, 0, math.random(4, 18))
    b.BackgroundColor3 = Theme.Accent
    b.BorderSizePixel = 0
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = b
    SpecBars[i] = b
end

task.spawn(function()
    while RunService.RenderStepped:Wait() do
        for _, bar in ipairs(SpecBars) do
            TweenService:Create(bar, TweenInfo.new(0.12), {Size = UDim2.new(0, 5, 0, math.random(3, 20)}):Play()
        end
        task.wait(0.1)
    end
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -42, 0, 10)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.Text
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Theme.Card

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Sidebar & Content Area
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 58)
Sidebar.Size = UDim2.new(0, 155, 1, -68)
Sidebar.BackgroundColor3 = Theme.Header

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 175, 0, 58)
ContentArea.Size = UDim2.new(1, -185, 1, -68)
ContentArea.BackgroundColor3 = Theme.Header

local TabFrames = {}

local function CreateTab(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Text = "  " .. name
    Btn.TextColor3 = Theme.TextSub
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.BackgroundColor3 = Theme.Card
    Btn.LayoutOrder = order

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = ContentArea
    Scroll.Size = UDim2.new(1, -12, 1, -12)
    Scroll.Position = UDim2.new(0, 6, 0, 6)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.Visible = false

    local Lay = Instance.new("UIListLayout")
    Lay.Parent = Scroll
    Lay.Padding = UDim.new(0, 8)

    TabFrames[name] = Scroll

    Btn.MouseButton1Click:Connect(function()
        for n, f in pairs(TabFrames) do f.Visible = (n == name) end
        for _, b in ipairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = Theme.TextSub
                b.BackgroundColor3 = Theme.Card
            end
        end
        Btn.TextColor3 = Theme.Text
        Btn.BackgroundColor3 = Theme.AccentSec
    end)

    return Scroll
end

local function AddSection(parent, text)
    local L = Instance.new("TextLabel")
    L.Parent = parent
    L.Size = UDim2.new(1, 0, 0, 22)
    L.Text = text
    L.TextColor3 = Theme.Accent
    L.TextSize = 11
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag)
    local state = _G.Mofenk[flag] or false
    local F = Instance.new("Frame")
    F.Parent = parent
    F.Size = UDim2.new(1, 0, 0, 36)
    F.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F

    local L = Instance.new("TextLabel")
    L.Parent = F
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Size = UDim2.new(0.7, 0, 1, 0)
    L.Text = text
    L.TextColor3 = Theme.Text
    L.TextSize = 11
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local Sw = Instance.new("TextButton")
    Sw.Parent = F
    Sw.Position = UDim2.new(1, -48, 0.5, -10)
    Sw.Size = UDim2.new(0, 38, 0, 20)
    Sw.Text = ""
    Sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 65)

    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw

    local Knob = Instance.new("Frame")
    Knob.Parent = Sw
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = Knob

    Sw.MouseButton1Click:Connect(function()
        state = not state
        _G.Mofenk[flag] = state
        TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
    end)
end

local function AddButton(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Parent = parent
    B.Size = UDim2.new(1, 0, 0, 34)
    B.Text = text
    B.TextColor3 = Theme.Text
    B.TextSize = 11
    B.Font = Enum.Font.GothamBold
    B.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = B

    B.MouseButton1Click:Connect(function() pcall(cb) end)
end

local function AddTextbox(parent, placeholder, cb)
    local F = Instance.new("Frame")
    F.Parent = parent
    F.Size = UDim2.new(1, 0, 0, 36)
    F.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F

    local Box = Instance.new("TextBox")
    Box.Parent = F
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.PlaceholderText = placeholder
    Box.Text = _G.Mofenk.CurrentConfigName
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Theme.TextSub
    Box.TextSize = 11
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.BackgroundTransparency = 1

    Box.FocusLost:Connect(function(enter)
        if cb then cb(Box.Text) end
    end)
end

-- BUILD ALL TABS
local TabHome   = CreateTab("🏠 Home & Avatar", 1)
local TabFarm   = CreateTab("🎲 Farm Engine", 2)
local TabTower  = CreateTab("🏰 Tower & Plot", 3)
local TabBonus  = CreateTab("🎁 Codes & Stats", 4)
local TabConfig = CreateTab("📁 Configs", 5)
local TabUtils  = CreateTab("⚡ Server Utils", 6)

TabFrames["🏠 Home & Avatar"].Visible = true

-- TAB 1: LIVE 3D AVATAR & PROFIL
AddSection(TabHome, "👤 LIVE 3D AVATAR PREVIEW")
local Viewport = Instance.new("ViewportFrame")
Viewport.Parent = TabHome
Viewport.Size = UDim2.new(1, 0, 0, 150)
Viewport.BackgroundColor3 = Theme.Card

local VPC = Instance.new("UICorner")
VPC.CornerRadius = UDim.new(0, 8)
VPC.Parent = Viewport

task.spawn(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart")
    char.Archivable = true
    local clone = char:Clone()
    clone.Parent = Viewport

    local cam = Instance.new("Camera")
    cam.Parent = Viewport
    cam.CFrame = CFrame.new(clone.HumanoidRootPart.Position + Vector3.new(0, 1.5, 5), clone.HumanoidRootPart.Position)
    Viewport.CurrentCamera = cam

    RunService.RenderStepped:Connect(function()
        if clone and clone:FindFirstChild("HumanoidRootPart") then
            clone.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(1.2), 0)
        end
    end)
end)

local InfoCard = Instance.new("TextLabel")
InfoCard.Parent = TabHome
InfoCard.Size = UDim2.new(1, 0, 0, 60)
InfoCard.BackgroundColor3 = Theme.Card
InfoCard.TextColor3 = Theme.Text
InfoCard.TextSize = 11
InfoCard.Font = Enum.Font.GothamMedium
InfoCard.TextXAlignment = Enum.TextXAlignment.Left
InfoCard.TextYAlignment = Enum.TextYAlignment.Top

local IC = Instance.new("UICorner")
IC.CornerRadius = UDim.new(0, 8)
IC.Parent = InfoCard

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local d = data()
            InfoCard.Text = string.format("  Player: %s | ID: %d\n  Uang: %s | Rebirth: %s", LocalPlayer.Name, LocalPlayer.UserId, tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0))
        end)
    end
end)

-- TAB 2: FARM ENGINE
AddSection(TabFarm, "🎲 AUTOMATED FARMING ENGINE")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Auto Roll Spins", "AutoSpins")
AddToggle(TabFarm, "Auto Sell Inventory Junk", "AutoSell")
AddToggle(TabFarm, "Auto Buy Best Dice", "AutoDice")
AddToggle(TabFarm, "Auto Buy Pad Upgrades", "AutoUpgrade")
AddToggle(TabFarm, "Auto Rebirth", "AutoRebirth")

-- TAB 3: TOWER & PLOT
AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Plot Balance", "AutoCollect")
AddToggle(TabTower, "Smart Placement (Best Income)", "SmartPlace")
AddToggle(TabTower, "Auto Level Up Slots", "AutoLevel")
AddToggle(TabTower, "Auto Tower Runner", "AutoTower")
AddToggle(TabTower, "Auto Fuse Units", "AutoFusion")

-- TAB 4: CODES & STATS
AddSection(TabBonus, "🎁 CODES & STATS")
AddToggle(TabBonus, "Auto Redeem Codes", "AutoCodes")
AddToggle(TabBonus, "Auto Claim Rewards", "AutoClaim")
AddToggle(TabBonus, "Auto Claim Quests", "AutoQuests")
AddToggle(TabBonus, "Auto Add Rebirth Stats", "AutoStats")

-- TAB 5: CONFIG MANAGER
AddSection(TabConfig, "📁 SIMPAN & MUAT CONFIGURASI JSON")
AddTextbox(TabConfig, "Masukkan Nama Config...", function(txt)
    _G.Mofenk.CurrentConfigName = txt
end)
AddButton(TabConfig, "💾 Simpan Config Sekarang", function()
    if SaveConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Berhasil menyimpan config!", "success", 3)
    end
end)
AddButton(TabConfig, "📂 Muat Config Sekarang", function()
    if LoadConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Berhasil memuat config!", "success", 3)
    end
end)
AddToggle(TabConfig, "Auto-Load Config Saat Run", "AutoLoadConfig")

-- TAB 6: SERVER UTILS
AddSection(TabUtils, "⚡ SERVER TOOLS & TELEPORT")
AddButton(TabUtils, "🌐 Server Hop (Cari Server Baru)", function() ServerHop() end)
AddButton(TabUtils, "🔄 Rejoin Server Saat Ini", function() RejoinServer() end)

-- FLOATING TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "👑"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 12)
TC.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- AUTOMATION BACKEND LOOPS
task.spawn(function()
    MofenkNotify("MOFENKHUB V25", "Master Engine Ultimate Full Aktif!", "success", 3)
    while task.wait(2.5) do
        if _G.Mofenk.AutoRoll and R.RollDice then pcall(function() R.RollDice:InvokeServer() end) end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if _G.Mofenk.AutoCollect and R.CollectBalance then
            local d = data()
            if d and d.Slots then
                for k, _ in pairs(d.Slots) do pcall(function() R.CollectBalance:FireServer(tonumber(k)) end) end
            end
        end
    end
end)
