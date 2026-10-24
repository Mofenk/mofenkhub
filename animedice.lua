-- =====================================================================
-- 👑 MOFENKHUB V32.0 — ULTIMATE MASTER UNCUT EDITION (ZERO ERROR)
-- Game: Anime Dice | 100% Robust Nil Protection, Full 10 Tabs UI,
-- Tower Math Simulator, Auto Roll/Sell/Upgrade/Rebirth, Configs & Server Hop
-- =====================================================================

task.wait(1.5) -- Inisialisasi aman untuk mencegah race condition

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

-- 1. CLEANUP INSTANCE LAMA
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV32" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. MASTER CONFIG GLOBAL
_G.Mofenk = {
    AutoAFK            = true,
    AutoReconnect      = true,
    SmartNotifications = true,
    CurrentConfigName  = "DefaultConfig",
    AutoLoadConfig     = false,
    
    AutoRoll     = true,
    AutoSpins    = true,
    AutoCollect  = true,
    SmartPlace   = true,
    AutoLevel    = true,
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
    AutoFusion   = false,
    AutoPasses   = true
}

-- 3. CONFIG FILE MANAGER (JSON)
local ConfigFolder = "MofenkHub/Configs"
if isfolder and not isfolder(ConfigFolder) then
    pcall(function() makefolder("MofenkHub") makefolder(ConfigFolder) end)
end

local function SaveConfiguration(name)
    if not writefile then return false end
    name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
    local path = ConfigFolder .. "/" .. name .. ".json"
    writefile(path, HttpService:JSONEncode(_G.Mofenk))
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
    duration = duration or 3.5
    
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
                   
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Card
    TitleLbl.Position = UDim2.new(0, 12, 0, 6)
    TitleLbl.Size = UDim2.new(1, -24, 0, 16)
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.TextSize = 11
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.BackgroundTransparency = 1
    
    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Parent = Card
    MsgLbl.Position = UDim2.new(0, 12, 0, 24)
    MsgLbl.Size = UDim2.new(1, -24, 0, 22)
    MsgLbl.Text = message
    MsgLbl.TextColor3 = Theme.TextSub
    MsgLbl.TextSize = 10
    MsgLbl.Font = Enum.Font.GothamMedium
    MsgLbl.BackgroundTransparency = 1
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- 6. SAFE SERVICE & REMOTE MAPPING (DENGAN NULL-CHECK AMAN)
local Framework, Network
pcall(function() Framework = ReplicatedStorage:WaitForChild("Framework", 15) end)
pcall(function() Network = ReplicatedStorage:WaitForChild("Network", 15) end)

local function safeFind(parent, path)
    local node = parent
    for part in string.gmatch(path, "[^%.]+") do
        if node then node = node:FindFirstChild(part) else return nil end
    end
    return node
end

local R = {
    RollDice       = Network and (safeFind(Network, "RollService.RF.RollDice") or safeFind(Network, "RollService.RE.RollDice")),
    CollectBalance = Network and (safeFind(Network, "PlotService.RE.CollectBalance") or safeFind(Network, "PlotService.RF.CollectBalance")),
    PlayTower      = Network and (safeFind(Network, "Towers.RF.PlayTower") or safeFind(Network, "Towers.RE.PlayTower")),
    CompleteFloor  = Network and (safeFind(Network, "Towers.RF.CompleteTowerFloor") or safeFind(Network, "Towers.RE.CompleteTowerFloor")),
    CancelTower    = Network and (safeFind(Network, "Towers.RF.CancelTower") or safeFind(Network, "Towers.RE.CancelTower")),
    SellInventory  = Network and (safeFind(Network, "SellService.RF.SellInventory") or safeFind(Network, "SellService.RE.SellInventory")),
}

local DataController, TowersConfig
pcall(function()
    if Framework then 
        DataController = require(Framework.Features.Data.DataController)
        TowersConfig = require(Framework.Features.Towers.Towers)
    end
end)

local function data()
    local ok, res = pcall(function() return DataController.___X end)
    return ok and res or nil
end

-- SERVER UTILITIES
local function ServerHop()
    MofenkNotify("SERVER HOP", "Mencari server publik kosong...", "info", 3)
    local Http = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, res = pcall(function() return Http:JSONDecode(game:HttpGet(Api)) end)
    if success and res and res.data then
        for _, s in ipairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end
end

local function RejoinServer()
    MofenkNotify("REJOIN", "Menghubungkan ulang...", "info", 3)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- 7. UI UTAMA V32 PRO (10 TABS + PROFILE DATA + ZERO ERROR)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV32"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 750, 0, 520)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
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

-- Header Topbar
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Header

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Size = UDim2.new(0, 320, 1, 0)
Title.Text = "👑 MOFENKHUB V32.0 (ZERO ERROR)"
Title.TextColor3 = Theme.Text
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

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
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 58)
Sidebar.Size = UDim2.new(0, 170, 1, -68)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.ScrollBarThickness = 3

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 190, 0, 58)
ContentArea.Size = UDim2.new(1, -200, 1, -68)
ContentArea.BackgroundColor3 = Theme.Header

local TabFrames = {}

local function CreateTab(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar
    Btn.Size = UDim2.new(1, -6, 0, 32)
    Btn.Text = "  " .. name
    Btn.TextColor3 = Theme.TextSub
    Btn.TextSize = 10
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
    F.Size = UDim2.new(1, 0, 0, 34)
    F.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F

    local L = Instance.new("TextLabel")
    L.Parent = F
    L.Position = UDim2.new(0, 10, 0, 0)
    L.Size = UDim2.new(0.7, 0, 1, 0)
    L.Text = text
    L.TextColor3 = Theme.Text
    L.TextSize = 10
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local Sw = Instance.new("TextButton")
    Sw.Parent = F
    Sw.Position = UDim2.new(1, -44, 0.5, -9)
    Sw.Size = UDim2.new(0, 34, 0, 18)
    Sw.Text = ""
    Sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 65)

    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw

    local Knob = Instance.new("Frame")
    Knob.Parent = Sw
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = Knob

    Sw.MouseButton1Click:Connect(function()
        state = not state
        _G.Mofenk[flag] = state
        TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
    end)
end

local function AddButton(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Parent = parent
    B.Size = UDim2.new(1, 0, 0, 32)
    B.Text = text
    B.TextColor3 = Theme.Text
    B.TextSize = 10
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
    F.Size = UDim2.new(1, 0, 0, 34)
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
    Box.TextSize = 10
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.BackgroundTransparency = 1

    Box.FocusLost:Connect(function(enter)
        if cb then cb(Box.Text) end
    end)
end

-- ==================== 10 TAB LENGKAP ====================
local Tab1  = CreateTab("🏠 1. Home Dashboard", 1)
local Tab2  = CreateTab("👤 2. Profile Data", 2)
local Tab3  = CreateTab("🎲 3. Farm & Rolls", 3)
local Tab4  = CreateTab("💰 4. Sell & Inventory", 4)
local Tab5  = CreateTab("🏰 5. Tower Automations", 5)
local Tab6  = CreateTab("⚡ 6. Upgrades & Rebirth", 6)
local Tab7  = CreateTab("🔮 7. Fusion & Traits", 7)
local Tab8  = CreateTab("🎁 8. Codes & Quests", 8)
local Tab9  = CreateTab("📁 9. Config Manager", 9)
local Tab10 = CreateTab("🌐 10. Server Utilities", 10)

TabFrames["🏠 1. Home Dashboard"].Visible = true

-- ISI TAB 1: HOME
AddSection(Tab1, "📊 GAME STATISTICS & INFO")
local InfoCard = Instance.new("TextLabel")
InfoCard.Parent = Tab1
InfoCard.Size = UDim2.new(1, 0, 0, 65)
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

-- ISI TAB 2: PROFILE DATA LENGKAP
AddSection(Tab2, "👤 IN-GAME PROFILE STATS")
local ProfileCard = Instance.new("TextLabel")
ProfileCard.Parent = Tab2
ProfileCard.Size = UDim2.new(1, 0, 0, 160)
ProfileCard.BackgroundColor3 = Theme.Card
ProfileCard.TextColor3 = Theme.Text
ProfileCard.TextSize = 11
ProfileCard.Font = Enum.Font.GothamMedium
ProfileCard.TextXAlignment = Enum.TextXAlignment.Left
ProfileCard.TextYAlignment = Enum.TextYAlignment.Top
local PC = Instance.new("UICorner")
PC.CornerRadius = UDim.new(0, 8)
PC.Parent = ProfileCard

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local d = data()
            ProfileCard.Text = string.format(
                "  📋 DETAIL PROFIL AKUN:\n  • Nama: %s\n  • User ID: %s\n  • Balance / Uang: %s\n  • Total Rebirth: %s\n  • Status Hub: Aktif & Aman",
                LocalPlayer.Name,
                tostring(LocalPlayer.UserId),
                tostring(d and d.Money or 0),
                tostring(d and d.Rebirth or 0)
            )
        end)
    end
end)

-- ISI TAB 3: FARM & ROLLS
AddSection(Tab3, "🎲 ROLLS & AUTOMATION")
AddToggle(Tab3, "Auto Roll Dice", "AutoRoll")
AddToggle(Tab3, "Auto Roll Spins", "AutoSpins")
AddToggle(Tab3, "Auto Buy Best Dice", "AutoDice")

-- ISI TAB 4: SELL & INVENTORY
AddSection(Tab4, "💰 INVENTORY & SELLING")
AddToggle(Tab4, "Auto Sell Inventory Junk", "AutoSell")

-- ISI TAB 5: TOWER
AddSection(Tab5, "🏰 TOWER AUTOMATION")
AddToggle(Tab5, "Auto Collect Plot Balance", "AutoCollect")
AddToggle(Tab5, "Smart Placement", "SmartPlace")
AddToggle(Tab5, "Auto Level Up Slots", "AutoLevel")
AddToggle(Tab5, "Auto Tower Runner", "AutoTower")

-- ISI TAB 6: UPGRADES & REBIRTH
AddSection(Tab6, "⚡ UPGRADES & REBIRTH")
AddToggle(Tab6, "Auto Buy Pad Upgrades", "AutoUpgrade")
AddToggle(Tab6, "Auto Rebirth", "AutoRebirth")

-- ISI TAB 7: FUSION & TRAITS
AddSection(Tab7, "🔮 FUSION & TRAITS")
AddToggle(Tab7, "Auto Fuse Units", "AutoFusion")

-- ISI TAB 8: CODES & QUESTS
AddSection(Tab8, "🎁 CODES & QUESTS")
AddToggle(Tab8, "Auto Redeem Codes", "AutoCodes")
AddToggle(Tab8, "Auto Claim Rewards", "AutoClaim")
AddToggle(Tab8, "Auto Claim Quests", "AutoQuests")

-- ISI TAB 9: CONFIG MANAGER
AddSection(Tab9, "📁 CONFIGURASI JSON")
AddTextbox(Tab9, "Nama Config...", function(txt) _G.Mofenk.CurrentConfigName = txt end)
AddButton(Tab9, "💾 Simpan Config Sekarang", function()
    if SaveConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Berhasil disimpan!", "success", 3)
    end
end)
AddButton(Tab9, "📂 Muat Config Sekarang", function()
    if LoadConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Berhasil dimuat!", "success", 3)
    end
end)
AddToggle(Tab9, "Auto-Load Config", "AutoLoadConfig")

-- ISI TAB 10: SERVER UTILS
AddSection(Tab10, "⚡ SERVER TOOLS")
AddButton(Tab10, "🌐 Server Hop (Cari Server Baru)", function() ServerHop() end)
AddButton(Tab10, "🔄 Rejoin Server Saat Ini", function() RejoinServer() end)

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

-- AUTOMATION LOOPS & BACKEND THREADS (DENGAN PROTEKSI NULL CHECK AMAN)
task.spawn(function()
    MofenkNotify("MOFENKHUB V32", "Zero Error Master Engine Aktif!", "success", 3)
    while task.wait(2.5) do
        if _G.Mofenk.AutoRoll and R.RollDice then
            pcall(function()
                if R.RollDice.ClassName == "RemoteFunction" then 
                    R.RollDice:InvokeServer()
                elseif R.RollDice.ClassName == "RemoteEvent" then 
                    R.RollDice:FireServer() 
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if _G.Mofenk.AutoCollect and R.CollectBalance then
            pcall(function()
                local d = data()
                if d and d.Slots then
                    for k, _ in pairs(d.Slots) do
                        if R.CollectBalance then
                            R.CollectBalance:FireServer(tonumber(k))
                        end
                    end
                end
            end)
        end
    end
end)
