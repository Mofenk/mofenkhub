-- ===================================================================== --
-- 👑 MOFENKHUB V107.0 — GROW A GARDEN (GAG) FULL SPY & CONFIG SCRIPT
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
local Stats             = game:GetService("Stats")

-- Auto Exec on Teleport
pcall(function()
    local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        qot([[
            task.wait(3)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/gag.lua"))()
        ]])
    end
end)

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
    if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "MofenkGAG") then v:Destroy() end end end)

if not game:IsLoaded() then
    local t0 = os.clock()
    while not game:IsLoaded() and os.clock() - t0 < 30 do task.wait(0.2) end
end

_G.__GAG_SCRIPT = (_G.__GAG_SCRIPT or 0) + 1
local generation = _G.__GAG_SCRIPT

-- ===================================================================== --
-- 1. THEMES & CONFIGURATION MANAGER
-- ===================================================================== --
local THEMES = {
    ["Hitam Putih"] = {
        Bg      = Color3.fromRGB(0, 0, 0),
        Card    = Color3.fromRGB(18, 18, 18),
        Header  = Color3.fromRGB(10, 10, 10),
        Acc1    = Color3.fromRGB(255, 255, 255),
        Acc2    = Color3.fromRGB(200, 200, 200),
        Text    = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(160, 160, 160)
    },
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
    cfgName = "MofenkGAGConfig1", autoLoadEnabled = false,
    selectedTheme = "Hitam Putih",
    toggleKey = Enum.KeyCode.RightControl.Name,
    -- Trade & Booth Setup
    autoJoinTrade = true,
    autoClaimBooth = true,
    selectedBoothSkin = "Default",
    autoEquipSkin = true,
    -- Events & Pets
    autoClaimAlien = true,
    -- Character & Protections
    wsOn = false, wsValue = 16, afk = true,
    webhookEnabled = false, webhookUrl = ""
}

local STATE = {
    pingMs = 0, fpsCurrent = 60,
    tradeWorldStatus = "Main World",
    boothStatus = "Belum Klaim"
}

local ConfigUpdaters = {}
local ThemeElements = { Backgrounds = {}, Cards = {}, Headers = {}, Accents = {}, Texts = {}, SubTexts = {} }
local GLASS_THEME = THEMES["Hitam Putih"]

local function UpdateTheme(themeName)
    if not THEMES[themeName] then return end
    GLASS_THEME = THEMES[themeName]
    F.selectedTheme = themeName

    for _, v in ipairs(ThemeElements.Backgrounds) do v.BackgroundColor3 = GLASS_THEME.Bg end
    for _, v in ipairs(ThemeElements.Cards) do v.BackgroundColor3 = GLASS_THEME.Card end
    for _, v in ipairs(ThemeElements.Headers) do v.BackgroundColor3 = GLASS_THEME.Header end
    for _, v in ipairs(ThemeElements.Accents) do
        if v:IsA("UIStroke") then v.Color = GLASS_THEME.Acc1
        elseif v:IsA("TextLabel") or v:IsA("TextButton") then v.TextColor3 = GLASS_THEME.Acc1
        else v.BackgroundColor3 = GLASS_THEME.Acc1 end
    end
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

-- ===================================================================== --
-- 2. GAME EVENT SPY & REMOTE MAPPING
-- ===================================================================== --
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents", 15)
local TradeEvents = GameEvents and GameEvents:FindFirstChild("TradeEvents")
local BoothEvents = TradeEvents and TradeEvents:FindFirstChild("Booths")
local SkinService  = GameEvents and GameEvents:FindFirstChild("TradeBoothSkinService")
local TokenRAPs    = TradeEvents and TradeEvents:FindFirstChild("TokenRAPs")
local AlienEvent   = GameEvents and GameEvents:FindFirstChild("AlienEvent")

local Remotes = {
    ClaimBooth    = BoothEvents and BoothEvents:FindFirstChild("ClaimBooth"),
    RemoveBooth   = BoothEvents and BoothEvents:FindFirstChild("RemoveBooth"),
    EquipSkin     = SkinService and SkinService:FindFirstChild("Equip"),
    TeleportTrade = TokenRAPs and TokenRAPs:FindFirstChild("TeleportToListing"),
    AlienPets     = AlienEvent and AlienEvent:FindFirstChild("GiveAlienatedPets")
}

local KnownBoothSkins = {
    {label = "Default Skin", val = "Default"},
    {label = "Wooden Stand", val = "Wooden Stand"},
    {label = "Golden Booth", val = "Golden Booth"},
    {label = "Cyber Neon Stand", val = "Cyber Booth"},
    {label = "Pumpkin Halloween", val = "Halloween Booth"},
    {label = "Alien UFO Stand", val = "Alien Stand"}
}

-- ===================================================================== --
-- 3. INTERACTIVE LOGO "M" & TOAST NOTIFICATION SYSTEM
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleGAG"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 56, 0, 56); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = GLASS_THEME.Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 28; ToggleBtn.TextColor3 = GLASS_THEME.Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 14); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 2; TS.Color = GLASS_THEME.Acc1; TS.Parent = ToggleBtn

table.insert(ThemeElements.Cards, ToggleBtn); table.insert(ThemeElements.Accents, ToggleBtn); table.insert(ThemeElements.Accents, TS)

ToggleBtn.MouseEnter:Connect(function() TweenService:Create(ToggleBtn, TweenInfo.new(0.18), {Size = UDim2.new(0, 60, 0, 60)}):Play() end)
ToggleBtn.MouseLeave:Connect(function() TweenService:Create(ToggleBtn, TweenInfo.new(0.18), {Size = UDim2.new(0, 56, 0, 56)}):Play() end)

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
        ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 65), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 65))
    end
end)

local NotifyGui = Instance.new("ScreenGui"); NotifyGui.Name = "MofenkNotifyGuiGAG"; NotifyGui.Parent = parentGui; NotifyGui.ResetOnSpawn = false
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
-- 4. ULTIMATE MAIN UI SETUP
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkGAGUltraHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 960, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundColor3 = GLASS_THEME.Bg; MainFrame.BackgroundTransparency = 0.08
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2; MainStroke.Color = GLASS_THEME.Acc1; MainStroke.Parent = MainFrame

table.insert(ThemeElements.Backgrounds, MainFrame); table.insert(ThemeElements.Accents, MainStroke)

local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateResponsiveScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if viewport.X <= 0 or viewport.Y <= 0 then return end
    
    local scaleX = (viewport.X * 0.92) / 960
    local scaleY = (viewport.Y * 0.92) / 620
    local targetScale = math.min(scaleX, scaleY)
    
    ScreenScale.Scale = math.clamp(targetScale, 0.35, 1.15)
end

UpdateResponsiveScale()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale) end

local MainScale = Instance.new("UIScale"); MainScale.Parent = MainFrame; MainScale.Scale = 1

local isWindowOpen = false
local function ToggleWindow()
    if isWindowOpen then
        isWindowOpen = false
        local tw = TweenService:Create(MainScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        tw:Play()
        tw.Completed:Connect(function() if not isWindowOpen then MainFrame.Visible = false end end)
    else
        isWindowOpen = true
        MainFrame.Visible = true
        MainScale.Scale = 0
        TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleWindow)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode.Name == F.toggleKey then ToggleWindow() end
end)

-- Top Bar Header
local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 54); TopBar.BackgroundColor3 = GLASS_THEME.Header; TopBar.BackgroundTransparency = 0.2
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 16); TopCorner.Parent = TopBar
table.insert(ThemeElements.Headers, TopBar)

local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 580, 1, 0); Title.Text = "👑 MOFENKHUB  |  GROW A GARDEN V107.0"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 15; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1
table.insert(ThemeElements.Accents, Title)

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -48, 0, 11); CloseBtn.Size = UDim2.new(0, 34, 0, 34); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 16; CloseBtn.BackgroundColor3 = GLASS_THEME.Card; CloseBtn.BackgroundTransparency = 0.3
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(ToggleWindow)
table.insert(ThemeElements.Cards, CloseBtn); table.insert(ThemeElements.Texts, CloseBtn)

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
    
    local AccentBar = Instance.new("Frame"); AccentBar.Parent = Btn; AccentBar.Size = UDim2.new(0, 0, 0.7, 0); AccentBar.Position = UDim2.new(0, 4, 0.15, 0); AccentBar.BackgroundColor3 = GLASS_THEME.Acc1
    local AC = Instance.new("UICorner"); AC.CornerRadius = UDim.new(1, 0); AC.Parent = AccentBar
    
    local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -18, 1, -18); Scroll.Position = UDim2.new(0, 9, 0, 9); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 5; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
    local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 12)
    
    TabFrames[name] = Scroll; TabButtons[name] = Btn; TabAccents[name] = AccentBar
    
    table.insert(ThemeElements.Cards, Btn); table.insert(ThemeElements.SubTexts, Btn); table.insert(ThemeElements.Accents, AccentBar)

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
    
    table.insert(ThemeElements.Cards, GroupCard); table.insert(ThemeElements.Accents, GS)

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
        Sw.BackgroundColor3 = F[flag] and GLASS_THEME.Acc1 or Color3.fromRGB(40, 40, 40)
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

local function AddInput(parent, text, flag, isNum)
    local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
    local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.48, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.5, 0, 0.8, 0); Box.TextColor3 = GLASS_THEME.Acc1; Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundColor3 = GLASS_THEME.Header; Box.BackgroundTransparency = 0.25; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
    local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.6; BS.Parent = Box
    
    table.insert(ThemeElements.Texts, L); table.insert(ThemeElements.Accents, Box); table.insert(ThemeElements.Headers, Box); table.insert(ThemeElements.Accents, BS)

    local function updateVisuals() Box.Text = tostring(F[flag] or "") end
    table.insert(ConfigUpdaters, updateVisuals)

    Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
    updateVisuals()
end

local function AddDropdown(parent, title, options, flag, isMulti)
    local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 46); Frm.BackgroundTransparency = 1
    local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.58, 0, 0.8, 0); Btn.TextColor3 = GLASS_THEME.Acc1; Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundColor3 = GLASS_THEME.Header; Btn.BackgroundTransparency = 0.25; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Btn
    local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.6; BS.Parent = Btn
    
    local DropList = Instance.new("Frame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 310, 0, 200); DropList.BackgroundColor3 = GLASS_THEME.Bg; DropList.Visible = false; DropList.ZIndex = 300
    local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 10); DLC.Parent = DropList
    local DLS = Instance.new("UIStroke"); DLS.Thickness = 1.5; DLS.Color = GLASS_THEME.Acc1; DLS.Parent = DropList

    local ScrollOpts = Instance.new("ScrollingFrame"); ScrollOpts.Parent = DropList; ScrollOpts.Position = UDim2.new(0, 8, 0, 8); ScrollOpts.Size = UDim2.new(1, -16, 1, -16); ScrollOpts.BackgroundTransparency = 1; ScrollOpts.ScrollBarThickness = 5; ScrollOpts.ZIndex = 301; ScrollOpts.AutomaticCanvasSize = Enum.AutomaticSize.Y; ScrollOpts.CanvasSize = UDim2.new(0,0,0,0)
    local DLL = Instance.new("UIListLayout"); DLL.Parent = ScrollOpts; DLL.Padding = UDim.new(0, 4)

    local function UpdatePos()
        if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 3) end
    end
    Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

    local function updateMainBtn() Btn.Text = tostring(F[flag] or "Pilih") end
    table.insert(ConfigUpdaters, updateMainBtn)

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton"); OptBtn.Parent = ScrollOpts; OptBtn.Size = UDim2.new(1, 0, 0, 36); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = GLASS_THEME.Text; OptBtn.TextSize = 12; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundColor3 = GLASS_THEME.Card; OptBtn.BackgroundTransparency = 0.5; OptBtn.ZIndex = 302
        local OC = Instance.new("UICorner"); OC.CornerRadius = UDim.new(0, 6); OC.Parent = OptBtn

        OptBtn.MouseButton1Click:Connect(function()
            F[flag] = opt.val
            DropList.Visible = false
            updateMainBtn()
        end)
    end

    updateMainBtn()
    Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

-- CONSOLE SPY LOG SYSTEM
local function makeConsole(tab, cfg)
    local handle = {}
    handle.name = cfg.Name or ""
    handle.maxLines = tonumber(cfg.MaxLines) or 60
    handle.lines = {}
    local para = Instance.new("TextLabel"); para.Parent = tab; para.Size = UDim2.new(1, 0, 0, 160); para.BackgroundColor3 = GLASS_THEME.Header; para.BackgroundTransparency = 0.4; para.TextColor3 = GLASS_THEME.Text; para.TextSize = 11; para.Font = Enum.Font.Code; para.TextXAlignment = Enum.TextXAlignment.Left; para.TextYAlignment = Enum.TextYAlignment.Top; para.TextWrapped = true; local PC = Instance.new("UICorner"); PC.CornerRadius = UDim.new(0, 8); PC.Parent = para; local PP = Instance.new("UIPadding"); PP.Parent = para; PP.PaddingTop = UDim.new(0, 8); PP.PaddingLeft = UDim.new(0, 8); PP.PaddingRight = UDim.new(0, 8); PP.PaddingBottom = UDim.new(0, 8)

    table.insert(ThemeElements.Headers, para); table.insert(ThemeElements.Texts, para)

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
local T_Dash = CreateTab("Dashboard", "📊")
local T_Trd  = CreateTab("Trade & Booth", "🏬")
local T_Evt  = CreateTab("Events & Pets", "🌽")
local T_Char = CreateTab("Character", "⚡")
local T_Set  = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; Sidebar:GetChildren()[2].TextColor3 = GLASS_THEME.Acc1

-- 1. DASHBOARD TAB
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK REAL-TIME")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 95); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0, 0.5); PImg.Position = UDim2.new(0, 8, 0.5, 0); PImg.Size = UDim2.new(0, 76, 0, 76); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 2; PStr.Color = GLASS_THEME.Acc1; PStr.Parent = PImg

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0, 98, 0, 0); PLbl.Size = UDim2.new(1, -108, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = GLASS_THEME.Text; PLbl.TextSize = 13; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

table.insert(ThemeElements.Texts, PLbl); table.insert(ThemeElements.Accents, PStr)

local G_TradeStats = AddGroup(T_Dash, "LIVE TRADE & BOOTH MONITORING")
local TradeLbl = Instance.new("TextLabel"); TradeLbl.Parent = G_TradeStats; TradeLbl.Size = UDim2.new(1, 0, 0, 75); TradeLbl.BackgroundTransparency = 1; TradeLbl.TextColor3 = GLASS_THEME.Text; TradeLbl.TextSize = 13; TradeLbl.Font = Enum.Font.GothamMedium; TradeLbl.TextXAlignment = Enum.TextXAlignment.Left; TradeLbl.TextYAlignment = Enum.TextYAlignment.Top
table.insert(ThemeElements.Texts, TradeLbl)

local G_Logs = AddGroup(T_Dash, "SYSTEM REMOTE SPY CONSOLE LOG")
local console = makeConsole(G_Logs, { Name = "Console Log", MaxLines = 100 })
local function clog(m)
    print("[MOFENKHUB GAG] " .. tostring(m))
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
        PLbl.Text = string.format("👤 Player: %s (%s)\n⚡ Ping: %d ms | 🖥️ FPS: %d\n🎮 Game: Grow a Garden (GAG)", LocalPlayer.Name, LocalPlayer.DisplayName, STATE.pingMs, STATE.fpsCurrent)
        
        local inTradeWorld = workspace:FindFirstChild("TradeWorld") or workspace:FindFirstChild("Booths")
        STATE.tradeWorldStatus = inTradeWorld and "Farmer Trade World" or "Main World"
        TradeLbl.Text = string.format("🌐 Lokasi World: %s\n🏬 Status Booth: %s\n🎨 Skin Booth Aktif: %s", STATE.tradeWorldStatus, STATE.boothStatus, F.selectedBoothSkin)
    end) end
end)

-- 2. TRADE & BOOTH TAB
local G_Trade = AddGroup(T_Trd, "AUTO FARMER TRADE WORLD & BOOTH CLAIM")
AddToggle(G_Trade, "Auto Join Farmer Trade World (Saat Terlempar ke Main)", "autoJoinTrade")
AddToggle(G_Trade, "Auto Claim Booth Kosong (Otomatis)", "autoClaimBooth")

local G_Skin = AddGroup(T_Trd, "BOOTH SKIN SELECTION")
AddDropdown(G_Skin, "Pilih Skin Booth:", KnownBoothSkins, "selectedBoothSkin", false)
AddToggle(G_Skin, "Auto Equip Skin Saat Klaim Booth", "autoEquipSkin")

local BtnManualClaim = Instance.new("TextButton"); BtnManualClaim.Parent = G_Trade; BtnManualClaim.Size = UDim2.new(1, 0, 0, 36); BtnManualClaim.Text = "🏬 KLAIM BOOTH SEKARANG"; BtnManualClaim.Font = Enum.Font.GothamBold; BtnManualClaim.TextSize = 13; BtnManualClaim.TextColor3 = GLASS_THEME.Acc1; BtnManualClaim.BackgroundColor3 = GLASS_THEME.Header; local BMC = Instance.new("UICorner"); BMC.CornerRadius = UDim.new(0,8); BMC.Parent = BtnManualClaim
table.insert(ThemeElements.Headers, BtnManualClaim); table.insert(ThemeElements.Accents, BtnManualClaim)

BtnManualClaim.MouseButton1Click:Connect(function()
    pcall(function()
        if Remotes.ClaimBooth then
            if Remotes.ClaimBooth:IsA("RemoteFunction") then Remotes.ClaimBooth:InvokeServer()
            elseif Remotes.ClaimBooth:IsA("RemoteEvent") then Remotes.ClaimBooth:FireServer() end
            Notify("Booth Claim", "Eksekusi Klaim Booth Terkirim!", 2.5)
        end
    end)
end)

-- 3. EVENTS TAB
local G_EvtCtrl = AddGroup(T_Evt, "EVENT AUTOMATION & PET REWARDS")
AddToggle(G_EvtCtrl, "Auto Claim Alien Event Pets", "autoClaimAlien")

-- 4. CHARACTER TAB
local G_Char = AddGroup(T_Char, "MOVEMENT & PROTECTION MODS")
local function applyWS()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = (F.wsOn and F.wsValue) or 16 end
end

AddToggle(G_Char, "Aktifkan WalkSpeed Modifier", "wsOn", function() applyWS() end)
AddToggle(G_Char, "Anti-AFK Protection", "afk")

-- 5. SETTINGS TAB (FULL COMPLETE CONFIG MANAGER)
local G_Theme = AddGroup(T_Set, "TEMA & KEYBIND BINDING")

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

-- FULL CONFIG PRESETS MANAGEMENT UI
local G_SetConfig = AddGroup(T_Set, "FILE CONFIG PRESETS MANAGEMENT")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 36); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 13; BtnSave.TextColor3 = GLASS_THEME.Acc1; BtnSave.BackgroundColor3 = GLASS_THEME.Header; local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,8); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName); Notify("Config Saved", "Berhasil disimpan: " .. tostring(F.cfgName)) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 36); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 13; BtnLoad.TextColor3 = GLASS_THEME.Acc1; BtnLoad.BackgroundColor3 = GLASS_THEME.Header; local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,8); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName); Notify("Config Loaded", "Berhasil dimuat: " .. tostring(F.cfgName)) end) end)

local BtnDelete = Instance.new("TextButton"); BtnDelete.Parent = G_SetConfig; BtnDelete.Size = UDim2.new(1, 0, 0, 36); BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN"; BtnDelete.Font = Enum.Font.GothamBold; BtnDelete.TextSize = 13; BtnDelete.TextColor3 = Color3.fromRGB(239, 68, 68); BtnDelete.BackgroundColor3 = GLASS_THEME.Header; local BTD = Instance.new("UICorner"); BTD.CornerRadius = UDim.new(0,8); BTD.Parent = BtnDelete

local ListTitle = Instance.new("TextLabel"); ListTitle.Parent = G_SetConfig; ListTitle.Size = UDim2.new(1, 0, 0, 24); ListTitle.Text = "📁 PILIH CONFIG TERSEDIA:"; ListTitle.TextSize = 13; ListTitle.Font = Enum.Font.GothamBold; ListTitle.TextColor3 = GLASS_THEME.Acc1; ListTitle.BackgroundTransparency = 1

local ConfigScroll = Instance.new("ScrollingFrame"); ConfigScroll.Parent = G_SetConfig; ConfigScroll.Size = UDim2.new(1, 0, 0, 110); ConfigScroll.BackgroundColor3 = GLASS_THEME.Header; ConfigScroll.BackgroundTransparency = 0.4; ConfigScroll.ScrollBarThickness = 5; ConfigScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; ConfigScroll.CanvasSize = UDim2.new(0,0,0,0)
local CSC = Instance.new("UICorner"); CSC.CornerRadius = UDim.new(0, 8); CSC.Parent = ConfigScroll

table.insert(ThemeElements.Headers, BtnSave); table.insert(ThemeElements.Accents, BtnSave)
table.insert(ThemeElements.Headers, BtnLoad); table.insert(ThemeElements.Accents, BtnLoad)
table.insert(ThemeElements.Headers, ConfigScroll); table.insert(ThemeElements.Accents, ListTitle)

local function RefreshConfigList()
    for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(CFG_FOLDER)) do
                local fileName = file:match("([^/]+)$"):gsub("%.json$", "")
                local FileBtn = Instance.new("TextButton"); FileBtn.Parent = ConfigScroll; FileBtn.Size = UDim2.new(1, 0, 0, 34); FileBtn.Text = "📄 " .. fileName; FileBtn.TextSize = 12; FileBtn.Font = Enum.Font.GothamMedium; FileBtn.TextColor3 = GLASS_THEME.Text; FileBtn.BackgroundColor3 = GLASS_THEME.Card; FileBtn.BackgroundTransparency = 0.3
                local FBC = Instance.new("UICorner"); FBC.CornerRadius = UDim.new(0, 6); FBC.Parent = FileBtn
                
                table.insert(ThemeElements.Cards, FileBtn); table.insert(ThemeElements.Texts, FileBtn)

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

local BtnRefresh = Instance.new("TextButton"); BtnRefresh.Parent = G_SetConfig; BtnRefresh.Size = UDim2.new(1, 0, 0, 34); BtnRefresh.Text = "🔄 REFRESH LIST CONFIG"; BtnRefresh.Font = Enum.Font.GothamBold; BtnRefresh.TextSize = 12; BtnRefresh.TextColor3 = GLASS_THEME.Acc1; BtnRefresh.BackgroundColor3 = GLASS_THEME.Card; local BTR = Instance.new("UICorner"); BTR.CornerRadius = UDim.new(0,8); BTR.Parent = BtnRefresh
BtnRefresh.MouseButton1Click:Connect(RefreshConfigList)
table.insert(ThemeElements.Cards, BtnRefresh); table.insert(ThemeElements.Accents, BtnRefresh)

-- ===================================================================== --
-- 6. ALL BACKEND THREADS
-- ===================================================================== --

-- 1. Anti-AFK & Disconnect Listener
local vu = game:GetService("VirtualUser")
task.spawn(function()
    while _G.__GAG_SCRIPT == generation do
        task.wait(30)
        if F.afk then
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.zero)
            end)
        end
    end
end)

pcall(function()
    local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true) or LocalPlayer.PlayerGui:FindFirstChild("PromptOverlay", true)
    if PromptOverlay then
        PromptOverlay.ChildAdded:Connect(function(child)
            if F.afk and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
                clog("Disconnect detected! Reconnecting...")
                local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
                if qot then
                    qot([[
                        task.wait(3)
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/gag.lua"))()
                    ]])
                end
                task.wait(2)
                pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            end
        end)
    end
end)

-- 2. Auto Join Trade World Thread (TokenRAPs.TeleportToListing)
task.spawn(function()
    while _G.__GAG_SCRIPT == generation do
        if F.autoJoinTrade then
            pcall(function()
                local inTradeWorld = workspace:FindFirstChild("TradeWorld") or workspace:FindFirstChild("Booths")
                if not inTradeWorld and Remotes.TeleportTrade then
                    clog("Teleporting to Farmer Trade World...")
                    if Remotes.TeleportTrade:IsA("RemoteFunction") then
                        Remotes.TeleportTrade:InvokeServer()
                    elseif Remotes.TeleportTrade:IsA("RemoteEvent") then
                        Remotes.TeleportTrade:FireServer()
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- 3. Auto Claim Booth & Skin Equip Thread (Booths.ClaimBooth & TradeBoothSkinService.Equip)
task.spawn(function()
    while _G.__GAG_SCRIPT == generation do
        if F.autoClaimBooth then
            pcall(function()
                local boothsFolder = workspace:FindFirstChild("Booths") or (workspace:FindFirstChild("TradeWorld") and workspace.TradeWorld:FindFirstChild("Booths"))
                local myBoothFound = false

                if boothsFolder then
                    for _, booth in ipairs(boothsFolder:GetChildren()) do
                        local owner = booth:FindFirstChild("Owner") or booth:GetAttribute("Owner")
                        if owner == LocalPlayer.Name then
                            myBoothFound = true
                            STATE.boothStatus = "Sudah Klaim (" .. booth.Name .. ")"
                            break
                        end
                    end

                    if not myBoothFound and Remotes.ClaimBooth then
                        for _, booth in ipairs(boothsFolder:GetChildren()) do
                            local owner = booth:FindFirstChild("Owner") or booth:GetAttribute("Owner")
                            if not owner or owner == "" then
                                local boothId = booth.Name
                                clog("Claiming Booth: " .. tostring(boothId))
                                if Remotes.ClaimBooth:IsA("RemoteFunction") then
                                    Remotes.ClaimBooth:InvokeServer(boothId)
                                elseif Remotes.ClaimBooth:IsA("RemoteEvent") then
                                    Remotes.ClaimBooth:FireServer(boothId)
                                end
                                
                                STATE.boothStatus = "Berhasil Klaim (" .. tostring(boothId) .. ")"
                                Notify("Auto Booth", "Berhasil Klaim Booth: " .. tostring(boothId), 3)
                                task.wait(0.5)

                                if F.autoEquipSkin and Remotes.EquipSkin and F.selectedBoothSkin ~= "Default" then
                                    clog("Equipping Skin: " .. tostring(F.selectedBoothSkin))
                                    if Remotes.EquipSkin:IsA("RemoteEvent") then
                                        Remotes.EquipSkin:FireServer(F.selectedBoothSkin)
                                    elseif Remotes.EquipSkin:IsA("RemoteFunction") then
                                        Remotes.EquipSkin:InvokeServer(F.selectedBoothSkin)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
        task.wait(3.5)
    end
end)

-- 4. Alien Event Claim Thread
task.spawn(function()
    while _G.__GAG_SCRIPT == generation do
        if F.autoClaimAlien and Remotes.AlienPets then
            pcall(function()
                if Remotes.AlienPets:IsA("RemoteFunction") then Remotes.AlienPets:InvokeServer()
                elseif Remotes.AlienPets:IsA("RemoteEvent") then Remotes.AlienPets:FireServer() end
            end)
        end
        task.wait(10)
    end
end)

-- 5. Auto Save Config Loop
task.spawn(function()
    while _G.__GAG_SCRIPT == generation do
        task.wait(10)
        pcall(function() saveConfig(F.cfgName) end)
    end
end)

clog("MOFENKHUB GAG V107.0 Loaded Full Successfully!")
Notify("MOFENKHUB GAG Ready!", "Remote Spy & Full Config Presets Siap Digunakan.", 4)
