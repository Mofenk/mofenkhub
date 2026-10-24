-- =====================================================================
-- 👑 MOFENKHUB V10.0 — ANIME DICE PERFECT ENGINE (SERVER MIRRORED)
-- Game: Anime Dice | Real Inventory ID Selling, DataController & Smart Auto-Farm
-- Compatible: Delta, Delta Lite, UgPhone, vsphone, Hydrogen, Codex
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI SISA RUN SEBELUMNYA
local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV10" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI GLOBAL MASTER
_G.Mofenk = {
    AutoAFK = true,
    AutoExecute = true,
    AutoReconnect = true,
    
    SpyEnabled = true,
    ClickInspectEnabled = false,
    SpyConsoleLog = true,
    SmartNotifications = true,
    SelectedRemoteForDebug = "SellInventory",
    CustomPayloadInput = "{}",
    
    -- Feature Toggles
    AutoRoll = false,
    AutoSellInventory = false,
    AutoCollectBalance = false,
    AutoEquipBest = false,
    AutoRebirth = false,
    AutoBuyDice = false,
    AutoBuyUpgrade = false,
    
    KeepRarityFloor = 3, -- 1=Common, 2=Uncommon, 3=Rare (Jual di bawah Rare)
    EnableFly = false, FlySpeed = 50
}

-- 3. THEME ACCENT COLOR SYSTEM
local Themes = {
    Cyan   = Color3.fromRGB(0, 208, 255),
    Purple = Color3.fromRGB(170, 0, 255),
    Red    = Color3.fromRGB(255, 60, 60),
    Green  = Color3.fromRGB(0, 230, 118),
    Gold   = Color3.fromRGB(255, 193, 7)
}
local CurrentTheme = Themes.Cyan
local ThemeStrokes = {}

local function UpdateThemeColor(newColor)
    CurrentTheme = newColor
    for _, stroke in ipairs(ThemeStrokes) do
        if stroke and stroke.Parent then stroke.Color = newColor end
    end
end

-- 4. SMART TOAST NOTIFICATION SYSTEM 🔔
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -260, 0, 20)
NotifyContainer.Size = UDim2.new(0, 250, 1, -40)
NotifyContainer.BackgroundTransparency = 1

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function MofenkNotify(title, message, nType, duration)
    if not _G.Mofenk.SmartNotifications then return end
    duration = duration or 3.5
    
    local Card = Instance.new("Frame")
    Card.Parent = NotifyContainer
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Card.BackgroundTransparency = 1
    Card.ClipsDescendants = true
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1.5
    CardStroke.Transparency = 1
    CardStroke.Parent = Card
    
    if nType == "success" then
        CardStroke.Color = Color3.fromRGB(0, 230, 118)
    elseif nType == "error" then
        CardStroke.Color = Color3.fromRGB(255, 60, 60)
    elseif nType == "warn" or nType == "inspect" then
        CardStroke.Color = Color3.fromRGB(255, 193, 7)
    elseif nType == "spy" then
        CardStroke.Color = Color3.fromRGB(170, 0, 255)
    else
        CardStroke.Color = CurrentTheme
    end
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Card
    TitleLbl.Position = UDim2.new(0, 10, 0, 6)
    TitleLbl.Size = UDim2.new(1, -20, 0, 16)
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.TextSize = 11
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextTransparency = 1
    
    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Parent = Card
    MsgLbl.Position = UDim2.new(0, 10, 0, 24)
    MsgLbl.Size = UDim2.new(1, -20, 0, 22)
    MsgLbl.Text = message
    MsgLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
    MsgLbl.TextSize = 10
    MsgLbl.Font = Enum.Font.GothamMedium
    MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
    MsgLbl.TextWrapped = true
    MsgLbl.BackgroundTransparency = 1
    MsgLbl.TextTransparency = 1
    
    TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local fadeOut = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            fadeOut:Play()
            fadeOut.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- 5. AKSED DATA MODULE INTERNAL GAME (DATA CONTROLLER)
local Framework = ReplicatedStorage:WaitForChild("Framework", 10)
local DataController, UnitConfig
pcall(function()
    DataController = require(Framework.Features.Data.DataController)
    UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
end)

local function GetGameData()
    return DataController and DataController.___X or nil
end

-- RARITY SORT ORDER MAP
local RARITY_MAP = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
    Mythical = 6, Divine = 7, Exotic = 8, Celestial = 9, Heavenly = 10
}

-- 6. REAL-TIME LOGGING ENGINE 📝
local LogScroll = nil
local function MofenkLog(msg, logType)
    local timestamp = os.date("%H:%M:%S")
    local formattedMsg = string.format("[%s] %s", timestamp, tostring(msg))
    print(formattedMsg)
    
    if LogScroll and LogScroll.Parent then
        local LogItem = Instance.new("TextLabel")
        LogItem.Parent = LogScroll
        LogItem.Size = UDim2.new(1, -10, 0, 18)
        LogItem.Text = formattedMsg
        
        if logType == "error" then
            LogItem.TextColor3 = Color3.fromRGB(255, 90, 90)
        elseif logType == "success" then
            LogItem.TextColor3 = Color3.fromRGB(100, 255, 150)
        elseif logType == "inspect" then
            LogItem.TextColor3 = Color3.fromRGB(255, 215, 0)
        elseif logType == "send" then
            LogItem.TextColor3 = Color3.fromRGB(120, 200, 255)
        elseif logType == "return" then
            LogItem.TextColor3 = Color3.fromRGB(220, 150, 255)
        else
            LogItem.TextColor3 = Color3.fromRGB(200, 210, 225)
        end
        
        LogItem.TextSize = 11
        LogItem.Font = Enum.Font.Code
        LogItem.TextXAlignment = Enum.TextXAlignment.Left
        LogItem.BackgroundTransparency = 1
        
        LogScroll.CanvasPosition = Vector2.new(0, 99999)
    end
end

-- 7. REAL-TIME NETWORK SPY HOOK (__NAMECALL)
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                local argStr = #args > 0 and tostring(args[1]) or "None"
                if _G.Mofenk.SpyConsoleLog then
                    MofenkLog(string.format("📡 [SPY] %s | %s(%s)", self.Name, method, argStr), "send")
                end
                MofenkNotify("📡 SPY DETECTED", string.format("%s (%s)", self.Name, method), "spy", 2)
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 8. EKSSEKUSI AUTO SELL PERBAIKAN AKURAT (MENGIRIM ARRAY ID ITEM REAL)
local function PerformSmartAutoSell()
    local gData = GetGameData()
    local Network = ReplicatedStorage:FindFirstChild("Network")
    local SellRF = Network and Network:FindFirstChild("SellService") and Network.SellService:FindFirstChild("RF") and Network.SellService.RF:FindFirstChild("SellInventory")
    
    if not gData or not gData.Inventory or not SellRF then
        MofenkLog("❌ Data Inventory atau Remote SellInventory Tidak Ditemukan!", "error")
        return
    end

    -- Kumpulkan ID unit yang terpasang di plot slot agar tidak ikut terjual
    local placedUnitIDs = {}
    if gData.Slots then
        for _, slot in pairs(gData.Slots) do
            if slot.unitId then placedUnitIDs[slot.unitId] = true end
        end
    end

    local itemsToSell = {}
    for unitID, unitData in pairs(gData.Inventory) do
        local entry = UnitConfig and UnitConfig.entries and UnitConfig.entries[unitData.name]
        if entry and not placedUnitIDs[unitID] then
            local rarityRank = RARITY_MAP[entry.rarity] or 1
            local isLocked = unitData.attributes and unitData.attributes.locked
            
            -- Jual jika kelangkaannya di bawah batas konfig & tidak dikunci
            if rarityRank < _G.Mofenk.KeepRarityFloor and not isLocked and not entry.limited then
                table.insert(itemsToSell, unitID)
            end
        end
    end

    if #itemsToSell > 0 then
        local success, value, totalSold = pcall(function()
            return SellRF:InvokeServer(itemsToSell)
        end)
        if success then
            MofenkLog(string.format("✅ [AUTO SELL SUCCESS] Berhasil Menjual %d Item! Nilai: %s", tonumber(totalSold) or #itemsToSell, tostring(value or "OK")), "success")
            MofenkNotify("AUTO SELL SUCCESS", string.format("Terjual: %d Unit Item!", tonumber(totalSold) or #itemsToSell), "success", 3)
        else
            MofenkLog("❌ [AUTO SELL FAILED] Server Menolak Panggilan!", "error")
        end
    else
        MofenkLog("ℹ️ Tidak ada unit sampah yang memenuhi kriteria penjualan.", "inspect")
    end
end

-- 9. MAIN UI BUILDER (DRAGGABLE + RESIZABLE)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV10"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = CurrentTheme
MainStroke.Parent = MainFrame
table.insert(ThemeStrokes, MainStroke)

-- Header Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 240, 1, 0)
TitleLabel.Text = "MOFENKHUB V10.0 — PERFECT ENGINE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = TopBar
StatsLabel.Position = UDim2.new(0, 260, 0, 0)
StatsLabel.Size = UDim2.new(0, 200, 1, 0)
StatsLabel.Text = "FPS: -- | Ping: -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(160, 170, 200)
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.GothamMedium

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -38, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 52)
Sidebar.Size = UDim2.new(0, 145, 1, -60)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Sidebar.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 4)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 159, 0, 52)
ContentArea.Size = UDim2.new(1, -167, 1, -60)
ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
ContentArea.BorderSizePixel = 0

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentArea

local TabFrames = {}

local function CreateTab(tabName, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = Sidebar
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.Text = " " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(170, 170, 190)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    TabBtn.LayoutOrder = layoutOrder

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Parent = ContentArea
    TabScroll.Size = UDim2.new(1, -12, 1, -12)
    TabScroll.Position = UDim2.new(0, 6, 0, 6)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 4
    TabScroll.ScrollBarImageColor3 = CurrentTheme
    TabScroll.Visible = false

    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Parent = TabScroll
    ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollLayout.Padding = UDim.new(0, 8)

    TabFrames[tabName] = TabScroll

    TabBtn.MouseButton1Click:Connect(function()
        for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
        for _, btn in ipairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(170, 170, 190)
                btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
            end
        end
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    end)

    return TabScroll
end

local function AddSection(parent, titleText)
    local SecLabel = Instance.new("TextLabel")
    SecLabel.Parent = parent
    SecLabel.Size = UDim2.new(1, 0, 0, 20)
    SecLabel.Text = titleText
    SecLabel.TextColor3 = CurrentTheme
    SecLabel.TextSize = 11
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    SecLabel.BackgroundTransparency = 1
    table.insert(ThemeStrokes, SecLabel)
end

local function AddToggle(parent, text, flag, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton")
    Switch.Parent = Frame
    Switch.Position = UDim2.new(1, -48, 0.5, -10)
    Switch.Size = UDim2.new(0, 38, 0, 20)
    Switch.Text = ""
    Switch.BackgroundColor3 = _G.Mofenk[flag] and CurrentTheme or Color3.fromRGB(50, 50, 65)

    local SwCorner = Instance.new("UICorner")
    SwCorner.CornerRadius = UDim.new(1, 0)
    SwCorner.Parent = Switch

    Switch.MouseButton1Click:Connect(function()
        _G.Mofenk[flag] = not _G.Mofenk[flag]
        Switch.BackgroundColor3 = _G.Mofenk[flag] and CurrentTheme or Color3.fromRGB(50, 50, 65)
        MofenkNotify("FITUR DIUBAH", text .. " -> " .. tostring(_G.Mofenk[flag]), _G.Mofenk[flag] and "success" or "warn", 2)
        if callback then callback(_G.Mofenk[flag]) end
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
    Btn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

-- TAB BUILDERS
local TabFarm     = CreateTab("🌾 Khusus Farm", 1)
local TabConsole  = CreateTab("🔍 Console & Log", 2)

TabFrames["🌾 Khusus Farm"].Visible = true

-- TAB 1: KHUSUS FARM
AddSection(TabFarm, "🎲 AUTOMATED FARMING")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Auto Sell Inventory (Real ID Array)", "AutoSellInventory")

AddButton(TabFarm, "⚡ Eksekusi Auto Sell Sekarang (Manual)", function()
    PerformSmartAutoSell()
end)

-- TAB 2: CONSOLE LOG
AddSection(TabConsole, "📝 LIVE IN-UI CONSOLE LOG")
LogScroll = Instance.new("ScrollingFrame")
LogScroll.Parent = TabConsole
LogScroll.Size = UDim2.new(1, 0, 0, 200)
LogScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 4

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 6)
LogCorner.Parent = LogScroll

local LogLayout = Instance.new("UIListLayout")
LogLayout.Parent = LogScroll
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 2)

-- FLOATING TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "🎲"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local TogCorner = Instance.new("UICorner")
TogCorner.CornerRadius = UDim.new(0, 12)
TogCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- AUTOMATION LOOP
task.spawn(function()
    MofenkNotify("MOFENKHUB V10.0", "Engine Sukses Terhubung ke Server Data!", "success", 3)
    while task.wait(3) do
        if _G.Mofenk.AutoSellInventory then
            PerformSmartAutoSell()
        end
    end
end)
