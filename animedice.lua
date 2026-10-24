-- =====================================================================
-- 👑 MOFENKHUB V9.0 — SMART NOTIFICATION & DEEP SPY INSPECTOR EDITION
-- Game: Anime Dice | Smart Toast Popups, Click-to-Spy, Fuzzy Resolver & Resizable UI
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
    if v.Name == "MofenkUltraHubV9" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
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
    SelectedRemoteForDebug = "sell",
    CustomPayloadInput = '"All"',
    
    -- Feature Toggles
    AutoRoll = false,
    AutoSellInventory = false,
    AutoSellEquipped = false,
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
    
    -- Fade In Animation
    TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Auto Destroy Fade Out
    task.delay(duration, function()
        if Card and Card.Parent then
            local fadeOut = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                Card:Destroy()
            end)
        end
    end)
end

-- 5. SERIALIZER & DUMP TABLE ENGINE
local function DumpTable(tbl, maxDepth, currentDepth)
    currentDepth = currentDepth or 1
    maxDepth = maxDepth or 3
    if type(tbl) ~= "table" then return tostring(tbl) end
    if currentDepth > maxDepth then return "{...}" end

    local str = "{"
    local first = true
    for k, v in pairs(tbl) do
        if not first then str = str .. ", " end
        first = false
        local keyStr = tostring(k)
        local valStr
        if type(v) == "table" then
            valStr = DumpTable(v, maxDepth, currentDepth + 1)
        elseif type(v) == "string" then
            valStr = '"' .. v .. '"'
        elseif typeof(v) == "Instance" then
            valStr = "<" .. v.Name .. ">"
        else
            valStr = tostring(v)
        end
        str = str .. keyStr .. "=" .. valStr
    end
    return str .. "}"
end

-- 6. AUTO FUZZY REMOTE RESOLVER
local function FindRemoteFuzzy(keyword)
    if not keyword or keyword == "" then return nil end
    local searchKey = keyword:lower()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find(searchKey) then
                return obj
            end
        end
    end
    return nil
end

-- 7. REAL-TIME LOGGING ENGINE 📝
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

-- 8. REAL-TIME NETWORK SPY HOOK (__NAMECALL)
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                local parsedArgs = {}
                for i, arg in ipairs(args) do
                    table.insert(parsedArgs, type(arg) == "table" and DumpTable(arg) or tostring(arg))
                end
                local argStr = #parsedArgs > 0 and table.concat(parsedArgs, ", ") or "None"
                
                if _G.Mofenk.SpyConsoleLog then
                    MofenkLog(string.format("📡 [SPY] %s | %s(%s)", self.Name, method, argStr), "send")
                end
                MofenkNotify("📡 SPY DETECTED", string.format("%s (%s)\nArgs: %s", self.Name, method, argStr:sub(1, 40)), "spy", 2.5)
            end)

            if method == "InvokeServer" then
                local startTime = tick()
                local results = {oldNamecall(self, ...)}
                local elapsed = math.floor((tick() - startTime) * 1000)
                task.spawn(function()
                    local parsedRes = {}
                    for i, res in ipairs(results) do
                        table.insert(parsedRes, type(res) == "table" and DumpTable(res) or tostring(res))
                    end
                    local resStr = #parsedRes > 0 and table.concat(parsedRes, ", ") or "Nil"
                    MofenkLog(string.format("📥 [RETURN %dms] %s -> %s", elapsed, self.Name, resStr), "return")
                end)
                return unpack(results)
            end
        end
        return oldNamecall(self, ...)
    end))
end

-- 9. CLICK-TO-INSPECT USER INPUT LISTENER
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not _G.Mofenk.ClickInspectEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local guiObjects = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
        
        if #guiObjects > 0 then
            for i, obj in ipairs(guiObjects) do
                if not obj:IsDescendantOf(parentGui:FindFirstChild("MofenkUltraHubV9")) and not obj:IsDescendantOf(NotifyGui) then
                    local textVal = (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.Text or ""
                    local info = string.format("UI: %s [%s]\nPath: %s", obj.Name, obj.ClassName, textVal ~= "" and ("Text: " .. textVal) or obj.Name)
                    
                    MofenkLog("🔍 [CLICK INSPECT] " .. info, "inspect")
                    MofenkNotify("🔍 CLICK INSPECTED", string.format("%s (%s)\n%s", obj.Name, obj.ClassName, textVal), "inspect", 3)
                    break
                end
            end
        end
    end
end)

-- 10. MAIN UI BUILDER (DRAGGABLE + RESIZABLE)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV9"
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
TitleLabel.Size = UDim2.new(0, 220, 1, 0)
TitleLabel.Text = "MOFENKHUB V9.0 — SMART HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = TopBar
StatsLabel.Position = UDim2.new(0, 240, 0, 0)
StatsLabel.Size = UDim2.new(0, 220, 1, 0)
StatsLabel.Text = "FPS: -- | Ping: -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(160, 170, 200)
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

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

-- RESIZE HANDLE
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
        local newWidth = math.clamp(startSize.X.Offset + delta.X, 460, 900)
        local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 300, 650)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

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
local TabHome     = CreateTab("🏠 Home & Profil", 1)
local TabDebug    = CreateTab("🛠️ Remote Debugger", 2)
local TabFarm     = CreateTab("🌾 Khusus Farm", 3)
local TabTower    = CreateTab("🏰 Tower & Plot", 4)
local TabUnit     = CreateTab("⚔️ Unit & Gear", 5)
local TabShop     = CreateTab("⬆️ Upgrade & Shop", 6)
local TabPlayer   = CreateTab("⚡ Player & Utils", 7)
local TabConsole  = CreateTab("🔍 Console & Log", 8)

TabFrames["🛠️ Remote Debugger"].Visible = true

-- TAB 1: HOME & PROFIL
AddSection(TabHome, "👤 LIVE PROFIL USER")
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Parent = TabHome
ProfileFrame.Size = UDim2.new(1, 0, 0, 64)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

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
        end)
    end
end)

-- TAB 2: INTERACTIVE REMOTE DEBUGGER & SPY
AddSection(TabDebug, "🔍 CLICK-TO-SPY & NOTIFICATIONS")
AddToggle(TabDebug, "Click-to-Spy Mode (Sentuh UI Game)", "ClickInspectEnabled")
AddToggle(TabDebug, "Smart Toast Notifications", "SmartNotifications")

AddSection(TabDebug, "🛠️ FUZZY REMOTE TESTER")

local InputLabel1 = Instance.new("TextLabel")
InputLabel1.Parent = TabDebug
InputLabel1.Size = UDim2.new(1, 0, 0, 16)
InputLabel1.Text = "Kata Kunci Remote (misal: sell, roll, rebirth, equip):"
InputLabel1.TextColor3 = Color3.fromRGB(180, 180, 200)
InputLabel1.TextSize = 10
InputLabel1.Font = Enum.Font.GothamMedium
InputLabel1.TextXAlignment = Enum.TextXAlignment.Left
InputLabel1.BackgroundTransparency = 1

local RemoteBox = Instance.new("TextBox")
RemoteBox.Parent = TabDebug
RemoteBox.Size = UDim2.new(1, 0, 0, 30)
RemoteBox.Text = _G.Mofenk.SelectedRemoteForDebug
RemoteBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RemoteBox.TextSize = 11
RemoteBox.Font = Enum.Font.Code
RemoteBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

local RBoxCorner = Instance.new("UICorner")
RBoxCorner.CornerRadius = UDim.new(0, 6)
RBoxCorner.Parent = RemoteBox

RemoteBox.FocusLost:Connect(function()
    _G.Mofenk.SelectedRemoteForDebug = RemoteBox.Text
end)

local InputLabel2 = Instance.new("TextLabel")
InputLabel2.Parent = TabDebug
InputLabel2.Size = UDim2.new(1, 0, 0, 16)
InputLabel2.Text = "Payload Custom (contoh: \"All\", true, 1, nil):"
InputLabel2.TextColor3 = Color3.fromRGB(180, 180, 200)
InputLabel2.TextSize = 10
InputLabel2.Font = Enum.Font.GothamMedium
InputLabel2.TextXAlignment = Enum.TextXAlignment.Left
InputLabel2.BackgroundTransparency = 1

local PayloadBox = Instance.new("TextBox")
PayloadBox.Parent = TabDebug
PayloadBox.Size = UDim2.new(1, 0, 0, 30)
PayloadBox.Text = _G.Mofenk.CustomPayloadInput
PayloadBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PayloadBox.TextSize = 11
PayloadBox.Font = Enum.Font.Code
PayloadBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

local PBoxCorner = Instance.new("UICorner")
PBoxCorner.CornerRadius = UDim.new(0, 6)
PBoxCorner.Parent = PayloadBox

PayloadBox.FocusLost:Connect(function()
    _G.Mofenk.CustomPayloadInput = PayloadBox.Text
end)

AddButton(TabDebug, "🚀 Auto-Resolve & Eksekusi Remote Sekarang", function()
    local keyword = _G.Mofenk.SelectedRemoteForDebug
    local payloadText = _G.Mofenk.CustomPayloadInput
    
    local foundRemote = FindRemoteFuzzy(keyword)
    
    if foundRemote then
        local parsedArg = nil
        if payloadText == "nil" or payloadText == "" then
            parsedArg = nil
        elseif payloadText == "true" then
            parsedArg = true
        elseif payloadText == "false" then
            parsedArg = false
        elseif tonumber(payloadText) then
            parsedArg = tonumber(payloadText)
        else
            parsedArg = payloadText:gsub('"', '')
        end
        
        local startTime = tick()
        if foundRemote:IsA("RemoteFunction") then
            local res = foundRemote:InvokeServer(parsedArg)
            local elapsed = math.floor((tick() - startTime) * 1000)
            MofenkLog(string.format("✅ [INVOKE RETURN %dms] -> %s", elapsed, DumpTable(res)), "success")
            MofenkNotify("REMOTE EXECUTED", string.format("%s (%dms)\nReturn: %s", foundRemote.Name, elapsed, DumpTable(res)), "success", 3.5)
        elseif foundRemote:IsA("RemoteEvent") then
            foundRemote:FireServer(parsedArg)
            MofenkLog("✅ [FIRE OK] RemoteEvent Fired!", "success")
            MofenkNotify("REMOTE FIRED", foundRemote.Name .. " Terkirim!", "success", 3)
        end
    else
        MofenkLog("❌ Remote '" .. keyword .. "' tidak ditemukan!", "error")
        MofenkNotify("REMOTE ERROR", "Remote '" .. keyword .. "' Tidak Ditemukan!", "error", 3)
    end
end)

-- TAB 3: KHUSUS FARM
AddSection(TabFarm, "🎲 AUTOMATED FARMING")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Smart Rebirth (3s Cooldown)", "AutoRebirth")
AddToggle(TabFarm, "Auto Sell Inventory", "AutoSellInventory")
AddToggle(TabFarm, "Auto Sell Equipped", "AutoSellEquipped")

-- TAB 4: TOWER & PLOT
AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Money / Plot Balance", "AutoCollectBalance")
AddToggle(TabTower, "Auto Level Up Slot", "AutoLevelUpSlot")
AddToggle(TabTower, "Auto Interact Slot", "AutoInteractSlot")
AddToggle(TabTower, "Auto Equip Best Plot Units", "AutoEquipBest")

-- TAB 5: UNIT & GEAR
AddSection(TabUnit, "⚔️ UNIT & GEAR MANAGEMENT")
AddToggle(TabUnit, "Auto Equip Unit", "AutoEquipUnit")
AddToggle(TabUnit, "Auto Equip Gear", "AutoEquipGear")
AddToggle(TabUnit, "Auto Fuse Units", "AutoFuse")
AddToggle(TabUnit, "Auto Use Boosts", "AutoUseBoosts")

-- TAB 6: UPGRADE & SHOP
AddSection(TabShop, "🛒 SHOP & DICE UPGRADES")
AddToggle(TabShop, "Auto Buy Dice", "AutoBuyDice")
AddToggle(TabShop, "Auto Buy Upgrades", "AutoBuyUpgrade")

-- TAB 7: PLAYER & UTILS
AddSection(TabPlayer, "🎨 THEME COLOR ACCENT")
local ThemeFrame = Instance.new("Frame")
ThemeFrame.Parent = TabPlayer
ThemeFrame.Size = UDim2.new(1, 0, 0, 36)
ThemeFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

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
        MofenkNotify("THEME UPDATED", "Warna aksen diubah ke " .. name, "success", 2)
    end)
end

AddSection(TabPlayer, "🤖 PROTECTION & MOVEMENT")
AddToggle(TabPlayer, "Auto AFK (Anti Disconnect)", "AutoAFK")
AddToggle(TabPlayer, "Auto Reconnect", "AutoReconnect")

-- TAB 8: CONSOLE LOG & DIAGNOSTICS
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

-- FLOATING LOGO TOGGLE BUTTON
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

local TogStroke = Instance.new("UIStroke")
TogStroke.Thickness = 2
TogStroke.Color = CurrentTheme
TogStroke.Parent = ToggleBtn
table.insert(ThemeStrokes, TogStroke)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- FPS & PING MONITOR
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

-- ANTI-AFK ENGINE
LocalPlayer.Idled:Connect(function()
    if _G.Mofenk.AutoAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- AUTOMATION ENGINE
task.spawn(function()
    MofenkNotify("MOFENKHUB V9.0", "Script Berhasil Dijalankan!", "success", 3)
    while task.wait(0.5) do
        if _G.Mofenk.AutoSellInventory then
            local r = FindRemoteFuzzy("SellInventory")
            if r and r:IsA("RemoteFunction") then
                pcall(function() r:InvokeServer() end)
            end
        end
    end
end)
