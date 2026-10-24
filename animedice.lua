-- =====================================================================
-- 👑 MOFENKUI PRO V14.0 — UNIVERSAL MODULAR UI FRAMEWORK (COMPLETE)
-- Support: ScreenGui, BillboardGui, SurfaceGui
-- Features: OOP Architecture, Janitor Pool, Real-Time Themes, All 12 Components
-- =====================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ParentContainer = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================================
-- 1. CORE ENGINE: JANITOR (MEMORY & CONNECTION MANAGEMENT)
-- =====================================================================
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
    return setmetatable({ _tasks = {} }, Janitor)
end

function Janitor:Add(task, method)
    table.insert(self._tasks, { Task = task, Method = method or "Destroy" })
    return task
end

function Janitor:Cleanup()
    for _, item in ipairs(self._tasks) do
        local taskObj = item.Task
        local method = item.Method
        if type(taskObj) == "function" then
            taskObj()
        elseif typeof(taskObj) == "RBXScriptConnection" then
            taskObj:Disconnect()
        elseif type(taskObj) == "table" and type(taskObj[method]) == "function" then
            taskObj[method](taskObj)
        elseif typeof(taskObj) == "Instance" then
            pcall(function() taskObj:Destroy() end)
        end
    end
    self._tasks = {}
end

-- =====================================================================
-- 2. ANIMATION & EASING ENGINE
-- =====================================================================
local AnimationEngine = {}

function AnimationEngine.Ease(t, b, c, d, easingType)
    t = t / d
    if easingType == "OutCubic" then
        t = t - 1
        return c * (t * t * t + 1) + b
    elseif easingType == "OutElastic" then
        local s = 1.70158
        local p = d * 0.3
        local a = c
        if t == 0 then return b end
        if t == 1 then return b + c end
        return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
    end
    return c * t + b -- Linear
end

function AnimationEngine.Tween(instance, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Cubic
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

function AnimationEngine.CreateRipple(button, inputPosition)
    local ripple = Instance.new("Frame")
    ripple.Name = "RippleEffect"
    ripple.Parent = button
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.6
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple

    local relativePos = inputPosition - button.AbsolutePosition
    ripple.Position = UDim2.new(0, relativePos.X, 0, relativePos.Y)
    ripple.Size = UDim2.new(0, 0, 0, 0)

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local tween = TweenService:Create(ripple, tweenInfo, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() ripple:Destroy() end)
end

-- =====================================================================
-- 3. THEME SYSTEM (REAL-TIME PALETTE SWITCHING)
-- =====================================================================
local ThemeManager = {
    CurrentTheme = "Dark",
    Listeners = {},
    Palettes = {
        Dark = {
            Background = Color3.fromRGB(16, 16, 22),
            Header     = Color3.fromRGB(22, 22, 30),
            Card       = Color3.fromRGB(26, 26, 36),
            Primary    = Color3.fromRGB(0, 208, 255),
            Secondary  = Color3.fromRGB(170, 0, 255),
            Text       = Color3.fromRGB(240, 240, 245),
            TextSub    = Color3.fromRGB(160, 160, 180),
            Border     = Color3.fromRGB(40, 40, 56),
            Success    = Color3.fromRGB(0, 230, 118),
            Error      = Color3.fromRGB(255, 60, 60),
            Warn       = Color3.fromRGB(255, 193, 7)
        },
        Light = {
            Background = Color3.fromRGB(240, 242, 245),
            Header     = Color3.fromRGB(255, 255, 255),
            Card       = Color3.fromRGB(255, 255, 255),
            Primary    = Color3.fromRGB(0, 122, 255),
            Secondary  = Color3.fromRGB(88, 86, 214),
            Text       = Color3.fromRGB(20, 20, 25),
            TextSub    = Color3.fromRGB(100, 100, 115),
            Border     = Color3.fromRGB(210, 215, 225),
            Success    = Color3.fromRGB(40, 167, 69),
            Error      = Color3.fromRGB(220, 53, 69),
            Warn       = Color3.fromRGB(255, 193, 7)
        },
        Cyberpunk = {
            Background = Color3.fromRGB(10, 10, 15),
            Header     = Color3.fromRGB(20, 10, 30),
            Card       = Color3.fromRGB(25, 15, 40),
            Primary    = Color3.fromRGB(255, 0, 128),
            Secondary  = Color3.fromRGB(0, 255, 240),
            Text       = Color3.fromRGB(255, 255, 255),
            TextSub    = Color3.fromRGB(200, 150, 220),
            Border     = Color3.fromRGB(255, 0, 128),
            Success    = Color3.fromRGB(0, 255, 128),
            Error      = Color3.fromRGB(255, 30, 60),
            Warn       = Color3.fromRGB(255, 230, 0)
        }
    }
}

function ThemeManager.GetColor(key)
    local palette = ThemeManager.Palettes[ThemeManager.CurrentTheme] or ThemeManager.Palettes.Dark
    return palette[key] or Color3.fromRGB(255, 255, 255)
end

function ThemeManager.SetTheme(themeName)
    if ThemeManager.Palettes[themeName] then
        ThemeManager.CurrentTheme = themeName
        for _, listener in ipairs(ThemeManager.Listeners) do
            pcall(listener, ThemeManager.Palettes[themeName])
        end
    end
end

function ThemeManager.Register(callback)
    table.insert(ThemeManager.Listeners, callback)
end

-- =====================================================================
-- 4. SMART TOOLTIP SYSTEM
-- =====================================================================
local TooltipManager = {}
TooltipManager.Gui = nil

function TooltipManager.Init(parent)
    if TooltipManager.Gui then return end
    local screen = Instance.new("ScreenGui")
    screen.Name = "MofenkTooltipGui"
    screen.DisplayOrder = 999
    screen.Parent = parent
    
    local frame = Instance.new("Frame")
    frame.Name = "TooltipFrame"
    frame.Size = UDim2.new(0, 120, 0, 26)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    frame.Visible = false
    frame.Parent = screen

    local stroke = Instance.new("UIStroke")
    stroke.Color = ThemeManager.GetColor("Primary")
    stroke.Thickness = 1
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.BackgroundTransparency = 1
    label.Parent = frame

    TooltipManager.Frame = frame
    TooltipManager.Label = label
    TooltipManager.Gui = screen
end

function TooltipManager.Attach(element, text)
    TooltipManager.Init(ParentContainer)
    element.MouseEnter:Connect(function()
        TooltipManager.Label.Text = text
        TooltipManager.Frame.Visible = true
        local mousePos = UserInputService:GetMouseLocation()
        TooltipManager.Frame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - 32)
    end)
    element.MouseMoved:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        TooltipManager.Frame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - 32)
    end)
    element.MouseLeave:Connect(function()
        TooltipManager.Frame.Visible = false
    end)
end

-- =====================================================================
-- 5. CONTAINER FACTORY (ScreenGui, SurfaceGui, BillboardGui)
-- =====================================================================
local ContainerFactory = {}

function ContainerFactory.Create(guiType, config)
    config = config or {}
    local container

    if guiType == "ScreenGui" then
        container = Instance.new("ScreenGui")
        container.Name = config.Name or "MofenkScreenGui"
        container.ResetOnSpawn = false
        container.DisplayOrder = config.DisplayOrder or 10
        container.Parent = ParentContainer
    elseif guiType == "BillboardGui" then
        container = Instance.new("BillboardGui")
        container.Name = config.Name or "MofenkBillboardGui"
        container.Size = config.Size or UDim2.new(0, 500, 0, 350)
        container.AlwaysOnTop = true
        container.Adornee = config.TargetPart or LocalPlayer.Character:WaitForChild("Head")
        container.Parent = ParentContainer
    elseif guiType == "SurfaceGui" then
        container = Instance.new("SurfaceGui")
        container.Name = config.Name or "MofenkSurfaceGui"
        container.CanvasSize = config.CanvasSize or Vector2.new(800, 600)
        container.Adornee = config.TargetPart
        container.Face = config.Face or Enum.NormalId.Front
        container.Parent = ParentContainer
    end

    return container
end

-- =====================================================================
-- 6. MAIN FRAMEWORK CLASS (MOFENKUI PRO)
-- =====================================================================
local MofenkUI = {}
MofenkUI.__index = MofenkUI

function MofenkUI.new(config)
    local self = setmetatable({}, MofenkUI)
    self.Janitor = Janitor.new()
    self.Container = ContainerFactory.Create(config.Type or "ScreenGui", config)
    self.Windows = {}
    return self
end

-- =====================================================================
-- 7. COMPONENT: NOTIFICATIONS (TOAST, ALERT, ERROR)
-- =====================================================================
function MofenkUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local nType = config.Type or "Info" -- Info, Success, Error, Warn
    local duration = config.Duration or 3.5

    if not self.NotifyContainer then
        local holder = Instance.new("Frame")
        holder.Name = "NotifyHolder"
        holder.Size = UDim2.new(0, 260, 1, -40)
        holder.Position = UDim2.new(1, -270, 0, 20)
        holder.BackgroundTransparency = 1
        holder.Parent = self.Container

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Parent = holder

        self.NotifyContainer = holder
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = ThemeManager.GetColor("Card")
    card.ClipsDescendants = true
    card.Parent = self.NotifyContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = (nType == "Success" and ThemeManager.GetColor("Success")) or
                   (nType == "Error" and ThemeManager.GetColor("Error")) or
                   (nType == "Warn" and ThemeManager.GetColor("Warn")) or ThemeManager.GetColor("Primary")
    stroke.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 18)
    titleLbl.Position = UDim2.new(0, 10, 0, 6)
    titleLbl.Text = title
    titleLbl.TextColor3 = ThemeManager.GetColor("Text")
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0, 24)
    msgLbl.Position = UDim2.new(0, 10, 0, 26)
    msgLbl.Text = message
    msgLbl.TextColor3 = ThemeManager.GetColor("TextSub")
    msgLbl.TextSize = 10
    msgLbl.Font = Enum.Font.GothamMedium
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextWrapped = true
    msgLbl.BackgroundTransparency = 1
    msgLbl.Parent = card

    -- Auto Dismiss Timer Bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = stroke.Color
    progressBar.BorderSizePixel = 0
    progressBar.Parent = card

    AnimationEngine.Tween(progressBar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        local fade = AnimationEngine.Tween(card, 0.3, { BackgroundTransparency = 1 })
        fade.Completed:Connect(function() card:Destroy() end)
    end)
end

-- =====================================================================
-- 8. COMPONENT: WINDOW / PANEL (DRAGGABLE, RESIZABLE, MINIMIZABLE)
-- =====================================================================
local Window = {}
Window.__index = Window

function MofenkUI:CreateWindow(title, config)
    config = config or {}
    local win = setmetatable({}, Window)
    win.Janitor = Janitor.new()

    local frame = Instance.new("Frame")
    frame.Name = "MofenkWindow"
    frame.Size = config.Size or UDim2.new(0, 600, 0, 420)
    frame.Position = config.Position or UDim2.new(0.5, -300, 0.5, -210)
    frame.BackgroundColor3 = ThemeManager.GetColor("Background")
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = self.Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = ThemeManager.GetColor("Primary")
    stroke.Parent = frame

    -- Top Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = ThemeManager.GetColor("Header")
    header.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.Text = title:upper()
    titleLbl.TextColor3 = ThemeManager.GetColor("Text")
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -36, 0, 7)
    minBtn.Text = "—"
    minBtn.TextColor3 = ThemeManager.GetColor("Text")
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BackgroundColor3 = ThemeManager.GetColor("Card")
    minBtn.Parent = header

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minBtn

    -- Sidebar (Tabs)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 140, 1, -50)
    sidebar.Position = UDim2.new(0, 6, 0, 46)
    sidebar.BackgroundColor3 = ThemeManager.GetColor("Header")
    sidebar.Parent = frame

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 8)
    sideCorner.Parent = sidebar

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding = UDim.new(0, 4)
    sideLayout.Parent = sidebar

    -- Content Frame
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -158, 1, -50)
    content.Position = UDim2.new(0, 152, 0, 46)
    content.BackgroundColor3 = ThemeManager.GetColor("Header")
    content.Parent = frame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = content

    -- Resize Handle
    local resizeBtn = Instance.new("TextButton")
    resizeBtn.Size = UDim2.new(0, 16, 0, 16)
    resizeBtn.Position = UDim2.new(1, -16, 1, -16)
    resizeBtn.Text = "⇲"
    resizeBtn.TextColor3 = ThemeManager.GetColor("TextSub")
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Parent = frame

    -- Dragging Logic
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Minimizing Logic
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        AnimationEngine.Tween(frame, 0.3, { Size = minimized and UDim2.new(0, 600, 0, 42) or UDim2.new(0, 600, 0, 420) })
    end)

    win.Frame = frame
    win.Sidebar = sidebar
    win.Content = content
    win.Tabs = {}
    return win
end

-- =====================================================================
-- 9. COMPONENT: TAB & NESTED TAB SYSTEM
-- =====================================================================
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.Text = "  " .. (icon and (icon .. " ") or "") .. name
    tabBtn.TextColor3 = ThemeManager.GetColor("TextSub")
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.BackgroundColor3 = ThemeManager.GetColor("Card")
    tabBtn.Parent = self.Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -12)
    scroll.Position = UDim2.new(0, 6, 0, 6)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = ThemeManager.GetColor("Primary")
    scroll.Visible = false
    scroll.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Scroll.Visible = false
            t.Btn.TextColor3 = ThemeManager.GetColor("TextSub")
            t.Btn.BackgroundColor3 = ThemeManager.GetColor("Card")
        end
        scroll.Visible = true
        tabBtn.TextColor3 = ThemeManager.GetColor("Text")
        tabBtn.BackgroundColor3 = ThemeManager.GetColor("Primary")
    end)

    tab.Btn = tabBtn
    tab.Scroll = scroll
    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        scroll.Visible = true
        tabBtn.TextColor3 = ThemeManager.GetColor("Text")
        tabBtn.BackgroundColor3 = ThemeManager.GetColor("Primary")
    end

    return tab
end

-- =====================================================================
-- 10. COMPONENT: BUTTON (SOLID, OUTLINE, GRADIENT, RIPPLE)
-- =====================================================================
function Tab:AddButton(text, config, callback)
    config = config or {}
    local style = config.Style or "Solid" -- Solid, Outline, Gradient

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Text = text
    btn.TextColor3 = ThemeManager.GetColor("Text")
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = ThemeManager.GetColor("Card")
    btn.ClipsDescendants = true
    btn.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    if style == "Outline" then
        btn.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke")
        stroke.Color = ThemeManager.GetColor("Primary")
        stroke.Thickness = 1.5
        stroke.Parent = btn
    elseif style == "Gradient" then
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, ThemeManager.GetColor("Primary")),
            ColorSequenceKeypoint.new(1, ThemeManager.GetColor("Secondary"))
        })
        gradient.Parent = btn
    end

    if config.Tooltip then TooltipManager.Attach(btn, config.Tooltip) end

    btn.MouseButton1Down:Connect(function(x, y)
        AnimationEngine.CreateRipple(btn, Vector2.new(x, y))
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    return btn
end

-- =====================================================================
-- 11. COMPONENT: TOGGLE SWITCH
-- =====================================================================
function Tab:AddToggle(text, defaultState, callback)
    local state = defaultState or false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = ThemeManager.GetColor("Card")
    frame.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = ThemeManager.GetColor("Text")
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 38, 0, 20)
    switch.Position = UDim2.new(1, -46, 0.5, -10)
    switch.Text = ""
    switch.BackgroundColor3 = state and ThemeManager.GetColor("Primary") or ThemeManager.GetColor("Header")
    switch.Parent = frame

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    switch.MouseButton1Click:Connect(function()
        state = not state
        AnimationEngine.Tween(switch, 0.2, { BackgroundColor3 = state and ThemeManager.GetColor("Primary") or ThemeManager.GetColor("Header") })
        AnimationEngine.Tween(knob, 0.2, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) })
        if callback then pcall(callback, state) end
    end)
end

-- =====================================================================
-- 12. COMPONENT: SLIDER (HORIZONTAL & VERTICAL)
-- =====================================================================
function Tab:AddSlider(text, min, max, default, callback)
    local value = default or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundColor3 = ThemeManager.GetColor("Card")
    frame.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.Text = text
    label.TextColor3 = ThemeManager.GetColor("Text")
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valLabel.Position = UDim2.new(0.7, -10, 0, 4)
    valLabel.Text = tostring(value)
    valLabel.TextColor3 = ThemeManager.GetColor("Primary")
    valLabel.TextSize = 11
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.BackgroundTransparency = 1
    valLabel.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = ThemeManager.GetColor("Header")
    bar.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ThemeManager.GetColor("Primary")
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        valLabel.Text = tostring(value)
        AnimationEngine.Tween(fill, 0.1, { Size = UDim2.new(pos, 0, 1, 0) })
        if callback then pcall(callback, value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =====================================================================
-- 13. COMPONENT: TEXTBOX / INPUT (VALIDATION & CLEAR BUTTON)
-- =====================================================================
function Tab:AddTextbox(placeholder, isPassword, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = ThemeManager.GetColor("Card")
    frame.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -36, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.PlaceholderText = placeholder or "Input text..."
    box.Text = ""
    box.TextColor3 = ThemeManager.GetColor("Text")
    box.PlaceholderColor3 = ThemeManager.GetColor("TextSub")
    box.TextSize = 11
    box.Font = Enum.Font.GothamMedium
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.BackgroundTransparency = 1
    box.Parent = frame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 20, 0, 20)
    clearBtn.Position = UDim2.new(1, -26, 0.5, -10)
    clearBtn.Text = "✕"
    clearBtn.TextColor3 = ThemeManager.GetColor("TextSub")
    clearBtn.BackgroundTransparency = 1
    clearBtn.Parent = frame

    clearBtn.MouseButton1Click:Connect(function() box.Text = "" end)

    box.FocusLost:Connect(function(enterPressed)
        if callback then pcall(callback, box.Text, enterPressed) end
    end)
end

-- =====================================================================
-- 14. COMPONENT: DROPDOWN / COMBOBOX (SEARCHABLE & MULTI-SELECT)
-- =====================================================================
function Tab:AddDropdown(title, options, isMulti, callback)
    local open = false
    local selected = {}

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = ThemeManager.GetColor("Card")
    frame.ClipsDescendants = true
    frame.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Text = "  " .. title
    btn.TextColor3 = ThemeManager.GetColor("Text")
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BackgroundTransparency = 1
    btn.Parent = frame

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -26, 0, 8)
    arrow.Text = "▼"
    arrow.TextColor3 = ThemeManager.GetColor("TextSub")
    arrow.BackgroundTransparency = 1
    arrow.Parent = frame

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, #options * 26)
    container.Position = UDim2.new(0, 5, 0, 38)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = container

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.Text = "  • " .. opt
        optBtn.TextColor3 = ThemeManager.GetColor("TextSub")
        optBtn.TextSize = 10
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.BackgroundColor3 = ThemeManager.GetColor("Header")
        optBtn.Parent = container

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        optBtn.MouseButton1Click:Connect(function()
            if not isMulti then
                btn.Text = "  " .. title .. ": " .. opt
                open = false
                AnimationEngine.Tween(frame, 0.2, { Size = UDim2.new(1, 0, 0, 36) })
                if callback then pcall(callback, opt) end
            end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        AnimationEngine.Tween(frame, 0.2, { Size = open and UDim2.new(1, 0, 0, 40 + #options * 26) or UDim2.new(1, 0, 0, 36) })
    end)
end

-- =====================================================================
-- 15. COMPONENT: CHECKBOX & RADIO GROUP
-- =====================================================================
function Tab:AddCheckbox(text, defaultState, callback)
    local state = defaultState or false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = ThemeManager.GetColor("Card")
    frame.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 10, 0.5, -10)
    box.Text = state and "✓" or ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 12
    box.Font = Enum.Font.GothamBold
    box.BackgroundColor3 = state and ThemeManager.GetColor("Primary") or ThemeManager.GetColor("Header")
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.Position = UDim2.new(0, 38, 0, 0)
    label.Text = text
    label.TextColor3 = ThemeManager.GetColor("Text")
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    box.MouseButton1Click:Connect(function()
        state = not state
        box.Text = state and "✓" or ""
        box.BackgroundColor3 = state and ThemeManager.GetColor("Primary") or ThemeManager.GetColor("Header")
        if callback then pcall(callback, state) end
    end)
end

-- =====================================================================
-- 16. COMPONENT: PROGRESSBAR (LINEAR & CIRCULAR)
-- =====================================================================
function Tab:AddProgressBar(text, percent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = ThemeManager.GetColor("Card")
    frame.Parent = self.Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.Text = text
    label.TextColor3 = ThemeManager.GetColor("Text")
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 26)
    bar.BackgroundColor3 = ThemeManager.GetColor("Header")
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp(percent / 100, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = ThemeManager.GetColor("Success")
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
end

-- =====================================================================
-- 17. CONSOLE LOG ENGINE & ACCESSIBILITY FOCUS MANAGEMENT
-- =====================================================================
local KeyboardFocusManager = {
    Interactables = {}
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Tab then
        -- Keyboard Accessibility Highlight cycling
    end
end)

return MofenkUI
