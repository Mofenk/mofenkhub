-- =====================================================================
-- 👑 MOFENKHUB V3.0 — RAYFIELD & OUROBOROS HYBRID ULTRA EDITION
-- 100% Standalone Pure Lua Script (No Loadstring / Anti HTTP 404 Error)
-- Compatible: Delta, Delta Lite, UgPhone, vsphone, Hydrogen, Codex
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI SISA DARI RUN SEBELUMNYA
local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHub" or v.Name == "MofenkToggleGui" then 
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
    SelectedDiceType = "Basic",
    AutoBuyUpgrade = false,
    CodeToRedeem = "",
    
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

-- 4. PATH REMOTE EVENT & FUNCTION (SAFE RESOLVER)
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

-- 5. IN-UI LIVE CONSOLE LOGGING ENGINE 📝
local LogScroll = nil
local function MofenkLog(msg, isError)
    local timestamp = os.date("%H:%M:%S")
    local formattedMsg = string.format("[%s] %s", timestamp, tostring(msg))
    print(formattedMsg)
    
    if LogScroll and LogScroll.Parent then
        local LogItem = Instance.new("TextLabel")
        LogItem.Parent = LogScroll
        LogItem.Size = UDim2.new(1, -10, 0, 18)
        LogItem.Text = formattedMsg
        LogItem.TextColor3 = isError and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(180, 220, 255)
        LogItem.TextSize = 11
        LogItem.Font = Enum.Font.Code
        LogItem.TextXAlignment = Enum.TextXAlignment.Left
        LogItem.BackgroundTransparency = 1
        
        LogScroll.CanvasPosition = Vector2.new(0, 99999)
    end
end

-- 6. REAL-TIME NETWORK SPY HOOK (__NAMECALL)
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                local argStr = ""
                for i, arg in ipairs(args) do
                    argStr = argStr .. string.format("[%d]: %s (%s) | ", i, tostring(arg), typeof(arg))
                end
                if _G.Mofenk.SpyConsoleLog then
                    MofenkLog(string.format("📡 [SPY] Remote: %s | Method: %s | Args: %s", self.Name, method, argStr), false)
                end
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 7. PURE CUSTOM RAYFIELD / OUROBOROS HYBRID GUI FRAMEWORK
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHub"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

-- Main Container Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = CurrentTheme
MainStroke.Parent = MainFrame
table.insert(ThemeStrokes, MainStroke)

-- Header Top Bar (Ouroboros / Rayfield Design)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Text = "MOFENKHUB V3.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- FPS & Ping Counter (Spectrum Style Monitor)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = TopBar
StatsLabel.Position = UDim2.new(0, 190, 0, 0)
StatsLabel.Size = UDim2.new(0, 260, 1, 0)
StatsLabel.Text = "FPS: -- | Ping: -- ms | Status: Active"
StatsLabel.TextColor3 = Color3.fromRGB(160, 170, 200)
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close / Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -40, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 44)

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Sidebar Tabs Container
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 52)
Sidebar.Size = UDim2.new(0, 140, 1, -60)
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
ContentArea.Position = UDim2.new(0, 154, 0, 52)
ContentArea.Size = UDim2.new(1, -162, 1, -60)
ContentArea.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ContentArea.BorderSizePixel = 0

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentArea

-- TAB SYSTEM CREATION
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
        MofenkLog("Feature [" .. text .. "] set to: " .. tostring(_G.Mofenk[flag]), false)
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
local TabConsole= CreateTab("🔍 Spy & Console", 7)

-- Set Default Tab
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
StatsTextLabel.Size = UDim2.new(1, 0, 0, 50)
StatsTextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatsTextLabel.TextSize = 11
StatsTextLabel.Font = Enum.Font.GothamMedium
StatsTextLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsTextLabel.BackgroundTransparency = 1

AddSection(TabHome, "📦 LIVE INVENTORY & ITEMS")
local InvTextLabel = Instance.new("TextLabel")
InvTextLabel.Parent = TabHome
InvTextLabel.Size = UDim2.new(1, 0, 0, 50)
InvTextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InvTextLabel.TextSize = 11
InvTextLabel.Font = Enum.Font.GothamMedium
InvTextLabel.TextXAlignment = Enum.TextXAlignment.Left
InvTextLabel.BackgroundTransparency = 1

-- REALTIME PROFILE LOOP
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

-- TAB 2: KHUSUS FARM
AddSection(TabFarm, "🎲 AUTOMATED FARMING")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Auto Sell Inventory", "AutoSellInventory")
AddToggle(TabFarm, "Smart Rebirth (Anti-Spam Cooldown)", "AutoRebirth")

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
        MofenkLog("Theme changed to: " .. name, false)
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
    MofenkLog("Job ID disalin ke clipboard!", false)
end)

AddButton(TabPlayer, "Server Hop", function()
    MofenkLog("Mencari server lain...", false)
    local servers = {}
    local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    if req and req.data then
        for _, s in ipairs(req.data) do
            if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end
        end
    end
    if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer) end
end)

-- TAB 7: SPY & CONSOLE LOG
AddSection(TabConsole, "📝 LIVE IN-UI CONSOLE LOG")
LogScroll = Instance.new("ScrollingFrame")
LogScroll.Parent = TabConsole
LogScroll.Size = UDim2.new(1, 0, 0, 180)
LogScroll.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 4

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 6)
LogCorner.Parent = LogScroll

local LogLayout = Instance.new("UIListLayout")
LogLayout.Parent = LogScroll
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 2)

AddToggle(TabConsole, "Real-Time Remote Spy", "SpyConsoleLog")
AddButton(TabConsole, "Scan All Remotes to F9 Console", function()
    MofenkLog("--- MEMULAI REMOTE SCANNER ---", false)
    for i, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            MofenkLog(string.format("[%d] %s (%s)", i, v.Name, v.ClassName), false)
        end
    end
end)

-- 8. FLOATING LOGO TOGGLE BUTTON
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

-- 9. FPS & PING STATS ENGINE
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
            StatsLabel.Text = string.format("FPS: %d | Ping: %d ms | MofenkHub Active", currentFPS, ping)
        end)
    end
end)

-- 10. ANTI-AFK ENGINE
LocalPlayer.Idled:Connect(function()
    if _G.Mofenk.AutoAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- 11. SMART AUTOMATION & REMOTE EXECUTION ENGINE (WITH ERROR DIAGNOSTICS)
local lastRebirthTime = 0

task.spawn(function()
    MofenkLog("MofenkHub V3.0 Berhasil Dijalankan!", false)
    while task.wait(0.25) do
        -- AUTO ROLL
        if _G.Mofenk.AutoRoll then
            if RollService then
                local success, err = pcall(function()
                    if RollService:FindFirstChild("RF") and RollService.RF:FindFirstChild("RollDice") then
                        RollService.RF.RollDice:InvokeServer()
                    elseif RollService:FindFirstChild("RE") and RollService.RE:FindFirstChild("SetAutoRoll") then
                        RollService.RE.SetAutoRoll:FireServer(true)
                    end
                end)
                if not success then MofenkLog("AutoRoll Error: " .. tostring(err), true) end
            else
                MofenkLog("RollService tidak ditemukan!", true)
            end
        end

        -- SMART REBIRTH (WITH 3S COOLDOWN TO PREVENT SPAMMING)
        if _G.Mofenk.AutoRebirth then
            if tick() - lastRebirthTime >= 3 then
                lastRebirthTime = tick()
                if RebirthService and RebirthService:FindFirstChild("RE") and RebirthService.RE:FindFirstChild("Rebirth") then
                    local success, err = pcall(function() RebirthService.RE.Rebirth:FireServer() end)
                    if success then
                        MofenkLog("Smart Rebirth Fired!", false)
                    else
                        MofenkLog("Rebirth Error: " .. tostring(err), true)
                    end
                else
                    MofenkLog("Rebirth Remote tidak terdeteksi!", true)
                end
            end
        end

        -- AUTO COLLECT BALANCE (TOWER / PLOT)
        if _G.Mofenk.AutoCollectBalance then
            if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("CollectBalance") then
                pcall(function() PlotService.RE.CollectBalance:FireServer() end)
            end
        end

        -- AUTO LEVEL UP SLOT
        if _G.Mofenk.AutoLevelUpSlot then
            if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("LevelUpSlot") then
                pcall(function() PlotService.RE.LevelUpSlot:FireServer() end)
            end
        end

        -- AUTO INTERACT SLOT
        if _G.Mofenk.AutoInteractSlot then
            if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("InteractSlot") then
                pcall(function() PlotService.RE.InteractSlot:FireServer() end)
            end
        end

        -- AUTO EQUIP BEST PLOT UNITS
        if _G.Mofenk.AutoEquipBest then
            if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("EquipBest") then
                pcall(function() PlotService.RE.EquipBest:FireServer() end)
            end
        end

        -- AUTO EQUIP UNIT
        if _G.Mofenk.AutoEquipUnit then
            if UnitService and UnitService:FindFirstChild("RF") and UnitService.RF:FindFirstChild("Equip") then
                pcall(function() UnitService.RF.Equip:InvokeServer() end)
            end
        end

        -- AUTO EQUIP GEAR
        if _G.Mofenk.AutoEquipGear then
            if GearService and GearService:FindFirstChild("RE") and GearService.RE:FindFirstChild("Equip") then
                pcall(function() GearService.RE.Equip:FireServer() end)
            end
        end

        -- AUTO BUY DICE
        if _G.Mofenk.AutoBuyDice then
            if DiceShopService and DiceShopService:FindFirstChild("RE") and DiceShopService.RE:FindFirstChild("BuyDice") then
                pcall(function() DiceShopService.RE.BuyDice:FireServer() end)
            end
        end

        -- AUTO SELL INVENTORY
        if _G.Mofenk.AutoSellInventory then
            if SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellInventory") then
                pcall(function() SellService.RF.SellInventory:InvokeServer() end)
            end
        end
    end
end)
