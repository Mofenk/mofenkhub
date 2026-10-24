-- =====================================================================
-- 👑 MOFENKHUB V35.0 — MASTER CONTROL MODULAR (PRO EDITION)
-- Game: Anime Dice | Structured Group UI, Manual Default, Fixed Remotes
-- =====================================================================

task.wait(1.5)

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- 1. BERSIHKAN INSTANCE LAMA
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI GLOBAL (DEFAULT MATI / MANUAL DI AWAL)
_G.Mofenk = {
    AutoAFK            = false,
    AutoReconnect      = true,
    SmartNotifications = true,
    
    -- Farm & Roll
    AutoRoll     = false,
    AutoSpins    = false,
    AutoDice     = false,
    
    -- Jual & Inventaris
    AutoSell     = false,
    SellRarity   = 3,
    AutoLock     = false,
    AutoGear     = false,
    AutoFuse     = false,
    
    -- Tower & Sesi
    AutoTower    = false,
    TowerName    = "Infinity Tower",
    AutoCollect  = false,
    SmartPlace   = false,
    AutoLevel    = false,
    
    -- Upgrade & Rebirth
    AutoUpgrade  = false,
    AutoRebirth  = false,
    
    -- Quirk / Traits / ToolsQuirt
    AutoQuirk    = false,
    QuirkMode    = "Pilih Otomatis",
    AutoTrait    = false,
    AutoGrade    = false,
    AutoPotion   = false,
    
    -- Quest & Redeem
    AutoCodes    = false,
    AutoClaim    = false,
    AutoQuests   = false,
    
    -- Webhook
    WebhookUrl   = "",
    WebhookActive = false,
}

-- 3. MAPPING REMOTE GAME (DIPERBAIKI AGAR WORK)
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
    BuyDice        = Network and (safeFind(Network, "RollService.RF.BuyDice") or safeFind(Network, "RollService.RE.BuyDice")),
    CollectBalance = Network and (safeFind(Network, "PlotService.RE.CollectBalance") or safeFind(Network, "PlotService.RF.CollectBalance")),
    PlayTower      = Network and (safeFind(Network, "Towers.RF.PlayTower") or safeFind(Network, "Towers.RE.PlayTower")),
    SellInventory  = Network and (safeFind(Network, "SellService.RF.SellInventory") or safeFind(Network, "SellService.RE.SellInventory")),
    Fuse           = Network and safeFind(Network, "FusingService.RE.Fuse"),
}

local DataController
pcall(function()
    if Framework then DataController = require(Framework.Features.Data.DataController) end
end)

local function data()
    local ok, res = pcall(function() return DataController.___X end)
    return ok and res or nil
end

-- 4. TEMA VISUAL MODERN & ELEGAN (SPECTRUM DARK)
local Theme = {
    Bg        = Color3.fromRGB(15, 15, 22),
    Header    = Color3.fromRGB(22, 22, 32),
    Card      = Color3.fromRGB(28, 28, 42),
    Accent    = Color3.fromRGB(0, 200, 255),
    AccentSec = Color3.fromRGB(110, 40, 230),
    Text      = Color3.fromRGB(240, 240, 245),
    TextSub   = Color3.fromRGB(140, 140, 165)
}

-- 5. NOTIFIKASI TOAST
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

local function MofenkNotify(title, message, duration)
    duration = duration or 3
    local Card = Instance.new("Frame")
    Card.Parent = NotifyContainer
    Card.Size = UDim2.new(1, 0, 0, 48)
    Card.BackgroundColor3 = Theme.Card
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Card
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Card
    TitleLbl.Position = UDim2.new(0, 10, 0, 4)
    TitleLbl.Size = UDim2.new(1, -20, 0, 16)
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Theme.Accent
    TitleLbl.TextSize = 11
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.BackgroundTransparency = 1
    
    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Parent = Card
    MsgLbl.Position = UDim2.new(0, 10, 0, 20)
    MsgLbl.Size = UDim2.new(1, -20, 0, 20)
    MsgLbl.Text = message
    MsgLbl.TextColor3 = Theme.TextSub
    MsgLbl.TextSize = 9
    MsgLbl.Font = Enum.Font.GothamMedium
    MsgLbl.BackgroundTransparency = 1
    
    task.delay(duration, function()
        pcall(function() Card:Destroy() end)
    end)
end

-- 6. UI UTAMA (MODULAR GROUP TABS)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV35"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 760, 0, 520)
MainFrame.Position = UDim2.new(0.5, -380, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Theme.Accent
MainStroke.Parent = MainFrame

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Size = UDim2.new(0, 350, 1, 0)
Title.Text = "👑 MOFENKHUB V35.0 — MODULAR CONTROL"
Title.TextColor3 = Theme.Text
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Theme.Card
local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 6)
CC.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar Group Nav
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 50)
Sidebar.Size = UDim2.new(0, 170, 1, -58)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.ScrollBarThickness = 2
local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 3)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 185, 0, 50)
ContentArea.Size = UDim2.new(1, -193, 1, -58)
ContentArea.BackgroundColor3 = Theme.Header

local TabFrames = {}

local function CreateTab(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar
    Btn.Size = UDim2.new(1, -4, 0, 30)
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
    Scroll.Size = UDim2.new(1, -10, 1, -10)
    Scroll.Position = UDim2.new(0, 5, 0, 5)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.Visible = false

    local Lay = Instance.new("UIListLayout")
    Lay.Parent = Scroll
    Lay.Padding = UDim.new(0, 6)

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
    L.Size = UDim2.new(1, 0, 0, 20)
    L.Text = text
    L.TextColor3 = Theme.Accent
    L.TextSize = 10
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag)
    local state = _G.Mofenk[flag] or false
    local F = Instance.new("Frame")
    F.Parent = parent
    F.Size = UDim2.new(1, 0, 0, 32)
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
    Sw.Position = UDim2.new(1, -40, 0.5, -8)
    Sw.Size = UDim2.new(0, 30, 0, 16)
    Sw.Text = ""
    Sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 45, 60)

    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw

    local Knob = Instance.new("Frame")
    Knob.Parent = Sw
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = Knob

    Sw.MouseButton1Click:Connect(function()
        state = not state
        _G.Mofenk[flag] = state
        TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 45, 60)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
    end)
end

-- TAB PEMBUATAN (GROUPING TERPISAH)
local Tab1  = CreateTab("📊 Dashboard & Profil", 1)
local Tab2  = CreateTab("🎲 Roll & Farm", 2)
local Tab3  = CreateTab("💰 Jual & Inventaris", 3)
local Tab4  = CreateTab("🏰 Tower Automation", 4)
local Tab5  = CreateTab("⚡ Upgrade & Rebirth", 5)
local Tab6  = CreateTab("🔮 Quirk & Traits", 6)
local Tab7  = CreateTab("🎁 Quest & Redeem", 7)
local Tab8  = CreateTab("🌐 Webhook & Server", 8)

TabFrames["📊 Dashboard & Profil"].Visible = true

-- TAB 1: DASHBOARD & PROFIL (DIGABUNG DALAM SATU GRUP BERSIH)
AddSection(Tab1, "👤 INFORMASI PROFIL & AKUN")
local ProfileCard = Instance.new("TextLabel")
ProfileCard.Parent = Tab1
ProfileCard.Size = UDim2.new(1, 0, 0, 85)
ProfileCard.BackgroundColor3 = Theme.Card
ProfileCard.TextColor3 = Theme.Text
ProfileCard.TextSize = 10
ProfileCard.Font = Enum.Font.GothamMedium
ProfileCard.TextXAlignment = Enum.TextXAlignment.Left
ProfileCard.TextYAlignment = Enum.TextYAlignment.Top
local PC = Instance.new("UICorner")
PC.CornerRadius = UDim.new(0, 6)
PC.Parent = ProfileCard

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local d = data()
            ProfileCard.Text = string.format(
                "  • Nama: %s\n  • User ID: %s\n  • Uang / Saldo: %s\n  • Rebirth: %s\n  • Status: Terhubung Stabil",
                LocalPlayer.Name, tostring(LocalPlayer.UserId),
                tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0)
            )
        end)
    end
end)

-- TAB 2: ROLL & FARM
AddSection(Tab2, "🎲 PENGATURAN ROLL & DADU")
AddToggle(Tab2, "Auto Roll Dadu", "AutoRoll")
AddToggle(Tab2, "Auto Putar Spin", "AutoSpins")
AddToggle(Tab2, "Auto Beli Dadu Terbaik", "AutoDice")

-- TAB 3: JUAL & INVENTARIS
AddSection(Tab3, "💰 PENGELOLAAN INVENTARIS")
AddToggle(Tab3, "Auto Jual Unit/Item Sampah", "AutoSell")
AddToggle(Tab3, "Auto Kunci Unit Langka", "AutoLock")
AddToggle(Tab3, "Auto Pasang Gear Terbaik", "AutoGear")
AddToggle(Tab3, "Auto Fusion Unit", "AutoFuse")

-- TAB 4: TOWER AUTOMATION
AddSection(Tab4, "🏰 PENGATURAN TOWER")
AddToggle(Tab4, "Auto Jalankan Tower Runner", "AutoTower")
AddToggle(Tab4, "Auto Ambil Saldo Plot", "AutoCollect")
AddToggle(Tab4, "Smart Placement Unit", "SmartPlace")
AddToggle(Tab4, "Auto Upgrade Level Slot", "AutoLevel")

local TowerContainer = Instance.new("Frame")
TowerContainer.Parent = Tab4
TowerContainer.Size = UDim2.new(1, 0, 0, 34)
TowerContainer.BackgroundColor3 = Theme.Card
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 6)
TC.Parent = TowerContainer

local TowerLbl = Instance.new("TextLabel")
TowerLbl.Parent = TowerContainer
TowerLbl.Position = UDim2.new(0, 10, 0, 0)
TowerLbl.Size = UDim2.new(0.4, 0, 1, 0)
TowerLbl.Text = "Pilih Tower:"
TowerLbl.TextColor3 = Theme.Text
TowerLbl.TextSize = 10
TowerLbl.Font = Enum.Font.GothamMedium
TowerLbl.TextXAlignment = Enum.TextXAlignment.Left
TowerLbl.BackgroundTransparency = 1

local TowerBtn = Instance.new("TextButton")
TowerBtn.Parent = TowerContainer
TowerBtn.Position = UDim2.new(0.4, 0, 0.15, 0)
TowerBtn.Size = UDim2.new(0.58, 0, 0.7, 0)
TowerBtn.Text = _G.Mofenk.TowerName
TowerBtn.TextColor3 = Theme.Accent
TowerBtn.TextSize = 10
TowerBtn.Font = Enum.Font.GothamBold
TowerBtn.BackgroundColor3 = Theme.Header
local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 4)
TBC.Parent = TowerBtn

local towers = {"Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower"}
local tIdx = 1
TowerBtn.MouseButton1Click:Connect(function()
    tIdx = tIdx % #towers + 1
    _G.Mofenk.TowerName = towers[tIdx]
    TowerBtn.Text = _G.Mofenk.TowerName
    MofenkNotify("TOWER", "Target diubah ke: " .. _G.Mofenk.TowerName, 2)
end)

-- TAB 5: UPGRADE & REBIRTH
AddSection(Tab5, "⚡ UPGRADE & REBIRTH")
AddToggle(Tab5, "Auto Beli Pad Upgrades", "AutoUpgrade")
AddToggle(Tab5, "Auto Rebirth Otomatis", "AutoRebirth")

-- TAB 6: QUIRK & TRAITS
AddSection(Tab6, "🔮 QUIRK, TRAIT & POTION")
AddToggle(Tab6, "Auto Roll Quirk", "AutoQuirk")
AddToggle(Tab6, "Auto Roll Trait", "AutoTrait")
AddToggle(Tab6, "Auto Roll Grade", "AutoGrade")
AddToggle(Tab6, "Auto Gunakan Potion", "AutoPotion")

-- TAB 7: QUEST & REDEEM
AddSection(Tab7, "🎁 KODE & QUEST")
AddToggle(Tab7, "Auto Redeem Kode", "AutoCodes")
AddToggle(Tab7, "Auto Klaim Login Reward", "AutoClaim")
AddToggle(Tab7, "Auto Klaim Semua Quest", "AutoQuests")

-- TAB 8: WEBHOOK & SERVER
AddSection(Tab8, "🌐 KONTROL SERVER & WEBHOOK")
AddToggle(Tab8, "Aktifkan Webhook Discord", "WebhookActive")

local BtnHop = Instance.new("TextButton")
BtnHop.Parent = Tab8
BtnHop.Size = UDim2.new(1, 0, 0, 32)
BtnHop.Text = "🌐 Pindah Server (Server Hop)"
BtnHop.TextColor3 = Theme.Text
BtnHop.TextSize = 10
BtnHop.Font = Enum.Font.GothamBold
BtnHop.BackgroundColor3 = Theme.Card
local BHB = Instance.new("UICorner")
BHB.CornerRadius = UDim.new(0, 6)
BHB.Parent = BtnHop
BtnHop.MouseButton1Click:Connect(function()
    MofenkNotify("SERVER", "Mencari server kosong...", 2)
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(Api)) end)
    if success and res and res.data then
        for _, s in ipairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end
end)

-- TOMBOL APUNG INTERAKTIF (BISA DISEMBUNYIKAN)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Text = "👑"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.TextSize = 20
ToggleBtn.Active = true
ToggleBtn.Draggable = true
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 10)
TC.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- THREAD UTAMA EKSEKUSI BACKEND SESUAI TOGGLE MANUAL
task.spawn(function()
    MofenkNotify("MOFENKHUB V35", "Sistem berhasil dimuat. Silakan aktifkan fitur sesuai kebutuhan.", 4)
    while task.wait(2) do
        -- 1. Auto Roll Dadu
        if _G.Mofenk.AutoRoll and R.RollDice then
            pcall(function()
                if R.RollDice.ClassName == "RemoteFunction" then 
                    R.RollDice:InvokeServer()
                elseif R.RollDice.ClassName == "RemoteEvent" then 
                    R.RollDice:FireServer() 
                end
            end)
        end
        
        -- 2. Auto Buy Dice
        if _G.Mofenk.AutoDice and R.BuyDice then
            pcall(function()
                if R.BuyDice.ClassName == "RemoteFunction" then 
                    R.BuyDice:InvokeServer()
                elseif R.BuyDice.ClassName == "RemoteEvent" then 
                    R.BuyDice:FireServer() 
                end
            end)
        end
        
        -- 3. Auto Collect Plot Balance
        if _G.Mofenk.AutoCollect and R.CollectBalance then
            pcall(function()
                if R.CollectBalance.ClassName == "RemoteFunction" then
                    R.CollectBalance:InvokeServer()
                elseif R.CollectBalance.ClassName == "RemoteEvent" then
                    R.CollectBalance:FireServer()
                end
            end)
        end
        
        -- 4. Auto Sell Inventory
        if _G.Mofenk.AutoSell and R.SellInventory then
            pcall(function()
                if R.SellInventory.ClassName == "RemoteFunction" then
                    R.SellInventory:InvokeServer(_G.Mofenk.SellRarity)
                elseif R.SellInventory.ClassName == "RemoteEvent" then
                    R.SellInventory:FireServer(_G.Mofenk.SellRarity)
                end
            end)
        end
    end
end)
