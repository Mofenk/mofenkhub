-- =====================================================================
-- 👑 MOFENKHUB V50 — PREMIUM CUSTOM UI EDITION (DELTA SAFE)
-- Game: Dadu Brainrot! | 100% Standalone (Tidak butuh library luar)
-- =====================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. SISTEM FAILSAFE UI (ANTI-INVISIBLE)
-- ==========================================
local UI_Target
pcall(function() UI_Target = gethui() end)
if not UI_Target then pcall(function() UI_Target = CoreGui end) end
if not UI_Target or (typeof(UI_Target) == "Instance" and not pcall(function() return UI_Target.Name end)) then
    UI_Target = LocalPlayer:WaitForChild("PlayerGui")
end

for _, v in pairs(UI_Target:GetChildren()) do
    if v.Name == "MofenkHubPremium" then v:Destroy() end
end

-- ==========================================
-- 2. KONFIGURASI & FUNGSI GAME
-- ==========================================
_G.Mofenk = {
    AutoCollect = false, AutoRoll = false, AutoRebirth = false,
    AutoEquipBest = false, AutoEquipSquad = false,
    AutoDungeon = false, AutoShop = false, AutoQuest = false, AutoLuckyBlock = false,
    DungeonList = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"},
    DungeonNames = {"Sahur Tower", "Orcala Tower", "Bombardiro Tower", "Spiderini Tower", "Larila Tower"},
    CurrentDungeonIndex = 1
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local function safeFire(remoteName, ...)
    pcall(function()
        if Remotes and Remotes:FindFirstChild(remoteName) then
            local remote = Remotes[remoteName]
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end
    end)
end

-- ==========================================
-- 3. CUSTOM UI LIBRARY (FRAMEWORK)
-- ==========================================
local MofenkUI = {}
local Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Topbar = Color3.fromRGB(30, 30, 35),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(90, 120, 255),
    AccentHover = Color3.fromRGB(110, 140, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    ToggleOff = Color3.fromRGB(45, 45, 50),
    ToggleOn = Color3.fromRGB(80, 200, 120)
}

function MofenkUI:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MofenkHubPremium"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = UI_Target

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    -- Topbar
    local Topbar = Instance.new("Frame", MainFrame)
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)
    
    local TopbarFix = Instance.new("Frame", Topbar)
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.BackgroundColor3 = Theme.Topbar
    TopbarFix.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", Topbar)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Topbar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Dragging Logic
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
    Topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 150, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", Sidebar)
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local TabPadding = Instance.new("UIPadding", Sidebar)
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)

    -- Container for Pages
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Size = UDim2.new(1, -150, 1, -40)
    PageContainer.Position = UDim2.new(0, 150, 0, 40)
    PageContainer.BackgroundTransparency = 1

    local WindowData = {Pages = {}, Buttons = {}}
    local FirstTab = true

    function WindowData:CreateTab(tabName, icon)
        icon = icon or "📁"
        
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.BackgroundTransparency = FirstTab and 0.8 or 1
        TabBtn.Text = "  " .. icon .. "  " .. tabName
        TabBtn.TextColor3 = FirstTab and Theme.Text or Theme.TextDark
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local PageScroll = Instance.new("ScrollingFrame", PageContainer)
        PageScroll.Size = UDim2.new(1, -20, 1, -20)
        PageScroll.Position = UDim2.new(0, 10, 0, 10)
        PageScroll.BackgroundTransparency = 1
        PageScroll.ScrollBarThickness = 3
        PageScroll.Visible = FirstTab
        
        local PageLayout = Instance.new("UIListLayout", PageScroll)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        table.insert(WindowData.Pages, PageScroll)
        table.insert(WindowData.Buttons, TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for i, page in ipairs(WindowData.Pages) do
                page.Visible = (page == PageScroll)
                local btn = WindowData.Buttons[i]
                TweenService:Create(btn, TweenInfo.new(0.3), {
                    BackgroundTransparency = (page == PageScroll) and 0.8 or 1,
                    TextColor3 = (page == PageScroll) and Theme.Text or Theme.TextDark
                }):Play()
            end
        end)

        FirstTab = false

        local TabElements = {}
        
        function TabElements:CreateToggle(text, configKey, callback)
            local ToggleFrame = Instance.new("Frame", PageScroll)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            ToggleFrame.BackgroundColor3 = Theme.Topbar
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel", ToggleFrame)
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Indicator = Instance.new("Frame", ToggleFrame)
            Indicator.Size = UDim2.new(0, 40, 0, 20)
            Indicator.Position = UDim2.new(1, -55, 0.5, -10)
            Indicator.BackgroundColor3 = Theme.ToggleOff
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame", Indicator)
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local Btn = Instance.new("TextButton", ToggleFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""

            Btn.MouseButton1Click:Connect(function()
                _G.Mofenk[configKey] = not _G.Mofenk[configKey]
                local state = _G.Mofenk[configKey]
                
                TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}):Play()
                TweenService:Create(Circle, TweenInfo.new(0.3), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                
                if callback then callback(state) end
            end)
        end

        function TabElements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", PageScroll)
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

            Btn.MouseButton1Down:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentHover}):Play()
            end)
            Btn.MouseButton1Up:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            end)
            Btn.MouseButton1Click:Connect(function() pcall(callback) end)
            
            return Btn
        end

        function TabElements:CreateLabel(text)
            local Lbl = Instance.new("TextLabel", PageScroll)
            Lbl.Size = UDim2.new(1, 0, 0, 30)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Theme.Accent
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Center
            return Lbl
        end

        return TabElements
    end

    return WindowData
end

-- ==========================================
-- 4. MEMBANGUN UI & MENU
-- ==========================================
local Window = MofenkUI:CreateWindow("👑 MOFENK HUB V50")

-- TAB 1: UTAMA
local TabUtama = Window:CreateTab("Utama", "🏠")
TabUtama:CreateLabel("--- Auto Farming Dasar ---")
TabUtama:CreateToggle("🧲 Auto Collect Uang", "AutoCollect")
TabUtama:CreateToggle("🎲 Auto Roll Dadu", "AutoRoll")
TabUtama:CreateToggle("♻️ Auto Rebirth (Max)", "AutoRebirth")

-- TAB 2: INVENTORY & SQUAD
local TabInven = Window:CreateTab("Equipment", "🛡️")
TabInven:CreateLabel("--- Manajemen Pet & Squad ---")
TabInven:CreateToggle("🏆 Auto Equip Best Brainrot", "AutoEquipBest")
TabInven:CreateToggle("⚔️ Auto Equip Battle Squad", "AutoEquipSquad")

-- TAB 3: DUNGEON
local TabDungeon = Window:CreateTab("Dungeon", "🔥")
TabDungeon:CreateLabel("--- Pengaturan Tower ---")

local targetText = "🎯 Target: " .. _G.Mofenk.DungeonNames[_G.Mofenk.CurrentDungeonIndex]
local DungeonBtn = TabDungeon:CreateButton(targetText, function() end)
DungeonBtn.MouseButton1Click:Connect(function()
    _G.Mofenk.CurrentDungeonIndex = _G.Mofenk.CurrentDungeonIndex + 1
    if _G.Mofenk.CurrentDungeonIndex > #_G.Mofenk.DungeonNames then _G.Mofenk.CurrentDungeonIndex = 1 end
    DungeonBtn.Text = "🎯 Target: " .. _G.Mofenk.DungeonNames[_G.Mofenk.CurrentDungeonIndex]
end)

TabDungeon:CreateToggle("⚔️ Mulai Auto Dungeon", "AutoDungeon")
TabDungeon:CreateToggle("🛍️ Auto Beli Dungeon Shop", "AutoShop")

-- TAB 4: MISC & QUEST
local TabMisc = Window:CreateTab("Lainnya", "🎁")
TabMisc:CreateLabel("--- Ekstra Fitur ---")
TabMisc:CreateToggle("📜 Auto Claim Quests", "AutoQuest")
TabMisc:CreateToggle("🎁 Auto Buka Lucky Blocks", "AutoLuckyBlock")
TabMisc:CreateButton("🌐 Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- ==========================================
-- 5. BACKGROUND LOOP (FARMING LOGIC)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.Mofenk.AutoCollect then safeFire("MoneyCollected") end
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoEquipBest then safeFire("EquipBest") end
            if _G.Mofenk.AutoEquipSquad then safeFire("EquipBestBattleSquadRequest") end
            if _G.Mofenk.AutoQuest then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoLuckyBlock then safeFire("OpenLuckyBlocks") end
            if _G.Mofenk.AutoShop then safeFire("DungeonShopAutoBuy") end
            
            if _G.Mofenk.AutoDungeon then 
                local targetId = _G.Mofenk.DungeonList[_G.Mofenk.CurrentDungeonIndex]
                safeFire("RequestDungeonTeleport", targetId) 
            end
        end)
    end
end)

-- Anti AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- Notifikasi Sukses
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "👑 MofenkHub",
        Text = "V50 Premium UI Berhasil Dimuat!",
        Duration = 5,
    })
end)
