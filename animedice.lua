-- =====================================================================
-- 👑 MOFENKHUB V4.0 — ULTRA DIAGNOSTIC & RESIZABLE EDITION
-- Game: Anime Dice | Full Sell Remotes, Diagnostics, Resizable & Draggable UI
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
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI LAMA
local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV4" or v.Name == "MofenkToggleGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI GLOBAL MASTER
_G.Mofenk = {
    AutoAFK = true,
    AutoExecute = true,
    AutoReconnect = true,
    
    SpyEnabled = true,
    SpyConsoleLog = true,
    
    -- Feature Toggles
    AutoRoll = false,
    AutoSellInventory = false,
    AutoSellEquipped = false,
    EnableGameAutoSell = false,
    AutoClaimQuests = false,
    AutoClaimRewards = false,
    AutoCollectBalance = false,
    AutoLevelUpSlot = false,
    AutoInteractSlot = false,
    AutoEquipBest = false,
    AutoRebirth = false,
    AutoEquipUnit = false,
    AutoEquipGear = false,
    AutoFuse = false,
    AutoUseBoosts = false,
    AutoBuyDice = false,
    AutoBuyUpgrade = false,
    
    EnableFly = false, FlySpeed = 50,
    EnableWalkSpeed = false, WalkSpeedVal = 16
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
        if stroke and stroke.Parent then
            stroke.Color = newColor
        end
    end
end

-- 4. PATH REMOTE EVENT & FUNCTION (HASIL SCAN CONS0LE F9)
local Network = ReplicatedStorage:WaitForChild("Network", 5)

local RollService = Network and Network:FindFirstChild("RollService")
local SellService = Network and Network:FindFirstChild("SellService")
local QuestService = Network and Network:FindFirstChild("QuestService")
local DailyRewardService = Network and Network:FindFirstChild("DailyRewardService")
local OfflineEarningsService = Network and Network:FindFirstChild("OfflineEarningsService")
local GroupRewardService = Network and Network:FindFirstChild("GroupRewardService")
local PlotService = Network and Network:FindFirstChild("PlotService")
local DiceShopService = Network and Network:FindFirstChild("DiceShopService")
local RebirthService = Network and Network:FindFirstChild("RebirthService")
local UnitService = Network and Network:FindFirstChild("UnitService")
local GearService = Network and Network:FindFirstChild("GearService")
local FusingService = Network and Network:FindFirstChild("FusingService")
local CodesService = Network and Network:FindFirstChild("CodesService")
local BoostService = Network and Network:FindFirstChild("BoostService")

-- 5. REAL-TIME LOGGING ENGINE 📝
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
        elseif logType == "warn" then
            LogItem.TextColor3 = Color3.fromRGB(255, 200, 80)
        else
            LogItem.TextColor3 = Color3.fromRGB(180, 220, 255)
        end
        
        LogItem.TextSize = 11
        LogItem.Font = Enum.Font.Code
        LogItem.TextXAlignment = Enum.TextXAlignment.Left
        LogItem.BackgroundTransparency = 1
        
        LogScroll.CanvasPosition = Vector2.new(0, 99999)
    end
end

-- 6. PURE CUSTOM RAYFIELD UI BUILDER (DRAGGABLE + RESIZABLE)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV4"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

-- Container Utama Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
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

-- Top Header Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 180, 1, 0)
TitleLabel.Text = "MOFENKHUB V4.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- FPS & Ping Monitor
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = TopBar
StatsLabel.Position = UDim2.new(0, 180, 0, 0)
StatsLabel.Size = UDim2.new(0, 260, 1, 0)
StatsLabel.Text = "FPS: -- | Ping: -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(160, 170, 200)
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -38, 0, 7)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 44)

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- RESIZE HANDLE (TOMBOL RESIZE POJOK KANAN BAWAH)
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Name = "ResizeHandle"
ResizeBtn.Parent = MainFrame
ResizeBtn.Position = UDim2.new(1, -18, 1, -18)
ResizeBtn.Size = UDim2.new(0, 16, 0, 16)
ResizeBtn.Text = "⇲"
ResizeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
ResizeBtn.TextSize = 12
ResizeBtn.Font = Enum.Font.GothamBold
ResizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ResizeBtn.BackgroundTransparency = 0.3

local ResCorner = Instance.new("UICorner")
ResCorner.CornerRadius = UDim.new(0, 4)
ResCorner.Parent = ResizeBtn

local isResizing = false
local startSize, startPos

ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        startSize = MainFrame.Size
        startPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startPos
        local newWidth = math.clamp(startSize.X.Offset + delta.X, 420, 850)
        local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 280, 600)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

-- Sidebar Tabs Container
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 50)
Sidebar.Size = UDim2.new(0, 140, 1, -58)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Sidebar.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 4)

-- Content Area Frame
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 154, 0, 50)
ContentArea.Size = UDim2.new(1, -162, 1, -58)
ContentArea.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ContentArea.BorderSizePixel = 0

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentArea

-- TAB CREATION LOGIC
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
    TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
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
        for name, frame in pairs(TabFrames) do
            frame.Visible = (name == tabName)
        end
        for _, btn in ipairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(170, 170, 190)
                btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            end
        end
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
    end)

    return TabScroll
end

-- HELPER UI COMPONENT BUILDERS
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
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

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
        MofenkLog("Feature [" .. text .. "] -> " .. tostring(_G.Mofenk[flag]), _G.Mofenk[flag] and "success" or "warn")
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
    Btn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- TAB BUILDERS
local TabHome   = CreateTab("🏠 Home & Profil", 1)
local TabFarm   = CreateTab("🌾 Khusus Farm", 2)
local TabTower  = CreateTab("🏰 Tower & Plot", 3)
local TabUnit   = CreateTab("⚔️ Unit & Gear", 4)
local TabShop   = CreateTab("⬆️ Upgrade & Shop", 5)
local TabPlayer = CreateTab("⚡ Player & Utils", 6)
local TabConsole= CreateTab("🔍 Console & Log", 7)

TabFrames["🏠 Home & Profil"].Visible = true

-- TAB 1: HOME & PROFIL
AddSection(TabHome, "👤 LIVE PROFIL USER")
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Parent = TabHome
ProfileFrame.Size = UDim2.new(1, 0, 0, 64)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

local ProfCorner = Instance.new("UICorner")
ProfCorner.CornerRadius = UDim.new(0, 8)
ProfCorner.Parent = ProfileFrame

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Parent = ProfileFrame
AvatarImg.Size = UDim2.new(0, 48, 0, 48)
AvatarImg.Position = UDim2.new(0, 8, 0, 8)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = AvatarImg

local AvStroke = Instance.new("UIStroke")
AvStroke.Thickness = 2
AvStroke.Color = CurrentTheme
AvStroke.Parent = AvatarImg
table.insert(ThemeStrokes, AvStroke)

local ProfLabel = Instance.new("TextLabel")
ProfLabel.Parent = ProfileFrame
ProfLabel.Position = UDim2.new(0, 64, 0, 4)
ProfLabel.Size = UDim2.new(1, -70, 1, -8)
ProfLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
ProfLabel.TextSize = 11
ProfLabel.Font = Enum.Font.GothamMedium
ProfLabel.TextXAlignment = Enum.TextXAlignment.Left
ProfLabel.BackgroundTransparency = 1

AddSection(TabHome, "📊 LIVE PLAYER LEADERSTATS")
local StatsTextLabel = Instance.new("TextLabel")
StatsTextLabel.Parent = TabHome
StatsTextLabel.Size = UDim2.new(1, 0, 0, 45)
StatsTextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatsTextLabel.TextSize = 11
StatsTextLabel.Font = Enum.Font.GothamMedium
StatsTextLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsTextLabel.BackgroundTransparency = 1

AddSection(TabHome, "📦 LIVE INVENTORY & ITEMS")
local InvTextLabel = Instance.new("TextLabel")
InvTextLabel.Parent = TabHome
InvTextLabel.Size = UDim2.new(1, 0, 0, 45)
InvTextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InvTextLabel.TextSize = 11
InvTextLabel.Font = Enum.Font.GothamMedium
InvTextLabel.TextXAlignment = Enum.TextXAlignment.Left
InvTextLabel.BackgroundTransparency = 1

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            ProfLabel.Text = string.format("USN: %s | ID: %d\nDisplay: %s\nAge: %d Hari", LocalPlayer.Name, LocalPlayer.UserId, LocalPlayer.DisplayName, LocalPlayer.AccountAge or 0)
            
            local st = ""
            if LocalPlayer:FindFirstChild("leaderstats") then
                for _, s in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                    st = st .. string.format("• %s: %s  ", s.Name, tostring(s.Value))
                end
            end
            StatsTextLabel.Text = st ~= "" and st or "Leaderstats Kosong."

            local inv = "• Backpack Items: " .. tostring(#(LocalPlayer.Backpack:GetChildren())) .. "\n• Equipped Tool: "
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                inv = inv .. (tool and tool.Name or "None")
            end
            InvTextLabel.Text = inv
        end)
    end
end)

-- TAB 2: KHUSUS FARM (DENGAN ALL SELL REMOTES INTEGRATED)
AddSection(TabFarm, "🎲 AUTOMATED FARMING")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Smart Rebirth (3s Cooldown)", "AutoRebirth")

AddSection(TabFarm, "💰 SELL REMOTES DIAGNOSTIC & AUTOMATION")
AddToggle(TabFarm, "Auto Sell Inventory (SellInventory)", "AutoSellInventory")
AddToggle(TabFarm, "Auto Sell Equipped (SellEquipped)", "AutoSellEquipped")
AddToggle(TabFarm, "Game AutoSell Switcher (SetAutoSell)", "EnableGameAutoSell", function(state)
    if SellService then
        if SellService:FindFirstChild("RE") and SellService.RE:FindFirstChild("SetAutoSell") then
            pcall(function() SellService.RE.SetAutoSell:FireServer(state) end)
            MofenkLog("SetAutoSell Fired: " .. tostring(state), "info")
        end
        if SellService:FindFirstChild("RE") and SellService.RE:FindFirstChild("UpdateAutoSell") then
            pcall(function() SellService.RE.UpdateAutoSell:FireServer(state) end)
            MofenkLog("UpdateAutoSell Fired: " .. tostring(state), "info")
        end
    end
end)

AddButton(TabFarm, "Tes Manual Sell Inventory Sekarang", function()
    if SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellInventory") then
        local res = SellService.RF.SellInventory:InvokeServer()
        MofenkLog("[MANUAL TEST] SellInventory Res: " .. tostring(res), "success")
    else
        MofenkLog("[MANUAL TEST] SellInventory RF Tidak Ditemukan!", "error")
    end
end)

AddButton(TabFarm, "Tes Manual Sell Equipped Sekarang", function()
    if SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellEquipped") then
        local res = SellService.RF.SellEquipped:InvokeServer()
        MofenkLog("[MANUAL TEST] SellEquipped Res: " .. tostring(res), "success")
    else
        MofenkLog("[MANUAL TEST] SellEquipped RF Tidak Ditemukan!", "error")
    end
end)

-- TAB 3: TOWER & PLOT
AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Money / Plot Balance", "AutoCollectBalance")
AddToggle(TabTower, "Auto Level Up Slot", "AutoLevelUpSlot")
AddToggle(TabTower, "Auto Interact Slot", "AutoInteractSlot")
AddToggle(TabTower, "Auto Equip Best Plot Units", "AutoEquipBest")

-- TAB 4: UNIT & GEAR
AddSection(TabUnit, "⚔️ UNIT & GEAR MANAGEMENT")
AddToggle(TabUnit, "Auto Equip Unit", "AutoEquipUnit")
AddToggle(TabUnit, "Auto Equip Gear", "AutoEquipGear")
AddToggle(TabUnit, "Auto Fuse Units", "AutoFuse")
AddToggle(TabUnit, "Auto Use Boosts", "AutoUseBoosts")

-- TAB 5: UPGRADE & SHOP
AddSection(TabShop, "🛒 SHOP & DICE UPGRADES")
AddToggle(TabShop, "Auto Buy Dice", "AutoBuyDice")
AddToggle(TabShop, "Auto Buy Upgrades", "AutoBuyUpgrade")

-- TAB 6: PLAYER & UTILS
AddSection(TabPlayer, "🎨 THEME COLOR ACCENT")
local ThemeFrame = Instance.new("Frame")
ThemeFrame.Parent = TabPlayer
ThemeFrame.Size = UDim2.new(1, 0, 0, 36)
ThemeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

local ThCorner = Instance.new("UICorner")
ThCorner.CornerRadius = UDim.new(0, 6)
ThCorner.Parent = ThemeFrame

local ThLayout = Instance.new("UIListLayout")
ThLayout.Parent = ThemeFrame
ThLayout.FillDirection = Enum.FillDirection.Horizontal
ThLayout.Padding = UDim.new(0, 8)
ThLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ThLayout.VerticalAlignment = Enum.VerticalAlignment.Center

for name, color in pairs(Themes) do
    local ColorBtn = Instance.new("TextButton")
    ColorBtn.Parent = ThemeFrame
    ColorBtn.Size = UDim2.new(0, 24, 0, 24)
    ColorBtn.Text = ""
    ColorBtn.BackgroundColor3 = color

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = ColorBtn

    ColorBtn.MouseButton1Click:Connect(function()
        UpdateThemeColor(color)
        MofenkLog("Theme diubah ke: " .. name, "info")
    end)
end

AddSection(TabPlayer, "🤖 PROTECTION & MOVEMENT")
AddToggle(TabPlayer, "Auto AFK (Anti Disconnect)", "AutoAFK")
AddToggle(TabPlayer, "Auto Reconnect", "AutoReconnect")
AddToggle(TabPlayer, "Aktifkan Fly", "EnableFly", function(v)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if v then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "MofenkFlyBV"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        task.spawn(function()
            while _G.Mofenk.EnableFly and hrp:FindFirstChild("MofenkFlyBV") do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.Mofenk.FlySpeed
                task.wait(0.05)
            end
            if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
        end)
    else
        if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
    end
end)

AddButton(TabPlayer, "Copy Server Job ID", function()
    if setclipboard then setclipboard(tostring(game.JobId)) end
    MofenkLog("Job ID disalin ke clipboard!", "success")
end)

AddButton(TabPlayer, "Server Hop", function()
    MofenkLog("Mencari server lain...", "warn")
    local servers = {}
    local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    if req and req.data then
        for _, s in ipairs(req.data) do
            if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end
        end
    end
    if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer) end
end)

-- TAB 7: CONSOLE LOG & DIAGNOSTICS
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

AddToggle(TabConsole, "Real-Time Remote Spy Log", "SpyConsoleLog")

-- 7. FLOATING LOGO TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
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

local TogStroke = Instance.new("UIStroke")
TogStroke.Thickness = 2
TogStroke.Color = CurrentTheme
TogStroke.Parent = ToggleBtn
table.insert(ThemeStrokes, TogStroke)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 8. FPS & PING STATS ENGINE
local frameCount = 0
local lastTime = tick()
local currentFPS = 60

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        currentFPS = frameCount
        frameCount = 0
        lastTime = now
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            StatsLabel.Text = string.format("FPS: %d | Ping: %d ms", currentFPS, ping)
        end)
    end
end)

-- 9. ANTI-AFK ENGINE
LocalPlayer.Idled:Connect(function()
    if _G.Mofenk.AutoAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- 10. DIAGNOSTIC MAIN AUTOMATION ENGINE
task.spawn(function()
    MofenkLog("MofenkHub V4.0 Berhasil Dijalankan!", "success")
    while task.wait(0.5) do
        -- AUTO SELL INVENTORY (WITH DIAGNOSTIC LOG)
        if _G.Mofenk.AutoSellInventory then
            if SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellInventory") then
                local success, result = pcall(function()
                    return SellService.RF.SellInventory:InvokeServer()
                end)
                if success then
                    MofenkLog("[AUTO SELL INVENTORY] Result: " .. tostring(result), "success")
                else
                    MofenkLog("[AUTO SELL INVENTORY] Error: " .. tostring(result), "error")
                end
            else
                MofenkLog("SellService.RF.SellInventory tidak terdeteksi!", "error")
            end
        end

        -- AUTO SELL EQUIPPED (WITH DIAGNOSTIC LOG)
        if _G.Mofenk.AutoSellEquipped then
            if SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellEquipped") then
                local success, result = pcall(function()
                    return SellService.RF.SellEquipped:InvokeServer()
                end)
                if success then
                    MofenkLog("[AUTO SELL EQUIPPED] Result: " .. tostring(result), "success")
                else
                    MofenkLog("[AUTO SELL EQUIPPED] Error: " .. tostring(result), "error")
                end
            else
                MofenkLog("SellService.RF.SellEquipped tidak terdeteksi!", "error")
            end
        end

        -- AUTO ROLL
        if _G.Mofenk.AutoRoll and RollService then
            pcall(function()
                if RollService:FindFirstChild("RF") and RollService.RF:FindFirstChild("RollDice") then
                    RollService.RF.RollDice:InvokeServer()
                elseif RollService:FindFirstChild("RE") and RollService.RE:FindFirstChild("SetAutoRoll") then
                    RollService.RE.SetAutoRoll:FireServer(true)
                end
            end)
        end

        -- AUTO COLLECT BALANCE
        if _G.Mofenk.AutoCollectBalance and PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("CollectBalance") then
            pcall(function() PlotService.RE.CollectBalance:FireServer() end)
        end

        -- AUTO LEVEL UP SLOT
        if _G.Mofenk.AutoLevelUpSlot and PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("LevelUpSlot") then
            pcall(function() PlotService.RE.LevelUpSlot:FireServer() end)
        end

        -- AUTO EQUIP BEST
        if _G.Mofenk.AutoEquipBest and PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("EquipBest") then
            pcall(function() PlotService.RE.EquipBest:FireServer() end)
        end
    end
end)
