-- ===================================================================== --
-- 👑 MOFENKHUB V104.0 — ULTIMATE EDITION (SMOOTH ANIMATIONS & THEMES)
-- ===================================================================== --

--!nocheck
task.wait(0.2)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local GuiService        = game:GetService("GuiService")
local Stats             = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ===================================================================== --
-- 1. AUTO EXECUTE ON TELEPORT
-- ===================================================================== --
local SCRIPT_URL = "https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/animedice.lua"
local AUTOEXEC_CODE = string.format([[
    task.wait(3)
    loadstring(game:HttpGet("%s"))()
]], SCRIPT_URL)

local function armAutoExec()
    local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(qot, AUTOEXEC_CODE)
    end
end
armAutoExec()

-- Safe Parent GUI Setup
local successGui, parentGui = pcall(function()
    if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- Safe Wait for Client Boot
if not game:IsLoaded() then
    local t0 = os.clock()
    while not game:IsLoaded() and os.clock() - t0 < 30 do task.wait(0.2) end
end
if not LocalPlayer then
    local t0 = os.clock()
    while not LocalPlayer and os.clock() - t0 < 30 do
        task.wait(0.2)
        pcall(function() LocalPlayer = Players.LocalPlayer end)
    end
end

_G.__MOFENKHUB = (_G.__MOFENKHUB or 0) + 1
local generation = _G.__MOFENKHUB

-- ===================================================================== --
-- 2. THEMES & CONFIGURATION MANAGER
-- ===================================================================== --
local THEMES = {
    ["Glass Blue"] = {
        Bg      = Color3.fromRGB(11, 19, 36),
        Card    = Color3.fromRGB(20, 32, 58),
        Header  = Color3.fromRGB(15, 23, 42),
        Acc1    = Color3.fromRGB(59, 130, 246),
        Acc2    = Color3.fromRGB(37, 99, 235),
        Text    = Color3.fromRGB(241, 245, 249),
        SubText = Color3.fromRGB(148, 163, 184)
    },
    ["Cyberpunk Purple"] = {
        Bg      = Color3.fromRGB(20, 10, 30),
        Card    = Color3.fromRGB(38, 20, 56),
        Header  = Color3.fromRGB(28, 14, 42),
        Acc1    = Color3.fromRGB(168, 85, 247),
        Acc2    = Color3.fromRGB(147, 51, 234),
        Text    = Color3.fromRGB(250, 245, 255),
        SubText = Color3.fromRGB(192, 132, 252)
    },
    ["AMOLED Black"] = {
        Bg      = Color3.fromRGB(10, 10, 10),
        Card    = Color3.fromRGB(22, 22, 22),
        Header  = Color3.fromRGB(16, 16, 16),
        Acc1    = Color3.fromRGB(255, 255, 255),
        Acc2    = Color3.fromRGB(200, 200, 200),
        Text    = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 150, 150)
    },
    ["Emerald Green"] = {
        Bg      = Color3.fromRGB(6, 28, 20),
        Card    = Color3.fromRGB(14, 48, 36),
        Header  = Color3.fromRGB(10, 38, 28),
        Acc1    = Color3.fromRGB(16, 185, 129),
        Acc2    = Color3.fromRGB(5, 150, 105),
        Text    = Color3.fromRGB(236, 253, 245),
        SubText = Color3.fromRGB(110, 231, 183)
    }
}

local F = {
    cfgName = "MofenkConfig1", autoLoadEnabled = false,
    selectedTheme = "Glass Blue",
    toggleKey = Enum.KeyCode.RightControl.Name,
    -- Server & Hop
    autoHop40 = false, hopInterval = 2400,
    -- System & Character
    wsOn = false, wsValue = 16, flyOn = false, flySpeed = 50, noclip = false,
    afk = true, autoReconnect = true, fpsOn = false,
    spyHook = false,
    -- Webhook
    webhookEnabled = false, webhookUrl = ""
}

local STATE = {
    pingMs = 0, fpsCurrent = 60,
    hopTimeRemaining = 2400
}

local ConfigUpdaters = {}
local ThemeElements = { Strokes = {}, Cards = {}, Headers = {}, Accents = {}, Texts = {}, SubTexts = {}, Backgrounds = {} }

local GLASS_THEME = THEMES["Glass Blue"]

local function UpdateTheme(themeName)
    if not THEMES[themeName] then return end
    GLASS_THEME = THEMES[themeName]
    F.selectedTheme = themeName

    for _, v in ipairs(ThemeElements.Backgrounds) do v.BackgroundColor3 = GLASS_THEME.Bg end
    for _, v in ipairs(ThemeElements.Cards) do v.BackgroundColor3 = GLASS_THEME.Card end
    for _, v in ipairs(ThemeElements.Headers) do v.BackgroundColor3 = GLASS_THEME.Header end
    for _, v in ipairs(ThemeElements.Accents) do if v:IsA("UIStroke") then v.Color = GLASS_THEME.Acc1 elseif v:IsA("TextLabel") or v:IsA("TextButton") then v.TextColor3 = GLASS_THEME.Acc1 else v.BackgroundColor3 = GLASS_THEME.Acc1 end end
    for _, v in ipairs(ThemeElements.Texts) do v.TextColor3 = GLASS_THEME.Text end
    for _, v in ipairs(ThemeElements.SubTexts) do v.TextColor3 = GLASS_THEME.SubText end
end

local CFG_FOLDER = "MofenkHub_GAG_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end

local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or F.cfgName or "DefaultConfig") .. ".json" end

local function saveConfig(name)
    if writefile then
        pcall(function() 
            writefile(getCfgPath(name), HttpService:JSONEncode(F)) 
            local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
            if F.autoLoadEnabled then
                writefile(pointerPath, name or F.cfgName or "DefaultConfig")
            else
                if isfile and isfile(pointerPath) then delfile(pointerPath) end
            end
        end)
    end
end

local function loadConfig(name)
    local path = getCfgPath(name)
    if readfile and isfile and isfile(path) then
        pcall(function() 
            local d = HttpService:JSONDecode(readfile(path))
            for k,v in pairs(d) do F[k]=v end 
            if F.selectedTheme then UpdateTheme(F.selectedTheme) end
            for _, updateUI in ipairs(ConfigUpdaters) do pcall(updateUI) end
        end)
    end
end

pcall(function()
    local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
    if readfile and isfile and isfile(pointerPath) then
        local autoName = readfile(pointerPath)
        if autoName and autoName ~= "" then 
            F.cfgName = autoName
            local d = HttpService:JSONDecode(readfile(getCfgPath(autoName)))
            for k,v in pairs(d) do F[k]=v end 
            F.autoLoadEnabled = true 
            if F.selectedTheme then UpdateTheme(F.selectedTheme) end
        end
    end
end)

local function SendWebhook(title, description, colorCode)
    if not F.webhookEnabled or F.webhookUrl == "" then return end
    local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
    if req then
        pcall(function()
            req({
                Url = F.webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({ username = "MOFENKHUB", avatar_url = "https://i.imgur.com/3qGMB7j.png", embeds = {{ title = title, description = description, color = colorCode or 3447003, footer = {text = "Player: " .. LocalPlayer.Name} }} })
            })
        end)
    end
end

-- ===================================================================== --
-- 3. INTERACTIVE LOGO "M" & TOAST NOTIFICATION SYSTEM
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 62, 0, 62); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = GLASS_THEME.Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 32; ToggleBtn.TextColor3 = GLASS_THEME.Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 16); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 2.5; TS.Color = GLASS_THEME.Acc1; TS.Parent = ToggleBtn

table.insert(ThemeElements.Cards, ToggleBtn)
table.insert(ThemeElements.Accents, ToggleBtn)
table.insert(ThemeElements.Accents, TS)

-- Hover Animation for Logo Button
ToggleBtn.MouseEnter:Connect(function()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 66, 0, 66)}):Play()
end)
ToggleBtn.MouseLeave:Connect(function()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 62, 0, 62)}):Play()
end)

-- Drag Mechanics
local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize
        ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 70), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 70))
    end
end)

-- Toast Notification Builder
local NotifyGui = Instance.new("ScreenGui"); NotifyGui.Name = "MofenkNotifyGui"; NotifyGui.Parent = parentGui; NotifyGui.ResetOnSpawn = false
local NotifyHolder = Instance.new("Frame"); NotifyHolder.Parent = NotifyGui; NotifyHolder.Position = UDim2.new(1, -320, 0, 20); NotifyHolder.Size = UDim2.new(0, 300, 1, -40); NotifyHolder.BackgroundTransparency = 1
local NotifyLayout = Instance.new("UIListLayout"); NotifyLayout.Parent = NotifyHolder; NotifyLayout.Padding = UDim.new(0, 8); NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function Notify(title, msg, duration)
    duration = duration or 3.5
    local Card = Instance.new("Frame"); Card.Parent = NotifyHolder; Card.Size = UDim2.new(1, 0, 0, 62); Card.BackgroundColor3 = GLASS_THEME.Card; Card.BackgroundTransparency = 0.15
    local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = Card
    local CS = Instance.new("UIStroke"); CS.Thickness = 1.5; CS.Color = GLASS_THEME.Acc1; CS.Parent = Card
    
    local T = Instance.new("TextLabel"); T.Parent = Card; T.Position = UDim2.new(0, 12, 0, 6); T.Size = UDim2.new(1, -24, 0, 22); T.Text = title; T.TextColor3 = GLASS_THEME.Acc1; T.Font = Enum.Font.GothamBold; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left; T.BackgroundTransparency = 1
    local M = Instance.new("TextLabel"); M.Parent = Card; M.Position = UDim2.new(0, 12, 0, 28); M.Size = UDim2.new(1, -24, 0, 28); M.Text = msg; M.TextColor3 = GLASS_THEME.Text; M.Font = Enum.Font.GothamMedium; M.TextSize = 12; M.TextXAlignment = Enum.TextXAlignment.Left; M.TextWrapped = true; M.BackgroundTransparency = 1
    
    Card.Position = UDim2.new(1, 50, 0, 0)
    TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)})
            tw:Play()
            tw.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- ===================================================================== --
-- 4. ULTIMATE MAIN UI SETUP WITH SMOOTH ANIMATIONS
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHubGAG"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 960, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundColor3 = GLASS_THEME.Bg; MainFrame.BackgroundTransparency = 0.12
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2; MainStroke.Color = GLASS_THEME.Acc1; MainStroke.Parent = MainFrame

table.insert(ThemeElements.Backgrounds, MainFrame)
table.insert(ThemeElements.Accents, MainStroke)

local MainScale = Instance.new("UIScale"); MainScale.Parent = MainFrame; MainScale.Scale = 1

local isWindowOpen = false
local function ToggleWindow()
    if isWindowOpen then
        isWindowOpen = false
        local tw = TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        tw:Play()
        tw.Completed:Connect(function()
            if not isWindowOpen then MainFrame.Visible = false end
        end)
    else
        isWindowOpen = true
        MainFrame.Visible = true
        MainScale.Scale = 0
        TweenService:Create(MainScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleWindow)

-- Global Keybind Handler
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode.Name == F.toggleKey then
        ToggleWindow()
    end
end)

-- Top Bar Header
local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 54); TopBar.BackgroundColor3 = GLASS_THEME.Header; TopBar.BackgroundTransparency = 0.2
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 16); TopCorner.Parent = TopBar
table.insert(ThemeElements.Headers, TopBar)

local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 580, 1, 0); Title.Text = "👑 MOFENKHUB  |  GROW A GARDEN EDITION"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 15; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1
table.insert(ThemeElements.Accents, Title)

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -48, 0, 11); CloseBtn.Size = UDim2.new(0, 34, 0, 34); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 16; CloseBtn.BackgroundColor3 = GLASS_THEME.Card; CloseBtn.BackgroundTransparency = 0.3
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(ToggleWindow)
table.insert(ThemeElements.Cards, CloseBtn)
table.insert(ThemeElements.Texts, CloseBtn)

-- Sidebar Navigation
local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 12, 0, 64); Sidebar.Size = UDim2.new(0, 200, 1, -74); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 3; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 6)

-- Content Area
local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 220, 0, 64); ContentArea.Size = UDim2.new(1, -232, 1, -74); ContentArea.BackgroundColor3 = GLASS_THEME.Header; ContentArea.BackgroundTransparency = 0.3
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 14); ContentCorner.Parent = ContentArea
table.insert(ThemeElements.Headers, ContentArea)

local TabFrames, TabButtons, TabAccents = {}, {}, {}
local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 42); Btn.Text = "   " .. icon .. "   " .. name; Btn.TextColor3 = GLASS_THEME.SubText; Btn.TextSize = 13; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundColor3 = GLASS_THEME.Card; Btn.BackgroundTransparency = 0.4
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
    
    -- Accent Indicator Bar
    local AccentBar = Instance.new("Frame"); AccentBar.Parent = Btn; AccentBar.Size = UDim2.new(0, 0, 0.7, 0); AccentBar.Position = UDim2.new(0, 4, 0.15, 0); AccentBar.BackgroundColor3 = GLASS_THEME.Acc1
    local AC = Instance.new("UICorner"); AC.CornerRadius = UDim.new(1, 0); AC.Parent = AccentBar
    
    local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -18, 1, -18); Scroll.Position = UDim2.new(0, 9, 0, 9); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 5; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
    local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 12)
    
    TabFrames[name] = Scroll; TabButtons[name] = Btn; TabAccents[name] = AccentBar
    
    table.insert(ThemeElements.Cards, Btn)
    table.insert(ThemeElements.SubTexts, Btn)
    table.insert(ThemeElements.Accents, AccentBar)

    Btn.MouseButton1Click:Connect(function()
        for n, f in pairs(TabFrames) do f.Visible = (n == name) end
        for n, b in pairs(TabButtons) do 
            b.BackgroundTransparency = 0.4; b.TextColor3 = GLASS_THEME.SubText; b.BackgroundColor3 = GLASS_THEME.Card
            TweenService:Create(TabAccents[n], TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0.7, 0)}):Play()
        end
        Btn.BackgroundTransparency = 0.1; Btn.TextColor3 = GLASS_THEME.Acc1; Btn.BackgroundColor3 = GLASS_THEME.Card
        TweenService:Create(AccentBar, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 4, 0.7, 0)}):Play()
    end)
    return Scroll
end

local function AddGroup(parent, title)
    local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundColor3 = GLASS_THEME.Card; GroupCard.BackgroundTransparency = 0.25
    local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 12); GC.Parent = GroupCard
    local GS = Instance.new("UIStroke"); GS.Thickness = 1.2; GS.Color = GLASS_THEME.Acc1; GS.Transparency = 0.7; GS.Parent = GroupCard
    local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 10); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 12); GPadding.PaddingBottom = UDim.new(0, 12); GPadding.PaddingLeft = UDim.new(0, 12); GPadding.PaddingRight = UDim.new(0, 12)
    
    table.insert(ThemeElements.Cards, GroupCard)
    table.insert(ThemeElements.Accents, GS)

    if title and title ~= "" then
        local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 28); HeaderLbl.Text = title; HeaderLbl.TextColor3 = GLASS_THEME.Acc1; HeaderLbl.TextSize = 14; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1
        table.insert(ThemeElements.Accents, HeaderLbl)
    end
    return GroupCard
end

local function AddToggle(parent, text, flag, callback)
    local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
    local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.68, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -52, 0.5, -13); Sw.Size = UDim2.new(0, 46, 0, 26); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
    local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 22, 0, 22); Knob.BackgroundColor3 = GLASS_THEME.Text; local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
    
    table.insert(ThemeElements.Texts, L)

    local function updateVisuals()
        Sw.BackgroundColor3 = F[flag] and GLASS_THEME.Acc1 or Color3.fromRGB(30, 41, 59)
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = F[flag] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)}):Play()
    end
    table.insert(ConfigUpdaters, updateVisuals)

    Sw.MouseButton1Click:Connect(function()
        F[flag] = not F[flag]
        updateVisuals()
        Notify("MofenkHub Toggle", text .. ": " .. (F[flag] and "AKTIF" or "NONAKTIF"), 2)
        if callback then pcall(callback, F[flag]) end
    end)
    updateVisuals()
end

local function AddSlider(parent, text, flag, min, max, default, callback)
    min = min or 0; max = max or 100; default = default or min
    F[flag] = F[flag] or default

    local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 52); Frm.BackgroundTransparency = 1
    local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.6, 0, 0, 24); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local ValLbl = Instance.new("TextLabel"); ValLbl.Parent = Frm; ValLbl.Position = UDim2.new(0.6, 0, 0, 0); ValLbl.Size = UDim2.new(0.4, -6, 0, 24); ValLbl.Text = tostring(F[flag]); ValLbl.TextColor3 = GLASS_THEME.Acc1; ValLbl.TextSize = 13; ValLbl.Font = Enum.Font.GothamBold; ValLbl.TextXAlignment = Enum.TextXAlignment.Right; ValLbl.BackgroundTransparency = 1
    
    local Track = Instance.new("Frame"); Track.Parent = Frm; Track.Position = UDim2.new(0, 6, 0, 32); Track.Size = UDim2.new(1, -12, 0, 10); Track.BackgroundColor3 = GLASS_THEME.Header; local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(1, 0); TC.Parent = Track
    local Fill = Instance.new("Frame"); Fill.Parent = Track; Fill.Size = UDim2.new((F[flag] - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = GLASS_THEME.Acc1; local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(1, 0); FC.Parent = Fill
    local Knob = Instance.new("Frame"); Knob.Parent = Track; Knob.AnchorPoint = Vector2.new(0.5, 0.5); Knob.Position = UDim2.new((F[flag] - min) / (max - min), 0, 0.5, 0); Knob.Size = UDim2.new(0, 18, 0, 18); Knob.BackgroundColor3 = GLASS_THEME.Text; local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob

    table.insert(ThemeElements.Texts, L)
    table.insert(ThemeElements.Accents, ValLbl)
    table.insert(ThemeElements.Headers, Track)
    table.insert(ThemeElements.Accents, Fill)

    local function updateValue(val)
        val = math.clamp(math.floor(val), min, max)
        F[flag] = val
        ValLbl.Text = tostring(val)
        local percent = (val - min) / (max - min)
        TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
        if callback then pcall(callback, val) end
    end

    local isDragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local posX = input.Position.X - Track.AbsolutePosition.X
            local percent = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
            updateValue(min + (max - min) * percent)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local posX = input.Position.X - Track.AbsolutePosition.X
            local percent = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
            updateValue(min + (max - min) * percent)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    table.insert(ConfigUpdaters, function() updateValue(F[flag] or default) end)
end

local function AddInput(parent, text, flag, isNum)
    local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
    local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.48, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.5, 0, 0.8, 0); Box.TextColor3 = GLASS_THEME.Acc1; Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundColor3 = GLASS_THEME.Header; Box.BackgroundTransparency = 0.25; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
    local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.6; BS.Parent = Box
    
    table.insert(ThemeElements.Texts, L)
    table.insert(ThemeElements.Accents, Box)
    table.insert(ThemeElements.Headers, Box)
    table.insert(ThemeElements.Accents, BS)

    local function updateVisuals() Box.Text = tostring(F[flag] or "") end
    table.insert(ConfigUpdaters, updateVisuals)

    Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
    updateVisuals()
end

local function AddKeybind(parent, text, flag, defaultKey, callback)
    F[flag] = F[flag] or defaultKey
    local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
    local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.52, 0, 0.1, 0); Btn.Size = UDim2.new(0.48, 0, 0.8, 0); Btn.Text = tostring(F[flag]); Btn.TextColor3 = GLASS_THEME.Acc1; Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundColor3 = GLASS_THEME.Header; Btn.BackgroundTransparency = 0.25; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Btn
    local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.6; BS.Parent = Btn

    table.insert(ThemeElements.Texts, L)
    table.insert(ThemeElements.Accents, Btn)
    table.insert(ThemeElements.Headers, Btn)
    table.insert(ThemeElements.Accents, BS)

    local isBinding = false
    Btn.MouseButton1Click:Connect(function()
        isBinding = true
        Btn.Text = "Tekan Tombol..."
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if isBinding and not gpe then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                isBinding = false
                F[flag] = input.KeyCode.Name
                Btn.Text = input.KeyCode.Name
                Notify("Keybind Updated", "Tombol " .. text .. " diubah ke " .. input.KeyCode.Name, 2.5)
                if callback then pcall(callback, input.KeyCode) end
            end
        end
    end)

    table.insert(ConfigUpdaters, function() Btn.Text = tostring(F[flag] or defaultKey) end)
end

local function makeConsole(tab, cfg)
    local handle = {}
    handle.name = cfg.Name or ""
    handle.maxLines = tonumber(cfg.MaxLines) or 60
    handle.lines = {}
    local para = Instance.new("TextLabel"); para.Parent = tab; para.Size = UDim2.new(1, 0, 0, 160); para.BackgroundColor3 = GLASS_THEME.Header; para.BackgroundTransparency = 0.4; para.TextColor3 = GLASS_THEME.Text; para.TextSize = 11; para.Font = Enum.Font.Code; para.TextXAlignment = Enum.TextXAlignment.Left; para.TextYAlignment = Enum.TextYAlignment.Top; para.TextWrapped = true; local PC = Instance.new("UICorner"); PC.CornerRadius = UDim.new(0, 8); PC.Parent = para; local PP = Instance.new("UIPadding"); PP.Parent = para; PP.PaddingTop = UDim.new(0, 8); PP.PaddingLeft = UDim.new(0, 8); PP.PaddingRight = UDim.new(0, 8); PP.PaddingBottom = UDim.new(0, 8)

    table.insert(ThemeElements.Headers, para)
    table.insert(ThemeElements.Texts, para)

    function handle:Append(text)
        table.insert(handle.lines, tostring(text))
        while #handle.lines > handle.maxLines do table.remove(handle.lines, 1) end
        local view, first = {}, math.max(1, #handle.lines - 10 + 1)
        for i = first, #handle.lines do table.insert(view, handle.lines[i]) end
        pcall(function() para.Text = table.concat(view, "\n") end)
    end
    return handle
end

-- ===================================================================== --
-- 5. TABS ASSEMBLY
-- ===================================================================== --
local T_Dash   = CreateTab("Dashboard", "📊")
local T_Spy    = CreateTab("Spy Scanner", "🔍")
local T_Server = CreateTab("Server Hop", "🌐")
local T_Char   = CreateTab("Character", "⚡")
local T_Set    = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; Sidebar:GetChildren()[2].TextColor3 = GLASS_THEME.Acc1

-- 1. DASHBOARD TAB
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK REAL-TIME")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 95); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0, 0.5); PImg.Position = UDim2.new(0, 8, 0.5, 0); PImg.Size = UDim2.new(0, 76, 0, 76); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 2; PStr.Color = GLASS_THEME.Acc1; PStr.Parent = PImg

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0, 98, 0, 0); PLbl.Size = UDim2.new(1, -108, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = GLASS_THEME.Text; PLbl.TextSize = 13; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

table.insert(ThemeElements.Texts, PLbl)
table.insert(ThemeElements.Accents, PStr)

local G_HopTimer = AddGroup(T_Dash, "AUTO SERVER HOP TIMER (40 MENIT)")
local HopTimerLbl = Instance.new("TextLabel"); HopTimerLbl.Parent = G_HopTimer; HopTimerLbl.Size = UDim2.new(1, 0, 0, 30); HopTimerLbl.BackgroundTransparency = 1; HopTimerLbl.TextColor3 = GLASS_THEME.Acc1; HopTimerLbl.TextSize = 14; HopTimerLbl.Font = Enum.Font.GothamBold; HopTimerLbl.TextXAlignment = Enum.TextXAlignment.Left; HopTimerLbl.Text = "Status: Disabled"
table.insert(ThemeElements.Accents, HopTimerLbl)

local G_Logs = AddGroup(T_Dash, "MOFENKHUB CONSOLE LOG")
local console = makeConsole(G_Logs, { Name = "Console Log", MaxLines = 100 })
local function clog(m)
    print("[MOFENKHUB]", m)
    pcall(function() console:Append(m) end)
end

task.spawn(function()
    local lastTime = os.clock()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastTime >= 1 then
            STATE.fpsCurrent = frameCount
            frameCount = 0
            lastTime = now
        end
    end)

    while task.wait(0.8) do pcall(function()
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
        STATE.pingMs = ping
        PLbl.Text = string.format("👤 Player: %s (%s)\n🆔 UserId: %d\n📍 PlaceId: %d\n⚡ Ping: %d ms | 🖥️ FPS: %d", LocalPlayer.Name, LocalPlayer.DisplayName, LocalPlayer.UserId, game.PlaceId, STATE.pingMs, STATE.fpsCurrent)
    end) end
end)

-- 2. SPY SCANNER TAB
local G_SpyScan = AddGroup(T_Spy, "REMOTE SERVICE SCANNER (DELTA / ROBLOX CONSOLE)")

local function scanAndPrintRemotes()
    clog("--- [ SPY SCANNER STARTED ] ---")
    local count = 0
    local targetServices = { ReplicatedStorage, workspace, Players, game:GetService("Lighting") }
    
    for _, svc in ipairs(targetServices) do
        clog("Scanning Service: " .. svc.Name)
        for _, obj in ipairs(svc:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                count = count + 1
                local info = string.format("[%s] -> %s", obj.ClassName, obj:GetFullName())
                print("[MOFENK SPY] " .. info)
                clog(info)
            end
        end
    end
    clog("--- [ SCAN FINISHED: " .. count .. " REMOTES FOUND ] ---")
    Notify("Spy Scanner", "Ditemukan " .. count .. " remotes! Cek Delta Console.", 4)
end

local BtnScan = Instance.new("TextButton"); BtnScan.Parent = G_SpyScan; BtnScan.Size = UDim2.new(1, 0, 0, 36); BtnScan.Text = "🔍 SCAN ALL SERVICES & PRINT TO CONSOLE"; BtnScan.Font = Enum.Font.GothamBold; BtnScan.TextSize = 12; BtnScan.TextColor3 = GLASS_THEME.Acc1; BtnScan.BackgroundColor3 = GLASS_THEME.Header; local BSC = Instance.new("UICorner"); BSC.CornerRadius = UDim.new(0,8); BSC.Parent = BtnScan
BtnScan.MouseButton1Click:Connect(function() task.spawn(scanAndPrintRemotes) end)
table.insert(ThemeElements.Headers, BtnScan)
table.insert(ThemeElements.Accents, BtnScan)

local G_SpyHook = AddGroup(T_Spy, "REMOTE CALL INSPECTOR (HOOK NAMECALL)")
AddToggle(G_SpyHook, "Hook FireServer / InvokeServer Calls", "spyHook", function(v)
    if v then Notify("Spy Hook", "Mendengarkan panggilan Remote... Cek Delta Console!", 4) end
end)

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if F.spyHook and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            print(string.format("[MOFENK SPY CALL] %s:%s() | Args: %s", self:GetFullName(), method, HttpService:JSONEncode(args)))
        end
        return oldNamecall(self, ...)
    end)
end

-- 3. SERVER HOP TAB (LIST & VISITED SYSTEM)
local G_HopSys = AddGroup(T_Server, "AUTO SERVER HOP SYSTEM (PUBLIC API LIST)")

local VISIT_TTL = 1800
local function visitedPath() return CFG_FOLDER .. "/visited_" .. tostring(LocalPlayer.UserId) .. ".json" end

local function loadVisited()
    local t = {}
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return t end
    local path = visitedPath()
    if not isfile(path) then return t end
    local okR, txt = pcall(readfile, path)
    if not okR then return t end
    local okD, d = pcall(function() return HttpService:JSONDecode(txt) end)
    if not (okD and type(d) == "table") then return t end
    local now = os.time()
    for job, ts in pairs(d) do
        ts = tonumber(ts)
        if type(job) == "string" and ts and now - ts < VISIT_TTL then t[job] = ts end
    end
    return t
end

local function saveVisited(t)
    if typeof(writefile) ~= "function" then return end
    pcall(function() writefile(visitedPath(), HttpService:JSONEncode(t)) end)
end

local function doHop(lowPop)
    task.spawn(function()
        armAutoExec()
        Notify("Server Hop", "Mencari server di daftar publik...", 4)
        local visited = loadVisited()
        local cands, cursor, pages = {}, nil, 0
        local order = lowPop and "Asc" or "Desc"
        local currentPlace = game.PlaceId

        while pages < 3 do
            local url = "https://games.roblox.com/v1/games/" .. tostring(currentPlace) .. "/servers/Public?sortOrder=" .. order .. "&limit=100&excludeFullGames=true"
            if cursor then url = url .. "&cursor=" .. cursor end
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if not ok then break end
            local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
            if not (ok2 and data and data.data) then break end
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and not visited[s.id] and (tonumber(s.playing) or 0) < (tonumber(s.maxPlayers) or 99) then
                    table.insert(cands, s)
                end
            end
            cursor = data.nextPageCursor
            pages += 1
            if not cursor then break end
        end

        if #cands == 0 then
            Notify("Server Hop", "Semua server publik sudah dikunjungi, berpindah acak...", 4)
            TeleportService:Teleport(currentPlace, LocalPlayer)
            return
        end

        local target = cands[1]
        visited[target.id] = os.time()
        saveVisited(visited)
        Notify("Server Hop", "Teleportasi ke " .. target.id .. " (" .. target.playing .. " pemain)...", 4)
        TeleportService:TeleportToPlaceInstance(currentPlace, target.id, LocalPlayer)
    end)
end

AddToggle(G_HopSys, "Auto Server Hop Setiap 40 Menit", "autoHop40", function(v)
    if v then
        F.hopInterval = 2400
        clog("Auto Hop 40 Menit diaktifkan.")
    else
        HopTimerLbl.Text = "Status: Disabled"
    end
end)

local BtnHopNow = Instance.new("TextButton"); BtnHopNow.Parent = G_HopSys; BtnHopNow.Size = UDim2.new(1, 0, 0, 34); BtnHopNow.Text = "🌐 HOP SERVER SEKARANG"; BtnHopNow.Font = Enum.Font.GothamBold; BtnHopNow.TextSize = 12; BtnHopNow.TextColor3 = GLASS_THEME.Acc1; BtnHopNow.BackgroundColor3 = GLASS_THEME.Header; local BHNC = Instance.new("UICorner"); BHNC.CornerRadius = UDim.new(0,8); BHNC.Parent = BtnHopNow
BtnHopNow.MouseButton1Click:Connect(function() doHop(false) end)

local BtnHopLow = Instance.new("TextButton"); BtnHopLow.Parent = G_HopSys; BtnHopLow.Size = UDim2.new(1, 0, 0, 34); BtnHopLow.Text = "📉 HOP SERVER SEPI (LOW PLAYER)"; BtnHopLow.Font = Enum.Font.GothamBold; BtnHopLow.TextSize = 12; BtnHopLow.TextColor3 = GLASS_THEME.Acc1; BtnHopLow.BackgroundColor3 = GLASS_THEME.Header; local BHLC = Instance.new("UICorner"); BHLC.CornerRadius = UDim.new(0,8); BHLC.Parent = BtnHopLow
BtnHopLow.MouseButton1Click:Connect(function() doHop(true) end)

local BtnRejoin = Instance.new("TextButton"); BtnRejoin.Parent = G_HopSys; BtnRejoin.Size = UDim2.new(1, 0, 0, 34); BtnRejoin.Text = "🔄 REJOIN SERVER SAMA"; BtnRejoin.Font = Enum.Font.GothamBold; BtnRejoin.TextSize = 12; BtnRejoin.TextColor3 = GLASS_THEME.Acc1; BtnRejoin.BackgroundColor3 = GLASS_THEME.Header; local BRC = Instance.new("UICorner"); BRC.CornerRadius = UDim.new(0,8); BRC.Parent = BtnRejoin
BtnRejoin.MouseButton1Click:Connect(function()
    armAutoExec()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

table.insert(ThemeElements.Headers, BtnHopNow); table.insert(ThemeElements.Accents, BtnHopNow)
table.insert(ThemeElements.Headers, BtnHopLow); table.insert(ThemeElements.Accents, BtnHopLow)
table.insert(ThemeElements.Headers, BtnRejoin); table.insert(ThemeElements.Accents, BtnRejoin)

-- 40-Min Hop Thread
task.spawn(function()
    while _G.__MOFENKHUB == generation do
        task.wait(1)
        if F.autoHop40 then
            F.hopInterval = F.hopInterval - 1
            local m = math.floor(F.hopInterval / 60)
            local s = F.hopInterval % 60
            HopTimerLbl.Text = string.format("Hop Berikutnya dalam: %02d:%02d", m, s)
            if F.hopInterval <= 0 then
                F.hopInterval = 2400
                doHop(false)
            end
        end
    end
end)

-- 4. CHARACTER TAB
local G_Char = AddGroup(T_Char, "MOVEMENT & CHARACTER MODS")

local function applyWS()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = (F.wsOn and F.wsValue) or 16 end
end

AddToggle(G_Char, "Aktifkan WalkSpeed Modifier", "wsOn", function() applyWS() end)
AddSlider(G_Char, "Atur WalkSpeed:", "wsValue", 16, 250, 16, function() applyWS() end)

-- Fly System
local flyGyro, flyVel, flyMoveConn, flyKeys = nil, nil, nil, {}
local function flyStop()
    if flyMoveConn then pcall(function() flyMoveConn:Disconnect() end) flyMoveConn = nil end
    if flyGyro then pcall(function() flyGyro:Destroy() end) flyGyro = nil end
    if flyVel then pcall(function() flyVel:Destroy() end) flyVel = nil end
    table.clear(flyKeys)
end

local function flyStart()
    flyStop()
    local ch = LocalPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyGyro = Instance.new("BodyGyro")
    flyGyro.P = 9000
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp
    flyVel = Instance.new("BodyVelocity")
    flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVel.Velocity = Vector3.zero
    flyVel.Parent = hrp
    flyMoveConn = RunService.RenderStepped:Connect(function()
        if not F.flyOn then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local dir = Vector3.zero
        if flyKeys[Enum.KeyCode.W] then dir += cam.CFrame.LookVector end
        if flyKeys[Enum.KeyCode.S] then dir -= cam.CFrame.LookVector end
        if flyKeys[Enum.KeyCode.A] then dir -= cam.CFrame.RightVector end
        if flyKeys[Enum.KeyCode.D] then dir += cam.CFrame.RightVector end
        if flyKeys[Enum.KeyCode.Space] then dir += Vector3.new(0, 1, 0) end
        if flyKeys[Enum.KeyCode.LeftShift] then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit * F.flySpeed end
        pcall(function()
            flyVel.Velocity = dir
            flyGyro.CFrame = cam.CFrame
        end)
    end)
end

UserInputService.InputBegan:Connect(function(i, g)
    if g or not F.flyOn then return end
    flyKeys[i.KeyCode] = true
end)
UserInputService.InputEnded:Connect(function(i) flyKeys[i.KeyCode] = nil end)

AddToggle(G_Char, "Aktifkan Fly (WASD + Space/Shift)", "flyOn", function(v)
    if v then flyStart() else flyStop() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand = false end end
end)
AddSlider(G_Char, "Kecepatan Fly (Fly Speed):", "flySpeed", 10, 200, 50)

RunService.Stepped:Connect(function()
    if not F.noclip then return end
    local ch = LocalPlayer.Character
    if ch then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

AddToggle(G_Char, "Noclip (Tembus Tembok)", "noclip")

local G_Prot = AddGroup(T_Char, "SYSTEM PROTECTION & OPTIMIZATION")
AddToggle(G_Prot, "Anti-AFK Protection", "afk")
AddToggle(G_Prot, "Auto Reconnect Saat Disconnect", "autoReconnect")

AddToggle(G_Prot, "FPS Boost (Matikan Bayangan & Partikel)", "fpsOn", function(v)
    if v then
        pcall(function()
            local L = game:GetService("Lighting")
            table.insert(fpsRestore, { o = L, p = "GlobalShadows", v = L.GlobalShadows })
            L.GlobalShadows = false
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
                    table.insert(fpsRestore, { o = o, p = "Enabled", v = o.Enabled })
                    o.Enabled = false
                end
            end
        end)
        Notify("Performance", "FPS Boost Aktif.", 3)
    else
        for _, r in ipairs(fpsRestore) do pcall(function() r.o[r.p] = r.v end) end
        table.clear(fpsRestore)
        Notify("Performance", "FPS Boost Nonaktif.", 3)
    end
end)

-- 5. SETTINGS TAB
local G_Theme = AddGroup(T_Set, "TEMA & KEYBIND BINDING")

local ThemeBtns = {}
local FrmTheme = Instance.new("Frame"); FrmTheme.Parent = G_Theme; FrmTheme.Size = UDim2.new(1, 0, 0, 42); FrmTheme.BackgroundTransparency = 1
local LTheme = Instance.new("TextLabel"); LTheme.Parent = FrmTheme; LTheme.Position = UDim2.new(0, 6, 0, 0); LTheme.Size = UDim2.new(0.35, 0, 1, 0); LTheme.Text = "Pilih Tema UI:"; LTheme.TextColor3 = GLASS_THEME.Text; LTheme.TextSize = 13; LTheme.Font = Enum.Font.GothamMedium; LTheme.TextXAlignment = Enum.TextXAlignment.Left; LTheme.BackgroundTransparency = 1; table.insert(ThemeElements.Texts, LTheme)

local ThemeGrid = Instance.new("Frame"); ThemeGrid.Parent = FrmTheme; ThemeGrid.Position = UDim2.new(0.38, 0, 0.1, 0); ThemeGrid.Size = UDim2.new(0.62, 0, 0.8, 0); ThemeGrid.BackgroundTransparency = 1
local TGL = Instance.new("UIListLayout"); TGL.Parent = ThemeGrid; TGL.FillDirection = Enum.FillDirection.Horizontal; TGL.Padding = UDim.new(0, 6); TGL.HorizontalAlignment = Enum.HorizontalAlignment.Right

for tName, _ in pairs(THEMES) do
    local TBtn = Instance.new("TextButton"); TBtn.Parent = ThemeGrid; TBtn.Size = UDim2.new(0, 75, 1, 0); TBtn.Text = tName:match("^%w+"); TBtn.TextColor3 = GLASS_THEME.Text; TBtn.TextSize = 10; TBtn.Font = Enum.Font.GothamBold; TBtn.BackgroundColor3 = GLASS_THEME.Header; local TBC = Instance.new("UICorner"); TBC.CornerRadius = UDim.new(0, 6); TBC.Parent = TBtn
    table.insert(ThemeElements.Headers, TBtn); table.insert(ThemeElements.Texts, TBtn)
    
    TBtn.MouseButton1Click:Connect(function()
        UpdateTheme(tName)
        Notify("Theme Manager", "Tema diubah ke: " .. tName, 2.5)
    end)
end

AddKeybind(G_Theme, "Tombol Toggle Window UI:", "toggleKey", "RightControl")

local G_SetConfig = AddGroup(T_Set, "FILE CONFIG PRESETS MANAGEMENT")
AddToggle(G_SetConfig, "Auto Load Config Saat Script Dijalankan", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 36); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 13; BtnSave.TextColor3 = GLASS_THEME.Acc1; BtnSave.BackgroundColor3 = GLASS_THEME.Header; local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,8); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName); Notify("Config Saved", "Berhasil disimpan: " .. tostring(F.cfgName)) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 36); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 13; BtnLoad.TextColor3 = GLASS_THEME.Acc1; BtnLoad.BackgroundColor3 = GLASS_THEME.Header; local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,8); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName); Notify("Config Loaded", "Berhasil dimuat: " .. tostring(F.cfgName)) end) end)

local BtnDelete = Instance.new("TextButton"); BtnDelete.Parent = G_SetConfig; BtnDelete.Size = UDim2.new(1, 0, 0, 36); BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN"; BtnDelete.Font = Enum.Font.GothamBold; BtnDelete.TextSize = 13; BtnDelete.TextColor3 = Color3.fromRGB(239, 68, 68); BtnDelete.BackgroundColor3 = GLASS_THEME.Header; local BTD = Instance.new("UICorner"); BTD.CornerRadius = UDim.new(0,8); BTD.Parent = BtnDelete

local ListTitle = Instance.new("TextLabel"); ListTitle.Parent = G_SetConfig; ListTitle.Size = UDim2.new(1, 0, 0, 24); ListTitle.Text = "📁 PILIH CONFIG TERSEDIA:"; ListTitle.TextSize = 13; ListTitle.Font = Enum.Font.GothamBold; ListTitle.TextColor3 = GLASS_THEME.Acc1; ListTitle.BackgroundTransparency = 1

local ConfigScroll = Instance.new("ScrollingFrame"); ConfigScroll.Parent = G_SetConfig; ConfigScroll.Size = UDim2.new(1, 0, 0, 110); ConfigScroll.BackgroundColor3 = GLASS_THEME.Header; ConfigScroll.BackgroundTransparency = 0.4; ConfigScroll.ScrollBarThickness = 5; ConfigScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; ConfigScroll.CanvasSize = UDim2.new(0,0,0,0)
local CSC = Instance.new("UICorner"); CSC.CornerRadius = UDim.new(0, 8); CSC.Parent = ConfigScroll
local ConfigLayout = Instance.new("UIListLayout"); ConfigLayout.Parent = ConfigScroll; ConfigLayout.Padding = UDim.new(0, 5)

table.insert(ThemeElements.Headers, BtnSave); table.insert(ThemeElements.Accents, BtnSave)
table.insert(ThemeElements.Headers, BtnLoad); table.insert(ThemeElements.Accents, BtnLoad)
table.insert(ThemeElements.Headers, ConfigScroll)
table.insert(ThemeElements.Accents, ListTitle)

local function RefreshConfigList()
    for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(CFG_FOLDER)) do
                local fileName = file:match("([^/]+)$"):gsub("%.json$", "")
                local FileBtn = Instance.new("TextButton"); FileBtn.Parent = ConfigScroll; FileBtn.Size = UDim2.new(1, 0, 0, 34); FileBtn.Text = "📄 " .. fileName; FileBtn.TextSize = 12; FileBtn.Font = Enum.Font.GothamMedium; FileBtn.TextColor3 = GLASS_THEME.Text; FileBtn.BackgroundColor3 = GLASS_THEME.Card; FileBtn.BackgroundTransparency = 0.3
                local FBC = Instance.new("UICorner"); FBC.CornerRadius = UDim.new(0, 6); FBC.Parent = FileBtn
                
                table.insert(ThemeElements.Cards, FileBtn)
                table.insert(ThemeElements.Texts, FileBtn)

                FileBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        F.cfgName = fileName
                        loadConfig(fileName)
                        Notify("Config Selected", "Memuat file: " .. fileName)
                    end)
                end)
            end
        end)
    end
end
RefreshConfigList()

BtnDelete.MouseButton1Click:Connect(function()
    pcall(function()
        local path = getCfgPath(F.cfgName)
        if delfile and isfile and isfile(path) then 
            delfile(path) 
            Notify("Config Deleted", "File dihapus: " .. tostring(F.cfgName))
            RefreshConfigList()
        end
    end)
end)

local G_Web = AddGroup(T_Set, "DISCORD WEBHOOK NOTIFIER")
AddToggle(G_Web, "Aktifkan Webhook Discord", "webhookEnabled")
AddInput(G_Web, "Webhook URL:", "webhookUrl", false)
local BtnTestWeb = Instance.new("TextButton"); BtnTestWeb.Parent = G_Web; BtnTestWeb.Size = UDim2.new(1, 0, 0, 34); BtnTestWeb.Text = "🔔 TEST KIRIM WEBHOOK"; BtnTestWeb.Font = Enum.Font.GothamBold; BtnTestWeb.TextSize = 12; BtnTestWeb.TextColor3 = GLASS_THEME.Acc1; BtnTestWeb.BackgroundColor3 = GLASS_THEME.Header; local BTWC = Instance.new("UICorner"); BTWC.CornerRadius = UDim.new(0,8); BTWC.Parent = BtnTestWeb
BtnTestWeb.MouseButton1Click:Connect(function() SendWebhook("✅ Webhook Connected!", "MOFENKHUB V104.0 tersambung sukses.", 3447003); Notify("Webhook", "Test webhook dikirim.", 3) end)

table.insert(ThemeElements.Headers, BtnTestWeb); table.insert(ThemeElements.Accents, BtnTestWeb)

-- Auto-Save Settings Thread
task.spawn(function()
    while _G.__MOFENKHUB == generation do
        task.wait(10)
        pcall(function() saveConfig(F.cfgName) end)
    end
end)

clog("MOFENKHUB V104.0 Ultimate Edition Loaded!")
Notify("MOFENKHUB V104.0 Loaded!", "UI Animations, Slider, Keybind & Theme Preset siap digunakan.", 4)
