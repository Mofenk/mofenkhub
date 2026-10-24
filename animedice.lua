-- =====================================================================
-- 👑 MOFENKHUB V2.0 — PURE CUSTOM UI EDITION (SPECTRUM / OUROBOROS STYLE)
-- 100% Standalone Pure Lua (Tanpa External Loadstring Library)
-- Compatible: Delta, Delta Lite, Hydrogen, UgPhone, vsphone
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

-- 1. PEMBERSIHAN UI LAMA
local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkCustomHub" or v.Name == "MofenkToggleGui" then 
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
    AutoBuyUpgrade = false,
    CodeToRedeem = "",
    
    EnableFly = false, FlySpeed = 50,
    EnableWalkSpeed = false, WalkSpeedVal = 16
}

-- 3. THEME SYSTEM (WARNA AKSEN)
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

-- 4. REMOTE SERVICES PATH
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

-- 5. REAL-TIME NETWORK SPY
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
                    print(string.format("[SPY DETECTED] Remote: %s | Method: %s | Args: %s", self.Name, method, argStr))
                end
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 6. PURE CUSTOM GUI FRAMEWORK BUILDER
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkCustomHub"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

-- Main Container Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 540, 0, 360)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
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

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Text = "MOFENKHUB V2.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- FPS & Ping Stats Bar (Spectrum Style)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = TopBar
StatsLabel.Position = UDim2.new(0, 180, 0, 0)
StatsLabel.Size = UDim2.new(0, 220, 1, 0)
StatsLabel.Text = "FPS: -- | Ping: -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
StatsLabel.TextSize = 12
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close / Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -38, 0, 7)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Sidebar Tab Container
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 50)
Sidebar.Size = UDim2.new(0, 130, 1, -58)
Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Sidebar.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 5)

-- Content Area Frame
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 146, 0, 50)
ContentArea.Size = UDim2.new(1, -154, 1, -58)
ContentArea.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
ContentArea.BorderSizePixel = 0

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentArea

-- TAB CREATION LOGIC
local Tabs = {}
local TabFrames = {}

local function CreateTab(tabName, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = Sidebar
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.Text = "  " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
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
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            end
        end
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    end)

    return TabScroll
end

-- HELPER FUNCTIONS FOR UI COMPONENTS
local function AddSection(parent, titleText)
    local SecLabel = Instance.new("TextLabel")
    SecLabel.Parent = parent
    SecLabel.Size = UDim2.new(1, 0, 0, 22)
    SecLabel.Text = titleText
    SecLabel.TextColor3 = CurrentTheme
    SecLabel.TextSize = 12
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    SecLabel.BackgroundTransparency = 1
    table.insert(ThemeStrokes, SecLabel)
end

local function AddToggle(parent, text, flag, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton")
    Switch.Parent = Frame
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Text = ""
    Switch.BackgroundColor3 = _G.Mofenk[flag] and CurrentTheme or Color3.fromRGB(50, 50, 65)

    local SwCorner = Instance.new("UICorner")
    SwCorner.CornerRadius = UDim.new(1, 0)
    SwCorner.Parent = Switch

    Switch.MouseButton1Click:Connect(function()
        _G.Mofenk[flag] = not _G.Mofenk[flag]
        Switch.BackgroundColor3 = _G.Mofenk[flag] and CurrentTheme or Color3.fromRGB(50, 50, 65)
        if callback then callback(_G.Mofenk[flag]) end
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- TAB BUILDERS
local TabHome = CreateTab("🏠 Live Data", 1)
local TabMain = CreateTab("🎲 Main & Farm", 2)
local TabUnits = CreateTab("✨ Units & Gear", 3)
local TabUtils = CreateTab("⚡ Utilities", 4)
local TabSpy = CreateTab("🔍 Spy & Scan", 5)

-- Default Active Tab
TabFrames["🏠 Live Data"].Visible = true

-- TAB 1: HOME & LIVE PROFILE & AVATAR
AddSection(TabHome, "👤 LIVE PROFIL USER")
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Parent = TabHome
ProfileFrame.Size = UDim2.new(1, 0, 0, 64)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)

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
StatsTextLabel.Size = UDim2.new(1, 0, 0, 60)
StatsTextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatsTextLabel.TextSize = 11
StatsTextLabel.Font = Enum.Font.GothamMedium
StatsTextLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsTextLabel.BackgroundTransparency = 1

AddSection(TabHome, "📦 LIVE INVENTORY & TOOLS")
local InvTextLabel = Instance.new("TextLabel")
InvTextLabel.Parent = TabHome
InvTextLabel.Size = UDim2.new(1, 0, 0, 80)
InvTextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InvTextLabel.TextSize = 11
InvTextLabel.Font = Enum.Font.GothamMedium
InvTextLabel.TextXAlignment = Enum.TextXAlignment.Left
InvTextLabel.BackgroundTransparency = 1

-- REALTIME PROFILE UPDATER LOOP
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            ProfLabel.Text = string.format("USN: %s | ID: %d\nDisplay: %s\nAge: %d Hari", LocalPlayer.Name, LocalPlayer.UserId, LocalPlayer.DisplayName, LocalPlayer.AccountAge or 0)
            
            local st = ""
            if LocalPlayer:FindFirstChild("leaderstats") then
                for _, s in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                    st = st .. string.format("• %s: %s\n", s.Name, tostring(s.Value))
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

-- TAB 2: MAIN & FARM
AddSection(TabMain, "🎲 ROLL & REBIRTH")
AddToggle(TabMain, "Auto Roll Dice", "AutoRoll")
AddToggle(TabMain, "Auto Rebirth", "AutoRebirth")

AddSection(TabMain, "🏡 PLOT & UPGRADES")
AddToggle(TabMain, "Auto Collect Plot Balance", "AutoCollectBalance")
AddToggle(TabMain, "Auto Level Up Plot Slot", "AutoLevelUpSlot")
AddToggle(TabMain, "Auto Interact Slot", "AutoInteractSlot")
AddToggle(TabMain, "Auto Equip Best Plot Units", "AutoEquipBest")

AddSection(TabMain, "🛒 SHOP & SELL")
AddToggle(TabMain, "Auto Buy Dice", "AutoBuyDice")
AddToggle(TabMain, "Auto Buy Upgrades", "AutoBuyUpgrade")
AddToggle(TabMain, "Auto Sell Inventory", "AutoSellInventory")

AddSection(TabMain, "🎁 QUESTS & REWARDS")
AddToggle(TabMain, "Auto Claim Quests", "AutoClaimQuests")
AddToggle(TabMain, "Auto Claim Daily / Group Rewards", "AutoClaimRewards")

-- TAB 3: UNITS & GEAR
AddSection(TabUnits, "✨ UNITS & GEAR")
AddToggle(TabUnits, "Auto Equip Unit", "AutoEquipUnit")
AddToggle(TabUnits, "Auto Equip Gear", "AutoEquipGear")
AddToggle(TabUnits, "Auto Fuse Units", "AutoFuse")
AddToggle(TabUnits, "Auto Use Boosts", "AutoUseBoosts")

-- TAB 4: UTILITIES & THEME COLOR SWITCHER
AddSection(TabUtils, "🎨 THEME COLOR ACCENT")
local ThemeFrame = Instance.new("Frame")
ThemeFrame.Parent = TabUtils
ThemeFrame.Size = UDim2.new(1, 0, 0, 36)
ThemeFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)

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
    end)
end

AddSection(TabUtils, "🤖 PROTECTION & MOVEMENT")
AddToggle(TabUtils, "Auto AFK (Anti Disconnect)", "AutoAFK")
AddToggle(TabUtils, "Auto Reconnect", "AutoReconnect")
AddToggle(TabUtils, "Aktifkan Fly", "EnableFly", function(v)
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

AddButton(TabUtils, "Copy Server Job ID", function()
    if setclipboard then setclipboard(tostring(game.JobId)) end
end)

AddButton(TabUtils, "Server Hop", function()
    local servers = {}
    local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    if req and req.data then
        for _, s in ipairs(req.data) do
            if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end
        end
    end
    if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer) end
end)

-- TAB 5: SPY & SCANNER
AddSection(TabSpy, "📡 SPY & SCANNER")
AddToggle(TabSpy, "Real-Time Spy Console Log", "SpyConsoleLog")
AddButton(TabSpy, "Scan Game Remotes (Cek Console F9)", function()
    for i, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print(string.format("[%d] %s (%s) -> %s", i, v.Name, v.ClassName, v:GetFullName()))
        end
    end
end)

-- 7. FLOATING LOGO TOGGLE BUTTON (DRAGGABLE)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
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

-- 9. ANTI-AFK & AUTOMATION ENGINE
LocalPlayer.Idled:Connect(function()
    if _G.Mofenk.AutoAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

task.spawn(function()
    while task.wait(0.25) do
        pcall(function()
            if _G.Mofenk.AutoRoll and RollService then
                if RollService:FindFirstChild("RF") and RollService.RF:FindFirstChild("RollDice") then RollService.RF.RollDice:InvokeServer() end
            end
            if _G.Mofenk.AutoRebirth and RebirthService then RebirthService.RE.Rebirth:FireServer() end
            if _G.Mofenk.AutoCollectBalance and PlotService then PlotService.RE.CollectBalance:FireServer() end
            if _G.Mofenk.AutoLevelUpSlot and PlotService then PlotService.RE.LevelUpSlot:FireServer() end
            if _G.Mofenk.AutoInteractSlot and PlotService then PlotService.RE.InteractSlot:FireServer() end
            if _G.Mofenk.AutoEquipBest and PlotService then PlotService.RE.EquipBest:FireServer() end
            if _G.Mofenk.AutoEquipUnit and UnitService then UnitService.RF.Equip:InvokeServer() end
            if _G.Mofenk.AutoEquipGear and GearService then GearService.RE.Equip:FireServer() end
            if _G.Mofenk.AutoFuse and FusingService then FusingService.RE.Fuse:FireServer() end
            if _G.Mofenk.AutoUseBoosts and BoostService then BoostService.RE.Use:FireServer() end
            if _G.Mofenk.AutoBuyDice and DiceShopService then DiceShopService.RE.BuyDice:FireServer() end
            if _G.Mofenk.AutoBuyUpgrade and Network then Network.RE.BuyUpgrade:FireServer() end
            if _G.Mofenk.AutoSellInventory and SellService then SellService.RF.SellInventory:InvokeServer() end
            if _G.Mofenk.AutoClaimQuests and QuestService then QuestService.RE.Claim:FireServer() end
            if _G.Mofenk.AutoClaimRewards then
                if DailyRewardService then DailyRewardService.RE.Claim:FireServer() end
                if OfflineEarningsService then OfflineEarningsService.RE.Claim:FireServer() end
                if GroupRewardService then GroupRewardService.RE.Claim:FireServer() end
            end
        end)
    end
end)
