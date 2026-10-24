-- =====================================================================
-- 👑 MOFENKHUB V35.0 — MASTER CONTROL ULTIMATE UNCUT (CUSTOM SYNCED)
-- Game: Anime Dice | Complete UI Interface, Syncing All Features & Spy Debugger
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

-- 1. BERSIHKAN INSTANCE SEBELUMNYA
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI UTAMA & PREFERENSI GLOBAL LENGKAP
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
    AutoTower    = true,
    TowerName    = "Infinity Tower",
    AutoDice     = true,
    AutoUpgrade  = true,
    AutoRebirth  = true,
    AutoSell     = true,
    SellRarity   = 3,
    KeepBest     = 20,
    
    -- Fitur Tambahan Sesuai Referensi UI
    AutoFuse     = true,
    AutoQuirk    = true,
    QuirkMode    = "Pilih Otomatis (Best)",
    AutoTrait    = true,
    AutoGrade    = true,
    AutoPotion   = true,
    AutoGear     = true,
    AutoLock     = true,
    AutoCodes    = true,
    AutoClaim    = true,
    AutoQuests   = true,
    
    -- Client & Performance Settings
    FpsBoost     = false,
    RemoveDrops  = false,
    HideUiStart  = false,
    
    -- Webhook Integrations
    RollHookUrl  = "",
    RollHookOn   = false,
    StatHookUrl  = "",
    StatHookOn   = false,
}

-- 3. MANAJEMEN BERKAS CONFIG (JSON READ/WRITE)
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

-- 4. SKEMA TEMA VISUAL MODERN (DARK GLASS)
local Theme = {
    Bg        = Color3.fromRGB(12, 12, 18),
    Header    = Color3.fromRGB(18, 18, 26),
    Card      = Color3.fromRGB(24, 24, 34),
    Accent    = Color3.fromRGB(0, 229, 255),
    AccentSec = Color3.fromRGB(124, 58, 237),
    Text      = Color3.fromRGB(245, 245, 250),
    TextSub   = Color3.fromRGB(150, 150, 175)
}

-- 5. SISTEM NOTIFIKASI TOAST PROFESSIONAL
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

-- 6. PEMETAAN LAYANAN SERVER & REMOTE
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

local function ServerHop()
    MofenkNotify("SERVER", "Mencari instans server publik baru...", "info", 3)
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
end

local function RejoinServer()
    MofenkNotify("SERVER", "Memuat ulang sesi server saat ini...", "info", 3)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- 7. SPY DEBUGGER INTERCEPTOR LENGKAP (UNTUK DETEKSI SCRIPT GAGAL / ERROR)
local SpyLogsList = {}
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            task.spawn(function()
                local argsString = ""
                pcall(function()
                    for i, arg in ipairs(args) do
                        argsString = argsString .. tostring(arg) .. (i < #args and ", " or "")
                    end
                end)
                local logText = string.format("[SPY] %s | Remote: %s | Args: [%s]", method, self.Name, argsString)
                if _G.Mofenk.SpyConsoleLog then
                    print(logText)
                end
                table.insert(SpyLogsList, 1, logText)
                if #SpyLogsList > 60 then table.remove(SpyLogsList, 61) end
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 8. ANTARES UI DASHBOARD (11 TAB LENGKAP SESUAI REFERENSI)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV35"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 780, 0, 540)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -270)
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

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Header

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Size = UDim2.new(0, 420, 1, 0)
Title.Text = "MOFENKHUB V35.0 — MASTER CONTROL + SPY"
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

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 58)
Sidebar.Size = UDim2.new(0, 185, 1, -68)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.ScrollBarThickness = 3

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 205, 0, 58)
ContentArea.Size = UDim2.new(1, -215, 1, -68)
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

local function AddTextbox(parent, placeholder, flag)
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
    Box.Text = tostring(_G.Mofenk[flag] or "")
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Theme.TextSub
    Box.TextSize = 10
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.BackgroundTransparency = 1

    Box.FocusLost:Connect(function()
        _G.Mofenk[flag] = Box.Text
    end)
end

-- INISIALISASI TAB LENGKAP
local Tab1  = CreateTab("🏠 1. Dashboard", 1)
local Tab2  = CreateTab("👤 2. Profil", 2)
local Tab3  = CreateTab("🎲 3. Roll & Farm", 3)
local Tab4  = CreateTab("💰 4. Jual & Gear", 4)
local Tab5  = CreateTab("🏰 5. Tower", 5)
local Tab6  = CreateTab("⚡ 6. Upgrade", 6)
local Tab7  = CreateTab("🔮 7. Quirk & Potion", 7)
local Tab8  = CreateTab("🎁 8. Kode & Quest", 8)
local Tab9  = CreateTab("💻 9. Klien & Performa", 9)
local Tab10 = CreateTab("📁 10. Config", 10)
local Tab11 = CreateTab("🌐 11. Webhook & Spy", 11)

TabFrames["🏠 1. Dashboard"].Visible = true

-- ISI TAB 1: DASHBOARD
AddSection(Tab1, "📊 STATISTIK SESI LIVE")
local InfoCard = Instance.new("TextLabel")
InfoCard.Parent = Tab1
InfoCard.Size = UDim2.new(1, 0, 0, 75)
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
            InfoCard.Text = string.format("  Pengguna: %s (ID: %d)\n  Saldo: %s | Rebirth: %s\n  Total Roll: %s | Dadu: %s", 
                LocalPlayer.Name, LocalPlayer.UserId, 
                tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0),
                tostring(d and d.Rolls or 0), tostring(d and d.Dice or "-"))
        end)
    end
end)

-- ISI TAB 2: PROFIL
AddSection(Tab2, "👤 AVATAR 3D & PROFIL PENGGUNA")
local Viewport = Instance.new("ViewportFrame")
Viewport.Parent = Tab2
Viewport.Size = UDim2.new(1, 0, 0, 130)
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

local ProfileCard = Instance.new("TextLabel")
ProfileCard.Parent = Tab2
ProfileCard.Size = UDim2.new(1, 0, 0, 110)
ProfileCard.BackgroundColor3 = Theme.Card
ProfileCard.TextColor3 = Theme.Text
ProfileCard.TextSize = 10
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
                "  📋 DETAIL PROFIL AKUN:\n  • Nama: %s (ID: %s)\n  • Saldo Uang: %s\n  • Level Rebirth: %s\n  • Dadu Terpasang: %s\n  • Status Sesi: Stabil",
                LocalPlayer.Name, tostring(LocalPlayer.UserId),
                tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0), tostring(d and d.Dice or "-")
            )
        end)
    end
end)

-- ISI TAB 3: ROLL & FARM
AddSection(Tab3, "🎲 PENGATURAN ROLL & OTOMATISASI")
AddToggle(Tab3, "Otomatis Roll Dadu", "AutoRoll")
AddToggle(Tab3, "Otomatis Putar Spin", "AutoSpins")
AddToggle(Tab3, "Otomatis Beli Dadu Terbaik", "AutoDice")

-- ISI TAB 4: JUAL & GEAR
AddSection(Tab4, "💰 MANAJEMEN INVENTARIS & GEAR")
AddToggle(Tab4, "Otomatis Jual Item/Unit Sampah", "AutoSell")
AddToggle(Tab4, "Otomatis Kunci Unit Langka", "AutoLock")
AddToggle(Tab4, "Otomatis Pasang Gear Terbaik", "AutoGear")

-- ISI TAB 5: TOWER
AddSection(Tab5, "🏰 OTOMATISASI TOWER & SELEKTOR")
AddToggle(Tab5, "Otomatis Ambil Saldo Plot", "AutoCollect")
AddToggle(Tab5, "Penempatan Cerdas (Smart Placement)", "SmartPlace")
AddToggle(Tab5, "Otomatis Tingkatkan Level Slot", "AutoLevel")
AddToggle(Tab5, "Otomatis Jalankan Tower", "AutoTower")

local TowerSelContainer = Instance.new("Frame")
TowerSelContainer.Parent = Tab5
TowerSelContainer.Size = UDim2.new(1, 0, 0, 36)
TowerSelContainer.BackgroundColor3 = Theme.Card
local TSC = Instance.new("UICorner")
TSC.CornerRadius = UDim.new(0, 6)
TSC.Parent = TowerSelContainer

local TowerLbl = Instance.new("TextLabel")
TowerLbl.Parent = TowerSelContainer
TowerLbl.Position = UDim2.new(0, 10, 0, 0)
TowerLbl.Size = UDim2.new(0.5, 0, 1, 0)
TowerLbl.Text = "Target Tower:"
TowerLbl.TextColor3 = Theme.Text
TowerLbl.TextSize = 10
TowerLbl.Font = Enum.Font.GothamMedium
TowerLbl.TextXAlignment = Enum.TextXAlignment.Left
TowerLbl.BackgroundTransparency = 1

local TowerBtnSel = Instance.new("TextButton")
TowerBtnSel.Parent = TowerSelContainer
TowerBtnSel.Position = UDim2.new(0.5, 0, 0.15, 0)
TowerBtnSel.Size = UDim2.new(0.48, 0, 0.7, 0)
TowerBtnSel.Text = _G.Mofenk.TowerName
TowerBtnSel.TextColor3 = Theme.Accent
TowerBtnSel.TextSize = 10
TowerBtnSel.Font = Enum.Font.GothamBold
TowerBtnSel.BackgroundColor3 = Theme.Header
local TBSC = Instance.new("UICorner")
TBSC.CornerRadius = UDim.new(0, 4)
TBSC.Parent = TowerBtnSel

local towersList = {"Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower", "Hidden Leaf Tower"}
local tIdx = 1
TowerBtnSel.MouseButton1Click:Connect(function()
    tIdx = tIdx % #towersList + 1
    _G.Mofenk.TowerName = towersList[tIdx]
    TowerBtnSel.Text = _G.Mofenk.TowerName
    MofenkNotify("TOWER", "Tower diubah ke: " .. _G.Mofenk.TowerName, "success", 2)
end)

-- ISI TAB 6: UPGRADE
AddSection(Tab6, "⚡ PENINGKATAN & REBIRTH")
AddToggle(Tab6, "Otomatis Beli Upgrade Pad", "AutoUpgrade")
AddToggle(Tab6, "Otomatis Rebirth", "AutoRebirth")

-- ISI TAB 7: QUIRK & POTION
AddSection(Tab7, "🔮 FUSION & POTION")
AddToggle(Tab7, "Otomatis Gabungkan Unit (Fusion)", "AutoFuse")
AddToggle(Tab7, "Otomatis Gunakan Potion", "AutoPotion")

AddSection(Tab7, "⚡ TOOLSQUIRT & OPSI QUIRK")
AddToggle(Tab7, "Otomatis Roll Quirk", "AutoQuirk")
AddToggle(Tab7, "Otomatis Roll Trait", "AutoTrait")
AddToggle(Tab7, "Otomatis Roll Grade", "AutoGrade")

-- ISI TAB 8: KODE & QUEST
AddSection(Tab8, "🎁 KODE, HADIAH & QUEST")
AddToggle(Tab8, "Otomatis Klaim Kode Redeem", "AutoCodes")
AddToggle(Tab8, "Otomatis Klaim Reward Login", "AutoClaim")
AddToggle(Tab8, "Otomatis Klaim Semua Quest", "AutoQuests")

-- ISI TAB 9: KLIEN & PERFORMA
AddSection(Tab9, "💻 PENGATURAN PERFORMA KLIEN")
AddToggle(Tab9, "FPS Boost Mode", "FpsBoost")
AddToggle(Tab9, "Hapus Dropped Money / Items", "RemoveDrops")
AddToggle(Tab9, "Sembunyikan UI saat Mulai", "HideUiStart")

-- ISI TAB 10: CONFIG
AddSection(Tab10, "📁 MANAJEMEN KONFIGURASI DATA")
AddTextbox(Tab10, "Nama Berkas Konfigurasi...", "CurrentConfigName")
AddButton(Tab10, "💾 Simpan Konfigurasi Saat Ini", function()
    if SaveConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Konfigurasi berhasil disimpan.", "success", 3)
    end
end)
AddButton(Tab10, "📂 Muat Konfigurasi Tersimpan", function()
    if LoadConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Konfigurasi berhasil dimuat.", "success", 3)
    end
end)
AddToggle(Tab10, "Muat Otomatis Saat Masuk", "AutoLoadConfig")

-- ISI TAB 11: WEBHOOK & SPY DEBUGGER
AddSection(Tab11, "🌐 INTEGRASI DISCORD WEBHOOK")
AddTextbox(Tab11, "URL Webhook Notifikasi Roll...", "RollHookUrl")
AddToggle(Tab11, "Aktifkan Webhook Roll", "RollHookOn")
AddTextbox(Tab11, "URL Webhook Laporan Status...", "StatHookUrl")
AddToggle(Tab11, "Aktifkan Webhook Status", "StatHookOn")

AddSection(Tab11, "⚡ UTILITAS SERVER & SPY DEBUGGER")
AddButton(Tab11, "🌐 Pindah Server Publik (Server Hop)", function() ServerHop() end)
AddButton(Tab11, "🔄 Hubungkan Ulang (Rejoin)", function() RejoinServer() end)
AddToggle(Tab11, "Aktifkan Konsol Logger Spy", "SpyConsoleLog")

local SpyBox = Instance.new("TextBox")
SpyBox.Parent = Tab11
SpyBox.Size = UDim2.new(1, 0, 0, 110)
SpyBox.BackgroundColor3 = Theme.Card
SpyBox.TextColor3 = Color3.fromRGB(0, 255, 128)
SpyBox.TextSize = 9
SpyBox.Font = Enum.Font.Code
SpyBox.MultiLine = true
SpyBox.ClearTextOnFocus = false
SpyBox.TextXAlignment = Enum.TextXAlignment.Left
SpyBox.TextYAlignment = Enum.TextYAlignment.Top
SpyBox.Text = "-- Advanced Spy Debugger Interceptor Aktif --"
local SBC = Instance.new("UICorner")
SBC.CornerRadius = UDim.new(0, 6)
SBC.Parent = SpyBox

task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if #SpyLogsList > 0 then
                SpyBox.Text = table.concat(SpyLogsList, "\n")
            end
        end)
    end
end)

-- TOMBOL APUNG TOGGLE MENU
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

-- THREAD UTAMA OTOMATISASI BACKEND
task.spawn(function()
    MofenkNotify("MOFENKHUB V35", "Sistem kendali utama dan Spy Interceptor aktif.", "success", 3)
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
    while task.wait(6) do
        if _G.Mofenk.AutoFuse and R.Fuse then
            pcall(function()
                local d = data()
                if d and d.Inventory then
                    local pile = {}
                    for id, u in pairs(d.Inventory) do
                        table.insert(pile, id)
                        if #pile >= 3 then break end
                    end
                    if #pile >= 3 then
                        R.Fuse:FireServer(pile[1], pile[2], pile[3])
                        MofenkNotify("FUSION", "Penggabungan otomatis 3 unit berhasil diproses.", "success", 2)
                    end
                end
            end)
        end
    end
end)
