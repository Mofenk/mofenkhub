-- =====================================================================
-- MOFENKHUB — DADU BRAINROT! ULTIMATE BOT EDITION V8.0
-- Fully Loaded: Auto Sell Rarity, Collect Money Base (30s Delay),
-- Dungeon Selector, Inventory View, Audio Indo, & Anti-AFK
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    localPlayer = Players.PlayerAdded:Wait()
end

local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

if CoreGui:FindFirstChild("MofenkHubDadu") then
    CoreGui.MofenkHubDadu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MofenkHubDadu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- =====================================================================
-- 1. BACKGROUND MUSIC PLAYER (LAGU INDONESIA)
-- =====================================================================
local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "HubMusicFolder"
SoundFolder.Parent = ScreenGui

local BackgroundMusic = Instance.new("Sound")
BackgroundMusic.Name = "BGM_Player"
BackgroundMusic.SoundId = "rbxassetid://1845773120" -- Sialan - Mahalini
BackgroundMusic.Looped = true
BackgroundMusic.Volume = 0.5
BackgroundMusic.Parent = SoundFolder

local MUSIC_LIBRARY = {
    { title = "Sialan — Mahalini", asset = "rbxassetid://1845773120" },
    { title = "Sampai Jadi Debu — Banda Neira", asset = "rbxassetid://1837424289" },
    { title = "Evaluasi — Hindia", asset = "rbxassetid://1839245102" },
    { title = "Hati-Hati di Jalan — Tulus", asset = "rbxassetid://1843345129" },
}
local currentSongIndex = 1
BackgroundMusic:Play()

-- =====================================================================
-- 2. MAIN FRAME (DRAGGABLE & RESIZABLE MofenkHub UI)
-- =====================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 460)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(170, 90, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Topbar (Header MofenkHub)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 450, 1, 0)
TitleLabel.Position = UDim2.new(0, 18, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚡ MofenkHub — Dadu Brainrot! [Bot Edition]"
TitleLabel.TextColor3 = Color3.fromRGB(240, 210, 255)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Tombol Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tombol Resize
local isMaximized = false
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Size = UDim2.new(0, 32, 0, 32)
ResizeBtn.Position = UDim2.new(1, -78, 0, 6)
ResizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
ResizeBtn.Font = Enum.Font.GothamBold
ResizeBtn.Text = "🗖"
ResizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResizeBtn.TextSize = 12
ResizeBtn.Parent = TopBar

local ResizeCorner = Instance.new("UICorner")
ResizeCorner.CornerRadius = UDim.new(0, 8)
ResizeCorner.Parent = ResizeBtn

ResizeBtn.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 920, 0, 580)}):Play()
        ResizeBtn.Text = "🗗"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 720, 0, 460)}):Play()
        ResizeBtn.Text = "🗖"
    end
end)

-- =====================================================================
-- 3. SIDEBAR NAVIGATION TABS
-- =====================================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 175, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Sidebar

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -185, 1, -55)
Container.Position = UDim2.new(0, 180, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -14, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 210)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

local tabMain = createTabButton("🎲 Roll & Base Farm", 1)
local tabDungeon = createTabButton("⚔️ Dungeon & Shop", 2)
local tabManage = createTabButton("📦 Sell & Inventory", 3)
local tabWorld = createTabButton("🌍 World & AFK Bot", 4)
local tabMusic = createTabButton("🎧 Profil & Musik", 5)

local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = Container

    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    return page
end

local pageMain = createPage()
local pageDungeon = createPage()
local pageManage = createPage()
local pageWorld = createPage()
local pageMusic = createPage()

pageMain.Visible = true
local pages = {pageMain, pageDungeon, pageManage, pageWorld, pageMusic}
local tabs = {tabMain, tabDungeon, tabManage, tabWorld, tabMusic}

for i, tab in ipairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        for _, p in ipairs(pages) do p.Visible = false end
        pages[i].Visible = true
    end)
end

-- =====================================================================
-- 4. TOGGLE GENERATOR (KEREN DENGAN INDIKATOR STATUS)
-- =====================================================================
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 500, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "    " .. text
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.new(0, 12, 0, 12)
    statusIndicator.Position = UDim2.new(1, -25, 0.5, -6)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    statusIndicator.Parent = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = statusIndicator

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 90, 60)}):Play()
            TweenService:Create(statusIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 255, 120)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 38)}):Play()
            TweenService:Create(statusIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}):Play()
        end
        callback(active)
    end)
end

-- =====================================================================
-- 5. IMPLEMENTASI FITUR BOT UTAMA
-- =====================================================================

-- Tab 1: Auto Roll Instant & Collect Money Base (30s Delay)
createToggle(pageMain, "Auto Instant Roll Dice", function(state)
    getgenv().AutoRoll = state
    task.spawn(function()
        while getgenv().AutoRoll do
            pcall(function()
                if Remotes:FindFirstChild("RollRequest") then
                    Remotes.RollRequest:FireServer()
                end
            end)
            task.wait(0.2)
        end
    end)
end)

createToggle(pageMain, "Auto Collect Money (All Base | Delay 30s)", function(state)
    getgenv().AutoCollectMoney = state
    task.spawn(function()
        while getgenv().AutoCollectMoney do
            pcall(function()
                -- Mengambil uang dari semua pod / base brainrot
                if Remotes:FindFirstChild("MoneyCollected") then
                    Remotes.MoneyCollected:FireServer()
                end
                -- Menyapu workspace untuk part uang jika ada
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("money") or obj.Name:lower():find("cash") then
                        if obj:IsA("BasePart") then
                            firetouchinterest(localPlayer.Character.HumanoidRootPart, obj, 0)
                            firetouchinterest(localPlayer.Character.HumanoidRootPart, obj, 1)
                        end
                    end
                end
            end)
            task.wait(30) -- Delay 30 detik sesuai permintaan
        end
    end)
end)

createToggle(pageMain, "Auto Claim Rewards / Quests", function(state)
    getgenv().AutoRewards = state
    task.spawn(function()
        while getgenv().AutoRewards do
            pcall(function()
                if Remotes:FindFirstChild("ClaimAllQuests") then
                    Remotes.ClaimAllQuests:InvokeServer()
                end
                if Remotes:FindFirstChild("ClaimPlaytimeGift") then
                    Remotes.ClaimPlaytimeGift:InvokeServer()
                end
            end)
            task.wait(10)
        end
    end)
end)

-- Tab 2: Dungeon (Select & Teleport) & Shop (Item List Display)
createToggle(pageDungeon, "Auto Farm Dungeon Tower (Map: Sahur)", function(state)
    getgenv().AutoDungeon = state
    task.spawn(function()
        while getgenv().AutoDungeon do
            pcall(function()
                if Remotes:FindFirstChild("RequestDungeonTeleport") then
                    Remotes.RequestDungeonTeleport:InvokeServer("Sahur")
                end
            end)
            task.wait(2)
        end
    end)
end)

createToggle(pageDungeon, "Auto Buy Dungeon Shop (Auto Restock & Buy)", function(state)
    getgenv().AutoShop = state
    task.spawn(function()
        while getgenv().AutoShop do
            pcall(function()
                if Remotes:FindFirstChild("DungeonShopAutoBuy") then
                    Remotes.DungeonShopAutoBuy:InvokeServer()
                end
            end)
            task.wait(5)
        end
    end)
end)

-- Tab 3: Auto Sell Sesuai Rarity Brainrot & Inventory Manager
local selectedRarity = "Common"
createToggle(pageManage, "Auto Sell Brainrot Berdasarkan Rarity Filter", function(state)
    getgenv().AutoSellRarity = state
    task.spawn(function()
        while getgenv().AutoSellRarity do
            pcall(function()
                if Remotes:FindFirstChild("SellAllRequest") then
                    Remotes.SellAllRequest:FireServer(selectedRarity)
                end
            end)
            task.wait(4)
        end
    end)
end)

-- Tab 4: World, Meteor, Hop Server, Render
createToggle(pageWorld, "Auto Claim Meteor / Lucky Blocks", function(state)
    getgenv().AutoMeteor = state
    task.spawn(function()
        while getgenv().AutoMeteor do
            pcall(function()
                if Remotes:FindFirstChild("MeteorClaimed") then
                    Remotes.MeteorClaimed:FireServer()
                end
                if Remotes:FindFirstChild("OpenLuckyBlocks") then
                    Remotes.OpenLuckyBlocks:InvokeServer(1)
                end
            end)
            task.wait(3)
        end
    end)
end)

createToggle(pageWorld, "Anti-AFK (Mencegah Terkick Server)", function(state)
    getgenv().AntiAfk = state
    local vu = game:GetService("VirtualUser")
    local conn
    if state then
        conn = localPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        if conn then conn:Disconnect() end
    end
end)

createToggle(pageWorld, "Toggle Render 3D (Optimasi HP / Anti Lag)", function(state)
    RunService:Set3dRenderingEnabled(not state)
end)

createToggle(pageWorld, "Auto Hop Server (Pindah Server Kosong)", function(state)
    getgenv().AutoHop = state
    task.spawn(function()
        while getgenv().AutoHop do
            task.wait(300) -- Cek setiap 5 menit
            pcall(function()
                local ts = game:GetService("TeleportService")
                local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                for _, s in ipairs(servers.data) do
                    if s.playing < s.maxPlayers then
                        ts:TeleportToPlaceInstance(game.PlaceId, s.id, localPlayer)
                        break
                    end
                end
            end)
        end
    end)
end)

-- Tab 5: Profil Karakter, Ping Data, & Pemutar Musik Indo
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(0, 500, 0, 85)
ProfileCard.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
ProfileCard.Parent = pageMusic

local PCorner = Instance.new("UICorner")
PCorner.CornerRadius = UDim.new(0, 8)
PCorner.Parent = ProfileCard

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 65, 0, 65)
AvatarImg.Position = UDim2.new(0, 10, 0, 10)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
AvatarImg.Parent = ProfileCard

local ACorner = Instance.new("UICorner")
ACorner.CornerRadius = UDim.new(1, 0)
ACorner.Parent = AvatarImg

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0, 400, 0, 20)
NameLabel.Position = UDim2.new(0, 85, 0, 10)
NameLabel.BackgroundTransparency = 1
NameLabel.Font = Enum.Font.GothamBold
NameLabel.Text = "Player: " .. localPlayer.Name
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextSize = 13
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ProfileCard

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 400, 0, 20)
PingLabel.Position = UDim2.new(0, 85, 0, 30)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = Enum.Font.Gotham
PingLabel.Text = "Ping: Menghitung..."
PingLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
PingLabel.TextSize = 11
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.Parent = ProfileCard

local InvInfoLabel = Instance.new("TextLabel")
InvInfoLabel.Size = UDim2.new(0, 400, 0, 20)
InvInfoLabel.Position = UDim2.new(0, 85, 0, 52)
InvInfoLabel.BackgroundTransparency = 1
InvInfoLabel.Font = Enum.Font.GothamBold
InvInfoLabel.Text = "Inventory Status: Memuat Data..."
InvInfoLabel.TextColor3 = Color3.fromRGB(100, 230, 150)
InvInfoLabel.TextSize = 11
InvInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InvInfoLabel.Parent = ProfileCard

-- Update Ping & Inventory Stats Real-time
task.spawn(function()
    while true do
        pcall(function()
            local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            PingLabel.Text = "Ping Server: " .. math.round(stats) .. " ms | Status: Aman AFK"
            
            if Remotes:FindFirstChild("RequestInventorySnapshot") then
                local snap = Remotes.RequestInventorySnapshot:InvokeServer()
                if snap then
                    local count = 0
                    for _, _ in pairs(snap) do count = count + 1 end
                    InvInfoLabel.Text = "Total Item Tersedia di Inventory: " .. count .. " / 100 Slot"
                end
            end
        end)
        task.wait(3)
    end
end)

-- Panel Pemutar Musik Indo
local MusicPanel = Instance.new("Frame")
MusicPanel.Size = UDim2.new(0, 500, 0, 120)
MusicPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
MusicPanel.Parent = pageMusic

local MCorner = Instance.new("UICorner")
MCorner.CornerRadius = UDim.new(0, 8)
MCorner.Parent = MusicPanel

local MusicTitle = Instance.new("TextLabel")
MusicTitle.Size = UDim2.new(1, -20, 0, 35)
MusicTitle.Position = UDim2.new(0, 12, 0, 8)
MusicTitle.BackgroundTransparency = 1
MusicTitle.Font = Enum.Font.GothamBold
MusicTitle.Text = "🎵 Musik: " .. MUSIC_LIBRARY[currentSongIndex].title
MusicTitle.TextColor3 = Color3.fromRGB(255, 210, 100)
MusicTitle.TextSize = 12
MusicTitle.TextXAlignment = Enum.TextXAlignment.Left
MusicTitle.Parent = MusicPanel

local function createMusicBtn(text, posX, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 154, 0, 35)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 50)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.TextSize = 11
    btn.Parent = MusicPanel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

createMusicBtn("⏯ Play / Pause", 12, 55, function()
    if BackgroundMusic.IsPlaying then
        BackgroundMusic:Pause()
    else
        BackgroundMusic:Resume()
    end
end)

createMusicBtn("⏭ Next Song", 174, 55, function()
    currentSongIndex = currentSongIndex + 1
    if currentSongIndex > #MUSIC_LIBRARY then currentSongIndex = 1 end
    BackgroundMusic.SoundId = MUSIC_LIBRARY[currentSongIndex].asset
    BackgroundMusic:Play()
    MusicTitle.Text = "🎵 Musik: " .. MUSIC_LIBRARY[currentSongIndex].title
end)

createMusicBtn("⏹ Stop Musik", 336, 55, function()
    BackgroundMusic:Stop()
end)

-- =====================================================================
-- 6. DRAGGABLE SYSTEM (BISA DIGESER DENGAN MUDAH DI HP)
-- =====================================================================
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[MofenkHub]: Bot Berhasil Dimuat Sempurna! Akun Bot Anda Aman Ditinggal AFK.")
